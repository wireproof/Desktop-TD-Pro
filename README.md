# Desktop TD Pro — iOS compatibility test

This experimental iOS app runs a recovered Desktop TD Pro SWF using the self-hosted Ruffle web player in WKWebView. It is not a native rewrite or a verified remaster. The app serves only bundled files on an ephemeral loopback address and disables Flash network access. Internet-dependent services and multiplayer are not verified. Simulator diagnostics report that the SWF loaded; game controls, audio, and physical-device gameplay require testing.

## Build

Install Xcode and XcodeGen. Run `xcodegen generate`, open `DesktopTDPro.xcodeproj`, choose a development team and provisioning profile, then build for a registered device. The original recovered game file is `app/Resources/Web/game.swf`, SHA-256 `0ff49ed237ebafdc7d179c6111910a3f1fa34dac4ccc4b23c79f5df447eb880c`. This copy came from https://web-develop.ca/Games/DesktopTDPROv2NAD/DesktopTDPROv2NAD.swf; its modification history and redistribution rights are unverified.

Ruffle is developed at https://github.com/ruffle-rs/ruffle; the bundled player files were obtained from the same game host. Ruffle's license information is in `app/Resources/Web/RUFFLE-LICENSE.md`. Desktop TD Pro and its original assets belong to their respective rights holders; no ownership or redistribution license is claimed here.

## Test build status

Version 0.1.0 build 1 was signed and installed on the iPhone Duo. Launch was blocked by the locked device at installation time. Ruffle reported that the SWF loaded in the iPhone simulator; menus, touch interaction, waves, audio, and physical-device operation have not been verified. This is a private experimental project and release, not a public distribution or a claim of completeness.
