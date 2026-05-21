# =====================================================================
# MODULES/NIXOS/SHELL — ZSH + STARSHIP + DIRENV + ZOXIDE
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

      ask() {
        local q="$*"
        local m="gemini:gemini-2.5-flash"
        local len=''${#q}
        if [[ $len -gt 200 ]]; then
          m="deepseek:deepseek-reasoner"
        elif [[ "$q" =~ (code|fix|error|bug|build|compile|nix|python|bash|go|vue|debug) ]]; then
          m="deepseek:deepseek-chat"
        elif [[ "$q" =~ (system|config|may|laptop|generat|switch|boot|nixos) ]]; then
          aichat --agent general "$q"
          return $?
        fi
        aichat -m "$m" -e "$q" || aichat -m "gemini:gemini-2.5-flash" -e "$q"
      }
    '';

    shellAliases = {
      nixos = "cd ~/.config/nixos && ./.devenv/profile/bin/dashboard";
      # ── nh (nix-helper) shortcuts ─────────────────────────────
      nhs = "nh search";       # Tìm package
      nhl = "nh list";         # Liệt kê generations
      nhc = "nh clean all";    # Dọn tất cả
      nho = "nh os switch";    # Switch hệ thống
      nhh = "nh home switch";  # Switch Home Manager
      nht = "nh os test";      # Test build
      nhb = "nh os boot";      # Build boot
      nixos-setup = "bash ~/.config/nixos/scripts/nixos-setup.sh";  # Post-install wizard
      # ── ISO Build ─────────────────────────────────────────────
      iso-standard = "cd ~/.config/nixos && iso-standard";      # Build vnixos-standard.iso
      iso-minidev = "cd ~/.config/nixos && iso-minidev";        # Build vnixos-minidev.iso
      # ── Legacy scripts ────────────────────────────────────────
      build = "noglob f() { cd ~/.config/nixos && LABEL_SLUG=$(echo \"$1\" | tr '[:upper:]' '[:lower:]' | tr ' ' '-') && TS=$(date +%y%m%d_%H%M%S) && git add . && git commit -m \"$1\" && sudo nixos-rebuild switch --flake .#$(hostname) && git push; }; f";
      sysupdate = "f() { cd ~/.config/nixos; if ! git diff --quiet || ! git diff --cached --quiet; then git add . && git commit -m \"sysupdate: $(date +%Y-%m-%d-%H%M)\"; fi; TS=$(date +%y%m%d_%H%M%S); sudo nixos-rebuild switch --flake .#$(hostname) && git push; }; f";
      appupdate = "f() { cd ~/.config/nixos; if ! git diff --quiet || ! git diff --cached --quiet; then git add . && git commit -m \"home: $(date +%Y-%m-%d-%H%M)\"; fi; home-manager switch --flake .#$(hostname); }; f";
      clean = "sudo nix-collect-garbage -d && sudo nix-env --list-generations -p /nix/var/nix/profiles/system";
      gen = "sudo nix-env --list-generations -p /nix/var/nix/profiles/system";
      ".." = "cd ..";
      "..." = "cd ../..";
      z = "zoxide";
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit -m";
      gp = "git push";
      gl = "git log --oneline --graph --all";
      gd = "git diff";
      dco = "podman-compose";
      d = "podman";
      v = "vim";
      a = "aichat -a";
      initrule = "cp ~/.rules ./.rules && echo '✅ .rules copied to current directory'";
      initproject = "bash ~/.config/nixos/scripts/initproject.sh";
    };
  };

  programs.zoxide.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv = {
    enable = false;
  };
  programs.starship.enable = true;
}
