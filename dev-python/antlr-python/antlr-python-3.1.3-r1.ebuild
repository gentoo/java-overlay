# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/antlr/antlr-3.1.3.ebuild,v 1.2 2009/03/29 16:48:01 betelgeuse Exp $

EAPI=4

PYTHON_DEPEND="2:2.6"

inherit python distutils

MY_P="antlr-${PV}"
DESCRIPTION="The python runtime for antlr:3"
HOMEPAGE="http://www.antlr.org/"
SRC_URI="http://www.antlr.org/download/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}/${MY_P}/runtime/Python"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}
