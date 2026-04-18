# 🌊 FlowState Sandbox

### The "Data Bucket Brigade" Architecture for Godot 4.6

**Stop writing signal spaghetti. Start flowing data.**

FlowState Sandbox is a high-performance, decoupled architecture experiment for Godot 4.6 — built specifically for developers who need to manage complex character states and local multiplayer without their codebase collapsing under the weight of `Input` singleton checks.

---

## 🏗 The Architecture: The "Data Bucket Brigade"

Traditional Godot characters *reach out* to grab input. This creates tight coupling. In FlowState, data flows in a **one-way Bucket Brigade**:

```
                  ┌───────────────┐
                  │ The Collector │  InputToCommandBridge
                  │ Captures raw  │  Stands between hardware
                  │ KBM/Controller│  and the game. Applies
                  │ input, applies│  custom deadzone math,
                  │ custom        │  then drops into a bucket.
                  │ deadzones     │
                  └───────┬───────┘
                          │
                          ▼
                  ┌───────────────┐
                  │  The Bucket   │  StatePacket
                  │  A lightweight│  Doesn't care if a human
                  │ data container│  or AI holds it — carries
                  │  move/look/   │  move_vec, look_vec, and
                  │     act       │  action states onward.
                  └───────┬───────┘
                          │
                          ▼
                  ┌───────────────┐
                  │  The Handoff  │  FlowDataMap
                  │ Every frame,  │  Character resolves the
                  │  builds a     │  bucket into a Context Dict
                  │ "Context Dict"│  — a snapshot of the world.
                  └───────┬───────┘
                          │
                          ▼
                  ┌───────────────┐
                  │ The Consumer  │  FlowHFSM
                  │  The state    │  "Walk" state doesn't check
                  │ machine reads │  the keyboard — it just
                  │  the bucket   │  looks in the bucket for
                  │  & decides    │  a move_vec. Pure flow.
                  └───────────────┘
```

### The Full Pipeline

```
DeviceManager                    LobbyManager                  SplitScreenManager
    │                                 │                               │
    │ new_device_connected            │ create_player()               │ assign_player_to_viewport()
    ▼                                 ▼                               ▼
InputToCommandBridge ──► StatePacket ──► FlowCharacter ──► SubViewport (rendering)
                                            │
                                  _physics_process():
                                    1. _poll_input()         # Updates move_input, is_moving, etc.
                                    2. data_map.resolve()    # Builds context dict
                                    3. root_state.process_state(delta, self, context)
                                          │
                                          ▼
                                    FlowState hierarchy
                                      ├── Behaviors read context
                                      ├── Conditions evaluate context
                                      └── required_keys filters context for children
```

---

## 🚀 Key Features

- **Zero-Friction Local Multiplayer** — Plug in 4 controllers and they *just work*. `DeviceManager` and `LobbyManager` route hardware to the right Brigade automatically.
- **Push-Data-Down Logic** — Behaviors never "reach up" to the actor. Data is pushed down, ensuring your states are 100% reusable and decoupled.
- **Jolt Physics Integrated** — Built for 3D performance using the industry-standard Jolt engine.
- **Visual Logic Workbench** — The FlowHFSM editor lets you see your Bucket Brigade in action in real-time.
- **Custom Data Resolvers** — Extend `FlowResolver` to transform data before behaviors see it (e.g., camera-relative input transformation).
- **Developer Tools** — Custom `QuickLogger` for high-visibility terminal debugging.

---

## 🛠 Tech Stack

| Layer | Tech |
|-------|------|
| Engine | Godot 4.6 (Forward Plus) |
| Physics | Jolt Physics |
| Logic | [FlowHFSM](https://github.com/jamesonBradfield/FlowHfsm) — Hierarchical Finite State Machine |
| Logging | Custom QuickLogger for high-visibility terminal debugging |

---

## 📥 Getting Started

```bash
# Clone with submodules to get the FlowHFSM core
git clone --recursive https://github.com/jamesonBradfield/FlowState-Sandbox.git
```

> Already cloned without `--recursive`? Run `git submodule update --init` inside the folder.

1. Open in **Godot 4.6**.
2. Run `main.tscn`.
3. Connect a controller or press a key — the `LobbyManager` will spawn your avatar and start the Brigade.

### Input Mapping

| Input | Action |
|-------|--------|
| WASD | Movement |
| Space | Jump |
| Escape | Pause |
| Controller L-Stick | Move |
| Controller R-Stick | Look |
| Controller A | Jump |
| Controller Start | Pause |

---

## 📂 Project Structure

```
├── Scenes/
│   ├── main.tscn              # 3D world (floor, lighting, sky)
│   ├── player.tscn            # FlowCharacter with FlowState hierarchy
│   ├── pause.tscn             # Pause menu UI
│   └── hud.tscn               # HUD overlay
├── Scripts/
│   ├── Core_Systems/
│   │   ├── quick_logger.gd    # Colored, leveled logging
│   │   ├── settings.gd        # Input sensitivity & deadzone config
│   │   └── session_manager.gd # (placeholder)
│   ├── Entities/
│   │   └── avatar.gd          # Extends FlowCharacter
│   ├── Input_Pipeline/
│   │   ├── device_manager.gd  # Detects & routes input devices
│   │   ├── input_to_command_bridge.gd  # Per-device input → StatePacket
│   │   ├── lobby_manager.gd   # Spawns players on device connect
│   │   ├── split_screen_manager.gd     # SubViewport grid + UI overlays
│   │   └── state_packet.gd    # Move/Look/Action data container
│   └── UI_Controllers/
│       ├── hud.gd             # Per-player HUD (state, speed, device)
│       └── pause_menu.gd     # Per-player pause menu
└── addons/
    └── FlowHFSM/              # Submodule: git@github.com:jamesonbradfield/FlowHfsm.git
        └── src/
            ├── core/           # FlowState, FlowBehavior, FlowCondition,
            │                   # FlowDataMap, FlowDataEntry, FlowBinding,
            │                   # FlowResolver, FlowCharacter
            ├── library/        # BehaviorPhysics, BehaviorLook, BehaviorRotation,
            │                   # ConditionInput, ConditionIsMoving, etc.
            └── editor/         # LogicSmasher workbench
```
