# CLAUDE.md — AI 助手使用指南（`knowledge` 仓库）

## 仓库概览

本仓库是一个**个人知识库**，记录了将 AI/ML 模型移植到嵌入式 NPU（神经网络处理单元）硬件的完整工作流程——主要面向 Android 设备上的 **MediaTek MT8371** 和 **Rockchip RK3576** 芯片平台。

仓库内容为碎片化笔记、工作流指南、提示词模板和问题排查记录，均来自真实移植项目的积累。内容以中文为主，部分为英文。

---

## 目录结构

```
knowledge/
├── README.md                          # 项目简介（一行描述）
├── CLAUDE.md                          # 本文件
└── Notes/
    ├── WORKFLOW_GUIDE.md              # MTK NPU 子代理系统说明——主 Agent 与
    │                                  # Subagent 的协作机制、信息注入和模板选择逻辑
    ├── PORTING_NOTES.md               # Helsinki (MarianMT) 移植到 MTK MT8371
    │                                  # 的关键问题与解决方案记录
    ├── MTK-提示词模版.md               # MTK 项目提示词模板合集
    ├── 测试日志.md                     # 测试过程日志
    ├── 下面给你一套端到端的流程清单.md   # 端到端移植流程清单
    ├── 将可执行文件改为动态库(.so).md   # 可执行文件转动态库方法
    ├── 安装NDK与make.md               # NDK 与 make 安装指南
    ├── 安装AndroidSDK.md              # Android SDK 安装指南
    ├── RKNN文件在硬件上推理步骤.md     # RKNN 模型在硬件上推理的步骤
    ├── ONNXRuntime Android下载地址.md  # ONNXRuntime Android 版下载地址
    ├── Helsinki移植到RK芯片.md         # Helsinki 模型移植到 RK3576 的方案
    ├── trash.md                       # 临时草稿/废弃内容
    └── vibe coding/
        ├── MTK-NPU 算法移植.md        # MTK NPU 完整移植流程 + 提示词模板
        │                              # （含 SenseVoice、Helsinki、EDSR、RCAN、
        │                              # Real-ESRGAN、Whisper、SwinIR、M2M100）
        ├── RK-NPU 算法移植.md         # Rockchip NPU 移植工作流
        ├── Helsinki -量化推理测试.md   # Helsinki 量化推理测试记录
        ├── Question Notes.md          # 问题记录与解答
        ├── TO DO.md                   # 任务追踪（按日期分组）
        └── claude code setting.md     # Claude Code 集成配置
```

---

## 知识领域

### 1. 目标硬件平台

| 平台 | 芯片 | NPU 架构 | 模型格式 |
|------|------|----------|---------|
| MediaTek（MTK） | MT8371 | MDLA 5.3 | `.dla` |
| Rockchip（RK） | RK3576 | RKNN | `.rknn` |

### 2. 模型移植流程（MTK — 三阶段）

**第一阶段 — Python 端：模型转换**
```
PyTorch (.pt) → TFLite (.tflite) → DLA (.dla)
```
- 每个转换环节需要独立脚本：`step1_pt_to_torchscript.py`、`step2_torchscript_to_tflite.py`、`step3_tflite_to_dla.py`
- 每步转换后必须验证输出正确才能继续：`test_pytorch.py`、`test_pt.py`、`test_tflite.py`
- 最终多格式对比测试：`test_compare.py`
- **关键**：必须使用 MTK 自定义的 TFLite 工具（不能用标准 TFLite），因为 MTK 有自定义算子
- **关键**：MTK MDLA 不支持动态形状，转换为 TFLite 时必须指定固定输入尺寸

**第二阶段 — C++ 端：推理实现**
- 严格复刻 Python 端的推理逻辑
- 使用 MTK NeuroPilot SDK API（不能使用 RKNN API）
- 使用 ndk-build 编译（`Android.mk` + `Application.mk`）
- 目标架构：`arm64-v8a`

