<<<<<<< ↓ LOCAL ↓
eval "$(direnv hook $SHELL)"
=======
source $HOME/.scripts/env.zsh
source $HOME/.scripts/plugins/*/*.plugin.zsh
>>>>>>> ↑ REMOTE ↑

<<<<<<< ↓ LOCAL ↓
=======
# load zsh plugins
PLUGINS="fast-syntax-highlighting last-working-dir zsh-autosuggestions zsh-history-substring-search"
for plugin in $( echo $PLUGINS | xargs ); do
  source $HOME/.scripts/plugins/$plugin/$plugin.plugin.zsh
done

# check for updates
eval "$(starship init zsh)"
>>>>>>> ↑ REMOTE ↑
