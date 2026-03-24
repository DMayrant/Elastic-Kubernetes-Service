#!/bin/bash

# Pushing VS code project to Repo
# create a public repo with NO readme.md 

# from VS code project directory 

git init
git add .
git commit -m "initial commit"

git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

git branch -M main
git push -u origin main
# OR 
git rebase --abort
git push -u origin main --force

# After making changes to file 

git status
git add <filename>
git commit -m "update"
git push
