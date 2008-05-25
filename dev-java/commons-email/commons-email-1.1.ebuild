# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="source doc"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Commons Email aims to provide a API for sending email."
HOMEPAGE="http://commons.apache.org/email/"
SRC_URI="mirror://apache/commons/email/source/${P}-src.tar.gz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
COMMON_DEP="java-virtuals/javamail
	java-virtuals/jaf"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
	${COMMON_DEP}"

S=${WORKDIR}/${P}-src
EANT_GENTOO_CLASSPATH="jaf,javamail"
EANT_BUILD_TARGET="package"

src_unpack() {
	unpack ${A}
	cd "${S}" || die
	sed -i -e 's:<classpath refid="build.classpath"/>::g' maven-build.xml || die "sed failed"
	sed -i -e 's:compile,test:compile:g' maven-build.xml || die "sed failed"
	java-ant_rewrite-classpath maven-build.xml
}

src_install() {
	java-pkg_newjar target/${P}.jar ${PN}.jar
	dodoc {NOTICE,README,RELEASE-NOTES}.txt || die
	use doc && java-pkg_dojavadoc target/site/apidocs
	use source && java-pkg_dosrc src/java/*
}
