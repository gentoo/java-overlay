# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=1
JAVA_PKG_IUSE="doc source"
inherit java-pkg-2 java-ant-2

DESCRIPTION="Java classes for interaction with an Asterisk PBX Server with support for FastAGI and Manager API."
HOMEPAGE="http://asterisk-java.org/"
SRC_URI="http://dev.gentoo.org/~fordfrog/distfiles/${P}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="0.3"
KEYWORDS="~amd64 ~x86"
IUSE="test"

COMMON_DEPEND="dev-java/log4j"
RDEPEND=">=virtual/jre-1.5
	${COMMON_DEPEND}"
DEPEND=">=virtual/jdk-1.5
	dev-java/ant-core
	test? (
		>=dev-java/easymock-2:2
		>=dev-java/junit-4:4
	)
	${COMMON_DEPEND}"

src_compile() {
	# create jar
	mkdir -p build/classes
	ejavac -sourcepath src/main/java -d build/classes -cp $(java-pkg_getjars log4j) \
		`find src/main/java -name "*.java"` || die "Cannot compile sources"
	mkdir dist
	cd build/classes
	jar -cvf "${S}/dist/${PN}.jar" org || die "Cannot create JAR"

	# generate javadoc
	if use doc ; then
		cd "${S}"
		mkdir javadoc
		javadoc -d javadoc -sourcepath src/main/java -subpackages org
	fi
}

src_test() {
	ejavac -sourcepath src/test/java/org \
		-cp build/classes:$(java-pkg_getjars easymock-2,junit-4) \
		-d build/classes `find src/test/java/org -name "*.java"`
	cd build/classes
	cp "${S}"/src/test/resources/* .
	for FILE in `find -name "*Test\.class"`; do
		CLASS=`echo ${FILE} | sed -e "s/\.class//" | sed -e "s%/%.%g" | sed -e "s/\.\.//"`
		java -cp .:$(java-pkg_getjars easymock-2,junit-4) org.junit.runner.JUnitCore ${CLASS} || die "Test failed"
	done
}

src_install() {
	java-pkg_dojar dist/${PN}.jar
	use doc && java-pkg_dojavadoc javadoc
	use source && java-pkg_dosrc src/main/java
}
