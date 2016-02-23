#!/bin/bash
## brief: trigger a downstream travis build
## see: travis API documentation
##

USER=$1
REPO=$2
TRAVIS_ACCESS_TOKEN=$3
BRANCH=$4
MESSAGE=$5

travis login --skip-completion-check --github-token $TRAVIS_ACCESS_TOKEN
travis whoami --skip-completion-check
TOKEN=$(travis token --skip-completion-check)
IFS=' ' read -r -a array <<< "$TOKEN"
echo "Token: ${array[${#array[@]}-1]}"
MY_TOKEN=${array[${#array[@]}-1]}
TOKEN=$MY_TOKEN

if [ $# -eq 5 ] ; then
    MESSAGE=",\"message\": \"$5\""
elif [ -n "$TRAVIS_REPO_SLUG" ] ; then
    MESSAGE=",\"message\": \"Triggered by upstream build of $TRAVIS_REPO_SLUG commit "`git rev-parse --short HEAD`"\""
else
    MESSAGE=""
fi
## For debugging:
echo "MESSAGE=$MESSAGE"
echo "TOKEN=$TOKEN"
echo "USER=$USER"
echo "REPO=$REPO"

body="{
\"request\": {
  \"branch\":\"$BRANCH\"
  $MESSAGE
}}"

curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Travis-API-Version: 3" \
  -H "Authorization: token ${TOKEN}" \
  -d "$body" \
  https://api.travis-ci.org/repo/${USER}%2F${REPO}/requests \
 | tee /tmp/travis-request-output.$$.txt

if grep -q '"@type": "error"' /tmp/travis-request-output.$$.txt; then
    exit 1
fi
if grep -q 'access denied' /tmp/travis-request-output.$$.txt; then
   echo && echo "Error:" 
   cat /tmp/travis-request-output.$$.txt
    exit 1
fi
