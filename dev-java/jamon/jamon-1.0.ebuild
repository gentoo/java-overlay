# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg
MY_PN="JAMon"
MY_PV="121003"
DESCRIPTION="Java Application Monitor (JAMon) is a free, simple, high performance, thread safe, Java API that allows developers to easily monitor production applications. JAMon can be used to determine application performance bottlenecks, user/application interactions, and application scalability"
HOMEPAGE="http://www.javaperformancetuning.com/tools/jamon/index.shtml"
SRC_URI="mirror://sourceforge/jamonapi/${MY_PN}All_${MY_PV}.zip"

LICENSE="BSD"
SLOT="1"
KEYWORDS="~x86"
IUSE="doc jikes"

DEPEND="virtual/jdk
	dev-java/ant
	app-arch/unzip
	jikes? (dev-java/jikes)"	
RDEPEND="virtual/jre"

src_unpack() {
	# The structure of the archive is really messy, so we have to clean it up a
	# bit ourselves

	mkdir ${S}
	cd ${S}
	unpack ${A}
	mv Code src

	# No provided ant script! Bad Java developer, bad!
	cp ${FILESDIR}/build-${PVR}.xml build.xml

	mv JAMonUsersGuide guide
	rm -r guide/javadoc guide/*.zip
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
}
