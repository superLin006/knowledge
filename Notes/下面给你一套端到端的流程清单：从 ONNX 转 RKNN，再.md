下面给你一套端到端的流程清单：从 ONNX 转 RKNN，再到 Android/Linux 设备（如 RK3576）上打包部署和运行测试，并补充常见坑位与排查。你可以按此作为项目交付的标准操作流程（SOP）。

一、准备阶段

-   硬件与系统
    
    -   目标设备：Rockchip NPU 平台（如 RK3576）
        
    -   设备可 adb root；具有 /data/local/tmp 写权限
        
-   开发环境
    
    -   主机：Windows 或 Linux 均可
        
    -   安装 Rockchip RKNN-Toolkit 或 RKNN-Toolkit2（建议与设备端 rknn\_runtime 版本一致）
        
    -   Python 3.8+，安装 rknn-toolkit2、numpy、onnx、onnxruntime（可选用于 ONNX 侧验证）
        
    -   模型与依赖
        
        -   Whisper ONNX（encoder.onnx、decoder.onnx）或你自己的 ONNX 模型
            
        -   对应的 tokenizer/词表、前后处理代码或资源（如 mel 滤波器、词表等）
            

二、ONNX → RKNN 转换

1.  明确输入输出与预处理
    

-   Whisper encoder 输入通常是 mel 频谱 [1, 80, 2000]（20s 窗口），FP16/FP32
    
-   Whisper decoder 输入为 tokens（INT64）+ encoder 输出特征（FP16）
    
-   准备好前处理（音频->mel）与后处理（解码、beam search/greedy、去标点等）
    

2.  转换脚本（Python，使用 RKNN-Toolkit2）
    

-   关键步骤
    
    -   rknn = RKNN()
        
    -   config（指定 target\_platform、quantize、mean/std、optimization level 等）
        
    -   load\_onnx(model=xxx.onnx)
        
    -   build(do\_quantization=..., dataset=...), 量化需准备数据集/校准文件
        
    -   export\_rknn('xxx.rknn')
        
-   示例要点
    
    -   target\_platform: 'rk3576'（与你设备匹配）
        
    -   FP16/INT8 选择：FP16 精度高、部署稳；INT8 更快但需校准数据
        
    -   Whisper decoder 若为动态维度，需固定或配置动态 shape 范围，便于 build
        

3.  量化（可选但推荐）
    

-   INT8 量化
    
    -   准备代表性音频集合，生成 mel 频谱作为校准数据（encoder）
        
    -   decoder 的量化较复杂：可能需要特征+token 的联合校准数据（建议先 FP16 跑通）
        
-   校准集不当会导致精度掉点明显；先 FP16 基线，再尝试 INT8
    

4.  转换验证（PC 上离线验证）
    

-   使用 rknn.infer() 喂入相同输入（mel 或 tokens+features）与 ONNX 对比
    
-   计算误差或端到端文本对比，确认精度可接受
    

三、设备端运行库与依赖准备

1.  选择运行时版本
    

-   设备端 rknn\_runtime 版本必须与 PC 端转换工具链匹配（同一大版本）
    
-   从 Rockchip 提供的 runtime 包中取出：
    
    -   librknnrt.so 等运行库（以及可能需要的依赖 libgomp、libstdc++ 等）
        
-   应用层依赖（demo 本身需要的 .so，包含音频处理、解码等）
    

2.  打包目录结构建议
    

-   rknn\_whisper\_demo/
    
    -   bin/ rknn\_whisper\_demo（可执行文件）
        
    -   lib/ librknnrt.so 等所有 .so 依赖
        
    -   model/ whisper\_encoder\_base\_20s.rknn, whisper\_decoder\_base\_20s.rknn
        
    -   assets/ 词表、mel 滤波器、测试音频（test\_en.wav）、配置文件
        
    -   scripts/ 可选：一键运行脚本 run.sh
        
-   确保可执行与 .so 使用相对路径加载，便于整体拷贝
    

四、Android/Linux 设备端部署与运行

1.  ADB 准备
    

-   adb root
    
-   adb remount（可选，不建议写 system；我们放 /data/local/tmp）
    
-   adb push rknn\_whisper\_demo /data/local/tmp/
    

2.  运行前设置
    

-   adb shell
    
