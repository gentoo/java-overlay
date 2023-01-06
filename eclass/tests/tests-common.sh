#!/usr/bin/env bash
# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

GENTOO_REPO_PATH=$(portageq get_repo_path / gentoo)
JAVA_REPO_PATH=$(portageq get_repo_path / java)

source "${GENTOO_REPO_PATH}/eclass/tests/tests-common.sh"
TESTS_ECLASS_SEARCH_PATHS=(
	"${GENTOO_REPO_PATH}/eclass"
	"${JAVA_REPO_PATH}/eclass"
)
