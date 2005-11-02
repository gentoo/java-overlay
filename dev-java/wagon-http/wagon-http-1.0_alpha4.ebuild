# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg wagon

DESCRIPTION=""
# svn co http://svn.apache.org/repos/asf/maven/wagon/tags/wagon-1.0-alpha-4/wagon-providers/wagon-http/ wagon-http-1.0-alpha-4

SLOT="1"
KEYWORDS="~x86 ~amd64"
IUSE="doc jikes"

RDEPEND="=dev-java/wagon-provider-api-1*
	dev-java/commons-logging
	dev-java/commons-lang
	=dev-java/commons-httpclient-2*"

src_unpack() {
	wagon_src_unpack
	mkdir -p ${S}/lib
	cd ${S}/lib
	java-pkg_jar-from wagon-provider-api-1
	java-pkg_jar-from commons-logging
	java-pkg_jar-from commons-lang
	java-pkg_jar-from commons-httpclient
}
