# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="XML databases and data manipulation technologie"

HOMEPAGE="http://www.smb-tec.com/xmldb/"
SRC_URI="mirror://sourceforge/xmldb-org/xmldb-api-11112001.tar.gz"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86"
IUSE=""
DEPEND=">=virtual/jdk-1.3
	sys-apps/sed
	>=dev-java/xerces-2.6.2-r1"
RDEPEND=">=virtual/jre-1.3"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd ${S}
	rm -f *.jar
	sed 's:;;:;:' -i org/xmldb/api/reference/modules/XPathQueryServiceImpl.java \
		|| die "sed failed"
}

src_compile() {
	find -name "*.java"  ! -path */api/tests/* | xargs javac -target 1.2 -source 1.2 \
		-classpath .:$(java-config -p xerces-2) || die "failed to compile"
	find -name "*.class" | xargs jar cf ${PN}.jar || die "failed to pack"
}

src_install() {
	java-pkg_dojar ${PN}.jar
}
