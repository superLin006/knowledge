我想做视频超分任务把EDSR、RCAN移植到rk3576这块芯片上用NPU跑起来，推送到检测到的Android设备在Android环境下完成测试，目前视频超分任务的源码在/home/xh/projects/MTK/MTKSuperResolution，我想先看看目前rk的这些算法案例中那个算法和想移植的算法匹配度比较高，我就参考他来做算法的移植，另外EDSR、RCAN他们是一块的吗，还是分开的两个不同算法

### EDSR、RCAN移植到rk3576 NPU推理测试

**1 完整且丰富的上下文**

\*\*目标：\*\*EDSR、RCAN移植到rk3576这块芯片上用NPU跑起来，推送到检测到的Android设备在Android环境下完成测试。

**\*\*历史以及计划\*\*：** 整个移植的流程可以分为三个大的步骤<br>第一步（python端）：从pytorch.bin(如果有的话)/pt—>onnx—>rknn，每个转换节点完成后需要单独测试（即拿到.pt 和 .onnx格式都推理测试一遍，检查输出）是否正确，正确后在进行下一个节点的转换（rknn文件除外，后面C++端再做验证）参考yolov8 的目录格式重组，工作主要在python端。<br>第二步（C++端）：将python推理代码，转化为C++推理代码，这部分参考yolov8项目的C++部分相关代码，了解RKNN接口是如何调用的，使用正确的RKNN API接口。<br>第三步（Android端）：编译好相关的C++代码（针对RK3576平台），推送到检测到的Android设备完成推理测试

**\*\*目前的环境：**\*\*conda环境  rknn310  python =3.10  ，安装其他的所需依赖。 其他资源目录如下：

(1)RKNN SDK（rknn-toolkits2-2.3.0）: 已在当前的conda环境 rknn310集成<br>(2)Android NDK：/home/xh/Android/Ndk/android-ndk-r18b<br>(3)Android SDK：/home/xh/Android/Sdk<br>(4)OnnxRuntime：/home/xh/Android/OnnxRuntime/onnxruntime-android-1.17.1<br>(5)第三方库文件：/home/xh/projects/rknn\_model\_zoo/3rdparty<br>(6)RKNN支持的onnx算子信息列表：/home/xh/projects/rknn\_model\_zoo/doc/RKNNToolKit2\_OP\_Support-2.3.0.md

**\*\*当前的意图\*\*：**<br>（1）参考yolov8项目，新建目录结构，检查环境，安装移植算法必要的依赖，推理测试.pt格式能正常推理输出，没有异常<br>（2）根据计划先完成python端的工作，有问题在分析解决

**\*\*注意事项以及限制\*\*：**<br>（1）由于算法模型要跑在RK NPU上，没办法一步实现端到端的输出，所以导出模型的中间格式onnx以及转换后的rknn格式，都只负责推理，前处理和后处理都需要分离出来单独处理（其他的案例都是这么做的）<br>（2）如果导出的模型没办法正常工作，或者报错了，那么可能是算子不支持的问题，就要我们自己定义模型机构或者修改算子，再重新导出来重新测试（我们先像其他案例一样，按照一般的方法正常导出），sensevoiceSmall这个案例就是这么做的 /home/xh/projects/sherpa-onnx-2025-1217/scripts/sense-voice/rknn<br>（3）由于RK NPU不支持动态形状，所有在转换为onnx格式的时候就得输入固定形状（510 x 339）

### RCAN移植到rk3576 NPU推理测试

1 完整且丰富的上下文

\*\*目标：\*RCAN移植到rk3576这块芯片上用NPU跑起来，推送到检测到的Android设备在Android环境下完成测试。

**历史以及计划**： 整个移植的流程可以分为三个大的步骤。<br>第一步（python端）：从pytorch.bin(如果有的话)/pt—>onnx—>rknn，每个转换节点完成后需要单独测试（即拿到.pt 和 .onnx格式都推理测试一遍，检查输出）是否正确，正确后在进行下一个节点的转换（rknn文件除外，后面C++端再做验证）参考edsr 的目录格式重组，工作主要在python端。<br>第二步（C++端）：将python推理代码，转化为C++推理代码，这部分参考edsr项目的C++部分相关代码，了解RKNN接口是如何调用的，使用正确的RKNN API接口。<br>第三步（Android端）：编译好相关的C++代码（针对RK3576平台），推送到检测到的Android设备完成推理测试

