#!/bin/bash

set -e

echo "Please ensure that you have the proper SSH keys and then press enter"
read

if [ ! -d ${HOME}/.dotfiles ]; then
	git clone git@github.com:fsouza/dotfiles.git ${HOME}/.dotfiles
fi
${HOME}/.dotfiles/bin/setup

if [ ! -d ${HOME}/.config/nvim ]; then
	mkdir -p ${HOME}/.config
	git clone git@github.com:fsouza/vimfiles.git ${HOME}/.config/nvim
fi

if [ ! -d ${HOME}/.linuxbrew ]; then
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
fi

source ${HOME}/.bashrc
nvim +PlugInstall +GoUpdateBinaries +q
