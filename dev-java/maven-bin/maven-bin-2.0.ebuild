# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit bash-completion

MY_PN=${PN//-bin}
MY_PV="${PV/_/-}" 
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="Project Management and Comprehension Tool for Java"
SRC_URI="mirror://apache/${MY_PN}/binaries/${MY_P}-bin.tar.bz2"
HOMEPAGE="http://maven.apache.org/"
LICENSE="Apache-2.0"
SLOT="2.0"
KEYWORDS="~amd64"
DEPEND=">=virtual/jdk-1.3"
RDEPEND=">=virtual/jdk-1.3"
IUSE="bash-completion"

S="${WORKDIR}/${MY_P}"

# TODO make these names better... I know theyre bad
MAVEN=${PN}-${SLOT}
SHARE="/usr/share/${MAVEN}"
COMPLETION="${MAVEN}-bash-completion"

RESTRICT="nomirror" # only till it gets mirrored

src_unpack() {
	unpack ${A}

	rm ${S}/bin/*.bat
}
src_install() {
	exeinto /usr/bin
	doexe ${S}/bin/mvn

	doenvd ${FILESDIR}/25${MAVEN/-bin}

	dodir ${SHARE}
	cp -Rp bin conf core lib ${D}/${SHARE}

	dodoc NOTICE.txt README.txt

	cat > ${D}/usr/bin/mvn <<-END
#!/bin/bash
JAVA_HOME=\$(java-config --jdk-home) ${SHARE}/bin/mvn \$@
	END

	dobashcompletion  ${FILESDIR}/2.0/bash_completion maven
}
