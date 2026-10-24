# CS50 Games - Assignment 4: Super Mario Bros.

## Implemented Requirements
1. **Procedural Platforming Level Generator**:
   - Generates varying terrain with grounded tiles, floating blocks, chasms, and sky backgrounds.
2. **Key Block & Lock Block Mechanics**:
   - The level randomly places a Key and a Lock Block.
   - Upon picking up the Key and colliding with the Lock Block, the lock is unlocked, granting 1,000 points and triggering the goal flag post to spawn.
3. **Flagpost Goal & Level Progression**:
   - Reaching and touching the goal post triggers `LEVEL COMPLETE` and transitions to the next procedurally generated level.
4. **Jumping & Camera Physics**:
   - Realistic gravity, velocity-based jump calculation, ground detection, and side-scrolling camera tracker.

## Controls
- **A / D** or **Left / Right Arrows**: Walk
- **Space** or **W** or **Up**: Jump
- **Escape**: Quit

## Submission
```bash
submit50 cs50/games/2018/projects/4/mario
```
