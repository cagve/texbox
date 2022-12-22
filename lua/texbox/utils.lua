local actions      = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

local M = {}

M.check_if_exists = function (lines, pattern)
	for _,line in ipairs(lines) do
		if string.find(line, pattern) then
			return  true, line
		end
	end
	return false, nil
end

M.visual_selection_range = function ()
	local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
	local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
	if csrow < cerow or (csrow == cerow and cscol <= cecol) then
		return csrow - 1, cscol - 1, cerow - 1, cecol
	else
		return cerow - 1, cecol - 1, csrow - 1, cscol
	end
end


M.new_conceal = function (command, cchar)
	-- Opens a file in read
	if string.find(command,'\\') then
		command = command
	else
		command = '\\'..command
	end

	local syntax ="syn match texMathSymbol '"..command.."' contained conceal cchar="..cchar
	local syntax2 ="syn match texMathSymbol '\\"..command.."' contained conceal cchar="..cchar
	vim.cmd(":"..syntax)
	local file = "/home/karu/.config/nvim/after/syntax/tex.vim"
	local lines = {}
	for line in io.lines(file) do
		lines[#lines + 1] = line
	end
	if M.check_if_exists(lines,command) then
		local input = vim.fn.input("Conceal for \\"..command.." already exists. Wanna overwrite? ")
		if input=="y"then
			vim.cmd(":e "..file)
			vim.cmd(":%s/^.*\\"..command..".*/"..syntax2)
			vim.cmd(":w "..file)
			vim.cmd(":bdelete")
			return
		end
	else
		local f = io.open(file, "a")
		io.output(f)
		io.write(syntax)
		io.write("\n")
		io.close(f)
	end
end

M.reload_conceal = function ()
	-- local new_command = require('texbox.latex').get_new_commands()
	local parser = vim.treesitter.get_parser(0, "latex")
	local root = parser:parse()[1]:root()
	local query_new = vim.treesitter.parse_query('latex', "(new_command_definition (curly_group_command_name (command_name) @new_command))")
	local counter = 0
	for _,match,_ in query_new:iter_matches(root, 0, 0, -1) do
		for _, node in pairs(match) do
			local command = vim.treesitter.get_node_text(node, 0)
			local input = vim.fn.input("Wanna add cchar for "..command.."? (yY/nN) > ")
			if input=="q" then
				print("")
				print(counter.." new cchars added")
				return
			elseif input ~= "" then
				vim.cmd(":syn match texMathSymbol '\\"..command.."' contained conceal cchar="..input)
				print("Cchar "..input.." added for "..command)
			end
			counter = counter+1
		end
	end
			-- local command = vim.treesitter.get_node_text(node,0)
			-- local new_buf = vim.api.nvim_create_buf(false, true)
			-- vim.api.nvim_buf_set_lines(new_buf, 0, -1, true, {"$"..command.."$"})
			-- vim.api.nvim_buf_set_option(new_buf, "filetype","tex")
			-- vim.api.nvim_set_current_buf(new_buf)
			-- -- -- local new_win = vim.api.nvim_open_win(new_buf, false, {relative='win', row=3, col=3, width=12, height=3})
			-- vim.api.nvim_win_set_cursor(0, {1,2})
			-- vim.cmd(":let g:current_conceal = synconcealed(line('.'), col('.'))")
			-- local conceal = vim.api.nvim_get_var('current_conceal')[2]
			-- vim.cmd(":bdelete")
			-- if conceal == "" then
			-- 	conceal = "None"
			-- end
			-- print("text: "..command.." conceal: "..conceal)
			--
end


return M
