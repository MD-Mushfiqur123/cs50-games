# CS50 Games - Assignment 8: Helicopter Game 3D

## Architecture & Implementation
Developed in C# for the Unity 3D Engine:
1. `HeliController.cs`:
   - Physics-based altitude lift via `Rigidbody.AddForce`.
   - Forward velocity clamping and realistic rotor spin animations (Main & Tail rotors).
   - Dynamic pitch tilt angle matching climbing/falling velocity.
   - Coin pickup (+100 pts), Gem pickup (+500 pts), crash triggers, and UI status updates.
2. `ObstacleSpawner.cs`:
   - Procedural infinite-runner level spawner.
   - Dynamically spawns skyscrapers, buildings, hovering coins, and rare gems along the forward Z-axis.
   - Automatic memory garbage collection removing obsolete buildings behind the player.

## Submission
```bash
submit50 cs50/games/2018/projects/8/helicopter
```
Or zip project folder and submit to the CS50 course portal.
