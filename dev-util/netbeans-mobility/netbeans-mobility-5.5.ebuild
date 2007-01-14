# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit versionator netbeans-5.5-pack

DESCRIPTION="NetBeans Mobility Pack for CLDC/MIDP"
HOMEPAGE="http://www.netbeans.org/products/mobility/"
SRC_URI="http://us1.mirror.netbeans.org/download/${MY_PV}/mlfcs/200612070100/${BIN_FILE}"

# TODO: find the license
LICENSE=""
KEYWORDS="~x86"

CLUSTER="mobility7.3"
PRODUCTID="NB_MOB"

#TODO: replace bundled jars with system jars
