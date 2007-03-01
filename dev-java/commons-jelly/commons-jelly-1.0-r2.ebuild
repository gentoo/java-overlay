# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-jelly/commons-jelly-1.0-r1.ebuild,v 1.4 2007/02/10 14:28:42 betelgeuse Exp $

inherit java-pkg-2 java-ant-2 eutils

MY_P="${P}-src"
DESCRIPTION="A Java and XML based scripting and processing engine"
HOMEPAGE="http://jakarta.apache.org/commons/jelly/"
SRC_URI="mirror://apache/jakarta/commons/jelly/source/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~x86"
IUSE="doc test source"

RDEPEND=">=virtual/jre-1.4
	~dev-java/servletapi-2.3
	=dev-java/commons-cli-1*
	dev-java/commons-lang
	dev-java/commons-discovery
	dev-java/forehead
	dev-java/jakarta-jstl
	dev-java/commons-jexl
	=dev-java/commons-beanutils-1.6*
	dev-java/commons-collections
	=dev-java/dom4j-1*
	=dev-java/jaxen-1.1*
	>=dev-java/xerces-2.7
	dev-java/junit
	dev-java/commons-logging"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	test? ( dev-java/ant-junit )
	${RDEPEND}"

S=${WORKDIR}/${MY_P}

EANT_BUILD_TARGET="jar"
EANT_GENTOO_CLASSPATH="servletapi-2.3
			commons-cli-1
			commons-lang
			commons-discovery
			forehead
			jakarta-jstl
			commons-jexl-1.0
			commons-beanutils-1.6
			commons-collections
			dom4j-1
			jaxen-1.1
			xerces-2
			junit
			commons-logging"

src_unpack() {
	unpack ${A}
	cd "${S}" || die
	# disables dependency fetching, and remove tests as a dependency of jar
	epatch ${FILESDIR}/${P}-gentoo.patch
	# searching for maven style generated ant build files
	# rewrite their classpath and prevent them to use bundled jars !
	for build in $(find "${WORKDIR}" -name build*xml);do
		java-ant_rewrite-classpath "$build"
	done

}

src_test() {
	ANT_TASKS="ant-junit" eant test
}

src_install() {
	java-pkg_newjar target/${P}.jar ${PN}.jar

	dodoc NOTICE.txt README.txt RELEASE-NOTES.txt || die

	use doc && java-pkg_dojavadoc dist/docs/api
	use source && java-pkg_dosrc src/java/*
}
