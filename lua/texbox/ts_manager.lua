package.loaded['texbox.latex'] = nil
local bufnr = 0
local api = vim.api
local ts = require('nvim-treesitter.ts_utils')
local M = {}

M.query_list = {
	entries = "(entry) @entry", -- Return all entries in table. Need a bib as source
	title = "(entry (field (identifier)@title(#match? @title title)(value) @value))", -- Need a entry as source
	author = "(entry (field (identifier)@author(#match? @author author)(value) @value))", -- Need a entry as source
	key = "(entry (key_brace)@keybrace)" -- Need a entry as source
}

M.latex_query ={
	label = "(label_definition (curly_group_text (text) @label_title))",
	ref = "(label_reference (word) @reference_title)",
    command = "(generic_command) @command",
    new_command = "(new_command_definition) @new_command"
}


M.get_latex_element = function(query_string, complex)
	if complex == nil then
		complex = false
	end
	local parser = vim.treesitter.get_parser(bufnr, "latex")
	local root = parser:parse()[1]:root()
	local query = vim.treesitter.query.parse('latex', query_string)
	local result = {}
	local counter = 1
	for _,match,_ in query:iter_matches(root,bufnr, 0, -1) do
		for _, node in pairs(match) do
			if complex == true then
				local text = vim.treesitter.get_node_text(node,0)
				local line = node:range()+1
				result[counter] = {
					text = text,
					line = line}
			else
				result[counter] = vim.treesitter.get_node_text(node,0)
			end
			counter = counter+1
		end
	end
	return result
end

M.get_ts_newcommands = function ()
    local lines = M.get_latex_element(M.latex_query["new_command"])
    local new_commands = {}
    for _, v in pairs(lines) do
        -- local name, command = v:match("(%b{}).*(%b{})")
        local name, command = v:match("(%b{})(.*)")
        local current_definition = {}
        name = name:gsub("{",''):gsub("}", "")
        command = command:gsub('{',''):gsub("}", "")
        table.insert(current_definition,name)
        table.insert(current_definition,command)
        table.insert(new_commands, current_definition)
    end
    return new_commands
end

M.get_ts_labels = function ()
	local labels = {}
	local results = M.get_latex_element(M.latex_query["label"], true)
	for _,result in pairs(results) do
		local entry = {
			text = result.text,
			line = result.line,
			path = vim.api.nvim_buf_get_name(0)

		}
		table.insert(labels, entry)
	end
		return labels
end


M.get_ts_preamble = function ()
	local parser = vim.treesitter.get_parser(bufnr, "latex")
	local root = parser:parse()[1]:root()

	local query_string = "(generic_environment) @env"
	local query = vim.treesitter.query.parse('latex',query_string)
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
	local end_row = tonumber(tostring(vim.treesitter.get_node_range(envs[1])))+1
	local text = api.nvim_buf_get_lines(bufnr, start_row,end_row,false)
	return text
end

M.get_ts_section = function () -- NO FUNCIONA 2 VECES
	local parser = vim.treesitter.get_parser(bufnr, "latex")
	local root = parser:parse()[1]:root()

	local current_row = api.nvim_win_get_cursor(0)[1]
	local query = vim.treesitter.query.parse('latex', '(section)@section')
	for _,match,_ in query:iter_matches(root,bufnr, 0, -1) do
		for _, node in pairs(match) do
			ts.goto_node(node,false,false)
			local start_row = api.nvim_win_get_cursor(0)[1]
			ts.goto_node(node,true,false)
			local end_row = api.nvim_win_get_cursor(0)[1]
			if current_row >= start_row and current_row <= end_row then
				local title_node = ts.get_named_children(ts.get_named_children(node)[1])[1] -- EL SEGUNDO HIJO ES EL TÍTULO DE LA SECCIÓN
				local title = vim.treesitter.get_node_text(title_node,0)
				print("Extrayendo sección: "..title)
				local text = api.nvim_buf_get_lines(bufnr, start_row,end_row,false)
				return text
			end
		end
	end
end

M.get_ts_bibdata = function (source, querystr)
	local parser = vim.treesitter.get_string_parser(source, "bibtex")
	local tree = parser:parse()[1]
	local root = tree:root()
	local query = vim.treesitter.query.parse('bibtex', querystr)
	local result = {}
	local counter = 1
	for _,match,_ in query:iter_matches(root,source, 0, -1) do
		for _, node in pairs(match) do
			result[counter] = vim.treesitter.get_node_text(node,source)
			counter = counter+1
		end
	end
	return result
end

M.get_ts_entry_by_key = function (source, key)
	local querystr = '(entry (key_brace) @keybrace(#match? @keybrace "'..key..'"))@entry'
	local parser = vim.treesitter.get_string_parser(source, "bibtex")
	local tree = parser:parse()[1]
	local root = tree:root()
	local query = vim.treesitter.query.parse('bibtex', querystr)
	local result = {}
	local counter = 1
	for _,match,_ in query:iter_matches(root,source, 0, -1) do
		for _, node in pairs(match) do
			-- print(vim.inspect(q.get_node_text(node,bibfile)))
			result[counter] = vim.treesitter.get_node_text(node,source)
			counter = counter+1
		end
	end
	return result
end

M.get_headings = function ()
    local headings = {}
    local matches = {
        'part',
        'chapter',
        'section',
        'subsection',
        'subsubsection',
        'paragraph',
        'subparagraph',
    }

	for _,type in pairs(matches) do
		local results = M.get_latex_element("("..type.."(curly_group (text) @section))", true)
		for _,result in pairs(results) do
			local entry = {
				type = type,
				text = result.text,
				line = result.line,
				path = vim.api.nvim_buf_get_name(0)
				
			}
			table.insert(headings, entry)
		end
	end
    return headings
end


return M
