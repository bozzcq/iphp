#!/bin/sh
# 用于 crontab 中执行一个 php 命令行脚本
# runphp 会进行加锁, 遍历一个脚本启动多个实例, 所以可以放心在用 crontab 来执行
php=php
php_file=$1
lock_file=/tmp/runphp_lock.`echo $1 | sed 's/\//_/g' | sed 's/^\.*//'`.lock

#echo "locking file: $lock_file"

if [ -f /usr/bin/flock ]; then
	flock -x -w 50 $lock_file -c "$php $php_file"
else
	lockfile -r 50 -1 $lock_file
	if [ "$?" -eq "0" ]; then
		$php $php_file
		rm -f $lock_file
	else
		# try to cleanup
		run=`ps aux | grep $php_file | grep -vw 'grep\|sh' | head -n 1 | awk '{print $2}'`
		if [ -n "$run" ]; then
			:
		else
			echo "$php_file not running, cleanup!"
			rm -f $lock_file
		fi
	fi
fi
