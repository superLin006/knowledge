我想继续完成helsinki翻译模型移植到rk3576上运行的工作，我的思路是<br>1 先在python环境下，分别导出对应的onnx格式的 encoder和decoder（导出的时候注意和RK平台的适配）<br>

2 在Python环境下用导出的onnx格式的encoder和decoder进行协同工作，测试完成翻译真实句子（en-zh）的工作，验证导出的模型的可用性

3 验证完第二步之后，再继续在linux机器的python环境下，完成encoder.onnx和decoder.onnx 格式到rknn格式的转换

4 根据Helsinki的官方python推理代码、复刻编写Android环境下的C++推理代码。用输入的简单测试token完成helsinki翻译模型(encoder.rknn和decoder.rknn)在RK3576芯片上的协同推理工作（编码+解码），验证rknn格式模型以及C++版推理代码的可用性

5 实现tokenizer，根据导出的vocab.txt,实现词表的映射，完成完整的翻译流程

你帮我评估一下这个方案是否可行？有补充的点吗，如果没问题的话，为了稳妥起见，我们先进行第一步和第二步的工作，我已经在本地准备好了原始的完整 en-zh的helsinki模型权重文件（C:\\Users\\HP\\Desktop\\en\_zh\_translation\\opus-mt-en-zh），如果遇到问题我会及时想你反馈，你在回答的时候，不需要给我详细的使用指导，和简单的说明就好了<br><br><br>我想继续完成helsinki翻译模型移植到rk3576上运行的工作，我的思路是 1 先在python环境下，分别导出对应的onnx格式的 encoder和decoder（导出的时候注意和RK平台的适配） 2 在Python环境下用导出的onnx格式的encoder和decoder进行协同工作，测试完成翻译真实句子（en-zh）的工作，验证导出的模型的可用性 3 验证完第二步之后，再继续在linux机器的python环境下，完成encoder.onnx和decoder.onnx 格式到rknn格式的转换 4 根据Helsinki的官方python推理代码、复刻编写Android环境下的C++推理代码。用输入的简单测试token完成helsinki翻译模型(encoder.rknn和decoder.rknn)在RK3576芯片上的协同推理工作（编码+解码），验证rknn格式模型以及C++版推理代码的可用性 5 实现tokenizer，C++端实现tokenizer,然后根据导出的vocab.txt，实现词表的映射，测试encoder能够正常工作，测试decoder能否正常工作，完成完整的翻译流程 整个过程我都尝试运行了一遍，输出几乎没有问题，现在我需要考虑的是性能问题 1 首先，由于我导出的模型是不带缓存对的，每次推理都会重复计算，这很耗时 2 推理代码Helsinki.cc目前需要确认是否用了zero-copy技术，这对于性能提升很有帮助的,并且RK3576芯片支持这项技术，我在whisper.cc这个文件中就实现了 这两点可以重点关注下，如果有遗漏的请你补充 请你先帮我深入分析一下，我们先不写代码，如果要写代码也请你不要对代码进行详细的使用指导，我自己会看，简单描述就好