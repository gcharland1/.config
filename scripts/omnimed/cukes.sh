#!/bin/bash

CWD=$PWD

# Run cukes
cd /home/gcharland/git/Omnimed-solutions/omnimed-test-e2e
npm run integration-test-dev

cd $CWD
