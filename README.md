# Dotfiles

Personal Linux configuration managed with [chezmoi][chezmoi], built on
[Omarchy][omarchy] (Arch Linux + Hyprland) with a focus on agentic coding.

## Stack

| Area | Tools |
| --- | --- |
| Desktop | Omarchy, Hyprland |
| Terminal workspaces | Herdr |
| Coding agent | OpenCode, opencode.nvim, CodeCompanion |
| Editor | Neovim with LazyVim |
| Shell | zsh, Oh My Zsh, Powerlevel10k, fzf, zoxide, eza, yazi |
| Terminals | Alacritty, Kitty, Foot, Ghostty |
| Multiplexer | tmux, tmuxinator |
| Documents | zathura |
| Automation | systemd user timers |

## Configuration

**Omarchy / Hyprland** — Personal overrides only: Vim-style window focus and
swapping, monitor workspace moves, keyboard and touchpad input, and window gaps.
Machine-specific monitor layouts are ignored.

**Herdr** — tmux-like terminal workspaces for AI agents: prefix and pane keys,
theme, default shell, session restore, and a workspace launcher script. Runtime
state and logs are ignored.

**Agentic coding** — OpenCode is the main agent, with a global config and Neovim
integration through opencode.nvim. CodeCompanion uses Gemini and the OpenCode
CLI. Shell aliases start OpenCode sessions, and the automation scripts use
OpenCode to write commits.

**Neovim** — LazyVim with language and AI extras plus personal plugin overrides.
Older Neovim and Vim configs are kept for reference.

**Shell** — zsh with Oh My Zsh, Powerlevel10k, autosuggestions, syntax
highlighting, fzf, zoxide, eza, yazi, conda/mamba, and a few git helpers.

**Terminals** — Alacritty, Kitty, Foot, and Ghostty, using Omarchy theme includes
where supported.

**tmux** — tmux config with TPM plugins, plus tmuxinator project templates.

**Other** — git config with delta and git-lfs, zathura, and shared git ignore
rules.

**Automation** — Systemd user timers run scripts that capture chezmoi drift, let
OpenCode group changes into Conventional Commits, rebase, apply, and push.
Desktop notifications report failures.

## Repository layout

This is the chezmoi source directory, not a mirror of `$HOME`.

- `dot_` prefixes a leading dot.
- `private_` sets private permissions.
- `executable_` marks executable scripts.
- `.tmpl` files are rendered as templates.

`.chezmoiignore` excludes generated and machine-specific files such as lockfiles,
theme symlinks, monitor layouts, and runtime state.

## Setup

Install Omarchy and the required tools, then apply the dotfiles:

```sh
sudo pacman -S chezmoi neovim tmux tmuxinator zathura alacritty kitty foot \
  zsh fzf zoxide eza yazi git-lfs

chezmoi init --apply <repo-url>
systemctl --user enable --now chezmoi-autocommit.timer notes-autocommit.timer
```

Herdr, OpenCode, LazyVim plugins, tmux plugins, and the Omarchy theme are
installed by their own tools.

## Usage

```sh
chezmoi edit ~/.zshrc   # edit the source
chezmoi diff            # inspect changes
chezmoi apply           # apply to $HOME
chezmoi re-add          # capture changes made in $HOME
```

Feel free to explore and take what you find useful.

[chezmoi]: https://www.chezmoi.io/
[omarchy]: https://omarchy.org/
[herdr]: https://github.com/herdrdev/herdr
[opencode]: https://opencode.ai/
