# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit versionator netbeans-5.5-pack

DESCRIPTION="NetBeans Profiler"
HOMEPAGE="http://www.netbeans.org/products/profiler/"
BIN_FILE="netbeans-profiler-${MY_PV}-linux.bin"
SRC_URI="http://us1.mirror.netbeans.org/download/${MY_PV}/fcs/200610171010/${BIN_FILE}"

LICENSE="SPL"
KEYWORDS="~x86"

CLUSTER="profiler1"
PRODUCTID="NB_PROF"
