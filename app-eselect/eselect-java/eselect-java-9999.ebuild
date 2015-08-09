# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit autotools subversion

ESVN_REPO_URI="http://overlays.gentoo.org/svn/proj/java/projects/${PN}/trunk/"

DESCRIPTION="A set of eselect modules for Java"
HOMEPAGE="http://www.gentoo.org/proj/en/java/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="
	!!app-eselect/eselect-ecj
	!!app-eselect/eselect-maven
	!!<dev-java/java-config-2.2
	app-admin/eselect"

src_prepare() {
	eautoreconf
}
