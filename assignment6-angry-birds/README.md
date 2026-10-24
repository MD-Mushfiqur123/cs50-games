# CS50 Games - Assignment 6: Angry Birds

## Implemented Requirements
1. **Slingshot Projectile Mechanics**:
   - Elastic slingshot tension rendering, pullback trajectory calculation, and impulse-based launch physics using Love2D Box2D physics simulation.
2. **Alien Split Mechanic**:
   - Clicking or tapping the screen while the alien is airborne triggers the split mechanic.
   - The primary alien splits into **three distinct aliens**:
     - Main alien retains current forward momentum.
     - Child 1 deviates upward (`vy - 90`).
     - Child 2 deviates downward (`vy + 90`).
   - All three collision bodies participate simultaneously in smashing wooden structures and targets.
3. **Destructible Structures & Targets**:
   - Multi-block wooden beam structures and target pig entities that topple on physics impact.

## Controls
- **Left Click + Drag from Slingshot**: Pull back and aim
- **Release Left Click**: Launch Alien
- **Left Click in Mid-Air**: Trigger 3-way Alien Split
- **R**: Reset Level
- **Escape**: Quit

## Submission
```bash
submit50 cs50/games/2018/projects/6/birds
```
