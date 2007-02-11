# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-tasks/ant-tasks-1.6.5-r2.ebuild,v 1.2 2006/07/22 23:09:33 flameeyes Exp $

ANT_TASK_JDKVER=1.5
ANT_TASK_JREVER=1.5
ANT_TASK_DEPNAME="junit-4"

inherit ant-tasks

KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

DEPEND="=dev-java/junit-4*"
RDEPEND="${DEPEND}"

src_compile() {
	eant jar-junit
}

src_install() {
	java-pkg_newjar build/lib/ant-junit.jar
}
