# FlowState Sandbox

**Local multiplayer in Godot shouldn't feel like defusing a bomb.**

You know the pattern: your player script calls `Input.get_vector()`, then your state script calls it again, then your AI script needs the same data but from a different source, and before long everything is reaching into everything else. Add a second player with a controller and it all falls apart — the `Input` singleton can't tell device IDs apart cleanly, your states are glued to the keyboard, and "reusable" is a word that doesn't apply anymore.

**FlowState Sandbox** is an architecture that solves this. Data flows *down* — from input, through a context dict, into your states. Nothing reaches up. Nothing checks the keyboard directly. Plug in 4 controllers and they just work.

Built on **Godot 4.6** with **Jolt Physics** and the **[FlowHFSM](https://github.com/jamesonBradfield/FlowHfsm)** addon.

## What It Does Differently

- **Local multiplayer that just works** — `DeviceManager` detects controllers on connect, `LobbyManager` spawns avatars automatically. No manual device mapping, no wrestling with the `Input` singleton's `device_id` issues.
- **Push-data-down, not pull** — Your `Walk` state doesn't check `Input`. It reads `move_vec` from a context dict that's built fresh each frame. Swap in AI input, replay data, or a network packet and your states don't change at all.
- **Decoupled by design** — `StatePacket` sits between hardware and game logic. Raw input gets normalized (custom deadzones, sensitivity) *before* it reaches your character. Your character never sees the hardware.
- **Visual state editing** — FlowHFSM's editor lets you build and inspect your state hierarchy in real-time. Behaviors, conditions, and transitions — all visible, all modular.
- **Custom data resolvers** — Need camera-relative movement? Extend `FlowResolver`, pipe it into the context dict, and every downstream consumer gets the transformed data for free.
- **High-visibility debugging** — `QuickLogger` gives you colored, leveled terminal output so you can actually see what's flowing where.

## How It Works

Raw input goes in one end. Context comes out the other. States read the context and act. That's it.

```
DeviceManager                    LobbyManager                  SplitScreenManager
    │                                 │                               │
    │ new_device_connected            │ create_player()               │ assign_player_to_viewport()
    ▼                                 ▼                               ▼
InputToCommandBridge ──► StatePacket ──► FlowCharacter ──► SubViewport (rendering)
        │                       │               │
        │ Captures & normalizes │ Carries       │ _physics_process():
        │ per-device input      │ move/look/    │   1. _poll_input()
        │ (custom deadzones,    │ action data   │   2. data_map.resolve() → context dict
        │ sensitivity)          │               │   3. root_state.process_state(delta, self, context)
        │                       │                       │
        └───────────────────────┴───────────────────────┘
                                        │
                                        ▼
                                FlowState hierarchy
                                  ├── Behaviors read context
                                  ├── Conditions evaluate context
                                  └── required_keys filters context for children
```

### Input → Data → Context → State

Each stage is its own node with one job. Data flows one direction. Nothing reaches backward.

| Stage | Node | Job |
|-------|------|-----|
| Collect | `InputToCommandBridge` | Per-device input capture, custom deadzones, sensitivity normalization |
| Carry | `StatePacket` | Hardware-agnostic data container (`move_vec`, `look_vec`, `actions`) |
| Resolve | `FlowDataMap` | Builds a context dict each frame from PATH bindings or custom `FlowResolver`s |
| Decide | `FlowHFSM` | States, behaviors, and conditions all read from context — never from `Input` |
| Render | `SplitScreenManager` | Per-player SubViewport, HUD, and device-filtered pause menu |

> 📐 _Detailed architecture diagrams coming soon._

### Why Custom Input Handling?

Godot's `Input` singleton can't cleanly separate inputs by `device_id` in a local multiplayer context. Each `InputToCommandBridge` handles its own device's deadzones and sensitivity before the data ever reaches game logic. Your character script never touches `Input` — it just reads from context.

## Quick Start

```bash
git clone --recursive https://github.com/jamesonbradfield/FlowState-Sandbox.git
```

> Already cloned without `--recursive`? Run `git submodule update --init`.

1. Open in **Godot 4.6** (Forward Plus).
2. Run `main.tscn`.
3. Connect a controller or press a key — the `LobbyManager` spawns your avatar and the data starts flowing.

### Controls

| Input | Action |
|-------|--------|
| WASD | Movement |
| Space | Jump |
| Escape | Pause |
| Controller L-Stick | Move |
| Controller R-Stick | Look |
| Controller A | Jump |
| Controller Start | Pause |
