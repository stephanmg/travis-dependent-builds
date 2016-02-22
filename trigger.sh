#!/bin/bash
## simple wrapper script

USER=$1
DOWNSTREAM_REPO=$2
BRANCH=$3
TRAVIS_ACCESS_TOKEN=$4

if [[ ($TRAVIS_BRANCH == $3) &&
   ($TRAVIS_PULL_REQUEST == false) &&
   ( (! $TRAVIS_JOB_NUMBER == *.*) || ($TRAVIS_JOB_NUMBER == *.1) ) ]] ; then
   ./trigger-travis.sh $1 $2 $4
fi
