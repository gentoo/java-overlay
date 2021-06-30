# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: gradle.eclass
# @MAINTAINER:
# Gentoo Java Project <java@gentoo.org>
# @AUTHOR:
# Florian Schmaus <flow@gentoo.org>
# @BLURB: Utility functions for the gradle build system.
# @DESCRIPTION:
# Utility functions for the gradle build system.
# WARNING: This eclass is currently experimental and
# subject to change.

EGRADLE_BIN="gradle"

# @FUNCTION: egradle
# @USAGE: [gradle-args]
# @DESCRIPTION
# Invoke gradle
egradle() {
	# TODO --no-build-cache ?
	local gradle_args=(
		--console=plain
		--info
		--stacktrace
		--no-daemon
		--offline
		--no-build-cache
		--gradle-user-home "${T}/gradle_user_home"
		--project-cache-dir "${T}/gradle_project_cache"
	)

	einfo "gradle "${gradle_args[@]}" ${@}"
	"${EGRADLE_BIN}" "${gradle_args[@]}" ${@} || die "gradle failed"
}
