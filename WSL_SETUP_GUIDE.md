# WSL + Ubuntu 安装后配置指南

## 安装状态
- WSL 2 正在安装
- Ubuntu 发行版已配置

## 安装完成后步骤

### 1. 重启电脑
安装完成后需要重启电脑。

### 2. 首次启动 Ubuntu
重启后，打开 PowerShell 或 CMD：
```powershell
wsl
```

第一次启动会要求设置：
- Ubuntu 用户名
- Ubuntu 密码

### 3. 更新 Ubuntu
```bash
sudo apt update && sudo apt upgrade -y
```

### 4. 安装必要工具
```bash
sudo apt install -y curl wget git vim nano
```

### 5. 验证 Hermes 终端
安装完成后，在 Hermes 中测试：
```
💻 $ uname -a
💻 $ df -h
💻 $ whoami
```

所有命令应该正常执行。

---

## 启动 Hermes（WSL 就绪后）

```powershell
C:\Users\tivol\hermes-agent\run.bat
```

或直接在 WSL 中运行：
```bash
cd /mnt/c/Users/tivol/hermes-agent
./venv/Scripts/hermes chat
```
