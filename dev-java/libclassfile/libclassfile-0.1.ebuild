# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/poslib/poslib-1.0.6.ebuild,v 1.3 2006/02/20 07:30:26 halcy0n Exp $

inherit base

DESCRIPTION=""
HOMEPAGE=""
SRC_URI="http://gentooexperimental.org/~unlord/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE="" # need to make this USE=python
RESTRICT="mirror"

DEPEND="dev-lang/swig"

pkg_setup() {
	if ! built_with_use dev-lang/swig python ; then
		eerror "Your swig has been built without python support,"
		eerror "please enable the 'python' useflag and recompile"
		eerror "dev-lang/swig."
		die "pkg_setup failed"
	fi
}

#src_compile() {
#	econf $(use_enable python) || die "econf failed"
#	emake || die "emake failed"
#}
