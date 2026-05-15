{ pkgs, ... }:

{
  packages = with pkgs; [
    nixpkgs-fmt
    nil
    shellcheck
    bat
    eza
    fd
    jq
    nixos-rebuild
    fzf
    gum
    git
  ];

  scripts = {
    # ── Core management scripts ──────────────────────────────────────
    switch.exec = "sudo nixos-rebuild switch --flake .#lg";
    boot.exec = "sudo nixos-rebuild boot --flake .#lg";
    gc.exec = "sudo nix-collect-garbage -d";
    update.exec = "nix flake update";
    fmt.exec = "nixpkgs-fmt *.nix modules/**/*.nix home/**/*.nix hosts/**/*.nix";
    list.exec = "sudo nix-env --list-generations -p /nix/var/nix/profiles/system";
    clean.exec = "sudo nix-collect-garbage -d && sudo nix-env --list-generations -p /nix/var/nix/profiles/system";

    # ── Home manager ──────────────────────────────────────────────────
    home.exec = ''
      cd ~/.config/nixos
      if ! git diff --quiet || ! git diff --cached --quiet; then
        git add . && git commit -m "home: $(date +%Y-%m-%d-%H%M)"
      fi
      home-manager switch --flake .#lg
      echo "✅ Home Manager rebuild complete!"
    '';

    # ── Interactive Dashboard ─────────────────────────────────────────
    dashboard.exec = ''
      #!/usr/bin/env bash
      cd ~/.config/nixos
      set -euo pipefail

      RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
      BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'
      WHITE='\033[1;37m'; NC='\033[0m'; DIM='\033[2m'

      cleanup() { echo -e "\n''${GREEN}👋 See you!''${NC}"; exit 0; }
      trap cleanup SIGINT SIGTERM

      while true; do
        clear
        echo -e "''${BOLD}''${CYAN}"
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║  ❄️  NIXOS GENERATION MANAGER — LG Gram 17                  ║"
        echo "╠══════════════════════════════════════════════════════════════╣"
        echo -e "''${NC}"

        CURRENT_GEN=$(sudo nix-env --list-generations -p /nix/var/nix/profiles/system 2>/dev/null | grep "(current)" | awk '{print $1}')
        GEN_COUNT=$(sudo nix-env --list-generations -p /nix/var/nix/profiles/system 2>/dev/null | wc -l)
        NIXOS_VER=$(nixos-version 2>/dev/null || echo "NixOS")
        UPTIME=$(uptime -p | sed 's/up //')

        echo -e "  ''${DIM}System:''${NC} ''${BOLD}''${NIXOS_VER}''${NC}  │  ''${DIM}Uptime:''${NC} ''${UPTIME}  │  ''${DIM}Generations:''${NC} ''${BOLD}''${GEN_COUNT}''${NC}  │  ''${DIM}Current:''${NC} ''${GREEN}#''${CURRENT_GEN}''${NC}"
        echo -e "''${CYAN}╟──────────────────────────────────────────────────────────────╢''${NC}"

        echo -e "  ''${BOLD}''${WHITE}┌─────┬──────────────────────────────┬─────────────────────┐''${NC}"
        echo -e "  ''${BOLD}''${WHITE}│ ID  │ Label                        │ Created             │''${NC}"
        echo -e "  ''${BOLD}''${WHITE}├─────┼──────────────────────────────┼─────────────────────┤''${NC}"

        sudo nix-env --list-generations -p /nix/var/nix/profiles/system 2>/dev/null | tail -50 | while read -r line; do
          GEN_NUM=$(echo "$line" | awk '{print $1}')
          GEN_DATE=$(echo "$line" | awk '{print $2" "$3" "$4}' | sed 's/ /-/1' | sed 's/ /-/1')
          GEN_LABEL=$(echo "$line" | awk '{for(i=5;i<=NF;i++) printf "%s ", $i; print ""}' | sed 's/ (current)//' | xargs)
          LEN=''${#GEN_LABEL}
          if [ "$LEN" -gt 28 ]; then
            GEN_LABEL="$(echo "$GEN_LABEL" | cut -c1-25)..."
          fi
          if [ -z "$GEN_LABEL" ]; then
            GEN_LABEL="(no label)"
          fi
          PADDING=$((28 - ''${#GEN_LABEL}))
          PAD=$(printf "%''${PADDING}s" "")
          if echo "$line" | grep -q "(current)"; then
            printf "  ''${GREEN}│ ''${BOLD}%3s''${NC} │ ''${GREEN}%s%s''${NC} │ ''${DIM}%s''${NC} │\n" "$GEN_NUM" "$GEN_LABEL" "$PAD" "$GEN_DATE"
          else
            printf "  ''${DIM}│ %3s''${NC} │ %s%s │ ''${DIM}%s''${NC} │\n" "$GEN_NUM" "$GEN_LABEL" "$PAD" "$GEN_DATE"
          fi
        done

        echo -e "  ''${BOLD}''${WHITE}└─────┴──────────────────────────────┴─────────────────────┘''${NC}"

        echo -e "''${CYAN}╟──────────────────────────────────────────────────────────────╢''${NC}"
        echo -e "  ''${BOLD}📌 Profiles:''${NC}"

        PROFILE_DIR="/nix/var/nix/profiles/per-user/root"
        PROFILE_COUNT=0
        if [ -d "$PROFILE_DIR" ]; then
          for pf in $(ls -1 "$PROFILE_DIR" 2>/dev/null); do
            case "$pf" in
              system|channels|home-manager) continue ;;
              *)
                PROFILE_COUNT=$((PROFILE_COUNT+1))
                PF_GEN=$(readlink "$PROFILE_DIR/$pf" 2>/dev/null | grep -oP 'system-\K\d+' | head -1 || echo "?")
                echo -e "    ''${YELLOW}⭐''${NC} ''${BOLD}$pf''${NC} ''${DIM}→ gen $PF_GEN''${NC}"
                ;;
            esac
          done
        fi
        if [ $PROFILE_COUNT -eq 0 ]; then
          echo -e "    ''${DIM}(no pinned profiles)''${NC}"
        fi

        echo ""
        echo -e "''${CYAN}╔══════════════════════════════════════════════════════════════╗''${NC}"
        echo -e "''${CYAN}║''${NC}  ''${BOLD}''${GREEN}B''${NC}/b: ''${WHITE}Build''${NC}   │  ''${BOLD}''${RED}D''${NC}/d: ''${WHITE}Delete''${NC}   │  ''${BOLD}''${BLUE}S''${NC}/s: ''${WHITE}Switch''${NC}   │  ''${BOLD}''${YELLOW}H''${NC}/h: ''${WHITE}Home''${NC}   │  ''${BOLD}''${RED}E''${NC}/e: ''${WHITE}Exit''${NC}  ''${CYAN}║''${NC}"
        echo -e "''${CYAN}╚══════════════════════════════════════════════════════════════╝''${NC}"
        echo ""
        read -r -p "  ► " CHOICE

        case "''${CHOICE,,}" in
          b|build)
            echo ""
            read -r -p "  🏷️  Label: " LABEL
            if [ -z "$LABEL" ]; then
              echo -e "  ''${RED}❌ Label cannot be empty!''${NC}"
              sleep 1
              continue
            fi
            LABEL_SLUG=$(echo "$LABEL" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
            echo ""
            echo -e "  ''${YELLOW}📦 Git add & commit...''${NC}"
            git add .
            git commit -m "$LABEL" || echo -e "  ''${DIM}(nothing to commit)''${NC}"
            GIT_HASH=$(git rev-parse --short HEAD)
            echo -e "  ''${YELLOW}🔨 Building: ''${BOLD}$LABEL_SLUG-$GIT_HASH''${NC}"
            sudo NIXOS_LABEL="$LABEL_SLUG-$GIT_HASH" nixos-rebuild switch --flake .#lg
            echo -e "  ''${GREEN}✅ Build complete!''${NC}"

            echo ""
            read -r -p "  📌 Pin as boot profile? (y/N): " PIN_CHOICE
            if [ "''${PIN_CHOICE,,}" = "y" ] || [ "''${PIN_CHOICE,,}" = "yes" ]; then
              read -r -p "  📛 Profile name (default: $LABEL_SLUG): " PROFILE_NAME
              PROFILE_NAME=''${PROFILE_NAME:-$LABEL_SLUG}
              sudo nixos-rebuild switch --flake .#lg --profile-name "$PROFILE_NAME"
              echo -e "  ''${GREEN}✅ Pinned as: ''${BOLD}$PROFILE_NAME''${NC}"
            fi

            echo ""
            read -r -p "  🔄 Git push? (Y/n): " PUSH_CHOICE
            if [ "''${PUSH_CHOICE,,}" != "n" ]; then
              git push
              echo -e "  ''${GREEN}✅ Pushed!''${NC}"
            fi
            echo ""
            read -r -p "  Press Enter to continue..." _
            ;;

          d|delete)
            echo ""
            read -r -p "  🗑️  Gen ID(s) to delete (space-separated): " GENS
            if [ -n "$GENS" ]; then
              for g in $GENS; do
                echo -e "  ''${YELLOW}Deleting generation $g...''${NC}"
                sudo nix-env --delete-generations "$g" --profile /nix/var/nix/profiles/system
              done
              echo -e "  ''${YELLOW}🧹 Running GC...''${NC}"
              sudo nix-collect-garbage -d
              echo -e "  ''${GREEN}✅ Cleaned up!''${NC}"
            fi
            echo ""
            read -r -p "  Press Enter to continue..." _
            ;;

          s|switch)
            echo ""
            read -r -p "  🔄 Switch to generation ID: " GEN_ID
            if [ -n "$GEN_ID" ]; then
              echo -e "  ''${YELLOW}Switching to gen $GEN_ID...''${NC}"
              sudo nix-env --switch-generation "$GEN_ID" --profile /nix/var/nix/profiles/system
              sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
              echo -e "  ''${GREEN}✅ Switched to gen $GEN_ID!''${NC}"
            fi
            echo ""
            read -r -p "  Press Enter to continue..." _
            ;;

          h|home)
            echo ""
            echo -e "  ''${YELLOW}🏠 Rebuilding Home Manager...''${NC}"
            cd ~/.config/nixos
            if ! git diff --quiet || ! git diff --cached --quiet; then
              git add . && git commit -m "home: $(date +%Y-%m-%d-%H%M)"
            fi
            home-manager switch --flake .#lg
            echo -e "  ''${GREEN}✅ Home Manager rebuild complete!''${NC}"
            echo ""
            read -r -p "  Press Enter to continue..." _
            ;;

          e|exit)
            echo ""
            echo -e "  ''${GREEN}👋 Goodbye!''${NC}"
            exit 0
            ;;

          "")
            continue
            ;;

          *)
            echo -e "  ''${RED}❌ Invalid choice! B/D/S/H/E''${NC}"
            sleep 1
            ;;
        esac
      done
    '';

    # ── Devenv shortcuts ──────────────────────────────────────────────
    dev.exec = "devenv";
    devup.exec = "devenv up";
    devdown.exec = "devenv down";
    devupdate.exec = "devenv update";
    devgc.exec = "devenv gc";
    devshell.exec = "devenv shell";
  };
}
