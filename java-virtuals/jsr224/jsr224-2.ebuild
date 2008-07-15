# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/java-virtuals/saaj-api/saaj-api-1.3.ebuild,v 1.3 2008/05/04 11:52:50 opfer Exp $

EAPI=1

inherit java-virtuals-2

DESCRIPTION="Virtual for the Java API for XML Web Services (JAX-WS, JSR 224)"
HOMEPAGE="http://www.gentoo.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86 ~x86-fbsd"
IUSE=""

DEPEND=""
RDEPEND="|| (
			=virtual/jdk-1.6*
			dev-java/jax-ws-api:2
		)
		>=dev-java/java-config-2.1.6
		"

JAVA_VIRTUAL_PROVIDES="jax-ws-api:2"
JAVA_VIRTUAL_VM="sun-jdk-1.6 ibm-jdk-bin-1.6"
