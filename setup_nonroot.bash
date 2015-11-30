#!/bin/bash

set -e

DATA_DIR=/var/data/${USER}

echo "Please ensure that you have the proper SSH keys and then press enter"
read

mkdir -p ${HOME}/Projects

pushd ${HOME}/Projects

if [ ! -d dotfiles ]; then
	git clone git@github.com:fsouza/dotfiles.git
fi

pushd dotfiles
git submodule update --init --recursive
popd

popd

pushd ${HOME}

ln -sf Projects/dotfiles/.gitconfig
ln -sf Projects/dotfiles/.gitignore_global
ln -sf Projects/dotfiles/.hgignore_global
ln -sf Projects/dotfiles/.hgrc
ln -sf Projects/dotfiles/.bash_profile .bashrc

if [ ! -d .vim ]; then
	git clone git@github.com:fsouza/vimfiles.git .vim
fi

pushd .vim
git submodule update --init --recursive
mkdir -p swp
popd

cat >.vimrc <<EOF
source $HOME/.vim/.vimrc
EOF

mkdir -p $HOME/.config
pushd $HOME/.config
curl -L https://github.com/fsouza/laptop-setup/raw/master/data/dconf.tar.gz | tar -xzvf -
popd

source $HOME/.bashrc

if [ -d ${DATA_DIR} ]; then
	mkdir -p ${DATA_DIR}/Downloads ${DATA_DIR}/gdrive ${DATA_DIR}/opt ${DATA_DIR}/Code ${DATA_DIR}/rbenv
	ln -sf ${DATA_DIR}/Downloads $HOME/Downloads
	ln -sf ${DATA_DIR}/gdrive $HOME/gdrive
	ln -sf ${DATA_DIR}/opt $HOME/opt
	ln -sf ${DATA_DIR}/Code $HOME/Code
	ln -sf ${DATA_DIR}/rbenv ${RBENV_ROOT}
fi

go get github.com/nsf/gocode/...
go get github.com/odeke-em/drive/cmd/drive

popd

vagrant plugin install vagrant-kvm
