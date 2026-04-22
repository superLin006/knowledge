# 安装 NDK 与 make

## 问题背景

两个常见报错原因：

1. `ANDROID_NDK_PATH` 指向的目录不存在
2. 系统未安装 make（导致 `CMAKE_MAKE_PROGRAM is not set`）

---

## 步骤 1：确认并设置正确的 NDK 路径

下载 r18b 或 r19c（优先用 r18b，更高版本可能链接 demo 失败）：

- r18b: https://dl.google.com/android/repository/android-ndk-r18b-linux-x86_64.zip
- r19c: https://dl.google.com/android/repository/android-ndk-r19c-linux-x86_64.zip

解压并设置环境变量：

```bash
mkdir -p ~/Android/Ndk
unzip android-ndk-r18b-linux-x86_64.zip -d ~/Android/Ndk
export ANDROID_NDK_PATH=~/Android/Ndk/android-ndk-r18b
```

校验：

```bash
test -d "$ANDROID_NDK_PATH" && echo "NDK OK" || echo "NDK MISSING"
ls $ANDROID_NDK_PATH/toolchains   # 应包含 llvm/ 或 aarch64-linux-android-4.9/
```

---

## 步骤 2：安装 make

```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y build-essential

# 仅缺 make
sudo apt-get install -y make
```

> cmake 3.28 已安装则无需重装。

---

## 步骤 3：重新执行构建

```bash
# 在 rknn_model_zoo 根目录
./build-android.sh -t rk3576 -a arm64-v8a -d whisper -b Release
```

---

## 常见后续问题

| 报错 | 解决 |
|------|------|
| 找不到 ninja | 脚本默认用 Unix Makefiles，有 make 即可；需要 Ninja 则 `apt install ninja-build` |
| 找不到编译器 | 确认 `$ANDROID_NDK_PATH/toolchains/llvm` 存在 |
| NDK 版本不兼容 | 优先使用 r18b 或 r19c |
