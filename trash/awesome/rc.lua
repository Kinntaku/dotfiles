-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then
            return
        end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
beautiful.useless_gap = 5
beautiful.font = "sans 12"
-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {awful.layout.suit.fair}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {{"hotkeys", function()
    hotkeys_popup.show_help(nil, awful.screen.focused())
end}, {"manual", terminal .. " -e man awesome"}, {"edit config", editor_cmd .. " " .. awesome.conffile},
                 {"restart", awesome.restart}, {"quit", function()
    awesome.quit()
end}}

-- 修改 menubar 出现的位置
menubar.geometry = {
    width = 800, -- 宽度
    height = 50, -- 高度
    x = (awful.screen.focused().geometry.width - 800) / 2, -- 屏幕中心 X
    y = (awful.screen.focused().geometry.height - 50) / 2 -- 屏幕中心 Y
}

mymainmenu = awful.menu({
    items = {{"awesome", myawesomemenu, beautiful.awesome_icon}, {"open terminal", terminal}}
})

mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(awful.button({}, 1, function(t)
    t:view_only()
end), awful.button({modkey}, 1, function(t)
    if client.focus then
        client.focus:move_to_tag(t)
    end
end), awful.button({}, 3, awful.tag.viewtoggle), awful.button({modkey}, 3, function(t)
    if client.focus then
        client.focus:toggle_tag(t)
    end
end), awful.button({}, 4, function(t)
    awful.tag.viewnext(t.screen)
end), awful.button({}, 5, function(t)
    awful.tag.viewprev(t.screen)
end))

local tasklist_buttons = gears.table.join(awful.button({}, 1, function(c)
    if c == client.focus then
        c.minimized = true
    else
        c:emit_signal("request::activate", "tasklist", {
            raise = true
        })
    end
end), awful.button({}, 3, function()
    awful.menu.client_list({
        theme = {
            width = 250
        }
    })
end), awful.button({}, 4, function()
    awful.client.focus.byidx(1)
end), awful.button({}, 5, function()
    awful.client.focus.byidx(-1)
end))

local function set_wallpaper(s)
    -- Wallpaper
    local my_wallpaper = "/home/kinntaku/Pictures/Wallpapers/wallpaper.png"

    -- 2. 直接调用 gears 的函数，跳过原本复杂的判断逻辑
    gears.wallpaper.maximized(my_wallpaper, s, true)
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)
-- 1. CPU 百分比
-- CPU: 读取 /proc/loadavg (虽然是负载，但最稳定) 或者使用简化版 stat

-- 1. 定义菜单内容
local powermenu = {{"Suspend", function()
    awful.spawn("systemctl suspend")
end}, {"Hibernate", function()
    awful.spawn("systemctl hibernate")
end}, {"Reboot", function()
    awful.spawn("systemctl reboot")
end}, {"Poweroff", function()
    awful.spawn("systemctl poweroff")
end}, {"Quit Awesome", function()
    awesome.quit()
end}}

-- 2. 创建菜单实例
local mypowermenu = awful.menu({
    items = powermenu,
    theme = {
        width = 250, -- 强制菜单宽度为 250 像素
        height = 40, -- 强制每一行的高度为 40 像素（配合大字体）
        font = "sans 14" -- 确保字体大小统一
    }
})

local cpu_widget = awful.widget.watch(
    'bash -c "cat /proc/stat | grep \'cpu \' | awk \'{print ($2+$4)*100/($2+$4+$5)}\' | cut -d. -f1 | sed \'s/$/%/\'"',
    2)

-- MEM: 使用 free 命令的最简提取
local mem_widget = awful.widget
                       .watch('bash -c "free | grep Mem | awk \'{print int($3/$2 * 100)}\' | sed \'s/$/%/\'"', 2)

-- VOL: 放弃 amixer，改用 pactl (PipeWire/PulseAudio 通用)
-- 音量显示组件
local vol_widget = wibox.widget.textbox()

