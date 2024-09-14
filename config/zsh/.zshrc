fpath=(/usr/share/zsh/site-functions $fpath)

setopt    autocd
setopt    histverify
unsetopt  beep
setopt    hist_ignore_space
bindkey   -e
stty      stop undef		# Disable ctrl-s to freeze terminal.

bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

autoload -Uz compinit
compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION
zmodload zsh/complist

autoload -Uz run-help
(( ${+aliases[run-help]} )) && unalias run-help
autoload -Uz run-help-git run-help-ip run-help-openssl run-help-p4 run-help-sudo run-help-svk run-help-svn

# stolen from omz
__sudo-replace-buffer() {
  local old=$1 new=$2 space=${2:+ }

  # if the cursor is positioned in the $old part of the text, make
  # the substitution and leave the cursor after the $new text
  if [[ $CURSOR -le ${#old} ]]; then
    BUFFER="${new}${space}${BUFFER#$old }"
    CURSOR=${#new}
  # otherwise just replace $old with $new in the text before the cursor
  else
    LBUFFER="${new}${space}${LBUFFER#$old }"
  fi
}

sudo-command-line() {
  # If line is empty, get the last run command from history
  [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"

  # Save beginning space
  local WHITESPACE=""
  if [[ ${LBUFFER:0:1} = " " ]]; then
    WHITESPACE=" "
    LBUFFER="${LBUFFER:1}"
  fi

  {
    # If $SUDO_EDITOR or $VISUAL are defined, then use that as $EDITOR
    # Else use the default $EDITOR
    local EDITOR=${SUDO_EDITOR:-${VISUAL:-$EDITOR}}

    # If $EDITOR is not set, just toggle the sudo prefix on and off
    if [[ -z "$EDITOR" ]]; then
      case "$BUFFER" in
        sudo\ -e\ *) __sudo-replace-buffer "sudo -e" "" ;;
        sudo\ *) __sudo-replace-buffer "sudo" "" ;;
        *) LBUFFER="sudo $LBUFFER" ;;
      esac
      return
    fi

    # Check if the typed command is really an alias to $EDITOR

    # Get the first part of the typed command
    local cmd="${${(Az)BUFFER}[1]}"
    # Get the first part of the alias of the same name as $cmd, or $cmd if no alias matches
    local realcmd="${${(Az)aliases[$cmd]}[1]:-$cmd}"
    # Get the first part of the $EDITOR command ($EDITOR may have arguments after it)
    local editorcmd="${${(Az)EDITOR}[1]}"

    # Note: ${var:c} makes a $PATH search and expands $var to the full path
    # The if condition is met when:
    # - $realcmd is '$EDITOR'
    # - $realcmd is "cmd" and $EDITOR is "cmd"
    # - $realcmd is "cmd" and $EDITOR is "cmd --with --arguments"
    # - $realcmd is "/path/to/cmd" and $EDITOR is "cmd"
    # - $realcmd is "/path/to/cmd" and $EDITOR is "/path/to/cmd"
    # or
    # - $realcmd is "cmd" and $EDITOR is "cmd"
    # - $realcmd is "cmd" and $EDITOR is "/path/to/cmd"
    # or
    # - $realcmd is "cmd" and $EDITOR is /alternative/path/to/cmd that appears in $PATH
    if [[ "$realcmd" = (\$EDITOR|$editorcmd|${editorcmd:c}) \
      || "${realcmd:c}" = ($editorcmd|${editorcmd:c}) ]] \
      || builtin which -a "$realcmd" | command grep -Fx -q "$editorcmd"; then
      __sudo-replace-buffer "$cmd" "sudo -e"
      return
    fi

    # Check for editor commands in the typed command and replace accordingly
    case "$BUFFER" in
      $editorcmd\ *) __sudo-replace-buffer "$editorcmd" "sudo -e" ;;
      \$EDITOR\ *) __sudo-replace-buffer '$EDITOR' "sudo -e" ;;
      sudo\ -e\ *) __sudo-replace-buffer "sudo -e" "$EDITOR" ;;
      sudo\ *) __sudo-replace-buffer "sudo" "" ;;
      *) LBUFFER="sudo $LBUFFER" ;;
    esac
  } always {
    # Preserve beginning space
    LBUFFER="${WHITESPACE}${LBUFFER}"

    # Redisplay edit buffer (compatibility with zsh-syntax-highlighting)
    zle redisplay
  }
}

zle -N sudo-command-line

# Defined shortcut keys: [Esc] [Esc]
bindkey -M emacs '\e\e' sudo-command-line
bindkey -M vicmd '\e\e' sudo-command-line
bindkey -M viins '\e\e' sudo-command-line

