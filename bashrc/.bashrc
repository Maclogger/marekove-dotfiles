# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
#
# Use VSCode instead of neovim as your default editor
# export EDITOR="code"
#
# Set a custom prompt with the directory revealed (alternatively use https://starship.rs)
# PS1="\W \[\e]0;\w\a\]$PS1"
eval "$(starship init bash)"

alias sail=./vendor/bin/sail

# Start ssh-agent if it's not already running and add your key
if ! pgrep -U "$USER" ssh-agent >/dev/null; then
  eval "$(ssh-agent -s)" >/dev/null
  ssh-add ~/.ssh/id_rsa >/dev/null
fi
