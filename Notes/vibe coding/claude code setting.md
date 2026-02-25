```text
智谱清言GLM claude code 配置
curl -O "https://cdn.bigmodel.cn/install/claude_code_env.sh" && bash ./claude_code_env.sh
api-key: 
27ed4af14abd4c24a8fa7a94e2114b44.iFPrZbJOoWGpUWMm
281545955d374864b3c9137992aa479d.7h18J9LlLyLQCMCI
```

```text
claude code Anthropic 配置:
 cp ~/.claude/settings.json.bak ~/.claude/settings.json
```

```text
 claude  --dangerously-skip-permissions
```

```text
SSH 
站点  ：ssh xiehuan@192.168.21.240
密码 ：!!U54%t3$bqP356EoD25@R&^5#!3#t^8
```

```text
github-login token
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
```

```text
切换串口信号到 tpye B
su
mwt 0x7000 9
```

```text
修复MTK设备端 NPU 权限
# 1.1 获取 root 杈限
adb root
# 1.2 设置 SELinux 为 Permissive 模式
adb shell setenforce 0
adb shell getenforce #验证输出:Permissive
# 1.3 修改 /dev/apusys 设备权限
adb shell chown root:root /dev/apusys
adb shell chmod 666 /dev/apusys
# 1.4 验证权限设置
adb shell ls -l /dev/apusys
#期望输出:crw-rw-rw-1 root root 10，102... /dev/apusys
注意:这些权限在设备重启后会丢失，需要重新设置。
```

```text
Android SDK 编译命令
./gradlew assembleDebug
```