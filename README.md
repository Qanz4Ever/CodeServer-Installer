# Code-Server + Cloudflared Auto Setup
Installer Bash untuk **Code-Server (VS Code Web)** yang otomatis terhubung ke **Cloudflare Tunnel**  
Tanpa expose port publik, tanpa ribet setting DNS manual, dan UX interaktif berbasis terminal.

> Dibuat untuk VPS Linux (Ubuntu recommended)

---

## ✨ Fitur Utama

- ✅ Install **code-server** otomatis
- ✅ Setup **Cloudflare Tunnel** (tanpa buka port)
- ✅ DNS auto-generate via `cloudflared tunnel route dns`
- ✅ Deteksi & reuse tunnel yang sudah ada
- ✅ Handle konflik DNS (manual delete + retry)
- ✅ **Uninstaller interaktif** (pilih tunnel pakai angka)
- ✅ Skip dependency jika sudah terpasang
- ✅ UX terminal rapi (clear screen, konfirmasi input)
- ✅ Systemd **sesuai dokumentasi resmi Cloudflare** (100% stabil)

---

## 🚀 Cara Install
### Tempel Saja Code Bash Ini Di Terminal Anda Dan Tunggu
```Bash
apt install git -y
git clone https://github.com/Qanz4Ever/Code-Server-And-Cloudflared-Auto-Setup/
cd Code-Server-And-Cloudflared-Auto-Setup
chmod +x app.sh.x
sudo ./app.sh.x
```
