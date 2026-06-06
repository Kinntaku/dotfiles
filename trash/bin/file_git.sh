#!/bin/bash
if [ "$1" == "commit" ]; then # 单文件提交
	read -e -r -p "commit: " commit_message
	if [ -z "$commit_message" ]; then # 无输入检测
		echo "No commit message"
		exit 1
	fi
	git add "$2"
	git commit "$2" -m "$2=${commit_message}"
elif [ "$1" == "resume" ]; then                                                              # 单文件回溯
	IFS=$'\n'                                                                                   # 指定换行
	commits=($(git --no-pager log --follow --oneline --format="%h|%s (%ad)" --date=short "$2")) # 获取文件提交列表
	for i in "${!commits[@]}"; do
		echo "[$i] ${commits[$i]}"
	done
	read -e -r -p "choose: " choice
	git checkout "$(echo "${commits[$choice]}" | cut -d'|' -f1)" -- "$2" # 回溯
else
	exit 1
fi