local function update_vol_widget()
    -- 同时获取音量百分比和静音状态 ([mute])
    awful.spawn.easy_async_with_shell(
        "pactl get-sink-mute @DEFAULT_SINK@; pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\\d+(?=%)' | head -n 1",
        function(stdout)
            -- 分割输出结果：第一行是 Mute 状态，第二行是音量
            local is_mute = stdout:match("Mute: yes")
            local vol = stdout:match("(%d+)\n$") or "0"

            local display_text = ""
            if is_mute then
                -- 静音时的显示格式，可以设为 "M" 或 "0%" 但带特殊颜色
                display_text = "<span font='sans 13' color='#f7768e'>Mute</span>"
            else
                -- 正常状态格式，与 mem_widget 统一
                display_text = "<span font='sans 13'>" .. vol .. "%</span>"
            end

            vol_widget:set_markup(display_text)
        end)
end
-- 初始化执行一次
update_vol_widget()

-- 麦克风显示组件
local mic_widget = wibox.widget.textbox()

local function update_mic_widget()
    -- 获取默认输入设备的静音状态和音量
    awful.spawn.easy_async_with_shell(
        "pactl get-source-mute @DEFAULT_SOURCE@; pactl get-source-volume @DEFAULT_SOURCE@ | grep -Po '\\d+(?=%)' | head -n 1",
        function(stdout)
            local is_mute = stdout:match("Mute: yes")
            local vol = stdout:match("(%d+)\n$") or "0"

            local display_text = ""
            if is_mute then
                -- 麦克风静音时显示 Mic(M) 或红色，防止开会尴尬
                display_text = "<span font='sans 13' color='#f7768e'>Mic(M)</span>"
            else
                -- 正常显示百分比
                display_text = "<span font='sans 13'>" .. vol .. "%</span>"
            end

            mic_widget:set_markup(display_text)
        end)
end

-- 初始化
update_mic_widget()

-- BRI: 你说这个好使，保留原样
local bright_widget = awful.widget.watch('bash -c "brightnessctl -m | cut -d, -f4"', 0.5)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "}, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(awful.button({}, 1, function()
        awful.layout.inc(1)
    end), awful.button({}, 3, function()
        awful.layout.inc(-1)
    end), awful.button({}, 4, function()
        awful.layout.inc(1)
    end), awful.button({}, 5, function()
        awful.layout.inc(-1)
    end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.noempty,
        buttons = taglist_buttons,
        style = {
            -- 核心：将这四个正方形指示器图标全部设为空
            squares_sel = "", -- 当前选中的 Tag 左上角方块
            squares_unsel = "", -- 未选中的 Tag 左上角方块
            squares_sel_empty = "", -- 选中的空 Tag
            squares_unsel_empty = "" -- 未选中的空 Tag
        }

    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        style = {
            -- 1. 取消高亮背景：将背景色设为透明或与任务栏背景一致
            bg_focus = "#00000000",

            -- 2. 将当前窗口文字颜色改为黄色 (例如经典的 Matcha 黄 #e6db74 或 纯黄 #ffff00)
            fg_focus = "#ffff00",

            -- 3. (可选) 如果你也不想要边框高亮，可以加这一行
            border_width = 0

            -- 保持你之前的图标大小设置
        }

    }

    -- Create the wibox
    s.mywibox = awful.wibar({
        position = "top",
        screen = s

    })

    -- Add widgets to the wibox
    s.mywibox:setup{
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            -- mylauncher,
            s.mytaglist,
            s.mypromptbox

        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.textbox("  CPU: "),
            cpu_widget,
            wibox.widget.textbox("  MEM: "),
            mem_widget,
            wibox.widget.textbox("  VOL: "),
            vol_widget,
            wibox.widget.textbox("  MIC: "),
            mic_widget,
            wibox.widget.textbox("  BRI: "),
            bright_widget,
            wibox.widget.textbox(" "),
            mytextclock,
            wibox.widget.textbox(" "),
            wibox.widget.systray()

        }
    }

