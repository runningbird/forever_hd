# Forever Graphics

A World of Warcraft Forever addon for client interface version `16001`. It applies selected graphics console variables at login and from an in-game Settings panel.

## Settings

The addon starts with the requested values enabled:

| Setting | Initial value |
| --- | ---: |
| `ResampleAlwaysSharpen` | 1 |
| `groundEffectDensity` | 256 |
| `groundEffectFade` | 370 |
| `groundEffectDist` | 500 |
| `cameraDistanceMaxZoomFactor` | 4.0 |
| `HDROutput` | 1 |
| `HDRFactor` | 1 |

Boolean options can be switched on or off directly. Numeric options have a **Manage** checkbox and an editable value. When a numeric option is unchecked, the addon stops changing that CVar and leaves its current value alone.

## Install

1. Copy the `ForeverGraphics` folder, containing `ForeverGraphics.toc` and `ForeverGraphics.lua`, into the client's `Interface/AddOns` directory.
2. The TOC targets interface version `16001`, reported by `GetBuildInfo()` on the Forever client.
3. Enable **Forever Graphics** in the AddOns list and reload the UI.
4. Open the panel with `/forevergraphics` or `/fg`.

The addon applies enabled values at login. The Settings panel also has an **Apply settings** button. Changes made to checkboxes or numeric fields apply immediately when applicable.
