if status is-interactive

    #################################################
    # BASIC PATH
    #################################################
    set -gx PATH $HOME/.local/bin /usr/local/bin $PATH

    #################################################
    # PROMPT (ZSH nicoulaj → Starship recommended)
    #################################################
    if command -v starship >/dev/null
        starship init fish | source
    end

    ############################################################
    # ===== FAST SYNTAX HIGHLIGHTING (ZSH-LIKE) =====
    # Fish does this natively — just tune colors
    ############################################################
    set -g fish_color_command            green
    set -g fish_color_param              cyan
    set -g fish_color_option             brcyan
    set -g fish_color_argument           normal
    set -g fish_color_operator           brmagenta
    set -g fish_color_escape             bryellow
    set -g fish_color_error              red
    set -g fish_color_quote              yellow
    set -g fish_color_redirection        brblue
    set -g fish_color_autosuggestion     brblack
    set -g fish_color_valid_path         --underline
    set -g fish_color_cwd                blue
    set -g fish_color_cwd_root           red

    ############################################################
    # ===== ZSH-AUTOCOMPLETE STYLE BEHAVIOR =====
    ############################################################

    # Enable threaded completion (faster)
    set -g fish_complete_in_thread true

    # Menu-style completion (like zsh-autocomplete)
    set -g fish_pager_show_completion_prefix true
    set -g fish_pager_color_prefix          cyan
    set -g fish_pager_color_completion      normal
    set -g fish_pager_color_description     brblack
    set -g fish_pager_color_selected_completion --background=brblue
    set -g fish_pager_color_selected_prefix white --bold

    # Case-insensitive completion
    set -g fish_complete_case_insensitive true

   ############################################################
    # ===== KEYBINDINGS (ZSH-LIKE) =====
    ############################################################

    # TAB cycles completions
    bind \t complete

    # Shift+TAB reverse cycle
    bind \e\[Z complete-and-search

    # Right arrow accepts autosuggestion (zsh-like)
    bind \e\[C forward-char

    # Alt+Right → accept one word
    bind \e\[1\;3C forward-word

    #################################################
    # POKEMON COLORSCRIPT + FASTFETCH
    #################################################
    if command -v pokemon-colorscripts >/dev/null
        pokemon-colorscripts --no-title -s -r | fastfetch \
            -c $HOME/.config/fastfetch/config-pokemon.jsonc \
            --logo-type file-raw \
            --logo-height 10 \
            --logo-width 5 \
            --logo -
    end

    #################################################
    # FZF (CTRL+R history search)
    #################################################
    if command -v fzf >/dev/null
        fzf_configure_bindings
    end

    #################################################
    # ALIASES (lsd)
    #################################################
    alias ls='lsd'
    alias l='ls -l'
    alias la='ls -a'
    alias lla='ls -la'
    alias lt='ls --tree'
    alias shutnow='shutdown now'
    alias gmadb='/opt/genymotion/genymotion'

    #################################################
    # PENTEST ALIASES
    #################################################
    alias sqlmap="python3 $HOME/Documents/scripts/scanning/sqli/sqlmap/sqlmap.py"
    alias msfvenom="$HOME/Documents/scripts/scanning/meta/metasploit-framework/msfconsole"

    #################################################
    # NVM (Fish-native, DO NOT source nvm.sh)
    #################################################
    set -gx NVM_DIR $HOME/.nvm
    # install once:
    # fisher install jorgebucaran/nvm.fish

    #################################################
    # RUST (DO NOT source ~/.cargo/env)
    #################################################
    set -gx CARGO_HOME $HOME/.cargo
    set -gx PATH $CARGO_HOME/bin $PATH
    set -gx RUST_BACKTRACE full

    #################################################
    # GO
    #################################################
    if command -v go >/dev/null
        set -gx PATH (go env GOPATH)/bin $PATH
    end

    #################################################
    # FLUTTER
    #################################################
    set -gx PATH /opt/flutter/bin $PATH
    set -gx CHROME_EXECUTABLE /usr/bin/brave-browser

    #################################################
    # ANDROID SDK
    #################################################
    set -gx ANDROID_HOME $HOME/Android
    set -gx PATH \
        $ANDROID_HOME/cmdline-tools/latest/bin \
        $ANDROID_HOME/platform-tools \
        $ANDROID_HOME/emulator \
        $PATH

    #################################################
    # DOTNET
    #################################################
    set -gx DOTNET_ROOT $HOME/.dotnet
    set -gx PATH \
        $DOTNET_ROOT \
        $DOTNET_ROOT/tools \
        /opt/mssql-tools18/bin \
        $PATH

    #################################################
    # BUN (Fish-safe, NO _bun source)
    #################################################
    set -gx BUN_INSTALL $HOME/.bun
    set -gx PATH $BUN_INSTALL/bin $PATH

    #################################################
    # ACME
    #################################################
    if test -f "$HOME/.acme.sh/acme.sh.env"
        source "$HOME/.acme.sh/acme.sh.env"
    end

    #################################################
    # NIX (Fish-safe PATH only)
    #################################################
    set -gx PATH $HOME/.nix-profile/bin $PATH

    #################################################
    # MISC PATHS
    #################################################
    set -gx PATH \
        $HOME/common-lisp/lem \
        $HOME/.surrealdb \
        $PATH

    #################################################
    # TERMINAL
    #################################################
    set -gx TERM xterm-256color

    #################################################
    # WAYLAND / KDE SAFE
    #################################################
    if test "$XDG_SESSION_TYPE" = wayland
        set -gx QT_QPA_PLATFORM xcb
    end

    #################################################
    source ~/.local/share/chezmoi/aliases/fish_aliases.fish
    source ~/.local/share/chezmoi/aliases/vars.fish
    #################################################
end