end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(awful.button({}, 3, function()
    mymainmenu:toggle()
end), awful.button({}, 4, awful.tag.viewnext), awful.button({}, 5, awful.tag.viewprev)))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join( -- {{{ Custom Media Keys
-- 音量控制 (Mod + F1/F2/F3 或笔记本自带多媒体键)
-- 增大音量
awful.key({}, "XF86AudioRaiseVolume", function()
    awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
end, {
    description = "volume up",
    group = "hotkeys"
}), -- 减小音量
awful.key({}, "XF86AudioLowerVolume", function()
    awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
end, {
    description = "volume down",
    group = "hotkeys"
}), -- 静音切换
awful.key({}, "XF86AudioMute", function()
    awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
end, {
    description = "toggle mute",
    group = "hotkeys"
}), -- 屏幕亮度控制 (笔记本自带亮度键)
-- 麦克风静音切换
awful.key({}, "XF86AudioMicMute", function()
    awful.spawn.easy_async("pactl set-source-mute @DEFAULT_SOURCE@ toggle", function()
        update_mic_widget()
    end)
end), -- 增加亮度
awful.key({}, "XF86MonBrightnessUp", function()
    awful.spawn("brightnessctl set 5%+")
end, {
    description = "brightness up",
    group = "hotkeys"
}), -- 降低亮度
awful.key({}, "XF86MonBrightnessDown", function()
    awful.spawn("brightnessctl set 5%-")
end, {
    description = "brightness down",
    group = "hotkeys"
}), -- }}}
-- {{{ Media Player Control
-- 播放/暂停
awful.key({}, "XF86AudioPlay", function()
    awful.spawn("playerctl play-pause")
end, {
    description = "play/pause",
    group = "media"
}), -- 下一曲
awful.key({}, "XF86AudioNext", function()
    awful.spawn("playerctl next")
end, {
    description = "next track",
    group = "media"
}), -- 上一曲
awful.key({}, "XF86AudioPrev", function()
    awful.spawn("playerctl previous")
end, {
    description = "previous track",
    group = "media"
}), -- 停止播放
awful.key({}, "XF86AudioStop", function()
    awful.spawn("playerctl stop")
end, {
    description = "stop",
    group = "media"
}), -- }}}
awful.key({modkey}, "v", function()
    awful.spawn("copyq show")
end, {
    description = "show copyq",
    group = "launcher"
}), awful.key({modkey}, "Right", awful.tag.viewnext, {
    description = "view next",
    group = "tag"
}), awful.key({modkey}, "Escape", awful.tag.history.restore, {
    description = "go back",
    group = "tag"
}), awful.key({modkey}, "j", function()
    awful.client.focus.byidx(1)
end, {
    description = "focus next by index",
    group = "client"
}), awful.key({modkey}, "k", function()
    awful.client.focus.byidx(-1)
end, {
    description = "focus previous by index",
    group = "client"
}), awful.key({modkey}, "w", function()
    mymainmenu:show()
end, {
    description = "show main menu",
    group = "awesome"
}), -- Layout manipulation
awful.key({modkey, "Shift"}, "j", function()
    awful.client.swap.byidx(1)
end, {
    description = "swap with next client by index",
    group = "client"
}), awful.key({modkey, "Shift"}, "k", function()
    awful.client.swap.byidx(-1)
end, {
    description = "swap with previous client by index",
    group = "client"
}), awful.key({modkey, "Control"}, "j", function()
    awful.screen.focus_relative(1)
end, {
    description = "focus the next screen",
    group = "screen"
}), awful.key({modkey, "Control"}, "k", function()
    awful.screen.focus_relative(-1)
end, {
    description = "focus the previous screen",
    group = "screen"
}), awful.key({modkey}, "u", awful.client.urgent.jumpto, {
    description = "jump to urgent client",
    group = "client"
}), awful.key({modkey}, "Tab", function()
    awful.client.focus.byidx(1) -- 1 代表向后循环，-1 代表向前
end, {
    description = "focus next by index",
    group = "client"
}), -- 如果你还需要原本的“回跳”功能，可以把 Shift + Tab 改为之前的逻辑
awful.key({modkey, "Shift"}, "Tab", function()
    awful.client.focus.byidx(-1)
end, {
    description = "focus previous by index",
    group = "client"
}), -- WASD 窗口焦点切换
-- Win + W (向上切换)
awful.key({modkey, "Shift"}, "w", function()
    awful.client.focus.bydirection("up")
end, {
    description = "focus up",
    group = "client"
}), -- Win + S (向下切换)
awful.key({modkey, "Shift"}, "s", function()
    awful.client.focus.bydirection("down")
end, {
    description = "focus down",
    group = "client"
}), -- Win + A (向左切换)
-- 注意：如果你之前把 Win + A 设为了切换工作区，这里会产生冲突。
-- 如果你想保留 A/D 切换工作区，建议将窗口切换设为 Win + hjkl 或其他组合。
-- 如果坚持用 WASD 切窗口，请注释掉之前的 viewprev/next。
awful.key({modkey, "Shift"}, "a", function()
    awful.client.focus.bydirection("left")
end, {
    description = "focus left",
    group = "client"
}), -- Win + D (向右切换)
awful.key({modkey, "Shift"}, "d", function()
    awful.client.focus.bydirection("right")
end, {
    description = "focus right",
    group = "client"
}), -- Standard program
awful.key({modkey}, "Return", function()
    awful.spawn(terminal)
end, {
    description = "open a terminal",
    group = "launcher"
}), awful.key({modkey, "Control"}, "r", awesome.restart, {
    description = "reload awesome",
    group = "awesome"
}), awful.key({modkey, "Shift"}, "e", awesome.quit, {
    description = "quit awesome",
    group = "awesome"
}), awful.key({modkey}, "l", function()
    awful.tag.incmwfact(0.05)
end, {
    description = "increase master width factor",
    group = "layout"
}), awful.key({modkey}, "h", function()
    awful.tag.incmwfact(-0.05)
end, {
    description = "decrease master width factor",
    group = "layout"
}), awful.key({modkey, "Shift"}, "h", function()
    awful.tag.incnmaster(1, nil, true)
end, {
    description = "increase the number of master clients",
    group = "layout"
}), awful.key({modkey, "Shift"}, "l", function()
    awful.tag.incnmaster(-1, nil, true)
end, {
    description = "decrease the number of master clients",
    group = "layout"
}), awful.key({modkey, "Control"}, "h", function()
    awful.tag.incncol(1, nil, true)
end, {
    description = "increase the number of columns",
    group = "layout"
}), awful.key({modkey, "Control"}, "l", function()
    awful.tag.incncol(-1, nil, true)
end, {
    description = "decrease the number of columns",
    group = "layout"
}), awful.key({modkey, "Control"}, "n", function()
    local c = awful.client.restore()
    -- Focus restored client
    if c then
        c:emit_signal("request::activate", "key.unminimize", {
            raise = true
        })
    end
end, {
    description = "restore minimized",
    group = "client"
}), -- Prompt
awful.key({modkey}, "r", function()
    awful.screen.focused().mypromptbox:run()
end, {
    description = "run prompt",
    group = "launcher"
}), -- Menubar
awful.key({modkey}, "grave", function()
    menubar.show()
end, {
    description = "show the menubar",
    group = "launcher"
}), awful.key({modkey}, "e", function()
    awful.spawn("thunar")
end, {
    description = "open file manager",
    group = "launcher"
}), awful.key({modkey}, "t", function()
    awful.spawn("kitty")
end, {
    description = "open kitty",
    group = "launcher"
}), -- 向后切换桌面 (d) - 到末尾停止
awful.key({modkey}, "d", function()
    local s = awful.screen.focused()
    local current_index = s.selected_tag.index
    -- 只有当当前索引小于总标签数时，才允许切换到下一个
    if current_index < #s.tags then
        awful.tag.viewnext(s)
    end
end, {
    description = "view next tag (no wrap)",
    group = "tag"
}), -- 向前切换桌面 (a) - 到开头停止
awful.key({modkey}, "a", function()
    local s = awful.screen.focused()
    local current_index = s.selected_tag.index
    -- 只有当当前索引大于 1 时，才允许切换到上一个
    if current_index > 1 then
        awful.tag.viewprev(s)
    end
end, {
    description = "view previous tag (no wrap)",
    group = "tag"
}), -- 1. 锁屏快捷键 (Mod + l)
awful.key({modkey}, "l", function()
    awful.spawn.with_shell("bash /home/kinntaku/user_dotfiles/bin/lock.sh")
end, {
    description = "lock screen",
    group = "launcher"
}), -- 2. 呼出 navi 备忘录 (Alt + Space)
awful.key({"Mod1"}, "space", function()
    awful.spawn("kitty -e navi --path /home/kinntaku/user_dotfiles/navi")
end, {
    description = "open navi cheatsheet",
    group = "launcher"
}), -- 启动 ROG 控制中心 (ROG 键/Launch3)
awful.key({}, "XF86Launch3", function()
    awful.spawn("rog-control-center")
end, {
    description = "open ROG control center",
    group = "launcher"
}), -- 在 globalkeys 中添加
awful.key({modkey}, "x", function()
    mypowermenu:show()
end, {
    description = "show power menu",
    group = "awesome"
}))

