# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="Virtual for JDK"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="1.5"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~ppc-aix ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="|| (
		>=dev-java/gcj-jdk-4.3
		>=dev-java/cacao-0.99.2
		=dev-java/sun-jdk-1.5.0*
		=dev-java/ibm-jdk-bin-1.5.0*
		=dev-java/jrockit-jdk-bin-1.5.0*
		=dev-java/diablo-jdk-1.5.0*
		=dev-java/apple-jdk-bin-1.5.0*
	)"
