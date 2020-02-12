# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

# jython depends on java-config, so don't add it or things will break
PYTHON_COMPAT=( python{2_6,2_7,3_1,3_2,3_3} pypy{1_8,1_9} )

inherit git-r3 distutils-r1 eutils

EGIT_REPO_URI="https://anongit.gentoo.org/git/proj/java-config.git"
EGIT_BRANCH="java-config-2.2"

DESCRIPTION="Java environment configuration tool"
HOMEPAGE="https://www.gentoo.org/proj/en/java/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="2"
KEYWORDS=""
IUSE=""

RDEPEND="
	sys-apps/baselayout-java
	sys-apps/portage"

python_test() {
	esetup.py test || die
}