clientkeys = gears.table.join(awful.key({modkey, "Shift"}, "f", function(c)
    c.fullscreen = not c.fullscreen
    c:raise()
end, {
    description = "toggle fullscreen",
    group = "client"
}), awful.key({"Mod1"}, "F4", function(c)
    c:kill()
end, {
    description = "close",
    group = "client"
}), awful.key({modkey}, "f", awful.client.floating.toggle, {
    description = "toggle floating",
    group = "client"
}), awful.key({modkey, "Control"}, "Return", function(c)
    c:swap(awful.client.getmaster())
end, {
    description = "move to master",
    group = "client"
}), awful.key({modkey}, "o", function(c)
    c:move_to_screen()
end, {
    description = "move to screen",
    group = "client"
}), awful.key({modkey}, "t", function(c)
    c.ontop = not c.ontop
end, {
    description = "toggle keep on top",
    group = "client"
}), awful.key({modkey}, "n", function(c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
end, {
    description = "minimize",
    group = "client"
}), awful.key({modkey}, "m", function(c)
    c.maximized = not c.maximized
    c:raise()
end, {
    description = "(un)maximize",
    group = "client"
}), awful.key({modkey, "Control"}, "m", function(c)
    c.maximized_vertical = not c.maximized_vertical
    c:raise()
end, {
    description = "(un)maximize vertically",
    group = "client"
}), awful.key({modkey, "Shift"}, "m", function(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c:raise()
end, {
    description = "(un)maximize horizontally",
    group = "client"
}))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys, -- View tag only.
    awful.key({modkey}, "#" .. i + 9, function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
            tag:view_only()
        end
    end, {
        description = "view tag #" .. i,
        group = "tag"
    }), -- Move client to tag.
    awful.key({modkey, "Control"}, "#" .. i + 9, function()
        if client.focus then
            local tag = client.focus.screen.tags[i]
            if tag then
                client.focus:move_to_tag(tag)
            end
        end
    end, {
        description = "move focused client to tag #" .. i,
        group = "tag"
    }) -- Toggle tag on focused client.
    )
end

clientbuttons = gears.table.join(awful.button({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", {
        raise = true
    })
end), awful.button({modkey}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", {
        raise = true
    })
    awful.mouse.client.move(c)
