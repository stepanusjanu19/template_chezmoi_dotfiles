return {

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
        version = "*",
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
    },

    {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua", "vim", "vimdoc",
      "bash", "json", "html", "css"
    },
    highlight = { enable = true },
    indent = { enable = true },
  },
},



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
