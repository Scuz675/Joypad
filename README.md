# Joypad

**Controller-focused action bars, Smart Mouselook and UI navigation for World of Warcraft 3.3.5a.**

> [!WARNING]
> **Joypad is currently a public beta / development addon.**
>
> It was originally built and tuned through real gameplay on **Triumvirate WoW** and is only now being generalised for other players. Expect rough edges, assumptions that still need removing, and features that may behave differently with other classes, UI setups or private-server clients.

## What is Joypad?

Joypad is a lightweight controller interface for WoW 3.3.5a built around secure/protected action buttons rather than trying to replace the entire WoW UI.

The goal is to make normal WoW gameplay feel comfortable on a controller while still working with the game's existing action bars, macros, unit frames and addons.

Current Joypad includes:

- **24 controller-facing protected buttons**
- **Base, L2, R2 and L2+R2 action layers**
- **Smart Mouselook** for controller-friendly camera control
- **UI Cursor** for navigating WoW and addon frames
- Per-button positioning, scaling and visibility
- Xbox, Steam, PlayStation and Nintendo-style button labels
- Vehicle / possess / encounter action-bar takeover support
- Optional Raid Cursor and raid-target steering features
- Optional **AwesomeWotLK** integration
- Optional **ElvUI** presentation/integration
- Optional **Shifty** integration
- Built-in keybind checking, repair and diagnostics

Joypad does **not** require ConsoleXP.

## Current status

Current beta line:

```text
0.45.x
```

The current public-beta work is focused on separating:

- Joypad Core
- generic controller behaviour
- personal/class-specific profiles
- optional integrations
- development diagnostics

Fresh installs no longer assume ElvUI, Shifty or development logging.

Existing users upgrading from earlier builds keep their existing gameplay/layout choices.

## Requirements

### WoW

Joypad targets:

```text
World of Warcraft 3.3.5a
Interface: 30300
```

It is primarily developed and tested on the **Triumvirate** custom 3.3.5a environment.

Other 3.3.5a servers may work, but are not yet considered fully supported.

### Controller input

Joypad is a WoW addon, **not a native controller driver**.

Your controller still needs to produce keyboard/mouse inputs using something such as:

- Steam Input
- controller remapping software
- another compatible input layer

Joypad then binds those physical keyboard inputs to its protected controller buttons inside WoW.

### AwesomeWotLK — recommended

Joypad's preferred client integration is:

**AwesomeWotLK**  
https://github.com/noname08662/awesome_wotlk

With a compatible AwesomeWotLK build, Joypad can use:

- `C_NamePlate` enhancements for Smart Mouselook target hints
- the AwesomeWotLK interaction system
- `INTERACTIONKEYBIND`
- `QueueInteract()`

You can quickly check that the relevant AwesomeWotLK features are available with:

```lua
/run print("Awesome:", C_NamePlate and type(C_NamePlate.GetNamePlates), "Interact:", type(QueueInteract))
```

A compatible build should report:

```text
Awesome: function Interact: function
```

ConsoleXP is **not required** and current Joypad builds no longer depend on its `actiontarget` or `CXPINTERACT` systems.

## Installation

1. Download or clone this repository.
2. Put the `Joypad` folder in:

```text
World of Warcraft\Interface\AddOns\Joypad
```

3. Restart WoW or reload the UI.
4. Make sure **Joypad** is enabled at the character-select AddOns screen.
5. In game, open Joypad settings with:

```text
/joypad settings
```

## First setup

### 1. Choose your layout

Joypad currently provides:

- **Generic** — neutral public-beta starting point
- **Scuz / Stream** — development/reference layout used during Joypad's original testing

For a new tester, start with:

```text
/joypad profile generic
```

> The Scuz / Stream profile exists as a known-good development reference. It is not intended to be the universal default for every class.

### 2. Set your button-label style

Joypad supports visual labels for:

- Steam
- Xbox
- PlayStation
- Nintendo

This only changes the controller presentation. It does not move your WoW action slots.

### 3. Configure physical keybinds

Joypad has tools for applying and checking its expected keyboard bindings.

Open:

```text
/joypad settings
```

and use **Apply Core Keybinds**.

If you use the additional trackpad/rear-button row, you can also apply **Extended Controller Keybinds**.

> [!CAUTION]
> Applying Joypad keybinds changes WoW's normal keyboard bindings. The Extended set intentionally uses keys that may otherwise be assigned to default panels, movement or bags.

If something becomes unbound:

```text
/joypad checkkeys
/joypad repairkeys
```

### 4. Put abilities on your normal WoW action bars

Joypad uses WoW action slots.

Your class abilities, macros and consumables remain your own action-bar setup rather than being permanently baked into Joypad.

This is important: Joypad is intended to provide the **controller layer**, while WoW's existing bars remain the source of truth for your actual abilities.

## Controller layout

Joypad exposes 24 controller positions.

The core row is:

| Joypad slot | Controller label |
|---:|---|
| 1 | A |
| 2 | B |
| 3 | X |
| 4 | Y |
| 5 | D-Pad Up |
| 6 | D-Pad Left |
| 7 | D-Pad Right |
| 8 | D-Pad Down |
| 9 | L1 |
| 10 | R1 |
| 11 | Select / View |
| 12 | Start / Menu |

The extended row provides:

- left trackpad/directional positions
- right trackpad/directional positions
- L4 / R4
- L5 / R5

Every action position can participate in Joypad's modifier layers:

```text
Base
L2
R2
L2 + R2
```

## Smart Mouselook

