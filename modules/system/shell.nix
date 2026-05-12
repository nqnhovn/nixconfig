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
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      ".." = "cd ..";
      "..." = "cd ../..";

      build = "noglob f() { cd ~/.config/nixos && git add . && git commit -m \"$1\" && GIT_HASH=$(git rev-parse --short HEAD) && sudo NIXOS_LABEL=\"$(echo \"$1\" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')-$GIT_HASH\" nixos-rebuild switch --flake .\\#lg && git push; }; f";
      sysupdate = "noglob f() { cd ~/.config/nixos; if ! git diff --quiet || ! git diff --cached --quiet; then git add . && git commit -m \"sysupdate: $(date +%Y-%m-%d\\ %H:%M)\"; fi; GIT_HASH=$(git rev-parse --short HEAD); sudo NIXOS_LABEL=\"sysupdate-$(date +%Y%m%d-%H%M)-$GIT_HASH\" nixos-rebuild switch --flake .\\#lg && git push; }; f";
      appupdate = "f() { cd ~/.config/nixos; if ! git diff --quiet || ! git diff --cached --quiet; then git add . && git commit -m \"appupdate: $(date +%Y-%m-%d\\ %H:%M)\"; fi; home-manager switch --flake .\\#lg; }; f";
      clean = "f() { echo '=== Cac the he hien tai ==='; sudo nix-env --list-generations --profile /nix/var/nix/profiles/system; echo ''; echo -n 'Nhap so gen muon xoa (Enter de bo qua): '; read -r gens; if [ -n \"$gens\" ]; then for g in $(echo $gens); do sudo nix-env --delete-generations $g --profile /nix/var/nix/profiles/system; done; echo 'Da xoa.'; fi; echo 'Dang don rac...'; sudo nix-collect-garbage -d; echo 'Hoan tat!'; }; f";

      dco = "podman-compose";
      d = "podman";
      v = "vim";

      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit -m";
      gp = "git push";
      gl = "git log --oneline --graph --all";
      gd = "git diff";

      dev = "devbox";
      nrs = "npm run serve";
      nrd = "npm run dev";
      nrw = "npm run watch";
      z = "zoxide";
    };
  };

  programs.zoxide.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.starship.enable = true;
}
