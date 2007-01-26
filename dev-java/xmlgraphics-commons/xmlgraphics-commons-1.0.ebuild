# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-utils-2

DESCRIPTION=""
HOMEPAGE="http://xmlgraphics.apache.org/commons/index.html"
SRC_URI="mirror://apache/xmlgraphics/commons/source/${P}-src.tar.gz"

LICENSE="Apache-2"
SLOT="1"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=virtual/jdk-1.4
		>=dev-java/commons-io-1"
RDEPEND=">=virtual/jre-1.4"


src_compile() {
	
}
