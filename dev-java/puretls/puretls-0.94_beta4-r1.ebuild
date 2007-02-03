# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/puretls/puretls-0.94_beta4.ebuild,v 1.9 2005/10/30 19:52:49 axxo Exp $

JAVA_PKG_IUSE="source doc"
WANT_ANT_TASKS="ant-core"

inherit java-pkg-2 java-ant-2

DESCRIPTION="PureTLS is a free Java-only implementation of the SSLv3 and TLSv1 (RFC2246) protocols"
HOMEPAGE="http://www.rtfm.com/puretls/"
SRC_URI="mirror://gentoo/puretls-0.9b4.tar.gz"
LICENSE="puretls"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE=""
RDEPEND=">=virtual/jre-1.4
	=dev-java/cryptix-asn1-bin-20011119
	=dev-java/cryptix-3.2.0*"
DEPEND=">=virtual/jdk-1.4
	${RDEPEND}
	>=dev-java/ant-core-1.7"

S="${WORKDIR}/${PN}-0.9b4"

src_unpack() {
	unpack ${A}
	cd ${S}

	java-pkg_jar-from cryptix-asn1-bin
	java-pkg_jar-from cryptix-3.2
	echo "jdk.version=1.4" >> build.properties
	echo "cryptix.jar=cryptix.jar" >> build.properties
	echo "cryptix-asn1.jar=cryptix-asn1.jar" >> build.properties
}

EANT_BUILD_TARGET="compile"

src_install() {
	java-pkg_dojar "${S}/build/${PN}.jar"

	dodoc ChangeLog CREDITS README
	use doc && java-pkg_dojavadoc "${S}/build/doc/api"
	use source && java-pkg_dosrc src/COM
}
