# Code-Server + Cloudflared Auto Installer

![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)
![License: Mfsavana 2.0](https://img.shields.io/badge/License-Mfsavana%202.0-yellow.svg)

Script Bash otomatis untuk instalasi, konfigurasi, dan pengelolaan **code-server** menggunakan **Cloudflare Tunnel** dengan UX interaktif, auto port detection, serta uninstall bersih.

---

## 📌 Penjelasan

Script ini dibuat untuk menyederhanakan proses instalasi **VS Code di browser (code-server)** yang diamankan menggunakan **Cloudflare Tunnel**, tanpa perlu membuka port publik secara manual.

Semua proses manual seperti install dependency, setup service, pembuatan tunnel, DNS, hingga systemd diotomatisasi dalam satu script.

---

## 🧰 Requirement

Sebelum menggunakan script ini, pastikan:

- OS: Ubuntu / Debian (atau turunan)
- Akses root (sudo)
- Domain sudah menggunakan Cloudflare DNS
- Koneksi internet aktif

Tidak membutuhkan:
- Web server (Nginx/Apache)
- SSL manual
- Port forwarding

---

## 🚀 Kegunaan

Script ini berguna untuk:

- Deploy code-server di VPS dengan cepat
- Mengamankan akses editor tanpa expose port
- Menghindari setup manual yang rawan error
- Uninstall & reinstall dengan aman
- Auto detect port kosong
- Custom subdomain & tunnel

---

## ▶️ Cara Menggunakan

### 1. Download Script Installer
```bash
wget https://example.com/install.sh -O install.sh
chmod +x install.sh
```

### 2. Jalankan Script
```bash
sudo ./install.sh
```

### 3. Ikuti Prompt
- Masukkan password code-server
- Masukkan subdomain
- Masukkan nama tunnel
- Pilih port (auto / manual / custom)

### 4. Hasil Akhir
```text
URL      : https://subdomain.domainkamu
Password : ********
Port     : 8xxx
```

### 5. Uninstall
Jalankan ulang script dan pilih menu **Uninstall**.

---

## ⚙️ Cara Kerja

1. Update sistem
2. Validasi input user
3. Deteksi port kosong
4. Install Node.js (jika belum ada)
5. Install code-server
6. Enable service code-server
7. Install cloudflared
8. Login Cloudflare
9. Buat tunnel
10. Buat DNS otomatis
11. Generate config cloudflared
12. Daftarkan systemd service
13. Jalankan semua service

---

## ❗ Bug atau Isu yang Tidak Diketahui

- DNS conflict jika subdomain sudah ada → perlu hapus manual
- Login Cloudflare membutuhkan browser
- FQDN kadang tidak terdeteksi otomatis (fallback tersedia)
- Jika range port penuh, user diminta pilih ulang

---

## 📜 Lisensi

### Apache License 2.0
Licensed under the Apache License, Version 2.0  
https://www.apache.org/licenses/LICENSE-2.0

---

### Mfsavana Lisensi 2.0
© Mfsavana  
Semua penggunaan mengikuti ketentuan Mfsavana Lisensi 2.0.
