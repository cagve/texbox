local bufnr = 0
local api = vim.api
local ts = require('nvim-treesitter.ts_utils')

-- local ts_query = require('vim.treesitter.query')

local latex_query ={
	label = "(label_definition (word) @label_title)",
	ref = "(label_reference (word) @reference_title)"
}

local M = {}

M.is_tex = function ()
	if(vim.bo.filetype == 'tex') then
		return true
	else
		return false
	end
end

M.get_latex_element = function(query_string)
	local parser = vim.treesitter.get_parser(bufnr, "latex")
	local root = parser:parse()[1]:root()

	local query = vim.treesitter.parse_query('latex', query_string)
	local result = {}
	local counter = 1
	for _,match,_ in query:iter_matches(root,bufnr, 0, -1) do
		for _, node in pairs(match) do
			result[counter] = ts.get_node_text(node,0)[1]
			counter = counter+1
		end
	end
	return result
end

M.get_labels = function ()
	if not M.is_tex() then
		print("No es un archivo tex")
		return
	end
	return M.get_latex_element(latex_query["label"])
end

M.add_labels = function ()
	local command = vim.fn.input("Titulo de la referencia >> ")
	api.nvim_put({"\\label{"..command.."}"}, "", true, true)
	vim.cmd('startinsert')
end



return M
