#设置qt主题
export QT_QPA_PLATFORMTHEME=qt6ct

#设置语言
export LANG=zh_CN.UTF-8 
export LC_ALL=zh_CN.UTF-8

# 合并 Xresources 配置, 见后文
xrdb -merge ~/.Xresources

# 设置壁纸
feh --bg-fill "/home/kinntaku/Pictures/Wallpapers/wallpaper.png" &

# 禁用自动休眠/黑屏
xset -dpms && xset s off && xset s noblank

# 自动锁屏服务（注意：这里必须加 & 后台运行）
xss-lock --transfer-sleep-lock -- /home/kinntaku/user_dotfiles/bin/lock.sh -n &

# dwm 的 bar, 见后文
/home/kinntaku/user_dotfiles/bin/dwm_bar.sh &

picom -b & # 合成器, 见后文
dunst & # 通知管理器
fcitx5 & # 输入法
nm-applet & # 网络托盘
blueman-applet & # 蓝牙托盘
flclash & # 飞机
copyq & # 剪贴板
Snipaste & # 截图软件
lxqt-policykit-agent & # 应用授权后端
rog-control-center & # 华硕面板

exec dwm