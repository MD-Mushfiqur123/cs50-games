# CS50 Games - Assignment 9: Dreadhalls

## Architecture & Implementation
Developed in C# for Unity 3D:
1. `DungeonGenerator.cs`:
   - DFS Backtracking algorithm generating fully connected, non-looping procedural labyrinths.
   - Dynamic instantiation of modular 3D floor tiles, corridor walls, ceilings, and flickering torch props.
   - Automatic placement of player start spawn and level exit portal/doorway.
2. `FlashlightController.cs`:
   - First-person spot light simulation attached to camera rig.
   - Realistic battery degradation over time, low-power voltage flickering, and battery pick-up recharging.

## Controls
- **W, A, S, D**: First-Person Walk
- **Mouse**: Look Around (Pitch / Yaw)
- **F**: Toggle Flashlight
- **Escape**: Pause / Menu

## Submission
```bash
submit50 cs50/games/2018/projects/9/dreadhalls
```
