# ============================================================================
# MAKEFILE — NIXOS CONFIGURATION TOOLKIT CHO LG GRAM 17
# ============================================================================

SHELL               := /usr/bin/env bash
NIX_SYSTEM_PROFILES := /nix/var/nix/profiles/system-profiles
NIX_MAIN_PROFILES   := /nix/var/nix/profiles
DOTFILES_DIR        := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

BLUE    := \033[1;34m
GREEN   := \033[1;32m
CYAN    := \033[1;36m
YELLOW  := \033[1;33m
RED     := \033[1;31m
RESET   := \033[0m

.PHONY: help list switch build boot home gc clean storage update init

help: list

# ============================================================================
# INTERACTIVE DASHBOARD
# ============================================================================
list:
	@while true; do \
		clear; \
		echo -e "$(BLUE)╔══════════════════════════════════════════════════════╗$(RESET)"; \
		echo -e "$(BLUE)║     ❄️  NIXOS TOOLKIT — LG Gram 17                   ║$(RESET)"; \
		echo -e "$(BLUE)╚══════════════════════════════════════════════════════╝$(RESET)"; \
		echo ""; \
		echo -e "$(BLUE)📜 GENERATIONS$(RESET)"; \
		printf "$(YELLOW)%-8s %-20s %-30s$(RESET)\n" "ID" "Thời gian" "Label"; \
		echo "──────────────────────────────────────────────────────────────"; \
		mapfile -t gen_lines < <(sudo nix-env --list-generations -p $(NIX_MAIN_PROFILES)/system 2>/dev/null); \
		declare -A gen_map; \
		gen_count=$${#gen_lines[@]}; \
		for idx in "$${!gen_lines[@]}"; do \
			seq_id=$$((idx + 1)); \
			read -r real_id date time status <<< "$${gen_lines[$$idx]}"; \
			gen_map[$$seq_id]=$$real_id; \
			conf_file="/boot/loader/entries/nixos-generation-$$real_id-default.conf"; \
			label="-"; \
			if [ -f "$$conf_file" ]; then \
				label=$$(sudo grep -oP 'title.*\(\K[^)]+' "$$conf_file" 2>/dev/null | head -1 || echo "-"); \
				[ -z "$$label" ] && label=$$(sudo grep '^version' "$$conf_file" 2>/dev/null | sed 's/version Generation [0-9]* //' | head -1 || echo "-"); \
			fi; \
			printf "%-8s %-20s %-30s\n" "$$seq_id" "$$date $$time" "$$label"; \
		done; \
		echo ""; \
		echo -e "$(CYAN)╔══════════════════════════════════════════════════════╗$(RESET)"; \
		echo -e "$(CYAN)║  [S] Switch (rebuild)  [H] Home switch              ║$(RESET)"; \
		echo -e "$(CYAN)║  [D] Delete gen        [G] GC (dọn rác)             ║$(RESET)"; \
		echo -e "$(CYAN)║  [U] Update flake.lock [R] Reboot                   ║$(RESET)"; \
		echo -e "$(CYAN)║  [E] Exit              [ID] Switch to generation    ║$(RESET)"; \
		echo -e "$(CYAN)╚══════════════════════════════════════════════════════╝$(RESET)"; \
		printf "$(YELLOW)❯ Chọn: $(RESET)"; \
		read action; \
		if [[ "$$action" =~ ^[0-9]+$$ ]]; then \
			real_id=$${gen_map[$$action]:-$$action}; \
			if [ -L "$(NIX_MAIN_PROFILES)/system-$$real_id-link" ]; then \
				echo -e "$(GREEN)🚀 Chuyển sang Generation $$action ($$real_id)...$(RESET)"; \
				sudo nix-env -p $(NIX_MAIN_PROFILES)/system --switch-generation $$real_id; \
				sudo $(NIX_MAIN_PROFILES)/system/bin/switch-to-configuration switch; \
				echo -e "$(BLUE)✅ Hoàn thành!$(RESET)"; \
				read -p "Reboot? (y/N): " rb; \
				[[ "$$rb" =~ ^[Yy] ]] && sudo reboot; \
			else \
				echo -e "$(RED)❌ Không tìm thấy Gen $$action$(RESET)"; sleep 2; \
			fi; \
		else \
			case "$$action" in \
				[Ss]) $(MAKE) --no-print-directory _switch ;; \
				[Hh]) $(MAKE) --no-print-directory _home ;; \
				[Dd]) $(MAKE) --no-print-directory _delete ;; \
				[Uu]) $(MAKE) --no-print-directory update ;; \
				[Rr]) sudo reboot ;; \
				[Gg]) sudo nix-collect-garbage -d; echo -e "$(GREEN)✅ Đã dọn rác!$(RESET)"; sleep 1 ;; \
				[Ee]) break ;; \
				*) echo "❌ Không hợp lệ!"; sleep 1 ;; \
			esac; \
			read -p "Nhấn Enter để tiếp tục..." _; \
		fi; \
	done

# ============================================================================
# LỆNH NHANH
# ============================================================================
switch:
	@$(MAKE) --no-print-directory _switch

build:
	@$(MAKE) --no-print-directory _switch

home:
	@$(MAKE) --no-print-directory _home

gc:
	@sudo nix-collect-garbage -d
	@echo -e "$(GREEN)✅ Đã dọn rác!$(RESET)"

