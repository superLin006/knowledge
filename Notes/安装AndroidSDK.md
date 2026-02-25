安装 Android SDK

1\. 下载 Android SDK Command Line Tools

cd ~<br>wget https://dl.google.com/android/repository/commandlinetools-linux-9477386\_latest.zip

2\. 解压

mkdir -p ~/Android/Sdk/cmdline-tools<br>unzip commandlinetools-linux-9477386\_latest.zip -d ~/Android/Sdk/cmdline-tools<br>mv ~/Android/Sdk/cmdline-tools/cmdline-tools ~/Android/Sdk/cmdline-tools/latest

3\. 设置环境变量

export ANDROID\_NDK\_PATH=~/Android/Ndk/android-ndk-r18b

export ANDROID\_HOME=~/Android/Sdk<br>export PATH=$PATH:$ANDROID\_HOME/cmdline-tools/latest/bin:$ANDROID\_HOME/platform-tools

4\. 安装必要组件

sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

5\. 创建 local.properties

echo "sdk.dir=$HOME/Android/Sdk" > ~/mnt/C:/Users/HP/Desktop/project/AI-real-time-ASR-Translate-SpeakerID/SherpaOnnxSimulateStreamingAsr/local.properties

6\. 重新编译

<br>./gradlew assembleDebug

cd /mnt/c/users/hp/desktop/project/AI-real-time-ASR-Translate-SpeakerID/SherpaOnnxSimulateStreamingAsr