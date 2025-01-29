#!/bin/bash

## Script cherry-pick commits from a text file list
#
# Version: 0.0.0.1
#
# Upstream-Name: kernel-halium-tree-patches
#  Source: https://gitlab.com/berbascum/kernel-halium-tree-patches
#
# Copyright (C) 2025 Berbascum <berbascum@ticv.cat>
# All rights reserved.
# BSD 3-Clause License


## Sample for generate list:
#git log --reverse linux-stable-dir/linux-local-4.15.y 6eaef1b1d872^..v4.15.18 --grep="bpf" -i --oneline > gitlog-bpf-4.15.18-full-reverse.log


file="gitlog-bpf-4.15.18-full-reverse-edited.log"

while read -r commit; do
    id="$(echo "${commit}" | awk '{print $1}')"
    subject="${commit}"
    is_merge="$(echo ${commit} | grep "${id} Merge")"
    echo ""
    echo ""
    echo ""
    echo "Patching: ${commit}"
    sleep 2
    if [ -n "${is_merge}" ]; then
        echo ""
        echo "The commit is a merge"
        sleep 2
        pick_result=$(git cherry-pick -m 1 "${id}" 2>&1 | grep "allow-empty")
        msg_full=$(git log -1 --format=%B "${id}")
        if [ -n "${pick_result}" ]; then 
            echo ""
            echo "The merge commit is empty"
            git commit --allow-empty -m "${msg_full}"
            exitcode=$?
            sleep 2
        fi
    else
        git cherry-pick "${id}"
        exitcode=$?
    fi
    if [ "${exitcode}" -ne "0" ]; then
        # git cherry-pick --abort
        echo ""
        echo ""
        echo ""
        echo "Patch FAILED ${commit}"
        exit 1
    fi
done < ${file}
