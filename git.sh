#!/bin/bash
 
cd pwd/public/

git init
git add .
git commit -m "blog updata"
git remote add origin git@github.com:nyarukov/nyarukov.github.io.git
git push origin

cd ../