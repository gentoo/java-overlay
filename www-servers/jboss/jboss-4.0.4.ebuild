# Copyright 1999-2007 Gentoo Foundation
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
KEYWORDS="~amd64 ~x86"

RDEPEND=">=virtual/jdk-1.4"
DEPEND="${RDEPEND}
		app-arch/unzip"

S=${WORKDIR}/${MY_P}
INSTALL_DIR="/usr/share/${PN}-${SLOT}"
VAR_INSTALL_DIR="/var/lib/${PN}-${SLOT}"
TMP_INSTALL_DIR="/var/tmp/${PN}-${SLOT}"
CACHE_INSTALL_DIR="/var/cache/${PN}-${SLOT}"
LOG_INSTALL_DIR="/var/log/${PN}-${SLOT}"

src_install() {
	#create jboss directory
	dodir ${INSTALL_DIR}

	exeinto /etc/init.d
	doexe ${FILESDIR}/${PV}/init.d/jboss-${SLOT}
	dodir /etc/conf.d
	cp ${FILESDIR}/${PV}/conf.d/jboss-${SLOT} ${D}/etc/conf.d

	#copy directories into 
	for f in bin client lib server copyright.txt; do
		cp -r ${f} ${D}/${INSTALL_DIR} || die "Failed to copy directories"
	done

	#set up /var/lib/jboss-${SLOT}
	dodir ${VAR_INSTALL_DIR}
	mv ${D}/${INSTALL_DIR}/server/{all,default,minimal} ${D}${VAR_INSTALL_DIR}
	for server in all default minimal; do
		cp ${FILESDIR}/${PV}/log4j.xml ${D}${VAR_INSTALL_DIR}/${server}/conf/ || die "failed"
	done
	rmdir ${D}/${INSTALL_DIR}/server

	keepdir ${LOG_INSTALL_DIR}
	keepdir ${TMP_INSTALL_DIR}
	keepdir ${CACHE_INSTALL_DIR}

	# the following hack is included until we determine how to make
	# Catalina believe it lives in /var/lib/jboss/$JBOSS_CONF.
	dosym ${VAR_INSTALL_DIR} ${INSTALL_DIR}/server
}

without_error() {
	$@ &>/dev/null || true
}

pkg_setup() {
	enewgroup jboss || die "Unable to create jboss group"
	enewuser jboss -1 /bin/sh /dev/null jboss || die "Unable to create jboss user"
}

pkg_postinst() {
	for dir in ${VAR_INSTALL_DIR} ${LOG_INSTALL_DIR} ${TMP_INSTALL_DIR} ${CACHE_INSTALL_DIR}; do
		chown -R jboss:jboss ${dir}
		chmod o-w ${dir}
		chmod o+rx ${dir}
	done

	# add write access for jboss group so user can use netbeans to start jboss
	chmod -R g+w ${VAR_INSTALL_DIR}/*

	einfo
	einfo " If you want to run jboss from netbeans, add your user to 'jboss' group."
	einfo
}
