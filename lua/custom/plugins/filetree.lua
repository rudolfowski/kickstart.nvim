return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  -- Lazy-load: bez tego neo-tree (+ nui) ładowały się przy każdym starcie.
  cmd = 'Neotree',
  keys = {
    -- NOTE: poprzednio było tu <C-m>, które w terminalu jest tym samym kodem
    -- co <CR> — Enter w trybie normalnym otwierał drzewko zamiast schodzić w dół.
    { '<leader>e', '<cmd>Neotree reveal<cr>', desc = 'Neo-tree: reveal current file' },
    { '<C-n>', '<cmd>Neotree toggle<cr>', desc = 'Neo-tree: toggle' },
  },
  opts = {},
}
