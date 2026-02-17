
1. Session Management

| Shortcut                    | Action                |
| --------------------------- | --------------------- |
| `prefix + c`                | Create a new window   |
| `prefix + w`                | List windows          |
| `prefix + ,`                | Rename current window |
| `prefix + &`                | Kill current window   |
| `tmux new -s name`          | Start new session     |
| `tmux ls`                   | List sessions         |
| `tmux attach -t name`       | Attach to session     |
| `tmux kill-session -t name` | Kill session          |
| `prefix + d`                | Detach from session   |

2. Pane Management.

| Shortcut           | Action                          |                         |
| ------------------ | ------------------------------- | ----------------------- |
| `prefix +          | `                               | Split pane horizontally |
| `prefix + -`       | Split pane vertically           |                         |
| `prefix + h/j/k/l` | Move to left/down/up/right pane |                         |
| `prefix + H/J/K/L` | Resize pane left/down/up/right  |                         |
| `prefix + x`       | Close current pane              |                         |
| `prefix + q`       | Show pane numbers               |                         |

3. Copy Mode & Scrolling

| Shortcut     | Action                                           |
| ------------ | ------------------------------------------------ |
| `prefix + [` | Enter copy mode                                  |
| `v`          | Start selection (vi-style)                       |
| `y`          | Copy selection to Windows clipboard (`clip.exe`) |
| Mouse drag   | Select & copy automatically                      |
| `prefix + ]` | Paste buffer                                     |
| Scroll wheel | Scroll buffer (mouse enabled)                    |

4. Status & Layout

| Shortcut               | Action                   |
| ---------------------- | ------------------------ |
| `prefix + r`           | Reload config            |
| `prefix + space`       | Switch window layout     |
| `prefix + alt + arrow` | Cycle layouts (optional) |

5. Miscellaneous

| Shortcut     | Action                    |
| ------------ | ------------------------- |
| `prefix + ?` | Show all key bindings     |
| `prefix + :` | Command prompt            |
| `prefix + s` | Choose session            |
| `prefix + l` | Toggle last active window |
