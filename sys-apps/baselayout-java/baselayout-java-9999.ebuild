# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools subversion

ESVN_REPO_URI="http://overlays.gentoo.org/svn/proj/java/projects/${PN}/trunk/"

DESCRIPTION="Baselayout for Java"
HOMEPAGE="http://www.gentoo.org/proj/en/java/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="!!<dev-java/java-config-2.2"

src_prepare() {
	eautoreconf
}