**第三阶段 — Android 端：部署测试**
- 交叉编译为 ARM64 可执行文件
- 通过 ADB 推送到 Android 设备
- 在硬件上运行并验证输出

### 3. 已记录的移植模型

| 模型 | 类型 | 备注 |
|------|------|------|
| SenseVoice (SenseVoiceSmall) | ASR 多语言语音识别 | 已集成到 sherpa-onnx 框架 |
| Helsinki / MarianMT | 神经机器翻译 | Encoder-Decoder + KV Cache，最复杂的移植案例 |
| EDSR | 超分辨率 | **MTK C++ 结构的主要参考项目** |
| RCAN | 超分辨率 | 残差通道注意力网络 |
| Real-ESRGAN | 超分辨率（GAN） | RRDB 纯 CNN 架构，MTK 算子支持良好 |
| SwinIR | 图像修复（Transformer） | 固定输入尺寸 `(1, 3, 512, 512)` |
| Whisper | 语音识别 | 带 KV Cache 的 Encoder-Decoder |
| M2M100 (418M) | 多语言机器翻译 | `lm_head` 必须在 CPU 运行（vocab=128112 超出 MDLA 维度限制） |
| Clip-Text | 文本编码器 | MTK API 调用方式的参考项目 |

---

## MTK MDLA 5.3 关键技术限制

以下为硬性限制，违反将导致模型转换失败：

| 限制 | 说明 | 解决方案 |
|------|------|---------|
| 不支持 5D Tensor | KV Cache 必须 ≤ 4D | 重整形状为 `[num_layers, batch, seq_len, d_model]` |
| 不支持 `GATHER` 算子 | Embedding 查表不可用 | 将权重导出为 `.bin`，在 C++ 端手动实现查表 |
| 不支持 `masked_fill` / `tril` | Causal mask 相关算子不可用 | 预计算 mask 存为 buffer，改用加法（`0/-1e9`）替代 |
| 不支持动态形状 | 输入尺寸必须固定 | 在 TFLite 转换时指定固定形状 |
| 维度限制 ≤ 65535 | 大词表层无法在 NPU 上执行 | 将 `lm_head` 移到 CPU（如 M2M100 vocab=128112） |
| Tensor 最大秩为 4D | MDLA 5.3 标准限制 | 所有高维 Tensor 需提前降维 |

**支持的算子（共 65 个）：** 标准 CNN 算子（Conv2d、BN、ReLU、Add 等）、基础 Transformer 算子（MatMul、Softmax、LayerNorm）。完整列表见 `~/.mtk_mdla_operators.md` 或 `/home/xh/projects/MTK/.claude/doc/mtk_mdla_operators.md`。

---

## 参考环境路径

以下为笔记中反复引用的开发机路径，汇总如下：

```
# SDK 与工具链
MTK NeuroPilot SDK:  /home/xh/projects/MTK/0_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron_sdk
MT8371 运行时库:     /home/xh/projects/MTK/0_Toolkits/.../neuron_sdk/mt8371
Android NDK (r25c):  /home/xh/Android/Ndk/android-ndk-r25c
Android NDK (r18b):  /home/xh/Android/Ndk/android-ndk-r18b
Android SDK:         /home/xh/Android/Sdk
OnnxRuntime:         /home/xh/Android/OnnxRuntime/onnxruntime-android-1.17.1

# 第三方库
第三方库目录:         /home/xh/projects/MTK/1_third_party/
  - FFTW3:           .../fftw/Android/arm64-v8a/
  - sentencepiece:   .../sentencepiece/lib/arm64-v8a/
  - libsndfile:      .../libsndfile/Android/arm64-v8a/
  - kaldi_native_fbank: .../kaldi_native_fbank/
工具目录:             /home/xh/projects/MTK/2_utils/

# 知识库与配置文件
算子支持列表:         ~/.mtk_mdla_operators.md（或 /home/xh/projects/MTK/.claude/doc/mtk_mdla_operators.md）
中央知识库:           ~/.mtk_npu_knowledge_base.md（或 /home/xh/projects/MTK/.claude/doc/mtk_npu_knowledge_base.md）
统一配置:             ~/.mtk_npu_config.json

# 已验证的参考项目（MTK）
EDSR（MTK）:         /home/xh/projects/MTK/superResolution/edsr/mtk    ← C++ 结构主要参考
SenseVoice（MTK）:   /home/xh/projects/MTK/sense-voice/sensevoice_mtk_cpp
Helsinki（MTK）:     /home/xh/projects/MTK/helsinki/
Clip-Text（MTK）:    /home/xh/projects/MTK/GAI-Deployment-Toolkit-v2.0.2_clip-text-v0.1/

# RK 参考项目
RKNN model zoo:      /home/xh/projects/rknn_model_zoo/examples/
Sherpa-onnx:         /home/xh/projects/sherpa-onnx/
```

