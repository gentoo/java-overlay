# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
MY_PV="1.4.7-R1.0"
MC_PV="${MY_PV%-*}"
MC_PN="minecraft-server-unobfuscated"
MC_JAR="${MC_PN}-${MC_PV}.jar"

inherit games vcs-snapshot java-pkg-2 java-pkg-simple

DESCRIPTION="Bukkit implementation for the official Minecraft server"
HOMEPAGE="http://bukkit.org"
SRC_URI="https://github.com/Bukkit/CraftBukkit/tarball/${MY_PV} -> ${P}.tar.gz
	http://repo.bukkit.org/content/repositories/releases/org/bukkit/minecraft-server/${MC_PV}/minecraft-server-${MC_PV}.jar -> ${MC_JAR}"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ipv6"
RESTRICT="test" # Needs hamcrest-1.2?

CDEPEND="dev-java/commons-lang:2.1
	dev-java/ebean:0
	dev-java/gson:2.2.2
	dev-java/guava:10
	>=dev-java/jansi-1.8:0
	dev-java/jline:2
	dev-java/jopt-simple:0
	>=dev-java/snakeyaml-1.9:0
	~games-server/bukkit-1679:0"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.6"
#	test? ( dev-java/hamcrest
#		dev-java/junit:4 )"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.6
	games-server/minecraft-common"

S="${WORKDIR}/${P}"

JAVA_GENTOO_CLASSPATH="bukkit,commons-lang-2.1,ebean,gson-2.2.2,guava-10,jansi,jline-2,jopt-simple,snakeyaml"
JAVA_CLASSPATH_EXTRA="${DISTDIR}/${MC_JAR}"
JAVA_SRC_DIR="src/main/java"

src_unpack() {
	A="${P}.tar.gz" vcs-snapshot_src_unpack
	mkdir -p "${S}/target/classes/META-INF" || die
	cd "${S}/target/classes" || die
	unpack "${MC_JAR}"
}

java_prepare() {
	# Easier to use java-pkg-simple.
	rm -v pom.xml || die

	cp "${FILESDIR}"/directory.sh . || die
	sed -i "s/@GAMES_USER_DED@/${GAMES_USER_DED}/g" directory.sh || die

	echo "Implementation-Version: Gentoo-${PVR}" > target/classes/META-INF/MANIFEST.MF || die
	cp -r src/main/resources/* target/classes || die
}

src_install() {
	local ARGS
	use ipv6 || ARGS="-Djava.net.preferIPv4Stack=true"

	java-pkg-simple_src_install
	java-pkg_dolauncher "${PN}" -into "${GAMES_PREFIX}" -pre directory.sh \
		--java_args "-Xmx1024M -Xms512M ${ARGS}" --main org.bukkit.craftbukkit.Main

	dosym minecraft-server "/etc/init.d/${PN}"
	dodoc README.md

	prepgamesdirs
}

pkg_postinst() {
	einfo "You may run ${PN} as a regular user or start a system-wide"
	einfo "instance using /etc/init.d/${PN}. The multiverse files are"
	einfo "stored in ~/.minecraft/servers or /var/lib/minecraft respectively."
	echo
	einfo "The console for system-wide instances can be accessed by any user in"
	einfo "the ${GAMES_GROUP} group using the minecraft-server-console command. This"
	einfo "starts a client instance of tmux. The most important key-binding to"
	einfo "remember is Ctrl-b d, which will detach the console and return you to"
	einfo "your previous screen without stopping the server."
	echo
	einfo "This package allows you to start multiple CraftBukkit server instances."
	einfo "You can do this by adding a multiverse name after ${PN} or by"
	einfo "creating a symlink such as /etc/init.d/${PN}.foo. You would"
	einfo "then access the console with \"minecraft-server-console foo\". The"
	einfo "default multiverse name is \"main\"."
	echo
	einfo "Some Bukkit plugins store information in a database. Regardless of"
	einfo "whether they handle their own database connectivity or use Bukkit's"
	einfo "own Ebean solution, you can install your preferred JDBC driver through"
	einfo "Portage. The available drivers are..."
	einfo ""
	einfo " # dev-java/h2"
	einfo " # dev-java/sqlite-jdbc"
	einfo " # dev-java/jdbc-mysql"
	einfo " # dev-java/jdbc-postgresql"
	echo

	if has_version games-server/minecraft-server; then
		ewarn "You already have the official server installed. You may run both this"
		ewarn "and CraftBukkit against the same multiverse but not simultaneously."
		ewarn "This is not recommended though so don't come crying to us if it"
		ewarn "trashes your world."
		echo
	fi

	games_pkg_postinst
}

src_test() {
	cd src/test/java || die

	local CP=".:${S}/${PN}.jar:$(java-pkg_getjars hamcrest,junit-4,${JAVA_GENTOO_CLASSPATH})"
	local TESTS=$(find * -name "*Test.java")
	TESTS="${TESTS//.java}"
	TESTS="${TESTS//\//.}"

	ejavac -cp "${CP}" -d . $(find * -name "*.java")
	ejunit4 -classpath "${CP}" ${TESTS}
}
