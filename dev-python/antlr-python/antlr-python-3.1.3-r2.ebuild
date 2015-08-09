# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1

MY_P="antlr-${PV}"
DESCRIPTION="The python runtime for antlr:3"
HOMEPAGE="http://www.antlr.org/"
SRC_URI="http://www.antlr.org/download/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}/${MY_P}/runtime/Python"
