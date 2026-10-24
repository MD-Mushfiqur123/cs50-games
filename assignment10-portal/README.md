# CS50 Games - Assignment 10: Portal

## Architecture & Implementation
Developed in C# for Unity 3D Engine:
1. `PortalGun.cs`:
   - Viewport center raycasting with layer masking against designated portalable surfaces (white panels).
   - Left-Click triggers the Blue Portal; Right-Click triggers the Orange Portal.
   - Surface normal alignment ensuring portals orient flush against wall surfaces.
   - Dynamic linking between paired portals upon instantiation.
2. `Portal.cs`:
   - Non-Euclidean physics teleportation system.
   - Preserves angular momentum and linear velocity using local matrix transformation (`InverseTransformPoint` / `TransformPoint`).
   - Ping-pong recursion prevention using entry tracking lists (`trackedColliders`).

## Controls
- **W, A, S, D**: Move
- **Mouse**: Look Around
- **Left Mouse Button**: Shoot Blue Portal
- **Right Mouse Button**: Shoot Orange Portal
- **Space**: Jump

## Submission
```bash
submit50 cs50/games/2018/projects/10/portal
```
