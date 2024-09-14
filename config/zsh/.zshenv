export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MOZ_ENABLE_WAYLAND=1
export NEXT_TELEMETRY_DISABLED=1
export _JAVA_AWT_WM_NONREPARENTING=1
export JAVA_OPTS="-XX:+IgnoreUnrecognizedVMOptions"
export JAVA_HOME='/usr/lib/jvm/default'

export EDITOR=nvim

export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export GOPATH="$XDG_DATA_HOME/go"
export WINEPREFIX="$XDG_DATA_HOME/wine"
export ANDROID_HOME="$XDG_DATA_HOME/android"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export W3M_DIR="$XDG_DATA_HOME/w3m"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$XDG_CONFIG_HOME/zsh/.history"
export XINITRC="$XDG_CONFIG_HOME/X11/xinitrc"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export KDEHOME="$XDG_CONFIG_HOME/kde"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"

export LESSHISTFILE="$XDG_CACHE_HOME/less/history"

export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"

export HISTSIZE=1000000
export SAVEHIST=$HISTSIZE

typeset -U path PATH
path=(~/.local/bin $path $GOPATH/bin)
export PATH
