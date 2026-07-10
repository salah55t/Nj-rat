FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# تثبيت Wine والبيئة الرسومية
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    fluxbox \
    wine32 \
    wine64 \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# تثبيت Ngrok (اختياري، لكننا نستخدم منفذ Render مباشرة)
RUN curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | gpg --dearmor -o /etc/apt/keyrings/ngrok.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/ngrok.gpg] https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list && \
    apt-get update && apt-get install -y ngrok

WORKDIR /app

# انسخ ملف SpyNote.exe (غيّر الاسم حسب ملفك)
COPY Pro.exe /app/app.exe

EXPOSE 10000

# سكربت الإقلاع
RUN echo '#!/bin/bash\n\
Xvfb :1 -screen 0 1024x768x16 &\n\
export DISPLAY=:1\n\
sleep 3\n\
fluxbox &\n\
x11vnc -forever -shared -nopw -display :1 -rfbport 5900 -bg -o /app/x11vnc.log\n\
sleep 2\n\
wine /app/app.exe 2>&1 | tee /app/wine.log &\n\
websockify --web /usr/share/novnc/ 10000 localhost:5900\n\
' > /app/start.sh && chmod +x /app/start.sh

CMD ["/app/start.sh"]
