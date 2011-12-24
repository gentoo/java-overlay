# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/tomcat/tomcat-5.5.27-r5.ebuild,v 1.2 2011/11/03 00:46:33 vapier Exp $

EAPI="2"
JAVA_PKG_IUSE="doc source"
WANT_ANT_TASKS="ant-trax"

inherit eutils java-pkg-2 java-ant-2 user

DESCRIPTION="Tomcat Servlet-2.4/JSP-2.0 Container"

MY_P="apache-${P}-src"
SLOT="5.5"
SRC_URI="mirror://apache/${PN}/${PN}-5/v${PV}/src/${MY_P}.tar.gz"
HOMEPAGE="http://tomcat.apache.org/"
KEYWORDS="~amd64 -ppc -ppc64 ~x86 ~x86-fbsd"
LICENSE="Apache-2.0"

IUSE="admin examples test"

RDEPEND="dev-java/eclipse-ecj:3.3
	dev-java/ant-eclipse-ecj:3.3
	dev-java/commons-beanutils:1.7
	>=dev-java/commons-collections-3.1
	>=dev-java/commons-daemon-1.0.1
	>=dev-java/commons-dbcp-1.2.1
	>=dev-java/commons-digester-1.7
	>=dev-java/commons-fileupload-1.1
	dev-java/commons-httpclient:0
	>=dev-java/commons-io-1.1
	>=dev-java/commons-el-1.0
	>=dev-java/commons-launcher-0.9
	>=dev-java/commons-logging-1.0.4
	>=dev-java/commons-modeler-2.0
	>=dev-java/commons-pool-1.2
	=dev-java/junit-3*
	>=dev-java/log4j-1.2.9
	>=dev-java/saxpath-1.0
	>=dev-java/tomcat-servlet-api-${PV}-r1:2.4
	dev-java/ant-core
	admin? ( dev-java/struts:1.2 )
	dev-java/sun-javamail
	>=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5
	${RDEPEND}"

S=${WORKDIR}/${MY_P}

TOMCAT_NAME="${PN}-${SLOT}"
WEBAPPS_DIR="/var/lib/${TOMCAT_NAME}/webapps"

pkg_setup() {
	java-pkg-2_pkg_setup
	# new user for tomcat
	enewgroup tomcat
	enewuser tomcat -1 -1 /dev/null tomcat

	java-pkg_filter-compiler ecj-3.1  ecj-3.2
}

