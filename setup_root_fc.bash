#!/bin/bash

set -e

OWNER=${OWNER:-fss}
GROUPS="@virtualization "
PACKAGES="curl git mercurial clang clang-devel vim python-devel libevent-devel libxml2-devel libxslt-devel community-mysql-server community-mysql-libs youtube-dl python3 python3-devel mongodb-server parallel gcc-gfortran scala mono mono-basic pypy tree python-virtualenv redis xclip virtualbox-5.0 dkms libvirt-devel golang vagrant epel"

curl -L http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo -o /etc/yum.repos.d/virtualbox.repo

echo "deb http://repository.spotify.com testing non-free" | tee /etc/apt/sources.list.d/spotify.list
echo "deb https://apt.dockerproject.org/repo debian-jessie main" | tee /etc/apt/sources.list.d/docker.list

dnf clean all
dnf update -y
dnf install ${PACKAGES} -y

cat > /etc/locale.gen <<EOF
en_US.UTF-8 UTF-8
pt_BR.UTF-8 UTF-8
EOF
locale-gen

pushd /tmp

if [ ! -f /usr/local/bin/gitter ]; then
	curl -LO https://update.gitter.im/linux64/gitter_2.4.0_amd64.deb
	dpkg -i gitter_2.4.0_amd64.deb
fi

if [ ! -f /usr/bin/slack ]; then
	curl -LO https://slack-ssb-updates.global.ssl.fastly.net/linux_releases/slack-desktop-1.2.6-amd64.deb
	dpkg -i slack-desktop-1.2.6-amd64.deb
fi

rm -f *.deb

FIREFOX_FILE=firefox-developer-edition.tar.bz2

if [ ! -d /opt/firefox ]; then
	curl -Lo ${FIREFOX_FILE} "https://download.mozilla.org/?product=firefox-aurora-latest-ssl&os=linux64&lang=en-US"
	mkdir -p /opt/firefox
	tar -C /opt -xjvf ${FIREFOX_FILE}
	rm -f ${FIREFOX_FILE}
fi
ln -sf /opt/firefox/firefox /usr/local/bin/firefox

mkdir -p /usr/local/var

id ${OWNER} || useradd -m -s /bin/bash ${OWNER}

chown -R ${OWNER}:${OWNER} /opt/firefox /usr/local/var

popd

usermod -G sudo,kvm,libvirt ${OWNER}

if [ ! -f /usr/local/bin/rustc ]; then
	curl -sSf https://static.rust-lang.org/rustup.sh | bash -s -- --disable-sudo --yes
fi

curl -sSL https://get.docker.com/ | sh

curl --silent --location https://rpm.nodesource.com/setup | bash -
dnf -y install nodejs
