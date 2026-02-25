## AI算法 移植到MTK NPU完整流程（包含提示词和skills——以senseVoice为案例 ）

**1 完整且丰富的上下文**

**\*\*目标\*\***：我的最终目标是，把senseVoiceSmall这个模型跑在MTK 的MT8371这款芯片的NPU上，实现端到端的语音输入、文本输出。

**\*\*历史以及计划\*\*：为了实现这个目标我分为了两个大步骤。<br><br>第一步： 将模型编译转换为为MTK NPU 支持的.dla格式（已完成）。**<br>详细工作内容：工作目录在SenseVoice\_workspace，在model\_prepare目录下依次运行对应的脚本，也可以执行python脚本（0\_run.sh、1\_save\_pt.sh、2\_pt2tflite.sh）<br>（1）将senseVoiceSmall模型 从pytorch格式导出为.pt格式(这一步非常关键，需要自定义模型的结构来适配芯片的算子什么的torch\_model.py就是自定义的结构，导出完成后需要和原始pytorch对比输出是否一致，最好是将导出的.pt和huggface实现对比每一层的数据输出是否一致，这样才能确保最后的.pt是没问题的，进而保证后续的流程正确)<br>（2）再转换为.tflite格式（这里要用到MTK自定义的工具，包含了他自定义的算子，标准的tf会报错）<br>（3）验证完.pt、.tflite格式模型的输出正确且一致（test\_converted\_models）<br>（4）最终经过编译脚本（compile/compile\_sensevoice\_fp.sh）由.tflite格式转化为 MTK NPU支持的.dla格式。**<br><br>第二步：编写C++推理代码，完整复现python端的推理过程，编译成可执行文件，加载.dla文件以及必要的测试文件，推送到Android设备完成测试。（已完成）**<br>计划的详细工作内容：工作目录在 sensevoice\_mtk\_cpp<br>（1）参考/home/xh/projects/sherpa-onnx/sherpa-onnx/csrc/rknn/     这个目录下的offline-sense-voice-model-rknn.cc   和 offline-sense-voice-model-rknn.h 这里应该有验证过的推理过程，只是这个是适配RKNN芯片<br>（2）需要参考 /home/xh/projects/MTK/GAI-Deployment-Toolkit-v2.0.2\_clip-text-v0.1/inference/jni/src  这个项目中 正确的MTK NPU接口的调用，替换掉（1）中错误的接口调用<br>（3）编译的时候参考 /home/xh/projects/MTK/GAI-Deployment-Toolkit-v2.0.2\_clip-text-v0.1/inference  它有对应的shell脚本(.bat文件)，以及编译的过程，以及文件，需要的第三方库文件，如果这个这个目录没有，接下来，我会给出，如果不够，你在询问我我会提供给你。

**\*\*目前的环境\*\***：conda 环境 MTK-sensevoice ,必要的环境和工具都已经安装，参考的资源目录汇总如下：<br>(1)MTK SDK: /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk<br>(2)NDK：/home/xh/Android/Ndk/android-ndk-r25c<br>(3)SDK：/home/xh/Android/Sdk<br>(4)OnnxRuntime：/home/xh/Android/OnnxRuntime/onnxruntime-android-1.17.1<br>(5)C++推理代码：/home/xh/projects/sherpa-onnx/sherpa-onnx/csrc/rknn/     /home/xh/projects/MTK/GAI-Deployment-Toolkit-v2.0.2\_clip-text-v0.1/inference/jni/src<br>(6) MTK调用接口：/home/xh/projects/MTK/GAI-Deployment-Toolkit-v2.0.2\_clip-text-v0.1/inference/jni/src<br>(7)第三方库：/home/xh/projects/MTK/1\_third\_party/kaldi\_native\_fbank（sensevoice音频处理）

**2 当前的意图/任务**

（1）在github建一个新的公开仓库  MTK-sense-voice 先把 /home/xh/projects/MTK/sense-voice 这个目录的代码，推送到github方便还原回滚记录(注意只推送代码，大的文件，留在本地)<br>（2）在/home/xh/projects/MTK/GAI-Deployment-Toolkit-v2.0.2\_clip-text-v0.这个项目中测试  /home/xh/projects/MTK/sense-voice/SenseVoice\_workspace/compile/sensevoice\_MT8371.dla 这个dla文件能否正常加载，工作<br>（3）复现一遍已完成的部分，第一步的步骤，检测测试没问题，将模型编译转换为为MTK NPU 支持的.dla格式，<br>（4）你来帮我完成整个测试，并推送到检测到的Android设备，观察输出结果，有问题就分析解决<br>（5）请你完全参照这个/home/xh/projects/MTK/GAI-Deployment-Toolkit-v2.0.2\_clip-text-v0.1 项目的形式来操作，编译可执行代码，推送到Android测试，因为在之前的对话中已经证实过了他能正常运行到我的Android设备，只有完整复刻他的方式才能更好的发现问题定位问题

