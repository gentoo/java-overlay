# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java

DESCRIPTION=""
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~x86"
IUSE=""

RDEPEND="dev-java/kaffe
	dev-java/eclipse-ecj-compat
	dev-java/fastjar
	dev-java/gjdoc"

src_install() {
	local VM_HOME="/opt/${P}"
	dodir ${VM_HOME} ${VM_HOME}/bin
	cd ${D}/${VM_HOME}
	ln -sf /opt/kaffe*/include
	cd ${VM_HOME}/bin
	ln -sf /usr/bin/ecj-compat-3.1 java
	ln -sf /usr/bin/gjdoc javadoc
	
	set_java_env ${FILESDIR}/${VMHANDLE} || die "Failed to install environment files"
}
