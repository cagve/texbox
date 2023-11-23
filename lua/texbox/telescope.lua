local pickers = require "telescope.pickers"
local actions = require "telescope.actions"
local entry_display = require("telescope.pickers.entry_display")
local action_state = require("telescope.actions.state")
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local ts_manager = require('texbox.ts_manager')
local util = require('texbox.utils')
local texbox = require('texbox.texbox')

local M = {}

M.bib_to_telescope = function (source)
	local entries = ts_manager.get_ts_bibdata(source, ts_manager.query_list["entries"])
	local telescope_entry ={}
	for index, entry in ipairs(entries) do
		local row = {}
		row[1] = ts_manager.get_ts_bibdata(entry, ts_manager.query_list["key"])[1]
		row[2] = ts_manager.get_ts_bibdata(entry, ts_manager.query_list["title"])[2]:gsub("{",""):gsub("}","")
		row[3] = ts_manager.get_ts_bibdata(entry, ts_manager.query_list["author"])[2]:gsub("{",""):gsub("}","")
		telescope_entry[index] = row
	end
	return telescope_entry
end

M.telescope_bib = function(opts)
	local bib = util.get_bib()
	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 80 },
			{ width = 18 },
			{ remaining = true },
		},
	})
	local make_display = function(entry)
		return displayer({
			entry.title,
			entry.author,
		})
	end
	opts = opts or {}
	pickers.new(opts, {
		prompt_title = "Bib entry",
		finder = finders.new_table {
			results = M.bib_to_telescope(bib),
			entry_maker = function(entry)
				return {
					ordinal = entry[2] .. entry[3],
					display = make_display,

					key = entry[1],
					title = entry[2],
					author = entry[3],
				}
			end
		},
		sorter = conf.generic_sorter(opts),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				texbox.add_to_bib(ts_manager.get_ts_entry_by_key(bib, selection.key))
				-- vim.api.nvim_put({ selection[1] }, "", false, true)
			end)
			return true
		end,
	}):find()
end


return M
