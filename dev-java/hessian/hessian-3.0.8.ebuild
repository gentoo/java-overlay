# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="The Hessian binary web service protocol makes web services usable without requiring a large framework, and without learning yet another alphabet soup of protocols."
HOMEPAGE="http://www.caucho.com/hessian/"
SRC_URI="http://www.caucho.com/hessian/download/${P}-src.jar"

# Supposedly something Apache
LICENSE=""
SLOT="3.0.8"
KEYWORDS="~x86"
IUSE="jikes doc"

DEPEND="virtual/jdk
	app-arch/unzip
	jikes? (dev-java/jikes)
	dev-java/ant"	
RDEPEND="virtual/jre
	=dev-java/servletapi-2.3*"

SERVLET="servletapi-2.3 servlet.jar"

src_unpack() {
	mkdir -p ${P}/src
	unzip -qq -d ${S}/src ${DISTDIR}/${A}

	# We need to move things around a bit
#	mkdir -p ${S}/src
#	mv com ${S}/src

	cd ${S}
	# No included ant script! Bad Java developer, bad!
	cp ${FILESDIR}/build-${PVR}.xml build.xml

	# Populate classpath
	cat > build.properties <<-EOF 
		classpath=$(java-pkg_getjars servletapi-2.3)
	EOF
}

src_compile() {
	local antflags="-Dproject.name=${PN} jar"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "Compilation failed"
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dohtml -r dist/doc/api
}
