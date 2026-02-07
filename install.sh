#!/bin/bash
set -e

# All Code Created By Mfsavana
# Don't Use And Steal Code
# License Apache License 2.0
# Credit Mfsavana © 2026

# ========= COLOR =========
G="\e[32m"; Y="\e[33m"; R="\e[31m"; B="\e[34m"; C="\e[36m"; N="\e[0m"
log()  { echo -e "${C}$1${N}"; }
ok()   { echo -e "${G}$1${N}"; }
warn() { echo -e "${Y}$1${N}"; }
err()  { echo -e "${R}$1${N}"; }

clear_if(){ clear; }

[[ $EUID -ne 0 ]] && err "Run as root" && exit 1

# =========================
# PORT DETECTOR
# =========================
find_free_port() {
  local start="$1"
  local end="$2"

  for ((port=start; port<=end; port++)); do
    if ! ss -tuln 2>/dev/null | awk '{print $5}' | grep -q ":$port\$"; then
      echo "$port"
      return 0
    fi
  done

  return 1
}

clear
echo -e "${B}========================================${N}"
echo -e "${B} Code-Server + Cloudflared Setup${N}"
echo -e "${B}========================================${N}"
echo
echo "1) Install / Setup"
echo "2) Uninstall"
echo
read -p "> " MODE
clear_if

# =========================
# UNINSTALL (INTERAKTIF)
# =========================
if [[ "$MODE" == "2" ]]; then
  DID_UNINSTALL=false
  log "Checking existing tunnels..."

  if command -v cloudflared >/dev/null 2>&1 && [[ -d /root/.cloudflared ]]; then
    mapfile -t TUNNELS < <(cloudflared tunnel list | awk 'NR>1 {print $1" "$2}')
    if [[ ${#TUNNELS[@]} -gt 0 ]]; then
      echo
      echo "Available tunnels:"
      i=1
      for t in "${TUNNELS[@]}"; do echo "  [$i] $t"; ((i++)); done
      echo
      read -p "Delete a tunnel? (number / ENTER to skip): " PICK
      if [[ "$PICK" =~ ^[0-9]+$ && "$PICK" -ge 1 && "$PICK" -le ${#TUNNELS[@]} ]]; then
        TID=$(echo "${TUNNELS[$((PICK-1))]}" | awk '{print $1}')
        TNAME=$(echo "${TUNNELS[$((PICK-1))]}" | awk '{print $2}')

        systemctl stop cloudflared 2>/dev/null || true
        systemctl disable cloudflared 2>/dev/null || true
        pkill -f cloudflared || true
        sleep 1

        cloudflared tunnel cleanup "$TNAME" 2>/dev/null || true
        cloudflared tunnel delete "$TID"
        DID_UNINSTALL=true
        ok "Tunnel deleted"
      fi
    else
      warn "No tunnels found"
    fi
  else
    warn "cloudflared not installed or config missing"
  fi

  systemctl stop cloudflared code-server@root 2>/dev/null || true
  systemctl disable cloudflared code-server@root 2>/dev/null || true

  rm -rf /root/.cloudflared \
         /root/.config/code-server \
         /etc/systemd/system/cloudflared.service

  systemctl daemon-reload

  [[ "$DID_UNINSTALL" == true ]] && ok "Uninstalled" || warn "Nothing to uninstall"
  exit 0
fi

# =========================
# INPUT (WITH VALIDATION)
# =========================
while true; do
  while true; do read -p "Code-server password: " CS_PASS; [[ -n "$CS_PASS" ]] && break || warn "Password cannot be empty"; done; clear_if
  while true; do read -p "Subdomain: " SUB; [[ -n "$SUB" ]] && break || warn "Subdomain cannot be empty"; done; clear_if
  while true; do read -p "Tunnel name: " TUNNEL; [[ -n "$TUNNEL" ]] && break || warn "Tunnel name cannot be empty"; done; clear_if

  echo -e "${B}========================================${N}"
  echo -e "${B} Confirm Configuration${N}"
  echo -e "${B}========================================${N}"
  echo
  echo -e "${C}Password :${N} ${CS_PASS}"
  echo -e "${C}Subdomain:${N} ${SUB}"
  echo -e "${C}Tunnel   :${N} ${TUNNEL}"
  echo
  echo "(y) Continue"
  echo "(n) Re-enter"
  echo "(c) Cancel"
  read -p "> " CFM

  case "$CFM" in
    y|Y) break ;;
    n|N) clear_if ;;
    c|C) err "Cancelled by user"; exit 0 ;;
    *) warn "Invalid choice"; sleep 1 ;;
  esac
done

# =========================
# PORT SELECTION
# =========================
while true; do
  clear_if
  echo -e "${B}========================================${N}"
  echo -e "${B} Port Configuration${N}"
  echo -e "${B}========================================${N}"
  echo
  echo "1) Auto detect (default: 8000-9000)"
  echo "2) Manual input"
  echo "3) Custom range auto scan"
  echo
  read -p "> " PORT_SEL

  case "$PORT_SEL" in
    1)
      PORT=$(find_free_port 8000 9000)
      [[ -n "$PORT" ]] && ok "Using port: $PORT" && break || warn "No free port in range"
      ;;
    2)
      read -p "Enter port: " PORT
      ss -tuln | awk '{print $5}' | grep -q ":$PORT\$" && warn "Port in use" || break
      ;;
    3)
      read -p "Start range: " RS
      read -p "End range  : " RE
      [[ "$RS" =~ ^[0-9]+$ && "$RE" =~ ^[0-9]+$ && "$RS" -le "$RE" ]] || { warn "Invalid range"; continue; }
      PORT=$(find_free_port "$RS" "$RE")
      [[ -n "$PORT" ]] && ok "Using port: $PORT" && break || warn "No free port in that range"
      ;;
    *)
      warn "Invalid choice"
      ;;
  esac