-   cd /data/local/tmp/rknn\_whisper\_demo
    
-   chmod +x ./bin/rknn\_whisper\_demo（或 ./rknn\_whisper\_demo）
    
-   export LD\_LIBRARY\_PATH=/data/local/tmp/rknn\_whisper\_demo/lib:$LD\_LIBRARY\_PATH
    
-   如有额外依赖路径，同样加入 LD\_LIBRARY\_PATH
    

3.  运行
    

-   ./bin/rknn\_whisper\_demo model/whisper\_encoder\_base\_20s.rknn model/whisper\_decoder\_base\_20s.rknn en assets/test\_en.wav
    
-   观察输出：初始化耗时、推理耗时、识别文本、RTF
    

五、工程化与优化

1.  性能优化
    

-   多核/多线程
    
    -   NPU 核使用策略（toolkit 有 set core mask/ctx config 的接口）
        
    -   解码部分 CPU 并行（例如 beam search）
        
-   量化与模型规模
    
    -   使用小模型（tiny/base）更快；INT8 量化提速明显但需校准
        
-   I/O 与复用
    
    -   避免每次重新加载模型，将 encoder/decoder 在进程内复用
        
    -   预热运行一次，后续 latency 更稳定
        
-   流式/长音频处理
    
    -   20s 窗口模型需对长音频分段
        
    -   重叠分段+VAD（语音端点检测）提升边界效果
        
    -   逐段拼接文本并做后处理（时间戳、断句）
        

2.  精度与多语言
    

-   模型选择
    
    -   英文 vs 多语言；匹配语言代码（en/zh/...）
        
-   文本后处理
    
    -   去除特殊token；大小写、标点规范化
        
-   词表/Tokenizer 一致性
    
    -   确保与 ONNX/RKNN 模型用同一套词表与预处理参数（mel 滤波器、音频采样率）
        

3.  应用集成（Android APK 可选）
    

-   NDK 集成
    
    -   将 librknnrt.so 和其它 .so 放入 app/src/main/jniLibs/arm64-v8a/
        
    -   使用 CMake/ndk-build 链接 rknnrt
        
    -   在 Java/Kotlin 通过 JNI 调用 native 接口
        
-   动态权限与资源
    
    -   录音权限、存储访问
        
    -   模型与词表放到 assets，首次启动解压到内部存储，再设置 LD\_LIBRARY\_PATH 或用 System.load() 显式加载
        
-   AAB/APK 体积优化
    
    -   只打 arm64-v8a 架构；按需裁剪 .so
        

六、常见问题与排查

-   运行时报 “error while loading shared libraries”
    
    -   LD\_LIBRARY\_PATH 未设置或缺少依赖 .so；用绝对路径重新 export
        
-   “RKNN runtime 版本不匹配”
    
    -   PC 转换工具链与设备端 runtime 版本不一致；统一版本重导出
        
-   性能不足或 RTF > 1
    
    -   检查是否启用 NPU、是否 INT8 量化、是否选择更小模型
        
    -   避免每次初始化；尽量批量/流式
        
-   精度异常
    
    -   检查前处理（采样率、mel 参数、归一化）是否与训练/ONNX一致
        
    -   量化校准集分布不匹配；先用 FP16 验证基线
        
-   Decoder 动态 shape 导致 build 失败或运行异常
    
    -   固定维度或在 build 时声明动态范围；必要时将解码器改成 step-by-step 迭代接口
        

七、最小可复现清单（你现在的成功路径）

-   已有：
    
    -   rknn\_whisper\_demo 目录（含 bin/lib/model/assets）
        
    -   adb root + push 到 /data/local/tmp
        
    -   export LD\_LIBRARY\_PATH 到 lib
        
    -   运行命令行，输出正常、RTF<1
        
-   待补充到项目文档：
    
    -   转换脚本与其依赖版本号（toolkit 版本、runtime 版本、量化与否）
        
    -   模型与资源的来源、hash 与路径
        
    -   一键部署/运行脚本（push、chmod、设置环境、运行）
        

需要我给你一份模板化的转换脚本（RKNN-Toolkit2）和设备端一键运行脚本吗？你告诉我使用的 toolkit/runtime 版本和模型规格（tiny/base/small 等），我给你定制示例。