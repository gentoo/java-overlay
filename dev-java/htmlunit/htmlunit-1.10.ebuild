# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source test"

inherit java-pkg-2 java-ant-2

MY_P="${PN}-src-${PV}"

DESCRIPTION="HtmlUnit is a java unit testing framework for testing web based applications."
HOMEPAGE="http://htmlunit.sourceforge.net/"
SRC_URI="mirror://sourceforge/htmlunit/${MY_P}.zip"
LICENSE="as-is"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"

COMMON_DEP="
	>=dev-java/commons-collections-3.2
	=dev-java/commons-httpclient-3.0*
	>=dev-java/commons-io-1.2
	~dev-java/commons-lang-2.1*
	>=dev-java/commons-logging-1.1
	~dev-java/jaxen-1.1*
	dev-java/junit
	dev-java/nekohtml
	=dev-java/rhino-1.6*
	=dev-java/xerces-2*"

DEPEND=">=virtual/jdk-1.4
	doc? ( app-arch/unzip )
	${COMMON_DEP}"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack "${A}"
	cd "${S}"

	mkdir "${S}"/ant-jars && cd "${S}"/ant-jars
	java-pkg_jar-from commons-collections
	java-pkg_jar-from commons-httpclient-3
	java-pkg_jar-from commons-lang-2.1
	java-pkg_jar-from commons-logging
	java-pkg_jar-from commons-io-1
	java-pkg_jar-from jaxen-1.1
	java-pkg_jar-from junit
	java-pkg_jar-from nekohtml
	java-pkg_jar-from rhino-1.6
	java-pkg_jar-from xerces-2
}
src_compile() {
	cd "${S}"

	mkdir "${S}"/ant-jars
	local antflags="jar"
	eant ${antflags}
}
src_install() {
	java-pkg_dojar ${PN}.jar
#	use doc && java-pkg_dojavadoc ${WORKDIR}/${JSF_P}/javadocs/
}
src_test() {
	eant junit
}

