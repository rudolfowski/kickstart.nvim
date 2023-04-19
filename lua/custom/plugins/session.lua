return {
	'rmagatti/auto-session',
	dependencies = {
		'rmagatti/session-lens',
		'nvim-telescope/telescope.nvim'
	},
	config = function()
		local session = require 'auto-session'
		local session_lens = require 'session-lens'

		session.setup {
			log_level = "error",
			auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
		}
		session_lens.setup()
	end
}
