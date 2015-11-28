#!/bin/bash

set -e

OWNER=${OWNER:-fss}
GROUPS="@virtualization "
PACKAGES="curl git mercurial clang clang-devel vim python-devel libevent-devel libxml2-devel libxslt-devel community-mysql-server community-mysql-libs youtube-dl python3 python3-devel mongodb-server parallel gcc-gfortran scala mono mono-basic pypy tree python-virtualenv redis xclip virtualbox-5.0 dkms libvirt-devel golang vagrant epel spotify-client"

echo "fastestmirror=true" >> /etc/dnf/dnf.conf

dnf clean all
dnf update -y

dnf install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf config-manager --add-repo=http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo
dnf config-manager --add-repo=http://negativo17.org/repos/fedora-spotify.repo

dnf install ${PACKAGES} -y

cat > /etc/locale.gen <<EOF
en_US.UTF-8 UTF-8
pt_BR.UTF-8 UTF-8
EOF
locale-gen

pushd /tmp

if [ ! -f /usr/bin/slack ]; then
	curl -LO https://slack-ssb-updates.global.ssl.fastly.net/linux_releases/slack-1.2.6-0.1.fc21.x86_64.rpm
	dnf install -y slack-1.2.6-0.1.fc21.x86_64.rpm
	rm -f slack-1.2.6-0.1.fc21.x86_64.rpm
fi

FIREFOX_FILE=firefox-developer-edition.tar.bz2

if [ ! -d /opt/firefox ]; then
	curl -Lo ${FIREFOX_FILE} "https://download.mozilla.org/?product=firefox-aurora-latest-ssl&os=linux64&lang=en-US"
	mkdir -p /opt/firefox
	tar -C /opt -xjvf ${FIREFOX_FILE}
	rm -f ${FIREFOX_FILE}
fi
ln -sf /opt/firefox/firefox /usr/bin/firefox

mkdir -p /usr/local/var
chown -R ${OWNER}:${OWNER} /opt/firefox /usr/local/var

popd

if [ ! -f /usr/local/bin/rustc ]; then
	curl -sSf https://static.rust-lang.org/rustup.sh | bash -s -- --disable-sudo --yes
fi

curl -sSL https://get.docker.com/ | sh

curl --silent --location https://rpm.nodesource.com/setup | bash -
dnf install nodejs -y
