return {
  'rmagatti/auto-session',
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
  -- NOTE: musi być eager — lazy-loading zepsułby automatyczne przywracanie sesji.
  lazy = false,
  opts = {
    log_level = 'error',
    -- NOTE: stara nazwa `auto_session_suppress_dirs` jest przestarzała.
    suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
    -- Picker sesji jest wbudowany w auto-session (`:AutoSession search`);
    -- osobna wtyczka `rmagatti/session-lens` nie jest już potrzebna
    -- (była najdroższą pozycją przy starcie, ~17 ms).
    session_lens = {
      load_on_setup = true,
    },
  },
  keys = {
    { '<leader>sS', '<cmd>AutoSession search<cr>', desc = '[S]earch [S]essions' },
  },
}
