# FlowState Sandbox

Welcome to **FlowState Sandbox**, an experimental Godot 4 architecture showcasing decoupled local multiplayer inputs and FlowHFSM integration.

> **Note:** This project was originally built during the Portfolio Builder Jam, but because I heavily used AI to brainstorm and design this architecture, I have **self-disqualified** myself from the jam. I want to clearly state that this is **solely an experiment** and **should not count towards any judging**. That being said, I am very proud of what I've achieved with it!

## Overview

This project is built using Godot 4.6 and features a modular approach to player control, input management, and state logic. It supports seamless local multiplayer and split-screen functionality out of the box.

### Key Features
- **Local Multiplayer Support:** Dynamically connects controllers and keyboards to distinct players using `DeviceManager` and `LobbyManager`.
- **Abstract Input Handling:** Decouples raw input from player logic using the `StatePacket` data structure.
- **Hierarchical Finite State Machine:** Uses the **[FlowHFSM](https://github.com/jamesonBradfield/FlowHfsm)** addon (which is another GitHub repo of mine) to manage complex character states and behaviors visually and modularly.
  > **Note on FlowHFSM:** While this project utilizes [FlowHFSM](https://github.com/jamesonBradfield/FlowHfsm), I haven't quite nailed how to handle input and other stateless data effectively enough to recommend this specific architecture for anyone else yet.
- **Developer Tools:** Integrates `Panku Console`, `Debug Menu`, and a custom `QuickLogger` for fast debugging and development.

## Architecture & FlowHFSM Integration

One of the core technical highlights of this project is how it handles player input and state logic. The architecture cleanly separates the "brain" (input processing) from the "body" (the avatar).

### The Flow
1. **Input Collection (`InputToCommandBridge`):**
   Instead of the player character reading `Input` singleton directly, an `InputToCommandBridge` node is created for each connected device. This bridge listens to keyboard/mouse or controller inputs and normalizes them (e.g., applying custom deadzones and sensitivity).
   
   **Note on Custom Input Handling:** We utilize custom deadzones and sensitivity calculations here because Godot's built-in `Input` singleton currently struggles to cleanly discern inputs coming from specific, multiple `device_id`s in a local multiplayer context without causing crossover or missing nuances (like independent sensitivity settings per controller).

2. **Data Encapsulation (`StatePacket`):**
   The bridge continuously updates a `StatePacket` object. This packet contains:
   - `move_vec`: A Vector2 representing movement intention.
   - `look_vec`: A Vector2 representing camera look intention.
   - `actions`: A Dictionary of boolean states for button presses (e.g., jump, interact).

3. **State Machine (`FlowHFSM` & `Avatar`):**
   The `LobbyManager` assigns the `StatePacket` to the spawned player avatar. The `Avatar` class inherits from `FlowCharacter` (provided by the FlowHFSM plugin). 
   
   The FlowHFSM integration drives the player's behavior:
   - **FlowStates:** Define the current state of the player (e.g., Idle, Moving, Airborne).
   - **FlowBehaviors:** Reusable scripts attached to states that read the `StatePacket` to execute logic. For example, `BehaviorPhysics` applies forces based on `move_vec`, and `BehaviorLook` rotates the camera based on `look_vec`.
   - **FlowConditions:** Evaluate data in the `StatePacket` (like checking if `move_vec` is non-zero) to trigger state transitions (e.g., transitioning from Idle to Walk).

### Why this approach?
- **Modularity:** Behaviors and conditions are highly reusable across different characters or AI.
- **Networking/Replays:** Because the player's movement is entirely driven by a `StatePacket`, adding network synchronization, AI puppetting, or a replay system becomes trivial. You just feed a different `StatePacket` to the `FlowCharacter`.
- **Clean Code:** Avoids massive "spaghetti" `_physics_process` functions by breaking logic into isolated, manageable HFSM nodes.

## Setup
1. Clone the repository using `git clone --recursive https://github.com/jamesonBradfield/FlowState-Sandbox.git` (this ensures the FlowHFSM submodule is downloaded).
   - If you already cloned it without `--recursive`, run `git submodule update --init` inside the folder.
2. Open the project in Godot 4.6 (Forward Plus).
3. Run the main scene. Try connecting a controller or using the keyboard to see the `LobbyManager` dynamically spawn avatars.