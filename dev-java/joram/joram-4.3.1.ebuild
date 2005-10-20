# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION=""
HOMEPAGE=""
SRC_URI="http://download.us.forge.objectweb.org/${PN}/${P}-src.tgz"

LICENSE=""
SLOT="0"
KEYWORDS="~x86"
IUSE=""

LDEPEND="dev-java/gnu-activation
	dev-java/jakarta-regexp"
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4"

src_unpack() {
	:;
}
