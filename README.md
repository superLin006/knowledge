# Knowledge Base

团队共享知识库，用于记录 AI 算法移植、嵌入式 Android 开发过程中遇到的问题、解决方案和最佳实践。

每位成员在根目录下维护自己的目录，互不干扰。

---

## 目录结构

```
knowledge/
├── XH/                       # 谢欢的笔记目录
│   └── Notes/
│       ├── 00-picture/           # 图片资源
│       ├── 01-algorithm-porting/ # 算法移植笔记
│       ├── 02-environment-setup/ # 环境搭建
│       ├── 03-workflow-reference/# 工作流参考
│       ├── 04-dev-tools/         # 开发工具配置
│       ├── 05-logs/              # 测试日志与问题记录
│       └── 06-interview/         # 面试准备
└── README.md
```

---

## XH/Notes 目录说明

### 00-picture — 图片资源

所有 md 文件引用的图片统一存放于此，各文件使用相对路径引用。

### 01-algorithm-porting — 算法移植

记录将各类 AI 模型移植到 NPU 的完整流程，包括转换链、环境配置、注意事项。

| 文件 | 内容 |
|------|------|
| `MTK-NPU 算法移植.md` | MTK MT8371 平台移植笔记（SenseVoice、Helsinki、Whisper、EDSR/RCAN 等） |
| `RK-NPU 算法移植.md` | RK3576 平台移植笔记（EDSR、RCAN、SwinIR、Real-ESRGAN） |
| `模型量化推理测试.md` | 模型量化推理测试流程与记录 |
| `算法移植问题记录.md` | 移植过程中遇到的问题与解决方案 |

### 02-environment-setup — 环境搭建

Android 开发环境的安装和配置步骤。

| 文件 | 内容 |
|------|------|
| `安装AndroidSDK.md` | Android SDK 安装步骤 |
| `安装NDK与make.md` | NDK 安装及 make 工具配置 |
| `ONNXRuntime.md` | OnnxRuntime Android 库下载地址及本地路径 |

### 03-workflow-reference — 工作流参考

常用操作流程的快速参考手册。

| 文件/目录 | 内容 |
|----------|------|
| `AI算法端侧部署推理流程.md` | AI 算法端侧部署推理完整流程 |
| `android_deliver_workflow.md` | Android 交付标准工作流 |
| `MTK-多Agent协作工作流/` | MTK NPU 多 Agent 自动化工作流（含 subagents、知识库、算子支持列表） |

### 04-dev-tools — 开发工具配置

Claude Code 及开发环境的配置文件与使用笔记。

| 文件/目录 | 内容 |
|----------|------|
| `Setting.md` | 开发环境配置笔记 |
| `Tools.md` | 工具使用笔记 |
| `Claude code/` | Claude Code 配置（settings.json 备份、状态栏脚本、使用说明） |

### 05-logs — 测试日志与问题记录

模型推理测试的实验记录、调试日志及问题笔记。

| 文件 | 内容 |
|------|------|
| `TO DO.md` | 工作待办清单与阶段性总结 |
| `Question Notes.md` | 问题记录与学习笔记 |

### 06-interview — 面试准备

面试指南与题库，针对语音算法工程师岗位。

| 文件 | 内容 |
|------|------|
| `语音算法技术.md` | 语音算法技术概览（ASR、TTS、声学模型等） |
| `Zipformer微调技术笔记.md` | Zipformer 全参数微调、LoRA 微调、继续训练全流程技术笔记 |
| `面试指南.md` | 聆思科技 AI 算法工程师岗位专属面试指南 |
| `面试题库及答案.md` | 语音算法核心面试题库及标准答案 |

---

## 主要平台

| 平台 | 芯片 | 转换链 | 主要模型 |
|------|------|--------|---------|
| MTK NPU | MT8371 | `.pt → .tflite → .dla` | SenseVoice、Helsinki、Whisper、EDSR、RCAN |
| RK NPU | RK3576 | `.pt → .onnx → .rknn` | Whisper、Helsinki、EDSR、RCAN、SwinIR、Real-ESRGAN |
