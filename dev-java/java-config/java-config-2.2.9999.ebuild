# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/java-config/java-config-2.1.12-r1.ebuild,v 1.1 2012/12/05 19:05:48 sera Exp $

EAPI="5"

# jython depends on java-config, so don't add it or things will break
PYTHON_COMPAT=( python{2_6,2_7,3_1,3_2,3_3} pypy{1_8,1_9} )

inherit subversion distutils-r1 eutils

ESVN_REPO_URI="http://overlays.gentoo.org/svn/proj/java/projects/java-config-2/trunk/"

DESCRIPTION="Java environment configuration tool"
HOMEPAGE="http://www.gentoo.org/proj/en/java/"
#SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS=""
IUSE=""

RDEPEND="
	>=dev-java/java-config-wrapper-0.15
	sys-apps/portage"

python_test() {
	"${PYTHON}" tests/run-test-suite.py || die
}

python_install_all() {
	distutils-r1_python_install_all

	insinto /usr/share/java-config-2/config/
	newins config/jdk-defaults-${ARCH}.conf jdk-defaults.conf
}
