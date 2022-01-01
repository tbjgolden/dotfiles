#!/usr/bin/env sh

semver_regex() {
  local VERSION="([0-9]+)[.]([0-9]+)[.]([0-9]+)"
  local INFO="([0-9A-Za-z-]+([.][0-9A-Za-z-]+)*)"
  local PRERELEASE="(-${INFO})"
  local METAINFO="([+]${INFO})"
  echo "^${VERSION}${PRERELEASE}?${METAINFO}?$"
}

SEMVER_REGEX=`semver_regex`
unset -f semver_regex

semver_check() {
  echo $1 | grep -Eq "$SEMVER_REGEX"
}

semver_parse() {
  semver_check "$1" &&
  echo $1 | sed -E -e "s/$SEMVER_REGEX/\1 \2 \3 \5 \8/" -e 's/  / _ /g' -e 's/ $/ _/'
}

semver_compare() {
  if ! (semver_check "$1" && semver_check "$2"); then
    return 3
  fi

  A=`semver_parse "$1"`
  B=`semver_parse "$2"`
  set $A $B

  if [ $1 -gt $6 ]; then
    return 1;
  elif [ $1 -lt $6 ]; then
    return 2;
  elif [ $2 -gt $7 ]; then
    return 1;
  elif [ $2 -lt $7 ]; then
    return 2;
  elif [ $3 -gt $8 ]; then
    return 1;
  elif [ $3 -lt $8 ]; then
    return 2;
  else
    return 0;
  fi
}

semver_compare $1 $2