# Completions
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $XDG_CACHE_HOME/zsh/zcompcache

# use the vi navigation keys in menu completion
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Shift-Tab to go to the previous completion
bindkey -M menuselect '^[[Z' reverse-menu-complete

# Begin Hooks
autoload -Uz add-zsh-hook

reset_broken_terminal() {
  printf '%b' '\e[0m\e(B\e)0\017\e[?5l\e7\e[0;0r\e8'
}
add-zsh-hook -Uz precmd reset_broken_terminal

zshcache_time="$(date +%s%N)"
rehash_precmd() {
  if [[ -a /var/cache/zsh/pacman ]]; then
    local paccache_time="$(date -r /var/cache/zsh/pacman +%s%N)"
    if (( zshcache_time < paccache_time )); then
      rehash
      zshcache_time="$paccache_time"
    fi
  fi
}
add-zsh-hook -Uz precmd rehash_precmd

clear-screen-and-scrollback() {
    echoti civis >"$TTY"
    printf '%b' '\e[H\e[2J' >"$TTY"
    zle .reset-prompt
    zle -R
    printf '%b' '\e[3J' >"$TTY"
    echoti cnorm >"$TTY"
}

zle -N clear-screen-and-scrollback
bindkey '^L' clear-screen-and-scrollback

bindkey -s '^f' 'tmux-sessionizer\n'
# End Hooks

# Begin exports
export WORDCHARS=${WORDCHARS/\/}

export GPG_TTY=$(tty)
gpgconf --launch gpg-agent

export FZF_DEFAULT_COMMAND="fd --threads $(nproc) --type file --strip-cwd-prefix --hidden --follow --exclude .git"

export FZF_DEFAULT_OPTS="
    --layout=reverse
    --bind 'ctrl-e:preview-down'
    --bind 'ctrl-y:preview-up'
    --bind 'ctrl-d:preview-half-page-down'
    --bind 'ctrl-u:preview-half-page-up'
    --bind 'ctrl-f:preview-page-down'
    --bind 'ctrl-b:preview-page-up'
    --bind 'shift-up:preview-top'
    --bind 'shift-down:preview-bottom'"

export FZF_ALT_C_COMMAND="fd --threads $(nproc) --type directory --hidden --follow --exclude .git"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:toggle-preview'
  --color header:italic
  --header 'Press CTRL-/ to toggle preview'"

export FZF_CTRL_R_OPTS="
  --exact
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"
# End exports

# Begin Functions
ext () {
  if [ -f $1 ]; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar.xz)    tar -xf $1   ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ext()"; return 1 ;;
    esac
  else
    echo "'$1' is not a valid file"
    return 1
  fi
}

