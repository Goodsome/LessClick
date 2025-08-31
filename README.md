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

## Installation
1. Download the release archive.
2. Extract and place the folder `LessClick` into:
   - Retail: `World of Warcraft\_retail_\Interface\AddOns\`
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
