#!/bin/bash

git config user.name "Travis CI"
git config user.email "$COMMIT_AUTHOR_EMAIL"

# Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc
ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in deploy_key.enc -out deploy_key -d
chmod 600 deploy_key
eval `ssh-agent -s`
ssh-add deploy_key

docker pull kaizhang/haskell-stack
docker run -v `pwd`:/build:rw kaizhang/haskell-stack /bin/bash -c \
    "cd build && stack build --allow-different-user"
