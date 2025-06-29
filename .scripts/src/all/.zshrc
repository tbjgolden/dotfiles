source $HOME/.scripts/env.zsh
source $HOME/.scripts/plugins/*/*.plugin.zsh

# load zsh plugins
PLUGINS="fast-syntax-highlighting last-working-dir zsh-autosuggestions zsh-history-substring-search"
for plugin in $( echo $PLUGINS | xargs ); do
  source $HOME/.scripts/plugins/$plugin/$plugin.plugin.zsh
done

alias nano='vim'

# check for updates
eval "$(starship init zsh)"

