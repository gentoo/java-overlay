# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/tomcat/tomcat-3.3.2-r2.ebuild,v 1.4 2005/02/07 23:43:14 luckyduck Exp $

inherit eutils

DESCRIPTION="Apache Servlet-2.2/JSP-1.1 Container"

JT_P="jakarta-${P}.tar.gz"
S=${WORKDIR}/jakarta-${P}
SLOT="${PV/.*}"
SRC_URI="mirror://apache/jakarta/tomcat-${SLOT}/v${PV}/bin/${JT_P}"
HOMEPAGE="http://jakarta.apache.org/tomcat"
KEYWORDS="x86 ppc ~sparc ~alpha"
LICENSE="Apache-2.0"
DEPEND="sys-apps/sed"
RDEPEND=">=virtual/jdk-1.3
		sys-apps/sed"
IUSE=""

TOMCAT_HOME="/opt/${PN}${SLOT}"
TOMCAT_NAME="${PN}${SLOT}"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${PV}/gentoo.diff
}

src_install() {
	dodoc LICENSE

	# INIT SCRIPTS AND ENV
	insinto /etc/init.d
	insopts -m0750
	newins ${FILESDIR}/${PV}/tomcat.init ${TOMCAT_NAME}

	insinto /etc/conf.d
	insopts -m0644
	newins ${FILESDIR}/${PV}/tomcat.conf ${TOMCAT_NAME}

	diropts -m750
	dodir ${TOMCAT_HOME} /var/log/${TOMCAT_NAME} /etc/${TOMCAT_NAME}
	keepdir /var/log/${TOMCAT_NAME}

	mv conf/* ${D}/etc/${TOMCAT_NAME}
	mv bin doc lib modules native webapps ${D}${TOMCAT_HOME}

	dosym /etc/${TOMCAT_NAME} ${TOMCAT_HOME}/conf
	dosym /var/log/${TOMCAT_NAME} ${TOMCAT_HOME}/logs
}

pkg_preinst() {
	enewgroup tomcat
	enewuser tomcat -1 -1 /dev/null tomcat

	chown -R tomcat:tomcat ${D}/opt/${TOMCAT_NAME}
	chown -R tomcat:tomcat ${D}/etc/${TOMCAT_NAME}
	chown -R tomcat:tomcat ${D}/var/log/${TOMCAT_NAME}
}

pkg_postinst() {
	#due to previous ebuild bloopers, make sure everything is correct
	chown -R root:root /usr/share/doc/${PF}
	chown root:root /etc/init.d/${TOMCAT_NAME}
	chown root:root /etc/conf.d/${TOMCAT_NAME}

	chown -R tomcat:tomcat /opt/${TOMCAT_NAME}
	chown -R tomcat:tomcat /etc/${TOMCAT_NAME}
	chown -R tomcat:tomcat /var/log/${TOMCAT_NAME}

	chmod 750 /etc/${TOMCAT_NAME}

	einfo " "
	einfo " NOTICE!"
	einfo " FILE LOCATIONS:"
	einfo " 1.  Tomcat home directory: ${TOMCAT_HOME}"
	einfo "     Contains application data, configuration files."
	einfo " 2.  Runtime settings: /etc/conf.d/${TOMCAT_NAME}"
	einfo "     Contains CLASSPATH and JAVA_HOME settings."
	einfo " 3.  Configuration:  /etc/${TOMCAT_NAME}"
	einfo " 4.  Logs:  /var/log/${TOMCAT_NAME}/"
	einfo " "
	einfo " "
	einfo " STARTING AND STOPPING TOMCAT:"
	einfo "   /etc/init.d/${TOMCAT_NAME} start"
	einfo "   /etc/init.d/${TOMCAT_NAME} stop"
	einfo "   /etc/init.d/${TOMCAT_NAME} restart"
	einfo " "
	einfo " "
	ewarn " If you are upgrading from older ebuild do NOT use"
	ewarn " /etc/init.d/tomcat and /etc/conf.d/tomcat you probably"
	ewarn " want to remove these. "
	ewarn " A version number has been appended so that tomcat 3, 4 and 5"
	ewarn " can be installed side by side"
	einfo " "
	einfo " NETWORK CONFIGURATION:"
	einfo " By default, Tomcat runs on port 8080.  You can change this"
	einfo " value by editing /etc/${TOMCAT_NAME}/server.xml."
	einfo " "
	einfo " To test Tomcat while it's running, point your web browser to:"
	einfo " http://localhost:8080/"
	einfo " "
	einfo " "
	einfo " BUGS:"
	einfo " Please file any bugs at http://bugs.gentoo.org/ or else it"
	einfo " may not get seen.  Thank you."
	einfo " "
}
