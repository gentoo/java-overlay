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
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE="examples test"

CDEPEND="dev-java/hamcrest"
RDEPEND=">=virtual/jre-1.5
	${CDEPEND}"
DEPEND=">=virtual/jdk-1.5
	userland_GNU? ( >=sys-apps/findutils-4.3 )
	app-arch/unzip
	${CDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	mkdir src
	cd src
	unzip ../${P}-src.jar || die "Could not extract sources"
	cd "${S}"

	# Their own unit tests do not even work in unix!
	# - reported to upstream
	#sed -i 's/";"/File.pathSeparator/' org/junit/tests/JUnitCoreTest.java || die

	# remove jars
	cd ${S}
	find -name "*.jar" | xargs rm -v

	# remove compiled classes
	find . -name "*.class" -print -delete \
		|| die "Failed to remove bundled classes"

	# remove javadoc dir
	rm -fr javadoc
}

src_compile() {
	# create jar
	mkdir -p build/classes
	ejavac -sourcepath src -d build/classes -classpath $(java-pkg_getjars hamcrest) \
		$(find src -name "*.java") || die "Cannot compile sources"
	mkdir dist
	cd build/classes
	jar -cvf ${S}/dist/${PN}.jar junit org || die "Cannot create JAR"

	# generate javadoc
	if use doc ; then
		cd ${S}
		mkdir javadoc
		javadoc -d javadoc -sourcepath src -subpackages junit:org \
			-classpath $(java-pkg_getjars hamcrest) || die "Javadoc creation failed"
	fi
}

src_test() {
	ejavac -sourcepath org:junit -classpath $(java-pkg_getjars hamcrest):build/classes \
		-d build/classes $(find org junit -name "*.java")
	cd build/classes
	for FILE in $(find . -name "AllTests\.class"); do
		echo $FILE
		if [[ ${FILE} != "./org/junit/runners/AllTests.class" ]] ; then
			CLASS=`echo ${FILE} | sed -e "s/\.class//" | sed -e "s%/%.%g" | sed -e "s/\.\.//"`
			java -classpath .:$(java-pkg_getjars hamcrest) \
			org.junit.runner.JUnitCore ${CLASS} || die "Test failed"
		fi
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
