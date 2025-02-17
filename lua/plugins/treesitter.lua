return {
    "nvim-treesitter/nvim-treesitter",
    opts = {
        auto_install = false,
        ensure_installed = {
            "lua",
            "vim",
            "vimdoc",
            "markdown",
            "markdown_inline",
            "c_sharp",
            "sql",
            "xml",
            "json"
        },
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false
        }
    }
}
