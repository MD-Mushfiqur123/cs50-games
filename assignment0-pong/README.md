# CS50 Games - Assignment 0: Pong

## Objective
Implement an AI-controlled paddle such that either Player 1 or Player 2 (or both) can be controlled autonomously by tracking the Y coordinate of the ball.

## Implementation Details
In `main.lua`:
- We added an `ai` mode toggled with `TAB` (defaulting to AI on Player 2).
- Inside `love.update(dt)`, when `gameMode == 'ai'`, Player 2 checks the ball's Y-coordinate relative to the paddle's center:
  ```lua
  local paddleCenter = player2.y + player2.height / 2
  local ballCenter = ball.y + ball.height / 2
  local deadzone = 4 -- Prevents continuous micro-jittering

  if ballCenter < paddleCenter - deadzone then
      player2.dy = -PADDLE_SPEED
  elseif ballCenter > paddleCenter + deadzone then
      player2.dy = PADDLE_SPEED
  else
      player2.dy = 0
  end
  ```
- Player 1 is controlled by the user using `W` and `S` keys.

## Controls
- **W / S**: Move Player 1 Up / Down
- **Up / Down Arrows**: Move Player 2 Up / Down (in Human mode)
- **Enter / Return**: Start game / Serve ball / Restart after win
- **TAB**: Toggle AI / Human control for Player 2
- **Escape**: Quit game

## Submission Instructions
```bash
submit50 cs50/games/2018/projects/0/pong
```
Or zip this directory and upload to the CS50 course portal.
