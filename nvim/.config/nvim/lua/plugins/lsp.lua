-- local vue_language_server_path = vim.fn.expand("$MASON/packages")
--   .. "/vue-language-server"
--   .. "/node_modules/@vue/language-server"

local vue_language_server_path = vim.fn.stdpath("data")
  .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

local tsserver_filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      cssls = {
        settings = {
          css = {
            lint = {
              unknownAtRules = "ignore",
            },
          },
          scss = {
            lint = {
              unknownAtRules = "ignore",
            },
          },
          less = {
            lint = {
              unknownAtRules = "ignore",
            },
          },
        },
      },
      intelephense = {
        -- put your lincence key in ~/intelephense/licence.txt
        -- if it is correct, RENAME functionality will be available
      },
      vue_ls = {
        enabled = true,
        -- on_init = setup_vue_ls_on_init, -- Pripojíme našu funkciu pre preposielanie požiadaviek
        filetypes = { "vue" }, -- Zabezpečíme, že vue_ls beží len pre .vue súbory
      },
      ts_ls = {
        enabled = false,
        init_options = {
          plugins = {
            {
              name = "@vue/typescript-plugin",
              location = vue_language_server_path,
              languages = { "vue" },
              configNamespace = "typescript",
            },
          },
        },
        filetypes = tsserver_filetypes,
      },
      vtsls = {
        enabled = true,
        settings = {
          vtsls = {
            tsserver = {
              globalPlugins = {
                {
                  name = "@vue/typescript-plugin",
                  location = vue_language_server_path,
                  languages = { "vue" },
                  configNamespace = "typescript",
                },
              },
            },
          },
        },
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
      },
    },
  },
}
