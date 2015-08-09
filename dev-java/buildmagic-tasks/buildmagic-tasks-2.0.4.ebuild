# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="JBoss buildmagic tasks module"
HOMEPAGE="http://www.jboss.org"
BASE_URL="http://www.elvanor.net/gentoo"
#BASE_URL="mirror://gentoo"

# This ebuild is based on files obtained from jpackage repository (jboss4-buildmagic-tasks)
# Note that the version number of buildmagic only reflects the version number of the jpackage rpm file
# To recreate the tarball:
# 
# Download the rpm from http://mirrors.dotsrc.org/jpackage/1.7/generic/free/SRPMS/jboss4-buildmagic-tasks-2.0-4jpp.src.rpm
# Convert the rpm to tar, untar jboss-buildmagic-2.0.tar.gz
# In the buildmagic folder remove directories thirdparty and tools/lib (this saves space)
# Compress the folder as buildmagic-${PV}.tar.bz2
# jboss-common-4.0.0.DR4.tar.gz is directly included in the rpm package
#
# Things to improve: 
#
# Javadoc generation
# Better handle stuff from jboss-common-4.0.0.DR4

SRC_URI="${BASE_URL}/buildmagic-${PV}.tar.bz2 ${BASE_URL}/jboss-common-4.0.0.DR4.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND="dev-java/log4j
	>=dev-java/bsf-2.3
	dev-java/ant-core
	>=dev-java/xerces-2.8"

DEPEND=">=virtual/jdk-1.4
	${CDEPEND}"

RDEPEND=">=virtual/jre-1.4
	${CDEPEND}"

S="${WORKDIR}/buildmagic/tasks"

src_unpack() {
	unpack ${A}

	cd ${S}/..

	# TODO: make this into a patch
	# curtesy of jpackage.org
	cp tasks/build.xml tasks/build.xml.sav
	for f in `find tasks/src -name "*.java"`; do
		sed -e 's|com\.ibm\.bsf|org\.apache\.bsf|' $f > temp.java
		cp temp.java $f
	done
	rm temp.java

	# curtesy of jpackage.org
	epatch ${FILESDIR}/jboss4-buildmagic-tasks-build_xml.patch

	epatch "${FILESDIR}/buildmagic-tasks-${PV}-defaults.ent.patch"

	# in order to avoid a circular dependency with jboss-common, we need
	# to include the classes from jboss-common that we actually need
	# TODO: this most likely can be cleaned up with some for loops
	mkdir -p tasks/src/main/org/jboss/util/file
	mkdir -p tasks/src/main/org/jboss/util/platform
	mkdir -p tasks/src/main/org/jboss/util/stream
	mkdir -p tasks/src/main/org/jboss/logging
	cp ../jboss-common/src/main/org/jboss/util/DirectoryBuilder.java tasks/src/main/org/jboss/util
	cp ../jboss-common/src/main/org/jboss/util/Strings.java tasks/src/main/org/jboss/util
	cp ../jboss-common/src/main/org/jboss/util/NestedError.java tasks/src/main/org/jboss/util
	cp ../jboss-common/src/main/org/jboss/util/NestedThrowable.java tasks/src/main/org/jboss/util
	cp ../jboss-common/src/main/org/jboss/util/ThrowableHandler.java tasks/src/main/org/jboss/util
	cp ../jboss-common/src/main/org/jboss/util/ThrowableListener.java tasks/src/main/org/jboss/util
	cp ../jboss-common/src/main/org/jboss/util/NullArgumentException.java tasks/src/main/org/jboss/util
	cp ../jboss-common/src/main/org/jboss/util/EmptyStringException.java tasks/src/main/org/jboss/util
	cp ../jboss-common/src/main/org/jboss/util/file/Files.java tasks/src/main/org/jboss/util/file
	cp ../jboss-common/src/main/org/jboss/util/platform/Java.java tasks/src/main/org/jboss/util/platform
	cp ../jboss-common/src/main/org/jboss/util/stream/Streams.java tasks/src/main/org/jboss/util/stream
	cp ../jboss-common/src/main/org/jboss/logging/Logger.java tasks/src/main/org/jboss/logging
	cp ../jboss-common/src/main/org/jboss/logging/LoggerPlugin.java tasks/src/main/org/jboss/logging
	cp ../jboss-common/src/main/org/jboss/logging/NullLoggerPlugin.java tasks/src/main/org/jboss/logging

	#rm -rf thirdparty
	#rm -rf tools/lib

	cp ${FILESDIR}/build.properties tasks/build.properties
	java-ant_rewrite-classpath tasks/build.xml
}

src_compile() {
	cd "${S}"
	gentoo_jars="$(java-pkg_getjars ant-core,xerces-2,bsf-2.3)"
	ANT_TASKS="ant-tasks" eant -propertyfile build.properties -Dgentoo.classpath="${gentoo_jars}"
}

src_install() {
	java-pkg_dojar output/lib/buildmagic-tasks.jar
}
