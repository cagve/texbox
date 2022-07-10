local q = require('vim.treesitter.query')
local M = {}

-- TODO: REFCATORING repito todo el rato split, refactoring

M.run_tableaux = function ()
	local yank_text = vim.fn.getreg('"0')
	local yank_lines = {}
	for s in yank_text:gmatch("[^\r\n]+") do
		table.insert(yank_lines, s)
	end

	local conclusion_list = {}
	for s in yank_lines[1]:gmatch("([^:]+)") do
		table.insert(conclusion_list, s)
	end

	local premises_list = {}
	for s in yank_lines[2]:gmatch("([^:]+)") do
		table.insert(premises_list, s)
	end

	local conclusion = conclusion_list[2]
	local premises = premises_list[2]
	print("Creating tableaux: ")
	print("Conclusion: "..conclusion)
	print("Premises: "..premises)

	local pyexp = [[
let s:mytext = 'hello world'
function! s:Test()
py3 << EOF
from epistemictree import rules as rl
premises = "]]..premises..[[".split(',')
print(rl.test_theorem(']]..conclusion..[[', premises))
EOF
endfunction

-- call s:Test()
	-- ]]

	local result =vim.api.nvim_exec(pyexp, true)
	return result
end

M.get_counter_model = function ()
	local dotfile = '/home/karu/model.dot'
	local command = 'dot2tex -ftikz '..dotfile
	local handle = io.popen(command)
	local source = handle:read("*a")

	source = source:gsub('] {','] {$')
		:gsub('$\\backslash$n',' ' )
		:gsub('∨','\\lor ')
		:gsub('-','\\lnot ')
		:gsub('→','\\to ')
		:gsub('∧','\\land ')
		:gsub('};','$};')
		:gsub('\\lnot >','->')

	local parser = vim.treesitter.get_string_parser(source, "latex")
	local tree = parser:parse()[1]
	local root = tree:root()
	local query_str = "(generic_environment (begin (curly_group_text (text) @text (#match? @text tikzpicture))))@entry"
	local query = vim.treesitter.parse_query('latex', query_str)
	local result = {}
	local counter = 1

	for _,match,_ in query:iter_matches(root,source, 0, -1) do
		for _, node in pairs(match) do
			result[counter] = q.get_node_text(node,source)
			counter = counter+1
		end
	end
	local tikz_lines = {"\\begin{figure}[ht!]","\\centering"}
	for s in result[2]:gmatch("[^\r\n]+") do
		table.insert(tikz_lines, s)
	end
	table.insert(tikz_lines,"\\end{figure}")
	local current_pos = vim.api.nvim_win_get_cursor(0)
	vim.api.nvim_buf_set_lines(0, current_pos[1]+1, current_pos[1]+1, true, tikz_lines)
end

M.get_tableaux =function ()
	local dotfile = '/home/karu/tree.dot'
	local command = 'dot2tex -ftikz '..dotfile
	local handle = io.popen(command)
	local source = handle:read("*a")

	source = source:gsub('] {','] {$')
		:gsub('∨','\\lor ')
		:gsub('-','\\lnot ')
		:gsub('→','\\to ')
		:gsub('∧','\\land ')
		:gsub('};','$};')
	 	:gsub('','\\times ')
		:gsub('', '\\downarrow ')
		:gsub('\\lnot >','->')
	local parser = vim.treesitter.get_string_parser(source, "latex")
	local tree = parser:parse()[1]
	local root = tree:root()
	local query_str = "(generic_environment (begin (curly_group_text (text) @text (#match? @text tikzpicture))))@entry"
	local query = vim.treesitter.parse_query('latex', query_str)
	local result = {}
	local counter = 1
	for _,match,_ in query:iter_matches(root,source, 0, -1) do
		for _, node in pairs(match) do
			result[counter] = q.get_node_text(node,source)
			counter = counter+1
		end
	end
	local tikz_lines = {"\\begin{figure}[ht!]","\\centering"}
	for s in result[2]:gmatch("[^\r\n]+") do
		table.insert(tikz_lines, s)
	end
	table.insert(tikz_lines,"\\end{figure}")
	local current_pos = vim.api.nvim_win_get_cursor(0)

	vim.api.nvim_buf_set_lines(0, current_pos[1]+1, current_pos[1]+1, true, tikz_lines)
end

M.run_tree = function ()
	M.run_tableaux()
	M.get_tableaux()
end

return M
