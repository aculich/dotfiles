#!/bin/bash

cat extensions.list | xargs -L 1 code --force --install-extension
cursor --list-extensions > extensions.list

