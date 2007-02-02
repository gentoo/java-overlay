# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/cryptix/cryptix-3.2.0.ebuild,v 1.5 2005/07/15 17:31:24 axxo Exp $

JAVA_PKG_IUSE="source doc"
WANT_ANT_TASKS="ant-core"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Aims at facilitating the task programmers face in coding, accessing and generating java-bound, both types and values, defined as ASN.1 constructs, or encoded as such."
HOMEPAGE="http://cryptix-asn1.sourceforge.net/"
SRC_URI="mirror://gentoo/cryptix32-20001002-r3.2.0.zip"

LICENSE="CGL"
SLOT="3.2"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE=""

DEPEND=">=virtual/jdk-1.4
	app-arch/unzip"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}

src_unpack() {
	unpack "${A}"
	cd "${S}"

	cp "${FILESDIR}/build.xml" "."
}

src_install() {
	java-pkg_newjar lib/cryptix32.jar

	use doc && java-pkg_dojavadoc api/
	use source && java-pkg_dosrc src/*
}