command_not_found_handler () {
    local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
    printf 'zsh: command not found: %s\n' "$1"
    local entries=(
        ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"}
    )
    if (( ${#entries[@]} ))
    then
        printf "${bright}$1${reset} may be found in the following packages:\n"
        local pkg
        for entry in "${entries[@]}"
        do
            # (repo package version file)
            local fields=(
                ${(0)entry}
            )
            if [[ "$pkg" != "${fields[2]}" ]]
            then
                printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
            fi
            # printf '    /%s:' "${fields[4]}"
            printf '    %s\n' "$(pacman -Si "${fields[2]}" 2>/dev/null | sed -n 's/^Description *: //p')"
            pkg="${fields[2]}"
        done
    fi
    return 127
}

cdw () {
  local w="$(which "$1" 2>/dev/null)"
  [ -n "$w" ] && cd "$(dirname "$w")" || return 127
}

mkcd () {
  mkdir -p "$1" && cd "$1"
}

disass () {
    local file
    file="${1/#\~/$HOME}"
    [[ ! -f "$file" ]] && echo "invalid file" >&2 && return 1

    local symbol
    symbol="${2:-$(fzf \
        --prompt "symbol: " \
        --preview \
            "objdump -SCwj .text \
            -Mintel \
            --no-show-raw-insn \
            --no-addresses \
            --disassemble={} "$file" |
            sed 's| *#.*||'" < \
            <(nm --defined-only --demangle "$file" 2>/dev/null | cut -d' ' -f3-))}"
    [[ -z "$symbol" ]] && return 1

    objdump -SCwj .text \
        -Mintel \
        --no-show-raw-insn \
        --no-addresses \
        --visualize-jumps=extended-color \
        --disassembler-color=extended-color \
        --disassemble="$symbol" "$file" | sed 's| *#.*||'
}

_disass () {
    local state
    _arguments \
        '1:filename:_files' \
        '2:symbols:->symbols'

    case $state in
        symbols)
            local symbols
            local file
            file="${words[2]/#\~/$HOME}"
            symbols=("${(@f)"$(nm --defined-only --demangle "$file" 2>/dev/null | cut -d' ' -f3-)"}")
            [[ -z "$symbols" ]] && return 1
            compadd "${symbols[@]}"
            ;;
    esac
}

compdef _disass disass

.. () {
  local count="${1:-1}"
  for i in {1..$count}; do
    builtin cd ..
  done
}

muc () {
 print -l ${(o)history%% *} | uniq -c | sort -nr
}

add-alias () {
  [ $# -ne 2 ] && echo "Usage: $0 <aliased_command> <command>" >&2 && return 1
  local al="$1"
  local cmd="$2"
  sed -i "s:^\(# End Aliases\):alias $al='$cmd'\n\1:g" "${ZDOTDIR:-$HOME}/.zshrc" && source "${ZDOTDIR:-$HOME}/.zshrc"
}

PASTE_HIST_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/.paste_history"

paste () {
  local file=${1:-/dev/stdin}
  local url="$(curl -fsSL --data-binary @"${file}" https://paste.rs)"
  [ $? -ne 0 ] && echo "Failed to paste" >&2 && return 1
  echo "$url" | tee -a "$PASTE_HIST_FILE"
}

_paste () {
  _files
}

compdef _paste paste

delete-paste () {
  local paste_id="${1:-$(fzf --preview 'curl -sL {} | bat --color=always --style=numbers' < "$PASTE_HIST_FILE")}"
  [ -z "$paste_id" ] && return 1
  curl -X DELETE "$paste_id"
  local escaped_paste_id="$(echo "$paste_id" | sed 's/\//\\\//g')"
  sed -i "/^${escaped_paste_id}$/d" "$PASTE_HIST_FILE"
}

# tab completion that will list all pastes in the paste history file for delete-paste
_delete-paste () {
    # (@f) splits the file into an array by newlines (the default)
    # there are other tags each has their own purpose, for example:
    #   @s splits by spaces
    #   @m splits by newlines and removes empty lines
    #   @n splits by newlines and keeps empty lines
    #   @w splits by words
    #   @c splits by characters
    #   @C splits by characters and keeps empty lines
    #   @F splits by fields
    #   @M splits by matches
    #   @O splits by offsets
    #   @Q splits by quoted strings
    #   @R splits by regex
    #   @S splits by shwords
    #   @T splits by tabs
    #   @U splits by unquoted strings
    #   @W splits by words
    #   @X splits by extended glob
    #   @Z splits by null bytes
    local paste_ids=("${(@f)$(cat "$PASTE_HIST_FILE")}")
    compadd "${paste_ids[@]}"
}

compdef _delete-paste delete-paste

mknote () {
    local notes_dir="${NOTES_DIR:-$HOME/notes}"
    if [[ "$1" == "-l" ]]; then
        local note_file="$(fd . --type=file "$notes_dir" | fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}')"
        [[ -f "$note_file" ]] && ${EDITOR:-nvim} "$note_file"
    else
        local name="$(date +%Y-%m-%d)$([[ -n "$1" ]] && echo "-$1")"
        local note_file="$notes_dir/$name.md"
        mkdir -p "$(dirname "$note_file")"
        [[ -f "$note_file" ]] || echo "# $name" > "$note_file"
        ${EDITOR:-nvim} "$note_file"
    fi
}

go-init () {
    local user="$(git config --get user.name)"
    [ -z "$user" ] && echo "Failed to get username from git!" >&2 && return 1

    local basename="$(basename "$PWD")"
    go mod init "github.com/$user/$basename"
}

ch () {
    curl -fsSL "https://cheat.sh/$1"
}

wf () {
    local file="${1:?File name is required}"
    shift
    [ -f "$file" ] || {
        echo "$file is not a valid file!" >&2 
        return 1
    }
    tail -f "$file" | bat --paging=never "$@"
}

help() {
    "$@" --help 2>&1 | bat --plain --language=help
}

dockershellhere() {
    dirname=${PWD##*/}
    docker run --rm --interactive --tty --entrypoint=/bin/bash -v $(pwd):/${dirname} --workdir /${dirname} "$@"
}

dockershellshhere() {
    dirname=${PWD##*/}
    docker run --rm --interactive --tty --entrypoint=/bin/sh -v $(pwd):/${dirname} --workdir /${dirname} "$@"
}

tmuxhere () {
    local session_name="${1:-$(basename "$PWD")}"
    tmux new-session -s "$session_name"
}

findprojects () {
    builtin cd -- \
        "$(fd . --max-depth=1 --threads=$(nproc) --type=directory --hidden --follow --exclude={.bzr,CVS,.git,.hg,.svn,.idea,.tox,node_modules,target,build} ~/Projects ~/Playground | \
        fzf --preview 'exa --tree --icons --git --git-ignore --group-directories-first --color=always --level=3 --ignore-glob="node_modules|target|build" {}')"
    zle reset-prompt
}

zle -N findprojects

bindkey '^o' findprojects

vf () {
    if [[ $# -eq 0 ]]; then
        fzf --preview 'bat -n --color=always {}' --bind 'enter:become(nvim {+})'
    else
        nvim "$@"
    fi
}

vg () {
    local initial_query="$1"
    local rg_prefix="rg --column --line-number --no-heading --color=always --smart-case "
    local result="$(FZF_DEFAULT_COMMAND="$rg_prefix '$initial_query'" \
        fzf --bind "change:reload:$rg_prefix {q} || true" \
        --ansi --disabled --query "$initial_query" \
        --height=50% --layout=reverse)"

    if [[ -n "$result" ]]; then
        local file="$(echo "$result" | cut -d':' -f1)"
        local line="$(echo "$result" | cut -d':' -f2)"
        nvim "$file" "+$line"
    fi
}

nvim-server () {
    local ip="${1:-0.0.0.0}"
    local port="${2:-6666}"
    echo "[$(date "+%Y/%m/%d %H:%M:%S")] Starting nvim server at $ip:$port"
    nvim --listen "$ip:$port" --headless
    echo "[$(date "+%Y/%m/%d %H:%M:%S")] Stopped nvim server at $ip:$port"
}

nvim-client () {
    local ipport="${1:?IP:PORT is required}"
    nvim --remote-ui --server "$ipport"
}

dirdiff () {
    local left="${1:?Left directory is required}"
    local right="${2:?Right directory is required}"
    diff --unified --recursive "$left" "$right" | delta
}

exit_zsh() { exit }
zle -N exit_zsh
bindkey '^D' exit_zsh
# End Functions

# Begin Aliases
alias :q='exit'
alias a2c-http='aria2c --lowest-speed-limit=1K --http-user-agent="Mozilla/5.0" --http-accept-gzip=true'
alias a2c-max='aria2c --max-connection-per-server=16 --split=16 --min-split-size=1M --continue=true'
alias a2c-torrent='a2c-max --bt-metadata-only=true --follow-torrent=true --check-certificate=false'
alias a2c='aria2c'
alias ac='ani-cli'
alias clear='tput clear'
alias cls='tput clear'
alias decrypt='gpg --decrypt'
alias dockershell='docker run --rm --interactive --tty --entrypoint=/bin/bash'
alias dockershellsh='docker run --rm --interactive --tty --entrypoint=/bin/sh'
alias dump='od -w16 -A x -t x1z -v'
alias egrep='egrep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
alias encrypt='gpg --symmetric --force-mdc --cipher-algo aes256 --armor'
alias fgrep='fgrep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gcl='git clone --depth 1'
alias gcm='git commit -m'
alias gd='git diff'
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
alias gs='git status'
alias ida32='wine ~/RE/idapro/ida.exe &>/dev/null & disown'
alias ida='wine64 ~/RE/idapro/ida64.exe &>/dev/null & disown'
alias j='just'
alias junk='yay -Qdtq'
alias ll='exa -lah --icons --git --group-directories-first'
alias ls='exa'
alias lzd='lazydocker'
alias lzg='lazygit'
alias pcp='rsync -ah --progress'
alias prp='pacman -Qq | fzf --multi --preview "pacman -Qi {1}" | xargs -ro sudo pacman -Rcns'
alias psi='pacman -Slq | fzf --multi --preview "pacman -Si {1}" | xargs -ro sudo pacman -S'
alias pubip="curl -fsSL https://httpbin.org/get | jq -r '.origin'"
alias py='python'
alias rced="${EDITOR:-nvim} ${ZDOTDIR:-$HOME}/.zshrc && source ${ZDOTDIR:-$HOME}/.zshrc"
alias sd='systemd-analyze'
alias shn='shutdown now'
alias tmp='cd $(mktemp -d)'
alias tn='tmux new -s "$(basename $(pwd))"'
alias v='nvim'
alias vd='neovide'
alias wreboot='systemctl reboot --boot-loader-entry=auto-windows'
alias x='exit'
alias xo='xdg-open'
alias y='yay'
alias yeet='yay -Rcns'
alias yps='yay -Ps'
alias yq='yay -Q'
alias yqi='yay -Qi'
alias yqq='yay -Qq'
alias ys='yay -S'
alias ysi='yay -Si'
alias yss='yay -Ss'
alias ytmp3='yt-dlp -x --audio-format mp3 --audio-quality 320k -o "%(title)s.%(ext)s"'
# End Aliases

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

bindkey '^ ' autosuggest-accept


eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"
