# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/tomcat/tomcat-5.0.28.ebuild,v 1.1 2004/10/09 09:59:14 axxo Exp $

inherit eutils java-pkg

DESCRIPTION="Apache Servlet-2.4/JSP-2.0 Container"
SLOT="${PV/.*}"
SRC_URI="mirror://apache/jakarta/tomcat-${SLOT}/v${PV}/src/jakarta-${P}-src.tar.gz"
KEYWORDS="~x86"
LICENSE="Apache-2.0"
DEPEND="sys-apps/sed
	   >=virtual/jdk-1.4
	   >=dev-java/commons-beanutils-1.7.0
	   >=dev-java/commons-collections-3.1
	   >=dev-java/commons-daemon-1.0
	   >=dev-java/commons-digester-1.5
	   >=dev-java/commons-logging-1.0.4
	   >=dev-java/commons-el-1.0
	   >=dev-java/regexp-1.3
	   >=dev-java/xerces-2.6.2-r1
	   >=dev-java/log4j-1.2.8
	   >=dev-java/commons-dbcp-1.2.1
	   >=dev-java/commons-httpclient-2.0
	   >=dev-java/commons-pool-1.2
	   >=dev-java/commons-fileupload-1.0
	   >=dev-java/commons-modeler-1.1
	   >=dev-java/commons-launcher-0.9
	   >=dev-java/junit-3.8.1
	   dev-java/jmx
	   =dev-java/struts-1.1-r2
	   >=dev-java/saxpath-1.0
	   >=dev-java/jaxen-1.0
	   jikes? ( dev-java/jikes )"
RDEPEND=">=virtual/jdk-1.4
		jikes? ( dev-java/jikes )"
IUSE="doc jikes"
S=${WORKDIR}/jakarta-${P}-src

TOMCAT_HOME="/opt/${PN}${SLOT}"
TOMCAT_NAME="${PN}${SLOT}"

src_unpack() {
	unpack ${A}
	cd ${S}

	# update the build.xml to remove downloading
	epatch ${FILESDIR}/${PV}/build.xml-01.patch
	epatch ${FILESDIR}/${PV}/build.xml-02.patch

	epatch ${FILESDIR}/${PV}/gentoo.diff
	use jikes && epatch ${FILESDIR}/${PV}/jikes.diff

}

