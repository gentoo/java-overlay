# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-lang/commons-lang-2.0-r1.ebuild,v 1.7 2004/06/24 22:22:30 agriffis Exp $

inherit java-pkg eutils

DESCRIPTION="Jakarta components to manipulate core java classes"
HOMEPAGE="http://jakarta.apache.org/commons/lang.html"
SRC_URI="http://cvs.apache.org/builds/jakarta-commons/nightly/commons-jexl/commons-jexl-src-20040729.zip"
DEPEND=">=virtual/jdk-1.3
	>=dev-java/ant-1.4
	dev-java/commons-logging
	jikes? ( dev-java/jikes )
	junit? ( >=dev-java/junit-3.7 )"
RDEPEND=">=virtual/jre-1.3"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc jikes junit"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/build.xml.patch
}

src_compile() {
	local antflags="jar"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} javadoc"
	use junit && antflags="${antflags} test"
	mkdir -p target/lib
	ant ${antflags} || die "compilation failed"
}

src_install() {
	mv target/commons-jexl-1.0-beta-1.jar target/${PN}.jar
	java-pkg_dojar target/*.jar
	dodoc LICENSE.txt NOTICE.txt
	use doc && dohtml -r dist/docs/
}
