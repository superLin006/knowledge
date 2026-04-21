# Helsinki 翻译模型移植到 RK3576

## 移植方案

分五个步骤完成从 PyTorch 权重到 RK3576 NPU 端到端推理的完整流程。

**第一步**：Python 环境下分别导出 Encoder 和 Decoder 的 ONNX 格式（注意 RK 平台适配）

**第二步**：Python 环境下用导出的 encoder.onnx + decoder.onnx 协同推理，测试完整翻译句子（en→zh），验证模型可用性

**第三步**：在 Linux 上完成 encoder.onnx + decoder.onnx → rknn 格式转换

**第四步**：根据 Helsinki 官方 Python 推理代码，编写 Android C++ 推理代码。用简单测试 token 完成 encoder.rknn + decoder.rknn 在 RK3576 上的协同推理（编码+解码），验证 rknn 模型及 C++ 推理代码可用性

**第五步**：实现 C++ 端 tokenizer，根据导出的 vocab.txt 完成词表映射，实现完整翻译流程

> 整个流程已验证跑通，输出几乎没有问题。

---

## 性能优化方向

### 1. KV Cache（优先级高）

当前导出的模型不带 KV Cache，每次推理都重复计算，耗时较长。需重新导出带 KV Cache 的版本。

### 2. Zero-Copy 技术

需确认 `Helsinki.cc` 是否使用了 zero-copy。RK3576 芯片支持该技术，在 `whisper.cc` 中已实现，可参考移植。

---

## 资源

- 原始模型权重（en-zh）：`models/opus-mt-en-zh`
- 参考实现：`/home/xh/projects/Local-multilingual-real-time-speech-recognition-and-real-time-subtitle-translation/translate/helsinki-rknn/`
