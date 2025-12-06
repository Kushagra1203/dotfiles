return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },

  config = function()
    local mason_lspconfig = require("mason-lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local keymap = vim.keymap

    --------------------------------------------------------------------
    -- LSP Attach Keymaps
    --------------------------------------------------------------------
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }

        opts.desc = "References"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

        opts.desc = "Declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        opts.desc = "Definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

        opts.desc = "Implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

        opts.desc = "Type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

        opts.desc = "Code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        opts.desc = "Rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        opts.desc = "Doc"
        keymap.set("n", "K", vim.lsp.buf.hover, opts)

        opts.desc = "Diag (file)"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

        opts.desc = "Diag (line)"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
      end,
    })

    --------------------------------------------------------------------
    -- Capabilities
    --------------------------------------------------------------------
    local capabilities = cmp_nvim_lsp.default_capabilities()

    --------------------------------------------------------------------
    -- Diagnostic Signs
    --------------------------------------------------------------------
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    --------------------------------------------------------------------
    -- Mason LSP setup
    --------------------------------------------------------------------
    mason_lspconfig.setup()

    local installed_servers = mason_lspconfig.get_installed_servers()

    --------------------------------------------------------------------
    -- NEW Neovim 0.11 API setup
    --------------------------------------------------------------------
    for _, server in ipairs(installed_servers) do
      local opts = {
        capabilities = capabilities,
      }

      ---------------------------------------------------
      -- Custom server overrides (cleaned)
      ---------------------------------------------------

      if server == "graphql" then
        opts.filetypes = {
          "graphql",
          "gql",
          "typescriptreact",
          "javascriptreact",
        }

      elseif server == "emmet_ls" then
        opts.filetypes = {
          "html",
          "typescriptreact",
          "javascriptreact",
          "css",
          "sass",
          "scss",
          "less",
        }

      elseif server == "lua_ls" then
        opts.settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            completion = { callSnippet = "Replace" },
          },
        }
      end

      ---------------------------------------------------
      -- NEW START METHOD
      ---------------------------------------------------
      vim.lsp.start(
        vim.tbl_deep_extend(
          "force",
          vim.lsp.config[server] or {},
          opts
        )
      )
    end
  end,
}

