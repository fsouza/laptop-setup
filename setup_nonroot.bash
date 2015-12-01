#!/bin/bash

set -e

DATA_DIR=/var/data/${USER}

echo "Please ensure that you have the proper SSH keys and then press enter"
read

pushd ${HOME}

if [ ! -d .dotfiles ]; then
	git clone git@github.com:fsouza/dotfiles.git .dotfiles
fi

pushd .dotfiles
git submodule update --init --recursive
popd

ln -sf .dotfiles/.gitconfig
ln -sf .dotfiles/.gitignore_global
ln -sf .dotfiles/.hgignore_global
ln -sf .dotfiles/.hgrc
ln -sf .dotfiles/.bash_profile .bashrc

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
	mkdir -p ${DATA_DIR}/Downloads ${DATA_DIR}/gdrive ${DATA_DIR}/opt ${DATA_DIR}/Projects ${DATA_DIR}/rbenv ${DATA_DIR}/go ${DATA_DIR}/vagrant
	ln -sfT ${DATA_DIR}/Downloads $HOME/Downloads
	ln -sfT ${DATA_DIR}/gdrive $HOME/gdrive
	ln -sfT ${DATA_DIR}/opt $HOME/opt
	ln -sfT ${DATA_DIR}/Projects $HOME/Projects
	ln -sfT ${DATA_DIR}/rbenv ${RBENV_ROOT}
	ln -sfT ${DATA_DIR}/go/src ${HOME}/src
	ln -sfT ${DATA_DIR}/vagrant ${HOME}/.vagrant.d
fi

go get github.com/nsf/gocode/...
go get github.com/odeke-em/drive/cmd/drive

popd

vagrant plugin install vagrant-libvirt
