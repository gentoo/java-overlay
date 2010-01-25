# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Virtual for JDK"
HOMEPAGE="http://java.sun.com/"
SRC_URI=""

LICENSE="as-is"
SLOT="1.5"
KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~x86 ~ppc-aix ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="|| (
		=virtual/gnu-classpath-jdk-1.5
		=dev-java/sun-jdk-1.5.0*
		=dev-java/ibm-jdk-bin-1.5.0*
		=dev-java/jrockit-jdk-bin-1.5.0*
		=dev-java/diablo-jdk-1.5.0*
		=dev-java/apple-jdk-bin-1.5.0*
	)"
DEPEND=""
