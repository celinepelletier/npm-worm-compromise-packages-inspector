## NPM packages inspector 

This repo is made to help check if you are affected by https://www.stepsecurity.io/blog/ctrl-tinycolor-and-40-npm-packages-compromised#identify-and-remove-compromised-packages

Run the github repo inspector to find shai-hulud repo/branch/workflow 

```
./github-repo-inspector.sh <organization or username>
```

Run he package lock inspector to find if you have dependancies in the list of known affected dependancies in one of your repo (the list comes from the article up there and may not be exhaustive)

```
 ./package-lock-extractor.sh <organization or username>
```