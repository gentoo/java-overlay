# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

JAVA_PKG_IUSE="doc examples source test"
inherit java-pkg-2 java-ant-2

MY_P="${PN}${PV}"
DESCRIPTION="EasyMock generates Mock Objects for interfaces in JUnit tests on the fly"
HOMEPAGE="http://www.easymock.org/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.zip"

LICENSE="MIT"
SLOT="2"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	app-arch/unzip
	>=virtual/jdk-1.5
	test? ( >=dev-java/junit-4 )
"
RDEPEND=">=virtual/jre-1.5"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	rm -rf javadoc ${PN}.jar || die
	unzip -qq -d src/ src.zip
	use test && unzip -qq -d test/ tests.zip
	use examples && unzip -qq -d examples/ samples.zip
	find . -name '*.class' -delete || die
}

src_compile() {
	mkdir classes || die

	ejavac -d classes $(find src -name "*.java")

	jar -cf ${PN}.jar -C classes . || die "jar failed"

	if use doc ; then
		mkdir javadoc || die
		javadoc -d javadoc -sourcepath src -subpackages org || die
	fi
}

src_test() {
	ejavac -cp ${PN}.jar:$(java-pkg_getjars junit-4) -d classes \
		$(find test/org -name "*.java")
	cd classes
	for FILE in $(find -name "*Test\.class"); do
		local CLASS=$(echo ${FILE} | sed -e "s/\.class//" | sed -e "s%/%.%g" | sed -e "s/\.\.//")
		java -cp .:$(java-pkg_getjars --with-dependencies junit-4) \
			org.junit.runner.JUnitCore ${CLASS} || die "Test ${CLASS} failed"
	done
}

src_install() {
	java-pkg_dojar ${PN}.jar
	dohtml *.html *.css || die

	use doc && java-pkg_dojavadoc javadoc
	use source && java-pkg_dosrc src/org
	use examples && java-pkg_doexamples examples
}
