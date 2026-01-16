return {

    {
        "NvChad/NvChad",
        lazy = false,
        opts = {
            rocks = {
                enabled = false,
            },
        },
    },

    {
        "stevearc/conform.nvim",
        -- event = 'BufWritePre', -- uncomment for format on save
        opts = require "configs.conform",
    },

    -- These are some examples, uncomment them if you want to see them work!
    {
        "neovim/nvim-lspconfig",
        config = function()
            require "configs.lspconfig"
        end,
    },

    -- Auto pairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
    },

    -- Comment (replacement for vim-commentary)
    {
        "numToStr/Comment.nvim",
        config = true,
    },

    -- Surround (replacement for vim-surround)
    {
        "kylechui/nvim-surround",
        config = true,
    },

    {
        "mfussenegger/nvim-dap",
    }


    -- test new blink
    -- { import = "nvchad.blink.lazyspec" },

    -- {
    -- 	"nvim-treesitter/nvim-treesitter",
    -- 	opts = {
    -- 		ensure_installed = {
    -- 			"vim", "lua", "vimdoc",
    --      "html", "css"
    -- 		},
    -- 	},
    -- },
}
