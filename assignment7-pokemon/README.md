# CS50 Games - Assignment 7: Pokemon

## Implemented Requirements
1. **Experience Bar (EXP Bar) UI**:
   - Blue progress bar dynamically rendered under player Pokemon's HP bar representing `currentExp / expToLevel`.
   - Smooth updates when EXP is awarded post-battle.
2. **Level-Up Stat Increases**:
   - When cumulative EXP exceeds the threshold, the Pokemon advances to the next level.
   - Core combat stats (`maxHP`, `attack`, `defense`, `speed`) scale dynamically with random increments mimicking classic Game Boy Pokemon mechanics.
3. **Turn-Based Battle State Machine**:
   - Random encounter zone when stepping through the grass patch.
   - Fight / Run menu selection, turn order damage calculation, and victory/defeat screens.

## Controls
- **Overworld**:
  - `W, A, S, D` or `Arrow Keys`: Move Trainer
- **Battle**:
  - `1` or `Space` or `Enter`: Fight / Advance Dialogue
  - `2`: Run from Battle
- **Escape**: Quit

## Submission
```bash
submit50 cs50/games/2018/projects/7/pokemon
```
