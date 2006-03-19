# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils

MY_P="${P}-src"
DESCRIPTION="A clean room implementation of the Java Message Service specification"
HOMEPAGE="http://ubermq.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.zip"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~x86"
IUSE="doc jikes"

LDEPEND="dev-java/concurrent-util
		dev-java/jgroups
		dev-java/junit
		dev-java/log4j
		=dev-java/webcanal-bin-2*"
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	jikes? ( dev-java/jikes )
	${LDEPEND}"
RDEPEND=">=virtual/jre-1.4
	${LDEPEND}"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-lrmp.patch

	cd ${S}/lib
	rm *.jar

	java-pkg_jar-from concurrent-util
	java-pkg_jar-from jgroups jgroups-core.jar
	java-pkg_jar-from junit
	java-pkg_jar-from log4j
	java-pkg_jar-from webcanal-bin-2
}

src_compile() {
	local antflags="dist"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "Compilation failed"
}

src_install() {
	java-pkg_dojar dist/*.jar
	
	use doc && java-pkg_dohtml -r doc/javadoc
	dodoc README
}
