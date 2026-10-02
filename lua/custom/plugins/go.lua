return {
  'ray-x/go.nvim',
  dependencies = { -- optional packages
    'ray-x/guihua.lua',
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    require('go').setup()

    -- NOTE: formatowanie przy zapisie robi conform (goimports, init.lua).
    -- Był tu BufWritePre z require('go.format').goimports(), ale to asynchroniczny
    -- code action gopls — zmieniał bufor już PO zapisie, plik zostawał niesformatowany.
  end,
  -- NOTE: był tu też `event = { 'CmdlineEnter' }`, który ładował wtyczkę przy
  -- pierwszym naciśnięciu `:` w dowolnym pliku, kasując sens lazy-loadingu po `ft`.
  ft = { 'go', 'gomod' },
  build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
}