---

## Subagent 系统（MTK NPU Skills）

笔记中描述了一套基于 Claude Code 的多代理架构，用于自动化模型移植流程。详见 `Notes/WORKFLOW_GUIDE.md`。

**模板存储路径：** `/home/xh/projects/MTK/.claude/subagents/`

| 模板文件 | 职责 |
|---------|------|
| `project-initializer.md` | 创建项目目录结构、下载模型、测试基线 |
| `operator-analyst.md` | 分析模型算子在 MTK MDLA 上的支持情况 |
| `python-converter.md` | PyTorch → TFLite → DLA 转换 |
| `cpp-implementer.md` | C++ 推理实现 + ndk-build 编译 |
| `android-deployer.md` | Android APK 编译与设备部署 |

**主 Agent 工作方式：** 读取对应模板 → 收集项目信息（模型路径、参考代码、库路径）→ 组合为完整 prompt → 通过 `Task()` 调用 Subagent。

---

## 仓库使用规范

1. **语言：** 笔记可以用中文或英文记录，两者均可，不要随意翻译已有内容。

2. **文件格式：** 所有笔记均为 Markdown 格式。图片使用本地文件引用（CherryStudio 格式：`file://C:\Users\...`）。

3. **新增笔记：** 记录新移植项目或问题时，参照 `vibe coding/MTK-NPU 算法移植.md` 的结构：
   - 第 1 节：完整上下文（目标、历史计划、环境路径）
   - 第 2 节：当前意图/任务
   - 第 3 节：约束与限制
   - 第 4 节：辅助视觉（截图等，如有）

4. **问题记录：** 参照 `PORTING_NOTES.md` 的结构：
   - 问题描述（附展示错误模式的代码）
   - 解决方案（附修改后的代码）

5. **TO DO.md：** 使用 `M.DD` 格式的日期分组，完成的条目标记为 `[x]`。

6. **不要添加代码文件：** 本仓库仅用于文档记录，所有实际代码均位于外部项目目录中。

---

## 安全警告

**仓库中存在明文敏感凭据：**

- `Notes/vibe coding/claude code setting.md` 中包含 GitHub 个人访问令牌、API Key 和 SSH 凭据。

**使用本仓库时请注意：**
- 不要将此仓库设为公开
- 不要再提交任何新的密钥或凭据
- 若仓库曾被公开访问，建议立即轮换相关凭据

---

## 优先阅读文件

处理任何 MTK NPU 模型移植任务前，建议按顺序阅读以下文件：

1. `Notes/WORKFLOW_GUIDE.md` — 了解子代理编排系统的工作原理
2. `Notes/PORTING_NOTES.md` — MTK 已知限制与经过验证的解决方案
3. `Notes/vibe coding/MTK-NPU 算法移植.md` — 各移植阶段的完整提示词模板
4. `~/.mtk_npu_knowledge_base.md` — 中央知识库（位于开发机）
5. `~/.mtk_mdla_operators.md` — 算子支持列表（位于开发机）
