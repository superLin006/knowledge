# MTK NPU Subagent 系统工作原理

本文档详细说明主 Agent 和 Subagent 的协同工作机制、信息注入机制和判断逻辑。

---

## 🤖 主 Agent 的信息注入机制

### 核心原理

**是的，主 Agent 会主动注入相关信息到 Subagent**

主 Agent 不会简单地传递你的请求，而是：

1.  **读取模板**：从 `/home/xh/projects/MTK/.claude/subagents/` 读取对应模板
    
2.  **收集信息**：读取项目相关文件（模型、代码、配置等）
    
3.  **组合指令**：模板（通用流程）+ 项目信息（具体数据）
    
4.  **调用 Subagent**：传递完整的上下文信息
    

---

## 📂 Subagent 目录的加载机制

### 不会自动读取整个目录

**重要**：主 Agent 不会自动加载 `/home/xh/projects/MTK/.claude/subagents/` 下的所有文件

| 方式  | 行为  |
| --- | --- |
| ❌ **不会** | 自动读取所有 subagent 模板文件 |
| ❌ **不会** | 预加载目录到上下文 |
| ✅ **会** | 根据任务类型**动态选择**并读取需要的模板 |

### 工作判断流程

```text
你的请求："继续C++实现"
    ↓
主Agent分析任务类型
    ↓
判断：这是 C++ 实现阶段
    ↓
动态决策：需要读取 cpp-implementer.md
    ↓
执行：Read("/home/xh/projects/MTK/.claude/subagents/cpp-implementer.md")
    ↓
收集项目信息：
  - 读取 Python 推理代码
  - 读取 DLA 模型路径
  - 读取参考项目结构
    ↓
组合：模板 + 你的项目信息
    ↓
调用：Task(prompt=组合后的完整指令)
```

---

## 🔍 主 Agent 的判断逻辑

### 判断依据

主 Agent 通过以下信息判断如何工作：

1.  **你的请求内容**
    
    -   明确的文件名 → 直接读取/编辑
        
    -   阶段描述（"继续C++实现"）→ 读取对应 subagent 模板
        
    -   新项目请求 → 从 project-initializer 开始
        
2.  **当前工作目录**
    
    -   通过 `pwd` 确定项目位置
        
    -   分析目录结构判断项目状态
        
3.  **上下文历史**
    
    -   之前完成的工作
        
    -   下一步应该做什么
        

### 实际例子

#### 场景1：你说"更新 cpp-implementer.md"

```text
主Agent的判断：
- ✓ 你明确提到文件名
- ✓ 直接读取该文件
- ✓ 不需要调用 subagent
- ✓ 直接编辑文件

操作：
Read("/home/xh/projects/MTK/.claude/subagents/cpp-implementer.md")
Edit(修改内容)
```

#### 场景2：你说"继续C++实现"

```text
主Agent的判断：
- ✓ 这是 C++ 实现阶段
- ✓ 需要使用 cpp-implementer 模板
- ✓ 需要收集项目信息
- ✓ 需要调用 subagent

操作：
1. Read("/home/xh/projects/MTK/.claude/subagents/cpp-implementer.md")
2. Read("/home/xh/projects/MTK/whisper/mtk/python/test_tflite.py")  # 推理逻辑
3. Read("/home/xh/projects/MTK/superResolution/edsr/mtk/cpp/jni/Android.mk")  # 参考
4. 组合：模板 + 项目信息 + 参考代码
5. Task(subagent_type="general-purpose", prompt=完整指令)
```

#### 场景3：你说"移植YOLO-v8"

```text
主Agent的判断：
- ✓ 新项目，从零开始
- ✓ 第一步：项目初始化
- ✓ 需要收集新算法信息

操作：
1. Read("project-initializer.md")
2. 收集：算法名、模型、环境、参考项目
3. 注入：模板 + YOLO-v8 具体信息
4. Task(subagent_type="general-purpose", prompt=初始化指令)
5. 等你确认后继续下一步
```

---

## 🔄 完整信息流

### 架构图

```text
┌─────────────────────────────────────────────────────┐
│                      用户 (You)                      │
│  提供算法移植需求（模型、平台、环境、参考项目等）       │
└────────────────────┬────────────────────────────────┘
                     │ 提供详细 prompt
                     ▼
┌─────────────────────────────────────────────────────┐
│                   主Agent (我)                       │
│  职责：解析需求 → 选择模板 → 组合信息 → 调用Subagent  │
└────────────────────┬────────────────────────────────┘
                     │
         ┌───────────┼───────────┐
         │           │           │
         ▼           ▼           ▼
    ┌─────────┐ ┌─────────┐ ┌─────────┐
    │ 读取5个  │ │ 组合用户 │ │ 调用Task │
    │ subagent│ │ 信息     │ │ 工具    │
    │ 模板    │ │          │ │         │
    └─────────┘ └─────────┘ └─────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │  Subagent (独立上下文)  │
         │  收到：模板+所有项目信息 │
         └───────────────────────┘
```

