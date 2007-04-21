# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# WARNING: JUNIT.JAR IS _NOT_ SYMLINKED TO ANT-CORE LIB FOLDER AS JUNIT3 IS

JAVA_PKG_IUSE="doc source"
inherit java-pkg-2 java-ant-2

MY_P=${P/-/}
S=${WORKDIR}/${MY_P}
DESCRIPTION="Simple framework to write repeatable tests"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.zip"
HOMEPAGE="http://www.junit.org/"
LICENSE="CPL-1.0"
SLOT="4"
KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="examples test"

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5
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
#   needed in the jar so the jar creation should be fine-tuned

src_unpack() {
	unpack ${A}
	cd ${S}
	mkdir src
	cd src
	unzip ../${P}-src.jar || die "Could not extract sources"

	# Their own unit tests do not even work in unix!
	# - reported to upstream
	sed -i 's/";"/File.pathSeparator/' org/junit/tests/JUnitCoreTest.java

	# remove jars
	cd ${S}
	rm -v *.jar

	# remove compiled classes
	find -name "*.class" | xargs rm -v

	# remove javadoc dir
	rm -fr javadoc
}

src_compile() {
	# create jar
	mkdir -p build/classes
	ejavac -sourcepath src -d build/classes `find src -name "*.java"` || die "Cannot compile sources"
	mkdir dist
	cd build/classes
	jar -cvf ${S}/dist/${PN}.jar junit org || die "Cannot create JAR"

	# generate javadoc
	if use doc ; then
		cd ${S}
		mkdir javadoc
		javadoc -d javadoc -sourcepath src -subpackages junit:org
	fi
}

src_test() {
	ejavac -sourcepath org:junit -cp build/classes -d build/classes `find org -name "*.java"` `find junit -name "*.java"`
	cd build/classes
	for FILE in `find -name "AllTests\.class"`; do
		CLASS=`echo ${FILE} | sed -e "s/\.class//" | sed -e "s%/%.%g" | sed -e "s/\.\.//"`
		java -cp . org.junit.runner.JUnitCore ${CLASS} || die "Test failed"
	done
}

src_install() {
	java-pkg_dojar dist/${PN}.jar
	dodoc README.html cpl-v10.html

	if use examples; then
		dodir /usr/share/doc/${PF}/examples/org/junit/samples/
		cp -r org/junit/samples/* ${D}/usr/share/doc/${PF}/examples/org/junit/samples/ || die "Could not install examples"
	fi

	use source && java-pkg_dosrc junit org src/junit src/org

	use doc && java-pkg_dohtml -r doc
	use doc && java-pkg_dojavadoc javadoc
}