\*\*目前的环境：\*\*conda环境  rknn310  python =3.10  ，安装其他的所需依赖。 其他资源目录如下：

(1)RKNN SDK（rknn-toolkits2-2.3.0）: 已在当前的conda环境 rknn310集成<br>(2)Android NDK：/home/xh/Android/Ndk/android-ndk-r18b<br>(3)Android SDK：/home/xh/Android/Sdk<br>(4)OnnxRuntime：/home/xh/Android/OnnxRuntime/onnxruntime-android-1.17.1<br>(5)第三方库文件：/home/xh/projects/rknn\_model\_zoo/3rdparty<br>(6)RKNN支持的onnx算子信息列表：/home/xh/projects/rknn\_model\_zoo/doc/RKNNToolKit2\_OP\_Support-2.3.0.md

**当前的意图**：<br>（1）参考edsr项目，新建目录结构，检查环境，安装移植算法必要的依赖，推理测试.pt格式能正常推理输出，没有异常 （2）根据计划先完成python端的工作，有问题在分析解决

**注意事项以及限制**：<br>（1）由于算法模型要跑在RK NPU上，没办法一步实现端到端的输出，所以导出模型的中间格式onnx以及转换后的rknn格式，都只负责推理，前处理和后处理都需要分离出来单独处理（其他的案例都是这么做的）<br>（2）如果导出的模型没办法正常工作，或者报错了，那么可能是算子不支持的问题，就要我们自己定义模型机构或者修改算子，再重新导出来重新测试（我们先像其他案例一样，按照一般的方法正常导出），sensevoiceSmall这个案例就是这么做的 /home/xh/projects/sherpa-onnx-2025-1217/scripts/sense-voice/rknn<br>（3）由于RK NPU不支持动态形状，所有在转换为onnx格式的时候就得输入固定形状(图片大小256×256)

### SwinIR移植到rk3576 NPU推理测试

1 完整且丰富的上下文

\*\*目标：\*\*SwinIR移植到rk3576这块芯片上用NPU跑起来，推送到检测到的Android设备在Android环境下完成测试。

**历史以及计划**： 整个移植的流程可以分为三个大的步骤<br>第一步（python端）：从pytorch.pth→onnx→rknn，每个转换节点完成后需要单独测试（即拿到.pth 和 .onnx格式都推理测试一遍，检查输出）是否正确，正确后再进行下一个节点的转换（rknn文件除外，后面C++端再做验证）参考yolov8的目录格式重组，工作主要在python端。<br>第二步（C++端）：将python推理代码，转化为C++推理代码，这部分参考yolov8项目的C++部分相关代码，了解RKNN接口是如何调用的，使用正确的RKNN API接口。<br>第三步（Android端）：编译好相关的C++代码（针对RK3576平台），推送到检测到的Android设备完成推理测试

\*\*目前的环境：\*\*conda环境 rknn310 python=3.10 ，安装其他的所需依赖。 其他资源目录如下：<br>(1)RKNN SDK（rknn-toolkits2-2.3.0）: 已在当前的conda环境 rknn310集成<br>(2)Android NDK：/home/xh/Android/Ndk/android-ndk-r18b<br>(3)Android SDK：/home/xh/Android/Sdk<br>(4)OnnxRuntime：/home/xh/Android/OnnxRuntime/onnxruntime-android-1.17.1<br>(5)第三方库文件：/home/xh/projects/rknn\_model\_zoo/3rdparty<br>(6)RKNN支持的onnx算子信息列表：/home/xh/projects/rknn\_model\_zoo/doc/RKNNToolKit2\_OP\_Support-2.3.0.md

**当前的意图**：<br>（1）参考yolov8项目，新建目录结构，检查环境，安装移植算法必要的依赖，推理测试.pth格式能正常推理输出，没有异常<br>（2）根据计划先完成python端的工作，有问题再分析解决

**注意事项以及限制**：<br>（1）由于算法模型要跑在RK NPU上，没办法一步实现端到端的输出，所以导出模型的中间格式onnx以及转换后的rknn格式，都只负责推理，前处理和后处理都需要分离出来单独处理（其他的案例都是这么做的）