Smart Mouselook is one of Joypad's core features.

It starts WoW's native mouselook for selected gameplay/controller events so that camera control feels more natural and the normal mouse cursor does not remain in the middle of gameplay.

The exact triggers are configurable.

Useful commands:

```text
/joypad mouselook on
/joypad mouselook off
```

AwesomeWotLK users can optionally use its enhanced nameplate data as the preferred aim/tooltip hint source.

Smart Mouselook itself remains Joypad-owned and does not depend on ConsoleXP.

## UI Cursor

UI Cursor provides a controller-oriented way to move through clickable UI elements while preserving normal controller gameplay outside UI interaction.

Toggle it with:

```text
/joypad uicursor on
/joypad uicursor off
```

Support varies between UI addons because WoW 3.3.5a frames were not designed around controller navigation.

## AwesomeWotLK interaction

When available, Joypad uses AwesomeWotLK's:

```text
INTERACTIONKEYBIND
```

for controller interaction.

This is preferable to stock `INTERACTTARGET`, because the stock command is mainly useful for targetable units and does not provide the same world-object interaction behaviour.

### Known interaction limitation

There is currently a known AwesomeWotLK/Triumvirate edge case where `/interact` may select an unintended nearby candidate or report:

```text
You need to be closer to interact with that target.
```

even though manually right-clicking the intended world object works.

This has been reported upstream to AwesomeWotLK.

If Joypad's interaction button and `/interact` produce the same result, the failure is in the AwesomeWotLK interaction candidate path rather than Joypad's binding.

## Profiles

Public-beta profile work is still evolving.

Current profiles include:

### Generic

Neutral starting point intended for beta testers.

It avoids assuming:

- ElvUI
- Shifty
- development logging

Apply with:

```text
/joypad profile generic
```

### Scuz / Stream

The original development/reference layout.

It is retained because it is heavily battle-tested and useful as a regression reference while Joypad is generalised.

Apply with:

```text
/joypad profile scuz
```

## Optional integrations

### AwesomeWotLK

Recommended.

Used for enhanced client-side controller features such as interaction and nameplate information when the required APIs are detected.

### ElvUI

Optional.

Joypad has additional behaviour and presentation that can work with ElvUI, particularly around raid/unit-frame features.

Fresh installs no longer assume ElvUI is present.

### Shifty

Optional.

Joypad exposes a read-only `JoypadAPI` and can display Shifty suggestion highlighting when Shifty is installed.

Fresh installs do not enable Shifty-specific presentation by default.

## Useful commands

### General

```text
/joypad settings
/joypad status
/joypad version
/joypad show
/joypad hide
/joypad toggle
/joypad lock
/joypad unlock
```

### Input

```text
/joypad bindings
/joypad checkkeys
/joypad repairkeys
/joypad fixinput
```

### Smart Mouselook

```text
/joypad mouselook on
/joypad mouselook off
/joypad smartcenter
/joypad centerzone
```

### UI Cursor

```text
/joypad uicursor on
/joypad uicursor off
```

### Profiles

```text
/joypad profile generic
/joypad profile scuz
```

### Diagnostics

Diagnostics are **off by default**.

For a bug-report session:

```text
/joypad diagnostics on
```

When finished:

```text
/joypad diagnostics off
```

To disable diagnostics and clear stored diagnostic logs:

```text
/joypad diagnostics clear
```

## `/joypad status`

When reporting a problem, please include the output of:

```text
/joypad status
```

It reports useful environment information such as:

- Joypad version
- active profile
- class
- AwesomeWotLK detection
- `QueueInteract()` availability
- Smart Mouselook state
- UI Cursor state
- ElvUI detection
- Shifty detection
- diagnostics state

## Reporting bugs

Please use the GitHub Issues page:

https://github.com/Scuz675/Joypad/issues

A useful report includes:

```text
Joypad version:
Server/client:
Class/spec:
Controller:
Controller input/remapping software:
AwesomeWotLK version:
UI addon (ElvUI/default/other):

/joypad status output:

What I expected:

What happened:

Steps to reproduce:

Lua error, if any:
```

Screenshots or short video clips are especially useful for controller/UI problems.

## Public-beta scope

Joypad is **not yet claiming to be a polished universal controller addon for every WoW 3.3.5a setup**.

The current beta is intended to answer a simpler question:

> Can another player install Joypad, map their controller, move/camera/interact/use modifier abilities, and play normally without inheriting the original developer's personal setup?

Feedback from different:

- classes/specs
- controllers
- UI addons
- screen resolutions
- AwesomeWotLK builds

is particularly useful.

## Development priorities

Current priorities include:

1. Removing remaining character/class-specific assumptions from Core.
2. Improving the generic first-run experience.
3. Separating Core, profiles and optional integrations more cleanly.
4. Testing classes other than Druid.
5. Improving controller/UI compatibility outside ElvUI.
6. Keeping diagnostics useful without making SavedVariables noisy.
7. Responding to issues found by public/stream testers.

## Notes for existing users

The public-beta cleanup is designed to preserve existing gameplay and layout settings when upgrading.

Diagnostic logging that was historically useful during development is now opt-in, and newer internal migration metadata is being moved away from normal user-facing configuration.

If an upgrade behaves unexpectedly, please report it rather than deleting your SavedVariables immediately — migration bugs are particularly useful to identify during beta.

---

Joypad started as a personal controller setup for 3.3.5a and gradually became something other players wanted to try after seeing it used in normal gameplay. The public beta is the process of turning that heavily tuned personal addon into something that can be safely and sensibly used by other people.