java_prepare() {
	epatch "${FILESDIR}/${SLOT}/26-main_tomcat_catalina_jasper_build_xml.patch"
	# https://issues.apache.org/bugzilla/show_bug.cgi?id=45827
	epatch "${FILESDIR}/${SLOT}/5.5.27-dynamic-JSSE13Factory.patch"
	epatch "${FILESDIR}/${SLOT}/examples-cal.patch"
	epatch "${FILESDIR}/${SLOT}/build-jspc-classpath.patch"

	use examples && epatch "${FILESDIR}/${SLOT}/jsr152_jsr154_examples_build_xml.patch"

	sed -i -e 's:${struts.lib}:/usr/share/struts-1.2:' \
		"${S}/container/webapps/admin/build.xml"

	einfo "Removing 1.3 factories to so we don't need com.sun.*"
	rm -v connectors/util/java/org/apache/tomcat/util/net/jsse/*13* || die

	# avoid packed jars :-)
	mkdir -p "${S}"/build/build/common
	cd "${S}"/build/build

	mkdir ./bin && cd ./bin
	java-pkg_jar-from commons-logging commons-logging-api.jar
	java-pkg_jar-from commons-daemon

	mkdir "${S}"/build/build/common/lib && cd "${S}"/build/build/common/lib
	java-pkg_jar-from ant-core
	java-pkg_jar-from commons-collections
	java-pkg_jar-from commons-dbcp
	java-pkg_jar-from commons-el
	java-pkg_jar-from commons-pool
	java-pkg_jar-from tomcat-servlet-api-2.4

	mkdir -p "${S}"/build/build/server/lib && cd "${S}"/build/build/server/lib
	java-pkg_jar-from commons-beanutils-1.7 commons-beanutils.jar
	java-pkg_jar-from commons-digester
	java-pkg_jar-from commons-modeler

}

src_compile(){
	local antflags="-Dbase.path=${T}"

	antflags="${antflags} -Dservletapi.build.notrequired=true"
	antflags="${antflags} -Djspapi.build.notrequired=true"
	antflags="${antflags} -Dcommons-beanutils.jar=$(java-pkg_getjar commons-beanutils-1.7 commons-beanutils.jar)"
	antflags="${antflags} -Dcommons-collections.jar=$(java-pkg_getjars commons-collections)"
	antflags="${antflags} -Dcommons-daemon.jar=$(java-pkg_getjars commons-daemon)"
	antflags="${antflags} -Dcommons-digester.jar=$(java-pkg_getjars commons-digester)"
	antflags="${antflags} -Dcommons-dbcp.jar=$(java-pkg_getjars commons-dbcp)"
	antflags="${antflags} -Dcommons-el.jar=$(java-pkg_getjars commons-el)"
	antflags="${antflags} -Dcommons-fileupload.jar=$(java-pkg_getjars commons-fileupload)"
	antflags="${antflags} -Dcommons-httpclient.jar=$(java-pkg_getjars commons-httpclient)"
	antflags="${antflags} -Dcommons-io.jar=$(java-pkg_getjars commons-io-1)"
	antflags="${antflags} -Dcommons-launcher.jar=$(java-pkg_getjars commons-launcher)"
	antflags="${antflags} -Dcommons-logging.jar=$(java-pkg_getjar commons-logging commons-logging.jar)"
	antflags="${antflags} -Dcommons-logging-api.jar=$(java-pkg_getjar commons-logging commons-logging-api.jar)"
	antflags="${antflags} -Dcommons-pool.jar=$(java-pkg_getjars commons-pool)"
	antflags="${antflags} -Dcommons-modeler.jar=$(java-pkg_getjars commons-modeler)"
	antflags="${antflags} -Djdt.jar=$(java-pkg_getjar eclipse-ecj-3.3 ecj.jar)"
	antflags="${antflags} -Djsp-api.jar=$(java-pkg_getjar tomcat-servlet-api-2.4 jsp-api.jar)"
	antflags="${antflags} -Djunit.jar=$(java-pkg_getjars junit)"
	antflags="${antflags} -Dlog4j.jar=$(java-pkg_getjars log4j)"
	antflags="${antflags} -Dmail.jar=$(java-pkg_getjar sun-javamail mail.jar)"
	antflags="${antflags} -Dsaxpath.jar=$(java-pkg_getjar saxpath saxpath.jar)"
	antflags="${antflags} -Dservlet-api.jar=$(java-pkg_getjar tomcat-servlet-api-2.4 servlet-api.jar)"
	if use admin; then
		antflags="${antflags} -Dstruts.jar=$(java-pkg_getjar struts-1.2 struts.jar)"
		antflags="${antflags} -Dstruts.home=/usr/share/struts"
	else
		antflags="${antflags} -Dadmin.build.notrequired=true"
		antflags="${antflags} -Dadmin.precompile.notrequired=true"
	fi
	if ! use examples; then
		antflags="${antflags} -Dexamples.build.notrequired=true"
		antflags="${antflags} -Dexamples.precompile.notrequired=true"
	fi
	antflags="${antflags} -Djasper.home=${S}/jasper"

	eant ${antflags}
}

src_install() {
	cd "${S}"/build/build

	# init.d, conf.d
	newinitd "${FILESDIR}"/${SLOT}/tomcat.init.2 ${TOMCAT_NAME}
	newconfd "${FILESDIR}"/${SLOT}/tomcat.conf.2 ${TOMCAT_NAME}

	# create dir structure
	diropts -m755 -o tomcat -g tomcat
	dodir /usr/share/${TOMCAT_NAME}
	keepdir /var/log/${TOMCAT_NAME}/
	keepdir /var/tmp/${TOMCAT_NAME}/
	keepdir /var/run/${TOMCAT_NAME}/

	local CATALINA_BASE=/var/lib/${TOMCAT_NAME}/
	dodir   ${CATALINA_BASE}
	keepdir ${CATALINA_BASE}/shared/lib
	keepdir ${CATALINA_BASE}/shared/classes

	keepdir /usr/share/${TOMCAT_NAME}/common/lib

	dodir   /etc/${TOMCAT_NAME}
	fperms  750 /etc/${TOMCAT_NAME}

	diropts -m0755

	# we don't need dos scripts
	rm -f bin/*.bat

	# copy the manager and admin context's to the right position
	mkdir -p conf/Catalina/localhost
	if use admin; then
		cp "${S}"/container/webapps/admin/admin.xml \
			conf/Catalina/localhost
	fi
	cp "${S}"/container/webapps/manager/manager.xml \
		conf/Catalina/localhost

	# make the jars available via java-pkg_getjar and jar-from, etc
	base=$(pwd)
	libdirs="common/lib server/lib"
	for dir in ${libdirs}
	do
		cd "${dir}"

		for jar in *.jar;
		do
			# replace the file with a symlink
			if [ ! -L ${jar} ]; then
				java-pkg_dojar ${jar}
				rm -f ${jar}
				ln -s ${DESTTREE}/share/${TOMCAT_NAME}/lib/${jar} ${jar}
			fi
		done

		cd ${base}
	done

	# replace a packed struts.jar
	if use admin; then
		cd server/webapps/admin/WEB-INF/lib
		rm -f struts.jar
		java-pkg_jar-from struts-1.2 struts.jar
		cd ${base}
	else
		rm -fR server/webapps/admin
	fi

	cd server/webapps/manager/WEB-INF/lib
	java-pkg_jar-from commons-fileupload
	java-pkg_jar-from commons-io-1
	cd ${base}

	# replace the default pw with a random one, see #92281
	local randpw=$(echo ${RANDOM}|md5sum|cut -c 1-15)
	sed -e s:SHUTDOWN:${randpw}: -i conf/{server,server-minimal}.xml

	# copy over the directories
	chown -R tomcat:tomcat webapps/* conf/*
	cp -pR conf/* "${D}"/etc/${TOMCAT_NAME} || die "failed to copy conf"
	cp -HR bin common server "${D}"/usr/share/${TOMCAT_NAME} || die "failed to copy"

	# replace catalina.policy with gentoo specific one bug #176701
	cp "${FILESDIR}"/${SLOT}/catalina.policy "${D}"/etc/${TOMCAT_NAME} || die "failed to replace catalina.policy"

	keepdir               ${WEBAPPS_DIR}
	set_webapps_perms     "${D}"/${WEBAPPS_DIR}

	# Copy over webapps, some controlled by use flags
	cp -p ../RELEASE-NOTES webapps/ROOT/RELEASE-NOTES.txt
	cp -pr webapps/ROOT "${D}"${CATALINA_BASE}/webapps
	if use doc; then
		cp -pr webapps/tomcat-docs "${D}"${CATALINA_BASE}/webapps
	fi
	if use examples; then
		cp -pr webapps/{jsp-examples,servlets-examples,webdav} \
			"${D}"${CATALINA_BASE}/webapps
	fi

	# symlink the directories to make CATALINA_BASE possible
	dosym /etc/${TOMCAT_NAME} ${CATALINA_BASE}/conf
	dosym /var/log/${TOMCAT_NAME} ${CATALINA_BASE}/logs
	dosym /var/tmp/${TOMCAT_NAME} ${CATALINA_BASE}/temp
	dosym /var/run/${TOMCAT_NAME} ${CATALINA_BASE}/work

	dodoc  "${S}"/build/{RELEASE-NOTES,RUNNING.txt}
	fperms 640 /etc/${TOMCAT_NAME}/tomcat-users.xml
}

pkg_postinst() {
	#due to previous ebuild bloopers, make sure everything is correct
	chown root:root /etc/init.d/${TOMCAT_NAME}
	chown root:root /etc/conf.d/${TOMCAT_NAME}

	elog
	elog " This ebuild implements a new filesystem layout for tomcat"
	elog " please read http://www.gentoo.org/proj/en/java/tomcat-guide.xml"
	elog " for more information!."
	elog
	ewarn "naming-factory-dbcp.jar is not built at this time. Please fetch"
	ewarn "jar from upstream binary if you need it. Gentoo Bug # 144276"
	elog
	elog " Please file any bugs at http://bugs.gentoo.org/ or else it"
	elog " may not get seen.  Thank you."
	elog
}

#helpers
set_webapps_perms() {
	chown  tomcat:tomcat ${1} || die "Failed to change owner off ${1}."
	chmod  750           ${1} || die "Failed to change permissions off ${1}."
}

pkg_config() {
	# Better suggestions are welcome
	local currentdir=$(egethome tomcat)

	elog "The default home directory for Tomcat is /dev/null."
	elog "You need to change it if your applications needs it to"
	elog "be an actual directory. Current home directory:"
	elog "${currentdir}"
	elog ""
	elog "Do you want to change it [yes/no]?"

	local answer
	read answer

	if [[ "${answer}" == "yes" ]]; then
		elog ""
		elog "Suggestions:"
		elog "${WEBAPPS_DIR}"
		elog ""
		elog "If you want to suggest a directory, file a bug to"
		elog "http://bugs.gentoo.org"
		elog ""
		elog "Enter home directory:"

		local homedir
		read homedir

		elog ""
		elog "Setting home directory to: ${homedir}"

		/usr/sbin/usermod -d"${homedir}" tomcat

		elog "You can run emerge --config =${PF}"
		elog "again to change to homedir"
		elog "at any time."
	fi
}
