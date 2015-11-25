#!/bin/bash

OWNER=${OWNER:-fss}
PACKAGES="curl git mercurial clang build-essential spotify-client apt-https-transport vim-nox msttcorefonts python-dev libevent-dev libxml2-dev libxslt-dev libmysqlclient-dev mysql-server"

export DEBIAN_FRONTEND=noninteractive

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
echo deb http://repository.spotify.com testing non-free | tee /etc/apt/sources.list.d/spotify.list

sed -ie '/^deb /s/jessie main$/\0 non-free contrib/' /etc/apt/sources.list

apt-get update
apt-get dist-upgrade -y
apt-get install ${PACKAGES} -qqy

pushd /tmp

curl -sLO https://update.gitter.im/linux64/gitter_2.4.0_amd64.deb
curl -sLO https://slack-ssb-updates.global.ssl.fastly.net/linux_releases/slack-desktop-1.2.6-amd64.deb
dpkg -i *.deb
rm -f *.deb

FIREFOX_FILE=firefox-developer-edition.tar.bz2

curl -sLo ${FIREFOX_FILE} "https://download.mozilla.org/?product=firefox-aurora-latest-ssl&os=linux64&lang=en-US"
mkdir -p /opt/firefox
tar -C /opt/firefox -xjvf ${FIREFOX_FILE}
rm -f ${FIREFOX_FILE}

popd