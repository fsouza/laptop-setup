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

rm -f .gitconfig .gitignore_global .hgignore_global .hgrc .bashrc

ln -s Projects/dotfiles/.gitconfig
ln -s Projects/dotfiles/.gitignore_global
ln -s Projects/dotfiles/.hgignore_global
ln -s Projects/dotfiles/.hgrc
ln -s Projects/dotfiles/.bash_profile .bashrc

rm -rf .vim

git clone git@github.com:fsouza/vimfiles.git .vim
cat >.vimrc <<EOF
source $HOME/.vim/.vimrc
EOF

pushd .vim
git submodule update --init --recursive
mkdir swp
popd

popd