src_compile(){
	local antflags="-Dbase.path=${T}"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	antflags="${antflags} -Dcommons-beanutils.jar=$(java-pkg_getjar commons-beanutils commons-beanutils.jar)"
	antflags="${antflags} -Dcommons-collections.jar=$(java-config -p commons-collections)"
	antflags="${antflags} -Dcommons-daemon.jar=$(java-config -p commons-daemon)"
	antflags="${antflags} -Dcommons-digester.jar=$(java-config -p commons-digester)"
	antflags="${antflags} -Dcommons-el.jar=$(java-config -p commons-el)"
	antflags="${antflags} -Dcommons-logging.jar=$(java-pkg_getjar commons-logging commons-logging.jar)"
	antflags="${antflags} -Dcommons-logging-api.jar=$(java-pkg_getjar commons-logging commons-logging-api.jar)"
	antflags="${antflags} -Dregexp.jar=$(java-config -p regexp)"
	antflags="${antflags} -DxercesImpl.jar=$(java-pkg_getjar xerces-2 xercesImpl.jar)"
	antflags="${antflags} -Dxml-apis.jar=$(java-pkg_getjar xerces-2 xml-apis.jar)"
	antflags="${antflags} -Dlog4j.jar=$(java-config -p log4j)"
	antflags="${antflags} -Dcommons-dbcp.jar=$(java-config -p commons-dbcp)"
	antflags="${antflags} -Dcommons-httpclient.jar=$(java-config -p commons-httpclient)"
	antflags="${antflags} -Dcommons-pool.jar=$(java-config -p commons-pool)"
	antflags="${antflags} -Dcommons-fileupload.jar=$(java-config -p commons-fileupload)"
	antflags="${antflags} -Djunit.jar=$(java-config -p junit)"
	antflags="${antflags} -Dstruts.jar=$(java-pkg_getjar struts struts.jar)"

	antflags="${antflags} -Djmx.jar=$(java-pkg_getjar jmx jmxri.jar)"
	antflags="${antflags} -Djmx-tools.jar=$(java-pkg_getjar jmx jmxtools.jar)"
	antflags="${antflags} -Dcommons-launcher.jar=$(java-config -p commons-launcher)"
	#`
	# This is used to reference the tld files in /usr/share/struts/lib
	#
	antflags="${antflags} -Dstruts.home=/usr/share/struts"
	antflags="${antflags} -Dcommons-modeler.jar=$(java-config -p commons-modeler)"
	antflags="${antflags} -Dstruts.jar=$(java-pkg_getjar struts struts.jar)"
	antflags="${antflags} -Djaxen.jar=$(java-pkg_getjar jaxen jaxen-full.jar)"
	antflags="${antflags} -Dsaxpath.jar=$(java-pkg_getjar saxpath saxpath.jar)"

	ant ${antflags} || die "compile failed"

}
src_install() {
	cd ${S}/jakarta-tomcat-5/build

	#
	newinitd ${FILESDIR}/${PV}/tomcat.init ${TOMCAT_NAME}
	newconfd ${FILESDIR}/${PV}/tomcat.conf ${TOMCAT_NAME}
	use jikes && sed -e "\cCATALINA_OPTScaCATALINA_OPTS=\"-Dbuild.compiler.emacs=true\"" -i ${D}/etc/conf.d/${TOMCAT_NAME}

	#
	diropts -m750
	dodir /usr/share/${TOMCAT_NAME}
	dodir /var/log/${TOMCAT_NAME}/default
	dodir /etc/${TOMCAT_NAME}/default
	dodir /var/tmp/${TOMCAT_NAME}/default
	dodir /var/run/${TOMCAT_NAME}/default
	dodir /var/lib/${TOMCAT_NAME}/default

	keepdir /var/log/${TOMCAT_NAME}/default
	keepdir /etc/${TOMCAT_NAME}/default
	keepdir /var/tmp/${TOMCAT_NAME}/default
	keepdir /var/run/${TOMCAT_NAME}/default

	rm -f bin/*.bat
	cp -a conf/* ${D}/etc/${TOMCAT_NAME}/default || die "failed to copy conf"
	cp -a bin common server shared ${D}/usr/share/${TOMCAT_NAME} || die "failed to copy"

	#
	dodir /var/lib/${TOMCAT_NAME}/default/webapps
	if use doc; then
		cp -r webapps/{tomcat-docs,jsp-examples,servlets-examples} ${D}/var/lib/${TOMCAT_NAME}/default/webapps
	fi
	cp -r webapps/{ROOT,balancer,webdav} ${D}/var/lib/${TOMCAT_NAME}/default/webapps

	#
	dosym /etc/${TOMCAT_NAME}/default /var/lib/${TOMCAT_NAME}/default/conf
	dosym /var/log/${TOMCAT_NAME}/default /var/lib/${TOMCAT_NAME}/default/logs
	dosym /var/tmp/${TOMCAT_NAME}/default /var/lib/${TOMCAT_NAME}/default/temp
	dosym /var/run/${TOMCAT_NAME}/default /var/lib/${TOMCAT_NAME}/default/work

	dodoc ${S}/jakarta-tomcat-5/{LICENSE,RELEASE-NOTES,RUNNING.txt}

	fperms 640 /etc/${TOMCAT_NAME}/default/tomcat-users.xml
}


pkg_preinst() {
	enewgroup tomcat
	enewuser tomcat -1 -1 /dev/null tomcat

	chown -R root:tomcat ${D}/usr/share/${TOMCAT_NAME}
	chown -R tomcat:tomcat ${D}/etc/${TOMCAT_NAME}
	chown -R tomcat:tomcat ${D}/var/log/${TOMCAT_NAME}
	chown -R tomcat:tomcat ${D}/var/tmp/${TOMCAT_NAME}
	chown -R tomcat:tomcat ${D}/var/run/${TOMCAT_NAME}
	chown -R tomcat:tomcat ${D}/var/lib/${TOMCAT_NAME}
}

pkg_postinst() {
	#due to previous ebuild bloopers, make sure everything is correct
	chown root:root /etc/init.d/${TOMCAT_NAME}
	chown root:root /etc/conf.d/${TOMCAT_NAME}

	# all binaries in /usr/share are owned by root for security
	# with the exeption of the common directory as this is where
	# users typically install libs
	chown -R root:tomcat /usr/share/${TOMCAT_NAME}
	chown -R tomcat:tomcat /usr/share/${TOMCAT_NAME}/common

	# These directories contain the runtime files and
	# are therefor owned by tomcat
	chown -R tomcat:tomcat /etc/${TOMCAT_NAME}
	chown -R tomcat:tomcat /var/log/${TOMCAT_NAME}
	chown -R tomcat:tomcat /var/tmp/${TOMCAT_NAME}
	chown -R tomcat:tomcat /var/run/${TOMCAT_NAME}
	chown -R tomcat:tomcat /var/lib/${TOMCAT_NAME}

	chmod 750 /etc/${TOMCAT_NAME}

	einfo " "
	einfo " NOTICE!"
	einfo " FILE LOCATIONS:"
	einfo " 1.  Tomcat home directory: ${TOMCAT_HOME}"
	einfo "     Contains application data, configuration files."
	einfo " 2.  Runtime settings: /etc/conf.d/${TOMCAT_NAME}"
	einfo "     Contains CLASSPATH and JAVA_HOME settings."
	einfo " 3.  Configuration:  /etc/${TOMCAT_NAME}/default"
	einfo " 4.  Logs:  /var/log/${TOMCAT_NAME}/default"
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
	ewarn " This ebuild implements a new filesystem layout for tomcat"
	ewarn " please read http://gentoo-wiki.com/Tomcat_Gentoo_ebuild for"
	ewarn " more information!."
	einfo " "
	einfo " NETWORK CONFIGURATION:"
	einfo " By default, Tomcat runs on port 8080.  You can change this"
	einfo " value by editing /etc/${TOMCAT_NAME}/default/server.xml."
	einfo " "
	einfo " To test Tomcat while it's running, point your web browser to:"
	einfo " http://localhost:8080/"
	! use doc && einfo " You do not have the doc USE flag set, examples have NOT been installed."
	einfo " "
	einfo " "
	einfo " BUGS:"
	einfo " Please file any bugs at http://bugs.gentoo.org/ or else it"
	einfo " may not get seen.  Thank you."
	einfo " "
}
