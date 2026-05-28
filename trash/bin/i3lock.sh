#!/bin/sh

BLANK='#00000000'
CLEAR='#00000000'
DEFAULT='#ffffffff'
TEXT='#ffffffff'
WRONG='#fc5500ff'
VERIFYING='#0089B6ff'
BACKGROUND='#000000ff'

i3lock \
--color=$BACKGROUND          \
--insidever-color=$CLEAR     \
--ringver-color=$VERIFYING   \
\
--insidewrong-color=$CLEAR   \
--ringwrong-color=$WRONG     \
\
--inside-color=$BLANK        \
--ring-color=$DEFAULT        \
--line-color=$BLANK          \
--separator-color=$BLANK     \
\
--verif-color=$TEXT          \
--wrong-color=$TEXT          \
--time-color=$TEXT           \
--date-color=$TEXT           \
--layout-color=$TEXT         \
--keyhl-color=$VERIFYING         \
--bshl-color=$WRONG          \
--modifoutline-color=$TEXT  \
\
--screen 1                   \
--clock                      \
--indicator                  \
--time-str="%H:%M:%S"        \
--date-str="%A, %Y-%m-%d"       \
--keylayout 1                \
\
--time-size=100 \
--date-size=24 \
\
--radius 40                 \
--ring-width 10             \
--ind-pos="x+w/2:y+h/2+300" \
--time-pos="w/2:h/2-30"     \
--date-pos="w/2:h/2+30"     \
--verif-pos="w/2:h/2"       \
--wrong-pos="w/2:h/2"       \
--modif-pos="w/2:h-30"      \
--status-pos="w/2:h/2"      \