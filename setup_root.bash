#!/bin/bash

set -e

OWNER=${OWNER:-fsouza}
PACKAGES="curl git irb python-setuptools ruby perl-Thread-Queue gperf xclip"
echo "fastestmirror=true" >> /etc/dnf/dnf.conf

dnf check-update -y
dnf upgrade -y

dnf install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
dnf config-manager --add-repo=http://negativo17.org/repos/fedora-spotify.repo

dnf groupinstall 'Development Tools' -y
dnf install ${PACKAGES} -y

set +e
localedef -c -i en_US -f UTF-8 en_US.UTF-8
localedef -c -i pt_BR -f UTF-8 pt_BR.UTF-8
set -e

pushd /tmp

FIREFOX_FILE=firefox-developer-edition.tar.bz2
if [ ! -d /opt/firefox ]; then
	curl -Lo ${FIREFOX_FILE} "https://download.mozilla.org/?product=firefox-aurora-latest-ssl&os=linux64&lang=en-US"
	mkdir -p /opt/firefox
	tar -C /opt -xjvf ${FIREFOX_FILE}
	rm -f ${FIREFOX_FILE}
fi
ln -sf /opt/firefox/firefox /usr/bin/firefox

chown -R ${OWNER}:${OWNER} /opt/firefox

popd

if [ ! -f /usr/local/bin/rustc ]; then
	curl -sSf https://static.rust-lang.org/rustup.sh | bash -s -- --disable-sudo --yes
fi

curl -sSL https://get.docker.com/ | sh

curl -sL https://rpm.nodesource.com/setup_7.x | bash -
dnf install nodejs -y