（2）如果导出的模型没办法正常工作，或者报错了，那么可能是算子不支持的问题，就要我们自己定义模型结构或者修改算子，再重新导出来重新测试（我们先像其他案例一样，按照一般的方法正常导出），sensevoiceSmall这个案例就是这么做的 /home/xh/projects/sherpa-onnx-2025-1217/scripts/sense-voice/rknn

（3）由于RK NPU不支持动态形状，所有在转换为onnx格式的时候就得输入固定形状，SwinIR的输入尺寸必须是window\_size的整数倍（通常window\_size=8），建议使用(1, 3, 512, 512)作为固定输入尺寸

### Real-ESRGAN移植到rk3576 NPU推理测试

**1 完整且丰富的上下文**

\*\*\*\*目标：\*\*\*\*Real-ESRGAN移植到rk3576这块芯片上用NPU跑起来，推送到检测到的Android设备在Android环境下完成测试。

**历史以及计划：** 整个移植的流程可以分为三个大的步骤<br>**第一步（python端）**：从pytorch.pth→onnx→rknn，每个转换节点完成后需要单独测试（即拿到.pth 和 .onnx格式都推理测试一遍，检查输出）是否正确，正确后再进行下一个节点的转换（rknn文件除外，后面C++端再做验证）参考rcan的目录格式重组，工作主要在python端。(已完成)<br>\*\*\*\*第二步（C++端）：\*\***将python推理代码，转化为C++推理代码，这部分参考rcan项目的C++部分相关代码，了解RKNN接口是如何调用的，使用正确的RKNN API接口。（待完成）<br>**\*\*第三步（Android端）：\*\*\*\*编译好相关的C++代码（针对RK3576平台），推送到检测到的Android设备完成推理测试（待完成）

\*\*目前的环境：\*\*conda环境 rknn310 python=3.10 ，安装其他的所需依赖。 其他资源目录如下：<br>(1)RKNN SDK（rknn-toolkits2-2.3.0）: 已在当前的conda环境 rknn310集成<br>(2)Android NDK：/home/xh/Android/Ndk/android-ndk-r18b<br>(3)Android SDK：/home/xh/Android/Sdk<br>(4)OnnxRuntime：/home/xh/Android/OnnxRuntime/onnxruntime-android-1.17.1<br>(5)第三方库文件：/home/xh/projects/rknn\_model\_zoo/3rdparty<br>(6)RKNN支持的onnx算子信息列表：/home/xh/projects/rknn\_model\_zoo/doc/RKNNToolKit2\_OP\_Support-2.3.0.md

**2 当前的意图：**<br>（1）我想你检查一下目前Python端的代码、及相关工作是否正常，测试图片用MTK/superResolution/rcan/mtk/test\_data/input\_510x339.png，有问题再分析解决。<br>（2）没有问题，在询问我下一步的指令，我会在判断python端的结果后给出

**3 注意事项以及限制：**<br>（1）由于算法模型要跑在RK NPU上，没办法一步实现端到端的输出，所以导出模型的中间格式onnx以及转换后的rknn格式，都只负责推理，前处理和后处理都需要分离出来单独处理（其他的案例都是这么做的）

（2）如果导出的模型没办法正常工作，或者报错了，那么可能是算子不支持的问题，就要我们自己定义模型结构或者修改算子，再重新导出来重新测试（我们先像其他案例一样，按照一般的方法正常导出），sensevoiceSmall这个案例就是这么做的 /home/xh/projects/sherpa-onnx-2025-1217/scripts/sense-voice/rknn

（3）由于RK NPU不支持动态形状，所有在转换为onnx格式的时候就得输入固定形状。Real-ESRGAN对输入尺寸没有特殊限制，建议使用510×339作为固定输入尺寸，可以根据实际需求调整

（4）Real-ESRGAN是基于RRDB（Residual in Residual Dense Block）的纯CNN架构，主要使用的算子都是常规卷积操作（Conv2d、LeakyReLU、Add等），这些算子RKNN支持都很好。需要注意的算子：PixelShuffle（用于上采样）、LeakyReLU（激活函数）。这些都在RKNN支持列表中，但导出ONNX前仍需确认。

（5）Real-ESRGAN的前处理：通常需要归一化到[0,1]范围；后处理：输出需要clip到[0,1]范围，需要×255转回uint8。这些都需要在模型外部单独实现。