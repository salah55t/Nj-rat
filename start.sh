#!/bin/bash

# بدء خادم العرض الافتراضي
Xvfb :1 -screen 0 1024x768x16 &
XVFB_PID=$!
export DISPLAY=:1

# انتظار حتى يصبح Xvfb جاهزاً
for i in {1..10}; do
    xdpyinfo -display :1 >/dev/null 2>&1 && break
    echo "Waiting for Xvfb... ($i)"
    sleep 1
done

# بدء مدير النوافذ
fluxbox &

# بدء خادم VNC للوصول عن بعد
x11vnc -forever -shared -nopw -display :1 -rfbport 5900 -bg -o /app/x11vnc.log

# تشغيل ngrok (غير ضروري للعرض لكن نضعه)
ngrok config add-authtoken Cr_3GGdkvG7pObxEzyudWvsReOI1J4
ngrok tcp 1177 &

# تثبيت .NET Framework (مرة واحدة)
winetricks -q dotnet40 2>&1 > /app/winetricks.log &

# تشغيل التطبيق مع Wine (مع تعيين DISPLAY مرة أخرى للتأكيد)
export DISPLAY=:1
wine /app/app.exe 2>&1 | tee /app/wine.log &

# تشغيل websockify لربط noVNC بالمنفذ 10000
websockify --web /usr/share/novnc/ 10000 localhost:5900
