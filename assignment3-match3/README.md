# CS50 Games - Assignment 3: Match 3

## Requirements Implemented
1. **Valid Swaps Only (Swap Reversion)**:
   - When the player selects adjacent tiles, the game tests whether the swap produces any match (`#matches > 0`).
   - If no match is created, the tiles are automatically reverted to their original positions without penalty.
2. **Shiny / Special Tiles**:
   - Shiny tiles sparkle with pulsing indicators.
   - When a shiny tile is matched horizontally, the **entire horizontal row** is wiped out.
   - When matched vertically, the **entire vertical column** is wiped out.
3. **Guaranteed Playable Board**:
   - During level generation and post-cascade reshuffling, `board:hasAvailableMatches()` verifies that at least one valid swap exists. If deadlocked, it automatically reshuffles the board.

## Controls
- **W, A, S, D** or **Arrow Keys**: Move cursor
- **Space** or **Enter**: Select first tile / swap with adjacent target tile
- **Escape**: Quit

## Submission
```bash
submit50 cs50/games/2018/projects/3/match
```
