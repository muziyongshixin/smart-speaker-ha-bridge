# Agent 操作约定
先读 README.md、docs/REPRODUCE.md 和 docs/KNOWN_ISSUES.md。使用 prompts/REPRODUCE.md 启动任务。
- 这是已运行案例的复现工程，不是一键通用刷机工具。不刷音箱、不 root、不克隆设备认证。
- 先只读检查设备与网络，记录阶段进度到 private/progress.md；所有个人信息仅存 private/。
- 不提交 HA .storage、数据库、日志、云端 material.json、令牌、账号、MAC、序列号和完整实体清单。
- 不关闭 TLS 验证，不把 HA 暴露公网，不覆盖已有配置。变更前私有备份。
- 登录、验证码、账户条款由用户完成；设备实物动作先说明影响。先虚拟开关，再真实灯，最后空调等。
- 必须区分配置加载、云端注册、语音触发、物理动作四层证据。仅收到成功返回不得声称实测成功。
- 更新组件前检查上游版本和补丁可应用性。失败应停止该步并报告具体错误，禁止强行应用。
- HA 配置包含 !include；不要用不支持该标签的 YAML 解析器回写整个 configuration.yaml。
