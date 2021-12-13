local pickers      = require "telescope.pickers"
local latex        = require 'texbox.latex'
local finders      = require "telescope.finders"
local actions      = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local conf         = require 'telescope.config'.values

local M = {}

M.labels_telescope = function (opts)
	opts = opts or {}
	pickers.new({
		prompt_title = "Labels",
		finder = finders.new_table {
			results = latex.get_labels(),
		},
		attach_mappings = function(prompt_bufnr,map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				local result = "\\ref{"..selection[1].."}"
				vim.api.nvim_put({result}, "", true, true)
			end)
			map("n", "<C-a>", M.add_labels)
			map("i", "<C-a>", M.add_labels)
			return true
		end,
		sorter = conf.generic_sorter(opts),
	}):find()
end

M.add_labels = function(prompt_bufnr)
	actions.close(prompt_bufnr)
	latex.add_labels()
end


return M
