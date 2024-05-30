echo "https://${PRIVATE_REPO_USER}:${PRIVATE_REPO_TOKEN}@${PRIVATE_REPO}" > ~/.gitcredentials.store
git config --global credential.helper 'store --file ~/.gitcredentials.store'
git config --global advice.detachedHead false
git clone $IAC_TERRAFORM_MODULES_REPO
cd govstack-sandbox-infra-oci
git checkout $IAC_TERRAFORM_MODULES_TAG

