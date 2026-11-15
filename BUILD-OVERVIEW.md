# Desktop TD

Desktop TD is an iPhone/iPad compatibility project for the recovered **Desktop Tower Defense Pro** Flash game. It runs the original game and its graphics and sounds using a bundled Ruffle player in a local `WKWebView`. The app is not a native rewrite or an upscaled graphics remaster. This project preserves the recovered game for testing; it does not claim ownership of the original game or a license to redistribute it.

## iPhone build

The current build is **0.4.2 (11)**, bundle identifier `com.wireproof.dtdpro`. It is landscape-only and fills the available display, with the slight stretching the owner selected. iOS is asked to hide system overlays. The small settings button shifts between menus and gameplay so it stays clear of the Sandbox heading and the score; in Sandbox setup it is centered in the space to the right of the heading. The red icon is the default; the settings menu offers the supplied purple alternative.

The owner confirmed that game audio works, a Sandbox tower upgrades during a wave, and the previous full-screen layout was the best fit so far on the iPhone Duo. The new settings-button position, purple icon, long sessions, and all combinations of towers and modes still require physical-device verification. iPad has not been verified. Screens with camera cutouts or system overlays may cover edge content when filling the display.

## Playing

- Tap a tower in the palette, then tap the board to place it. Dragging from the palette to the board is also supported.
- Tap a placed tower to select it, then use **Upgrade** or **Sell**. An in-wave upgrade takes time and shows a progress bar. Upgrades require sufficient gold and must be enabled in Sandbox settings.
- Use the settings button for the local checkpoint commands and alternative app icon.
- The original Sandbox **Preload towers** option can restore the last tower layout saved by the game when a run is started. Use matching Sandbox settings.

### Local checkpoints

During an active single-player Sandbox run, choose **Save Sandbox checkpoint** from the settings button. The request waits for a clear moment between waves; wait for the success message. There is one local checkpoint slot. To load it, enter a new Sandbox game with the same settings, leave **Preload towers** off, and choose **Load Sandbox checkpoint** before starting or placing towers.

The checkpoint preserves a between-wave state, not an active wave. It is unavailable after the final wave starts and does not cover Scenarios, Sprint, or multiplayer. A controlled browser test saved and restored a checkpoint after an actual wave; a physical-device save-and-restore test is still needed. Local layouts and checkpoints belong to the app's local WebKit storage; deleting the app removes its local data. Keep a backup before replacing or removing the app.

## Offline and compatibility status

The game and Ruffle files are bundled and served from a fixed loopback address, `127.0.0.1:58882`. A content security policy restricts connections to the local origin, and the app blocks external navigation. The fixed address preserves the storage origin between updates. Flash script access is enabled for the local checkpoint and touch-upgrade bridge.

Sandbox tower preload and the checkpoint are local replacements, not a recreation of all former account features. Cloud accounts, online leaderboards and multiplayer have not been recreated. The recovered game is running through an emulator, so behavior in every mode and exact equivalence to the original Flash runtime have not been established. If the former `com.wireproof.desktoptdpro` app remains installed, it is a separate iOS app with a separate data container; iOS does not automatically transfer data between bundle identifiers.

## Desktop builds

The standalone desktop edition uses Electron with the same bundled Ruffle game. macOS packages are provided for Apple silicon and Intel; the Windows build is a portable x64 EXE. The window can be resized or switched to full screen (F11 on Windows, Control–Command–F on macOS). The **Game** menu provides Sandbox checkpoint save and load. Local desktop saves are separate from iPhone saves and from other computers.

The desktop programs serve bundled files on `127.0.0.1:58919` and keep game data in the operating system's per-user application-data directory. They do not require a Flash installation or the original game server. A second copy cannot start while the first holds the local port.

The macOS build is ad-hoc signed and not notarized; the Windows build is unsigned. Operating-system security checks can prevent or warn about running these builds. Use your own code-signing credentials and distribution process for broadly trusted releases. Desktop features and local persistence require more real-world testing.

