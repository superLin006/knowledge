问题点有两个：

1.  ANDROID\_NDK\_PATH 指向的目录不存在
    
2.  系统未安装 make（导致 “CMAKE\_MAKE\_PROGRAM is not set”）
    

按下面修复：

步骤1：确认并设置正确的 NDK 路径

-   查看你机器上实际的 NDK 安装位置。如果没有安装 r18/r19，请下载其一：
    
    -   \[**r18b: https://dl.google.com/android/repository/android-ndk-r18b-linux-x86\_64.zip**\](https://r18b: https://dl.google.com/android/repository/android-ndk-r18b-linux-x86\_64.zip)
        
    -   \[**r19c: https://dl.google.com/android/repository/android-ndk-r19c-linux-x86\_64.zip**\](https://r19c: https://dl.google.com/android/repository/android-ndk-r19c-linux-x86\_64.zip)
        
-   解压到你有权限的目录，例如：
    
    -   mkdir -p ~/opts/ndk
        
    -   unzip android-ndk-r18b-linux-x86\_64.zip -d ~/Android/Ndk
        
    -   解压后路径通常是 ~/opts/ndk/android-ndk-r18b
        
-   设置环境变量并校验：
    

export ANDROID\_NDK\_PATH=~/Android/Ndk/android-ndk-r18b

-   test -d "$ANDROID\_NDK\_PATH" && echo "NDK OK" || echo "NDK MISSING"
    
-   ls $ANDROID\_NDK\_PATH/toolchains 含有 aarch64-linux-android-4.9/ 或 llvm/ 即可
    

步骤2：安装 make（以及基础构建工具）

-   在服务器（或你当前编译机）安装：
    
    -   Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y build-essential
        
    -   若仅缺 make：sudo apt-get install -y make
        
-   你已安装了 cmake 3.28，不必再装 cmake。
    

步骤3：重新执行构建

-   在 rknn\_model\_zoo 根目录：
    
    -   ./build-android.sh -t rk3576 -a arm64-v8a -d whisper -b Release
        

若仍报错，请把新的报错贴出；常见后续问题与处理：

-   找不到 ninja：脚本默认用 “Unix Makefiles”，只要有 make 就行。如果改用 Ninja，需要安装 sudo apt-get install -y ninja-build，并在环境中指定 -G Ninja（本脚本一般不需要）。
    
-   找不到编译器：确认 ANDROID\_NDK\_PATH 下有 toolchains/llvm。r18b/r19c 都有。
    
-   NDK 版本不兼容：优先用 r18b 或 r19c。更高版本可能链接 demo 失败。
    

等你把 NDK 路径和 make 安装好后再跑一次，我们继续看结果。