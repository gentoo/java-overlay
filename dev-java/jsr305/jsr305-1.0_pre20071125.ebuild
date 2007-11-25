# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# WARNING: JUNIT.JAR IS _NOT_ SYMLINKED TO ANT-CORE LIB FOLDER AS JUNIT3 IS

JAVA_PKG_IUSE="doc source"
inherit java-pkg-2 java-ant-2

MY_P=${P/-/}
DESCRIPTION="JSR 305: Annotations for Software Defect Detection in Java"
SRC_URI="http://dev.gentoo.org/~fordfrog/distfiles/${P}.tar.bz2"
HOMEPAGE="http://code.google.com/p/jsr-305/"
LICENSE="BSD-2"
KEYWORDS="~x86"
IUSE="examples"
SLOT="0"

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5"

S=${WORKDIR}/${PN}

src_compile() {
	# create jar
	cd ri
	mkdir -p build/classes
	ejavac -sourcepath src/main/java -d build/classes $(find src/main/java -name "*.java") \
		|| die "Cannot compile sources"
	mkdir dist
	cd build/classes
	jar -cvf "${S}"/ri/dist/${PN}.jar javax || die "Cannot create JAR"

	# generate javadoc
	if use doc ; then
		cd "${S}"/ri
		mkdir javadoc
		javadoc -d javadoc -sourcepath src/main/java -subpackages javax \
			|| die "Javadoc creation failed"
	fi
}

src_install() {
	cd ri
	java-pkg_dojar dist/${PN}.jar

	if use examples; then
		dodir /usr/share/doc/${PF}/examples/
		cp -r "${S}"/sampleUses/* "${D}"/usr/share/doc/${PF}/examples/ || die "Could not install examples"
	fi

	if use source ; then
		cd "${S}"/ri/src/main/java
		java-pkg_dosrc javax
	fi

	if use doc ; then
		cd "${S}"/ri
		java-pkg_dojavadoc javadoc
	fi
}
