# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-gnome

DESCRIPTION="Java bindings for EDS"

SLOT="0"
# Doesn't work yet. some missing files
KEYWORDS="-*"
#KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPS=">=gnome-extra/evolution-data-server-1.2
		>=dev-libs/glib-2.6.0"

DEPEND="${DEPS}"
RDEPEND="${DEPS}"

