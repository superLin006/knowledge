### 转化为DLA格式避免Gather操作优化后的备选方案

方案3：Prompt 预处理（推荐）

在 NPU 推理之前，用 CPU 计算 prompt embedding，然后作为额外输入传给 NPU

模型输入变成 6 个：

输入1: audio\_features [1, 166, 560] 输入2: prompt\_emb\_0 [1, 560] # CPU 预计算的 embedding 输入3: prompt\_emb\_1 [1, 560] 输入4: prompt\_emb\_2 [1, 560] 输入5: prompt\_emb\_3 [1, 560] 输入6: dummy [1] # 占位符（保持接口兼容）

C++ 调用流程： // 1. CPU 端：根据 prompt 查表获取 embedding float\* prompt\_emb\_0 = embedding\_table[language\_id]; // [560] float\* prompt\_emb\_1 = embedding\_table[event\_id]; // [560] float\* prompt\_emb\_2 = embedding\_table[event\_type\_id]; // [560] float\* prompt\_emb\_3 = embedding\_table[text\_norm\_id]; // [560]

// 2. 输入到 NPU NeuronRuntime\_setInput(runtime, 0, audio\_features, ...); NeuronRuntime\_setInput(runtime, 1, prompt\_emb\_0, ...); NeuronRuntime\_setInput(runtime, 2, prompt\_emb\_1, ...); NeuronRuntime\_setInput(runtime, 3, prompt\_emb\_2, ...); NeuronRuntime\_setInput(runtime, 4, prompt\_emb\_3, ...); NeuronRuntime\_execute(runtime);

优点：

✅ 只需要 1 个 DLA 文件

✅ 支持任意 prompt 组合

✅ embedding lookup 在 CPU 上做（支持 GATHER）

✅ NPU 只做推理计算

缺点：

⚠️ 需要 C++ 端实现 embedding 查表（轻量级，很快）

### AI科学家面试

1.多模态AI处理

音频：

（1） ASR(语音识别)部署到端侧设备，业界有哪些可行的方案，针对语种覆盖不全（特别是小语种）怎么解决呢？<br>（2）AI语音转写需要实时处理、准确率高、延迟要求低，而端侧设备算力比较有限，有什么比较常见的优化手段和实现方案吗？<br>（3）假如要做一个AI语音助手（语音唤醒），利用关键词唤醒后做到屏幕上的内容所见即所控，有什么好的思路吗？

视频（图像）：<br>（1）实时画面帧测，在联网的状态下，实时检测屏幕敏感内容，如何优化降低延迟呢，LLM可以应用进来处理吗？<br>（2）视频超分、画质提升相关的AI算法有了解过吗

文本（LLM）：<br>（1）目前的LLM在很多场景都有应用，在端侧设备要部署一个小型的LLM来做本地会议纪要总结，这样子的小型LLM往往降智比较厉害，针对特定任务有什么比较好的优化手段吗？

2.  传统算法<br><br>（1） 隔空手势操作屏幕上的内容<br>（2）OCR字符识别，识别数学、化学公式等<br>（3）智能笔远距离划线画圈批注
    

1 除了sensevoice 模型的类别也挺多的，但是针对MTK这个平台流程都是类似的，不同模型在步骤上的差异   预处理、后处理都是不同的，模型结构适配是重点工作，由于芯片不支持动态形状<br>2  关于目标芯片平台，我确实还有RKNN的，他们的流程差异比较大(主要体现在.pt—>.onnx—>.rknn  转换的工具不一样，他们都有自己各自的工具，但是我可以提前安装好在对应的conda环境中，其他的差异不大)，我想的是把他们分开<br> 3  希望 skill 完全自动化整个流程(分开为python端和C++端，这两个单独自动化整个流程)  对于模型结构适配（如自定义 torch\_model.py），这部分每次都需要大量调整这是无法避免的，因为要保证后续的流程正确，第一步的正确性至关重要<br>4 模型结构适配、以及复刻python端的C++代码实现，非常容易出问题，也耗时<br>5 我提到的路径和工具（NDK、SDK、OnnxRuntime等）在你的其他项目中都是固定的<br>

---

### WSL空间压缩回收

diskpart<br>select vdisk file="C:\\Users\\HP\\AppData\\Local\\Packages\\CanonicalGroupLimited.Ubuntu22.04LTS\_79rhkp1fndgsc\\LocalState\\ext4.vhdx"<br>attach vdisk readonly<br>compact vdisk<br>detach vdisk<br>exit

### Helsinki有两类模型预处理架构不一样

标准模型 opus-mt-xx-xx（使用 BPE + 查vocab.txt）<br>大模型 opus-mt-tc-big-xx-xx (使用 sentensePiece处理token)

