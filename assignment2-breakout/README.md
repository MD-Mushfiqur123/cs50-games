# CS50 Games - Assignment 2: Breakout

## Assignment Features Implemented
1. **Locked Brick Mechanism**:
   - Spawns distinct golden locked bricks with keyholes that cannot be broken by ball collisions alone.
   - Requires collecting the falling Key Powerup to unlock and clear them for 2,500 bonus points.
2. **Powerups System**:
   - **Key Powerup**: Drops randomly and grants the ability to break locked bricks upon paddle contact.
   - **Multi-Ball Powerup**: Instantly spawns 2 additional balls into the playfield with differentiated trajectory angles.
3. **Paddle Resizing Dynamics**:
   - **Score Milestones**: Paddle grows larger when crossing score thresholds (3,000 and 7,000 points).
   - **Shrinkage Penalty**: Paddle shrinks by one tier each time a life/ball is lost, down to minimum size.

## Controls
- **A / D** or **Left / Right Arrows**: Move Paddle
- **Space / Enter**: Launch Ball / Advance / Restart
- **Escape**: Exit

## Submission
```bash
submit50 cs50/games/2018/projects/2/breakout
```
