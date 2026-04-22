# RK-NPU 算法移植提示词

> RK3576 平台，统一三步流程：Python 端 → C++ 端 → Android 端
> 转换链：`.pt/.pth → .onnx → .rknn`

---

## EDSR、RCAN 移植到 RK3576 NPU

### 1. 上下文

**目标**：EDSR、RCAN 移植到 RK3576 芯片的 NPU，推送到 Android 设备完成测试。

**历史与计划**：分三个大步骤。

**第一步（Python 端）**：pt → onnx → rknn

- 每个转换节点完成后单独测试（`.pt` 和 `.onnx` 都推理一遍，检查输出），正确后再进行下一节点（rknn 除外）
- 参考 yolov8 的目录格式重组，工作主要在 Python 端

**第二步（C++ 端）**：将 Python 推理代码转化为 C++ 推理代码

- 参考 yolov8 项目的 C++ 部分，了解 RKNN 接口调用，使用正确的 RKNN API

**第三步（Android 端）**：编译 C++ 代码（针对 RK3576 平台），推送到 Android 设备完成推理测试

**目前的环境**：conda 环境 `rknn310`，python=3.10

| 资源 | 路径 |
|------|------|
| RKNN SDK（2.3.0）| 已集成在 conda 环境 `rknn310` |
| Android NDK | `/home/xh/Android/Ndk/android-ndk-r18b` |
| Android SDK | `/home/xh/Android/Sdk` |
| OnnxRuntime | `/home/xh/Android/OnnxRuntime/onnxruntime-android-1.17.1` |
| 第三方库 | `/home/xh/projects/rknn_model_zoo/3rdparty` |
| RKNN 算子支持列表 | `/home/xh/projects/rknn_model_zoo/doc/RKNNToolKit2_OP_Support-2.3.0.md` |

### 2. 当前意图

1. 参考 yolov8 项目，新建目录结构，检查环境，安装依赖，测试 `.pt` 格式正常推理输出
2. 先完成 Python 端工作，有问题分析解决

### 3. 注意事项

1. onnx 及 rknn 格式只负责推理，前处理和后处理需分离出来单独处理
2. 如果模型导出失败，可能是算子不支持，需自定义模型结构或修改算子（参考 sensevoiceSmall 案例：`/home/xh/projects/sherpa-onnx-2025-1217/scripts/sense-voice/rknn`）
3. RK NPU 不支持动态形状，转 onnx 时需固定输入形状（510 × 339）

---

## RCAN 移植到 RK3576 NPU

### 1. 上下文

**目标**：RCAN 移植到 RK3576 芯片的 NPU，推送到 Android 设备完成测试。

**历史与计划**：分三个大步骤，流程同 EDSR，参考 edsr 目录格式重组。

**目前的环境**：conda 环境 `rknn310`，python=3.10（资源目录同 EDSR）

### 2. 当前意图

1. 参考 edsr 项目，新建目录结构，检查环境，安装依赖，测试 `.pt` 正常推理输出
2. 先完成 Python 端工作，有问题分析解决

### 3. 注意事项

同 EDSR，固定输入形状为 256 × 256。

---

## SwinIR 移植到 RK3576 NPU

### 1. 上下文

**目标**：SwinIR 移植到 RK3576 芯片的 NPU，推送到 Android 设备完成测试。

**历史与计划**：分三个大步骤，转换链：`.pth → onnx → rknn`，参考 yolov8 目录格式。

**目前的环境**：conda 环境 `rknn310`，python=3.10（资源目录同 EDSR）

### 2. 当前意图

1. 参考 yolov8 项目，新建目录结构，检查环境，安装依赖，测试 `.pth` 格式正常推理输出
2. 先完成 Python 端工作，有问题分析解决

### 3. 注意事项

1. onnx 及 rknn 格式只负责推理，前后处理分离
2. 算子不支持时需自定义模型结构（参考 sensevoiceSmall 案例）
3. 固定输入形状：SwinIR 输入尺寸须为 `window_size`（通常为 8）的整数倍，建议使用 (1, 3, 512, 512)

---

## Real-ESRGAN 移植到 RK3576 NPU

### 1. 上下文

**目标**：Real-ESRGAN 移植到 RK3576 芯片的 NPU，推送到 Android 设备完成测试。

**历史与计划**：

**第一步（Python 端）**：`.pth → onnx → rknn`（**已完成**）

- 可参考 rk realesrgan 项目（含原始模型架构定义、权重、测试图片及推理代码）
- `test_pytorch.py` 可直接复制 rk 项目的版本
- 参考 rcan 目录格式重组

**第二步（C++ 端）**：将 Python 推理代码转换为 C++（**待完成**）

- 参考 rcan 项目 C++ 部分，使用正确的 RKNN API

**第三步（Android 端）**：编译并推送到 Android 设备完成推理测试（**待完成**）

**目前的环境**：conda 环境 `rknn310`，python=3.10（资源目录同 EDSR）

### 2. 当前意图

1. 检查 Python 端代码及工作是否正常，测试图片：`MTK/superResolution/rcan/mtk/test_data/input_510x339.png`
2. Python 端确认无问题后，给出下一步指令

### 3. 注意事项

1. onnx 及 rknn 格式只负责推理，前后处理分离
2. 算子不支持时需自定义模型结构（参考 sensevoiceSmall 案例）
3. 固定输入形状：Real-ESRGAN 无特殊限制，建议使用 510 × 339
4. Real-ESRGAN 基于 RRDB（纯 CNN 架构），主要算子（Conv2d、LeakyReLU、Add）RKNN 支持良好；需注意 PixelShuffle 和 LeakyReLU，导出 ONNX 前需确认
5. 前处理：归一化到 [0, 1]；后处理：clip 到 [0, 1] 后 × 255 转回 uint8，均在模型外部实现

## Helsinki 翻译模型移植到 RK3576

### 移植方案

分五个步骤完成从 PyTorch 权重到 RK3576 NPU 端到端推理的完整流程。

**第一步**：Python 环境下分别导出 Encoder 和 Decoder 的 ONNX 格式（注意 RK 平台适配）

**第二步**：Python 环境下用导出的 encoder.onnx + decoder.onnx 协同推理，测试完整翻译句子（en→zh），验证模型可用性

**第三步**：在 Linux 上完成 encoder.onnx + decoder.onnx → rknn 格式转换

**第四步**：根据 Helsinki 官方 Python 推理代码，编写 Android C++ 推理代码。用简单测试 token 完成 encoder.rknn + decoder.rknn 在 RK3576 上的协同推理（编码+解码），验证 rknn 模型及 C++ 推理代码可用性

**第五步**：实现 C++ 端 tokenizer，根据导出的 vocab.txt 完成词表映射，实现完整翻译流程

> 整个流程已验证跑通，输出几乎没有问题。

---

### 性能优化方向

#### 1. KV Cache（优先级高）

当前导出的模型不带 KV Cache，每次推理都重复计算，耗时较长。需重新导出带 KV Cache 的版本。

#### 2. Zero-Copy 技术

需确认 `Helsinki.cc` 是否使用了 zero-copy。RK3576 芯片支持该技术，在 `whisper.cc` 中已实现，可参考移植。

---

### 资源

- 原始模型权重（en-zh）：`models/opus-mt-en-zh`
- 参考实现：`/home/xh/projects/Local-multilingual-real-time-speech-recognition-and-real-time-subtitle-translation/translate/helsinki-rknn/`
