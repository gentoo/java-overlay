# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JWSDP_VERSION="2.0"
JWSDP_DESC="Sun Java Streaming XML Parser"

inherit java-wsdp

KEYWORDS="~x86"

DEPEND="dev-java/sun-jaxp-bin
	dev-java/jsr173"

REMOVE_JARS="jsr173_api"
