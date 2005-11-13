# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg

DESCRIPTION="A continuous build framework"
HOMEPAGE="http://cruisecontrol.sourceforge.net/"
SRC_URI="mirror://sourceforge/cruisecontrol/${P}.zip"

LICENSE="ThoughtWorks"
SLOT="0"
KEYWORDS="x86"

IUSE="doc jikes test"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	=dev-java/batik-1.5.1*
	dev-util/checkstyle
	dev-java/commons-net
	dev-java/commons-logging
	=dev-java/jakarta-oro-2.0*
	=dev-java/jcommon-0.8*
	=dev-java/jdom-1.0*
	test? (dev-java/ant-tasks dev-java/junit)
	dev-java/log4j
	=dev-java/mx4j-2.1*
	=dev-java/servletapi-2.3*
	dev-java/sun-jaf-bin
	dev-java/sun-javamail-bin
	dev-java/xalan
	=dev-java/xerces-2*
	"
RDEPEND=">=virtual/jdk-1.4
	dev-java/sun-jaf-bin
	=dev-java/jakarta-oro-2*
	=dev-java/jdom-1.0
	dev-java/log4j
	dev-java/sun-javamail-bin
	=dev-java/mx4j-2.1*
	=dev-java/xerces-1.3*
	dev-java/xalan
	=dev-java/fast-md5-2*
	=www-servers/jetty-5*
	=dev-java/smack-2.0*
	=dev-java/jfreechart-0.9.8*
	=dev-java/cewolf-0.10*"

CRUISE_CONF_DIR="/etc/cruisecontrol"
CRUISE_WORK_DIR="/var/cruisecontrol"
CRUISE_LOG_DIR="/var/log/cruisecontrol"

CRUISE_USER="cruise"
CRUISE_GROUP="cruise"

src_unpack() {
	unpack ${A}
	cd ${S}

	# gentooify the build.xml
	epatch ${FILESDIR}/${PV}/${P}-gentoo.patch

	# Patch for PMD reports -cgs
	#epatch ${FILESDIR}/${P}-pmd.patch

	# Patch for FindBugs reports -cgs
	epatch ${FILESDIR}/${PV}/${P}-findbugs.patch


	cd ${S}/main
	# Remove classes we can't deal with:
	#	uses library with dead upstream
	rm src/net/sourceforge/cruisecontrol/publishers/X10Publisher.java

	cd ${S}/main/lib
	rm *.jar

	java-pkg_jar-from sun-jaf-bin activation.jar
	java-pkg_jar-from fast-md5-2 fast-md5.jar fast-md5.jar
	java-pkg_jar-from commons-net commons-net.jar
	java-pkg_jar-from jakarta-oro-2.0 jakarta-oro.jar
	java-pkg_jar-from jdom-1.0 jdom.jar
	java-pkg_jar-from log4j log4j.jar
	java-pkg_jar-from sun-javamail-bin mail.jar
	java-pkg_jar-from mx4j-2.1 mx4j-remote.jar
	java-pkg_jar-from mx4j-2.1 mx4j-tools.jar
	java-pkg_jar-from mx4j-2.1 mx4j.jar
	java-pkg_jar-from xalan xalan.jar
	java-pkg_jar-from xerces-2 xercesImpl.jar
	java-pkg_jar-from xerces-2 xml-apis.jar
	java-pkg_jar-from jetty-5 org.mortbay.jetty.jar
	java-pkg_jar-from smack-2.0 smack.jar

	cd ${S}/reporting/jsp/lib
	rm *.jar
	java-pkg_jar-from batik-1.5.1 batik-awt-util.jar
	java-pkg_jar-from batik-1.5.1 batik-svggen.jar
	java-pkg_jar-from batik-1.5.1 batik-util.jar
	java-pkg_jar-from cewolf-0.10
	java-pkg_jar-from checkstyle checkstyle.jar checkstyle-all-3.1.jar
	java-pkg_jar-from commons-logging commons-logging.jar
	java-pkg_jar-from jcommon-0.8 jcommon.jar jcommons-0.8.0.jar
	java-pkg_jar-from jfreechart-0.9.8 jfreechart.jar jfreechart-0.9.8.jar
	java-pkg_jar-from jfreechart-0.9.8 jfreechart-demo.jar jfreechart-0.9.8-demo.jar
	java-pkg_jar-from servletapi-2.3 servlet.jar
	java-pkg_jar-from xalan xalan.jar
	java-pkg_jar-from xerces-2 xercesImpl.jar
	java-pkg_jar-from xerces-2 xml-apis.jar
}

src_compile() {
	local antflags="jar"

	cd ${S}/main
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} javadoc"
	ant ${antflags} || die "Compilation of CruiseControl failed"

	einfo "Building CruiseControl Web App"

	cd ${S}/reporting/jsp

	# TODO: detect jdk version, and set the correct properties
	cat << EOF > override.properties
user.log.dir=${CRUISE_WORK_DIR}/logs
user.build.status.file=buildstatus.txt
cruise.build.artifacts.dir=${CRUISE_WORK_DIR}/artifacts
jdk1.4=true
EOF

	antflags="war"
	ant ${antflags} || die "Compile of CruiseControl web app failed"
}

src_install() {
	cd ${S}/main

	java-pkg_dojar dist/${PN}.jar

	if use doc; then
		dohtml -r docs
		dohtml -r reporting/jsp/docs
	fi

	cd ${S}/reporting/jsp

	java-pkg_dowar dist/*.war

	enewgroup ${CRUISE_GROUP}

	# Just in case.  See below. -cgs
	/usr/sbin/nscd -i group

	enewuser ${CRUISE_USER} -1 /bin/bash ${CRUISE_WORK_DIR} ${CRUISE_GROUP}

	# Old cache produces "install: invalid user `cruise'" -cgs
	/usr/sbin/nscd -i passwd

	insinto ${CRUISE_CONF_DIR}
	doins ${FILESDIR}/${PV}/config.xml

	newinitd ${FILESDIR}/${PV}/${PN}.init ${PN}
	newconfd ${FILESDIR}/${PV}/${PN}.conf ${PN}

	diropts -m 0775 -o root -g ${CRUISE_GROUP}
	keepdir ${CRUISE_LOG_DIR}

	diropts -m 0775 -g ${CRUISE_GROUP}
	keepdir ${CRUISE_WORK_DIR}

	diropts -m 0775 -o ${CRUISE_USER} -g ${CRUISE_GROUP}
	keepdir ${CRUISE_WORK_DIR}/artifacts
	keepdir ${CRUISE_WORK_DIR}/checkout
	keepdir ${CRUISE_WORK_DIR}/logs
}

src_test() {
	if use test; then
		cd ${S}/main/

		local antflags="${antflags} test-all"
		ant ${antflags} || die "unit tests failed"

	else
		ewarn "Skipping unit tests..."
		ewarn "You must specify USE=test in order to get the proper"
		ewarn "dependencies to run unit tests, in addition to"
		ewarn "FEATURES=test."
	fi
}
