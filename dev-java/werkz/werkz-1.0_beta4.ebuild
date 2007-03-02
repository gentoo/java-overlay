# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

WANT_ANT_TASKS="ant-junit"

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="Goal-oriented process framework"
HOMEPAGE="http://werkz.sourceforge.net/"
# project still used but definitivly dead
SRC_URI="http://gentooexperimental.org/distfiles/${P}.tar.bz2"
LICENSE="Werken"
SLOT="0"
KEYWORDS=""
IUSE="doc source"

LDEPEND="dev-java/commons-logging
	=dev-java/commons-jelly-1*
	=dev-java/commons-jelly-tags-ant-1*
	dev-java/ant-core"
DEPEND=">=virtual/jdk-1.4 ${LDEPEND}"
RDEPEND=">=virtual/jre-1.4 ${LDEPEND}"

S=${WORKDIR}/${PN}

EANT_GENTOO_CLASSPATH="commons-jelly-1,commons-jelly-tags-ant-1,commons-logging,ant-core"
EANT_BUILD_TARGET="jar"
EANT_DOC_TARGET="-Djavadocdir=target/docs/api javadoc"

src_unpack() {
	unpack ${A}
	cd ${S} || die
	epatch ${FILESDIR}/${P}-gentoo.patch
	for i in $(find ${S}/build*xml);do
		java-ant_rewrite-classpath "$i"
		sed  -i ${i} -re\
			's/pathelement\s*path="\$\{testclassesdir\}"/pathelement path="\$\{gentoo.classpath\}:\$\{testclassesdir\}"/'\
			|| die

	done
}

src_install() {
	java-pkg_newjar target/${PN}*.jar ${PN}.jar
	use doc && java-pkg_dojavadoc target/docs/api
	use source && java-pkg_dosrc src
}


src_test() {
	eant test || die "Test failed"
}
