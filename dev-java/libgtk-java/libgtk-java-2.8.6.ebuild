# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/libgtk-java/libgtk-java-2.8.3-r1.ebuild,v 1.1 2006/03/28 04:20:15 nichoj Exp $

inherit java-gnome

DESCRIPTION="Java bindings for GTK+"

SLOT="2.8"
KEYWORDS="~amd64 ~ppc ~x86"

DEPS=">=x11-libs/gtk+-2.8.3
		>=dev-java/glib-java-0.2.3
		>=dev-java/cairo-java-1.0.2
		>=dev-libs/glib-2.6.0
		>=x11-libs/cairo-1.0.0-r2"

DEPEND="${DEPS}"
RDEPEND="${DEPS}"

JAVA_GNOME_PC="gtk2-java.pc"
