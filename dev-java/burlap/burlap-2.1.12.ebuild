# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="The Burlap web service protocol makes web services usable without requiring a large framework, and without learning yet another alphabet soup of protocols."
HOMEPAGE="http://www.caucho.com/burlap/"
SRC_URI="http://www.caucho.com/burlap/download/burlap-2.1.12-src.jar"

LICENSE="Apache-1.1"
SLOT="2.1"
KEYWORDS="~x86"

# TODO: some minor patching is needed for jikes
#IUSE="doc"
IUSE="doc jikes source"

DEPEND=">=virtual/jdk-1.4
		app-arch/unzip
		dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4
		=dev-java/servletapi-2.3*"

src_unpack() {
	mkdir -p ${P}/src
	unzip -qq -d ${S}/src ${DISTDIR}/${A}

	cd ${S}
	# No ant script! Bad upstream... bad!
	cp ${FILESDIR}/build-${PVR}.xml build.xml

	# Populate classpath
	echo classpath=$(java-pkg_getjar servletapi-2.3 servlet.jar) >> build.properties
}

src_compile() {
	local antflags="-Dproject.name=${PN} jar"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "Compilation failed"
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dohtml -r dist/doc/api
	use source && java-pkg_dosrc src/*
}
