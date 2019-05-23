#!/usr/bin/env bash

set -ev

ls -al $HOME/helics

tar -zcvf helics-v$HELICS_VERSION-$TRAVIS_OS_NAME-$PYTHON_ARCH.tar.gz $HOME/helics

pwd
ls -al
