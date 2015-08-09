# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="2"

JAVA_PKG_IUSE="source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="A port of Kai Toedter's  JCalendar to Eclipse's SWT."
HOMEPAGE="http://swtcalendar.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}/${PN}-src-${PV}.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""

COMMON_DEP="dev-java/swt:3.5"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	${COMMON_DEP}"

S="${WORKDIR}/${PN}"

src_prepare() {
	mkdir -p lib || die
	java-pkg_jar-from --into lib swt-3.5 swt.jar
}

src_install() {
	java-pkg_dojar "${PN}.jar"
	use source && java-pkg_dosrc src
}

