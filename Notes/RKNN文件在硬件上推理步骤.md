以下是在笔记本（Windows）上，从已下载好的 rknn\_whisper\_demo 目录开始，到设备上运行的完整步骤：

-   你已经下载到了一个文件夹 rknn\_whisper\_demo（里面应包含 bin 或可执行文件、lib、model、以及测试音频）。
    
-   你的 ADB 已经在 PowerShell 当前目录可用（你之前在 platform-tools 里）。
    

### **步骤1：把 rknn\_whisper\_demo 放到 platform-tools 同级或任意易访问位置**

-   为了方便操作，你可以把 rknn\_whisper\_demo 整个文件夹复制到 C:\\Users\\HP\\Downloads\\platform-tools-latest-windows\\platform-tools\\
    
-   最终在该目录下能看到：
    
    -   adb.exe
        
    -   rknn\_whisper\_demo\\
        

### 步骤2：用 ADB 推送到设备

打开 PowerShell，切到 platform-tools 目录：

```text
cd  C:\Users\HP\Desktop\platform-tools-latest-windows\platform-tools
```

-   确认设备在线：
    

```text
.\adb.exe devices
```

-   创建目标目录并推送：
    

```text
.\adb.exe shell "mkdir -p /data/local/tmp/rknn_whisper_demo"
```

```text
.\adb.exe push rknn_whisper_demo /data/local/tmp/
```

### 步骤3：进入设备端、设置权限和库路径

-   进入 shell：
    

```text
.\adb.exe devices
.\adb.exe shell "mkdir -p /data/local/tmp/rknn_whisper_demo"
.\adb.exe push rknn_whisper_demo /data/local/tmp/
.\adb.exe shell
cd /data/local/tmp/rknn_helsinki_demo
chmod +x ./rknn_helsinki_demo
export LD_LIBRARY_PATH=/data/local/tmp/rknn_helsinki_demo/lib:$LD_LIBRARY_PATH
./rknn_whisper_demo_6s model/whisper_encoder_base_6s.rknn model/whisper_decoder_base_6s.rknn zh  model/test_zh.wav  model/vocab.txt  model/mel_80_filters.txt

```

-   切换目录：
    

```text
cd /data/local/tmp/rknn_whisper_demo
```

-   给可执行文件加权限：
    

如果可执行在当前目录：

```text
chmod +x ./rknn_whisper_demo
chmod +x ./rknn_whisper_demo_6s
chmod +x ./rknn_whisper_demo_10s
```

如果可执行在 bin 目录：

```text
chmod +x ./bin/rknn_whisper_demo
```

-   **设置库路径（很关键）：**
    

```text
export LD_LIBRARY_PATH=/data/local/tmp/rknn_whisper_demo/lib:$LD_LIBRARY_PATH
```

### 步骤4：运行 demo

-   如果可执行在当前目录：
    

```text
./rknn_whisper_demo_10s model/whisper_encoder_base_10s.rknn model/whisper_decoder_base_10s.rknn zh  model/test_zh.wav  model/vocab.txt  model/mel_80_filters.txt

```

-   如果在 bin 目录：
    

```text
./bin/rknn_whisper_demo model/whisper_encoder_base_20s.rknn model/whisper_decoder_base_20s.rknn en model/test_en.wav  model/vocab.txt  model/mel_80_filters.txt
```

### 使用参数说明：

<br>         ***./xxx   执行的脚本名称***

***model/xxx\_encoder\_xxx.rnkk    编码器***

***model/xxx\_decoder\_xxx.rnkk   解码器***

***language   ASR识别的目标语言（en/zh/ko/ja/..）***

***path/xxx\_.wav   音频文件路径***

成功表现

-   终端会打印初始化 RKNN 成功、加载模型成功、推理进度，以及最终识别出的文本。
    

常见问题与快速修复

-   报错 “error while loading shared libraries: xxx.so”：
    
    -   说明 LD\_LIBRARY\_PATH 未生效。请使用绝对路径重新设置：
        
        -   export LD\_LIBRARY\_PATH=/data/local/tmp/rknn\_whisper\_demo/lib
            
-   报错 “Permission denied”：
    
    -   确认在 /data/local/tmp 下运行，且已 chmod +x 可执行文件。
        
-   报错 “RKNN runtime 版本不匹配”：
    
    -   你推送的 lib 目录需与模型/SDK版本一致（例如 2.3.0），并且模型是针对 rk3576 转换生成的。
        
-   无法识别设备：
    
    -   用 .\\adb.exe kill-server && .\\adb.exe start-server
        
    -   检查数据线、驱动、以及 .\\adb.exe devices 输出是否为 device 状态。
        
-   长音频失败或截断：
    
    -   base\_20s 模型支持约 20 秒，请先用 test\_en.wav 验证。
        

如果你希望识别中文或自己的音频：

-   中文模型：换用对应的中文/多语言 rknn 模型，并把命令里的 en 改成 zh 或相应语言代码。
    
-   自己的音频：把你的 wav 文件放进 /data/local/tmp/rknn\_whisper\_demo/model 或任意路径，然后把命令最后一个参数改为该文件的路径。
    

