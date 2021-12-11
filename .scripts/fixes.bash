# electron trash needs to use kioclient5 if it's installed
if [ "$XDG_CURRENT_DESKTOP" == "KDE" ]; then
  if [ "$(grep -c 'ELECTRON_TRASH' $HOME/.envrc)" == "0" ]; then
    echo 'Adding ELECTRON_TRASH=kioclient5 to .envrc'
    echo "ELECTRON_TRASH=kioclient5" >> $HOME/.envrc
  fi
fi
