# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Virtual for Classpath-based JDKs that match the given version of the Java SE platform specification"
HOMEPAGE="http://www.gnu.org/software/classpath/"
SRC_URI=""

LICENSE="GPL-2-with-linking-exception"
SLOT="1.5"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

RDEPEND="|| (
		>=dev-java/gcj-jdk-4.3
		=dev-java/jamvm-1.5*
		>=dev-java/cacao-0.99.2
	)"
DEPEND=""
