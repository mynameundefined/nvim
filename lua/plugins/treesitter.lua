return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
        ensure_installed = {
            "lua",
            "vimdoc",
            "markdown",
            "c_sharp",
            "xml",
            "json"
        },

        sync_install = false,

        auto_install = true,

        indent = {
            enable = true
        },

        highlight = {
            enable = true,
            additional_vim_regex_highlighting = { "markdown" }
        }
    }
}
