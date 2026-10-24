# StarVanguard: Capstone Final Project (CS50 Games)

## 1. Overview & Vision
**StarVanguard** is a retro-inspired, high-intensity vertical arcade shoot-'em-up (shmup) engineered from scratch in Lua using the **LÖVE (Love2D)** framework and pixel-perfect virtual coordinate scaling via `push.lua`. Designed to satisfy all capstone requirements for **Harvard CS50's Introduction to Game Development**, the project demonstrates complete mastery over the game loop, finite state machine patterns, 2D particle simulation, multi-tiered enemy artificial intelligence, collision detection algorithms, audio/visual cues, and scoring architectures.

---

## 2. Gameplay & Mechanics
In *StarVanguard*, the player pilots the cutting-edge **Vanguard-01 Starfighter** against five progressively escalative waves of enemy alien squadrons and dreadnoughts across the Orion Nebula.

### Core Mechanics:
1. **Full Omnidirectional Maneuvering**:
   - Smooth 8-directional vector movement constrained within screen boundaries (`VIRTUAL_WIDTH: 480`, `VIRTUAL_HEIGHT: 270`).
2. **Dual Laser Cannons**:
   - Rapid-fire twin plasma blasters with cadence management (`shootCooldown = 0.15s`) to balance firepower with overheat mechanics.
3. **Shield & Lives Dynamic**:
   - The ship features an adaptive energy shield (`100 Max Shield`) that absorbs laser impacts and minor collisions.
   - When depleted, the player loses one of their 3 reserve starfighters and enters a momentary invulnerability flicker phase (2.0s).
4. **Enemy Squadron Formations & AI**:
   - **Type 1 (Scout Interceptors)**: Agile, light hulls that weave rapidly across the upper airspace, dropping targeted disruptor shots.
   - **Type 2 (Heavy Cruisers)**: Heavily armored vessels with 3 HP that withstand laser fire and fire sustained barrages.
   - **Type 3 (Dreadnought Boss)**: Appears on milestone waves (Wave 3 and Wave 5), boasting 30 HP, dynamic boss health bar HUD, and a lethal 3-way spread volley pattern.
5. **Particle Spark FX**:
   - Explosions feature vector-based particle emitters that disperse procedural sparks and fragments with fading alpha curves based on entity color palettes.

---

## 3. Technical Architecture & State Machine

The codebase follows a modular object-oriented design built on Lua metatables:

```
projects/cs50g/project/
├── main.lua          # Main game loop (load, update, draw, keypressed)
├── StateMachine.lua  # Finite State Machine implementation
├── push.lua          # Virtual resolution resolution-independent renderer
├── class.lua         # Lua OOP class metatable library
└── README.md         # Comprehensive project specification (>500 words)
```

### State Management:
1. **`title` State**:
   - Displays the retro neon title screen, briefing instructions, and waits for user activation (`Space` or `Enter`).
2. **`play` State**:
   - Active gameplay loop handling delta-time physics, laser arrays, collision resolution (AABB bounding boxes), enemy wave progression, and HUD rendering.
3. **`gameover` State**:
   - Triggered when all 3 starfighters are destroyed. Summarizes score and offers one-touch restart.
4. **`victory` State**:
   - Triggered upon clearing Wave 5 and destroying the final Dreadnought Boss. Celebrates mission completion with high score.

### Collision Detection:
Bounding box Axis-Aligned Bounding Box (AABB) intersection is performed every frame between:
- Player lasers vs. enemy fleets
- Enemy lasers vs. player starfighter
- Direct physical collisions between enemy hulls and the player starfighter

---

## 4. User Controls & Keybindings
| Action | Key / Input |
|---|---|
| **Move Up / Forward** | `W` or `Up Arrow` |
| **Move Down / Backward** | `S` or `Down Arrow` |
| **Strafe Left** | `A` or `Left Arrow` |
| **Strafe Right** | `D` or `Right Arrow` |
| **Dual Plasma Blasters** | `Space` or `Left Mouse Button` |
| **Restart / Advance** | `Space` or `Return / Enter` |
| **Quit Game** | `Escape` |

---

## 5. How to Run Locally
Ensure you have [LÖVE (Love2D)](https://love2d.org/) installed:
```bash
love c:\Users\mushfiqur\Desktop\agent\projects\cs50g\project\
```
Or drag and drop the `project/` directory directly onto the Love2D executable.

---

## 6. Verification & CS50 Compliance
- **Main Loop**: Complete 60 FPS delta-time integration.
- **State Machine**: Clean separation of title, gameplay, gameover, and victory states.
- **Asset / Procedural Loader**: Procedural vector rendering and audio synthesis guaranteeing zero missing binary asset crashes.
- **Scoring & Waves**: Persistent wave tracker and enemy defeat score multiplier.
