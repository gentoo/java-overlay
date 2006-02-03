# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JWSDP_VERSION="2.0"
JWSDP_DESC="Shared components for JWSDP"

inherit java-wsdp

KEYWORDS="~x86"

DEPEND="dev-java/jta
	dev-java/xsdlib
	dev-java/relaxng-datatype
	dev-java/xml-commons-resolver"

REMOVE_JARS="xsdlib relaxngDatatype jta-spec1_0_1 resolver"
