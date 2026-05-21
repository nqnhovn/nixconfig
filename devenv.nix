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
    switch.exec = "sudo nixos-rebuild switch --flake .#$(hostname)";
    boot.exec = "sudo nixos-rebuild boot --flake .#$(hostname)";
    gc.exec = "sudo nix-collect-garbage -d";
    update.exec = "nix flake update";
    fmt.exec = "nixpkgs-fmt flake/**/*.nix secrets/*.nix *.nix";
    list.exec = "sudo nix-env --list-generations -p /nix/var/nix/profiles/system";
    clean.exec = "sudo nix-collect-garbage -d && sudo nix-env --list-generations -p /nix/var/nix/profiles/system";

    # ── Home manager ──────────────────────────────────────────────────
    home.exec = ''
      cd ~/.config/nixos
      if ! git diff --quiet || ! git diff --cached --quiet; then
        git add . && git commit -m "home: $(date +%Y-%m-%d-%H%M)"
      fi
      home-manager switch --flake .#$(hostname)
      echo "✅ Home Manager rebuild complete!"
    '';

    # ── Interactive Dashboard ─────────────────────────────────────────
    dashboard.exec = ''
      #!/usr/bin/env bash
      cd ~/.config/nixos
      set -euo pipefail

      RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
      BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'
      WHITE='\033[1;37m'; MAGENTA='\033[1;35m'; NC='\033[0m'; DIM='\033[2m'

      cleanup() { echo -e "\n''${GREEN}👋 See you!''${NC}"; exit 0; }
      trap cleanup SIGINT SIGTERM

      while true; do
        clear
        echo -e "''${BOLD}''${CYAN}"
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║  ❄️  NIXOS GENERATION MANAGER — $(hostname)                 ║"
        echo "╠══════════════════════════════════════════════════════════════╣"
        echo -e "''${NC}"

        CURRENT_GEN=$(sudo nix-env --list-generations -p /nix/var/nix/profiles/system 2>/dev/null | grep "(current)" | awk '{print $1}')
        GEN_COUNT=$(sudo nix-env --list-generations -p /nix/var/nix/profiles/system 2>/dev/null | wc -l)
        NIXOS_VER=$(nixos-version 2>/dev/null || echo "NixOS")
        UPTIME=$(awk '{d=int($1/86400); h=int($1%86400/3600); m=int($1%3600/60); if(d) printf "%dd ", d; printf "%dh %dm", h, m}' /proc/uptime)

        echo -e "  ''${DIM}System:''${NC} ''${BOLD}''${NIXOS_VER}''${NC}  │  ''${DIM}Uptime:''${NC} ''${UPTIME}  │  ''${DIM}Generations:''${NC} ''${BOLD}''${GEN_COUNT}''${NC}  │  ''${DIM}Current:''${NC} ''${GREEN}#''${CURRENT_GEN}''${NC}"
        echo -e "''${CYAN}╟──────────────────────────────────────────────────────────────╢''${NC}"

        echo -e "  ''${BOLD}''${WHITE}┌─────┬──────────────────────────────┬─────────────────────┐''${NC}"
        echo -e "  ''${BOLD}''${WHITE}│ ID  │ Label                        │ Created             │''${NC}"
        echo -e "  ''${BOLD}''${WHITE}├─────┼──────────────────────────────┼─────────────────────┤''${NC}"

        # Load labels from local file
        declare -A LABELS
        if [ -f ~/.config/nixos/.gen-labels ]; then
          while read -r id rest; do
            [ -n "$id" ] && LABELS[$id]="$rest"
          done < ~/.config/nixos/.gen-labels
        fi
        sudo nix-env --list-generations -p /nix/var/nix/profiles/system 2>/dev/null | tail -50 | while read -r line; do
          GEN_NUM=$(echo "$line" | awk '{print $1}')
          GEN_DATE=$(echo "$line" | awk '{print $2" "$3" "$4}' | sed 's/ /-/1' | sed 's/ /-/1')
          GEN_LABEL="''${LABELS[$GEN_NUM]:-(no label)}"
          LEN=''${#GEN_LABEL}
          if [ "$LEN" -gt 28 ]; then
            GEN_LABEL="$(echo "$GEN_LABEL" | cut -c1-25)..."
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

        PROFILE_COUNT=0
        for entry in $(sudo sh -c 'ls -t /boot/loader/entries/nixos-*-generation-*.conf' 2>/dev/null); do
          PF_NAME=$(echo "$entry" | sed 's|.*/nixos-||;s|-generation-[0-9]*.conf||')
          [ -z "$PF_NAME" ] && continue
          PF_DATE=$(sudo stat -c "%y" "$entry" 2>/dev/null | sed 's/-//g; s/ .*//; s/^..//')_$(sudo stat -c "%y" "$entry" 2>/dev/null | cut -d' ' -f2 | cut -d. -f1 | sed 's/://g')
          PROFILE_COUNT=$((PROFILE_COUNT+1))
          echo -e "    ''${YELLOW}p$PROFILE_COUNT⭐''${NC} ''${BOLD}$PF_NAME''${NC} ''${DIM}$PF_DATE''${NC}"
        done
        if [ $PROFILE_COUNT -eq 0 ]; then
          echo -e "    ''${DIM}(none — pin with B→y after build)''${NC}"
        fi

        echo ""
        echo -e "''${CYAN}╔══════════════════════════════════════════════════════════════╗''${NC}"
        echo -e "''${CYAN}║''${NC}  ''${BOLD}''${GREEN}B''${NC}/b: ''${WHITE}Build''${NC}   │  ''${BOLD}''${RED}D''${NC}/d: ''${WHITE}Delete''${NC}   │  ''${BOLD}''${BLUE}S''${NC}/s: ''${WHITE}Switch''${NC}   │  ''${BOLD}''${YELLOW}H''${NC}/h: ''${WHITE}Home''${NC}  ''${CYAN}║''${NC}"
        echo -e "''${CYAN}║''${NC}  ''${BOLD}''${MAGENTA}C''${NC}/c: ''${WHITE}Clean''${NC}   │  ''${BOLD}''${YELLOW}R''${NC}/r: ''${WHITE}Reset''${NC}   │  ''${BOLD}''${BLUE}P''${NC}/p: ''${WHITE}Pin''${NC}     │  ''${BOLD}''${RED}E''${NC}/e: ''${WHITE}Exit''${NC}   ''${CYAN}║''${NC}"
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
            TS=$(date +%y%m%d_%H%M%S)
            echo -e "  ''${YELLOW}🔨 Building: ''${BOLD}$LABEL_SLUG-$TS''${NC}"
            sudo nixos-rebuild switch --flake .#$(hostname)
            NEW_GEN=$(sudo nix-env --list-generations -p /nix/var/nix/profiles/system 2>/dev/null | grep current | awk '{print $1}')
            echo "$NEW_GEN $LABEL_SLUG-$TS" >> ~/.config/nixos/.gen-labels
            echo -e "  ''${GREEN}✅ Build complete! Gen #$NEW_GEN''${NC}"

            echo ""
            read -r -p "  📌 Pin as boot profile? (y/N): " PIN_CHOICE
            if [ "''${PIN_CHOICE,,}" = "y" ] || [ "''${PIN_CHOICE,,}" = "yes" ]; then
              read -r -p "  📛 Profile name (default: $LABEL_SLUG): " PROFILE_NAME
              PROFILE_NAME=''${PROFILE_NAME:-$LABEL_SLUG}
              sudo nixos-rebuild switch --flake .#$(hostname) --profile-name "$PROFILE_NAME"
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
            read -r -p "  🗑️  Gen ID or pN (profile): " GENS
            if [ -n "$GENS" ]; then
              for g in $GENS; do
                case "$g" in
                  p*)
                    PN=''${g#p}
                    PF_ENTRY=$(sudo sh -c 'ls -t /boot/loader/entries/nixos-*-generation-*.conf' 2>/dev/null | sed -n ''${PN}p)
                    if [ -n "$PF_ENTRY" ]; then
                      PF_NAME=$(echo "$PF_ENTRY" | sed 's|.*/nixos-||;s|-generation-[0-9]*.conf||')
                      echo -e "  ''${YELLOW}Deleting profile $PF_NAME...''${NC}"
                      sudo rm "$PF_ENTRY"
                      # Also remove symlink to prevent recreation on next build
                      sudo rm -f "/nix/var/nix/profiles/system-profiles/$PF_NAME" 2>/dev/null || true
                      echo -e "  ''${GREEN}✅ Profile $PF_NAME deleted (entry + symlink)''${NC}"
                    else
                      echo -e "  ''${RED}Profile p$PN not found''${NC}"
                    fi
                    ;;
                  *)
                    echo -e "  ''${YELLOW}Deleting gen $g...''${NC}"
                    sudo nix-env --delete-generations "$g" --profile /nix/var/nix/profiles/system
                    sed -i "/^$g /d" ~/.config/nixos/.gen-labels 2>/dev/null
                    ;;
                esac
              done
              echo -e "  ''${YELLOW}🧹 Running GC...''${NC}"
              sudo nix-collect-garbage -d
              echo -e "  ''${GREEN}✅ Done!''${NC}"
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
              REV=$(cat /run/current-system/configuration-revision 2>/dev/null || true)
              if [ -n "$REV" ] && [ "$REV" != "dirty" ] && [ "$REV" != "unknown" ]; then
                echo -e "  ''${YELLOW}📋 Config revision: ''${BOLD}$REV''${NC}"
                cd ~/.config/nixos
                if git cat-file -t "$REV" >/dev/null 2>&1; then
                  git checkout "$REV" 2>/dev/null && echo -e "  ''${GREEN}✅ Git checkout $REV''${NC}" || echo -e "  ''${DIM}⚠️  Dirty repo, staying on current''${NC}"
                else
                  echo -e "  ''${DIM}⚠️  Revision $REV not in git history''${NC}"
                fi
              else
                echo -e "  ''${DIM}⚠️  No revision stored in this gen (pre-dashboard build)''${NC}"
              fi
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

          c|clean)
            echo ""
            read -r -p "  🧹 Keep how many recent gens? (default: 3): " KEEP
            KEEP=''${KEEP:-3}
            echo -e "  ''${YELLOW}Deleting all except $KEEP most recent...''${NC}"
            sudo nix-env --delete-generations +$KEEP --profile /nix/var/nix/profiles/system
            sudo nix-collect-garbage -d
            echo -e "  ''${GREEN}✅ Kept $KEEP recent gens, GC done!''${NC}"
            echo ""
            read -r -p "  Press Enter to continue..." _
            ;;

          r|reset)
            echo ""
            echo -e "  ''${YELLOW}🔄 Creating fresh profile starting from gen 1...''${NC}"
            echo -e "  ''${DIM}   Current profile preserved as backup''${NC}"
            cd ~/.config/nixos
            if ! git diff --quiet || ! git diff --cached --quiet; then
              git add . && git commit -m "reset: save before profile reset"
            fi
            sudo nixos-rebuild switch --flake .#lg --profile-name system
            sudo nix-collect-garbage -d
            echo -e "  ''${GREEN}✅ New profile created! Gen counter reset to 1''${NC}"
            echo -e "  ''${DIM}💡 Old boot entries remain until overwritten by new builds''${NC}"
            echo ""
            read -r -p "  Press Enter to continue..." _
            ;;

          p|pin)
            echo ""
            read -r -p "  📌 Pin STT (1st column) as profile: " PS
            if [ -n "$PS" ]; then
              GEN_ID=$(sudo nix-env --list-generations -p /nix/var/nix/profiles/system 2>/dev/null | awk "NR==$PS" | awk '{print $1}')
              # Fallback: if STT not found, try as gen ID directly
              if [ -z "$GEN_ID" ]; then
                if sudo nix-env --list-generations -p /nix/var/nix/profiles/system 2>/dev/null | grep -q "^\s*$PS\s"; then
                  GEN_ID="$PS"
                fi
              fi
              if [ -n "$GEN_ID" ]; then
                CURRENT=$(sudo nix-env --list-generations -p /nix/var/nix/profiles/system 2>/dev/null | grep current | awk '{print $1}')
                LBL=$(grep "^$GEN_ID " ~/.config/nixos/.gen-labels 2>/dev/null | cut -d' ' -f2-)
                [ -z "$LBL" ] && LBL="gen$GEN_ID"
                TS=$(date +%y%m%d_%H%M%S)
                read -r -p "  📛 Name (default: $LBL): " PF_NAME
                PF_NAME=''${PF_NAME:-$LBL}
                echo -e "  ''${YELLOW}Switching to gen $GEN_ID to pin...''${NC}"
                sudo nix-env --switch-generation "$GEN_ID" --profile /nix/var/nix/profiles/system
                sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
                sudo nixos-rebuild switch --flake .#lg --profile-name "$PF_NAME"
                echo -e "  ''${YELLOW}Switching back to gen $CURRENT...''${NC}"
                sudo nix-env --switch-generation "$CURRENT" --profile /nix/var/nix/profiles/system
                sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
                echo -e "  ''${GREEN}✅ Pinned gen $GEN_ID as: ''${BOLD}$PF_NAME''${NC}"
              else
                echo -e "  ''${RED}STT $PS not found''${NC}"
              fi
            fi
            echo -e "  ''${DIM}Enter to continue...''${NC}"; read -r _
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
