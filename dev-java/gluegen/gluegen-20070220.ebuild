# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

WANT_ANT_TASKS="ant-antlr"
JAVA_PKG_IUSE=""

inherit java-pkg-2 java-ant-2

DESCRIPTION="GlueGen is a tool which automatically generates the Java and JNI
code necessary to call C libraries"
HOMEPAGE="https://gluegen.dev.java.net"
SRC_URI="${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""

COMMON_DEP="dev-java/antlr"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}
	"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	${COMMON_DEP}"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}

	java-ant_rewrite-classpath "${PN}/make/build.xml"
}

src_compile() {
	cd make || dir "Unable to enter make directory"
	local antflags="-Dantlr.jar=$(java-pkg_getjars antlr)"
	local gcp="$(java-pkg_getjars ant-core):$(java-config --tools)"

	eant "${antflags}" -Dgentoo.classpath="${gcp}" all
}
src_install() {
	cd build || dir "Unable to enter build directory"

	#build copies system antlr.jar here.  
	#So we just need to replace it.
	java-pkg_jarfrom antlr
	rm "${PN}-rt-natives"*.jar
	java-pkg_dojar *.jar
	java-pkg_doso obj/*.so
	#use source && java-pkg_dosrc src
}

