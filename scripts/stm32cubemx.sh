#!/bin/bash
Xephyr -br -ac -noreset -screen 1920x1080 :5 >/dev/null 2>&1 &
sleep 0.5
systemd-run --user bash -c "DISPLAY=:5 stm32cubemx" >/dev/null 2>&1
