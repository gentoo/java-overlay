# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-projects/bsd/fbsd/overlay/dev-java/kaffe-sdk/kaffe-sdk-1.4.ebuild,v 1.1 2005/09/08 10:46:40 flameeyes Exp $

# TODO maybe kaffe-sdk should be recognized as a system vm, and make symlinks to
# whatever version of kaffe is actually being used

DESCRIPTION="A dummy ebuild to let Kaffe provide right virtuals"
HOMEPAGE=""
SRC_URI=""

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

PROVIDE="virtual/jdk
	virtual/jre"

RDEPEND="dev-java/kaffe"

