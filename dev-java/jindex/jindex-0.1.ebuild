# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils

DESCRIPTION="Jar Index tool"
HOMEPAGE="http://www.gentoo.org/proj/en/java/"
SRC_URI="http://gentooexperimental.org/~unlord/${P}.tar.bz2"

LICENSE="GLP-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""
RESTRICT="mirror"

DEPEND="virtual/python
	>=dev-python/sqlobject-0.6"
RDEPEND="virtual/python"

pkg_setup() {
	if ! built_with_use dev-python/sqlobject sqlite ; then
		eerror "Your sqlobject has been built without sqlite support,"
		eerror "please enable the 'sqlite' useflag and recompile"
		eerror "dev-python/sqlobject."
		die "pkg_setup failed"
	fi
}

src_install() {
	distutils_src_install
}

pkg_postrm() {
	python_mod_cleanup /usr/share/jindex/pym
}

pkg_postinst() {
	python_mod_optimize /usr/share/jindex/pym
}
