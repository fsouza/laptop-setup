#!/bin/bash

set -e

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

rm -rf .vim

git clone git@github.com:fsouza/vimfiles.git .vim

pushd .vim
git submodule update --init --recursive
mkdir swp
popd

cat >.vimrc <<EOF
source $HOME/.vim/.vimrc
EOF

popd
