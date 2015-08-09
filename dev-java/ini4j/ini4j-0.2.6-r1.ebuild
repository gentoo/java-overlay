# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

JAVA_PKG_IUSE="doc examples source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Simple Java API Windows style .ini file handling"
HOMEPAGE="http://ini4j.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-src-${PV}.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

COMMON_DEP="java-virtuals/servlet-api:2.4"

RDEPEND=">=virtual/jre-1.5
	${COMMON_DEP}"
# Preferences api is broken in 1.6 if a later xalan version is in cp
# http://bugs.sun.com/bugdatabase/view_bug.do?bug_id=6519088
DEPEND="
	>=virtual/jdk-1.5
	app-arch/unzip
	${COMMON_DEP}"

S=${WORKDIR}

java_prepare() {
	epatch "${FILESDIR}/disable-retroweaver.patch"
	# Needs Jetty
	rm -rf src/test/* || die
}

JAVA_ANT_REWRITE_CLASSPATH="yes"
EANT_BUILD_TARGET="build"
EANT_GENTOO_CLASSPATH="servlet-api-2.4"
# So that we don't need junit
EANT_EXTRA_ARGS="-Dbuild.src.sample=nbproject"

src_install() {
	dodoc ReleaseNotes.txt ChangeLog.txt || die
	java-pkg_dojar dist/*.jar
	use doc && java-pkg_dojavadoc build/doc/api
	use examples && java-pkg_doexamples src/doc/sample
	use source && java-pkg_dosrc src/classes/org
}
