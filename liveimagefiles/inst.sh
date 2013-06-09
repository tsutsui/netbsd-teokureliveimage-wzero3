#! /bin/sh
# $Id: inst.sh,v 1.10 2012/03/10 15:32:06 tsutsui Exp tsutsui $

MACHINE_ARCH=`uname -p`
MACHINE=`uname -m`

# set directory where this setupliveimage.img is mounted
FILEDIR=/mnt

# target root file system device
BOOTDEV=`sysctl -r kern.root_device`
ROOTFSDEV=/dev/${BOOTDEV}a

# default user settings
UID=100
USER="mikutter"
GROUP="users"
SHELL=/usr/pkg/bin/tcsh
#SHELL=/usr/pkg/bin/bash
PASSWORD="Teokure-"

# packages list
PACKAGES=" \
	bash tcsh zsh \
	emacs \
	medit \
	dillo \
	w3m \
	vlgothic-ttf ipafont \
	kterm mlterm \
	jwm \
	anthy anthy-elisp \
	ibus ibus-anthy \
	ruby193-mikutter \
	lhasa unzip \
	onscripter \
	ruby193-tw \
	"

#echo "mounting target disk image..."
#mount -o async ${ROOTFSDEV} /

#echo "copying local /etc settings..."
#cp ${FILEDIR}/etc.${MACHINE}/ttys /etc

echo "installing packages..."
#PACKAGESDIR=${FILEDIR}/packages/${MACHINE_ARCH}/All
PACKAGESDIR=${FILEDIR}/All
(cd ${PACKAGESDIR}; PKG_RCD_SCRIPTS=YES pkg_add $PACKAGES)

# set ibus-anthy as system default
/usr/pkg/bin/gconftool-2 --direct \
    --config-source xml:write:/usr/pkg/etc/gconf/gconf.xml.defaults \
    --type=list --list-type=string \
    --set /desktop/ibus/general/preload_engines "[anthy]"

# add rc.conf definitions for xdm
#echo wscons=YES				>> /etc/rc.conf
#echo xdm=YES				>> /etc/rc.conf

# add rc.conf definitions for packages
echo dbus=NO				>> /etc/rc.conf   
echo hal=NO				>> /etc/rc.conf   
echo avahidaemon=NO			>> /etc/rc.conf
echo nasd=NO				>> /etc/rc.conf

echo "updating fontconfig cache..."
/usr/X11R7/bin/fc-cache

echo "updating man database..."
(umask 022; /usr/sbin/makemandb -q)

echo "creating user account..."
useradd -m \
	-k ${FILEDIR}/skel \
	-u $UID \
	-g $GROUP \
	-G wheel \
	-s $SHELL \
	-p `pwhash $PASSWORD` \
	$USER

echo "done."
