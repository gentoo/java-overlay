# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

DESCRIPTION="JK module that is used to connect tomcat to apache using the ajp13 protocol"
HOMEPAGE="http://jakarta.apache.org/tomcat/connectors-doc/jk2/index.html"
SRC_URI="mirror://apache/jakarta/tomcat-connectors/jk/source/jakarta-tomcat-connectors-jk-${PV}-src.tar.gz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"
IUSE="apache2 ssl"
DEPEND="apache2? ( =net-www/apache-2* )
		!apache2? ( =net-www/apache-1* )
		>=virtual/jdk-1.4
		>=www-servers/tomcat-5.0.28"
RDEPEND="apache2? ( =net-www/apache-2* )
		!apache2? ( =net-www/apache-1* )
		>=virtual/jdk-1.4
		>=www-servers/tomcat-5.0.28"

S=${WORKDIR}/jakarta-tomcat-connectors-jk-${PV}-src/jk/native

src_compile() {
	local confopts=""
	! use apache2 && confopts="--with-apxs=/usr/sbin/apxs"
	use apache2 && confopts="--with-apxs=/usr/sbin/apxs2"
	if ! use apache2; then
		if use ssl; then
			confopts="${confopts} $(use_enable ssl EAPI)"
		fi
	fi
	econf ${confopts} || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	dodoc CHANGES.txt README docs/api/README.txt

	if use apache2; then
		exeinto /usr/lib/apache2-extramodules/
		doexe apache-2.0/mod_jk.so

		insinto /etc/apache2/conf/modules.d
		doins ${FILESDIR}/88_mod_jk.conf

		insinto /etc/apache2/conf
		doins ${FILESDIR}/workers.properties
	else
		exeinto /usr/lib/apache-extramodules/
		doexe apache-1.3/mod_jk.so

		insinto /etc/apache/conf/addon-modules
		doins ${FILESDIR}/mod_jk.conf
		insinto /etc/apache/conf
		doins ${FILESDIR}/workers.properties
	fi
}

pkg_postinst() {
	einfo "Installing a Apache config for mod_jk (mod_jk.conf)"
	einfo "To enable this module add -D JK to APACHE_OPTS"
	einfo "in the /etc/conf.d/apache file."
	if ! use apache2; then
		einfo "Then add the following line to the end of the"
		einfo "/etc/apache/conf/apache.conf"
		einfo "Include conf/addon-modules/mod_jk.conf"
	fi
}
