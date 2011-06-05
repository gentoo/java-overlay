# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"

EAPI="1"
inherit java-pkg-2 java-pkg-simple

DESCRIPTION="Experimental extended Stax API, used by Woodstox"
HOMEPAGE="http://woodstox.codehaus.org/"
SRC_URI="http://woodstox.codehaus.org/${PV}/${PN}-src-${PV}.tar.gz"

LICENSE="Apache-2.0 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="java-virtuals/stax-api:0
	>=virtual/jre-1.4"

DEPEND="java-virtuals/stax-api:0
	>=virtual/jdk-1.4"

JAVA_SRC_DIR="stax2-${PV}/src/java"
JAVA_GENTOO_CLASSPATH="stax-api"
