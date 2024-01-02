#!/bin/bash

CWD=$PWD

# Run cukes
runcukes

# Run init database
initdb

cd $CWD
