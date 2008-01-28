# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1
JAVA_PKG_IUSE="doc examples source"
WANT_ANT_TASKS="ant-nodeps"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Simple Java API Windows style .ini file handling"
HOMEPAGE="http://ini4j.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-src-${PV}.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"

IUSE=""

COMMON_DEP="dev-java/servletapi:2.4"

RDEPEND=">=virtual/jre-1.5
	${COMMON_DEP}"
#	test? (
#		dev-java/ant-junit
#		dev-java/ant-nodeps
#	)
DEPEND=">=virtual/jdk-1.5
	app-arch/unzip
	${COMMON_DEP}"

S=${WORKDIR}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/disable-retroweaver.patch"
	# Needs Jetty
	rm -v src/test/org/ini4j/IniPreferencesFactoryListenerTest.java || die
}

JAVA_ANT_REWRITE_CLASSPATH="yes"
EANT_BUILD_TARGET="build"
EANT_GENTOO_CLASSPATH="servletapi-2.4"
# So that we don't need junit
EANT_EXTRA_ARGS="-Dbuild.src.test=nbproject -Dbuild.src.sample=nbproject"

# TODO Failure with xalan
# [junit] java.lang.IllegalArgumentException: Not supported: indent-number
RESTRICT="test"
src_test() {
	ANT_TASKS="ant-junit,ant-nodeps" eant test
}

src_install() {
	dodoc ReleaseNotes.txt ChangeLog.txt || die
	java-pkg_dojar dist/*.jar
	use doc && java-pkg_dojavadoc build/doc/api
	use examples && java-pkg_doexamples src/doc/sample
	use source && java-pkg_dosrc src/classes/org
}
