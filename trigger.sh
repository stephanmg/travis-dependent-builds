#!/bin/bash
## brief: wrapper script which calls trigger-travis
## If the branch name of the upstream and downstream project are equal and
## we have a valid travis configuration in the downstream project then
## try to trigger a travis build with the given github/travis user and
## the given github/travis access token

# arguments
USER=$1
DOWNSTREAM_REPO=$2
BRANCH=$3
TRAVIS_ACCESS_TOKEN=$4

# check for correct input
if [[ ! $# == 4 ]] && usage

# trigger build if above conditions hold
if [[ ($TRAVIS_BRANCH == $3) &&
   ($TRAVIS_PULL_REQUEST == false) &&
   ( (! $TRAVIS_JOB_NUMBER == *.*) || ($TRAVIS_JOB_NUMBER == *.1) ) ]] ; then
   ./trigger-travis.sh $1 $2 $4 $3
fi

# help function
usage() {
   echo "$(basename $0): USER DOWNSTREAM_REPOSITORY BRANCH TRAVIS_ACCESS_TOKEN"
}
