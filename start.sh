#!/bin/bash
set -e

# 设置默认路径
: "${WETTY_BASE:=/terminal}"

# 设置 Basic Auth
if [[ -n "$BASIC_AUTH_USERNAME" && -n "$BASIC_AUTH_PASSWORD" ]]; then
  echo "$BASIC_AUTH_USERNAME:$(openssl passwd -apr1 "$BASIC_AUTH_PASSWORD")" > /etc/nginx/.htpasswd
else
  echo "❌ 必须设置 BASIC_AUTH_USERNAME 和 BASIC_AUTH_PASSWORD"
  exit 1
fi

# 渲染 nginx 配置（把路径变量替进去）
envsubst '${WETTY_BASE}' < /etc/nginx/templates/default.conf.template > /etc/nginx/sites-enabled/default

# 启动 tailscale（用户空间模式）
if [[ -n "$TAILSCALE_AUTHKEY" ]]; then
  echo "✅ 启动 tailscale..."
  tailscaled --tun=userspace-networking &
  sleep 3
  tailscale up --authkey="$TAILSCALE_AUTHKEY" --hostname="${TAILSCALE_HOSTNAME:-wetty-box}" --tun=userspace-networking
else
  echo "⚠️ 未设置 TAILSCALE_AUTHKEY，跳过 tailscale 启动"
fi

# 启动 nginx 和 wetty
nginx
wetty --port 3000 --base "$WETTY_BASE"