**3  约束：有哪些限制或要求？**

**4 辅助视觉：截图、录屏或图表（如适用）**

## MTK  NPU  senseVoice模型集成到sherpa-onnx 框架工作流程

**1 完整且丰富的上下文<br>**

**\*\*目标\*\***：我现在已经验证过了这个senseVoice模型可以在MTK NPU上运行，现在我需要把sensevoice\_mtk\_cpp这个目录的C++代码集成到 sherpa-onnx(/home/xh/projects/sherpa-onnx)这个框架，方便我后续的开发

**\*\*历史以及计划\*\*：**<br>（1）添加senseVoice对MTK的C++支持代码：在/home/xh/projects/sherpa-onnx/sherpa-onnx/csrc这个目录新建mtk目录像rknn和qnn这两个目录一样（在迁移代码的时候需要注意，MTK 运行时的库文件是需要动态加载，我之前测试过只有这个版本的代码才能成功）<br>（2）由于添加了senseVoice对MTK的C++支持代码，其他的地方也需要同步修改，上层kotlin才能正常调用，但是我不确定需要改动那些地方，请你帮我判断，需要的话添加修改<br>（3）重行编译整个项目的C++代码，/home/xh/projects/sherpa-onnx/build-android-rknn.sh 这个是我之前编译过的，针对的是rknn这个平台，另外MTK运行需要的相关的包也要拿过来编译或者加进来，避免报错<br>（4）把/home/xh/projects/AI-real-time-ASR-Translate-SpeakerID/SherpaOnnxSimulateStreamingAsr编译成apk文件，推送到Android设备测试①/assets/sense-voice-mtk 我已经把对应的文件放进去了，包括sensevoice-10s.dla和tokens.txt② 在/home/xh/projects/AI-real-time-ASR-Translate-SpeakerID/SherpaOnnxSimulateStreamingAsr/app/src/main/java/com/k2fsa/sherpa/onnx/OfflineRecognizer.kt这个文件添加了以下代码（需要你检查一下是否和我们的代码适配） 1000 -> { // MTK SenseVoice - 中英日韩粤多语言识别 return OfflineModelConfig( senseVoice = OfflineSenseVoiceModelConfig( model = "modelDir/tokens.txt", provider = "mtk", // 🔑 关键：使用 MTK NPU numThreads = 1, // MTK NPU 模式下使用 1 线程 ) }③ 观察日志查看输出

**\*\*目前的环境**：conda环境  MTK-sensevoice，其他资源目录如下：<br>(1)NDK：/home/xh/Android/Ndk/android-ndk-r25c<br>(2)SDK：/home/xh/Android/Sdk<br>(3)OnnxRuntime：/home/xh/Android/OnnxRuntime/onnxruntime-android-1.17.1<br>(4) sensevoice\_mtk\_cpp项目路径：/home/xh/projects/MTK/sense-voice/sensevoice\_mtk\_cpp<br>(5)sherpa-onnx项目路径：/home/xh/projects/sherpa-onnx

**2 当前的意图/任务**

我目前已经完成好了（1）（2）（3），现在的意图是焦距第（4）的工作

（1）需要重新编译/home/xh/projects/sherpa-onnx/build-android-mtk.sh，利用用生成的sherpa-onnx-offline 文件测试 senseVoice可以在MTK平台正常通过测试<br>（2）sherpa-onnx-offline 文件测试通过后，把/home/xh/projects/AI-real-time-ASR-Translate-SpeakerID/SherpaOnnxSimulateStreamingAsr编译成apk文件，推送到Android设备测试

①这样吧，我们先继续未完成的任务第四部（4）把/home/xh/projects/AI-real-time-ASR-Translate-SpeakerID/SherpaOnnxSimulateStreamingAsr编译成apk文件，推送到Android设备测试。。。由于我们验证过了通过命令行可以正常工作，我们先测试apk文件没问题，我们回过头再来处理这个问题，也像rknn这样来处理运行时库文件实现 统一处理

②回过头来解决MTK处理从内存加载模型而不是复制 assets 到文件系统在访问的方式

## Helsinki 算法 移植到 MTK NPU上

1 完整且丰富的上下文

\*\***目标**：\*\*我想把当前的用onnxruntime 跑在CPU上的Helsinki 算法 移植到 MTK NPU上跑起来，然后推送到检测到的Android设备完成推理测试。

**历史以及计划**： 整个移植的流程可以分为两个大的步骤<br>第一步：从pytorch—>tflite—>dla，每个节点完成后需要测试是否正确（dla文件除外）参考sensevoice（SenseVoice\_workspace）、clip-text（model\_prepare）项目python部分的过程以及相关代码，工作主要在python端

第二步：将python推理代码，转化为C++推理代码，这部分参考sensevoice项目的C++部分（sensevoice\_mtk\_cpp）过程以及相关代码，了解MTK接口是如何调用的

\*\*\*\*目前的环境：\*\*\*\*conda环境  MTK-helsinki  python =3.10  需要创建复制一份MTK-clip-encoder的环境，然后安装其他的所需依赖。<br>其他资源目录如下：

(1)MTK SDK: /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk<br>(2) 目标平台MT8371 运行所需要到库文件：  /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk/mt8371<br>(3)Android NDK：/home/xh/Android/Ndk/android-ndk-r25c<br>(4)Android SDK：/home/xh/Android/Sdk<br>(5)OnnxRuntime：/home/xh/Android/OnnxRuntime/onnxruntime-android-1.17.1<br>(6) sensevoice\_mtk\_cpp项目路径：/home/xh/projects/MTK/sense-voice/sensevoice\_mtk\_cpp<br>(7)SenseVoice\_workspace工作路径:/home/xh/projects/MTK/sense-voice/SenseVoice\_workspace<br>(8)clip-text工作路径：/home/xh/projects/MTK/GAI-Deployment-Toolkit-v2.0.2\_clip-text-v0.1/model\_prepare<br>(9)Helsinki C++推理算法目录路径：/home/xh/projects/Local-multilingual-real-time-speech-recognition-and-real-time-subtitle-translation/translate/helsinki-onnx

**2 当前的意图/任务**

conda环境已创建，切换过去,工作目录在/home/xh/projects/MTK/helsinki

现在我想 把 /home/xh/projects/MTK/helsinki/helsinki\_workspace 这个目录中的代码跑一遍，测试.pt .tflite格式的导出，以及验证他们的正确性，没问题后再编译成dla文件，先清理以下已经存在的文件

建立两个子目录helsinki\_workspace、helsinki\_mtk\_cpp，，在按照规划一步步完成任务，有需要我补充的再询问提示我

(1)MTK SDK: /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk<br>(2) 目标平台MT8371 运行所需要到库文件在  /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk/mt8371，有需要你可以获取<br>(3) C++推理代码其实已经实现了在/home/xh/projects/Local-multilingual-real-time-speech-recognition-and-real-time-subtitle-translation/translate/helsinki-rknn/cpp，只是这个是针对CPU onnxruntime的，需要改造来适配MTK NPU，或者你有更好的想法和方案也可尝试<br>现在请你进行编译转换成dla操作

C++推理代码其实已经实现了在/home/xh/projects/Local-multilingual-real-time-speech-recognition-and-real-time-subtitle-translation/translate/helsinki-rknn/cpp，只是这个是针对CPU onnxruntime的，需要改造来适配MTK NPU，而MTK NPU的接口调用可以参考/home/xh/projects/MTK/sense-voice/sensevoice\_mtk\_cpp 它里面有，你目前是这么来工作的吗，如果是请你继续

**3  约束：有哪些限制或要求**？

**4 辅助视觉：截图、录屏或图表（如适用）**

![pasted_image_cf186628-3b31-49c4-ab16-b4b4134f2cd2.png](file://C:\Users\HP\AppData\Roaming\CherryStudio\Data\Files\cf186628-3b31-49c4-ab16-b4b4134f2cd2.png)![pasted_image_ec46c1e3-dac4-4bbb-a709-8652ae690a15.png](file://C:\Users\HP\AppData\Roaming\CherryStudio\Data\Files\ec46c1e3-dac4-4bbb-a709-8652ae690a15.png)

## facebook/m2m100\_418M 算法 移植到 MTK NPU上

**1 完整且丰富的上下文**

**\*\*目标：\*\***我想把m2m100\_418M 算法 移植到 MTK NPU上跑起来，然后推送到检测到的Android设备完成推理测试。

**历史以及计划：** 整个移植的流程可以分为两个大的步骤<br>第一步（python端）：从pytorch.bin—>pt—>tflite—>dla，每个转换节点完成后需要单独测试是否正确，正确后在进行下一个节点的转换（dla文件除外,后面C++端再做验证）参考Helsinki（Helsinki\_workspace）（model\_prepare）项目python部分的过程以及相关代码，工作主要在python端，之所以参考他是因为他们的都是 标准Transform架构，encoder-decoder。这个过程需要注意，需要重新导出模型，导出的是带k v cache的版本，pt—>tflite这里会用到mtk自定义的算子来转换，有可能会失败，失败了需要重新调整导出代码，MTK/helsinki/PORTING\_NOTES.md  这个文件是Helsinki模型在移植到MTK NPU遇到的一些问题，以及解决方案。

**第二步（C++端）：**将python推理代码，转化为C++推理代码，这部分参考Helsinki项目的C++部分（Helsinki\_mtk\_cpp）过程以及相关代码，了解MTK接口是如何调用的。

**\*\*目前的环境：\*\***conda环境  MTK-m2m100  python =3.10  需要创建复制一份MTK-clip-helsinki的环境，然后安装其他的所需依赖。 其他资源目录如下：

(1)MTK SDK: /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk<br>(2) 目标平台MT8371 运行所需要到库文件：  /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk/mt8371<br>(3)Android NDK：/home/xh/Android/Ndk/android-ndk-r25c<br>(4)Android SDK：/home/xh/Android/Sdk<br>(5)OnnxRuntime：/home/xh/Android/OnnxRuntime/onnxruntime-android-1.17.1<br>(6) helsinki\_mtk\_cpp项目路径：/home/xh/projects/MTK/helsinki/helsinki\_mtk\_cpp<br>(7)helsinki\_workspace工作路径:/home/xh/projects/MTK/helsinki/helsinki\_workspace<br>(8)sentensePiece: /home/xh/projects/MTK/1\_third\_party/sentencepiece<br>

**2 当前的意图/任务**

先切换conda环境，切换过去,我目前已经完成了，python端的工作，但是我有个疑问，为什么说“由于 MT8371 MDLA 限制维度 <= 65535，而 M2M100 的 vocab\_size=128112， lm\_head 层无法在 NPU 上执行”，这个结论怎么得出来的，以及我现在要进行第二步完成C++端的工作，我得采用不带lmhead的版本嘛

先创建复制conda环境，切换过去,工作目录需要创建，在/home/xh/projects/MTK/m2m100，建立两个子目录m2m100\_workspace、m2m100\_mtk\_cpp，在按照规划一步步完成任务，我们先完成第一步python端的任务，下载模型的时候，使用modelscope   [https://www.modelscope.cn/models/facebook/m2m100\_418M/files](https://www.modelscope.cn/models/facebook/m2m100_418M/files)  我们只需要pytorch.bin的权重文件，过滤掉其他格式大的权重文件，加速下载，有需要我补充的再询问提示我

现在我想 把 /home/xh/projects/MTK/helsinki/helsinki\_workspace 这个目录中的代码跑一遍，测试.pt .tflite格式的导出，以及验证他们的正确性，没问题后再编译成dla文件，先清理以下已经存在的文件

建立两个子目录helsinki\_workspace、helsinki\_mtk\_cpp，，在按照规划一步步完成任务，有需要我补充的再询问提示我

(1)MTK SDK: /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk

(2) 目标平台MT8371 运行所需要到库文件在  /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk/mt8371，有需要你可以获取<br>(3) C++推理代码其实已经实现了在/home/xh/projects/Local-multilingual-real-time-speech-recognition-and-real-time-subtitle-translation/translate/helsinki-rknn/cpp，只是这个是针对CPU onnxruntime的，需要改造来适配MTK NPU，或者你有更好的想法和方案也可尝试 现在请你进行编译转换成dla操作

C++推理代码其实已经实现了在/home/xh/projects/Local-multilingual-real-time-speech-recognition-and-real-time-subtitle-translation/translate/helsinki-rknn/cpp，只是这个是针对CPU onnxruntime的，需要改造来适配MTK NPU，而MTK NPU的接口调用可以参考/home/xh/projects/MTK/sense-voice/sensevoice\_mtk\_cpp 它里面有，你目前是这么来工作的吗，如果是请你继续

**3  约束：有哪些限制或要求？**

**4 辅助视觉：截图、录屏或图表（如适用）**

## EDSR、RCAN移植到MTK NPU推理测试

**1 完整且丰富的上下文**

**\*\*目标\*\***：EDSR、RCAN移植到MTK MT8371这块芯片上用NPU跑起来，推送到检测到的Android设备在Android环境下完成测试。

**\*\*历史以及计划\*\***： 整个移植的流程可以分为三个大的步骤

**第一步（python端）：从pytorch.bin(如果有的话)/pt—>tflite—>dla**<br>(1) 每个环节需要单独的转换脚本，需要的转换脚本：step1\_pt\_to\_torchscript.py、step2\_torchscript\_to\_tflite.py、step3\_tflite\_to\_dla.py<br>(2) 每个转换节点完成后需要单独测，需要的测试脚本：test\_pytorch.py 、test\_pt.py、test\_tflite.py<br>(3)最后完整的对比不同格式模型差异，测试对比每个格式模型的差异：test\_compare.py<br>（即拿到.pt 和 .tflite格式都推理测试一遍，检查输出）是否正确，正确后在进行下一个节点的转换（dla文件除外，后面C++端再做验证）参考Helsinki 的目录格式重组，以及rk的edsr/rcan项目的python代码，工作主要在python端。<br>**第二步（C++端）：将python推理代码，转换为C++推理代码**<br>(1) 这部分参考rk的edsr/rcan项目的C++部分相关代码，以及Helsinki项目了解MTK API接口是如何调用的，使用正确的MTK API接口，替换RKNN接口。<br>**第三步（Android端）：编译好相关的C++代码（针对MT8371平台），推送到检测到的Android设备完成推理测试。**

**\*\*目前的环境\*\***: conda环境  MTK-superResolution  python =3.10  ，需要清理，在重新创建（clone 一份conda环境 MTK-clip-encoder），安装其他的所需依赖。<br>推理测试代码，MTK/MTKSuperResolution/infer.py，模型数据以及测试图片在MTK/MTKSuperResolution/data。<br>其他资源目录如下：<br>(1)MTK SDK: /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk<br>(2) 目标平台MT8371 运行所需要到运行时库文件：  /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk/mt8371<br>(3)Android NDK：/home/xh/Android/Ndk/android-ndk-r18b<br>(4)Android SDK：/home/xh/Android/Sdk<br>(5)OnnxRuntime：/home/xh/Android/OnnxRuntime/onnxruntime-android-1.17.1<br>(6)第三方库文件及工具：/home/xh/projects/MTK/1\_third\_party    /home/xh/projects/MTK/2\_utils<br>(7)MTK DLA支持的算子信息列表：~/.mtk\_mdla\_operators.md<br>(8) 中央知识库（已知问题和最佳实践）:~/.mtk\_npu\_knowledge\_base.md<br>(9) rk edsr项目：/home/xh/projects/rknn\_model\_zoo/examples/edsr<br>(10)rk rcan项目：/home/xh/projects/rknn\_model\_zoo/examples/rcan<br>(11)Helsinki项目：/home/xh/projects/MTK/helsinki

**2 当前的意图**：<br>（1）参考Helsinki项目，新建目录结构，检查环境，安装移植算法必要的依赖，推理测试.pt格式能正常推理输出，没有异常<br>（2）先完成edsr算法的移植，根据计划先完成python端的工作，有问题在分析解决，<br>（3）有任何缺少缺失的文件都和我需要我提供帮助的地方记得及时和我沟通

**3 注意事项以及限制**：<br>（1）由于算法模型要跑在MTK NPU上，没办法一步实现端到端的输出，所以导出模型的中间格式tflite以及转换后的dla格式，都只负责推理，前处理和后处理都需要分离出来单独处理（其他的案例都是这么做的）<br>（2）如果导出的模型没办法正常工作，或者报错了，那么可能是算子不支持的问题，就要我们自己定义模型机构或者修改算子，再重新导出来重新测试（我们先像其他案例一样，按照一般的方法正常导出），Helsinki这个案例就是这么做的/home/xh/projects/MTK/helsinki<br>（3）由于MTK NPU不支持动态形状，所以在转换为tflite格式的时候就得输入固定形状(510 x 339)<br>（4）我们再转tflite格式以及用tflite格式模型推理测试的时候都得用MTK提供的它自己的工具，不能用标准的tflite工具，不然会报错，他有他自定义的算子，MTK他的工具已经集成在环境中了<br>（5）对于有参考代码的部分，能复用就复用，这样不用重复造轮子，效率和准确性也能有效提升

## Real-ESRGAN移植到MTK NPU推理测试

**1 完整且丰富的上下文**

**目标：Real-ESRGAN移植到MTK8371这块芯片上用NPU跑起来，推送到检测到的Android设备在Android环境下完成测试。**

**历史以及计划**： 整个移植的流程可以分为三个大的步骤

**\*\*第一步（python端）：\*\*从pytorch.bin(如果有的话)/pt—>tflite—>dla**<br>(1) 每个环节需要单独的转换脚本，需要的转换脚本：step1\_pt\_to\_torchscript.py、step2\_torchscript\_to\_tflite.py、step3\_tflite\_to\_dla.py。<br>可以参考下rk的realesrgan 项目它里面有原始模型的架构定义，模型数据权重、测试图片等以及对应的推理代码。<br>(2) 每个转换节点完成后需要单独测，需要的测试脚本：test\_pytorch.py 、test\_pt.py、test\_tflite.py。<br>这个部分的test\_pytorch.py可以直接复制rk项目的realesrgan的test\_pytorch.py。<br>(3)最后完整的对比不同格式模型差异，测试对比每个格式模型的差异：test\_compare.py （即拿到.pt 和 .tflite格式都推理测试一遍，检查输出）是否正确，正确后在进行下一个节点的转换（dla文件除外，后面C++端再做验证）。<br>参考edsr的目录格式重组，以及edsr项目的python代码，工作主要在python端。<br>**\*\*第二步（C++端）：\*\*将python推理代码，转换为C++推理代码**<br>(1) 这部分参考rk的realesrgan项目的C++部分相关代码，以及edsr项目了解MTK API接口是如何调用的，使用正确的MTK API接口替换RKNN API接口进行推理。<br>**\*\*第三步（Android端）：\*\*编译好相关的C++代码（针对MT8371平台），推送到检测到的Android设备完成推理测试。**

**目前的环境**: conda环境  MTK-superResolution  python =3.10  ，需要切换过去，安装其他的所需依赖。<br>其他资源目录如下：<br>(1)MTK SDK: /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk<br>(2) 目标平台MT8371 运行所需要到运行时库文件：  /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk/mt8371<br>(3)Android NDK：/home/xh/Android/Ndk/android-ndk-r25c<br>(4)Android SDK：/home/xh/Android/Sdk<br>(5)OnnxRuntime：/home/xh/Android/OnnxRuntime/onnxruntime-android-1.17.1<br>(6)第三方库文件及工具：/home/xh/projects/MTK/1\_third\_party<br>(7)第三方工具： /home/xh/projects/MTK/2\_utils<br>(8)MTK DLA支持的算子信息列表：/home/xh/projects/MTK/.claude/doc/mtk\_mdla\_operators.md<br>(9) 中央知识库（已知问题和最佳实践）:/home/xh/projects/MTK/.claude/doc/mtk\_npu\_knowledge\_base.md<br>(10) rk realesrgan项目：/home/xh/projects/MTK/superResolution/realesrgan/rknn

**2 当前的意图：**<br>（1）参考mtk/edsr项目，新建目录结构，检查环境，安装移植算法必要的依赖<br>（2）根据计划先完成python端的工作，有问题在分析解决，<br>（3）完成Python端的工作后，我逐一检查输出结果，没有问题后，我在给出具体的下一步任务

**3 注意事项以及限制：**

（1）由于算法模型要跑在MTK NPU上，没办法一步实现端到端的输出，所以导出模型的中间格式tflite以及转换后的dla格式，都只负责推理，前处理和后处理都需要分离出来单独处理（其他的案例都是这么做的）<br>（2）如果导出的模型没办法正常工作，或者报错了，那么可能是算子不支持的问题，就要我们自己定义模型机构或者修改算子，再重新导出来重新测试（我们先像其他案例一样，按照一般的方法正常导出），Helsinki这个案例就是这么做的/home/xh/projects/MTK/helsinki<br>（3）由于MTK NPU不支持动态形状，所以在转换为tflite格式的时候就得输入固定形状(510 x 339)<br>（4）对于有参考代码的部分，能复用就复用，这样不用重复造轮子，效率和准确性也能有效提升<br>（5）我们再转tflite格式以及用tflite格式模型推理测试的时候都得用MTK提供的它自己的工具，不能用标准的tflite工具，不然会报错，他有他自定义的算子，MTK他的工具已经集成在环境中了<br>（6）Real-ESRGAN是基于RRDB（Residual in Residual Dense Block）的纯CNN架构，主要使用的算子都是常规卷积操作（Conv2d、LeakyReLU、Add等），这些算子MTK支持都很好。需要注意的算子：PixelShuffle（用于上采样）、LeakyReLU（激活函数）。导出TFLITE前需确认。<br>（7）Real-ESRGAN的前处理：通常需要归一化到[0,1]范围；后处理：输出需要clip到[0,1]范围，需要×255转回uint8。这些都需要在模型外部单独实现。

## whisper 移植到MTK NPU推理测试

<br>（查看MTK\_models\_zoo/.claude/subagents/README.md  根据readme.md完成任务）

**1 完整且丰富的上下文**

\*\*目标：\*\*whisper移植到MTK8371这块芯片上用NPU跑起来，推送到检测到的Android设备在Android环境下完成测试。

**历史以及计划**： 整个移植的流程可以分为三个大的步骤

**\*\*第一步（python端）**\*\*：**从pytorch.bin(如果有的话)/pt—>tflite—>dla<br>**(1) 每个环节需要单独的转换脚本，需要的转换脚本：step1\_pt\_to\_torchscript.py、step2\_torchscript\_to\_tflite.py、step3\_tflite\_to\_dla.py。<br>可以把openai whisper官方仓库  clone下来，再下载base模型，它里面有原始模型的架构定义，模型数据权重、测试数据等以及对应的推理代码。<br>(2) 每个转换节点完成后需要单独测，需要的测试脚本：test\_pytorch.py 、test\_pt.py、test\_tflite.py。<br>这个部分的test\_pytorch.py可以参考whisper官方项目的python推理脚本。<br>(3)最后完整的对比不同格式模型差异，测试对比每个格式模型的差异：test\_compare.py （即拿到.pt 和 .tflite格式都推理测试一遍，检查输出）是否正确，正确后在进行下一个节点的转换（dla文件除外，后面C++端再做验证）<br>参考edsr/mtk的目录格式重组，工作主要在python端。**<br><br>\*\*第二步（C++端）：\*\*将python推理代码，转换为C++推理代码<br>**(1) 这部分参考rk的whisper项目的C++部分相关代码以及复用他用到的第三方库，严格复刻python端的行为（test\_torchscript.pt）以及edsr项目了解MTK API接口是如何调用的，使用正确的MTK API接口替换RKNN API接口进行推理。**<br>**

**\*\*第三步（Android端）：\*\*\*\*编译好相关的C++代码（针对MT8371平台），推送到检测到的Android设备完成推理测试。**

**目前的环境：** conda环境  MTK-whisper  python =3.10  ，需要clone一份MTK-clip-encoder，然后切换过去，安装其他的所需依赖。 其他资源目录如下：<br>(1)MTK SDK: /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk<br>(2) 目标平台MT8371 运行所需要到运行时库文件：  /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk/mt8371<br>(3)Android NDK：/home/xh/Android/Ndk/android-ndk-r25c<br>(4)Android SDK：/home/xh/Android/Sdk<br>(5)OnnxRuntime：/home/xh/Android/OnnxRuntime/onnxruntime-android-1.17.1<br>(6)第三方库文件：/home/xh/projects/MTK/1\_third\_party <br>(7)第三方工具： /home/xh/projects/MTK/2\_utils<br>(8)MTK DLA支持的算子信息列表：/home/xh/projects/MTK/.claude/doc/mtk\_mdla\_operators.md<br>(9) 中央知识库（已知问题和最佳实践）:/home/xh/projects/MTK/.claude/doc/mtk\_npu\_knowledge\_base.md<br>(10) rk whisper项目：/home/xh/projects/rknn\_model\_zoo/examples/whisper

**2 当前的意图：**<br>（1）参考mtk/edsr项目，新建目录结构，检查环境，安装移植算法必要的依赖<br>（2）根据计划先完成python端的工作（带 k v cache），有问题在分析解决，<br>（3）完成Python端的工作后，我逐一检查输出结果，没有问题后，我在给出具体的下一步任务

**3 注意事项以及限制：**

（1）由于算法模型要跑在MTK NPU上，没办法一步实现端到端的输出，所以导出模型的中间格式tflite以及转换后的dla格式，都只负责推理，前处理和后处理都需要分离出来单独处理（其他的案例都是这么做的）<br>（2）如果导出的模型没办法正常工作，或者报错了，那么可能是算子不支持的问题，就要我们自己定义模型机构或者修改算子，再重新导出来重新测试（我们先像其他案例一样，按照一般的方法正常导出），Helsinki这个案例就是这么做的/home/xh/projects/MTK/helsinki<br>（3）由于MTK NPU不支持动态形状，所以在转换为tflite格式的时候就得输入固定形状(30s)<br>（4）对于有参考代码的部分，能复用就复用，这样不用重复造轮子，效率和准确性也能有效提升<br>（5）我们再转tflite格式以及用tflite格式模型推理测试的时候都得用MTK提供的它自己的工具，不能用标准的tflite工具，不然会报错，他有他自定义的算子，MTK他的工具已经集成在环境中了

## SwinIR 移植到MTK NPU推理测试

（查看MTK\_models\_zoo/.claude/subagents/README.md  根据readme.md完成任务）

**1 完整且丰富的上下文**

**\*\*目标：\*\***SwinIR移植到MTK8371这块芯片上用NPU跑起来，推送到检测到的Android设备在Android环境下完成测试。

**历史以及计划：** 整个移植的流程可以分为三个大的步骤

**第一步（python端）**：从pytorch.bin(如果有的话)/pt—>tflite—>dla<br>(1) 每个环节需要单独的转换脚本，需要的转换脚本：step1\_pt\_to\_torchscript.py、step2\_torchscript\_to\_tflite.py、step3\_tflite\_to\_dla.py。<br>把SwinIR官方仓库  clone下来，再下载需要的模型，它里面有原始模型的架构定义，模型数据权重、测试数据等以及对应的推理代码。<br>(2) 每个转换节点完成后需要单独测，需要的测试脚本：test\_pytorch.py 、test\_pt.py、test\_tflite.py。 这个部分的test\_pytorch.py可以参考SwinIR官方项目的python推理脚本。<br>(3)最后完整的对比不同格式模型差异，测试对比每个格式模型的差异：即拿到.pt 格式都推理测试一遍，检查输出，是否正确，正确后在进行下一个节点的转换（dla文件除外，后面C++端再做验证）<br>参考edsr/mtk的目录格式重组，工作主要在python端。

**\*\*第二步（C++端）：\*\***将python推理代码，转换为C++推理代码<br>(1) 这部分参考edsr项目的C++部分相关代码以及复用他用到的第三方库，严格复刻python端的行为（test\_pt.py）以及了解MTK API接口是如何调用的，使用正确的MTK API接口进行推理。

**\*\*第三步（Android端）：\*\***编译好相关的C++代码（针对MT8371平台），推送到检测到的Android设备完成推理测试。

**目前的环境：** conda环境  MTK-superResolution  python =3.10  ，切换过去，安装其他的所需依赖。 其他资源目录如下：<br>(1)MTK SDK: /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk<br>(2) 目标平台MT8371 运行所需要到运行时库文件：  /home/xh/projects/MTK/0\_Toolkits/neuropilot-sdk-basic-8.0.10-build20251029/neuron\_sdk/mt8371<br>(3)Android NDK：/home/xh/Android/Ndk/android-ndk-r25c<br>(4)Android SDK：/home/xh/Android/Sdk (5)OnnxRuntime：/home/xh/Android/OnnxRuntime/onnxruntime-android-1.17.1<br>(6)第三方库文件：/home/xh/projects/MTK/1\_third\_party <br>(7)第三方工具： /home/xh/projects/MTK/2\_utils<br>(8)MTK DLA支持的算子信息列表：/home/xh/projects/MTK/.claude/doc/mtk\_mdla\_operators.md<br>(9) 中央知识库（已知问题和最佳实践）:/home/xh/projects/MTK/.claude/doc/mtk\_npu\_knowledge\_base.md<br>(10)  edsr项目：/home/xh/projects/MTK\_models\_zoo/superResolution/edsr

**2 当前的意图：**<br>（1）参考mtk/edsr项目，新建目录结构(在/home/xh/projects/MTK\_models\_zoo/superResolution下)，检查环境，安装移植算法必要的依赖<br>（2）根据计划先完成python端的工作，有问题在分析解决，<br>（3）完成Python端的工作后，我逐一检查输出结果，没有问题后，我在给出具体的下一步任务

**3 注意事项以及限制：**

（1）由于算法模型要跑在MTK NPU上，没办法一步实现端到端的输出，所以导出模型的中间格式tflite以及转换后的dla格式，都只负责推理，前处理和后处理都需要分离出来单独处理（其他的案例都是这么做的）<br>（2）如果导出的模型没办法正常工作，或者报错了，那么可能是算子不支持的问题，就要我们自己定义模型机构或者修改算子，再重新导出来重新测试（我们先像其他案例一样，按照一般的方法正常导出），Helsinki这个案例就是这么做的/home/xh/projects/MTK/helsinki<br>（3）由于MTK NPU不支持动态形状，所以在转换为tflite格式的时候就得输入固定形状，建议使用(1, 3, 512, 512)作为固定输入尺寸<br>（4）对于有参考代码的部分，能复用就复用，这样不用重复造轮子，效率和准确性也能有效提升<br>（5）我们再转tflite格式以及用tflite格式模型推理测试的时候都得用MTK提供的它自己的工具，不能用标准的tflite工具，不然会报错，他有他自定义的算子，MTK他的工具已经集成在环境中了

<br>