我最近在了解claude code的subagent 来提高我的工作效率，以及产出的稳定性 ，我是做算法移植的，需要把一些.pt/pth格式的AI算法移植到端侧设备，这个过程是极其复杂的，不同的平台移植的过程会有点不一样，但是基本的步骤都是一致的（Python端、C++端，Android端），细节不一样，我主要做RKNN、MTK这两个平台的转换移植工作，现在拿MTK举例。我目前把这个工作的具体执行部分分成了三个步骤，假设前置工作已经做好，包括模型的下载，测试数据准备、conda环境的安装测试等<br>（1）Python端 .pth/pt 原始模型的推理测试， 这里需要拿到官方的模型架构定义（直接从源码copy过来），方便进行推理测试，分析那些结构NPU不能执行需要单独拆解出来交给CPU处理，以及检查NPU芯片支持的算子后，分析那些算子是不支持的、分析完成后修改调整原始模型架构，使其适应后续NPU的加速推理，这一步非常关键，修改调整后保存为xxx\_model.py，这一步完成之后将.pt/pth重行导出为.pt格式，在推理测试新的.pt输出正常后，再转换为.tflite测试.tflite没问题后，在转换为.dla格式至此Python端的工作就完成了，整个过程遵循一步一检查的方式。<br>（2）C++端 ，把前面的Python端，推理代码转换为C++推理代码，并使用正确的MTK NPU  API调用，完成后编译成可执行文件<br>（3）Android端 把上一步C++端的可执行文件，推送到Android设备完成推理测试<br>这是基本的步骤，再开始之前我会提供详细的信息<br><br>比如（MTK一个算法移植的案例）：

Real-ESRGAN移植到MTK NPU推理测试

1 完整且丰富的上下文

\*\*\*\*目标：\*\*\*\*Real-ESRGAN移植到MTK MT8371这块芯片上用NPU跑起来，推送到检测到的Android设备在Android环境下完成测试。

**历史以及计划**： 整个移植的流程可以分为三个大的步骤

\*\*第一步（python端）：\*\*从pytorch.bin(如果有的话)/pt—>tflite—>dla (1) 每个环节需要单独的转换脚本，需要的转换脚本：step1\_pt\_to\_torchscript.py、step2\_torchscript\_to\_tflite.py、step3\_tflite\_to\_dla.py 可以参考下rk的realesrgan 项目它里面有原始模型的架构定义，模型数据权重、测试图片等以及对应的推理代码 (2) 每个转换节点完成后需要单独测，需要的测试脚本：test\_pytorch.py 、test\_pt.py、test\_tflite.py 这个部分的test\_pytorch.py可以直接复制rk项目的realesrgan的test\_pytorch.py (3)最后完整的对比不同格式模型差异，测试对比每个格式模型的差异：test\_compare.py （即拿到.pt 和 .tflite格式都推理测试一遍，检查输出）是否正确，正确后在进行下一个节点的转换（dla文件除外，后面C++端再做验证）参考edsr的目录格式重组，以及edsr项目的python代码，工作主要在python端。 \*\*第二步（C++端）：\*\*将python推理代码，转换为C++推理代码 (1) 这部分参考rk的realesrgan项目的C++部分相关代码，以及edsr项目了解MTK API接口是如何调用的，使用正确的MTK API接口替换RKNN API接口进行推理。 \*\*第三步（Android端）：\*\*编译好相关的C++代码（针对MT8371平台），推送到检测到的Android设备完成推理测试。

目前的环境: conda环境  MTK-superResolution  python =3.10  ，需要切换过去，安装其他的所需依赖。 其他资源目录如下： (1)MTK SDK: /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk (2) 目标平台MT8371 运行所需要到运行时库文件：  /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk/mt8371 (3)Android NDK：/home/xh/Android/Ndk/android-ndk-r25c (4)Android SDK：/home/xh/Android/Sdk (5)OnnxRuntime：/home/xh/Android/OnnxRuntime/onnxruntime-android-1.17.1 (6)第三方库文件及工具：/home/xh/projects/MTK/1\_third\_party    /home/xh/projects/MTK/2\_utils (7)MTK DLA支持的算子信息列表：~/.mtk\_mdla\_operators.md (8) 中央知识库（已知问题和最佳实践）:~/.mtk\_npu\_knowledge\_base.md (9) rk realesrgan项目：/home/xh/projects/MTK/superResolution/realesrgan/rknn

2 当前的意图： （1）参考mtk/edsr项目，新建目录结构，检查环境，安装移植算法必要的依赖 （2）根据计划先完成python端的工作，有问题在分析解决， （3）完成Python端的工作后，我逐一检查输出结果，没有问题后，我在给出具体的下一步任务

3 注意事项以及限制：

（1）由于算法模型要跑在MTK NPU上，没办法一步实现端到端的输出，所以导出模型的中间格式tflite以及转换后的dla格式，都只负责推理，前处理和后处理都需要分离出来单独处理（其他的案例都是这么做的） （2）如果导出的模型没办法正常工作，或者报错了，那么可能是算子不支持的问题，就要我们自己定义模型机构或者修改算子，再重新导出来重新测试（我们先像其他案例一样，按照一般的方法正常导出），Helsinki这个案例就是这么做的/home/xh/projects/MTK/helsinki （3）由于MTK NPU不支持动态形状，所以在转换为tflite格式的时候就得输入固定形状(510 x 339) （4）对于有参考代码的部分，能复用就复用，这样不用重复造轮子，效率和准确性也能有效提升

<br>你可以看看我的这些项目基本就是按这个流程这么做的，/home/xh/projects/MTK/superResolution<br>

我要如何来设计呢，我们深度思考讨论一下