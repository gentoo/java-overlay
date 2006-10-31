# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/jboss/jboss-3.2.5.ebuild,v 1.11 2006/09/20 11:29:31 caster Exp $

inherit eutils java-pkg-2

MY_P="${P}.GA-src"

DESCRIPTION="An open source, standards-compliant, J2EE-based application server implemented in 100% Pure Java."
SRC_URI="mirror://sourceforge/jboss/${MY_P}.tar.gz"
RESTRICT="nomirror"
HOMEPAGE="http://www.jboss.org"
LICENSE="LGPL-2"
IUSE=""
SLOT="4"
KEYWORDS="~amd64 ~x86"

THIRDPARTY="=dev-java/antlr-2.7.6*
			=dev-java/apache-addressing-1.0*
			=dev-java/avalon-framework-4.1.5*
			=dev-java/avalon-logkit-1.2*
			=dev-java/bcel-5.1*
			=dev-java/commons-beanutils-1.6*
			=dev-java/bsf-2.3.0*
			=dev-java/commons-codec-1.3*"



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


set_env() {
	export ANT_OPTS="-Xmx1g"
}

src_unpack() {
	unpack ${A}

	fix_thirdparty
}

src_compile() {
	set_env

	cd build
	eant
}

src_install() {
	# copy startup stuff
	doinitd ${FILESDIR}/${PV}/init.d/jboss-${SLOT}
	newconfd ${FILESDIR}/${PV}/conf.d/jboss-${SLOT}-r1 jboss-${SLOT}
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
	einfo " If you want to run jboss from netbeans, add your user to 'jboss' group."
	einfo
}

function fix_thirdparty() {
	einfo "Fix bundled thirdparty jars"
	cd ${S}/thirdparty

	#We need to confirm #138236 ebuild is good and add to overlay/tree
	#fix_individual_dir antlr antlr-2.7.6
	
	fix_individual_dir apache-addressing apache-addressing addressing.jar addressing-1.0.jar

	fix_individual_dir apache-avalon avalon-framework-4.1

	fix_individual_dir apache-avalon-logkit avalon-logkit-1.2

	#fix_individual_dir apache-bcel bcel-5.1
	
	# Jboss Packages with 1.6.0 but attempting to use 1.6.1
	fix_individual_dir apache-beanutils commons-beanutils-1.6

	fix_individual_dir apache-bsf bsf-2.3
	
	# commons-codec should be 1.2 but only 1.3 in portage at present so
	# attempting to that
	fix_individual_dir apache-codec commons-codec commons-codec.jar commons-codec-1.2.jar

	#fix_individual_dir 


}

function fix_individual_dir() {
	cd ${1}/lib
	rm *.jar
	java-pkg_jarfrom ${2} ${3} ${4}
	cd ../..
}
