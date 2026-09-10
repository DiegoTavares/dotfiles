# dotfiles

Personal configuration, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

Each top-level directory is a *stow package* whose contents mirror `$HOME`:

```
dotfiles/
├── claude/CLAUDE.md                → ~/CLAUDE.md
├── zed/.config/zed/                → ~/.config/zed/
├── nvim/.config/nvim/              → ~/.config/nvim
├── ohmyzsh/.zshrc                  → ~/.zshrc
└── kanata/.config/kanata/          → ~/.config/kanata
```

`CLAUDE.md` at the repo root is a symlink into the `claude` package so the
project instructions are still picked up from the repository root.

## Install

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` installs GNU Stow if it is missing (Homebrew, apt, dnf, pacman,
zypper or apk) and links the packages for the current platform.

```sh
./install.sh zed nvim        # only these packages
./install.sh --delete zed    # remove the links (any stow flag is passed through)
DRY_RUN=1 ./install.sh       # show what would change
```

Stow refuses to overwrite existing regular files. Move or delete the conflicting
file first, or use `stow --adopt <pkg>` to pull it into the repository.

## Notes

- `zed` and `nvim` use the same paths on macOS and Linux (`~/.config/...`).
- `kanata/.config/kanata/start.sh` starts the Karabiner virtual HID daemon on
  macOS only; on Linux it just runs `kanata`. Override the binary or config with
  `KANATA_BIN` / `KANATA_CONFIG`.
- Zed's `agent.terminal_init_command` points at `~/.config/zed/herdr-agent.sh`,
  which ships with the `zed` package and falls back to running the agent
  directly when herdr is not installed.
