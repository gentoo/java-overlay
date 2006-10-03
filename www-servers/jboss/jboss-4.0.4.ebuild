# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/jboss/jboss-3.2.5.ebuild,v 1.11 2006/09/20 11:29:31 caster Exp $

inherit eutils java-pkg-2

MY_P="${P}.GA"

DESCRIPTION="An open source, standards-compliant, J2EE-based application server implemented in 100% Pure Java."
SRC_URI="mirror://sourceforge/jboss/${MY_P}.zip"
RESTRICT="nomirror"
HOMEPAGE="http://www.jboss.org"
LICENSE="LGPL-2"
IUSE=""
SLOT="4"
KEYWORDS="-amd64 -x86"

RDEPEND=">=virtual/jdk-1.4"
DEPEND="${RDEPEND}
		app-arch/unzip"

S=${WORKDIR}/${MY_P}
INSTALL_DIR="/usr/share/${PN}-${SLOT}"
VAR_INSTALL_DIR="/var/lib/${PN}-${SLOT}"

src_install() {
	#create jboss directory
	dodir ${INSTALL_DIR}
	#copy directories into 
	for f in bin client lib server copyright.txt; do
		cp -r ${f} ${D}/${INSTALL_DIR} || die "Failed to copy directories"
	done

	#set up /var/lib/jboss-${SLOT} 
	dodir ${VAR_INSTALL_DIR}
}

without_error() {
	$@ &>/dev/null || true
}

