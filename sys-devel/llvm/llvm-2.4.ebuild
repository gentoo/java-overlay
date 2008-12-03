# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils toolchain-funcs

DESCRIPTION="Low Level Virtual Machine"
HOMEPAGE="http://llvm.org/"
SRC_URI="http://llvm.org/releases/${PV}/llvm-${PV}.tar.gz"

LICENSE="LLVM"
# most part of LLVM fall under the "University of Illinois Open Source License"
# which doesn't seem to exist in portage yet, so I call it 'LLVM' for now.  it
# can be read from llvm/LICENSE.TXT in the source tarball.

# the directory llvm/runtime/GCCLibraries/libc contains a stripped down C
# library licensed under the LGPL 2.1 with some third party copyrights, see the
# two LICENCE* files in that directory.  Those parts do *not* get built, so
# we omit LGPL in ${LICENCE}

SLOT="0"

KEYWORDS="~x86 ~amd64 ~ppc"

IUSE="debug alltargets pic"
# 'jit' is not a flag anymore.  at least on x86, disabling it saves nothing
# at all, so having it always enabled for platforms that support it is fine

# we're not mirrored, fetch from homepage
RESTRICT="mirror"

DEPEND="dev-lang/perl
		>=sys-devel/make-3.79
		>=sys-devel/flex-2.5.4
		>=sys-devel/bison-1.28
		>=sys-devel/gcc-3.0
		"
RDEPEND="dev-lang/perl"
PDEPEND=""
# note that app-arch/pax is no longer a dependency

S="${WORKDIR}/llvm-${PV}"

MY_LLVM_GCC_PREFIX=/usr/lib/llvm-gcc
# this same variable is located in llvm-gcc's ebuild; keep them in sync

pkg_setup() {

	broken_gcc=( 3.2.2 3.2.3 3.3.2 4.1.1 )
	broken_gcc_x86=( 3.4.0 3.4.2 )
	broken_gcc_amd64=( 3.4.6 )

	gcc_vers=`gcc-fullversion`

	for version in ${broken_gcc[@]}
	do
		if [ "$gcc_vers" = "$version" ]; then
			elog "Your version of gcc is known to miscompile llvm"
			elog "check http://www.llvm.org/docs/GettingStarted.html for \
possible solutions"
			die "Your version of gcc is known to miscompile llvm"
		fi
	done

	if use x86; then
		for version in ${broken_gcc_x86[@]}
		do
			if [ "$gcc_vers" = "$version" ]; then
				elog "Your version of gcc is known to miscompile llvm in x86 \
architectures"
				elog "check http://www.llvm.org/docs/GettingStarted.html for \
possible solutions"
				die "Your version of gcc is known to miscompile llvm"
			fi
		done
	fi

	if use amd64; then
		for version in ${broken_gcc_amd64[@]}
		do
			if [ "$gcc_vers" = "$version" ]; then
				elog "Your version of gcc is known to miscompile llvm in amd64 \
architectures"
				elog "check http://www.llvm.org/docs/GettingStarted.html for \
possible solutions"
				die "Your version of gcc is known to miscompile llvm"
			fi
		done
	fi

	broken_bison=( 1.85 1.875 )

	for version in ${broken_bison[@]}
	do
		if [ $(bison --version | head -n1 | cut -f4 -d" ") = "$version" ]; then
			elog "Your version of Bison is known not to work with llvm, please \
upgrade to a newer version"
			die "Your version of Bison is known not to work with llvm"
		fi
	done


	buggy_ld=( 2.16 2.17 )

	for version in ${buggy_ld[@]}
	do
		if [ $(ld --version | head -n1 | cut -f5 -d" ") = "$version" ]; then
			ewarn "Your version of Binutils is known to be problematic with \
llvm -> llvm team recommends upgrading"
		fi
	done
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# unfortunately ./configure won't listen to --mandir and the-like, so take
	# care of this.
	einfo "Fixing install dirs"
	sed -e 's,^PROJ_docsdir.*,PROJ_docsdir := $(DESTDIR)$(PROJ_prefix)/share/doc/'${PF}, \
		-e 's,^PROJ_etcdir.*,PROJ_etcdir := $(DESTDIR)/etc/llvm,' \
		-i Makefile.config.in || die "sed failed"

	# fix gccld and gccas, which would otherwise point to the build directory
	einfo "Fixing gccld and gccas"
	sed -e 's,^TOOLDIR.*,TOOLDIR=/usr/bin,' \
		-i tools/gccld/gccld.sh tools/gccas/gccas.sh || die "sed failed"

	# all binaries get rpath'd to a dir in the temporary tree that doesn't
	# contain libraries anyway; can safely remove those to avoid QA warnings
	# (the exception would be if we build shared libraries, which we don't)
	einfo "Fixing rpath"
	sed -e 's,-rpath \$(ToolDir),,g' -i Makefile.rules || die "sed failed"

	# This patch solves the PIC code generation for 64bits platforms. It is
	# activated with a USE flag, so users know what they are doing
	if use amd64 && use pic; then
		epatch "${FILESDIR}"/llvm-2.3-64bits-pic.patch
		elog "PIC code generation for 64 bits -> patch applied"
	fi

	epatch "${FILESDIR}"/llvm-2.3-dont-build-hello.patch
	epatch "${FILESDIR}"/llvm-2.3-disable-strip.patch

}


src_compile() {
	local CONF_FLAGS=""

	if use debug; then
		CONF_FLAGS="${CONF_FLAGS} --disable-optimized"
		einfo "Note: Compiling LLVM in debug mode will create huge and slow binaries"
		# ...and you probably shouldn't use tmpfs, unless it can hold 900MB
	else
		CONF_FLAGS="${CONF_FLAGS} --enable-optimized --disable-assertions \
--disable-expensive-checks"
	fi

	if use alltargets; then
		CONF_FLAGS="${CONF_FLAGS} --enable-targets=all"
	else
		CONF_FLAGS="${CONF_FLAGS} --enable-targets=host-only"
	fi

	if use amd64 && use pic; then
		CONF_FLAGS="${CONF_FLAGS} --enable-pic"
	fi

	# a few minor things would be built a bit differently depending on whether
	# llvm-gcc is already present on the system or not.  let's avoid that by
	# not letting it find llvm-gcc.  llvm-gcc isn't required for anything
	# anyway.  this dummy path will get spread to a few places, but none where
	# it really matters.
	CONF_FLAGS="${CONF_FLAGS} --with-llvmgccdir=/dev/null"

	econf ${CONF_FLAGS} || die "econf failed"
	emake tools-only || die "emake failed"
}

src_install()
{
	make DESTDIR="${D}" install || die "make install failed"

	# for some reason, LLVM creates a few .dir files.  remove them
	find "${D}" -name .dir -print0 | xargs -r0 rm

	# tblgen and stkrc do not get installed and wouldn't be very useful anyway,
	# so remove their man pages.  llvmgcc.1 and llvmgxx.1 are present here for
	# unknown reasons.  llvm-gcc will install proper man pages for itself, so
	# remove these strange thingies here.
	einfo "Removing unnecessary man pages"
	rm "${D}"/usr/share/man/man1/{tblgen,stkrc,llvmgcc,llvmgxx}.1

	# this also installed the man pages llvmgcc.1 and llvmgxx.1, which is a bit
	# a mistery because those binares are provided by llvm-gcc

}


