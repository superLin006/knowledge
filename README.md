# Knowledge Base

个人工作学习知识库，记录 AI 算法移植、嵌入式 Android 开发过程中遇到的问题、解决方案和最佳实践。

主要涉及 MTK MT8371 / RK3576 NPU 平台的算法部署，以及 Android NDK 开发相关内容。

---

## 目录结构

```
Notes/
├── 01-algorithm-porting/     # 算法移植笔记
├── 02-environment-setup/     # 环境搭建
├── 03-workflow-reference/    # 工作流参考
├── 04-dev-tools/             # 开发工具配置
├── 05-logs/                  # 测试日志
├── picture/                  # 图片资源
├── Question Notes.md         # 问题与学习笔记
└── 语音算法技术.md            # 语音算法技术概览
```

---

## 各目录说明

### 01-algorithm-porting — 算法移植

记录将各类 AI 模型移植到 NPU 的完整流程和提示词，包括转换链、环境配置、注意事项。

| 文件 | 内容 |
|------|------|
| `MTK-NPU 算法移植.md` | MTK MT8371 平台移植笔记（SenseVoice、Helsinki、Whisper、EDSR/RCAN 等） |
| `RK-NPU 算法移植.md` | RK3576 平台移植笔记（EDSR、RCAN、SwinIR、Real-ESRGAN） |
| `Helsinki-RK移植.md` | Helsinki 翻译模型移植到 RK3576 的详细流程 |
| `Helsinki-量化推理测试.md` | Helsinki ONNX int8 量化推理测试流程 |
| `PORTING_NOTES.md` | 移植通用注意事项 |

### 02-environment-setup — 环境搭建

Android 开发环境的安装和配置步骤。

| 文件 | 内容 |
|------|------|
| `安装AndroidSDK.md` | Android SDK 安装步骤 |
| `安装NDK与make.md` | NDK 安装及 make 工具配置 |
| `ONNXRuntime Android下载地址.md` | OnnxRuntime Android 库下载地址及本地路径 |

### 03-workflow-reference — 工作流参考

常用操作流程的快速参考手册。

| 文件 | 内容 |
|------|------|
| `RKNN文件在硬件上推理步骤.md` | RK3576 Android 设备上运行 RKNN 模型的完整步骤（ADB 推送、权限设置、各 Demo 命令） |
| `android_deliver_workflow.md` | Android 交付标准工作流 |
| `WORKFLOW_GUIDE.md` | 通用工作流指南 |
| `TO DO.md` | 工作待办清单 |

### 04-dev-tools — 开发工具配置

Claude Code 及开发环境的配置文件。

| 文件 | 内容 |
|------|------|
| `claude code setting.md` | Claude Code 配置说明和使用笔记 |
| `settings.json.bak` | Claude Code settings.json 配置备份 |
| `statusline-command.sh` | 状态栏命令脚本 |

### 05-logs — 测试日志

模型推理测试的实验记录和调试日志。

| 文件 | 内容 |
|------|------|
| `测试日志.md` | Whisper RKNN 流式识别、APK 集成测试、SenseVoice MTK 调试记录 |
| `trash.md` | 临时记录和草稿 |

---

## 主要平台

| 平台 | 芯片 | 转换链 | 主要模型 |
|------|------|--------|---------|
| MTK NPU | MT8371 | `.pt → .tflite → .dla` | SenseVoice、Helsinki、Whisper、EDSR、RCAN |
| RK NPU | RK3576 | `.pt → .onnx → .rknn` | Whisper、Helsinki、EDSR、RCAN、SwinIR、Real-ESRGAN |
