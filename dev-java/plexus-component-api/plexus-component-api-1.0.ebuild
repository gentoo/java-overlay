# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="The Plexus project provides a full software stack for creating and executing software projects."
HOMEPAGE="http://plexus.codehaus.org/"

SRC_URI="http://dev.gentooexperimental.org/~kiorky/${P}.tar.bz2"

LICENSE="as-is" # http://plexus.codehaus.org/plexus-utils/license.html
SLOT="0"
KEYWORDS="~x86"
IUSE="source"

DEP="=dev-java/plexus-classworlds-1.2*"
DEPEND=">=virtual/jdk-1.4 ${DEP}"
RDEPEND=">=virtual/jre-1.4 ${DEP}"

EANT_BUILD_TARGET="jar"
EANT_EXTRA_FLAGS="-Dproject.name=${PN}"
EANT_GENTOO_CLASSPATH="plexus-classworlds"

src_unpack() {
	unpack ${A}
	find "${S}" -name *.jar -exec rm -f {} \; || die
	for build in $(find "${S}" -name build*xml);do
		java-ant_rewrite-classpath "$build"
		# get out of classpath errors at build/test time
		sed  -i "${build}" -re\
			's/depends="get-deps"/ /'\
			|| die
		sed  -i "${build}" -re\
			's/pathelement\s*path="\$\{testclassesdir\}"/pathelement path="\$\{gentoo.classpath\}:\$\{testclassesdir\}"/'\
			|| die
		sed  -i "${build}" -re\
			's/refid=\"build\.classpath/path=\"gentoo\.classpath/'\
			|| die
		# separate compile and test time
		sed  -i "${build}" -re\
			's/compile,test/compile/'\
			|| die
	done
}

src_install() {
	java-pkg_newjar target/*.jar "${PN}.jar"
	use source && java-pkg_dosrc "${S}/src/main/java"
}
