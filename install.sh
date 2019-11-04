#!/bin/bash

set -e
set -x

GO_VERSION="1.13"
GOPATH="`pwd`/code"

INSTALL_PACKAGES=(
  # vim
  vim-nox
  # docker
  apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  # dev
  git
  curl
  build-essential
  python3-pip
  virtualenvwrapper
  silversearcher-ag
  htop
  iftop
  iotop
  ipython3
  net-tools
  ethtool
  pv
)


UNINSTALL_PACKAGES=(
  # docker (packages from ubuntu repo)
  docker docker-engine docker.io containerd runc
)

sudo apt update
sudo apt purge -y "${UNINSTALL_PACKAGES[@]}"
sudo apt install -y "${INSTALL_PACKAGES[@]}"

# bash
mkdir -p ~/.bash
mkdir -p ~/bin

rm -rf ~/.bash/git-aware-prompt
git clone git://github.com/jimeh/git-aware-prompt.git ~/.bash/git-aware-prompt

if [[ ! -v SKIP_YAK ]];then
  cp `pwd`/yak ~/bin
fi

# vim
rm -fr ~/.vim
git clone https://github.com/lukaszo/.vim.git ~/.vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

rm -f ~/.vimrc
ln -s ~/.vim/.vimrc ~/.vimrc

pip3 install pynvim
vim +PluginInstall +qall
vim +:GoInstallBinaries +qall

# docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker "${USER}"

# golang
export GOPATH
mkdir -p ${GOPATH}/{bin,src,pkg}

curl -sL -o ~/bin/gimme https://raw.githubusercontent.com/travis-ci/gimme/master/gimme
chmod +x ~/bin/gimme
~/bin/gimme "${GO_VERSION}"
. `pwd`/.gimme/envs/go${GO_VERSION}.env

curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

# k8s
rm -rf ~/bin/kubectl
curl -L https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl -o ~/bin/kubectl
chmod +x ~/bin/kubectl

GO111MODULE="on" go get sigs.k8s.io/kind@v0.5.1
curl -L https://git.io/get_helm.sh | bash

# TODO: bashrc
