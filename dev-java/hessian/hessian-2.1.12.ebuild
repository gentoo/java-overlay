# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="The Hessian binary web service protocol makes web services usable without requiring a large framework, and without learning yet another alphabet soup of protocols."
HOMEPAGE="http://www.caucho.com/hessian/"
SRC_URI="http://www.caucho.com/hessian/download/${P}-src.jar"

# Supposedly Apache, but not sure which version
LICENSE=""
SLOT="2.1"
KEYWORDS="~x86"
IUSE="jikes doc"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4
	=dev-java/servletapi-2.3*"

src_unpack() {
	jar xvf ${DISTDIR}/${A}

	# We need to move things around a bit
	mkdir -p ${S}/src
	mv com ${S}/src

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
