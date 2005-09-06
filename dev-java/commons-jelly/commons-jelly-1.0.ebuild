# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils

MY_P="${P}-src"
DESCRIPTION=""
HOMEPAGE=""
SRC_URI="mirror://apache/jakarta/commons/jelly/source/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~x86"
IUSE="doc jikes"

LDEPEND="~dev-java/servletapi-2.3
	=dev-java/commons-cli-1*
	dev-java/commons-lang
	dev-java/commons-discovery
	dev-java/forehead
	dev-java/jakarta-jstl
	=dev-java/commons-jexl-1.0*
	=dev-java/commons-beanutils-1.6*
	dev-java/commons-collections
	dev-java/commons-logging
	=dev-java/dom4j-1*
	=dev-java/jaxen-1.1*
	=dev-java/xerces-2*"
DEPEND="virtual/jdk
	dev-java/ant-core
	jikes? (dev-java/jikes)
	dev-java/junit
	${LDEPEND}"
RDEPEND="virtual/jre
	${LDEPEND}"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd ${S}
	# disable dependency fetching, and remove tests as a dependency of jar
	epatch ${FILESDIR}/${P}-gentoo.patch

	mkdir -p ${S}/lib
	cd ${S}/lib
	java-pkg_jar-from servletapi-2.3,commons-cli-1,commons-lang
	java-pkg_jar-from commons-discovery,forehead,jakarta-jstl,commons-jexl-1.0
	java-pkg_jar-from commons-beanutils-1.6,commons-collections
	java-pkg_jar-from dom4j-1,jaxen-1.1,xerces-2
}

src_compile() {
	local antflags="-Dlibdir=lib jar"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "Ant failed"
}

src_install() {
	java-pkg_newjar target/${P}.jar ${PN}.jar
	use doc && java-pkg_dohtml -r dist/docs/api
	dodoc NOTICE.txt README.txt RELEASE-NOTES.txt
}

src_test() {
	ant test || die "Tests failed"
}
