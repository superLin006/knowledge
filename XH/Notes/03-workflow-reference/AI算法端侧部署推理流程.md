# RKNN 文件在硬件上推理步骤

> Windows 宿主机 + RK3576 Android 设备，通过 ADB 推送并运行。

---

## 通用流程

```
推送文件 → 进入设备 shell → 设置权限 + 库路径 → 运行
```

---

## 步骤 1：推送文件到设备

在 Windows PowerShell 的 `platform-tools` 目录下操作：

```powershell
cd C:\Users\HP\Desktop\platform-tools-latest-windows\platform-tools

# 确认设备在线
.\adb.exe devices

# 推送整个 demo 目录
.\adb.exe push rknn_whisper_demo /data/local/tmp/
```

---

## 步骤 2：进入设备 Shell，设置权限和库路径

```bash
.\adb.exe shell
cd /data/local/tmp/rknn_whisper_demo

# 设置可执行权限
chmod +x ./rknn_whisper_demo
chmod +x ./rknn_whisper_demo_6s
chmod +x ./rknn_whisper_demo_10s

# 设置库路径（关键）
export LD_LIBRARY_PATH=/data/local/tmp/rknn_whisper_demo/lib:$LD_LIBRARY_PATH
```

---

## 步骤 3：运行 Demo

**命令格式：**

```
./<可执行文件>  <encoder.rknn>  <decoder.rknn>  <语言>  <音频.wav>  <vocab.txt>  <mel_filters.txt>
```

---

## 各 Demo 快速命令参考

### Whisper

```bash
.\adb.exe push rknn_whisper_demo /data/local/tmp/
.\adb.exe shell
cd /data/local/tmp/rknn_whisper_demo
chmod +x ./rknn_whisper_demo ./rknn_whisper_demo_6s ./rknn_whisper_demo_10s ./rknn_whisper_medium_6s
export LD_LIBRARY_PATH=/data/local/tmp/rknn_whisper_demo/lib:$LD_LIBRARY_PATH

# base 6s 英文
./rknn_whisper_demo model/whisper_encoder_base_6s.rknn model/whisper_decoder_base_6s.rknn en model/test_en.wav model/vocab.txt model/mel_80_filters.txt

# base 10s 中文
./rknn_whisper_demo_10s model/whisper_encoder_base_10s.rknn model/whisper_decoder_base_10s.rknn zh model/test_zh.wav model/vocab.txt model/mel_80_filters.txt

# medium 6s
./rknn_whisper_medium_6s model/whisper_encoder_medium_6s.rknn model/whisper_decoder_medium_6s.rknn en model/test.wav model/vocab.txt model/mel_80_filters.txt
```

### Helsinki 翻译（RKNN 版）

```bash
.\adb.exe push rknn_helsinki_demo /data/local/tmp
.\adb.exe shell
cd /data/local/tmp/rknn_helsinki_demo
chmod +x ./rknn_helsinki_demo-zh-en ./rknn_helsinki_demo-en-zh ./rknn_helsinki_demo-ru-en
chmod +x ./helsinki_onnx_kv_demo_test ./rknn_helsinki_demo_cache
export LD_LIBRARY_PATH=/data/local/tmp/rknn_helsinki_demo/lib:$LD_LIBRARY_PATH

# ru-en（RKNN 模型）
./helsinki_onnx_kv_demo_test \
  ./model/encoder_model.rknn \
  ./model/decoder_model.rknn \
  ./model/decoder_with_past_model.rknn \
  ./tokenizer-ru-en/source.spm \
  ./tokenizer-ru-en/target.spm \
  ./tokenizer-ru-en/vocab.txt \
  "Hello World!" "I live in china" "I love programming"

# de-en（ONNX 模型）
./helsinki_onnx_kv_demo_test \
  ./model/encoder_model.onnx \
  ./model/decoder_model.onnx \
  ./model/decoder_with_past_model.onnx \
  ./tokenizer-de-en/source.spm \
  ./tokenizer-de-en/target.spm \
  ./tokenizer-de-en/vocab.txt \
  "hello world, i live in china."

# zh-en（文件输入）
./helsinki_onnx_kv_demo_test \
  ./model/encoder_model.onnx \
  ./model/decoder_model.onnx \
  ./model/decoder_with_past_model.onnx \
  ./tokenizer-zh-en/source.spm \
  ./tokenizer-zh-en/target.spm \
  ./tokenizer-zh-en/vocab.txt \
  --file test-en2zh.txt
```

