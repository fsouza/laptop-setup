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

mkdir -p $HOME/.config
pushd $HOME/.config
curl -L "https://doc-00-8g-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/luqktds9d1jrgcvavtmijhftuukt55f4/1448503200000/17430741088418587958/*/0B2S6OO3hfaEfS2k1M1VVVVQ4c1E?e=download" -o dconf.tar.gz
tar -xzvf dconf.tar.gz
rm dconf.tar.gz
popd

source $HOME/.bashrc
go get github.com/nsf/gocode/...
go get github.com/odeke-em/drive/cmd/drive

popd

vagrant plugin install vagrant-kvm
