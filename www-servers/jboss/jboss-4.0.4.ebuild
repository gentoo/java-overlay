# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/jboss/jboss-3.2.5.ebuild,v 1.11 2006/09/20 11:29:31 caster Exp $

inherit eutils java-pkg

MY_P="${P}.GA"

DESCRIPTION="An open source, standards-compliant, J2EE-based application server implemented in 100% Pure Java."
SRC_URI="mirror://sourceforge/jboss/${MY_P}-src.tar.gz"
RESTRICT="nomirror"
HOMEPAGE="http://www.jboss.org"
LICENSE="LGPL-2"
IUSE=""
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=">=virtual/jdk-1.4"
DEPEND="${RDEPEND}
	app-arch/unzip
	app-text/sgml-common
	dev-java/ant-core"

INSTALL_DIR=/usr/share/jboss

S=${WORKDIR}/${MY_P}-src

src_compile() {
	[ -n ${JDK_HOME} ] || JDK_HOME=$(java-config --jdk-home)
	export JAVA_HOME=${JDK_HOME}
	cd build
	# For more options on the "groups" parameter, see build/build.xml
	sh build.sh -Dgroups=all || die
#	sh build.sh || die
}

src_install() {
	dodir ${INSTALL_DIR}
	dodir ${INSTALL_DIR}/bin

	for f in run.sh shutdown.sh run.jar shutdown.jar; do
		cp build/output/${MY_P}/bin/${f} ${D}/${INSTALL_DIR}/bin || die "failed"
	done

	exeinto /etc/init.d
	doexe ${FILESDIR}/${PV}/init.d/jboss
	dodir /etc/conf.d
	cp ${FILESDIR}/${PV}/conf.d/jboss ${D}/etc/conf.d
	dodir /etc/env.d
	cp ${FILESDIR}/${PV}/env.d/50jboss ${D}/etc/env.d
	sed "s#@JBOSSPREFIX@#${INSTALL_DIR}#" \
		<${FILESDIR}/${PV}/env.d/50jboss \
		>${D}/etc/env.d/50jboss
#	see NEWS.Gentoo
#	echo 'CONFIG_PROTECT="/var/lib/jboss"' >>${D}/etc/env.d/50jboss

	for i in build/output/${MY_P}/server \
		build/output/${MY_P}/lib \
		build/output/${MY_P}/client
	do
		cp -pPR $i ${D}/${INSTALL_DIR}/ || die "failed"
	done

	dodir /var/lib/jboss
	mv ${D}/${INSTALL_DIR}/server/{all,default,minimal} ${D}/var/lib/jboss
	for server in all default minimal; do
		cp ${FILESDIR}/${PV}/log4j.xml ${D}/var/lib/jboss/${server}/conf/ || die "failed"
	done
	rmdir ${D}/${INSTALL_DIR}/server

	local classpath
	classpath=$(find ${D}/${INSTALL_DIR}/client -type f -name \*.jar |sed "s,${D}/,,g")
	classpath=$(echo ${classpath})
	cat >${D}/usr/share/jboss/package.env <<EOF
DESCRIPTION=Client side libraries for JBoss
CLASSPATH=${classpath// /:}
EOF

	dodoc server/src/docs/LICENSE.txt \
		${FILESDIR}/${PV}/README.Gentoo \
		${FILESDIR}/${PV}/NEWS.Gentoo
	cp -r build/output/${MY_P}/docs/examples ${D}/usr/share/doc/${PF}/

	insinto /usr/share/sgml/jboss/
	doins build/output/${MY_P}/docs/dtd/*
	doins ${FILESDIR}/${PV}/catalog

	keepdir /var/log/jboss
	keepdir /var/tmp/jboss
	keepdir /var/cache/jboss

	# the following hack is included until we determine how to make
	# Catalina believe it lives in /var/lib/jboss/$JBOSS_CONF.
	dosym /var/lib/jboss /usr/share/jboss/server
}

without_error() {
	$@ &>/dev/null || true
}

pkg_postinst() {
	without_error userdel jboss
	without_error groupdel jboss
	if ! enewgroup jboss || ! enewuser jboss -1 /bin/sh /dev/null jboss; then
		die "Unable to add jboss user and jboss group."
	fi

	for dir in /var/log/jboss /var/tmp/jboss /var/cache/jboss /var/lib/jboss; do
		chown -R jboss:jboss ${dir}
		chmod o-rwx ${dir}
	done

	install-catalog --add /etc/sgml/jboss.cat /usr/share/sgml/jboss/catalog
}

pkg_prerm() {
	if [ -e /etc/sgml/jboss.cat ]; then
		install-catalog --remove /etc/sgml/jboss.cat /usr/share/sgml/jboss/catalog
	fi
}
