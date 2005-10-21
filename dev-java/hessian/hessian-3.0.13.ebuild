# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="The Hessian binary web service protocol makes web services usable without requiring a large framework, and without learning yet another alphabet soup of protocols."
HOMEPAGE="http://www.caucho.com/hessian/"
SRC_URI="http://www.caucho.com/hessian/download/${P}-src.jar"

# Includes files from Resin that are under GPL
# see for example src/com/caucho/hessian/HessianContextFactory.java
LICENSE="Apache-1.1 GPL-2"
SLOT="3.0.13"
KEYWORDS="~x86"
IUSE="doc jikes source"

DEPEND=">=virtual/jdk-1.4
		app-arch/unzip
		jikes? ( dev-java/jikes )
		dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4
		=dev-java/servletapi-2.3*
		=dev-java/burlap-2.1*"

src_unpack() {
	mkdir -p ${P}/src
	unzip -qq -d ${S}/src ${DISTDIR}/${A}

	cd ${S}
	# No included ant script! Bad Java developer, bad!
	cp ${FILESDIR}/build-${PVR}.xml build.xml

	# Populate classpath
	echo "classpath=$(java-pkg_getjars servletapi-2.3)" >> build.properties
}

src_compile() {
	local antflags="-Dproject.name=${PN} -Dclasspath=$(java-pkg_getjars burlap-2.1) jar"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "Compilation failed"
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dohtml -r dist/doc/api
	use source && java-pkg_dosrc src/*
}
