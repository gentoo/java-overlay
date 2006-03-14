# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="An action-based web framework for Java"
HOMEPAGE="http://opensymphony.com/webwork"
SRC_URI="https://webwork.dev.java.net/files/documents/693/28623/webwork-2.2.1.zip"

LICENSE=""
SLOT="2.2"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	>=virtual/jdk-1.4
	app-arch/unzip
	"
RDEPEND=">=virtual/jre-1.4"

S="${WORKDIR}"

ant_src_unpack() {
	unpack ${A}

	ewarn "QA notice: using bundled jars!"
}

src_compile() {
	# TODO generate javadocs
	eant clean jar -Dskip.ivy=true
}

src_install() {
	java-pkg_newjar ${P}.jar ${PN}.jar

	# TODO install javadocs, misc docs
}
