# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Virtual for JDK"
HOMEPAGE="http://java.sun.com/"
SRC_URI=""

LICENSE="as-is"
SLOT="1.4"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE=""

DEPEND="|| (
		=dev-java/jamvm-1.4.2*
		=dev-java/kaffe-1.1*
		=dev-java/blackdown-jdk-1.4.2*
		=dev-java/sun-jdk-1.4.2*
		=dev-java/ibm-jdk-bin-1.4.2*
		=dev-java/jrockit-jdk-bin-1.4.2*
		=dev-java/apple-jdk-bin-1.4.2*
	)"
RDEPEND="${DEPEND}"
