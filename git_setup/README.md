# 📦 Offline Git & Portable Setup Guide

This folder enables **100% Offline Installation** of Git on **Windows** and **Linux (Ubuntu/Debian)**, as well as running Git portably without system-wide installation.

---

## 📁 Directory Structure

```text
DZbridge/
├── git_setup/
│   ├── windows/          <-- Place Windows Git Installer (.exe / .msi) or Portable Zip here
│   │   └── Git-2.44.0-64-bit.exe (Example)
│   ├── linux/            <-- Place Ubuntu/Debian Git .deb packages here
│   │   ├── git_*.deb
│   │   ├── git-man_*.deb
│   │   └── liberror-perl_*.deb
│   └── README.md
│
└── git_system/           <-- Local Portable Git Folder
    ├── bin/
    ├── cmd/
    └── usr/
```

---

## 🚀 How Offline Installation Works

### 1. 🪟 Windows (Offline Installation)
1. Download the official Windows Git installer (e.g. `Git-2.44.0-64-bit.exe`) or Portable Git `.zip` from a connected device:
   [https://git-scm.com/download/win](https://git-scm.com/download/win)
2. Copy the `.exe` or `.zip` file into `git_setup/windows/`.
3. Launch `git+manegment.bat` (or `git+manegment.sh`) and select **Option 28: Offline Git & Portable Setup Hub**.
4. Choose **Option 1: Windows Offline Installation**. It will automatically detect and run the installer silently or interactively.

---

### 2. 🐧 Linux / Ubuntu (Offline Installation)
1. On an internet-connected Ubuntu machine, download Git and its dependencies `.deb` packages:
   ```bash
   mkdir -p git_debs && cd git_debs
   apt-get download git git-man liberror-perl
   ```
2. Copy all `.deb` files into `git_setup/linux/`.
3. Launch `./git+manegment.sh` and select **Option 28: Offline Git & Portable Setup Hub**.
4. Choose **Option 2: Linux / Ubuntu Offline Installation**. It will execute:
   `sudo dpkg -i git_setup/linux/*.deb`

---

### 3. 💼 Portable Git Mode (No System Install Needed)
If you do not want to install Git system-wide, place portable Git binaries inside `git_system/`:
- **Windows Portable Git**: Extract Portable Git zip into `git_system/` (must contain `cmd/git.exe` or `bin/git.exe`).
- **Linux Portable Git**: Place compiled Git binary or standalone package inside `git_system/bin/git`.

When `git+manegment.sh` or `git+manegment.bat` starts, it **automatically detects `git_system/`** and runs all Git commands locally without requiring root or administrator privileges!
