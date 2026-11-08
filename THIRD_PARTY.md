# 上游与本地修改

- Home Assistant：https://github.com/home-assistant/core — Apache-2.0；本仓库不分发镜像。
- Xiaomi Home：https://github.com/XiaoMi/ha_xiaomi_home — 使用上游 0.5.0，依上游 LICENSE；本仓库不复制组件。
- OneConnect Bridge：https://github.com/chaosl1996/ha-oneconnect-bridge — Apache-2.0；基线 869db4260a4071893a045cad0539a3172b5892bc。本地补丁：Android手动MAC、默认测试入口、空调电源、扫地机指令与配对服务元数据。原作者及贡献者保有各自版权。
- Bemfa Cloud：https://github.com/bemfa/bemfa_cloud_ha — 基线 v0.1.20（发布归档前缀 c8c0377）。补丁：温湿度合并发布、未知水浸状态过滤。许可全文见 licenses/bemfa-LICENSE。
- Termux / Termux:Boot / udocker：仅链接并描述使用方式，不分发 APK 或二进制。

所有补丁均为本案例修改后的版本与原基线的差异；部署到其他版本前需要重新检查。
