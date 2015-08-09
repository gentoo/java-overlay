# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Advanced classloader framework"
HOMEPAGE="http://classworlds.codehaus.org/"
SRC_URI="http://dev.gentooexperimental.org/~kiorky/${P}.tar.bz2"
LICENSE="codehaus-classworlds"
SLOT="1.1"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=virtual/jre-1.4
		>=dev-java/xerces-2.7"
DEPEND=">=virtual/jdk-1.4
	${RDEPEND}
	>=dev-java/ant-core-1.6"

EANT_GENTOO_CLASSPATH="xerces-2"
EANT_BUILD_TARGET="jar"
EANT_DOC_TARGET="javadoc"

src_unpack() {
	unpack ${A}
	find "${S}" -name *.jar -type f -exec rm -f '{}' \;
	for build in $(find "${S}" -name build*xml);do
		java-ant_rewrite-classpath "$build"
		# get out of classpath errors at build/test time
		sed  -i "${build}" -re\
			's/pathelement\s*path="\$\{testclassesdir\}"/pathelement path="\$\{gentoo.classpath\}:\$\{testclassesdir\}"/'\
			|| die
		# separate compile and test time
		sed  -i "${build}" -re\
			's/compile,test/compile/'\
			|| die
	done
}

src_install() {
	java-pkg_newjar "target/${P}.jar" "${PN}.jar"
	use doc && java-pkg_dojavadoc dist/docs/api
	use source && java-pkg_dosrc "${S}/src/java/main/*"
}
