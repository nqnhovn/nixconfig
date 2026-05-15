# =====================================================================
# MODULES/SYSTEM/SHELL.NIX — ZSH + STÁRSHIP + DIRENV + ZOXIDE
# =====================================================================

{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    histSize = 10000;
    setOptions = [
      "HIST_IGNORE_DUPS"
      "SHARE_HISTORY"
      "HIST_FIND_NO_DUPS"
      "HIST_IGNORE_SPACE"
    ];

    interactiveShellInit = ''
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh

      sudo-command-line() {
        [[ -z $BUFFER ]] && zle up-history
        [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
        zle end-of-line
      }
      zle -N sudo-command-line
      bindkey "^[^[" sudo-command-line

      extract() {
        if [ -f $1 ]; then
          case $1 in
            *.tar.bz2) tar xjf $1 ;;
            *.tar.gz)  tar xzf $1 ;;
            *.bz2)     bunzip2 $1 ;;
            *.rar)     unrar x $1 ;;
            *.gz)      gunzip $1 ;;
            *.tar)     tar xf $1 ;;
            *.tbz2)    tar xjf $1 ;;
            *.tgz)     tar xzf $1 ;;
            *.zip)     unzip $1 ;;
            *.Z)       uncompress $1 ;;
            *.7z)      7z x $1 ;;
            *)         echo "'$1' cannot be extracted via extract()" ;;
          esac
        else
          echo "'$1' is not a valid file"
        fi
      }
    '';

    shellAliases = {
      # ── System / NixOS Aliases (Global) ───────────────────────────────────
      # Dashboard: interactive TUI for generation management (Build, Delete, Switch, Home, Exit)
      nixos = "cd ~/.config/nixos && dashboard";
      # Quick system rebuild with label (non-interactive)
      build = "noglob f() { cd ~/.config/nixos && LABEL_SLUG=$(echo \"$1\" | tr '[:upper:]' '[:lower:]' | tr ' ' '-') && GIT_HASH=$(git rev-parse --short HEAD) && git add . && git commit -m \"$1\" && sudo NIXOS_LABEL=\"$LABEL_SLUG-$GIT_HASH\" nixos-rebuild switch --flake .#lg && git push; }; f";
      # Quick system update (auto-label with date)
      sysupdate = "f() { cd ~/.config/nixos; if ! git diff --quiet || ! git diff --cached --quiet; then git add . && git commit -m \"sysupdate: $(date +%Y-%m-%d-%H%M)\"; fi; GIT_HASH=$(git rev-parse --short HEAD); sudo NIXOS_LABEL=\"sysupdate-$(date +%Y%m%d-%H%M)-$GIT_HASH\" nixos-rebuild switch --flake .#lg && git push; }; f";
      # Quick home-manager update
      appupdate = "f() { cd ~/.config/nixos; if ! git diff --quiet || ! git diff --cached --quiet; then git add . && git commit -m \"home: $(date +%Y-%m-%d-%H%M)\"; fi; home-manager switch --flake .#lg; }; f";
      # Quick GC
      clean = "sudo nix-collect-garbage -d && sudo nix-env --list-generations -p /nix/var/nix/profiles/system";
      # List generations
      gen = "sudo nix-env --list-generations -p /nix/var/nix/profiles/system";

      # ── Navigation Aliases ────────────────────────────────────────────────
      ".." = "cd ..";
      "..." = "cd ../..";
      z = "zoxide"; # zoxide (smart cd)

      # ── Listing Aliases ───────────────────────────────────────────────────
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";

      # ── Git Aliases ───────────────────────────────────────────────────────
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit -m";
      gp = "git push";
      gl = "git log --oneline --graph --all";
      gd = "git diff";

      # ── Podman/Docker Aliases ─────────────────────────────────────────────
      dco = "podman-compose";
      d = "podman";

      # ── Other Utility Aliases ─────────────────────────────────────────────
      v = "vim"; # Alias for vim
    };
  };

  programs.zoxide.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv = {
    enable = false; # Vô hiệu hóa nix-direnv để sử dụng devenv shell trực tiếp
  };
  programs.starship.enable = true;
}