end), awful.button({modkey}, 3, function(c)
    c:emit_signal("request::activate", "mouse_click", {
        raise = true
    })
    awful.mouse.client.resize(c)
end))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = { -- All clients will match this rule.
{
    rule = {},
    properties = {
        border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = awful.client.focus.filter,
        raise = true,
        keys = clientkeys,
        buttons = clientbuttons,
        screen = awful.screen.preferred,
        placement = awful.placement.no_overlap + awful.placement.no_offscreen
    }
}, -- Floating clients.
{
    rule = {
        class = "kitty"
    },
    properties = {
        floating = true,
        width = 1400, -- 初始宽度
        height = 800, -- 初始高度
        placement = awful.placement.centered -- 让它启动时出现在屏幕正中央
    }
}, -- 设置 Thunar 默认浮动并居中
{
    rule = {
        class = "Thunar"
    }, -- 注意：Thunar 的首字母通常是大写
    properties = {
        floating = true,
        width = 1400, -- 初始宽度
        height = 800, -- 初始高度
        placement = awful.placement.centered
    }
}, {
    rule = {
        class = "rog-control-center"
    }, -- 注意：Thunar 的首字母通常是大写
    properties = {
        floating = true,
        width = 1400, -- 初始宽度
        height = 800, -- 初始高度
        placement = awful.placement.centered
    }
}, -- 微信 (WeChat) 规则
{
    rule = {
        class = "wechat"
    },
    properties = {
        floating = true
    }
}, {
    rule = {
        class = "wechat",
        name = "Weixin"
    },
    properties = {
        floating = false
    }
}, -- 主窗口不浮动
-- QQ 规则
{
    rule = {
        class = "QQ"
    },
    properties = {
        floating = true
    }
}, -- 主窗口不浮动
{
    rule = {
        class = "copyq"
    },
    properties = {
        floating = true,
        width = 800, -- 初始宽度
        height = 500, -- 初始高度
        placement = awful.placement.centered

    }
}, -- 主窗口不浮动
{
    rule = {
        class = "QQ",
        name = "QQ"
    },
    properties = {
        floating = false
    }
} -- Set Firefox to always map on the tag named "2" on screen 1.
-- { rule = { class = "Firefox" },
--   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end
    c.maximized = false
    c.maximized_vertical = false
    c.maximized_horizontal = false
    c.size_hints_honor = false
    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
--     c:emit_signal("request::activate", "mouse_enter", {raise = false})
-- end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)
-- }}}R

