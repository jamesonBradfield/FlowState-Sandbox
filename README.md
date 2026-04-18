# FlowState Sandbox

Welcome to **FlowState Sandbox**, an experimental Godot 4 architecture showcasing decoupled local multiplayer inputs, push-data-down state machines, and FlowHFSM integration.

> **Note:** This project was originally built during the Portfolio Builder Jam, but because I heavily used AI to brainstorm and design this architecture, I have **self-disqualified** myself from the jam. I want to clearly state that this is **solely an experiment** and **should not count towards any judging**. That being said, I am very proud of what I've achieved with it!

## Overview

This project is built using Godot 4.6 and features a modular approach to player control, input management, and state logic. It supports seamless local multiplayer and split-screen functionality out of the box.

### Key Features
- **Local Multiplayer Support:** Dynamically connects controllers and keyboards to distinct players using `DeviceManager` and `LobbyManager`.
- **Abstract Input Handling:** Decouples raw input from player logic using the `StatePacket` data structure.
- **Push-Data-Down Architecture:** The actor resolves a `FlowDataMap` into a context dict each frame, which flows DOWN through the state hierarchy. Behaviors and conditions read from context — they never reach into actor properties directly.
- **Custom Data Resolvers:** Extend `FlowResolver` to transform data before behaviors see it (e.g. camera-relative input transformation).
- **Hierarchical Finite State Machine:** Uses the **[FlowHFSM](https://github.com/jamesonBradfield/FlowHfsm)** addon to manage complex character states and behaviors visually and modularly.
- **Developer Tools:** Integrates a custom `QuickLogger` for fast debugging and development.

## Architecture & Data Flow

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

### 1. Input Collection (`InputToCommandBridge`)
Instead of the player character reading `Input` singleton directly, an `InputToCommandBridge` node is created for each connected device. This bridge listens to keyboard/mouse or controller inputs and normalizes them (e.g., applying custom deadzones and sensitivity).

**Note on Custom Input Handling:** We utilize custom deadzones and sensitivity calculations here because Godot's built-in `Input` singleton currently struggles to cleanly discern inputs coming from specific, multiple `device_id`s in a local multiplayer context.

### 2. Data Encapsulation (`StatePacket`)
The bridge continuously updates a `StatePacket` object containing:
- `move_vec`: A Vector2 representing movement intention.
- `look_vec`: A Vector2 representing camera look intention.
- `actions`: A Dictionary of boolean states for button presses (e.g., jump, interact).

### 3. Data Context (`FlowDataMap`)
The `FlowCharacter` has a `data_map: FlowDataMap` export that defines what keys are available in the context each frame. Each entry maps a `StringName` key to a `FlowBinding`:
- **PATH mode:** `^":move_input"` reads the `move_input` property from the actor
- **RESOLVER mode:** Delegates to a custom `FlowResolver` script for complex logic

If no `data_map` is assigned, `FlowCharacter` auto-builds one from common properties (`move_input`, `camera`, `is_moving`, `state_packet`, `last_actions`, `animation_tree`, `model`).

### 4. State Machine (`FlowHFSM` & `Avatar`)
The `LobbyManager` assigns the `StatePacket` to the spawned player avatar. The `Avatar` class inherits from `FlowCharacter` (provided by the FlowHFSM plugin).

The FlowHFSM drives the player's behavior:
- **FlowStates:** Define the current state (e.g., Idle, Walk, Airborne). Can declare `required_keys` to filter what context children receive.
- **FlowBehaviors:** Reusable scripts that read from context by configurable key names. `BehaviorPhysics` reads `move_input_key` and `camera_key`.
- **FlowConditions:** Evaluate data from context (like checking if `is_moving` is true) to trigger state transitions.

### 5. UI Layer (`SplitScreenManager`)
The `SplitScreenManager` creates a `CanvasLayer` with a `GridContainer` of `SubViewportContainer`s. Each player gets:
- A `SubViewport` for 3D rendering (shares the main World3D)
- A `HUD` overlay on the CanvasLayer (crosshair, state name, speed)
- A `PauseMenu` on the CanvasLayer (device-filtered, proper pause/resume)

The pause menu uses `_input()` with `device_id` filtering so each player can pause independently.

## Project Structure

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

## Setup
1. Clone the repository using `git clone --recursive https://github.com/jamesonbradfield/FlowState-Sandbox.git` (this ensures the FlowHFSM submodule is downloaded).
   - If you already cloned it without `--recursive`, run `git submodule update --init` inside the folder.
2. Open the project in Godot 4.6 (Forward Plus).
3. Run the main scene. Try connecting a controller or using the keyboard to see the `LobbyManager` dynamically spawn avatars.

### Input Mapping
- **WASD** — Movement
- **Space** — Jump
- **Escape** — Pause
- **Controller** — Left stick move, right stick look, A to jump, Start to pause