你先按以上步骤执行，若有报错，把完整输出贴给我，我会继续帮你定位

### 清理日志 + 查看日志（宿主机）

```text
adb logcat -c
adb logcat *:S WhisperJNI:I WhisperDemo:I StreamingManager:I

adb logcat -s Helsinki_Translation

adb logcat -s "sherpa-onnx-sim-asr"  "HelsinkiONNXKV_JNI"  "HelsinkiONNXKV" "sherpa-onnx"  "SpeechPipeline"  "MainActivity"  "SpeechPipeline-JNI"  

"VoiceAssistant"  “VoiceAssistantManager” “DeepSeekClient”  "IntentManager"  "AudioPlayer"

adb logcat *:E
 
 adb logcat -c && adb shell am start -n com.k2fsa.sherpa.onnx.simulate.streaming.asr/.MainActivity && adb logcat | grep -iE "sherpa-onnx-sim-asr|sherpa-onnx|sensevoice|neuron|error|exception"
```

我说这个全国第一城市，上一次遭受的同类危机那恐怕还得追溯到上海堡垒时期，毕竟这些都是改改们惹的祸，当然要说因此导致上海乃至全国人民的团结恐怕就得是淞沪会战了，这不是夸张

\========== Final Transcription ========== 那恐怕还得追溯到上海保冷时期毕竟这些都是该一个人的货要说因此导致上海乃致全国人民的妨礼这也不是花粮

```text
.\adb.exe push rknn_whisper_demo /data/local/tmp/
.\adb.exe shell
cd /data/local/tmp/rknn_whisper_demo
chmod +x ./rknn_whisper_demo
chmod +x ./rknn_whisper_demo_6s
chmod +x ./rknn_whisper_demo_10s
chmod +x ./rknn_whisper_medium_6s
export LD_LIBRARY_PATH=/data/local/tmp/rknn_whisper_demo/lib:$LD_LIBRARY_PATH
./rknn_whisper_demo model/whisper_encoder_base_6s.rknn model/whisper_decoder_base_6s.rknn en  model/test_en.wav  model/vocab.txt  model/mel_80_filters.txt


./rknn_whisper_medium_6s model/whisper_encoder_medium_6s.rknn model/whisper_decoder_medium_6s.rknn en  model/test.wav  model/vocab.txt  model/mel_80_filters.txt
   
```

```text
.\adb.exe push rknn_helsinki_demo/model/opus_mt_en_zh_encoder_int8.rknn /data/local/tmp/rknn_helsinki_demo/model/

.\adb.exe push rknn_helsinki_demo /data/local/tmp
.\adb.exe shell
cd /data/local/tmp/rknn_helsinki_demo
chmod +x ./rknn_helsinki_demo-zh-en
chmod +x ./rknn_helsinki_demo-en-zh
chmod +x ./rknn_helsinki_demo-ru-en
chmod +x ./helsinki_onnx_kv_demo_test
chmod +x ./rknn_helsinki_demo_cache
export LD_LIBRARY_PATH=/data/local/tmp/rknn_helsinki_demo/lib:$LD_LIBRARY_PATH
./helsinki_onnx_kv_demo_test ./model/encoder_model.rknn ./model/decoder_model.rknn  ./model/decoder_with_past_model.rknn ./tokenizer-ru-en/source.spm  ./tokenizer-ru-en/target.spm  ./tokenizer-ru-en/vocab.txt 
"The evaluation measures cold-start performance when models load from disk." "The framework supports speculative decoding to accelerate autoregressive generation." "The documentary investigates labor conditions in the global AI data labeling industry."
 "Hello World!" "I live in china"  "I love programming"  "Complete the selection of a multilingual ASR model, supporting local deployment on RK chips to enable low-latency real-time speech recognition."

--file test-en2zh.txt
.\adb.exe push rknn_helsinki_demo /data/local/tmp
.\adb.exe shell
cd /data/local/tmp/rknn_helsinki_demo
chmod +x ./rknn_helsinki_demo-de-en
chmod +x ./rknn_helsinki_demo-es-zh
chmod +x ./helsinki_onnx_kv_demo_test
chmod +x ./rknn_helsinki_demo_cache
export LD_LIBRARY_PATH=/data/local/tmp/rknn_helsinki_demo/lib:$LD_LIBRARY_PATH
./helsinki_onnx_kv_demo_test  ./model/encoder_model.onnx ./model/decoder_model.onnx  ./model/decoder_with_past_model.onnx ./tokenizer-de-en/source.spm  ./tokenizer-de-en/target.spm  ./tokenizer-de-en/vocab.txt  "hello world, i live in china and i love programming."  "Complete the selection of a multilingual ASR model, supporting local deployment on RK chips to enable low-latency real-time speech recognition."  "Hello, how are you?"  "Machine learning is a subset of artificial intelligence." "The quick brown fox jumps over the lazy dog."  "I love programming in python" "climate change is one of the biggest challenges facing humanity." "Hello, world! Happy birthday, my dear friend!" "I’m feeling great today, what a wonderful day. How are you today?"  "When facing a problem, respond proactively and think independently first." "I’d like to buy osmanthus flowers and carry wine as before, yet it’s never quite the same as when I was young."  "Select a multilingual text translation model, deploying it locally on RK chips, and achieve real-time translation." "Complete the selection of a multilingual ASR model, supporting local deployment on RK chips to enable low-latency real-time speech recognition." "The imperial avenue is graced by a drizzle soft as cream;From afar, grass seems green, yet up close, none is seen.This is truly springtime’s finest hour—Far surpassing willows veiled in mist that fill the capital."


.\adb.exe push rknn_helsinki_demo /data/local/tmp
.\adb.exe shell
cd /data/local/tmp/rknn_helsinki_demo
chmod +x ./rknn_helsinki_demo-zh-en
chmod +x ./rknn_helsinki_demo-en-zh
chmod +x ./helsinki_onnx_kv_demo_test
chmod +x ./rknn_helsinki_demo_cache
export LD_LIBRARY_PATH=/data/local/tmp/rknn_helsinki_demo/lib:$LD_LIBRARY_PATH
./helsinki_onnx_kv_demo_test  ./model/encoder_model.onnx ./model/decoder_model.onnx  ./model/decoder_with_past_model.onnx ./tokenizer-zh-en/source.spm  ./tokenizer-zh-en/target.spm  ./tokenizer-zh-en/vocab.txt  --file test-en2zh.txt
   "你好，世界！" "生日快乐，我亲爱的朋友！" "欲买桂花同载酒，终不似少年游。" "遇到问题，要积极应对，先独立思考。""我今天感觉很棒，多么美好的一天！你今天好吗？" "选择多语言文本翻译模型，RK芯片本地部署，实现实时翻译。" "天街小雨润如酥，草色遥看近却无。最是一年春好处，绝胜烟柳满皇都。" "完成多语言ASR模型选择，支持RK芯片的本地部署，实现低延迟的实时语音识别。" "我今天感觉很棒，多么美好的一天！你今天好吗？选择多语言文本翻译模型，RK芯片本地部署，实现实时翻译。"  "亲爱的恋人，有话我们好好说，不要冷战，闹脾气好不好，我带你去吃好吃的！好不好？"  "今天天气很好，阳光洒在身上，暖洋洋的，我心情很愉悦，感觉棒极了，多么美好的一天！你今天有空吗？我想和你去公园逛逛，呼吸新鲜空气，好好感受一下轻松愉快的周末生活，对了你喜欢吃鱼吗，我会做烤鱼哦，晚上回来，让你尝尝我的手艺。"
```

