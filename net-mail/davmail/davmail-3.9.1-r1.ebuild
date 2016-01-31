# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="2"

REV="1646"
MY_P="${PN}-src-${PV}-${REV}"
JAVA_PKG_IUSE="source"

inherit user java-pkg-2 java-ant-2

DESCRIPTION="POP/IMAP/SMTP/Caldav/Carddav/LDAP Exchange Gateway"
HOMEPAGE="http://davmail.sourceforge.net/"
SRC_URI="mirror://sourceforge/davmail/${MY_P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# The tests can't be run in isolation?
RESTRICT="test"

CDEPEND="dev-java/commons-codec:0
	dev-java/commons-httpclient:3
	>=dev-java/htmlcleaner-2.2:0
	dev-java/jcifs:1.1
	dev-java/log4j:0
	dev-java/swt:3.8
	dev-java/stax2-api:0
	java-virtuals/javamail:0
	java-virtuals/servlet-api:2.5"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.6"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.6

	dev-java/commons-collections:0
	dev-java/slf4j-nop:0
	dev-java/xerces:2"

# The last three RDEPEND packages are required by jackrabbit-webdav.jar,
# which is bundled until it is feasible to build Apache Jackrabbit.

S="${WORKDIR}/${MY_P}"

JAVA_ANT_REWRITE_CLASSPATH="true"
EANT_BUILD_TARGET="compile"
EANT_GENTOO_CLASSPATH="commons-codec,commons-httpclient-3,htmlcleaner,jcifs-1.1,log4j,swt-3.8,stax2-api,javamail,servlet-api-2.5"
EANT_EXTRA_ARGS="-Dis.java6=true"

pkg_setup() {
	java-pkg-2_pkg_setup
	enewuser davmail
}

src_prepare() {
	# Delete bundled JARs but keep jackrabbit-webdav.jar.
	find lib -name "*.jar" ! -name "jackrabbit-webdav-*.jar" -delete -printf "removed %p\n" || die

	# Support htmlcleaner-2.2.
	sed -i -r \
		-e "/ContentToken/s/\.getContent\(\)/\0.toString()/" \
		-e "s/(Content|Comment)Token/\1Node/g" \
		src/java/davmail/exchange/ExchangeSession.java || die

	# These are unnecessary and require extra dependencies.
	find src/ -name "OSX*" -delete || die
	sed -i "/OSX[A-Z]/d" src/java/davmail/ui/{browser/DesktopBrowser,tray/DavGatewayTray}.java || die
}

src_compile() {
	java-pkg-2_src_compile
	jar cf "${PN}.jar" -C target/classes . || die
}

src_install() {
	java-pkg_register-dependency commons-collections,slf4j-nop,xerces-2

	java-pkg_dojar "${PN}.jar"
	java-pkg_newjar lib/jackrabbit-webdav-*.jar jackrabbit-webdav.jar

	newicon src/java/tray48.png "${PN}.png" || die
	java-pkg_dolauncher "${PN}" --main davmail.DavGateway
	make_desktop_entry "${PN}" "DavMail"

	insinto /etc
	doins src/web/WEB-INF/classes/davmail.properties || die
	newinitd "${FILESDIR}/initd" "${PN}" || die

	keepdir "/var/log/${PN}" || die
	fowners davmail:davmail "/var/log/${PN}" || die
	fperms 750 "/var/log/${PN}" || die

	dodoc releasenotes.txt || die
	use source && java-pkg_dosrc src/java/davmail
}

src_test() {
	local DIR="src/test"
	local CP="${DIR}:${PN}.jar:lib/jackrabbit-webdav-1.4.jar:$(java-pkg_getjars junit-4,${EANT_GENTOO_CLASSPATH})"
	ejavac -classpath "${CP}" -d "${DIR}" $(find "${DIR}" -name "*.java")

	local TESTS=$(find "${DIR}" -name "Test*.java" ! -path "${DIR}/davmail/ui/*")
	TESTS="${TESTS//src\/test\/}"
	TESTS="${TESTS//.java}"
	TESTS="${TESTS//\//.}"
	ejunit4 -classpath "${CP}" ${TESTS}
}

pkg_postinst() {
	einfo "You can run davmail as a user application or a system-wide service. In"
	einfo "the latter case, you will need to modify /etc/davmail.properties to suit"
	einfo "your needs. You may find it easier to run the davmail application,"
	einfo "configure it via the GUI and copy the resulting ~/.davmail.properties"
	einfo "to /etc."
	echo
	einfo "You can also run multiple system-wide instances of davmail by creating"
	einfo "symlinks such as /etc/init.d/davmail.foo and matching configuration"
	einfo "files such as /etc/davmail.foo.properties."
}
