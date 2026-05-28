#!/bin/bash

CLR_CPU="^c#BF616A^"     # 红
CLR_MEM="^c#D08770^"     # 橙
CLR_VOL="^c#A3BE8C^"     # 绿
CLR_MIC="^c#88C0D0^"     # 青
CLR_PWR="^c#81A1C1^"     # 蓝
CLR_BAT="^c#B48EAD^"     # 紫
CLR_DATE="^c#ECEFF4^"    # 白
CLR_WARN="^c#ECEFF4^^b#BF616A^" # 警告
RESET="^d^"


update_status() {
    # --- CPU 使用率 ---
    CPU_VAL=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf("%.0f", usage)}')
    CPU_DIS="${CLR_CPU}CPU:${CPU_VAL:-0}%${RESET}"

    # --- 内存使用率 ---
    MEM_TOTAL=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    MEM_AVAIL=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    MEM_VAL=$(( (MEM_TOTAL - MEM_AVAIL) * 100 / MEM_TOTAL ))
    MEM_DIS="${CLR_MEM}MEM:${MEM_VAL}%${RESET}"

    # --- 扬声器音量 ---
    V_NUM=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -Po '\d+(?=%)' | head -n 1 || echo "0")
    if pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -q "yes"; then
        VOL_DIS="${CLR_WARN}VOL:M${RESET}"
    else
        VOL_DIS="${CLR_VOL}VOL:${V_NUM}%${RESET}"
    fi

    # --- 麦克风音量 ---
    M_NUM=$(pactl get-source-volume @DEFAULT_SOURCE@ 2>/dev/null | grep -Po '\d+(?=%)' | head -n 1 || echo "0")
    if pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | grep -q "yes"; then
        MIC_DIS="${CLR_WARN}MIC:M${RESET}"
    else
        MIC_DIS="${CLR_MIC}MIC:${M_NUM}%${RESET}"
    fi

    # --- 电源模式 (Power-Profiles-Daemon) ---
    PWR_MODE=$(powerprofilesctl get 2>/dev/null || echo "N/A")
    case "$PWR_MODE" in
        *performance*) PWR_STR="PERF" ;;
        *balanced*)    PWR_STR="BAL"  ;;
        *power-saver*) PWR_STR="SAVE" ;;
        *)             PWR_STR="N/A"  ;;
    esac
    PWR_DIS="${CLR_PWR}PWR:${PWR_STR}${RESET}"

    # --- 亮度 ---
    BRT_CUR=$(brightnessctl g 2>/dev/null || echo 0)
    BRT_MAX=$(brightnessctl m 2>/dev/null || echo 1) # 避免除以0
    BRIGHT_VAL=$(( BRT_CUR * 100 / BRT_MAX ))
    BRT_DIS="${CLR_PWR}BRT:${BRIGHT_VAL}%${RESET}" # 注意：你脚本开头没定义 CLR_BRT，这里暂用 CLR_PWR

    # --- 电池 ---
    BAT_PATH=$(ls /sys/class/power_supply/BAT* -d 2>/dev/null | head -n 1)
    if [ -n "$BAT_PATH" ]; then
        BAT_VAL=$(cat "$BAT_PATH/capacity" 2>/dev/null || echo "0")
        [ "$BAT_VAL" -lt 20 ] && BAT_DIS="${CLR_WARN}BAT:${BAT_VAL}%${RESET}" || BAT_DIS="${CLR_BAT}BAT:${BAT_VAL}%${RESET}"
    else
        BAT_DIS=""
    fi
    
    # --- 时间 ---
    DATE_VAL=$(date +"%m.%d %H:%M")
    DATE_DIS="${CLR_DATE}${DATE_VAL}${RESET}"

    STATUS=" ${CPU_DIS} ${MEM_DIS} ${VOL_DIS} ${MIC_DIS} ${PWR_DIS} ${BRT_DIS} ${BAT_DIS}  ${DATE_DIS} "
    
    xprop -root -f WM_NAME 8s -set WM_NAME "$STATUS"
}

(
    while true; do
        update_status
        sleep 2
    done
) &

(
    pactl subscribe 2>/dev/null | grep --line-buffered -E "sink|source" | while read -r _; do
        update_status
    done
) &

update_status
while true; do sleep 60; done