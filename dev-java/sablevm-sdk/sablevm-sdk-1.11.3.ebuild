# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java

DESCRIPTION="A free java sdk using SableVM and various tools."
HOMEPAGE="http://sablevm.org/"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"

#
# Note: gjdoc and its dependency antlr depend on virtual/jdk so there is
#       a minor bootstrap issue to get around if no virtual/jdk has been
#       installed on the system.
#
#       This can be done by emerging sablevm-sdk twice as follows:
#       USE=nogjdoc emerge -av sablevm-sdk
#       emerge -av sablevm-sdk
#
IUSE="nogjdoc"

# what is virtual/java-scheme-2?
PROVIDE="virtual/jdk-1.4
	virtual/jre-1.4"
 
DEPEND="~dev-java/sablevm-${PV}
	dev-java/java-config
	dev-java/fastjar
	dev-java/cp-tools
	!nogjdoc? ( dev-java/gjdoc )"

#RDEPEND=""

S=${WORKDIR}

src_install() {
	# bin symlinks
	dodir /usr/lib/sablevm/bin
	dosym /usr/bin/fastjar /usr/lib/sablevm/bin/jar
	use nogjdoc || dosym /usr/bin/gjdoc /usr/lib/sablevm/bin/javadoc

	# cp-tools
	CPTOOLS="currencygen javah javap localegen native2ascii \
	  rmic rmiregistry serialver"
	for f in ${CPTOOLS} ; do
	  dosym /usr/bin/$f /usr/lib/sablevm/bin/$f
	done

	# man symlinks

	dodir /usr/lib/sablevm/man/man1

	dosym /usr/share/man/man1/java-sablevm.1.gz \
	  /usr/lib/sablevm/man/man1/java.1.gz

	dosym /usr/share/man/man1/jikes.1.gz \
	  /usr/lib/sablevm/man/man1/javac.1.gz

	dosym /usr/share/man/man1/fastjar.1.gz \
	  /usr/lib/sablevm/man/man1/jar.1.gz

	use nogjdoc ||
	  dosym /usr/share/man/man1/gjdoc.1.gz \
	    /usr/lib/sablevm/man/man1/javadoc.1.gz

	set_java_env ${FILESDIR}/${VMHANDLE}
}
