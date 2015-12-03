#!/bin/bash

dir_is_empty() {
	# usage:
	#  dir_is_empty <some-dir>
	#
	# returns 2 if the dir does not even exist
	# returns 1 if the dir is not empty
	# returns 0 (success) if the dir exists and is empty

	local dir=$1
	local files

	if [[ ! -e ${dir} ]] ; then
		return 2
	fi

	shopt -s nullglob dotglob     # To include hidden files
	files=( "${dir}"/* )
	shopt -u nullglob dotglob

	if [[ ${#files[@]} -eq 0 ]]; then
		return 0
	else
		return 1
	fi

}

# if folders are empty, they are probably mounted in from the host,
# so we sync them

if dir_is_empty "${SIMPLESAML_ROOT:-/NOTHERE}"/config ; then
	echo ""
	echo "Syncing ${SIMPLESAML_ROOT}/config"
	echo ""

	rsync -a /etc/simplesamlphp/config/* \
		"${SIMPLESAML_ROOT}"/config/
fi

if dir_is_empty "${SIMPLESAML_ROOT:-/NOTHERE}"/templates ; then
	echo ""
	echo "Syncing ${SIMPLESAML_ROOT}/templates"
	echo ""

	rsync -a /etc/simplesamlphp/templates/* \
		"${SIMPLESAML_ROOT}"/templates/
fi

