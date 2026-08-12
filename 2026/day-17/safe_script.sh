#!/bin/bash

set -e

mkdir /tmp/devops-test || echo "Directory already exists"
cd /tmp/devops-test || echo "Can't change to this directory"
touch demo_file.txt || echo "file already exists"


