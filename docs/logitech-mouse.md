# Logitech Lift remapping on macOS and Fedora

Updated 2026-10-24.

## Device and macOS

- MacBookPro18,1, MacBook Pro 16-inch with Apple M1 Pro and 32 GB RAM.
- macOS 27.0.1 (build 26A434).
- The connected mouse is **Logitech LIFT FOR MAC**, not MX Vertical: Bluetooth LE, VID `046D`, PID `B031`, firmware `RBM21.01_0010`, battery 100% at inspection.
- The HID++ probe identified protocol 4.5 and `REPROG_CONTROLS_V4` v5. It reports seven controls: left click, right click, middle click, Back, Forward, DPI Switch, and a virtual gesture button. Upright can divert four: middle, Back, Forward, and DPI. Left/right clicks are not remappable through this interface. Wheel scrolling remains a normal HID scroll control.
- Upright describes the native defaults as Back/Forward navigation, DPI cycling on the top button, and middle click on wheel click. These are device/app-reported defaults; the physical buttons have not yet been pressed in a manual test.

## Selected solution

[Upright](https://github.com/dpdev69/upright), a small native SwiftUI menu-bar app using Logitech HID++ 2.0. It uses no kernel extension or separate daemon. Release **1.1.2**, downloaded from the official GitHub release page. The release DMG SHA-256 was `51840968f03c61799b0e2544f205b88efc6395abc8f2f7ccba08f4085c86df1b`, matching the release metadata.

Upright's catalog lists Lift `046D:B031` and Bluetooth support, but marks Lift as published-data/simulator-tested and unverified on physical hardware. Its only model marked hardware-verified is MX Vertical. This unit was nevertheless detected and responded to the HID++ probe over Bluetooth; the probe observed a programmable-buttons feature and four divertable controls. This is evidence that the device interface works, but is not a substitute for button-by-button reliability testing.

## Configuration

Installed at `/Applications/Upright.app`. Current system-wide profile for Lift (`046D:B031`):

| Control | Upright action | Result |
|---|---|---|
| Back | Default | Left to mouse's native Back behavior |
| Forward | Default | Left to mouse's native Forward behavior |
| Top (DPI) | Mission Control | Requested mapping |
| Wheel Click | App Exposé | Opens App Exposé; replaces native middle click |
| Left/right click and scrolling | Untouched | Native behavior |

No app-specific profile was added. App restart was tested: the Lift reconnected in Upright and the menu-bar panel still showed the Mission Control mapping. **Open at login is off**, so Upright will not start automatically. Sleep/wake, Bluetooth reconnect after an actual disconnect, and physical button presses remain to be tested.

## Fedora PC configuration status

- Host: Fedora Linux 44, KDE Plasma 6.7.5, Wayland.
- The Lift (`046D:B031`) is paired with Fedora but was disconnected during inspection. Fedora reports no Solaar installation. The official Fedora repository offers Solaar 1.1.20 and its `solaar-udev` rules package.
- Proposed equivalent mappings: keep Back and Forward native; map Top/DPI to KDE Overview (`Meta+W`) and Wheel Click to Present Windows for the current application (`Ctrl+F7`, similar to App Exposé). The current Plasma shortcut file confirms both bindings.
- No Fedora package, device mapping, or udev rule has been installed. Solaar rules on Wayland need permission to access the Logitech HID++ interface and `/dev/uinput` to emit those shortcuts. The inspected upstream rule grants the active user raw access to Logitech HID devices and write access to `/dev/uinput`; this permits input injection and needs explicit approval. The current `/dev/uinput` node is root-only, and admin authentication is required to install the system package/rule.
- Fedora validation is pending Solaar installation, approval of the udev access rule, and connecting the mouse on its Fedora Easy-Switch channel.

## Permissions and limits

- **Input Monitoring: Allowed.** The local probe reported this status and Upright's Permissions pane showed it as Allowed. It enables opening the Logitech HID++ interface; it was already allowed when inspected.
- **Accessibility: Needed, not granted.** Upright's Permissions pane shows it as Needed. It is required for posting mapped keyboard shortcuts, media keys and clicks, and for scroll rewriting. Upright documents Mission Control and App Exposé as working without Accessibility, so the current button actions do not require granting it. Keep it off unless you later choose a mapping that requires it.
- The app's scroll rewriting controls are left at their defaults; scroll behavior was not changed or tested. The app notes that its scroll event tap applies to every mouse wheel while active because macOS does not identify the source mouse.
- The official app is universal (`arm64` and `x86_64`) and ad-hoc signed, not notarized. Gatekeeper's explicit assessment rejected the bundle as unnotarized. No Gatekeeper setting or quarantine flag was changed; the app was launched from `/Applications` after verifying the official release checksum. Do not use `xattr` quarantine removal or global Gatekeeper changes.
- No Logitech Options+ or competing remapper was installed.

## Configuration backup and rollback

- Pre-mapping backup: `~/Library/Application Support/Upright/backups/2026-10-24-pre-mapping.plist`.
- Upright preferences live in `~/Library/Preferences/io.github.upright.Upright.plist`; mapping key: `mappingProfiles.v3`.
- To restore the pre-mapping settings, quit Upright, then import the backup with `defaults import io.github.upright.Upright "$HOME/Library/Application Support/Upright/backups/2026-10-24-pre-mapping.plist"` and reopen Upright. Alternatively, use Settings → Buttons and set Top Button and Wheel Click back to **Default**; quit Upright to hand all temporarily diverted controls back to the mouse.
- To uninstall, quit Upright, remove `/Applications/Upright.app`, and remove its preferences with `defaults delete io.github.upright.Upright`. Delete the backup separately only if no longer needed. Input Monitoring can be revoked under System Settings → Privacy & Security → Input Monitoring.

## Follow-up validation

Physically press the DPI button and confirm Mission Control opens; press wheel click and confirm App Exposé opens. Check Back/Forward in a browser. Then test mouse sleep/wake, Bluetooth disconnect/reconnect, and restarting Upright. If a different mouse is connected during scroll tests, check that its wheel remains acceptable because Upright's optional scroll rewriting is global.
