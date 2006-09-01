# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils

DESCRIPTION="Jar Index tool"
HOMEPAGE="http://www.gentoo.org/proj/en/java/"
SRC_URI="http://gentooexperimental.org/~unlord/jindex-0.1.tar.bz2"

LICENSE="GLP-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="virtual/python"
RDEPEND="virtual/python"

src_install() {
	distutils_src_install
}

pkg_postrm() {
	python_mod_cleanup /usr/share/jindex/pym
}

pkg_postinst() {
	python_mod_optimize /usr/share/jindex/pym
}
