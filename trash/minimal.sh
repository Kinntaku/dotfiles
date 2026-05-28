#!/bin/bash

HIS=$HYPRLAND_INSTANCE_SIGNATURE
SOCKET_PATH="$XDG_RUNTIME_DIR/hypr/$HIS/.socket2.sock"

# 监听事件流
socat -U - UNIX-CONNECT:"$SOCKET_PATH" | while read -r line; do

    # 处理新打开的平铺窗口 (直接捕获 openwindow)
    if [[ "$line" == openwindow* ]]; then
        ADDR="0x${line#*>>}"
        ADDR="${ADDR%%,*}"

        WS_NAME=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$ADDR\") | .workspace.name" 2>/dev/null)
        IS_FLOATING=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$ADDR\") | .floating" 2>/dev/null)

        if [[ "$WS_NAME" == special:magic && "$IS_FLOATING" == "false" ]]; then
            hyprctl dispatch movetoworkspace e+0,address:$ADDR
            hyprctl dispatch togglespecialworkspace
            hyprctl dispatch focuswindow address:$ADDR
        fi
    fi

    # # 处理从悬浮转为平铺, 或延迟确定的平铺状态
    # if [[ "$line" == changefloatingmode* ]]; then
    #     # 格式: changefloatingmode>>ADDR,FLOATING_STATsE
    #     DATA="${line#*>>}"
    #     ADDR="0x${DATA%%,*}"
    #     STATE="${DATA#*,}"

    #     # 如果 STATE 为 0, 说明现在是平铺状态
    #     if [ "$STATE" == "0" ]; then
    #         WS_NAME=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$ADDR\") | .workspace.name")
    #         if [[ "$WS_NAME" == special:* ]]; then
    #             hyprctl dispatch movetoworkspace e+0,address:$ADDR
    #             hyprctl dispatch togglespecialworkspace
    #             hyprctl dispatch focuswindow address:$ADDR
    #         fi
    #     fi
    # fi
done
