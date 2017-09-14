#!/bin/bash
	export GitRepo=nav_sfdx1
	branch="test1"
	repoURL="git@github.com:nav0229/nav_sfdx1.git"
	if [ -d "$GitRepo" ]; then rm -Rf $GitRepo; fi
	git clone "$repoURL"
	if [[ $? -ne 0 ]]; then
	echo "---Error-->Check GIT Clone error"
	exit 1
	fi
	cd "$GitRepo"
	git checkout "$branch"
	cp ./mkso.sh ../
	chmod 755 ./mkso.sh
	cd ..
	rm -fR "$GitRepo"
	./mkso.sh