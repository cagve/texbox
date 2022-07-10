local pickers      = require "telescope.pickers"
local latex        = require 'texbox.latex'
local symbols	   = require 'texbox.symbols'
local finders      = require "telescope.finders"
local actions      = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local conf         = require 'telescope.config'.values
local api = vim.api

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
				local selection = action_state.get_selected_entry()[1]
				api.nvim_command('/'..selection)
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


M.latex_symbols = function (opts)
	opts = opts or {}
	pickers.new({
		sorter = conf.generic_sorter(opts),
		prompt_title = "Latex symbols",
		finder = finders.new_table({
			results = symbols,
			entry_maker = function(entry)
				return {
					value = entry.value,
					display = entry.name.." > "..entry.symbol,
					ordinal = entry.name,
				}
			end
		}),
	}):find()
end

return M
