# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-lang/commons-lang-2.1.ebuild,v 1.1 2005/10/01 08:24:41 axxo Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Jakarta components: small set of classes designed to make working with JDBC easier"
HOMEPAGE="http://jakarta.apache.org/commons/dbutils/"
SRC_URI="mirror://apache/jakarta/commons/dbutils/source/${P}-src.tar.gz"
DEPEND=">=virtual/jdk-1.3
	>=dev-java/ant-core-1.6
	dev-java/junit"
RDEPEND=">=virtual/jre-1.3"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="doc source"

src_compile() {

	use doc && antflags="${antflags} javadoc"
	eant -Dnoget=only jar ${antflags} || die "compilation failed"

}

src_install() {

	java-pkg_newjar target/${PN}-1.1-dev.jar ${PN}.jar

	use doc && java-pkg_dohtml -r dist/docs/
	use source && java-pkg_dosrc src/java/*

}
