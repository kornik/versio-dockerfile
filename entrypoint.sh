#!/bin/sh -l

/bin/versio $1
time=$(date)
echo "time=$time" >> $GITHUB_OUTPUT