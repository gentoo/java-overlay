# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# WARNING: JUNIT.JAR IS _NOT_ SYMLINKED TO ANT-CORE LIB FOLDER AS JUNIT3 IS

inherit java-pkg-2 java-ant-2

MY_P=${P/-/}
S=${WORKDIR}/${MY_P}
DESCRIPTION="Simple framework to write repeatable tests"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.zip"
HOMEPAGE="http://www.junit.org/"
LICENSE="CPL-1.0"
SLOT="4"
KEYWORDS="~x86 ~ppc ~sparc ~amd64 ~ppc64"
IUSE="doc source examples"

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5
	${RDEPEND}
	source? ( app-arch/zip )
	>=dev-java/ant-core-1.4
	app-arch/unzip"

# TODO:
# - figure how the junit jar in ant-lib could should be named
# - some way to switch between junit3 and junit4 in ant is required, otherwise
#   junit4 utilising test cases cannot be run through ant.
#   -> This would propably mean that whenever a build target is java >=1.5 the
#      ant script should put junit4.jar into classpath and otherwise use the
#      older junit.jar
# - even tests and javadoc is generated from dist target so it should be split into
#   more targets to better control what is performed
# - created jar includes even javadoc and some other stuff that doesn't seem to be
#   needed in the jar so the jar creation chould be fine-tuned

src_unpack() {
	unpack ${A}
	cd ${S}
	unzip ${P}-src.jar || die "Could not extract sources"

	# Their own unit tests do not even work in unix!
	# - reported to upstream
	sed -i 's/";"/File.pathSeparator/' org/junit/tests/JUnitCoreTest.java

	# remove jars
	rm -f *.jar
}

src_compile() {
	eant dist
}

src_install() {
	java-pkg_newjar ${MY_P}/${P}.jar
	dodir /usr/share/ant-core/lib

	dodoc README.html cpl-v10.html to-do.txt

	if use examples; then
		dodir /usr/share/doc/${PF}/examples/org/junit/samples/
		find org/junit/samples/ -name "*.class" | xargs rm
		cp -r org/junit/samples/* ${D}/usr/share/doc/${PF}/examples/org/junit/samples/ || die "Could not install examples"
	fi

	use source && java-pkg_dosrc junit org

	use doc && java-pkg_dohtml -r doc
	use doc && java-pkg_dojavadoc javadoc
}