done
clear_if

# =========================
# SYSTEM + INSTALLS
# =========================
log "Updating system"
apt update -y

if ! command -v node >/dev/null; then log "Installing Node.js LTS"; curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt install -y nodejs; else ok "Node.js already installed"; fi
if ! command -v code-server >/dev/null; then log "Installing code-server"; curl -fsSL https://code-server.dev/install.sh | sh; else ok "code-server already installed"; fi

mkdir -p /root/.config/code-server
cat > /root/.config/code-server/config.yaml <<EOF
bind-addr: 0.0.0.0:${PORT}
auth: password
password: ${CS_PASS}
cert: false
EOF
systemctl enable --now code-server@root

if ! command -v cloudflared >/dev/null; then log "Installing cloudflared"; curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && chmod +x /usr/local/bin/cloudflared; else ok "cloudflared already installed"; fi

log "Cloudflare login"
cloudflared tunnel login
clear_if

# =========================
# TUNNEL
# =========================
if cloudflared tunnel list | awk '{print $2}' | grep -qx "$TUNNEL"; then warn "Tunnel exists, reusing"; else log "Creating tunnel"; cloudflared tunnel create "$TUNNEL"; fi
TUNNEL_ID=$(cloudflared tunnel list | awk -v t="$TUNNEL" '$2==t{print $1}')

# =========================
# DNS HANDLING
# =========================
while true; do
  log "Creating DNS record"
  DNS_OUTPUT=$(cloudflared tunnel route dns "$TUNNEL" "$SUB" 2>&1 || true)
  echo "$DNS_OUTPUT"

  FQDN=$(echo "$DNS_OUTPUT" | grep -oE '[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | head -n1)
  [[ -n "$FQDN" ]] && break

  if echo "$DNS_OUTPUT" | grep -qi "already exists"; then
    warn "DNS exists → Delete manually in Cloudflare dashboard"
    read -p "Press ENTER to retry (or q to abort): " X
    [[ "$X" == "q" ]] && err "Aborted" && exit 1
    clear_if
  else
    err "DNS creation failed"
    exit 1
  fi
done

# =========================
# FQDN FALLBACK
# =========================
if [[ -z "$FQDN" && -f /root/.cloudflared/cert.pem ]]; then
  FQDN=$(openssl x509 -in /root/.cloudflared/cert.pem -noout -text | grep -oE 'DNS:[^,]+' | head -n1 | sed 's/DNS://')
fi
if [[ -z "$FQDN" ]]; then read -p "FQDN not detected, enter manually: " FQDN; fi

# =========================
# CLOUDLFARED CONFIG
# =========================
cat > /root/.cloudflared/config.yml <<EOF
tunnel: ${TUNNEL_ID}
credentials-file: /root/.cloudflared/${TUNNEL_ID}.json

ingress:
  - hostname: ${FQDN}
    service: http://localhost:${PORT}
  - service: http_status:404
EOF

# =========================
# SYSTEMD SERVICE
# =========================
cat > /etc/systemd/system/cloudflared.service <<EOF
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
TimeoutStartSec=0
Type=simple
ExecStart=/usr/local/bin/cloudflared tunnel run ${TUNNEL}
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now cloudflared

# =========================
# FINAL OUTPUT
# =========================
clear
echo -e "${B}========================================${N}"
echo -e "${B} Setup Completed${N}"
echo -e "${B}========================================${N}"
echo
echo -e "${C}URL      :${N} https://${FQDN}"
echo -e "${C}Password :${N} ${CS_PASS}"
echo -e "${C}Port     :${N} ${PORT}"
echo
ok "Code-server is ready"