```text
.\adb.exe push rk3588_android_arm64-v8a /data/local/tmp/
.\adb.exe shell
cd /data/local/tmp/rk3588_android_arm64-v8a/rknn_helsinki_demo
chmod +x ./rknn_helsinki_demo-zh-en
chmod +x ./rknn_helsinki_demo-en-zh
export LD_LIBRARY_PATH=/data/local/tmp/rk3588_android_arm64-v8a/rknn_helsinki_demo/lib:$LD_LIBRARY_PATH
./rknn_helsinki_demo-zh-en
```

```text
.\adb.exe push rk3588_android_arm64-v8a /data/local/tmp/
.\adb.exe shell
cd /data/local/tmp/rk3588_android_arm64-v8a/rknn_whisper_demo
chmod +x ./rknn_whisper_demo_6s
chmod +x ./rknn_whisper_demo_10s
export LD_LIBRARY_PATH=/data/local/tmp/rk3588_android_arm64-v8a/rknn_whisper_demo/lib:$LD_LIBRARY_PATH
./rknn_whisper_demo_6s model/whisper_encoder_base_6s.rknn model/whisper_decoder_base_6s.rknn zh  model/test_zh.wav  model/vocab.txt  model/mel_80_filters.txt
```

senvoice<br>

```text
.\adb.exe shell "mkdir -p /data/local/tmp/sherpa-onnx-senvoice"
.\adb.exe push sherpa-onnx-senvoice /data/local/tmp/
.\adb.exe shell
cd /data/local/tmp/sherpa-onnx-senvoice
chmod +x ./sherpa-onnx-offline
export LD_LIBRARY_PATH=/data/local/tmp/sherpa-onnx-senvoice/lib:$LD_LIBRARY_PATH
./sherpa-onnx-offline  --sense-voice-model=./model/model-10-seconds.rknn  --tokens=./model/tokens.txt  --provider=rknn  --num-threads=1 ./model/example/test_zh.wav

```

### rkllm

```text
.\adb.exe shell "mkdir -p /data/local/tmp/rkllm"
.\adb.exe push rkllm /data/local/tmp/
.\adb.exe shell
cd /data/local/tmp/rkllm
chmod +x ./llm_demo
export LD_LIBRARY_PATH=/data/local/tmp/rkllm/lib:$LD_LIBRARY_PATH
sh fix_freq_rk3576.sh
export RKLLM_LOG_LEVEL=1
./llm_demo ./model/Qwen2.5-0.5B-Instruct_w4a16_RK3576.rkllm  2048 4096
Qwen3-1.7B-rk3576-w4a16.rkllm basic
```