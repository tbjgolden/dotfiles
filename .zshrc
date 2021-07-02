export ZSH="$HOME/.oh-my-zsh"

HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="true"
DISABLE_UPDATE_PROMPT="true"
HIST_STAMPS="yyyy-mm-dd"

# Plugins in $ZSH/plugins/ and $ZSH_CUSTOM/plugins/
plugins=(colored-man-pages command-not-found docker git npm pep8 pip pyenv python sudo zsh_reload zsh-autosuggestions fast-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

eval "$(direnv hook zsh)"
eval "$(starship init zsh)"
