#!/bin/bash

CWD=$PWD

# Run init database
ant -buildfile /home/gcharland/git/Omnimed-solutions/build-tools/workspace/initDatabase.xml

# Run cukes
cd /home/gcharland/git/Omnimed-solutions/omnimed-test-e2e
npm run integration-test-dev

cd $CWD
