local pickers = require "telescope.pickers"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local entry_display = require("telescope.pickers.entry_display")
local action_state = require("telescope.actions.state")
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local q = require('vim.treesitter.query')
local t = require('vim.treesitter.languagetree')
local M = {}

M.get_bib = function()
	--TODO check if file exists
	local bib = vim.api.nvim_get_var("bib_file")
	local lines = {}
	for line in io.lines(bib) do
		lines[#lines + 1] = line
	end
	return table.concat(lines, '\n')
end

local query_list = {
	entries = "(entry) @entry", -- Return all entries in table. Need a bib as source
	title = "(entry (field (identifier)@title(#match? @title title)(value) @value))", -- Need a entry as source
	author = "(entry (field (identifier)@author(#match? @author author)(value) @value))", -- Need a entry as source
	key = "(entry (key_brace)@keybrace)" -- Need a entry as source
}

M.get_data = function(source, querystr)
	local parser = vim.treesitter.get_string_parser(source, "bibtex")
	local tree = parser:parse()[1]
	local root = tree:root()
	local query = vim.treesitter.parse_query('bibtex', querystr)
	local result = {}
	local counter = 1
	for _, match, _ in query:iter_matches(root, source, 0, -1) do
		for _, node in pairs(match) do
			result[counter] = q.get_node_text(node, source)
			counter = counter + 1
		end
	end
	return result
end

M.get_entry_by_key = function(source, key)
	local querystr = '(entry (key_brace) @keybrace(#match? @keybrace "' .. key .. '"))@entry'
	local parser = vim.treesitter.get_string_parser(source, "bibtex")
	local tree = parser:parse()[1]
	local root = tree:root()
	local query = vim.treesitter.parse_query('bibtex', querystr)
	local result = {}
	local counter = 1
	for _, match, _ in query:iter_matches(root, source, 0, -1) do
		for _, node in pairs(match) do
			-- print(vim.inspect(q.get_node_text(node,bibfile)))
			result[counter] = q.get_node_text(node, source)
			counter = counter + 1
		end
	end
	return result
end

M.bibtex_to_telescope = function(source)
	local entries = M.get_data(source, query_list["entries"])
	local telescope_entry = {}
	for index, entry in ipairs(entries) do
		local row = {}
		row[1] = M.get_data(entry, query_list["key"])[1]
		row[2] = M.get_data(entry, query_list["title"])[2]:gsub("{", ""):gsub("}", "")
		row[3] = M.get_data(entry, query_list["author"])[2]:gsub("{", ""):gsub("}", "")
		telescope_entry[index] = row
	end
	return telescope_entry
end

M.telescope = function(bib, opts)
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
			results = M.bibtex_to_telescope(bib),
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
				M.add_to_bib(M.get_entry_by_key(bib, selection.key))
				-- vim.api.nvim_put({ selection[1] }, "", false, true)
			end)
			return true
		end,
	}):find()
end

M.check_if_exists = function(lines, pattern)
	for _, line in ipairs(lines) do
		if string.find(line, pattern) then
			return true, line
		end
	end
	return false, nil
end

M.add_to_bib = function(entry)
	local buf = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local flag, l = M.check_if_exists(buf, "bibliography")
	if flag and vim.api.nvim_buf_get_option(0, 'filetype') == 'tex' then
		local file = string.match(l, '{.+}'):gsub("{", ""):gsub("}", "") .. ".bib"
		local lines = {}
		for line in io.lines(file) do
			lines[#lines + 1] = line
		end
		table.concat(lines, '\n')
		if M.check_if_exists(lines, entry[1]) then
			print("Entry exists")
			print(":)")
			return
		end
		file = io.open(file, "a")
		io.output(file)
		io.write(entry[2])
		io.close(file)
		print("New bib entry: ")
		print(entry[2])
	else
		print("Not bib file found")
		return flag
	end
end

M.run_telescope = function()
	local bib = M.get_bib()
	M.telescope(bib)
end

return M
