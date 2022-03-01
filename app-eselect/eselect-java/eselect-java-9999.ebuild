# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools git-r3

EGIT_REPO_URI="https://anongit.gentoo.org/git/proj/eselect-java.git"

DESCRIPTION="A set of eselect modules for Java"
HOMEPAGE="https://wiki.gentoo.org/wiki/Project:Java"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="app-admin/eselect"

src_prepare() {
	default
	eautoreconf
}
