待做清单

1.14

- [x] 1  ASR输出没有标点符号的问题 <!-- div-format -->

- [ ] 2 修复长音频输出异常的问题（超过10s） <!-- div-format -->

- [x] 3 集成到sherpa-onnx项目架构，并测试通过 <!-- div-format -->

- [x] 4 语种自动检测（中英日韩粤） <!-- div-format -->

- [x] 5 MTK dla模型无法用内存缓存加载的问题 <!-- div-format -->

- [x] 修复MTK 运行时 硬编码到设备查找的问题（改为手动指定目录，不依赖设备的路径和库文件） <!-- div-format -->

1.15

- [x] 熟悉移植标准Transform架构算法到MTK NPU <!-- div-format -->

- [x] 移植带k v cahce的Helsinki算法到MTK NPU <!-- div-format -->

1.19 - 1.23

- [x] ✅ 1. 建立完整的 MTK NPU Skills 工具链 <!-- div-format -->

- [x] 创建了 4 个核心 skills，实现从项目初始化到部署测试的完整自动化流程。 <!-- div-format -->

- [x] ✅ 2. 创建知识库系统 <!-- div-format -->

- [x] 建立了中央知识库，记录所有已知问题、解决方案和最佳实践，确保每次代码生成时自动避坑。 <!-- div-format -->

- [x] ✅ 3. 整理 MDLA 5.3 算子支持列表 <!-- div-format -->

- [x] 从 MTK SDK 文档提取并整理了完整的算子支持情况，明确了 65 个支持的算子和 22 个不支持的算子。 <!-- div-format -->

---

📦 创建的 Skills 列表

![pasted_image_b0c9fe58-0cfe-4931-b996-376dbc52c4fc.png](file://C:\Users\HP\AppData\Roaming\CherryStudio\Data\Files\b0c9fe58-0cfe-4931-b996-376dbc52c4fc.png)

📁 创建的文件清单

🔧 Skills 相关文件

![pasted_image_30a683c9-e580-4b2a-bea7-02356644cfba.png](file://C:\Users\HP\AppData\Roaming\CherryStudio\Data\Files\30a683c9-e580-4b2a-bea7-02356644cfba.png)

📚 知识库和配置文件<br>~/<br>├── .mtk\_npu\_config.json # 统一配置文件（NDK/SDK/平台信息）<br>├── .mtk\_npu\_knowledge\_base.md # 中央知识库（已知问题和最佳实践）<br>└── .mtk\_mdla\_operators.md # MDLA 5.3 算子支持列表

1.29

- [x] EDSR  MTK RK3576 移植部署测试 <!-- div-format -->

- [x] RCAN MTK RK3576 移植部署测试 <!-- div-format -->

- [x] RealESRGAN   MTK RK3576 移植部署测试 <!-- div-format -->

- [x] 协助开发解决翻译模型无法正常工作的问题 <!-- div-format -->

- [x] 整理超分辩率项目，提交到远程仓库 <!-- div-format -->