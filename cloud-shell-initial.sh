#!/bin/sh

# Generate SSH
rsaKeyFile=/home/cloudshell-user/.ssh/id_rsa
if [ ! -f "$rsaKeyFile" ]; then
    #add rsa key
    ssh-keygen -b 2048 -t rsa -f "$rsaKeyFile" -q -N ""
    echo "Please copy the following into your profile here: https://bitbucket.org/account/settings/ssh-keys and https://gitlab.com/-/user_settings/ssh_keys
    "
    cat ~/.ssh/id_rsa.pub

    read -r -p "Press any key to continue...
    "
fi

# Configure VIM
cat <<'EOF' > ~/.vimrc
source /usr/share/vim/vim82/defaults.vim
set mouse=
EOF

# Create .local/bin
mkdir -p $HOME/.local/bin

# Install Docker Compose v2
export DOCKER_COMPOSE_DLVERSION=v2.24.2
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_DLVERSION/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
docker compose version

# Install Helm
export HELM_DLVERSION=v3.14.0
wget https://get.helm.sh/helm-${HELM_DLVERSION}-linux-amd64.tar.gz
tar xvfz helm-${HELM_DLVERSION}-linux-amd64.tar.gz
mv linux-amd64/helm ~/.local/bin
rm -rf helm-${HELM_DLVERSION}-linux-amd64.tar.gz linux-amd64/

PATH="$HOME/.local/bin:$PATH"

# Put Bash Completion into .bashrc file
if ! grep -q 'kubectl completion bash' ~/.bashrc
then
  tee -a ~/.bashrc > /dev/null <<EOT

if [ -d "$HOME/.local/bin" ] ; then
  PATH="$HOME/.local/bin:$PATH"
fi

# Bash Completion
. <(kubectl completion bash)
. <(helm completion bash)
EOT
fi

source <(kubectl completion bash)
source <(helm completion bash)

sudo ssh-keyscan -H github.com >> ~/.ssh/known_hosts
sudo ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts
sudo ssh-keyscan -H gitlab.com >> ~/.ssh/known_hosts

# Git config
git config --global init.defaultBranch "main"
git config --global pull.rebase false
