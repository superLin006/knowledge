### 1 完整且丰富的上下文

\*\***目标**：\*\*我现在需要把多个Helsinki 翻译模型导出为onnx格式并量化为int8 然后完成int8的推理，最后跑在C++编译好的推理程序上，由onnxruntime驱动，完成Android设备上的推理测试。

**历史以及计划**：<br>（1）modelscope下载对应的模型权重，放到对应的文件夹models。（未做）比如 英→中 models/opus-mt-en-zh  [https://www.modelscope.cn/models/Helsinki-NLP/opus-mt-en-zh](https://www.modelscope.cn/models/Helsinki-NLP/opus-mt-en-zh) 需要注意每个语言对下载的路径规则可能不一样<br>（2） 编写python导出及推理代码，导出onnx格式的模型以及int8量化，完成量化模型的推理测试。（已完成）代码在/helsinki-onnx/python/export\_int8\_model.py    /helsinki-onnx/python/inference\_int8\_model.py<br>（3）编译helsinki C++推理代码，生成可执行文件，把量化后的int8模型，在检测到的Android设备完成进行推理测试。（未做）<br><br>**\*\*目前的环境**：conda环境  helsinki python=3.8 需要创建，其他资源目录如下：<br>(1)NDK：/home/xh/Android/Ndk/android-ndk-r25c<br>(2)SDK：/home/xh/Android/Sdk<br>(3)OnnxRuntime：/home/xh/Android/OnnxRuntime/onnxruntime-android-1.17.1<br>

### 2 当前的意图/任务

我已经完成了所有的工作，我想让你帮我把/home/xh/projects/Local-multilingual-real-time-speech-recognition-and-real-time-subtitle-translation/translate/helsinki-onnx/python/models/opus-mt-tc-big-en-ko 这个模型跑一遍流程，推送到Android设备测试，看看python输出结果和C++输出的结果是否都合理

1 先切换到conda Helsinki 环境 安装必要的文件，然后按顺序完成（1）（2）（3）计划的未完成的任务和工作，先完成整个的过程，确保没有问题后，再继续完成日、韩、到英语的整个测试过程。

<br>2 先切换到对应的conda环境 helsinki,由于以上任务和环节都已经跑通了，我现在的目标是，继续完成新的 中—>日、韩  日—>英、韩、中   韩—>日、英、中 的   整个测试过程

1 先创建conda环境 安装必要的文件，然后按顺序完成（1）（2）（3）计划的未完成的任务和工作，先完成整个的过程，确保没有问题后，再继续完成日、韩、到英语的整个测试过程。<br>