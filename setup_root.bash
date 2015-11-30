#!/bin/bash

set -e

OWNER=${OWNER:-fss}
PACKAGES="curl git mercurial clang build-essential spotify-client apt-transport-https vim-nox msttcorefonts python-dev libevent-dev libxml2-dev libxslt-dev libmysqlclient-dev mysql-server docker-engine youtube-dl python3 python3-dev mongodb-org parallel gfortran scala mono-devel rbenv ruby-build pypy tree python-virtualenv redis-server xclip qemu-kvm libvirt-bin virtinst virtualbox-5.0 dkms libvirt-dev gvfs-bin"
GO_VERSION=1.5.1

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install apt-transport-https

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF

curl -L https://www.virtualbox.org/download/oracle_vbox.asc | apt-key add -

echo "deb http://repository.spotify.com testing non-free" | tee /etc/apt/sources.list.d/spotify.list
echo "deb https://apt.dockerproject.org/repo debian-jessie main" | tee /etc/apt/sources.list.d/docker.list
echo "deb http://download.mono-project.com/repo/debian beta main" | tee /etc/apt/sources.list.d/mono-xamarin-beta.list
echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.0 main" | tee /etc/apt/sources.list.d/mongodb-org-3.0.list
echo "deb http://download.virtualbox.org/virtualbox/debian jessie contrib non-free" | tee /etc/apt/sources.list.d/virtualbox.list

sed -ie '/^deb /s/jessie main$/\0 non-free contrib/' /etc/apt/sources.list

apt-get update
apt-get dist-upgrade -y
apt-get install ${PACKAGES} -qy

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

if [ ! -f /usr/bin/vagrant ]; then
	curl -LO https://releases.hashicorp.com/vagrant/1.7.4/vagrant_1.7.4_x86_64.deb
	dpkg -i vagrant_1.7.4_x86_64.deb
fi

rm -f *.deb

FIREFOX_FILE=firefox-developer-edition.tar.bz2

if [ ! -d /opt/firefox ]; then
	curl -Lo ${FIREFOX_FILE} "https://download.mozilla.org/?product=firefox-aurora-latest-ssl&os=linux64&lang=en-US"
	mkdir -p /opt/firefox
	tar -C /opt -xjvf ${FIREFOX_FILE}
	rm -f ${FIREFOX_FILE}
	curl -L https://github.com/fsouza/laptop-setup/raw/master/data/firefox-developer-logo.png -o /opt/firefox/firefox-logo.png
fi

cat > /usr/share/applications/firefox.desktop <<EOF
[Desktop Entry]
Encoding=UTF-8
Name=Firefox Developer Edition
Comment=Browse the World Wide Web
GenericName=Web Browser
Exec=/opt/firefox/firefox %u
Terminal=false
X-Multiple Args=false
Type=Application
Icon=/opt/firefox/firefox-logo.png
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
EOF

if [ ! -d /usr/local/go ]; then
	curl -LO https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz
	mkdir -p /usr/local/go
	tar -C /usr/local -xzvf go${GO_VERSION}.linux-amd64.tar.gz
	rm go${GO_VERSION}.linux-amd64.tar.gz
fi

ln -sf /usr/local/go/bin/* /usr/local/bin
ln -sf /opt/firefox/firefox /usr/local/bin/firefox

mkdir -p /usr/local/var /var/data/${OWNER}

id ${OWNER} || useradd -m -s /bin/bash ${OWNER}

chown -R ${OWNER}:${OWNER} /opt/firefox /usr/local/var /usr/local/go /var/data/${OWNER}

popd

usermod -G sudo,kvm,libvirt ${OWNER}

if [ ! -f /usr/local/bin/rustc ]; then
	curl -sSf https://static.rust-lang.org/rustup.sh | bash -s -- --disable-sudo --yes
fi

if [ ! -f /usr/bin/node ]; then
	curl -sL https://deb.nodesource.com/setup_4.x | bash -
	apt-get install nodejs -y
	ln -sf /usr/bin/nodejs /usr/bin/node
fi
