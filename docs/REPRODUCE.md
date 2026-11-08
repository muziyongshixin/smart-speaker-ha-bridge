# 分阶段复现指南

## 0. 适用环境与资料
本案例：小米 5X / Android 8.1 / 无 root；Termux 0.118.3、Termux:Boot 0.8.1；HA 2026.11.0 ARM64，PRoot P2；Xiaomi Home 0.5.0；Bemfa Cloud 0.1.20；OneConnect Bridge 0.4.0 commit 869db4260a4071893a045cad0539a3172b5892bc。版本是复现基线，不代表最新版本。先核对当前上游兼容性。

官方来源：
- https://github.com/termux/termux-app/releases
- https://github.com/termux/termux-boot/releases
- https://github.com/indigo-dc/udocker
- https://github.com/home-assistant/core
- https://github.com/XiaoMi/ha_xiaomi_home
- https://github.com/bemfa/bemfa_cloud_ha
- https://github.com/chaosl1996/ha-oneconnect-bridge

Termux 是 Android 应用，不覆盖安卓。Termux 与 Boot 必须来自签名兼容的同一渠道；不要混装不同来源。USB调试与 USB安装是不同授权。安装/解锁由设备主人完成。

## 1. HA 运行环境
最省维护的是标准 Linux/HAOS；旧手机是进阶路径。手机上检查 aarch64、可用存储和联网。安装 Termux 的 python、proot、git 等依赖，再按 udocker 官方说明安装并检查 `udocker version`。Android 可能需要把 udocker 的 PRoot 引擎指向 Termux 的兼容 proot；本仓库没有把原设备环境假装成通用自动安装器。

获取官方 ARM64 HA 镜像 `ghcr.io/home-assistant/home-assistant:2026.11.0`；网络不通时可在电脑按 linux/arm64 拉取并以 docker archive 导出，传到手机后 `udocker load -i IMAGE.tar`。不要把 OCI archive 与 docker archive 混用。用 `udocker images` 确认实际镜像名。

```sh
udocker create --name=home-assistant ghcr.io/home-assistant/home-assistant:2026.11.0
udocker setup --execmode=P2 home-assistant
mkdir -p ~/ha/config ~/ha/runtime/tmp ~/ha/runtime/shm ~/ha/backups
```

将 runtime 中四个脚本复制到 `~/ha/` 并 `chmod +x ~/ha/*.sh`。在 `~/ha/runtime/resolv.conf` 写入实际可用 DNS（可用家庭路由器地址），不要照抄作者网络地址。把 examples 的 YAML 作为新安装起点；已有配置只合并必要内容。先替换 scenes.yaml 中空调实体，或者先使用空列表 `[]`。

执行 `~/ha/start-ha.sh`，检查 `~/ha/runtime/console.log`，打开 `http://手机局域网IP:8123`。用户自己创建管理员账户。此处只有启动脚本做过原设备验证；其他手机的 PRoot、DNS、组播适配必须独立验收。

## 2. 开机自启与局域网
Termux:Boot 安装后先打开一次。创建 `~/.termux/boot/start-home-assistant`：
```sh
#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock
/data/data/com.termux/files/home/ha/start-ha.sh
```
赋执行权限。MIUI 设置 Termux 和 Boot 自启动、后台不限制；必要时锁定最近任务。首次启动可能需解锁手机。用另一设备访问 HA 并确认未登录 API 返回 401；不要设路由器公网端口映射。重启测试需同时检查 HA、桥接与真实指令。原案例手机自启通过；新增 Huawei 只验证了 HA 服务重启恢复。

## 3. Xiaomi Home
按官方 README 将 custom_components/xiaomi_home 放入 HA config 并重启。通过 HA UI 添加集成、官方 OAuth 授权。只选一个家庭先验证；本案例一次导入其他家庭的上百设备导致负担。选 room 命名规则，使用短房间名。检查每个控制实体 supported_features，不把传感器强行当开关。

## 4. 小度 / 巴法云
获取 Bemfa v0.1.20 上游源，应用补丁（先 `git apply --check`），安装组件并按上游 README 登录授权。先只选择 input_boolean.bridge_test，建立主题并在小度 App 绑定同一巴法账号。开和关都要让用户语音验证 HA 状态变化。

再分批选择真实设备。使用短名称，不带家庭前缀与重复“开关”。传感器补丁支持在每个温湿度主题的配置中指定 `temperature` 和 `humidity` 两个实体，见补丁读取字段；修改配置条目必须经集成支持路径，若只能编辑 .storage，先正常停 HA 并备份，不能在运行中改。保留一个主题，避免两个主题同时响应同一房间湿度。删除云主题属于不可逆操作，先保存映射并取得用户确认。

## 5. Huawei Sound SE
```sh
git clone https://github.com/chaosl1996/ha-oneconnect-bridge.git
cd ha-oneconnect-bridge
git checkout 869db4260a4071893a045cad0539a3172b5892bc
git apply --check /path/to/this-repo/patches/oneconnect-android-controls.patch
git apply /path/to/this-repo/patches/oneconnect-android-controls.patch
```
把修改后的 custom_components/oneconnect_bridge 安装到 HA。补丁默认虚拟实体为 `input_boolean.bridge_test`，需与本次 HA 创建的实体一致。按上游文档配置网关、网卡；Android 读不到 MAC 时填设备实际 Wi-Fi MAC。确认组播与 UDP 5683 可用，不应通过关闭 VPN/防火墙全局保护来碰运气。

先只映射虚拟开关。在智慧生活里添加扫描到的网关，使用当前 PIN 配对，完成房间向导，按需启用“智慧语音控制设备和场景”。验证“小艺小艺，打开联动测试”能改变 HA。

随后使用上游映射编辑流程按真实实体生成子设备。灯按能力选型；补丁增加 climate/vacuum 基础开关、Android MAC 输入和配对动作描述。不要复制本案例的网关序列号、product material 或云身份。加载子设备后分别确认注册成功、App 可控、语音可控、实物变化。statusSync=1000 是本案例观察到的返回，不能单凭该数字当成成功；必须做后续检查。

## 6. 空调快捷场景
合并 examples/scenes.yaml，替换实体，先确认模式列表有 heat/cool、28/26 在支持范围。在 HA YAML 工具页重新加载场景，不必执行它。把 scene 实体通过 OneConnect 的原生 scene→瞬时开关映射暴露，房间客厅，华为名称分别“暖冬”“清凉”。若已注册设备，在智慧生活也修改显示名称；仅改本地映射不保证云端已有名称同步。

口令：打开暖冬→heat 28℃；打开清凉→cool 26℃；关闭客厅空调电源→off。关闭场景开关不等于关空调。用户确认实际动作后再标记通过。

## 7. 验收与回滚
每批记录：源实体可用、配置加载、云端注册、App开关、语音响应、HA状态、实物确认。最后测网络恢复、服务重启、自启动；不得以自动化测试反复切换空调模式。

私有备份应包含 config、启动脚本与组件版本，含敏感数据，不上传。回滚先正常停止 HA，恢复备份后启动；桥接身份正常重启应保留，不能把删身份当成常规修复。本地补丁更新时先备份再检查差异。
