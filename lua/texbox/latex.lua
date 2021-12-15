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

M.get_preamble = function ()
	local parser = vim.treesitter.get_parser(bufnr, "latex")
	local root = parser:parse()[1]:root()

	local query_string = "(environment) @env"
	local query = vim.treesitter.parse_query('latex',query_string)
	local envs = {}
	local counter = 1
	for _,match,_ in query:iter_matches(root,bufnr, 0, -1) do
		for _, node in pairs(match) do
			envs[counter] = node
			counter = counter+1
		end
	end
	-- ts.goto_node(envs[1],false,true) -- En latex el primer enviroment siempre es begin document
	local start_row = 0 -- La primera línea del preambulo siempre es 0
	local end_row = tonumber(tostring(ts.get_node_range(envs[1])))+1
	local text = api.nvim_buf_get_lines(bufnr, start_row,end_row,false)
	return text
end

M.get_section = function () -- NO FUNCIONA 2 VECES
	local parser = vim.treesitter.get_parser(bufnr, "latex")
	local root = parser:parse()[1]:root()

	local current_row = api.nvim_win_get_cursor(0)[1]
	local query = vim.treesitter.parse_query('latex', '(section)@section')
	for _,match,_ in query:iter_matches(root,bufnr, 0, -1) do
		for _, node in pairs(match) do
			ts.goto_node(node,false,false)
			local start_row = api.nvim_win_get_cursor(0)[1]
			ts.goto_node(node,true,false)
			local end_row = api.nvim_win_get_cursor(0)[1]
			if current_row >= start_row and current_row <= end_row then
				local title_node = ts.get_named_children(ts.get_named_children(node)[1])[1] -- EL SEGUNDO HIJO ES EL TÍTULO DE LA SECCIÓN
				local title = ts.get_node_text(title_node,0)[1]
				print("Extrayendo sección: "..title)
				local text = api.nvim_buf_get_lines(bufnr, start_row,end_row,false)
				return text
			end
		end
	end
end

M.create_document = function (text)
	local name = vim.fn.input("Nombre del archivo tex >> ")
	local new_buf = api.nvim_create_buf(true,false)
	api.nvim_buf_set_name(new_buf,name..".tex")
	api.nvim_buf_set_lines(new_buf,0,-1,false, text)
	api.nvim_buf_set_option(new_buf,"filetype","tex")
	api.nvim_buf_set_lines(new_buf,-1,-1,false,{"\\end{document}"})
end

return M
