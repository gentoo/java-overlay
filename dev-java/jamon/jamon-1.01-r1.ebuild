# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 eutils
MY_PN="JAMon"
MY_PV="103005"
DESCRIPTION="Java Application Monitor (JAMon) is a free, simple, high performance, thread safe, Java API that allows developers to easily monitor production applications. JAMon can be used to determine application performance bottlenecks, user/application interactions, and application scalability"
HOMEPAGE="http://www.javaperformancetuning.com/tools/jamon/index.shtml"
SRC_URI="mirror://sourceforge/jamonapi/${MY_PN}All_${MY_PV}.zip"

LICENSE="BSD"
SLOT="1"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	app-arch/unzip"
RDEPEND=">=virtual/jre-1.4
	~dev-java/servletapi-2.3"

src_unpack() {
	# The structure of the archive is really messy, so we have to clean it up a
	# bit ourselves

	mkdir ${S}
	cd ${S}
	unpack ${A}
	rm ${MY_PN}.{j,w}ar
	epatch ${FILESDIR}/${P}-java1.5.patch

	mv Code src

	# No provided ant script! Bad upstream, bad!
	cp ${FILESDIR}/build-1.0.xml build.xml
}

src_compile() {
	local antflags="-Dproject.name=${PN} jar"
	antflags="${antflags} $(use_doc)"

	antflags="${antflags} -Dclasspath=$(java-pkg_getjars servletapi-2.3)"
	eant ${antflags} || die "Compilation failed"
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dohtml -r dist/doc/api
}
