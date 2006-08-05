# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/libgconf-java/libgconf-java-2.12.1-r1.ebuild,v 1.1 2006/03/28 04:17:17 nichoj Exp $

inherit java-gnome

DESCRIPTION="Java bindings for Glade"
SLOT="2.12"

LICENSE="LGPL-2.1"
KEYWORDS="~amd64 ~ppc ~x86"

DEPS=">=gnome-base/gconf-2.12.0
	  >=dev-java/glib-java-0.2.1
	  >=dev-java/libgtk-java-2.8.1
	  >=dev-java/libgnome-java-2.8.0"

DEPEND="${DEPS}"
RDEPEND="${DEPS}"
