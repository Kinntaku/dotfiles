#!/bin/bash
if pkill -x wlsunset >/dev/null 2>&1; then
	exit 0
else
	setsid wlsunset -T 5001 -t 5000 >/dev/null 2>&1 &
fi
