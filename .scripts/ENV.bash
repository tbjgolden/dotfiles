# create file if it doesn't already exist
ENV_FILE=$HOME/ENV.json
if [ ! -f "$ENV_FILE" ]; then
  echo "{}" > $ENV_FILE
elif [[ -z $(grep '[^[:space:]]' $ENV_FILE) ]]; then
  echo "{}" > $ENV_FILE
fi

# check syntax
cat $ENV_FILE | jq "." &>/dev/null
if [ $? -ne "0" ]; then
  echo "Syntax error in $ENV_FILE"
  exit
fi

X=$( cat $ENV_FILE | jq -r 'to_entries[] | "\(.key), \(.value)"' )

echo $?
echo $X
