# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JWSDP_VERSION="2.0"
JWSDP_DESC="Java API for XML Processing"

inherit java-wsdp

KEYWORDS="~x86"
IUSE="${IUSE} dom4j"

DEPEND="${DEPEND}
	dev-java/sun-jwsdp-shared-bin
	dom4j? ( dev-java/dom4j )"
