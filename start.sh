#!/bin/bash
Xvfb :1 -screen 0 1024x768x16 &
export DISPLAY=:1
sleep 3
fluxbox &
sleep 1
x11vnc -forever -shared -nopw -display :1 -rfbport 5900 -bg -o /app/x11vnc.log
sleep 2
ngrok config add-authtoken Cr_3GGdkvG7pObxEzyudWvsReOI1J4
ngrok tcp 1177 &
winetricks -q dotnet40 2>&1 > /app/winetricks.log &
wine /app/app.exe 2>&1 > /app/wine.log &
websockify --web /usr/share/novnc/ 10000 localhost:5900
