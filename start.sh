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

# بدء خادم VNC
x11vnc -forever -shared -nopw -display :1 -rfbport 5900 -bg -o /app/x11vnc.log

# (اختياري) ngrok - علقناه لأننا لا نحتاجه مع Render، ولكن احتفظ به مشروحاً إن أردت
# ngrok config add-authtoken Cr_3GGdkvG7pObxEzyudWvsReOI1J4
# ngrok tcp 1177 &

# تثبيت .NET Framework (مرة واحدة)
winetricks -q dotnet40 2>&1 > /app/winetricks.log &

# تشغيل التطبيق مع Wine باستخدام سطح مكتب افتراضي
export DISPLAY=:1
wine explorer /desktop=app,1024x768 /app/app.exe 2>&1 | tee /app/wine.log &

# تشغيل websockify (noVNC)
websockify --web /usr/share/novnc/ 10000 localhost:5900
