# Harvard CS50 Games (cs502d) Master Solutions & Submission Manual

This manual contains instructions, technical solutions, and exact commands for running and submitting all 11 assignments and the Capstone Final Project for **Harvard CS50's Introduction to Game Development** (`cs502d`).

---

## 🗂️ Project Directory Structure

```
projects/cs50g/
├── assignment0-pong/           # AI Paddle tracking Y coordinate
├── assignment1-flappy-bird/    # Randomized pipe gap heights & spacing, pause, medals
├── assignment2-breakout/       # Locked brick, key & multiball powerups, paddle sizing
├── assignment3-match3/         # Shiny matches, guaranteed board, swap reversal
├── assignment4-mario/          # Jumping physics, key & lock blocks, gems, flagpole goal
├── assignment5-zelda/          # Pot lifting, carrying, throwing, room transitions
├── assignment6-angry-birds/    # Slingshot Box2D physics & mid-air 3-way alien split
├── assignment7-pokemon/        # EXP Bar UI, level-up stat increases, turn-based battle
├── assignment8-helicopter/     # Unity 3D C# HeliController & ObstacleSpawner
├── assignment9-dreadhalls/     # Unity 3D C# DungeonGenerator & FlashlightController
├── assignment10-portal/        # Unity 3D C# PortalGun & non-Euclidean Portal teleportation
├── project/                    # Capstone Final Project: StarVanguard (500+ word README)
└── final-project/              # Capstone Final Project Mirror
```

---

## 🚀 How to Run the Projects

### Running Love2D Games (Assignments 0 - 7, Final Project)
Make sure [LÖVE 2D (v11+)](https://love2d.org/) is installed on your computer.

```bash
# Run Assignment 0 (Pong)
love "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment0-pong"

# Run Assignment 1 (Flappy Bird)
love "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment1-flappy-bird"

# Run Assignment 2 (Breakout)
love "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment2-breakout"

# Run Assignment 3 (Match 3)
love "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment3-match3"

# Run Assignment 4 (Super Mario)
love "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment4-mario"

# Run Assignment 5 (Legend of Zelda)
love "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment5-zelda"

# Run Assignment 6 (Angry Birds)
love "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment6-angry-birds"

# Run Assignment 7 (Pokemon)
love "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment7-pokemon"

# Run Final Project (StarVanguard)
love "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\project"
```

### Running Unity 3D Projects (Assignments 8 - 10)
1. Open **Unity Hub** and select Unity 2018.4+ / 2019+ / 2020+.
2. Attach the respective C# scripts from `projects/cs50g/assignment<N>/`:
   - Assignment 8: Attach `HeliController.cs` to the Helicopter GameObject and `ObstacleSpawner.cs` to a Level Spawner GameObject.
   - Assignment 9: Attach `DungeonGenerator.cs` to a GameManager and `FlashlightController.cs` to the First-Person Camera.
   - Assignment 10: Attach `PortalGun.cs` to the First-Person Camera and `Portal.cs` to the Blue/Orange Portal prefabs.

---

## 📤 Official CS50 Submission Commands

CS50 uses `submit50` via GitHub authentication:

```bash
# Assignment 0: Pong
cd "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment0-pong"
submit50 cs50/games/2018/projects/0/pong

# Assignment 1: Fifty Bird (Flappy Bird)
cd "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment1-flappy-bird"
submit50 cs50/games/2018/projects/1/flappy

# Assignment 2: Breakout
cd "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment2-breakout"
submit50 cs50/games/2018/projects/2/breakout

# Assignment 3: Match 3
cd "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment3-match3"
submit50 cs50/games/2018/projects/3/match

# Assignment 4: Super Mario Bros.
cd "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment4-mario"
submit50 cs50/games/2018/projects/4/mario

# Assignment 5: The Legend of Zelda
cd "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment5-zelda"
submit50 cs50/games/2018/projects/5/zelda

# Assignment 6: Angry Birds
cd "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment6-angry-birds"
submit50 cs50/games/2018/projects/6/birds

# Assignment 7: Pokemon
cd "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment7-pokemon"
submit50 cs50/games/2018/projects/7/pokemon

# Assignment 8: Helicopter Game 3D
cd "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment8-helicopter"
submit50 cs50/games/2018/projects/8/helicopter

# Assignment 9: Dreadhalls
cd "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment9-dreadhalls"
submit50 cs50/games/2018/projects/9/dreadhalls

# Assignment 10: Portal
cd "c:\Users\mushfiqur\Desktop\agent\projects\cs50g\assignment10-portal"
submit50 cs50/games/2018/projects/10/portal
```

### Capstone Final Project Submission
1. Submit your project URL / GitHub repository via the CS50 Final Project portal:  
   `https://submit.cs50.io/users/<your-github-username>/cs50/games/2018/projects/final`
2. Include the YouTube demo link and the provided `projects/cs50g/project/README.md` (which meets the 500+ word requirement).

---

## 🎯 Verification Checklist

- [x] **Assignment 0 (Pong)**: Autonomous AI paddle tracking ball Y coordinate.
- [x] **Assignment 1 (Flappy Bird)**: Randomized pipe gaps, interval variations, pause feature, and bronze/silver/gold medals.
- [x] **Assignment 2 (Breakout)**: Locked brick requiring key pickup, multiball powerups, and paddle resizing dynamics.
- [x] **Assignment 3 (Match 3)**: Shiny tile clearing entire rows/columns, guaranteed valid swap enforcement, deadlock reshuffling.
- [x] **Assignment 4 (Super Mario)**: Procedural chasm level generator, key block, lock block unlocking goal post, gem scoring.
- [x] **Assignment 5 (Zelda)**: Pot lifting, overhead carrying, throwing physics, enemy knockouts, and room transitions.
- [x] **Assignment 6 (Angry Birds)**: Box2D slingshot physics, 3-way alien split on mid-air tap/click.
- [x] **Assignment 7 (Pokemon)**: Blue EXP bar progress display, level-up stat increases, and turn-based battle state machine.
- [x] **Assignment 8 (Helicopter 3D)**: Unity C# `HeliController` & procedural infinite `ObstacleSpawner`.
- [x] **Assignment 9 (Dreadhalls)**: Unity C# DFS `DungeonGenerator` & battery-draining `FlashlightController`.
- [x] **Assignment 10 (Portal)**: Unity C# raycasting `PortalGun` & non-Euclidean momentum-preserving `Portal`.
- [x] **Capstone Final Project (StarVanguard)**: Full standalone Love2D game with state machines, particle systems, multi-tiered enemy/boss waves, and 500+ word technical specification.
