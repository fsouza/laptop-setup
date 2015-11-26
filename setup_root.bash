#!/bin/bash

set -e

OWNER=${OWNER:-fss}
PACKAGES="curl git mercurial clang build-essential spotify-client apt-transport-https vim-nox msttcorefonts python-dev libevent-dev libxml2-dev libxslt-dev libmysqlclient-dev mysql-server docker-engine youtube-dl python3 python3-dev mongodb parallel gfortran scala mono rbenv ruby-build"
GO_VERSION=1.5.1

export DEBIAN_FRONTEND=noninteractive

apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb http://repository.spotify.com testing non-free" | tee /etc/apt/sources.list.d/spotify.list
echo "deb https://apt.dockerproject.org/repo debian-jessie main" | tee /etc/apt/sources.list.d/docker.list
echo "deb http://download.mono-project.com/repo/debian beta main" | tee /etc/apt/sources.list.d/mono-xamarin-beta.list

sed -ie '/^deb /s/jessie main$/\0 non-free contrib/' /etc/apt/sources.list

apt-get update
apt-get dist-upgrade -y
apt-get install ${PACKAGES} -qqy

pushd /tmp

curl -LO https://update.gitter.im/linux64/gitter_2.4.0_amd64.deb
curl -LO https://slack-ssb-updates.global.ssl.fastly.net/linux_releases/slack-desktop-1.2.6-amd64.deb
dpkg -i *.deb
rm -f *.deb

FIREFOX_FILE=firefox-developer-edition.tar.bz2

curl -Lo ${FIREFOX_FILE} "https://download.mozilla.org/?product=firefox-aurora-latest-ssl&os=linux64&lang=en-US"
mkdir -p /opt/firefox
tar -C /opt -xjvf ${FIREFOX_FILE}
rm -f ${FIREFOX_FILE}

curl -LO https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz
mkdir -p /usr/local/go
tar -C /usr/local -xzvf go${GO_VERSION}.linux-amd64.tar.gz
rm go${GO_VERSION}.linux-amd64.tar.gz

mkdir -p /usr/local/var

chown -R ${OWNER}:${OWNER} /opt/firefox /usr/local/var /usr/local/go
ln -s /opt/firefox/firefox /usr/bin/firefoxd

popd

usermod -G sudo ${OWNER}

curl -sSf https://static.rust-lang.org/rustup.sh | bash -s -- --disable-sudo --yes
