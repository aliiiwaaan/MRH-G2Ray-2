#!/bin/bash

TIMEOUT=300  # ۵ دقیقه (۳۰۰ ثانیه)
LAST_ACTIVITY=$(date +%s)

echo "✅ Idle Monitor فعال شد. در صورت عدم فعالیت به مدت ۵ دقیقه، کداسپیس متوقف می‌شود."

while true; do
  # بررسی کانکشن‌های فعال روی پورت ۴۴۳ (پروکسی VLESS) یا ۸۰۸۰ (پنل مدیریت)
  ACTIVE_CONN=$(netstat -tn 2>/dev/null | grep -E ':(443|8080).*ESTABLISHED' | wc -l)

  if [ "$ACTIVE_CONN" -gt 0 ]; then
    # اگر کانکشن فعالی وجود دارد، تایمر را ریست کن
    LAST_ACTIVITY=$(date +%s)
  else
    NOW=$(date +%s)
    IDLE_TIME=$((NOW - LAST_ACTIVITY))
    if [ "$IDLE_TIME" -ge "$TIMEOUT" ]; then
      echo "❌ هیچ کانکشن فعالی برای ۵ دقیقه وجود نداشت. در حال توقف کداسپیس برای ذخیره سهمیه..."
      gh codespace stop -c "$CODESPACE_NAME"
      break
    fi
  fi

  sleep 30  # هر ۳۰ ثانیه یکبار بررس کن
done
