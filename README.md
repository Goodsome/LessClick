# Less Click

Reduce clicks. Speed up routine actions with smart, lightweight QoL helpers.

- Author: xlx
- License: MIT
- CurseForge: https://www.curseforge.com/wow/addons/less-click

## Features
- Automates safe, everyday tasks
  - Auto repair at merchants (quiet, respects your settings)
- Lightweight and unobtrusive (no bloat, minimal CPU/memory)
- Simple in-game control (options panel + slash commands)

## Slash Commands
- `/lessclick` or `/lc`
  - `on` – enable the addon
  - `off` – disable the addon
  - `debug` – toggle debug logging

## Options
- Retail: Game Menu → Options → AddOns → Less Click
- Legacy/Classic: Interface Options → AddOns → Less Click

## Installation
1. Download the release archive.
2. Extract and place the folder `LessClick` into:
   - Retail: `World of Warcraft\_retail_\Interface\AddOns\`
   - Classic (if supported): `World of Warcraft\_classic_\Interface\AddOns\`
3. Restart the game or run `/reload`.

## Compatibility
- Retail supported. Classic uses legacy options panel if Settings API is unavailable.
- No third-party libraries required.

## Performance
- Event-driven; no heavy loops or constant scanning.

## Localization
- English (enUS)
- Simplified Chinese (zhCN)
- Contributions welcome!

## Roadmap
- Auto-sell gray (poor) items with safe exclusions
- Smart confirmation helpers (vendor, quest turn-in)
- Optional quick toggles/minimap/menu shortcuts

## Troubleshooting
- Not loading?
  - Ensure the folder name is exactly `LessClick` and contains `LessClick.toc`.
  - Check that your game version matches the addon's Interface number.
- Conflicting behavior?
  - If another addon automates the same task, disable one of the features to avoid duplication.
- Still stuck? Open an issue with steps to reproduce.

## License
MIT — free to use, modify, and distribute with attribution.

---

# 少点点 Less Click（中文说明）

让你少点几下，玩得更快更省心的轻量便捷插件。

- 作者：xlx
- 许可：MIT
- CurseForge：<https://www.curseforge.com/wow/addons/less-click>

## 功能
- 自动处理常见的安全操作
  - 在商人处自动修理（安静、不打扰）
- 轻量不打扰（无冗余占用）
- 简单易用（设置面板 + 命令行）

## 命令
- `/lessclick` 或 `/lc`
  - `on`：启用
  - `off`：禁用
  - `debug`：切换调试日志

## 设置
- 正服（Retail）：游戏菜单 → 选项 → 插件 → Less Click
- 经典服（如适用）：界面选项 → 插件 → Less Click

## 安装
1. 下载发布包；
2. 解压后将 `LessClick` 文件夹放入：
   - 正服：`World of Warcraft\_retail_\Interface\AddOns\`
   - 经典服（如适配）：`World of Warcraft\_classic_\Interface\AddOns\`
3. 重启游戏或输入 `/reload`。

## 兼容性
- 支持 Retail。若 Settings API 不可用，将回退到旧版设置面板。
- 无第三方库依赖。

## 性能
- 基于事件触发，不跑重循环。

## 本地化
- 英文（enUS）
- 简体中文（zhCN）
- 欢迎参与翻译与改进。

## 规划
- 自动售卖灰装（带安全排除）
- 智能确认（商人、任务等）
- 可选的快捷开关/小地图入口

## 常见问题
- 加载失败？
  - 确认文件夹名为 `LessClick`，且内含 `LessClick.toc`；
  - 确认 toc 的 Interface 版本与客户端一致。
- 功能冲突？
  - 若与其他同类功能叠加，请关闭其中一个以避免重复执行。

## 许可
MIT — 可自由使用、修改与分发，但需保留版权与许可声明。