#!/usr/bin/bash

git --git-dir=/home/gcharland/git/Omnimed-solutions/.git rev-parse --abbrev-ref HEAD | xclip -selection clipboard

google-chrome https://jenkins.omnimed.com/job/MergebackFeatureBranch/build?delay=0sec
