#!/bin/bash
echo $(git --no-pager log -1 --pretty=format:%h $1)
