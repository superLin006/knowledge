# CLAUDE.md — AI Assistant Guide for `knowledge` Repository

## Repository Overview

This is a **personal knowledge base** documenting the end-to-end workflow for porting AI/ML models to embedded NPU (Neural Processing Unit) hardware — primarily **MediaTek MT8371** and **Rockchip RK3576** chipsets on Android devices.

The repository contains fragmented notes, workflow guides, prompt templates, and troubleshooting documentation compiled from real porting projects. Content is written in a mix of Chinese and English.

---

## Repository Structure

```
knowledge/
├── README.md                          # One-line project description
├── CLAUDE.md                          # This file
└── Notes/
    ├── WORKFLOW_GUIDE.md              # MTK NPU subagent system — how main Agent
    │                                  # and subagents collaborate, inject context,
    │                                  # and dynamically select templates
    ├── PORTING_NOTES.md               # Helsinki (MarianMT) porting to MTK MT8371 —
    │                                  # detailed problems and solutions
    ├── MTK-提示词模版.md               # MTK prompt templates
    ├── 测试日志.md                     # Test logs
    ├── 下面给你一套端到端的流程清单.md   # End-to-end checklist
    ├── 将可执行文件改为动态库(.so).md   # Converting executables to .so libraries
    ├── 安装NDK与make.md               # NDK and make installation guide
    ├── 安装AndroidSDK.md              # Android SDK installation guide
    ├── RKNN文件在硬件上推理步骤.md     # RKNN inference steps on hardware
    ├── ONNXRuntime Android下载地址.md  # ONNXRuntime Android download links
    ├── Helsinki移植到RK芯片.md         # Helsinki porting strategy to RK3576
    ├── trash.md                       # Scratch/discard notes
    └── vibe coding/
        ├── MTK-NPU 算法移植.md        # Full workflow + prompt templates for MTK NPU
        │                              # porting (SenseVoice, Helsinki, EDSR, RCAN,
        │                              # Real-ESRGAN, Whisper, SwinIR, M2M100)
        ├── RK-NPU 算法移植.md         # Rockchip NPU porting workflow
        ├── Helsinki -量化推理测试.md   # Helsinki quantization/inference testing
        ├── Question Notes.md          # Q&A and open questions
        ├── TO DO.md                   # Task tracking (dated entries)
        └── claude code setting.md     # Claude Code integration config
```

---

## Knowledge Domains

### 1. Target Hardware Platforms

| Platform | Chip | NPU Architecture | Format |
|----------|------|------------------|--------|
| MediaTek (MTK) | MT8371 | MDLA 5.3 | `.dla` |
| Rockchip (RK) | RK3576 | RKNN | `.rknn` |

### 2. Model Porting Workflow (MTK — 3 Stages)

**Stage 1 — Python: Model Conversion**
```
PyTorch (.pt) → TFLite (.tflite) → DLA (.dla)
```
- Each conversion step requires a dedicated script: `step1_pt_to_torchscript.py`, `step2_torchscript_to_tflite.py`, `step3_tflite_to_dla.py`
- Each step must be validated before proceeding: `test_pytorch.py`, `test_pt.py`, `test_tflite.py`
- Final comparison across formats: `test_compare.py`
- **Critical**: Must use MTK's custom TFLite tools (not standard TFLite) — MTK has custom operators
- **Critical**: MTK MDLA does not support dynamic shapes — fixed input shapes required at TFLite conversion

**Stage 2 — C++: Inference Implementation**
- Replicate the Python inference logic exactly in C++
- Use MTK NeuroPilot SDK API (not RKNN API)
- Build with Android NDK using ndk-build (`Android.mk` + `Application.mk`)
- Target: `arm64-v8a`

**Stage 3 — Android: Deployment**
- Cross-compile to ARM64 binary
- Push to device via ADB
- Run on hardware and verify output

### 3. Models Documented

| Model | Type | Notes |
|-------|------|-------|
| SenseVoice (SenseVoiceSmall) | ASR (multi-language) | Integrated into sherpa-onnx framework |
| Helsinki / MarianMT | Neural Machine Translation | Encoder-Decoder with KV Cache; most complex porting case |
| EDSR | Super-Resolution | Reference project for MTK C++ structure |
| RCAN | Super-Resolution | Residual channel attention |
| Real-ESRGAN | Super-Resolution (GAN) | RRDB architecture; CNN ops well-supported by MTK |
| SwinIR | Image Restoration (Transformer) | Fixed input shape `(1, 3, 512, 512)` |
| Whisper | Speech Recognition | With KV Cache; encoder-decoder |
| M2M100 (418M) | Multilingual MT | `lm_head` must run on CPU (vocab_size=128112 exceeds MDLA dimension limit) |
| Clip-Text | Text Encoder | Reference project for MTK API usage |

---

## Critical Technical Constraints (MTK MDLA 5.3)

These are hard limits — violating them causes conversion failures:

| Constraint | Detail | Workaround |
|-----------|--------|-----------|
| No 5D tensors | KV Cache must be ≤ 4D | Reshape: `[num_layers, batch, seq_len, d_model]` |
| No `GATHER` operator | Embedding lookup unsupported | Export weights to `.bin`, implement CPU-side lookup in C++ |
| No `masked_fill` / `tril` | Causal mask ops unsupported | Pre-compute mask as buffer; replace with additive `0/-1e9` mask |
| No dynamic shapes | Fixed input shapes required | Specify shape at TFLite conversion time |
| Dimension limit ≤ 65535 | Large vocab layers fail | Move `lm_head` to CPU (e.g., M2M100 vocab=128112) |
| Max tensor rank: 4D | Standard for MDLA 5.3 | Reshape all higher-rank tensors |

