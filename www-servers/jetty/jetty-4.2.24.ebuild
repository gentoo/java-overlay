# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/jetty/jetty-4.2.19.ebuild,v 1.2 2004/08/25 03:05:15 swegener Exp $

inherit eutils java-pkg

DESCRIPTION="A Lightweight Servlet Engine"
SRC_URI="mirror://sourceforge/jetty/${P}-all.tar.gz"
HOMEPAGE="http://www.mortbay.org/"
KEYWORDS="~x86 ~ppc ~sparc"
LICENSE="Apache-1.1"

SLOT="${PV/.*}"
JETTY_HOME="/opt/${PN}${SLOT}"
JETTY_NAME="${PN}${SLOT}"

DEPEND=">=virtual/jdk-1.2
		dev-java/ant-core
		dev-java/sun-jmx
		>=dev-java/xerces-2.7
"
RDEPEND=">=virtual/jre-1.2
"
IUSE="jikes doc source extra junit"

pkg_setup() {
	enewgroup ${JETTY_NAME}
	enewuser ${JETTY_NAME} -1 /bin/bash ${JETTY_HOME} ${JETTY_NAME}
}

src_unpack() {
	unpack ${A}
	cd ${S}

	# this patch should be applied regardless if jikes is used
	# because it fixes Lexical warnings to the effect of:
	# "The use of "enum" as an identifier is deprecated, as it will be a keyword
	# once -source 1.5 is implemented."
	epatch ${FILESDIR}/${P}-jikes.patch

	epatch ${FILESDIR}/${PN}-4.2.19-gentoo.patch

	einfo "Removing jars that are part of jdk.."
	rm ${S}/ext/{jsse.jar,jnet.jar,jcert.jar}
	einfo "Removing jars that are provided by package..."
	rm ${S}/ext/{ant.jar,jmxri.jar,jmxtools.jar,xercesImpl.jar,xml-apis.jar}

	einfo "Constructing build.properties..."
	echo "ant.jar=`java-pkg_getjar ant-core ant.jar`" >> build.properties
	# TODO: use our own jasper-*.jar once its in portage
	echo "jmxri.jar=`java-pkg_getjar sun-jmx jmxri.jar`" >> build.properties
	echo "jmxtools.jar=`java-pkg_getjar sun-jmx jmxtools.jar`" >> build.properties
	echo "xercesImpl.jar=`java-pkg_getjar xerces-2 xercesImpl.jar`" >> build.properties	
	echo "xml-apis.jar=`java-pkg_getjar xerces-2 xml-apis.jar`" >> build.properties	

	# The ${S}/ext doesn't even seem to be needed.
#	cd ${S}/ext
#	java-pkg_jar-from ant-core ant.jar
#	java-pkg_jar-from jmx
#	java-pkg_jar-from xerces-2 xercesImpl.jar
#	java-pkg_jar-from xerces-2 xml-apis.jar
}

src_compile() {
	local antflags=""

	if use jikes; then
		antflags="${antflags} -Dbuild.compiler=jikes"
	fi

	ant clean ${antflags} webapps || die "Compilation failed"

	if use junit; then
		ant ${antflags} test || die "Tests failed"
	fi

	if use doc; then
		ant ${antflags} javadoc || die "Javadoc failed"
	fi

	# TODO: don't use packed jars
	if use extra; then
		cd ${S}/extra
		ant ${antflags} do.plus do.loadbalancer do.ftp || die "Extra packages failed"
	fi
}

src_install() {
	# TODO: maybe these should be symlinks?
	java-pkg_dojar ${S}/lib/*.jar
	
	dodoc *.TXT etc/LICENSE.*
	dohtml *.html

	# Clean out ${S} before it gets put into ${D}
	rm -r classes test
	rm *.TXT *.html
	if use !"source"; then
		rm -r ant.properties build.* src extra/*/src
	fi
	if use "!extra"; then
		rm -r extra
	fi

	local OPTS_1="-m 750 -o ${JETTY_NAME} -g ${JETTY_NAME}"
	local OPTS_2="-m 640 -o ${JETTY_NAME} -g ${JETTY_NAME}"
	
	diropts ${OPTS_1}
	insopts ${OPTS_1}

	einfo "Preparing directories..."
	dodir ${JETTY_HOME}/{bin,ext,tmp,webapps} /etc/ /var/log/${JETTY_NAME}
	keepdir ${JETTY_HOME}/tmp /var/log/${JETTY_NAME}
	touch ${D}/var/log/${JETTY_NAME}/${JETTY_NAME}.log

	insinto /etc/init.d
	newins ${FILESDIR}/${PV}/${PN}.init ${JETTY_NAME}

	into ${JETTY_HOME}
	dobin ${S}/bin/jetty.sh

	insopts ${OPTS_2}

	einfo "Populating /etc..."
	# TODO: this could be done with doconfd, but would need to change around
	# ${FILESDIR} layout
	insinto /etc/conf.d
	newins ${FILESDIR}/${PV}/${PN}.conf ${JETTY_NAME}

	insinto /etc/${JETTY_NAME}
	cd ${S}/etc
	newins ${FILESDIR}/${PV}/${PN}.etc ${JETTY_NAME}.conf
	doins admin.xml jetty.mlet jetty.xml webdefault.xml

	einfo "Installing packed jars..."
	insinto ${JETTY_HOME}/ext
	doins ${S}/ext/*.jar

	einfo "Installing webapps..."
	cd ${S}/webapps
	cp -a * ${D}/${JETTY_HOME}/webapps || die "Failed to copy webapps"

	# TODO: extra use flag
	
	einfo "Fixing permissions..."
	chown -R ${JETTY_NAME}:${JETTY_NAME} ${D}/${JETTY_HOME}
	chmod -R o-rwx ${D}/${JETTY_HOME}
}

pkg_postinst() {
	einfo
	einfo " NOTICE!"
	einfo " User and group '${JETTY_NAME}' have been added."
	einfo " "
	einfo " FILE LOCATIONS:"
	einfo " 1.  Jetty home directory: ${JETTY_HOME}"
	einfo "     Contains application data, configuration files."
	einfo " 2.  Runtime settings: /etc/conf.d/${JETTY_NAME}"
	einfo "     Contains CLASSPATH,JAVA_HOME,JAVA_OPTIONS,JETTY_PORT"
	einfo "              JETTY_USER,JETTY_CONF setting"
	einfo " 3.  You can configure your 'webapp'-lications in /etc/${JETTY_NAME}.conf"
	einfo "     (the default configured webapps are the JETTY's demo/admin)"
	einfo " 4.  For more information about JETTY refer to jetty.mortbay.org"
	einfo " 5.  Logs are located at:"
	einfo "                              /var/log/${JETTY_NAME}"
	einfo
	einfo " STARTING AND STOPPING JETTY:"
	einfo "   /etc/init.d/${JETTY_NAME} start"
	einfo "   /etc/init.d/${JETTY_NAME} stop"
	einfo "   /etc/init.d/${JETTY_NAME} restart"
	einfo " "
	einfo " "
	einfo " NETWORK CONFIGURATION:"
	einfo " By default, Jetty runs on port 8080.  You can change this"
	einfo " value by setting JETTY_PORT in /etc/conf.d/${JETTY_NAME} ."
	einfo " "
	einfo " To test Jetty while it's running, point your web browser to:"
	einfo " http://localhost:8080/"
	einfo
	einfo " BUGS:"
	einfo " Please file any bugs at http://bugs.gentoo.org/ or else it"
	einfo " may not get seen. Thank you!"
	einfo

}
