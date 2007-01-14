# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit versionator netbeans-5.5-pack

DESCRIPTION="NetBeans C/C++ Development Pack"
HOMEPAGE="http://www.netbeans.org/products/cplusplus/"
SRC_URI="http://us1.mirror.netbeans.org/download/${MY_PV}/cpp/fcs/061123/${BIN_FILE}"

LICENSE="CDDL"
KEYWORDS="~x86"

CLUSTER="cnd1"
PRODUCTID="NB_CND"
UNPACK_DIR="cnd1"
