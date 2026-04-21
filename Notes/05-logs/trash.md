# 草稿：实时 ASR+翻译 Windows 桌面应用

## 1. 目标

创建一个实时 ASR + 翻译的应用跑在 Windows 上，类似音乐歌词显示，支持：
- 窗口可拖动
- 透明度可调
- 字体颜色、大小可调

## 2. 历史工作与计划

已有现成代码，上层代码调用底层 C++ 推理实现，参考：
`/home/xh/projects/AI-real-time-ASR-Translate-SpeakerID`（目前是 APK 应用）

## 3. 目前的环境和资源

| 资源 | 路径 |
|------|------|
| Android SDK | `/home/xh/Android/Sdk` |
| Android NDK | `/home/xh/Android/Ndk/android-ndk-r25c` |
| OnnxRuntime | `/home/xh/Android/OnnxRuntime/onnxruntime-android-1.17.1` |
| APK 应用 | `/home/xh/projects/AI-real-time-ASR-Translate-SpeakerID` |

## 4. 当前意图

需要先规划实现方案，关键问题待明确：
- 是否跨平台编译 C++ 为 Windows DLL？
- UI 层用什么框架（Qt / Electron / WPF）？
- 推理引擎如何适配 Windows（OnnxRuntime Windows 版）？
