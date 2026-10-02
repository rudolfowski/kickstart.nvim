-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F10>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F11>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F12>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<F8>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'
    local dapgo = require 'dap-go'
    local dappy = require 'dap-python'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      -- Domyślny handler konfiguruje adapter + launch configi dla każdego
      -- zainstalowanego debuggera (codelldb → C/C++). Python i Go mają własne
      -- konfiguracje z nvim-dap-python / nvim-dap-go niżej — bez wyłączenia tu
      -- byłyby zdublowane wpisy.
      handlers = {
        function(config)
          require('mason-nvim-dap').default_setup(config)
        end,
        python = function() end,
        delve = function() end,
      },

      ensure_installed = {
        'delve', -- Go
        'python', -- debugpy
        'codelldb', -- C / C++
      },
    }

    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint)

    vim.keymap.set('n', '<leader>dB', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })

    vim.keymap.set('n', '<Leader>dr', function()
      dap.repl.toggle {
        height = 10,
      }
    end)

    vim.keymap.set('n', '<Leader>dt', function()
      dapgo.debug_test()
    end, { desc = 'Debug: Test' })

    vim.keymap.set('n', '<Leader>dc', function()
      dap.run_to_cursor()
    end, { desc = 'Debug: Run to cursor' })

    vim.keymap.set('n', '<Leader>dl', function()
      dap.run_last()
    end, { desc = 'Debug: Run Last' })

    vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function()
      require('dap.ui.widgets').hover()
    end, { desc = 'Debug: Hover' })

    vim.keymap.set({ 'n', 'v' }, '<Leader>dp', function()
      require('dap.ui.widgets').preview()
    end, { desc = 'Debug: Preview' })

    vim.keymap.set('n', '<Leader>df', function()
      local widgets = require 'dap.ui.widgets'
      widgets.centered_float(widgets.frames)
    end, { desc = 'Debug: Frames' })

    vim.keymap.set('n', '<Leader>ds', function()
      local widgets = require 'dap.ui.widgets'
      widgets.centered_float(widgets.scopes)
    end, { desc = 'Debug: Scopes' })

    vim.keymap.set('n', '<Leader>dq', function()
      dap.terminate()
    end, { desc = 'Debug: Quit' })

    vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = '', linehl = '', numhl = '' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
      layouts = {
        {
          -- You can change the order of elements in the sidebar
          elements = {
            -- Provide IDs as strings or tables with "id" and "size" keys
            {
              id = 'scopes',
              size = 0.25, -- Can be float or integer > 1
            },
            { id = 'breakpoints', size = 0.25 },
            { id = 'stacks', size = 0.25 },
            { id = 'watches', size = 0.25 },
          },
          size = 40,
          position = 'left', -- Can be "left" or "right"
        },
        --{
        --  elements = {
        --    "repl",
        --  },
        --  size = 10,
        --  position = "bottom", -- Can be "bottom" or "top"
        --},
      },
    }

    -- Change breakpoint icons
    -- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    -- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    -- local breakpoint_icons = vim.g.have_nerd_font
    --     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
    --   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    -- for type, icon in pairs(breakpoint_icons) do
    --   local tp = 'Dap' .. type
    --   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
    --   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    -- end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- NOTE: nvim-dap-go rejestruje własny adapter `delve`. Ten override jest
    -- zbędny, a hardcodowana ścieżka do kitty nie istnieje na macOS.
    -- dap.adapters.delve = {
    --   type = 'server',
    --   port = '${port}',
    --   executable = {
    --     command = 'kitty',
    --     args = { 'dlv', 'dap', '-l', '127.0.0.1:${port}' },
    --   },
    -- }

    -- debugpy z Masona (systemowy python3 go nie ma). Debugowany program
    -- dostaje interpreter z aktywnego venv / .venv / venv w projekcie, jeśli jest.
    dappy.setup(vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python')

    -- Install golang specific config
    require('dap-go').setup {
      tests = {
        verbose = true,
      },
    }

    -- NOTE: Debugowanie TS/JS (vscode-js-debug + nvim-dap-vscode-js, konfiguracje
    -- pwa-node/pwa-chrome pod Angulara na porcie 4200) zostało usunięte.
    -- Powód: most `mxsdev/nvim-dap-vscode-js` jest porzucony od 2023-03, a build
    -- `microsoft/vscode-js-debug` wymagał npm przy każdym update i brudził
    -- package-lock.json, przez co lazy odmawiało aktualizacji wtyczki.
    -- Historia konfiguracji jest w gicie, gdyby trzeba było ją odtworzyć.
  end,
}
