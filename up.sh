#!/bin/bash

/home/yusaka/opt/hugo/hugo

cd pubilc

git init 
git add .
git commit -m "Resolved merge conflicts"
git push -f origin master

cd ../
