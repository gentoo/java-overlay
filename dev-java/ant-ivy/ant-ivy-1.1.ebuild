# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils

MY_PN=${PN##*-}
MY_P=${MY_PN}-${PV}

DESCRIPTION="Ivy is a free java based dependency manager, with powerful features such as transitive dependencies, ant integration, maven repository compatibility, continuous integration, html reports and many more."
HOMEPAGE="http://jayasoft.org/ivy"
SRC_URI="http://jayasoft.org/visit.php?url=./downloads/${MY_PN}/${MY_P}-src.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc jikes"

LDEPEND="=dev-java/commons-cli-1*
	=dev-java/commons-httpclient-2*
	dev-java/commons-logging"
# TODO test earlier vm?
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	app-arch/unzip
	jikes? (dev-java/jikes)
	${LDEPEND}"
RDEPEND=">=virtual/jre-1.4
	${LDEPEND}"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}

	cd ${S}
	# disable resolve task, which downloads jars
	epatch ${FILESDIR}/${MY_P}-noresolve.patch
	# add clean and javadoc targets (submitted upstream)
	epatch ${FILESDIR}/${MY_P}-tasks.patch
	
	mkdir ${S}/lib
	cd ${S}/lib
	java-pkg_jar-from commons-cli-1,commons-httpclient,commons-logging
}

src_compile() {
	local antflags="jar"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "Ant failed"
}

src_install() {
	java-pkg_dojar build/artifact/${MY_PN}.jar
	dodir /usr/share/ant-core/lib
	dosym /usr/share/${PN}/lib/${MY_PN}.jar /usr/share/ant-core/lib/${PN}.jar
	use doc && java-pkg_dohtml -r build/doc/api
}

src_test() {
	ant test || die "Junit tests failed"
}
