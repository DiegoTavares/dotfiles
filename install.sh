#!/usr/bin/env bash
# Symlink this repository's dotfiles into $HOME with GNU Stow.
#
# Usage:
#   ./install.sh                # stow the packages for this platform
#   ./install.sh zed nvim       # stow only the named packages
#   ./install.sh --delete zed   # unstow (any stow flag is passed through)
#   DRY_RUN=1 ./install.sh      # show what would change

set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Packages that make sense everywhere, plus the platform-specific ones.
COMMON_PACKAGES=(claude zed nvim ohmyzsh)
DARWIN_PACKAGES=(kanata)
LINUX_PACKAGES=(kanata)

log() { printf '==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

install_stow() {
    log "GNU Stow not found, installing"
    if command -v brew >/dev/null 2>&1; then
        brew install stow
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y stow
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y stow
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm stow
    elif command -v zypper >/dev/null 2>&1; then
        sudo zypper install -y stow
    elif command -v apk >/dev/null 2>&1; then
        sudo apk add stow
    else
        die "no supported package manager found; install GNU Stow manually"
    fi
}

default_packages() {
    case "$(uname -s)" in
        Darwin) printf '%s\n' "${COMMON_PACKAGES[@]}" "${DARWIN_PACKAGES[@]}" ;;
        Linux)  printf '%s\n' "${COMMON_PACKAGES[@]}" "${LINUX_PACKAGES[@]}" ;;
        *)      printf '%s\n' "${COMMON_PACKAGES[@]}" ;;
    esac
}

main() {
    command -v stow >/dev/null 2>&1 || install_stow

    local flags=() packages=()
    for arg in "$@"; do
        case "$arg" in
            -*) flags+=("$arg") ;;
            *)  packages+=("$arg") ;;
        esac
    done

    if [[ ${#packages[@]} -eq 0 ]]; then
        while IFS= read -r pkg; do packages+=("$pkg"); done < <(default_packages)
    fi

    for pkg in "${packages[@]}"; do
        [[ -d "$DOTFILES_DIR/$pkg" ]] || die "no such package: $pkg"
    done

    [[ -n "${DRY_RUN:-}" ]] && flags+=(--simulate --verbose)

    log "stowing: ${packages[*]}"
    # ${arr[@]+...} keeps empty arrays from tripping `set -u` on bash 3.2 (macOS).
    stow --dir "$DOTFILES_DIR" --target "$HOME" ${flags[@]+"${flags[@]}"} "${packages[@]}"
    log "done"
}

main "$@"