clean: gc

storage:
	@echo -e "$(BLUE)📊 Dung lượng /nix/store:$(RESET)"
	@sudo du -sh /nix/store 2>/dev/null || true
	@echo -e "$(BLUE)📊 Dung lượng project:$(RESET)"
	@du -sh $(DOTFILES_DIR) --exclude=.git 2>/dev/null || true

update:
	@echo -e "$(BLUE)🔄 Cập nhật flake.lock...$(RESET)"; \
	cd $(DOTFILES_DIR) && nix flake update 2>&1 | grep -v "Git tree.*dirty" | grep -E "Updated|warning" || true; \
	if ! cd $(DOTFILES_DIR) && git diff --quiet flake.lock 2>/dev/null; then \
		cd $(DOTFILES_DIR) && git add flake.lock && git commit -m "Update flake.lock" --quiet && git push --quiet 2>/dev/null; \
		echo -e "$(GREEN)✅ Đã cập nhật & push flake.lock$(RESET)"; \
	else \
		echo -e "$(GREEN)✅ Không có gói mới$(RESET)"; \
	fi

# ============================================================================
# HÀM NỘI BỘ
# ============================================================================

define _get_label
	printf "$(YELLOW)📝 Nhãn cho Menu Boot (Enter để bỏ qua): $(RESET)"; \
	read -r raw_label; \
	if [ -n "$$raw_label" ]; then \
		slug_label=$$(echo "$$raw_label" | sed 's/[àáạảãâầấậẩẫăằắặẳẵ]/a/g;s/[èéẹẻẽêềếệểễ]/e/g;s/[ìíịỉĩ]/i/g;s/[òóọỏõôồốộổỗơờớợởỡ]/o/g;s/[ùúụủũưừứựửữ]/u/g;s/[ỳýỵỷỹ]/y/g;s/đ/d/g' | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$$//g'); \
		full_label="$$slug_label-$$(date +%Y%m%d-%H%M)"; \
	else \
		full_label=""; \
	fi
endef

define _git_sync
	cd $(DOTFILES_DIR); \
	if git status --porcelain | grep -q .; then \
		echo -e "$(YELLOW)📋 File chưa commit:$(RESET)"; \
		git status --short; \
		default_msg=$${commit_msg:-"Cập nhật cấu hình"}; \
		printf "$(YELLOW)📝 Commit message [$$default_msg]: $(RESET)"; \
		read -r user_msg; \
		commit_msg=$${user_msg:-"$$default_msg"}; \
		git add .; \
		git commit -m "$$commit_msg" --quiet; \
		echo -e "$(GREEN)✅ Đã commit: $$commit_msg$(RESET)"; \
	fi; \
	git push --quiet 2>/dev/null && echo -e "$(GREEN)✅ Đã push GitHub$(RESET)" || true
endef

_switch:
	@echo -e "\n$(BLUE)🚀 REBUILD & SWITCH$(RESET)"; \
	$(_get_label); \
	commit_msg="$${slug_label:-Cập nhật cấu hình}"; \
	$(_git_sync); \
	if [ -n "$$full_label" ]; then \
		cd $(DOTFILES_DIR) && sudo NIXOS_LABEL="$$full_label" nixos-rebuild switch --flake .#lg; \
	else \
		cd $(DOTFILES_DIR) && sudo nixos-rebuild switch --flake .#lg; \
	fi && \
	echo -e "$(GREEN)✅ Build thành công!$(RESET)"; \
	printf "$(YELLOW)🔄 Reboot ngay? (y/N): $(RESET)"; \
	read -r rb; \
	[[ "$$rb" =~ ^[Yy] ]] && sudo reboot || true

_home:
	@echo -e "\n$(BLUE)🏠 HOME-MANAGER SWITCH$(RESET)"; \
	commit_msg="Home-Manager update"; \
	cd $(DOTFILES_DIR) && $(_git_sync); \
	cd $(DOTFILES_DIR) && home-manager switch --flake .#lg && \
	echo -e "$(GREEN)✅ Home-Manager đã cập nhật!$(RESET)"

_delete:
	@mapfile -t gen_lines < <(sudo nix-env --list-generations -p $(NIX_MAIN_PROFILES)/system 2>/dev/null); \
	declare -A gen_map; \
	for idx in "$${!gen_lines[@]}"; do \
		seq_id=$$((idx + 1)); \
		read -r real_id _ <<< "$${gen_lines[$$idx]}"; \
		gen_map[$$seq_id]=$$real_id; \
		printf "%-5s %s\n" "$$seq_id" "$${gen_lines[$$idx]}"; \
	done; \
	printf "$(RED)🗑️  ID cần xóa (vd: 1,4,5): $(RESET)"; \
	read del_items; \
	IFS="," read -ra items <<< "$$del_items"; \
	for item in "$${items[@]}"; do \
		item=$$(echo "$$item" | tr -d ' '); \
		real_id=$${gen_map[$$item]:-$$item}; \
		sudo nix-env -p $(NIX_MAIN_PROFILES)/system --delete-generations "$$real_id" 2>/dev/null; \
		echo -e "$(GREEN)✅ Đã xóa Gen $$item ($$real_id)$(RESET)"; \
	done; \
	sudo nix-collect-garbage -d; \
	echo -e "$(GREEN)✅ Đã dọn rác$(RESET)"
