#!/usr/bin/env zsh
# Source my POSIX aliases.
source ~/.config/shell/aliases.sh

sc() {
	pwd > ~/.config/current_project
}

gp() {
	{ read dir; cd "$dir"; } < ~/.config/current_project
}

keypress() {
	xev | awk -F'[ )]+' '/^KeyPress/ { a[NR+2] } NR in a { printf "%-3s %s\n", $5, $8 }'
}

homeadd() {
  cat ~/.config/dotfiles.dots | grep -v '^#' | sed "s|^~|$HOME|" | xargs -I {} git --git-dir=$HOME/.cfg/ --work-tree=$HOME add {}
}

gp

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob nomatch notify
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install

# Configure syntax highlighting
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Configure autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh

# Configure the $PATH
fpath+=($HOME/.zsh/pure)
autoload -Uz promptinit;
promptinit;
prompt pure;

# Load any convenient secrets if they exist.
if [ -f ~/.secrets.sh ]; then
  source ~/.secrets.sh
fi

# Hook mise into the shell
eval "$(mise hook-env -s zsh)"

