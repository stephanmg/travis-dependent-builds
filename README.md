# travis-dependent-builds

Try to trigger downstream Travis projects from upstream Travis projects
hosted on github with a miminum of cluttering your current `travis.yml`
configuration of the upstream project (see prerequisites please).

Consider the following scenario (cf. figure below), i.e. the *DOWNSTREAM* 
projects depend on the *UPSTREAM* project and need to be build if the
*UPSTREAM* project was triggered by a new commit. Therefore we
can ensure, if the *UPSTREAM* project has changed and was tested
with success, that the dependent *DOWNSTREAM* projects are also
tested against the changes in the upstream project. This is to 
make sure that the changes in the *UPSTREAM* project  did really not
 harm the *DOWNSTREAM* projects by this given commit.

Please note, if a dependent project has been triggered by our
scripts, we log a message in the dependent Travis project (i. e.
triggered by upstream project with commit id 1c1234), to make it easy 
to find the commit of the *UPSTREAM* project which triggered the current
dependent project build and eventually made the *DOWNSTREAM* project fail.

![Dependent builds](/data/img/travis-dependent-builds.png)

## Usage
Consider you have an empty Python upstream project for now, e. g.:

```yml
language: 
   - python

python:
   - "2.6"

script:
   -
```

To trigger a downstream project (either your own or from a different user),
e. g. after success of testing, or in general after all your tests have been run, 
insert this snippet (note you can exchange *after_script* with for instance *after_success*, 
or anything you think should be appropriate for your usecase) into your `travis.yml`:

```yml
before_script:
   - gem install travis

after_script:
   - curl -LO https://raw.github.com/stephanmg/travis-dependent-builds/master/trigger.sh
   - chmod +x trigger.sh
   - ./trigger.sh stephanmg downstream master $TRAVIS_ACCESS_TOKEN 
```

This results in the following travis yml file:
```yml
language: 
   - python

python:
   - "2.6"

before_script:
   - gem install travis

script:
   -

after_script:
   - curl -LO https://raw.github.com/stephanmg/travis-dependent-builds/master/trigger.sh
   - chmod +x trigger.sh
   - ./trigger.sh stephanmg downstream master $TRAVIS_ACCESS_TOKEN 
```

### Explanation
The first curl statement, fetch the most recent version of the helper scripts
`trigger.sh` from the repository you are currently reading this README. 
The `chmod` makes the trigger.sh script executable.
The next line actually triggers a downstream project, termed *downstream*, 
of the github/travis user *stephanmg*, if the upstream project uses the 
master branch then a new build of the corresponding master branch of 
the downstream project will be scheduled. The TRAVIS_ACCESS_TOKEN
is the environement variable actually is your github token which you are
supposed to provide in the corresponding downstream travis project you want
to trigger (cf. prerequisites below).

### Prerequisites

1. Token
As a prerequisit you need to generate a TOKEN from Github's website,
e. g. go to your user profile, navigate to settings, generate an
as restrictive as possible TOKEN, and assign it a name, e. g. 
*TRAVIS*.
2. Settings 
Next, navigate to your Travis projects, for instance if your user is
*stephanmg* (github/travis) and your project *downstream* then go to:
https://travis-ci.org/stephanmg/downstream/settings
There you need to define a variable, termed e. g. TRAVIS_ACCESS_TOKEN
and assign the value of the TOKEN you generated previously. This variable
will be available in our `travis.yml` file by $TRAVIS_ACCESS_TOKEN.
This allows you to login passwordless in a e. g. shell script on the
travis build environment to your given downstream travis project,
and for instance trigger a new build (this could also be a downstream
project of a different user, if you know the variable which is used
for the TOKEN, e. g. could be different than TRAVIS_ACCESS_TOKEN, and
the corresponding username and of course the repository name itself)
* Optionally specify a branch to use
* Optionally multiple trigger statements

In the *after_script* section you could then have a various of `trigger`
statements, e. g.:

```yml
after_script:
   - ./trigger.sh stephanmg downstream master $TRAVIS_ACCESS_TOKEN 
   - ./trigger.sh othergithubuser downstreamProject2 devel $OUR_AGREED_ACCESS_TOKEN_VAR
   - ./trigger ...
```

# Future enhancements on demand
* upstream and downstream project branch are assumed to be the same, this could be more
flexible, i. e. allow for different branches
* provide a configuration file for the `trigger.sh` script, i. e. reduce call in your
`travis.yml` file to `./trigger.sh --conf dependent-builds.yml`, i. e. storing all relevant
information in `dependent-builds.yml` file.

# Caveats
If you're using a build matrix for your *UPSTREAM* project, then for each entry
you end up with a triggered *DOWNSTREAM* project. There might be a workaround for
this in the future - or if included in the Travis API soon hopefully.

# Questions
Feel free to message me - [see my profile](https://github.com/stephanmg)

# See 
[Travis API documentation](https://docs.travis-ci.com/user/triggering-builds/)
