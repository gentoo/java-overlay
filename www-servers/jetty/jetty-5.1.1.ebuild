# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg

DESCRIPTION="A Lightweight Servlet Engine"

SLOT="${PV/.*}"
SRC_URI="mirror://sourceforge/jetty/${P}-all.zip"
HOMEPAGE="http://www.mortbay.org/"
KEYWORDS="x86"
LICENSE="Apache-1.1"
RDEPEND="jikes? ( dev-java/jikes )
	>=virtual/jdk-1.4"
DEPEND="${RDEPEND}
	>=dev-java/ant-1.6
	extra? ( >=dev-java/commons-cli-1.0 )
	>=dev-java/commons-el-1.0
	>=dev-java/commons-logging-1.0.4
	extra? ( >=dev-java/jta-1.0.1 )
	junit? ( dev-java/junit )
	extra? ( >=dev-java/log4j-1.2 )
	extra? ( >=dev-java/sun-javamail-bin-1.3.1 )
	>=dev-java/xerces-2.7"
IUSE="doc extra jikes junit source"
S="${WORKDIR}/${P}"

JETTY_HOME="/opt/${PN}${SLOT}"
JETTY_NAME="${PN}${SLOT}"

pkg_setup() {
	enewgroup ${JETTY_NAME}
	enewuser ${JETTY_NAME} -1 /bin/bash ${JETTY_HOME} ${JETTY_NAME}
}

src_unpack() {
	unpack ${A}
	if use source; then
		S_ORIG="${WORKDIR}/${P}.orig"
		cp -a ${S} ${S_ORIG}
	fi
	epatch ${FILESDIR}/${PV}/${PN}.patch

	# We want our own JARs
	cd ${S}/ext
	for JAR in ant commons-el commons-logging xercesImpl xml-apis xmlParserAPIs; do
		rm -f ${JAR}*.jar
	done
	java-pkg_jar-from ant-core ant.jar
	java-pkg_jar-from commons-el commons-el.jar
	java-pkg_jar-from commons-logging commons-logging.jar
	java-pkg_jar-from xerces-2 xercesImpl.jar
	java-pkg_jar-from xerces-2 xml-apis.jar
	java-pkg_jar-from xerces-2 xmlParserAPIs.jar

	if use extra; then
		cd ${S}/extra/ext
		for JAR in commons-cli jta-spec1_0_1.jar log4j mail; do
			rm -f ${JAR}*.jar
		done
		java-pkg_jar-from commons-cli-1 commons-cli.jar
		java-pkg_jar-from jta jta.jar
		java-pkg_jar-from log4j log4j.jar
		java-pkg_jar-from sun-javamail-bin mail.jar
	fi
}

src_compile() {
	
	einfo "Cleaning source directory..."
	cd ${S}
	ant clean || die "Cleaning failed."

	einfo "Building main packages..."
	local antflags=""
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"

	cd ${S}
	ant ${antflags} prepare jars || die "Building main packages failed."
	use junit || ant ${antflags} webapps || die "Building main packages failed."

	if use extra; then
		einfo "Building extra packages..."
		cd ${S}/extra
		ant ${antflags} do.plus do.loadbalancer do.ftp || die "Building extra packages failed."
	fi

	cd ${S}
	
	if use junit; then
		einfo "Running tests..."
		ant ${antflags} test || die "Tests failed."
	elif use doc; then
		einfo "Building javadoc..."
		ant ${antflags} javadoc || die "Building javadoc failed."	
	fi
}

pkg_preinst() {
	chown -R ${JETTY_NAME}:${JETTY_NAME} ${D}
}

src_install() {
	OPTS_1="-m 750 -o ${JETTY_NAME} -g ${JETTY_NAME}"
	OPTS_2="-m 640 -o ${JETTY_NAME} -g ${JETTY_NAME}"

	cd ${S}

	einfo "Installing main packages..."
	diropts ${OPTS_1}
	insopts ${OPTS_1}

	insinto /etc/init.d
	newins ${FILESDIR}/${PV}/${PN}.init ${JETTY_NAME}

	dodir ${JETTY_HOME} ${JETTY_HOME}/bin ${JETTY_HOME}/tmp ${JETTY_HOME}/webapps /etc/${JETTY_NAME} /var/log/${JETTY_NAME}

	keepdir ${JETTY_HOME}/tmp
	keepdir /var/log/${JETTY_NAME}
	touch ${D}/var/log/${JETTY_NAME}/${JETTY_NAME}.log

	into ${JETTY_HOME}
	dobin ${S}/extra/unix/bin/jetty.sh

	insopts ${OPTS_2}

	insinto /etc
	newins ${FILESDIR}/${PV}/${PN}.etc ${JETTY_NAME}.conf

	insinto /etc/conf.d
	newins ${FILESDIR}/${PV}/${PN}.conf ${JETTY_NAME}

	insinto ${JETTY_HOME}
	dodoc ${S}/*.TXT

	cd ${S}/etc
	insinto /etc/${JETTY_NAME}
	doins admin.xml commons-logging.properties jetty.mlet jetty.xml simplelog.properties webdefault.xml
	dodoc LICENSE.*

	cd ${S}/webapps
	cp -a * ${D}/${JETTY_HOME}/webapps

	into /usr
	java-pkg_dojar ${S}/*.jar ${S}/ext/*.jar ${S}/lib/*.jar

	if use extra; then
		einfo "Installing extra packages..."
		dodir ${JETTY_HOME}/demo /etc/${JETTY_NAME}/dtd
		cp -a ${S}/demo/* ${D}/${JETTY_HOME}/demo

		cd ${S}/etc
		insinto /etc/${JETTY_NAME}
		doins demo* examplesRealm.properties ht* j2me.xml jdbcRealm.properties jettydemo.p12 jetty.policy proxy.xml simplelog.properties stress* watchdog.xml

		insinto /etc/${JETTY_NAME}/dtd
		doins ${S}/etc/dtd/*
		
		cd ${S}/extra/etc
		insinto ${JETTY_HOME}/extra/etc
		doins jaas.* jettyplus.* login.conf start*.config tmtest*
		dodoc LICENSE.*

		java-pkg_dojar ${S}/extra/ext/*.jar

		for DIR in . ftp ibmjsse j2ee jdk1.2 jsr77 jsr77/test loadbalancer plus plus/test wadi; do
			dodir ${JETTY_HOME}/extra/${DIR}
			insinto ${JETTY_HOME}/extra/${DIR}
			cd ${S}/extra/${DIR}
			doins $(find -type f -maxdepth 1)
		done

		for DIR in j2ee/etc jsr77/test lib plus/demo/webapps plus/test resources wadi win32 ;do
			dodir ${JETTY_HOME}/extra/${DIR}
			cp -a ${S}/extra/${DIR}/* ${D}/${JETTY_HOME}/extra/${DIR}
		done
	fi

	if use source; then
		einfo "Installing source files..."
		cd ${S_ORIG}
		insinto ${JETTY_HOME}
		doins ant.properties build.xml

		for DIR in extra/ftp/src extra/ftp/test/src extra/ibmjsse/src extra/j2ee/src extra/jdk1.2/src extra/jsr77/src extra/loadbalancer/src extra/plus/demo/src extra/plus/src extra/plus/test/src src test; do
			dodir ${JETTY_HOME}/${DIR}
			cp -a ${S_ORIG}/${DIR}/* ${D}/${JETTY_HOME}/${DIR}
		done
	fi

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
