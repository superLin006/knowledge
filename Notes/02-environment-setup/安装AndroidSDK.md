# 安装 Android SDK

## 1. 下载 Command Line Tools

```bash
cd ~
wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
```

## 2. 解压

```bash
mkdir -p ~/Android/Sdk/cmdline-tools
unzip commandlinetools-linux-9477386_latest.zip -d ~/Android/Sdk/cmdline-tools
mv ~/Android/Sdk/cmdline-tools/cmdline-tools ~/Android/Sdk/cmdline-tools/latest
```

## 3. 设置环境变量

```bash
export ANDROID_NDK_PATH=~/Android/Ndk/android-ndk-r18b
export ANDROID_HOME=~/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
```

## 4. 安装必要组件

```bash
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

## 5. 创建 local.properties

```bash
echo "sdk.dir=$HOME/Android/Sdk" > ~/mnt/C:/Users/HP/Desktop/project/AI-real-time-ASR-Translate-SpeakerID/SherpaOnnxSimulateStreamingAsr/local.properties
```

## 6. 重新编译

```bash
cd /mnt/c/users/hp/desktop/project/AI-real-time-ASR-Translate-SpeakerID/SherpaOnnxSimulateStreamingAsr
./gradlew assembleDebug
```
