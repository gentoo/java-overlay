# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg

DESCRIPTION="an open source RDF database with support for RDF Schema inferencing and querying"
HOMEPAGE="http://openrdf.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc junit source"

RDEPEND=">=virtual/jre-1.4
		>=www-servers/tomcat-4.0.4"
DEPEND=">=virtual/jdk-1.4
		dev-java/commons-fileupload
		dev-java/saxon
		dev-java/servletapi
		dev-java/soap
		>=www-servers/tomcat-4.0.4
		"

src_unpack() {
	unpack ${A}

	cd ${S}/ext
	rm -f *.jar
}

src_compile() {
	local antflags="build"
	use doc && antflags="${antflags} javadoc userdoc"
	antflags="${antflags} -lib $(java-config --classpath=servletapi-2.4,soap,commons-fileupload)"
	ant ${antflags} || die "Failed to run ant"
}

src_install() {
	java-pkg_dowar build/lib/*.war
	java-pkg_dojar build/lib/*.jar

	dodoc README CHANGELOG

	use doc && java-pkg_dohtml -r doc
	use source && java-pkg_dosrc -r src/*
}

pkg_postinst() {
	einfo "This ebuild does not install the Sesame webapp into any servlet"
	einfo "container. You got 2 choices:"
	einfo "- copy /usr/share/${PN}/webapps/${PN}.war to your servlet"
	einfo "  container's webapps directory"
	einfo "- unpack the war file to that directory with"
	einfo "  jar -xf /usr/share/${PN}/webapps/${PN}.war."
	einfo
	einfo "In case you are planning to use a database with Sesame, copy"
	einfo "the appropriate JDBC-driver file(s) to"
	einfo "[TOMCATROOT]/${PN}/WEB-INF/lib/"
	einfo
	einfo "Copy [TOMCATROOT]/${PN}/WEB-INF/lib/system.conf.example to"
	einfo "[TOMCATROOT]/${PN}/WEB-INF/lib/system.conf"
	einfo
	einfo "Restart the tomcat server and point you browser to"
	einfo "http://localhost:8080/sesame"
	einfo
	einfo "For further instructions go to http://openrdf.org/doc/users/index.html"
	einfo
}
