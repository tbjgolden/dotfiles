HYPHEN_INSENSITIVE="true"
HIST_STAMPS="yyyy-mm-dd"

plugins=(colored-man-pages command-not-found docker git npm pep8 pip pyenv python sudo zsh_reload zsh-autosuggestions fast-syntax-highlighting)

source $HOME/.scripts/functions.sh
source $HOME/.scripts/aliases.sh
source $HOME/.scripts/plugins/**/*.plugin.zsh

eval "$(starship init zsh)"
