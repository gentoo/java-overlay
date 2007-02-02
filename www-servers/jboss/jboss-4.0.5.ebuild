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
CONF_INSTALL_DIR="/etc/${PN}-${SLOT}"
VAR_INSTALL_DIR="/var/lib/${PN}-${SLOT}"
TMP_INSTALL_DIR="/var/tmp/${PN}-${SLOT}"
CACHE_INSTALL_DIR="/var/cache/${PN}-${SLOT}"
LOG_INSTALL_DIR="/var/log/${PN}-${SLOT}"
RUN_INSTALL_DIR="/var/run/${PN}-${SLOT}"

# NOTE: When you are updating CONFIG_PROTECT env.d file, you can use this script on your current install
# run from /var/lib/jboss-${SLOT} to get list of files that should be config protected. We protect *.xml,
# *.properties and *.tld files.
# SLOT="4" TEST=`find /var/lib/jboss-${SLOT}/ -type f | grep -E -e "\.(xml|properties|tld)$"`; echo $TEST

src_install() {
	# copy startup stuff
	doinitd ${FILESDIR}/${PV}/init.d/jboss-${SLOT}
	newconfd ${FILESDIR}/${PV}/conf.d/jboss-${SLOT} jboss-${SLOT}
	doenvd ${FILESDIR}/${PV}/env.d/50jboss-${SLOT}

	# create the directory structure
	diropts -m755
	dodir ${INSTALL_DIR}
	for PROFILE in all default minimal; do
		diropts -m775
		dodir ${VAR_INSTALL_DIR}/${PROFILE}/deploy
		keepdir ${LOG_INSTALL_DIR}/${PROFILE} ${CACHE_INSTALL_DIR}/${PROFILE} \
			${TMP_INSTALL_DIR}/${PROFILE} ${RUN_INSTALL_DIR}/${PROFILE}
		diropts -m755
		dodir ${CONF_INSTALL_DIR}/${PROFILE} ${VAR_INSTALL_DIR}/${PROFILE} \
			${VAR_INSTALL_DIR}/${PROFILE}/lib
	done
	keepdir ${VAR_INSTALL_DIR}/minimal/deploy

	# copy the files
	# write access is set for jboss group so user can use netbeans to start jboss
	insopts -m644
	diropts -m755
	insinto ${INSTALL_DIR}/bin
	doins -r bin/*.conf bin/*.jar
	exeinto ${INSTALL_DIR}/bin
	doexe bin/*.sh
	insinto ${INSTALL_DIR}
	doins -r client lib
	dodoc copyright.txt
	for PROFILE in all default minimal; do
		insinto ${CONF_INSTALL_DIR}/${PROFILE}
		doins -r server/${PROFILE}/conf/*
		insopts -m664
		diropts -m775
		insinto ${VAR_INSTALL_DIR}/${PROFILE}
		doins -r server/${PROFILE}/deploy
		insopts -m644
		diropts -m755
		doins -r server/${PROFILE}/lib
	done
	insinto ${VAR_INSTALL_DIR}/all
	doins -r server/all/deploy-hasingleton server/all/farm

	# correct access rights
	for dir in ${VAR_INSTALL_DIR} ${LOG_INSTALL_DIR} ${TMP_INSTALL_DIR} ${CACHE_INSTALL_DIR} ${RUN_INSTALL_DIR}; do
		fowners -R jboss:jboss ${dir}
	done

	# do symlinks
	for PROFILE in all default minimal; do
		dosym ${CONF_INSTALL_DIR}/${PROFILE} ${VAR_INSTALL_DIR}/${PROFILE}/conf
		dosym ${CACHE_INSTALL_DIR}/${PROFILE} ${VAR_INSTALL_DIR}/${PROFILE}/data
		dosym ${LOG_INSTALL_DIR}/${PROFILE} ${VAR_INSTALL_DIR}/${PROFILE}/log
		dosym ${TMP_INSTALL_DIR}/${PROFILE} ${VAR_INSTALL_DIR}/${PROFILE}/tmp
		dosym ${RUN_INSTALL_DIR}/${PROFILE} ${VAR_INSTALL_DIR}/${PROFILE}/work
	done

	# the following hack is included until we determine how to make
	# Catalina believe it lives in /var/lib/jboss/$JBOSS_CONF.
	dosym ${VAR_INSTALL_DIR} ${INSTALL_DIR}/server
}

pkg_setup() {
	enewgroup jboss || die "Unable to create jboss group"
	enewuser jboss -1 /bin/sh /dev/null jboss || die "Unable to create jboss user"
}

pkg_postinst() {
	# fix permissions
	chmod -R g+w ${CACHE_INSTALL_DIR} ${LOG_INSTALL_DIR} ${TMP_INSTALL_DIR} ${RUN_INSTALL_DIR}
	chown -R jboss:jboss ${CACHE_INSTALL_DIR} ${LOG_INSTALL_DIR} ${TMP_INSTALL_DIR} ${RUN_INSTALL_DIR}

	einfo
	einfo " If you want to run multiple instances of JBoss, you can do that this way:"
	einfo " 1) symlink init script:"
	einfo "    ln -s /etc/init.d/${PN}-${SLOT} /etc/init.d/${PN}-${SLOT}.foo"
	einfo " 2) copy original config file:"
	einfo "    cp /etc/conf.d/${PN}-${SLOT} /etc/conf.d/${PN}-${SLOT}.foo"
	einfo " 3) edit the new config file so it uses another JBOSS_SERVER_NAME, eventually"
	einfo "    create new server directories if you do not set one of the predefined"
	einfo "    server names like default, all or minimal and set up the new JBoss"
	einfo "    (you have to either bind new JBoss instance to another IP address or change"
	einfo "    used ports so they do not conflict)"
	einfo " 4) run the new JBoss instance:"
	einfo "    /etc/init.d/${PN}-${SLOT}.foo start"
	einfo
	einfo " If you want to run JBoss from Netbeans, add your user to 'jboss' group."
	einfo
}
