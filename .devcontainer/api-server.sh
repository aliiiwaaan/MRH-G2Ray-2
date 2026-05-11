#!/bin/bash

API_PORT=8081
INFO_FILE="/opt/mrh-admin/xray-info.json"

# تابع برای خواندن لینک VLESS از فایل JSON
get_vless_link() {
  if [ ! -f "$INFO_FILE" ]; then
    echo "error"
    return
  fi
  # استخراج فیلد vless_link از فایل JSON (اگر مستقیماً ذخیره شده باشد)
  # اگر چنین فیلدی وجود ندارد، لینک را از روی UUID و HOSTNAME می‌سازیم
  LINK=$(jq -r '.vless_link // ""' "$INFO_FILE" 2>/dev/null)
  if [ -n "$LINK" ]; then
    echo "$LINK"
  else
    echo "error"
  fi
}

echo "🚀 API Server روی پورت $API_PORT راه‌اندازی شد."

while true; do
  LINK=$(get_vless_link)
  if [ "$LINK" != "error" ] && [ -n "$LINK" ]; then
    RESPONSE="HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\n$LINK"
  else
    RESPONSE="HTTP/1.1 500 Internal Server Error\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\nLink not ready"
  fi
  echo -e "$RESPONSE" | nc -l -p "$API_PORT" -q 1
done
