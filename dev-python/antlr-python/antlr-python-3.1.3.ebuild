# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/antlr/antlr-3.1.3.ebuild,v 1.2 2009/03/29 16:48:01 betelgeuse Exp $

inherit distutils

DESCRIPTION="The python runtime for antlr:3"
HOMEPAGE="http://www.antlr.org/"
MY_P="antlr-${PV}"
SRC_URI="http://www.antlr.org/download/${MY_P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

RDEPEND=""
DEPEND=""

S="${WORKDIR}/${MY_P}/runtime/Python"
