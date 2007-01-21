# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: nichoj
# Purpose:
#

EXPORT_FUNCTIONS src_unpack src_install

TEST_LOG=${T}/${EBUILD_PHASE}.log
run_tests() {
	export FAILED_CHECKS=0
	export PHASE_TESTS_RUN=0
	for function in ${*}; do
		export TESTS_RUN=0
		echo
		echo "Testing ${function}"

		# clean out old files
		rm -rf ${function}
		# make a new test bed
		mkdir ${function}
		pushd ${function} >/dev/null

		# Run dem tests
		test_${function}

		# pull out
		popd >/dev/null

		echo "${TESTS_RUN} test(s) run"
		let "PHASE_TESTS_RUN+=${TESTS_RUN}"
	done

}

display_log_if_failed() {
	# Notify about failed checks
	if [[ ${FAILED_CHECKS} != 0 ]]; then
		eerror "Failed ${FAILED_CHECKS} test(s). Log as follows:"
		cat ${TEST_LOG}
		eerror "End transmission."
		return
	fi
}

test-harness_src_install() {
	export SRC_INSTALL_FAILED=0

	if [[ -n ${TEST_SRC_INSTALL_FUNCTIONS} ]]; then
		einfo "Running src_install tests"
		run_tests ${TEST_SRC_INSTALL_FUNCTIONS}
		echo
		einfo "src_install results: ${PHASE_TESTS_RUN} run, ${FAILED_CHECKS} failed"

		display_log_if_failed
	else
		einfo "No tests to run for src_install"
	fi
}

test-harness_src_unpack() {
	export SRC_INSTALL_FAILED=0

	export SRC_INSTALL_FAILED=0

	if [[ -n ${TEST_SRC_UNPACK_FUNCTIONS} ]]; then
		einfo "Running src_unpack tests"
		run_tests ${TEST_SRC_UNPACK_FUNCTIONS}
		echo
		einfo "src_unpack results: ${PHASE_TESTS_RUN} run, ${FAILED_CHECKS} failed"

		display_log_if_failed
	else
		einfo "No tests to run for src_unpack"
	fi
}

pre_test_death() { return 0; }
post_fail_test_death() { return 0; }
post_pass_test_death() { return 0; }

expect_death() {
	test_death 1 $@
}

expect_no_death() {
	test_death 0 $@
}

test_death() {
	pre_test_death $@
	local expected_value=${1}
	shift
	local start_str
	if [[ ${expected_value} == 0 ]]; then
		start_str="Not expecting '$@' to die"
	else
		start_str="Expecting '$@' to die"
	fi
	ebegin "${start_str}"

	echo "${start_str}" >> "${TEST_LOG}"
	( $@ ) >> ${TEST_LOG} 2>&1

	local actual_result=$?
	local result=$( [[ ${actual_result} == ${expected_value} ]] && echo 0 || echo 1 )
	echo "Result: ${result}" >> ${TEST_LOG}
	echo >> ${TEST_LOG}

	eend ${result}

	let "TESTS_RUN+=1"
	export TEST_RUN

	if [[ ${result} != 0 ]]; then
		post_fail_test_death $@
		let "FAILED_CHECKS+=1"
		return 1
	else
		post_pass_test_death $@
		return 0
	fi
}

expect_exists() {
	test_file_exists 0 $@
}

expect_not_exists() {
	test_file_exists 1 $@
}

test_file_exists() {
	local expected_value=${1}
	shift

	local failed_checks=0
	local file
	for file in $@; do
		local expected_value_str
		if [[ ${expected_value} == 0 ]]; then
			expected_value_str="Expecting ${file#${D}/}"
		elif [[ ${expected_value} == 1 ]]; then
			expected_value_str="Not expecting ${file#$D/}"
		else
			die "Whoops... only expecting 0 or 1"
		fi

		ebegin "${expected_value_str}"
		echo -n "${expected_value_str} ... " >> ${TEST_LOG}

		local test_str="-f ${file}"
		[[ ${expected_value} == 1 ]] && test_str="! ${test_str}"
		if [[ ${test_str} ]]; then
			eend 0
			echo "yes" >> ${TEST_LOG}
		else
			eend 1
			echo "no" >> ${TEST_LOG}
			let "failed_checks=${failed_checks}+1"
		fi
	done
	let "FAILED_CHECKS+=${failed_checks}"
	let "TESTS_RUN+=${#}"
	export FAILED_CHECKS TESTS_RUN

	return ${failed_checks}
}

expect_string() {
	local expected_value=${1}
	shift
	local command=$@

	local start_str="Expecting '${command}' to return '${expected_value}'"
	echo  ${start_str} >> ${TEST_LOG}

	ebegin "Expecting '${command}' to return '${expected_value}'"
	local returned_value=$( ${command} )

	if [[ ${expected_value} = ${returned_value} ]]; then
		eend 0
	else
		let "FAILED_CHECKS+=1"
		echo "Got ${returned_string} instead" >> ${TEST_LOG}
		eend 1
	fi
	let "TESTS_RUN+=1"
	export FAILED_CHECKS TESTS_RUN
}