### 详细流程示例

#### 用户请求："移植Whisper到MTK NPU"

```python
# ===== 主Agent的内部处理 =====

# 第1步：分析请求
{
    "algorithm": "Whisper",
    "type": "ASR",
    "platform": "MT8371",
    "stage": "新项目"
}

# 第2步：读取模板
template = Read("/home/xh/projects/MTK/.claude/subagents/project-initializer.md")

# 第3步：收集项目信息
project_info = {
    "project_path": "/home/xh/projects/MTK/whisper/mtk",
    "model_url": "https://openaipublic.azureedge.net/main/whisper/models/tiny.pt",
    "reference_project": "/home/xh/projects/MTK/superResolution/edsr/mtk",
}

# 第4步：组合完整指令
full_prompt = f"""
{template}

---

## 当前任务信息

算法名称: Whisper
模型文件: tiny.pt
算法类型: ASR (语音识别)
目标平台: MT8371

项目路径: /home/xh/projects/MTK/whisper/mtk
参考项目: /home/xh/projects/MTK/superResolution/edsr/mtk

请按照模板流程执行项目初始化。
"""

# 第5步：调用 Subagent
Task(
    subagent_type="general-purpose",
    description="初始化Whisper MTK项目",
    prompt=full_prompt  # ← 注入了模板+所有相关信息
)
```

#### Subagent 接收到的信息

```text
# Subagent 看到的完整上下文：

[模板内容]
# MTK NPU 项目初始化专家 (project-initializer)
## Subagent身份
你是MTK NPU项目初始化专家...
## 核心职责
创建项目目录结构、配置环境、下载模型...
## 🔄 工作流程
### 步骤1：创建标准目录结构
...

---

[用户项目信息]
## 当前任务信息
算法名称: Whisper
模型文件: tiny.pt
项目路径: /home/xh/projects/MTK/whisper/mtk
参考项目: /home/xh/projects/MTK/superResolution/edsr/mtk
...
```

---

## 📊 Subagent 模板库

### 目录结构

```text
/home/xh/projects/MTK/.claude/subagents/
├── README.md              # 系统概述
├── USAGE_EXAMPLE.md       # 使用示例
├── WORKFLOW_GUIDE.md      # 本文件：工作原理说明
├── project-initializer.md    # 项目初始化模板 ✅
├── operator-analyst.md       # 算子分析模板 ✅
├── python-converter.md       # Python转换模板 ✅
├── cpp-implementer.md        # C++实现模板 ✅
└── android-deployer.md       # Android部署模板 ⏳
```

### 模板选择逻辑

| 你的请求 | 主Agent选择 | 读取的模板 |
| --- | --- | --- |
| "移植YOLO-v8" | project-initializer | project-initializer.md |
| "分析算子支持情况" | operator-analyst | operator-analyst.md |
| "继续Python转换" | python-converter | python-converter.md |
| "继续C++实现" | cpp-implementer | cpp-implementer.md |
| "部署到Android" | android-deployer | android-deployer.md |

---

## 💡 关键设计原则

### 1\. 主 Agent 是"智能路由器"

```text
你的请求 → 我分析 → 判断需要哪个 subagent → 读取对应模板 → 注入项目信息 → 调用
```

**职责**：

-   ✓ 解析用户需求
    
-   ✓ 选择合适的模板
    
-   ✓ 收集项目信息
    
-   ✓ 组合完整指令
    
-   ✓ 汇总执行结果
    

### 2\. Subagent 目录是"模板库"

```text
不是一次性全读，而是按需读取！
```

**特点**：

-   ✓ 每个模板独立完整
    
-   ✓ 包含详细的工作流程
    
-   ✓ 基于实战经验优化
    
-   ✓ 可复用于不同算法
    

### 3\. 信息注入是"动态组合"

```text
模板（通用流程）+ 项目信息（具体数据）= 完整指令
```

**注入的信息类型**：

-   ✓ DLA 模型路径
    
-   ✓ Python 推理代码片段
    
-   ✓ 参考项目路径和关键代码
    
-   ├── 第三方库路径
    
-   ├── MTK SDK 路径
    
-   └──── 用户特殊需求
    

---

## 🎯 实际案例：Whisper 项目回顾

### 完整流程

