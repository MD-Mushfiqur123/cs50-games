# CS50 Games - Assignment 1: Fifty Bird (Flappy Bird)

## Assignment Objectives & Solutions
1. **Randomized Gap Height**: In `PipePair.lua`, `self.gap = math.random(75, 115)` instead of a fixed 90px gap.
2. **Randomized Interval Spacing**: In `main.lua`, `nextSpawnInterval = math.random(18, 32) / 10.0` (1.8 to 3.2 seconds between pipe spawns).
3. **Pause Feature**: Press `P` in `play` state to freeze scrolling, delta time, and bird physics while displaying a `PAUSED` overlay.
4. **Medal Reward System**:
   - Score 1 - 4: **Bronze Medal**
   - Score 5 - 9: **Silver Medal**
   - Score 10+: **Gold Medal**
   - Rendered with procedural medal graphics on the game over scoreboard.

## Controls
- **Space / Left Click**: Jump / Flap
- **P**: Pause / Unpause
- **Enter / Return**: Restart from Game Over
- **Escape**: Quit

## Submission
```bash
submit50 cs50/games/2018/projects/1/flappy
```