### Helsinki 翻译（rk3588 打包版）

```bash
.\adb.exe push rk3588_android_arm64-v8a /data/local/tmp/
.\adb.exe shell
cd /data/local/tmp/rk3588_android_arm64-v8a/rknn_helsinki_demo
chmod +x ./rknn_helsinki_demo-zh-en ./rknn_helsinki_demo-en-zh
export LD_LIBRARY_PATH=/data/local/tmp/rk3588_android_arm64-v8a/rknn_helsinki_demo/lib:$LD_LIBRARY_PATH
./rknn_helsinki_demo-zh-en
```

### SenseVoice（sherpa-onnx）

```bash
.\adb.exe shell "mkdir -p /data/local/tmp/sherpa-onnx-senvoice"
.\adb.exe push sherpa-onnx-senvoice /data/local/tmp/
.\adb.exe shell
cd /data/local/tmp/sherpa-onnx-senvoice
chmod +x ./sherpa-onnx-offline
export LD_LIBRARY_PATH=/data/local/tmp/sherpa-onnx-senvoice/lib:$LD_LIBRARY_PATH

./sherpa-onnx-offline \
  --sense-voice-model=./model/model-10-seconds.rknn \
  --tokens=./model/tokens.txt \
  --provider=rknn \
  --num-threads=1 \
  ./model/example/test_zh.wav
```

### rkllm（大语言模型）

```bash
.\adb.exe shell "mkdir -p /data/local/tmp/rkllm"
.\adb.exe push rkllm /data/local/tmp/
.\adb.exe shell
cd /data/local/tmp/rkllm
chmod +x ./llm_demo
export LD_LIBRARY_PATH=/data/local/tmp/rkllm/lib:$LD_LIBRARY_PATH
sh fix_freq_rk3576.sh
export RKLLM_LOG_LEVEL=1
./llm_demo ./model/Qwen2.5-0.5B-Instruct_w4a16_RK3576.rkllm 2048 4096
# 或
./llm_demo ./model/Qwen3-1.7B-rk3576-w4a16.rkllm basic
```

---

## 日志查看（宿主机）

```bash
# 清空日志
adb logcat -c

# Whisper
adb logcat *:S WhisperJNI:I WhisperDemo:I StreamingManager:I

# Helsinki
adb logcat -s Helsinki_Translation

# sherpa-onnx 应用
adb logcat -s "sherpa-onnx-sim-asr" "HelsinkiONNXKV_JNI" "HelsinkiONNXKV" "sherpa-onnx" "SpeechPipeline" "MainActivity"

# 只看错误
adb logcat *:E

# 启动 App 并实时过滤
adb logcat -c && adb shell am start -n com.k2fsa.sherpa.onnx.simulate.streaming.asr/.MainActivity \
  && adb logcat | grep -iE "sherpa-onnx-sim-asr|sherpa-onnx|sensevoice|neuron|error|exception"
```

---

## 常见问题

| 报错 | 解决 |
|------|------|
| `error while loading shared libraries: xxx.so` | `export LD_LIBRARY_PATH=/data/local/tmp/<demo>/lib`，使用绝对路径 |
| `Permission denied` | 确认在 `/data/local/tmp` 下运行，且已 `chmod +x` |
| `RKNN runtime 版本不匹配` | lib 目录版本需与模型/SDK 版本一致（如 2.3.0），且模型针对 rk3576 转换 |
| 无法识别设备 | `.\adb.exe kill-server && .\adb.exe start-server`，检查数据线和驱动 |
| 长音频失败或截断 | base_20s 模型支持约 20s，先用 `test_en.wav` 验证 |