```text
你 → "移植Whisper到MTK NPU"
     ↓
【阶段1：项目初始化】
主Agent：
  - 读取 project-initializer.md
  - 收集：算法名、模型URL、参考项目
  - 注入信息
  - 调用 Task(...)
Subagent：
  - 创建 /home/xh/projects/MTK/whisper/mtk/
  - 下载 whisper/tiny.pt
  - 测试 baseline
     ↓
【阶段2：算子分析】
你 → "继续算子分析"
主Agent：
  - 读取 operator-analyst.md
  - 收集：模型结构、算子列表
  - 注入信息
  - 调用 Task(...)
Subagent：
  - 分析算子支持
  - 发现：Embedding GATHER 不支持
  - 提供：Helsinki 分离方案
     ↓
【阶段3：Python转换】
你 → "继续Python转换"
主Agent：
  - 读取 python-converter.md
  - 收集：模型路径、算子分析结果
  - 注入：Embedding分离方案
  - 调用 Task(...)
Subagent：
  - .pt → .tflite → .dla
  - 分离 Embedding
  - 测试验证
     ↓
【阶段4：C++实现】
你 → "继续C++实现"
主Agent：
  - 读取 cpp-implementer.md
  - 收集：DLA模型、Python推理代码、EDSR参考
  - 注入：ndk-build结构、第三方库路径
  - 调用 Task(...)
Subagent：
  - 生成 jni/src/ 代码
  - 创建 Android.mk + Application.mk
  - 编译成功：libs/arm64-v8a/whisper_mtk
```

### 主 Agent 在阶段4的注入示例

````python
# 主 Agent 组合的完整指令

template = Read("cpp-implementer.md")

python_code = Read("/home/xh/projects/MTK/whisper/mtk/python/test_tflite.py")
reference_mk = Read("/home/xh/projects/MTK/superResolution/edsr/mtk/cpp/jni/Android.mk")

full_prompt = f"""
{template}

---

## 当前项目：Whisper ASR

### DLA 模型
- Encoder: /home/xh/projects/MTK/whisper/mtk/python/models/whisper_encoder.dla
- Decoder: /home/xh/projects/MTK/whisper/mtk/python/models/whisper_decoder.dla
- Embedding: /home/xh/projects/MTK/whisper/mtk/python/models/embeddings.pt

### Python 推理逻辑（需要复刻）
```python
{提取的关键代码片段}
````

### 参考项目结构

-   目录：/home/xh/projects/MTK/superResolution/edsr/mtk/cpp
    
-   编译方式：ndk-build（Android.mk + Application.mk）
    
-   输出：jni/libs/arm64-v8a/
    

### 第三方库

-   FFTW3: /home/xh/projects/MTK/1\_third\_party/fftw/Android/arm64-v8a/
    
-   sentencepiece: /home/xh/projects/MTK/1\_third\_party/sentencepiece/lib/arm64-v8a/
    
-   libsndfile: /home/xh/projects/MTK/1\_third\_party/libsndfile/Android/arm64-v8a/
    

### 前后处理要求

-   音频预处理：MFCC 特征提取
    
-   Embedding 查表：vocab embeddings
    
-   Token 解码：sentencepiece
    

请按照 EDSR 的目录结构实现 C++ 代码，使用 ndk-build 编译。 """

```text

---

## ✅ 优势总结

| 特性 | 说明 | 好处 |
|------|------|------|
| **按需加载** | 只读取需要的模板 | 节省上下文，提高效率 |
| **信息注入** | 主动收集并注入项目信息 | Subagent 无需自己查找 |
| **动态判断** | 根据请求智能选择模板 | 灵活适应不同任务 |
| **上下文隔离** | 每个 Subagent 独立工作 | 避免信息干扰 |
| **经验积累** | 模板基于实战持续优化 | 越用越智能 |

---

## 🔗 相关文档

- **系统概述**：`/home/xh/projects/MTK/.claude/subagents/README.md`
- **使用示例**：`/home/xh/projects/MTK/.claude/subagents/USAGE_EXAMPLE.md`
- **Subagent模板**：`/home/xh/projects/MTK/.claude/subagents/*.md`

---

## 📝 常见问题

### Q1: 我如何知道主 Agent 读取了哪些文件？
**A**: 主 Agent 会在函数调用中展示所有 `Read` 操作，你可以看到我读取了哪些文件。

### Q2: 如果主 Agent 判断错误怎么办？
**A**: 你可以明确指定："读取 cpp-implementer.md" 或 "使用 python-converter 模板"

### Q3: 我可以提供额外的参考信息吗？
**A**: 可以！在你的 prompt 中包含：
- 参考项目路径
- 特殊的代码示例
- 具体的要求或约束

### Q4: Subagent 会访问我的所有文件吗？
**A**: 不会。Subagent 只能访问主 Agent 明确传递的信息，不会自己扫描目录。

### Q5: 如何更新 subagent 模板？
**A**:
1. 直接编辑 `.md` 文件
2. 主 Agent 会自动使用最新版本
3. 建议在模板顶部更新版本号

---

**文档版本**: v1.0
**创建日期**: 2026-02-05
**最后更新**: 2026-02-05
**维护者**: MTK NPU移植团队
```