# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jcalendar/jcalendar-1.2.2-r1.ebuild,v 1.1 2006/08/04 04:56:48 nichoj Exp $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Java date chooser bean for graphically picking a date."
SRC_URI="http://www.toedter.com/download/${PN}.zip"
HOMEPAGE="http://www.toedter.com/en/jcalendar/"
LICENSE="LGPL-2.1"
SLOT="1.2"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE="doc source"
RDEPEND=">=virtual/jdk-1.4
	=dev-java/jgoodies-looks-1.2*"
DEPEND=">=virtual/jdk-1.4
	${RDEPEND}
	>=dev-java/ant-core-1.4
	>=app-arch/unzip-5.50-r1"

S=${WORKDIR}

src_unpack() {
	unpack ${A}

	cd ${S}/lib
	rm -f *.jar
	java-pkg_jar-from jgoodies-looks-1.2 looks.jar looks-1.2.2.jar
}

src_compile() {
	cd ${S}/src
	eant jar $(use_doc javadocs)
}

src_install() {
	java-pkg_dojar lib/jcalendar.jar

	dodoc readme.txt
	use doc && java-pkg_dohtml -r doc/*
	use source && java-pkg_dosrc src/com
}
