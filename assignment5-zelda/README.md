# CS50 Games - Assignment 5: Legend of Zelda

## Implemented Requirements
1. **Pot Lifting & Carrying**:
   - Approaching an idle ceramic pot and pressing `E` lifts it directly above the player's head.
   - The pot adheres to the player's movement and position.
2. **Pot Throwing & Shattering**:
   - Pressing `SPACE` while carrying a pot launches it in the player's facing direction.
   - Pots travel up to 4 tiles (64px) or until colliding with dungeon walls or enemy units.
   - Upon impact, the pot shatters and neutralizes the enemy.
3. **Room Transitions**:
   - Stepping through northern or southern doorways dynamically loads adjacent dungeon rooms, resetting entities and placing the player at the opposite doorway.
4. **Enemy AI & Sword Combat**:
   - Enemies patrol rooms autonomously and can be defeated using either sword strikes (`SPACE`) or thrown pots.

## Controls
- **W, A, S, D**: Move Link
- **E**: Lift Pot
- **Space**: Attack with Sword / Throw Held Pot
- **Escape**: Quit

## Submission
```bash
submit50 cs50/games/2018/projects/5/zelda
```