-- 环境配置
awful.spawn.with_shell("export QT_QPA_PLATFORMTHEME=qt6ct")
awful.spawn.with_shell("xrdb -merge ~/.Xresources")
awful.spawn.with_shell("xset -dpms && xset s off && xset s noblank")
awful.spawn.with_shell("xss-lock --transfer-sleep-lock -- /home/kinntaku/user_dotfiles/bin/lock.sh -n &")
awful.spawn.with_shell("picom -b")

-- 应用启动
awful.spawn.with_shell("fcitx5 &")
awful.spawn.with_shell("nm-applet &")
awful.spawn.with_shell("blueman-applet &")
awful.spawn.with_shell("flclash &")
awful.spawn.with_shell("copyq &")
awful.spawn.with_shell("Snipaste &")
awful.spawn.with_shell("lxqt-policykit-agent &")
awful.spawn.with_shell("rog-control-center &")
awful.spawn.with_shell("/usr/lib/xdg-desktop-portal &")
awful.spawn.with_shell("/usr/lib/xdg-desktop-portal-gtk &")

-- 音量监听
awful.spawn.with_line_callback("pactl subscribe", {
    stdout = function(line)
        if line:match("Event 'change' on sink") or line:match("Event 'change' on source") then
            update_vol_widget()
            update_mic_widget()
        end
    end
})