**Supported operators (65 total):** Standard CNN ops (Conv2d, BN, ReLU, Add, etc.), basic Transformer ops (MatMul, Softmax, LayerNorm). See `~/.mtk_mdla_operators.md` or `/home/xh/projects/MTK/.claude/doc/mtk_mdla_operators.md` for the full list.

---

## Reference Environment Paths

These are the development machine paths referenced throughout the notes:

```
# SDKs and Toolchains
MTK NeuroPilot SDK:  /home/xh/projects/MTK/0_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron_sdk
MT8371 runtime libs: /home/xh/projects/MTK/0_Toolkits/.../neuron_sdk/mt8371
Android NDK (r25c):  /home/xh/Android/Ndk/android-ndk-r25c
Android NDK (r18b):  /home/xh/Android/Ndk/android-ndk-r18b
Android SDK:         /home/xh/Android/Sdk
OnnxRuntime:         /home/xh/Android/OnnxRuntime/onnxruntime-android-1.17.1

# Third-party libraries
Third-party libs:    /home/xh/projects/MTK/1_third_party/
  - FFTW3:           .../fftw/Android/arm64-v8a/
  - sentencepiece:   .../sentencepiece/lib/arm64-v8a/
  - libsndfile:      .../libsndfile/Android/arm64-v8a/
  - kaldi_native_fbank: .../kaldi_native_fbank/
Utilities:           /home/xh/projects/MTK/2_utils/

# Knowledge/config files
Operator support:    ~/.mtk_mdla_operators.md (or /home/xh/projects/MTK/.claude/doc/mtk_mdla_operators.md)
Knowledge base:      ~/.mtk_npu_knowledge_base.md (or /home/xh/projects/MTK/.claude/doc/mtk_npu_knowledge_base.md)
Config:              ~/.mtk_npu_config.json

# Reference projects (completed, validated)
EDSR (MTK):          /home/xh/projects/MTK/superResolution/edsr/mtk    ← PRIMARY C++ REFERENCE
SenseVoice (MTK):    /home/xh/projects/MTK/sense-voice/sensevoice_mtk_cpp
Helsinki (MTK):      /home/xh/projects/MTK/helsinki/
Clip-Text (MTK):     /home/xh/projects/MTK/GAI-Deployment-Toolkit-v2.0.2_clip-text-v0.1/

# RK reference projects
RKNN model zoo:      /home/xh/projects/rknn_model_zoo/examples/
Sherpa-onnx:         /home/xh/projects/sherpa-onnx/
```

---

## Subagent System (MTK NPU Skills)

The notes describe a Claude Code multi-agent architecture for automating model porting. See `Notes/WORKFLOW_GUIDE.md` for full details.

**Templates are stored at:** `/home/xh/projects/MTK/.claude/subagents/`

| Template | Purpose |
|----------|---------|
| `project-initializer.md` | Create project structure, download model, test baseline |
| `operator-analyst.md` | Analyze model operator support on MTK MDLA |
| `python-converter.md` | PyTorch → TFLite → DLA conversion |
| `cpp-implementer.md` | C++ inference implementation + ndk-build compilation |
| `android-deployer.md` | Android APK build and device deployment |

**Main Agent behavior:** Reads the appropriate template, collects project-specific info (model paths, reference code, library paths), combines them into a complete prompt, then calls `Task()` with the subagent.

---

## Conventions for Working in This Repository

1. **Language:** Notes may be in Chinese or English — both are acceptable. Do not translate existing content unless asked.

2. **File format:** All notes are Markdown. Images are embedded as local file references (CherryStudio format: `file://C:\Users\...`).

3. **Adding notes:** When documenting a new porting project or issue, follow the structure in `vibe coding/MTK-NPU 算法移植.md`:
   - Section 1: Full context (goal, history, environment paths)
   - Section 2: Current intent/task
   - Section 3: Constraints/requirements
   - Section 4: Visual aids (if applicable)

4. **Documenting problems:** Follow the structure in `PORTING_NOTES.md`:
   - Problem description (with code showing the broken pattern)
   - Solution (with code showing the fix)

5. **TO DO.md:** Use dated entries (`M.DD` format). Mark items with `[x]` when complete.

6. **Do not add code files** — this is a documentation-only repository. All actual code lives in external project directories.

---

## Security Warning

**The repository contains sensitive credentials in plain text.** Specifically:

- `Notes/vibe coding/claude code setting.md` contains GitHub personal access tokens, API keys, and SSH credentials.

**If working with this repository:**
- Do not expose these files publicly
- Do not commit additional secrets
- Consider rotating any exposed credentials if the repo is ever made public

---

## Key Files to Read First

For any AI model porting task on MTK NPU, read these in order:

1. `Notes/WORKFLOW_GUIDE.md` — understand the subagent orchestration system
2. `Notes/PORTING_NOTES.md` — known MTK constraints and proven solutions
3. `Notes/vibe coding/MTK-NPU 算法移植.md` — full prompt templates for each porting stage
4. `~/.mtk_npu_knowledge_base.md` — central knowledge base (on dev machine)
5. `~/.mtk_mdla_operators.md` — operator support list (on dev machine)
