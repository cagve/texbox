local util = require'texbox.utils'
local ts_manager = require'texbox.ts_manager'
local ts = require('nvim-treesitter.ts_utils')
local M = {}

M.new_conceal = function (command, cchar)
	-- Check if input has \ or not
	if string.find(command,'\\') then
		command = '\\'..command
	else
	end

	local syntax ="syn match texMathSymbol '"..command.."' contained conceal cchar="..cchar
	local file = os.getenv( "HOME" ).."/.config/nvim/after/syntax/tex.vim"
	local lines = {}
	for line in io.lines(file) do
		lines[#lines + 1] = line
	end
	vim.cmd(syntax)
	if util.check_if_exists(lines,command) then
		local input = vim.fn.input("Conceal for "..command.." already exists. Wanna overwrite? ")
		if input=="y"then
			vim.cmd(":e "..file)
			vim.cmd(":%s/^.*"..command..".*/"..syntax)
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


M.add_conceal_to_newcommand_list = function ()
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
				M.new_conceal(command, input)
			end
			counter = counter+1
		end
	end
end

M.extract_section = function ()
	local preamble = ts_manager.get_ts_preamble()
	local document = ts_manager.get_ts_section()
	local text = util.merge_table(preamble,document)
	M.create_document(text)
end

M.extract_visual_text = function ()
	local preamble =ts_manager.get_ts_preamble()
	local visual_text = M.get_visual_text()
	local text = util.merge_table(preamble,visual_text)
	M.create_document(text)
end

M.create_document = function (text)
	local name = vim.fn.input("Nombre del archivo tex >> ")
	local path = ""
	local split = vim.split(name,"/")
	local file = split[#split]
	if string.find(file,".tex") == nil then
		file = file..".tex"
	end
	table.remove(split,#split)
	for _,k in pairs(split) do
		if path == "" then
			path = k
		else
			path = path.."/"..k
		end
	end
	-- If absolute path
	if split[1]=="" then
		path = "/"..path
	end

	local new_buf = vim.api.nvim_create_buf(true,false)
	vim.api.nvim_buf_set_name(new_buf,path.."/"..file)
	vim.api.nvim_buf_set_lines(new_buf,0,-1,false, text)

	vim.api.nvim_buf_set_option(new_buf,"filetype","tex")
	vim.api.nvim_buf_set_lines(new_buf,-1,-1,false,{"\\end{document}"})
end

M.new_command = function (command)
	local parser = vim.treesitter.get_parser(bufnr, "latex")
	local root = parser:parse()[1]:root()
	local query_string = "(generic_environment) @env"
	local query = vim.treesitter.parse_query('latex', query_string)
	local envs = {}
	local counter = 1
	for _,match,_ in query:iter_matches(root,bufnr, 0, -1) do
		for _, node in pairs(match) do
			envs[counter] = node
			counter = counter+1
		end
	end
	local end_row = tonumber(tostring(ts.get_node_range(envs[1])))+1
	local name = vim.fn.input("Command name for ".. command.." >> ")
	local return_text = "\\newcommand{\\"..name.."}{"..command.."}"
	local current_pos = vim.api.nvim_win_get_cursor(0)
	print("New command "..name.." does "..command)
	command = command:gsub('\\', '\\\\')
	vim.cmd("%s/"..command.."/\\\\"..name)
	vim.api.nvim_win_set_cursor(0,{end_row,0})
	vim.cmd('normal O '..return_text)
	vim.cmd(':norm! =j')
	vim.api.nvim_win_set_cursor(0,current_pos)
	local input = vim.fn.input("Wanna add cchar for "..name.."? (yY/nN) > ")
	if input=="y" then
		print("")
		local cchar = vim.fn.input("Cchar > ")
		M.new_conceal(name,cchar)
	end
end

M.new_conceal_from_yank = function ()
	local yank_text = string.gsub(vim.fn.getreg('"0'),"\n"," ")
	local input = vim.fn.input("Cchar for "..yank_text.." >> ")
	if input ~= "" then
		M.new_conceal(yank_text, input)
	end
end

M.new_conceal_from_visual = function ()
	local visual_text = util.get_visual_text()
	local input = vim.fn.input("Cchar for "..visual_text[1].." >> ")
	if input ~= "" then
		M.new_conceal(visual_text[1], input)
	end
end


M.newcommand_from_yank = function ()
	local yank_text = string.gsub(vim.fn.getreg('"0'),"\n"," ")
	M.new_command(yank_text)
end

M.newcommand_from_visual = function ()
	local visual_text = util.get_visual_text()
	M.new_command(visual_text[1])
end

M.add_to_bib = function (entry)
	local buf = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local flag,l = util.check_if_exists(buf, "bibliography{")
	if flag and vim.api.nvim_buf_get_option(0,'filetype') == 'tex' then
		local file = string.match(l, '{.+}'):gsub("{",""):gsub("}","")..".bib"
		local lines = {}
		for line in io.lines(file) do
			lines[#lines + 1] = line
		end
		table.concat(lines,'\n')
		if util.check_if_exists(lines, entry[1])then
			print("Entry exists :)")
			print(entry[1])
			return
		end
		print("New bib entry :) ")
		print(entry[2])
        local ans = vim.fn.input("Confirm? [Y/n]: ")
        if ans ~= 'y' then
            print("Bib entry not added")
           return 
        end
        print("Bib entry added")
		file = io.open(file, "a")
		io.output(file)
		io.write(entry[2])
		io.close(file)
	else
		print("Not bib file found")
		return flag
	end
end

M.add_labels = function ()
	local command = vim.fn.input("Titulo de la referencia >> ")
	api.nvim_put({"\\label{"..command.."}"}, "", true, true)
	vim.cmd('startinsert')
end

return M
