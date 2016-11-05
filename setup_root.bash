#!/bin/bash

set -e

OWNER=${OWNER:-fsouza}
PACKAGES="curl git irb python-setuptools ruby perl-Thread-Queue gperf xclip libcurl-devel sqlite-devel"
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

curl -sSL https://get.docker.com/ | sh

# setup onedrive client
curl -fsS https://dlang.org/install.sh | bash -s dmd
source ~/dlang/*/activate
git clone https://github.com/skilion/onedrive.git /tmp/onedrive

pushd /tmp/onedrive
make
make install
popd

rm -rf ~/dlang
