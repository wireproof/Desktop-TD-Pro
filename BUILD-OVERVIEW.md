# Desktop TD Pro — iOS compatibility test

An experimental iPhone/iPad app that runs a recovered Desktop TD Pro Flash file with Ruffle in WKWebView. This is a compatibility build, not a native rewrite or a verified remaster. It serves bundled content on a fixed loopback address and blocks Flash network access.

## Current test build

Version 0.2.0 build 3 adds the red app icon, a purple alternative (choose it from the in-app gear menu), and experimental touch handling: tap a tower then tap the board, or drag a tower to the board. The Flash grid is patched to refresh its selected cell on the placement press. The default Sandbox tower-preload option uses the original local SharedObject storage; its guest lock and a mismatched save-key check were corrected. The fixed loopback port preserves the storage origin of the existing iPhone test installation.

In a controlled desktop browser test, simulated input placed a tower and a drag gesture also placed a tower. A second run saved the layout, reloaded the game, and restored the tower and expected gold through Preload towers. The user confirmed that version 0.1.0 boots on the iPhone Duo. Version 0.2.0's physical touch, save/load, icon switching, and audio have not been verified. Full in-progress game saves, all account-gated features, online services and multiplayer are not implemented. Original game, Ruffle compatibility, and exact original equivalence remain under investigation.

## Build

Install Xcode and XcodeGen. Run `xcodegen generate`, open `DesktopTDPro.xcodeproj`, choose a development team and provisioning profile, and build for a registered device. Run `node tests/touch-bridge.test.js` for the touch translation unit tests. The patched game in `app/Resources/Web/game.swf` has SHA-256 `740d7a9ff2e4ed96c8939667e9614b46b63a3986d15a7f4648cbc5025063d251`. The unmodified recovered SWF had SHA-256 `0ff49ed237ebafdc7d179c6111910a3f1fa34dac4ccc4b23c79f5df447eb880c` and was downloaded from https://web-develop.ca/Games/DesktopTDPROv2NAD/DesktopTDPROv2NAD.swf. The modified ActionScript is retained under `patches/scripts`; JPEXS 26.5.0 was used to import it. Recompilation can change unrelated semantics, so check exports and runtime behavior before expanding patches.

Ruffle is developed at https://github.com/ruffle-rs/ruffle; the bundled player files came from the game host. Ruffle's license information is in `app/Resources/Web/RUFFLE-LICENSE.md`. Desktop TD Pro and its original assets belong to their respective rights holders; their provenance, modification history and redistribution rights are unverified. This is a private experimental project and does not claim a redistribution license.
