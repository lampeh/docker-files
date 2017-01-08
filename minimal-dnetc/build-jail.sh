#!/bin/bash
set -e

REPO=${3:-lampe/minimal-dnetc}
TAG=${1:-latest}
EXTRA=${2}

echo "Building image for $REPO:$TAG${EXTRA:+-$EXTRA}"

sed -i -e 's#//archive\.ubuntu\.com/#//de.archive.ubuntu.com/#' /etc/apt/sources.list

apt-get update || true
apt-get -y dist-upgrade
apt-get -y install makejail wget busybox

# docker dependency
apt-get -y install libltdl7

useradd -m -U -s /bin/sh -d /home/dnetc dnetc

cd $(mktemp -d)
mkdir target

wget http://http.distributed.net/pub/dcti/current-client/dnetc-linux-amd64.tar.gz
tar -xzf dnetc-linux-amd64.tar.gz
mv dnetc*/dnetc /home/dnetc/
cp /build/dnetc.ini /home/dnetc/
/bin/chown -R dnetc.dnetc /home/dnetc

{
cat <<-_EOF_
	cleanJailFirst=1
	chroot="$(pwd)/target"
	testCommandsInsideJail=["/home/dnetc/dnetc -bench"]
	processNames=["dnetc"]
	users=["root","dnetc"]
	groups=["root","dnetc"]
	forceCopy=["/home/dnetc/dnetc.ini","/etc/passwd","/etc/group","/lib/x86_64-linux-gnu/libnss_dns*"]
_EOF_

#if [ "$EXTRA" = "busybox" ]; then
	cat <<-_EOF_
		packages=["busybox"]
		#useDepends=1
		doNotCopy=["/usr/share/doc", "/usr/share/info", "/usr/share/man", "/etc/fstab", "/etc/mtab", "/proc", "/usr/share/initramfs-tools"]
	_EOF_
#fi
} >makejail.conf
makejail makejail.conf

cd target

# Volume mount point
mkdir home/dnetc/buffers
chown dnetc.dnetc home/dnetc/buffers

# Link busybox
#if [ "$EXTRA" = "busybox" ]; then
	ln -sf busybox bin/sh
#fi

imgId=`tar -c . | docker import -`
echo "FROM image: $imgId"

{
cat <<-_EOF_
	FROM $imgId
	WORKDIR /home/dnetc
	VOLUME /home/dnetc/buffers
	USER dnetc
	CMD ["./dnetc"]
_EOF_
}| docker build --force-rm=true -t $REPO:$TAG${EXTRA:+-$EXTRA} -