To build the desktop app, install Node.js and npm, then from the repository root run:

```sh
cd desktop
npm ci
npm run dist:mac    # macOS DMGs; run on macOS
npm run dist:win    # Windows portable EXE; run on Windows
```

## iPhone IPA and signing

The public release includes an **unsigned iPhone IPA** for re-signing with your own Apple development team and registered device. It cannot be installed as-is. Development provisioning profiles contain registered-device identifiers and are intentionally excluded from the public artifact. The owner's device-specific signed IPA remains in the private project and Synology backup. Apple development signatures can expire. Preserve the existing installation and its data when updating.

## Build from source

Requirements: macOS, Xcode with an iOS SDK, XcodeGen, and an Apple development team and device provisioning for a physical-device build. Node.js is useful for the touch-bridge check.

```sh
xcodegen generate
node tests/touch-bridge.test.js
xcodebuild -project DesktopTDPro.xcodeproj -scheme DesktopTDPro \
  -configuration Debug -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO build
xcodebuild -project DesktopTDPro.xcodeproj -scheme DesktopTDPro \
  -configuration Release -destination 'generic/platform=iOS' \
  -allowProvisioningUpdates build
```

Select your team and signing settings in `project.yml` or Xcode before building. The repository includes the patched SWF and the Ruffle runtime in `app/Resources/Web`, app code in `app/`, and the recovered ActionScript and bytecode modifications in `patches/`. The original game’s complete source code was not recovered; the repository contains the compiled game and the app and patch source, not the original authors’ complete source tree. The original unmodified SWF and local reverse-engineering tools are not required for an ordinary app build.

To reproduce the patched SWF, obtain the original recovered file from <https://web-develop.ca/Games/DesktopTDPROv2NAD/DesktopTDPROv2NAD.swf>, verify its SHA-256 is `0ff49ed237ebafdc7d179c6111910a3f1fa34dac4ccc4b23c79f5df447eb880c`, and install Java and [JPEXS Free Flash Decompiler](https://github.com/jindrapetrik/jpexs-decompiler) 26.5.0. Set `DTD_FFDEC_JAR` if the jar is not at `tools/ffdec-26.5.0/ffdec.jar`; set `DTD_JAVA` if `java` is not on the path.

```sh
DTD_FFDEC_JAR=/path/to/ffdec.jar scripts/rebuild-swf.sh original.swf rebuilt.swf
shasum -a 256 rebuilt.swf
```

The script checks the original hash and applies the source and bytecode patches in order. With JPEXS 26.5.0 the resulting SWF matched the bundled file byte-for-byte, SHA-256 `f9221838a0d33e3336c35c314ac9bf7c18cd092953b488ae09695d9391e0d2da`. Recompiling ActionScript can alter unrelated behavior; recheck exports and runtime behavior when changing patches.

## Planned platforms and work

- Finish iPhone interface and save verification, including cutouts, fold transitions, checkpoints, tower layouts, and longer games.
- Verify iPad Pro 11-inch sizing, input, audio and persistence.
- Continue macOS and Windows testing, including persistence, performance and signing/notarization for trusted distribution.
- Prepare a browser-hosted version for the owner's Synology web server and wireproof.net; no deployment has been made. The current Ruffle-based web assets are not a native HTML5 rewrite.
- Investigate a native HTML5 reconstruction and graphics remaster only if desired; preserve original gameplay and sounds and compare against the recovered build.
- Decide whether local replacements for additional account features, scores, or multiplayer are wanted and feasible.

Ruffle is developed at <https://github.com/ruffle-rs/ruffle>; its bundled license is in `app/Resources/Web/RUFFLE-LICENSE.md`. Desktop Tower Defense Pro and its original assets belong to their respective rights holders. Provenance and redistribution rights are unverified; no ownership or redistribution license is asserted.
