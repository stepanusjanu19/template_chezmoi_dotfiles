/*
 * chezmoi_manager.c
 * Integration for EXACT existing structure (no dot_config/chezmoi)
 * Place in: ~/.local/share/chezmoi/
 * Compile: gcc -o chezmoi_manager chezmoi_manager.c -std=c11
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <pwd.h>

#define COLOR_RESET   "\033[0m"
#define COLOR_GREEN   "\033[32m"
#define COLOR_YELLOW  "\033[33m"
#define COLOR_BLUE    "\033[34m"
#define COLOR_CYAN    "\033[36m"

typedef struct {
    char home[512];
    char chezmoi[512];          // ~/.local/share/chezmoi
    char dot_config[512];       // ~/.local/share/chezmoi/dot_config
    char fish[512];             // ~/.local/share/chezmoi/dot_config/fish
    char nvim[512];             // ~/.local/share/chezmoi/dot_config/nvim (if exists)
    //char nvim_root[512];        // ~/.local/share/chezmoi/nvim
    char git[512];              // ~/.local/share/chezmoi/.git
} Paths;

Paths paths;

void init_paths(void) {
    struct passwd *pw = getpwuid(getuid());
    strncpy(paths.home, pw->pw_dir, sizeof(paths.home) - 1);
    
    snprintf(paths.chezmoi, sizeof(paths.chezmoi), 
             "%s/.local/share/chezmoi", paths.home);
    snprintf(paths.dot_config, sizeof(paths.dot_config),
             "%s/dot_config", paths.chezmoi);
    snprintf(paths.fish, sizeof(paths.fish),
             "%s/dot_config/fish", paths.chezmoi);
    snprintf(paths.nvim, sizeof(paths.nvim),
             "%s/dot_config/nvim", paths.chezmoi);
    //snprintf(paths.nvim_root, sizeof(paths.nvim_root),
             //"%s/nvim", paths.chezmoi);
    snprintf(paths.git, sizeof(paths.git),
             "%s/.git", paths.chezmoi);
}

void print_info(const char *msg) {
    printf("%s[INFO]%s %s\n", COLOR_GREEN, COLOR_RESET, msg);
}

void print_success(const char *msg) {
    printf("%s[✓]%s %s\n", COLOR_GREEN, COLOR_RESET, msg);
}

int exec_cmd(const char *cmd) {
    return system(cmd) == 0;
}

void mkdir_p(const char *path) {
    char cmd[1024];
    snprintf(cmd, sizeof(cmd), "mkdir -p %s", path);
    exec_cmd(cmd);
}

void create_ci_manager(void) {
    print_info("Creating CI/CD sync manager...");
    
    char ci_dir[512];
    snprintf(ci_dir, sizeof(ci_dir), "%s/ci", paths.chezmoi);
    mkdir_p(ci_dir);
    
    char sync_file[512];
    snprintf(sync_file, sizeof(sync_file), "%s/sync.sh", ci_dir);
    
    FILE *f = fopen(sync_file, "w");
    if (f) {
        fprintf(f, "#!/bin/bash\n");
        fprintf(f, "# CI/CD Sync Manager\n");
        fprintf(f, "# Generated for your exact structure\n\n");
        fprintf(f, "CHEZMOI=\"%s\"\n\n", paths.chezmoi);
        fprintf(f, "echo \"🔄 CI/CD Sync starting...\"\n");
        fprintf(f, "cd \"$CHEZMOI\" || exit 1\n\n");
        fprintf(f, "# Pull from remote\n");
        fprintf(f, "if [ -d .git ]; then\n");
        fprintf(f, "    echo \"📥 Pulling changes...\"\n");
        fprintf(f, "    git pull --rebase || exit 1\n");
        fprintf(f, "fi\n\n");
        fprintf(f, "# Apply chezmoi\n");
        fprintf(f, "echo \"✨ Applying configurations...\"\n");
        fprintf(f, "chezmoi apply\n\n");
        fprintf(f, "# Auto commit if enabled\n");
        fprintf(f, "if [ \"$AUTO_COMMIT\" = \"true\" ] && [ -d .git ]; then\n");
        fprintf(f, "    if [[ -n $(git status -s) ]]; then\n");
        fprintf(f, "        git add .\n");
        fprintf(f, "        git commit -m \"Sync from $(hostname) - $(date +%%Y-%%m-%%d)\"\n");
        fprintf(f, "        git push\n");
        fprintf(f, "    fi\n");
        fprintf(f, "fi\n\n");
        fprintf(f, "echo \"✅ Sync complete!\"\n");
        fclose(f);
        chmod(sync_file, 0755);
        print_success("CI sync created: ci/sync.sh");
    }
}

void create_aliases(void) {
    print_info("Creating path aliases...");
    
    char alias_dir[512];
    snprintf(alias_dir, sizeof(alias_dir), "%s/aliases", paths.chezmoi);
    mkdir_p(alias_dir);
    
    char bash_alias[512];
    snprintf(bash_alias, sizeof(bash_alias), "%s/bash_aliases.sh", alias_dir);
    
    FILE *f = fopen(bash_alias, "w");
    if (f) {
        fprintf(f, "#!/bin/bash\n");
        fprintf(f, "# Chezmoi Aliases - Your Structure\n\n");
        fprintf(f, "# Path Variables\n");
        fprintf(f, "export CZ=\"%s\"\n", paths.chezmoi);
        fprintf(f, "export CZ_CONFIG=\"%s\"\n", paths.dot_config);
        fprintf(f, "export CZ_FISH=\"%s\"\n", paths.fish);
        fprintf(f, "export CZ_NVIM=\"%s\"\n", paths.nvim);
        fprintf(f, "export CZ_GIT=\"%s\"\n", paths.git);
        fprintf(f, "\n# Navigation Aliases\n");
        fprintf(f, "alias cz='cd $CZ'\n");
        fprintf(f, "alias czc='cd $CZ_CONFIG'\n");
        fprintf(f, "alias czf='cd $CZ_FISH'\n");
        fprintf(f, "alias czn='cd $CZ_NVIM'\n");
        fprintf(f, "\n# Chezmoi Commands\n");
        fprintf(f, "alias cm='chezmoi'\n");
        fprintf(f, "alias cma='chezmoi apply'\n");
        fprintf(f, "alias cmd='chezmoi diff'\n");
        fprintf(f, "alias cme='chezmoi edit'\n");
        fprintf(f, "alias cms='bash $CZ/ci/sync.sh'\n");
        fprintf(f, "\n# Git Commands\n");
        fprintf(f, "alias czgit='cd $CZ && git'\n");
        fprintf(f, "alias czst='cd $CZ && git status'\n");
        fprintf(f, "alias czpull='cd $CZ && git pull'\n");
        fprintf(f, "alias czpush='cd $CZ && git push'\n");
        fclose(f);
        chmod(bash_alias, 0755);
        print_success("Bash aliases: aliases/bash_aliases.sh");
    }
    
    // Fish aliases
    char fish_alias[512];
    snprintf(fish_alias, sizeof(fish_alias), "%s/fish_aliases.fish", alias_dir);
    
    f = fopen(fish_alias, "w");
    if (f) {
        fprintf(f, "# Chezmoi Aliases for Fish\n\n");
        fprintf(f, "# Path Variables\n");
        fprintf(f, "set -gx CZ \"%s\"\n", paths.chezmoi);
        fprintf(f, "set -gx CZ_CONFIG \"%s\"\n", paths.dot_config);
        fprintf(f, "set -gx CZ_FISH \"%s\"\n", paths.fish);
        fprintf(f, "set -gx CZ_NVIM \"%s\"\n", paths.nvim);
        fprintf(f, "\n# Navigation\n");
        fprintf(f, "abbr -a cz 'cd $CZ'\n");
        fprintf(f, "abbr -a czc 'cd $CZ_CONFIG'\n");
        fprintf(f, "abbr -a czf 'cd $CZ_FISH'\n");
        fprintf(f, "abbr -a czn 'cd $CZ_NVIM'\n");
        fprintf(f, "\n# Chezmoi\n");
        fprintf(f, "abbr -a cm chezmoi\n");
        fprintf(f, "abbr -a cma 'chezmoi apply'\n");
        fprintf(f, "abbr -a cmd 'chezmoi diff'\n");
        fprintf(f, "abbr -a cms 'bash $CZ/ci/sync.sh'\n");
        fprintf(f, "\n# Git\n");
        fprintf(f, "abbr -a czgit 'cd $CZ; and git'\n");
        fprintf(f, "abbr -a czst 'cd $CZ; and git status'\n");
        fclose(f);
        print_success("Fish aliases: aliases/fish_aliases.fish");
    }
}

void create_optimization(void) {
    print_info("Creating optimization config...");
    
    char opt_dir[512];
    snprintf(opt_dir, sizeof(opt_dir), "%s/optimize", paths.chezmoi);
    mkdir_p(opt_dir);
    
    char opt_conf[512];
    snprintf(opt_conf, sizeof(opt_conf), "%s/fedora.conf", opt_dir);
    
    FILE *f = fopen(opt_conf, "w");
    if (f) {
        fprintf(f, "# Fedora Optimization Config\n");
        fprintf(f, "# Generated by C integration\n\n");
        fprintf(f, "[dnf]\n");
        fprintf(f, "max_parallel_downloads = 10\n");
        fprintf(f, "fastestmirror = true\n");
        fprintf(f, "deltarpm = true\n\n");
        fprintf(f, "[sysctl]\n");
        fprintf(f, "vm.swappiness = 10\n");
        fprintf(f, "vm.vfs_cache_pressure = 50\n");
        fprintf(f, "net.ipv4.tcp_fastopen = 3\n\n");
        fprintf(f, "[paths]\n");
        fprintf(f, "chezmoi = %s\n", paths.chezmoi);
        fprintf(f, "config = %s\n", paths.dot_config);
        fclose(f);
        print_success("Optimization config: optimize/fedora.conf");
    }
}

void create_lua_config(void) {
    print_info("Creating Lua integration...");
    
    char lua_dir[512];
    snprintf(lua_dir, sizeof(lua_dir), "%s/lua", paths.chezmoi);
    mkdir_p(lua_dir);
    
    char lua_file[512];
    snprintf(lua_file, sizeof(lua_file), "%s/config.lua", lua_dir);
    
    FILE *f = fopen(lua_file, "w");
    if (f) {
        fprintf(f, "#!/usr/bin/env lua\n");
        fprintf(f, "-- Chezmoi Lua Configuration\n");
        fprintf(f, "-- For your exact structure\n\n");
        fprintf(f, "local Config = {\n");
        fprintf(f, "    paths = {\n");
        fprintf(f, "        chezmoi = \"%s\",\n", paths.chezmoi);
        fprintf(f, "        dot_config = \"%s\",\n", paths.dot_config);
        fprintf(f, "        fish = \"%s\",\n", paths.fish);
        fprintf(f, "        nvim = \"%s\",\n", paths.nvim);
        fprintf(f, "    }\n");
        fprintf(f, "}\n\n");
        fprintf(f, "function Config:sync()\n");
        fprintf(f, "    print(\"🔄 Syncing via Lua...\")\n");
        fprintf(f, "    os.execute(\"bash \" .. self.paths.chezmoi .. \"/ci/sync.sh\")\n");
        fprintf(f, "end\n\n");
        fprintf(f, "function Config:optimize()\n");
        fprintf(f, "    print(\"⚡ Running optimization...\")\n");
        fprintf(f, "    local opt_file = self.paths.chezmoi .. \"/optimize/fedora.conf\"\n");
        fprintf(f, "    print(\"Config: \" .. opt_file)\n");
        fprintf(f, "end\n\n");
        fprintf(f, "return Config\n");
        fclose(f);
        chmod(lua_file, 0755);
        print_success("Lua config: lua/config.lua");
    }
}

void create_readme(void) {
    char readme[512];
    snprintf(readme, sizeof(readme), "%s/INTEGRATION.md", paths.chezmoi);
    
    FILE *f = fopen(readme, "w");
    if (f) {
        fprintf(f, "# Chezmoi C & Lua Integration\n\n");
        fprintf(f, "Added to your structure:\n\n");
        fprintf(f, "```\n");
        fprintf(f, "%s/\n", paths.chezmoi);
        fprintf(f, "├── ci/              ← CI/CD sync manager\n");
        fprintf(f, "│   └── sync.sh\n");
        fprintf(f, "├── aliases/         ← Path aliases\n");
        fprintf(f, "│   ├── bash_aliases.sh\n");
        fprintf(f, "│   └── fish_aliases.fish\n");
        fprintf(f, "├── optimize/        ← System optimization\n");
        fprintf(f, "│   └── fedora.conf\n");
        fprintf(f, "├── lua/             ← Lua config\n");
        fprintf(f, "│   └── config.lua\n");
        fprintf(f, "├── dot_config/      ← YOUR EXISTING\n");
        fprintf(f, "│   ├── fish/        ← (unchanged)\n");
        fprintf(f, "│   └── nvim/        ← (unchanged)\n");
        fprintf(f, "├── doc_zshrc        ← YOUR EXISTING (unchanged)\n");
        fprintf(f, "└── .git/            ← YOUR EXISTING (unchanged)\n");
        fprintf(f, "```\n\n");
        fprintf(f, "## Usage\n\n");
        fprintf(f, "### Load Aliases\n");
        fprintf(f, "```bash\n");
        fprintf(f, "source %s/aliases/bash_aliases.sh\n", paths.chezmoi);
        fprintf(f, "```\n\n");
        fprintf(f, "### CI/CD Sync\n");
        fprintf(f, "```bash\n");
        fprintf(f, "cms    # or: bash %s/ci/sync.sh\n", paths.chezmoi);
        fprintf(f, "```\n\n");
        fprintf(f, "### Lua Config\n");
        fprintf(f, "```bash\n");
        fprintf(f, "lua %s/lua/config.lua\n", paths.chezmoi);
        fprintf(f, "```\n\n");
        fprintf(f, "### Quick Navigation\n");
        fprintf(f, "```bash\n");
        fprintf(f, "cz     # cd to chezmoi root\n");
        fprintf(f, "czf    # cd to fish config\n");
        fprintf(f, "czn    # cd to nvim config\n");
        fprintf(f, "```\n");
        fclose(f);
        print_success("README: INTEGRATION.md");
    }
}

int main(void) {
    printf("%s", COLOR_CYAN);
    printf("╔════════════════════════════════════════╗\n");
    printf("║  Chezmoi C Integration                 ║\n");
    printf("║  For Your Exact Structure              ║\n");
    printf("╚════════════════════════════════════════╝\n");
    printf("%s\n", COLOR_RESET);
    
    init_paths();
    
    printf("\n%s=== Your Existing Structure ===%s\n", COLOR_BLUE, COLOR_RESET);
    printf("Root: %s\n", paths.chezmoi);
    printf("  ├── dot_config/fish/\n");
    printf("  ├── dot_config/nvim/ (if exists)\n");
    printf("  ├── doc_zshrc\n");
    printf("  └── .git/\n");
    
    printf("\n%s=== Adding New Features ===%s\n", COLOR_BLUE, COLOR_RESET);
    
    create_ci_manager();
    create_aliases();
    create_optimization();
    create_lua_config();
    create_readme();
    
    printf("\n%s✅ Integration Complete!%s\n\n", COLOR_GREEN, COLOR_RESET);
    
    printf("New structure:\n");
    printf("  ├── ci/              ← NEW\n");
    printf("  ├── aliases/         ← NEW\n");
    printf("  ├── optimize/        ← NEW\n");
    printf("  ├── lua/             ← NEW\n");
    printf("  ├── dot_config/      ← UNCHANGED\n");
    printf("  ├── doc_zshrc        ← UNCHANGED\n");
    printf("  └── .git/            ← UNCHANGED\n\n");
    
    printf("Next steps:\n");
    printf("  1. source %s/aliases/bash_aliases.sh\n", paths.chezmoi);
    printf("  2. cms (to run CI/CD sync)\n");
    printf("  3. lua %s/lua/config.lua\n\n", paths.chezmoi);
    
    return 0;
}
