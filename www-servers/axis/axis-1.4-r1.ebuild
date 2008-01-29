# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

WANT_ANT_TASKS="ant-nodeps"
inherit eutils java-pkg-2 java-ant-2

MY_PV="${PV//./_}"
MY_P="${PN}-${MY_PV}"
SRCFILE="${PN}-src-${MY_PV}.tar.gz"
DESCRIPTION="Apache's implementation of the SOAP (Simple Object Access Protocol)"
HOMEPAGE="http://ws.apache.org/axis/"
SRC_URI="mirror://apache/ws/${PN}/${MY_PV}/${SRCFILE}"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~amd64 ~x86"
IUSE="debug doc"

RDEPEND="
	>=dev-java/commons-discovery-0.2
	>=dev-java/wsdl4j-1.5.1
	dev-java/sun-jaf
	>=dev-java/commons-logging-1.0.4
	java-virtuals/javamail
	>=dev-java/bsf-2.3
	=dev-java/castor-1.1*
	=dev-java/commons-httpclient-3*
	dev-java/commons-net
	dev-java/sun-jimi
	=dev-java/servletapi-2.4*"
DEPEND="=virtual/jdk-1.4*
	${RDEPEND}"
RDEPEND=">=virtual/jre-1.4
	${RDEPEND}"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}

	cd "${S}"
	# remove some <copy> actions
	epatch "${FILESDIR}/${P}-build.xml.patch"
	# remove exact lib paths and global java.classpath from classpath
	epatch "${FILESDIR}/${P}-path_refs.xml.patch"
	# add missing target to javac, xml rewriting would break entities
	epatch "${FILESDIR}/${P}-tools-build.xml.patch"
	# remove most of <available> checks
	epatch "${FILESDIR}/${P}-targets.xml.patch"
	# and replace them with predefined properties
	cp "${FILESDIR}/build.properties" . \
		|| die "failed to copy build.properties from ${FILESDIR}"

	# bundled fun
	find . -name '*.jar' -delete || die

	rm -rf docs/apiDocs

	cd "${S}/lib"

	# mandatory deps
	java-pkg_jar-from commons-discovery commons-discovery.jar
	java-pkg_jar-from wsdl4j wsdl4j.jar
	java-pkg_jar-from sun-jaf activation.jar
	java-pkg_jar-from commons-logging commons-logging.jar
	# not declared mandatory but fails without it
	# mailapi.jar would be enough but that's only in -bin, mail.jar superseedes
	java-pkg_jar-from --virtual javamail

	# for axis-ant.jar
	java-pkg_jar-from --build-only ant-core ant.jar

	# potentionally optional
	java-pkg_jar-from bsf-2.3
	java-pkg_jar-from castor-1.0
	java-pkg_jar-from commons-httpclient-3 commons-httpclient.jar
	java-pkg_jar-from commons-net commons-net.jar
	java-pkg_jar-from sun-jimi
	java-pkg_jar-from servletapi-2.4 servlet-api.jar

	# there could be more - jms, jetty, xml-security?, xml-xmlbeans
	# and even more for tests - junit, httpunit, log4j, clover
}

src_compile() {
	local antflags="-Ddeprecation=false -Dbase.path=/opt"
	use debug && antflags="${antflags} -Ddebug=on"
	use !debug && antflags="${antflags} -Ddebug=off"
	eant ${antflags} compile "$(use_doc javadocs)"
}

src_install() {
	java-pkg_dojar build/lib/axis*.jar
	java-pkg_dojar build/lib/jaxrpc.jar
	java-pkg_dojar build/lib/saaj.jar

	dodoc NOTICE README || die
	dohtml release-notes.html changelog.html || die

	if use doc; then
		java-pkg_dojavadoc build/javadocs/
		dohtml -r docs/*
	fi
}
