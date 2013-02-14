# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/java-virtuals/stax-api/stax-api-1-r1.ebuild,v 1.1 2009/05/23 11:52:55 ali_bush Exp $

EAPI=1

inherit java-virtuals-2

DESCRIPTION="Virtual for Java API for XML Binding (JAXB)"
HOMEPAGE="http://www.gentoo.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="|| (
			>=virtual/jre-1.6
			dev-java/jaxme
			dev-java/jaxb
		)
		>=dev-java/java-config-2.1.8
		"

JAVA_VIRTUAL_PROVIDES="jaxb-2"
JAVA_VIRTUAL_VM=">=virtual/jre-1.6"
