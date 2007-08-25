# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source test"
inherit java-pkg-2 java-ant-2

MY_P="${PN}${PV}"
DESCRIPTION="EasyMock provides Mock Objects for interfaces in JUnit tests by generating them on the fly using Java's proxy mechanism"
HOMEPAGE="http://www.easymock.org/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.zip"

# TODO figure out license
LICENSE="MIT"
SLOT="2"
KEYWORDS="~amd64 ~x86"
IUSE="examples"

COMMON_DEPEND="
	test? ( >=dev-java/junit-4 )"
DEPEND=">=virtual/jdk-1.5
	${COMMON_DEPEND}
	app-arch/unzip"
RDEPEND=">=virtual/jre-1.5
	${COMMON_DEPEND}"
S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd ${S}
	unzip -qq -d src/ src.zip
	use test && unzip -qq -d test/ tests.zip
	use examples && unzip -qq -d examples/ samples.zip
}

src_compile() {
	# create jar
	mkdir -p build/classes

	if use test ; then
		ejavac -sourcepath src -d build/classes -cp \
			$(java-pkg_getjars junit-4) \
			`find src -name "*.java"` || die "Cannot compile sources"
	else
		ejavac -sourcepath src -d build/classes `find src -name "*.java"` \
			|| die "Cannot compile sources"
	fi

	mkdir dist
	cd build/classes
	jar -cvf ${S}/dist/${PN}.jar org || die "Cannot create JAR"

	# generate javadoc
	if use doc ; then
		cd ${S}
		mkdir javadoc
		javadoc -d javadoc -sourcepath src -subpackages org
	fi
}

src_test() {
	ejavac -sourcepath test/org -cp build/classes:$(java-pkg_getjars junit-4) \
		-d build/classes `find test/org -name "*.java"`
	cd build/classes
	for FILE in `find -name "*Test\.class"`; do
		CLASS=`echo ${FILE} | sed -e "s/\.class//" | sed -e "s%/%.%g" | sed -e "s/\.\.//"`
		java -cp .:$(java-pkg_getjars --with-dependencies junit-4) \
		org.junit.runner.JUnitCore ${CLASS} || die "Test failed"
	done
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dojavadoc javadoc
	use source && java-pkg_dosrc src

	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp -r examples/* ${D}/usr/share/doc/${PF}/examples/ || die "Could not install examples"
	fi
}
