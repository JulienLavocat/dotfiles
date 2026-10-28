---
description: Add a tool's shell setup to the dotfiles in a form that works on both Linux and macOS. Use when the user installs a CLI or SDK, when an installer (pnpm, bun, volta, sdkman, conda, opencode…) appended lines to ~/.zshrc, or when asked to add an env var, PATH entry, alias or completion to the zsh config.
---

## Pending changes in the dotfiles

!`git -C ~/dotfiles status --short`

!`git -C ~/dotfiles diff -- .zshrc .zsh`

## Layout

The dotfiles live in `~/dotfiles` and are linked into `~` with `stow .`. `~/.zshrc` is a symlink to `~/dotfiles/.zshrc`, so anything an installer appends to `~/.zshrc` lands in the repo, usually with hardcoded paths. The same config is used on a Linux desktop and a MacBook.

| Kind of setting | Where it goes |
|---|---|
| PATH entry, env var or init for a tool used on both machines | `.zshrc` |
| Setting whose value differs by OS (clipboard command, `~/Library/...` paths) | `.zsh/os/linux.sh` and `.zsh/os/darwin.sh` |
| Aliases and general functions | `.zsh/aliases.sh`, `.zsh/functions.sh` |
| Anything tied to one project | `.zsh/projects/<project>.sh` |
| Static completion file (`_tool`) | `.zsh/completions/` (already on `fpath`) |
| Only makes sense on one machine | `~/.zshrc.local`, not tracked; say so to the user |

## Rules

- Use `$HOME`, never `/home/julien` or `/Users/julien`.
- Add PATH entries to the `path=(...)` array in `.zshrc` with the `(N-/)` qualifier so missing directories are skipped. Put entries that must win before `$path`, the rest after. Never write `export PATH=...:$PATH`: it bypasses `typeset -U` and creates duplicates in shells started inside tmux.
- Guard commands that may not be installed: `(( $+commands[tool] )) && eval "$(tool init zsh)"`. Guard sourced files with `[[ -s file ]]`.
- Keep the p10k instant prompt block first; nothing above it may print output. Keep the SDKMAN block and then the zoxide block last, in that order.
- When replacing an installer's block, remove it entirely and tell the user that re-running that installer will append it again.
- Leave commented-out blocks as they are unless asked.

## Verify

1. `zsh -n` every file you touched.
2. Start a shell with `TMUX=1` set, otherwise `.zshrc` attaches to tmux and the command hangs:
   ```sh
   TMUX=1 zsh -i -c 'whence -p <tool>; echo $PATH | tr : "\n" | sort | uniq -d' 2>&1
   ```
   The tool should resolve and the duplicate list should be empty. Errors about `monitor`, `zle` or gitstatus come from the shell having no terminal and also happen with the committed config; ignore them. Anything else (`command not found`, `no such file`) is a real problem.
3. You can only test the current OS. Say which one was not tested.

## Finish

Report what went where and why in a few lines. Don't commit unless asked.
