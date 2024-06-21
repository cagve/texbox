local util = require'texbox.utils'
local ts_manager = require'texbox.ts_manager'
local ts = require('nvim-treesitter.ts_utils')
local M = {}

M.new_conceal = function (command)
	-- Check if input has \ or not

	-- ((scoped_identifier) @hola (#eq? @hola "g:vimtex_syntax_custom_cmds"))

	local file = os.getenv( "HOME" ).."/.config/nvim/after/plugin/vimtex.vim"
	local buffer = vim.api.nvim_create_buf(true, false)
	if vim.api.nvim_buf_is_valid(buffer) then
        local file_content = {}
        local file = io.open(file, "r")
        if file then
            for line in file:lines() do
                table.insert(file_content, line)
            end
            file:close()
        else
            print("Error: Cannot open file " .. file)
            return
        end
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, file_content)
    else
        print("Error: Buffer " .. buffer .. " is not valid")
    end
	-- Set the buffer type to vim file
	vim.api.nvim_buf_set_option(buffer, 'filetype', 'vim')

	local parser = vim.treesitter.get_parser(buffer, "vim")
	local root = parser:parse()[1]:root()
	local query = vim.treesitter.query.parse('vim', '((scoped_identifier) @hola (#eq? @hola "g:vimtex_syntax_custom_cmds"))')
	

	local cchar = vim.fn.input("Which char do you want for "..command.."?  ")
	local math = vim.fn.input("Is "..cchar.." a math command (1/0)? ")

	local conceal = '\\ {"name": "'..command..'", "mathmode": "'..math..'", "concealchar": "'..cchar..'"}, '
    for _, match, _ in query:iter_matches(root, buffer, 0, -1) do
        for id, node in pairs(match) do
            local node_start_row, node_start_col, node_end_row, node_end_col = node:range()
			vim.api.nvim_buf_set_lines(buffer, node_end_row + 1, node_end_row + 1, false, {conceal})
        end
    end
	vim.api.nvim_buf_call(buffer, function()
		vim.cmd('write! ' .. file)
		vim.cmd('silent! noautocmd bwipeout!')
	end)
end


M.add_conceal_to_newcommand_list = function ()
	local parser = vim.treesitter.get_parser(0, "latex")
	local root = parser:parse()[1]:root()
	local query_new = vim.treesitter.query.parse('latex', "(new_command_definition (curly_group_command_name (command_name) @new_command))")
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
	if string.find(name,"tex") == nil then
		name = name..".tex"
	end
	local file  = "./"..name

	local new_buf = vim.api.nvim_create_buf(true,false)
	vim.api.nvim_buf_set_name(new_buf,file)
	vim.api.nvim_buf_set_lines(new_buf,0,-1,false, text)

	vim.api.nvim_buf_set_option(new_buf,"filetype","tex")
	vim.api.nvim_buf_set_lines(new_buf,-1,-1,false,{"\\end{document}"})
end

M.new_command = function (command)
	local bufnr = 0
	local parser = vim.treesitter.get_parser(bufnr, "latex")
	local root = parser:parse()[1]:root()
	local query_string = "(generic_environment) @env"
	local query = vim.treesitter.query.parse('latex', query_string)
	local envs = {}
	local counter = 1
	for _,match,_ in query:iter_matches(root,bufnr, 0, -1) do
		for _, node in pairs(match) do
			envs[counter] = node
			counter = counter+1
		end
	end
	local end_row = tonumber(tostring(vim.treesitter.get_node_range(envs[1])))+1
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
	M.new_conceal(yank_text)
end

M.new_conceal_from_visual = function ()
	local visual_text = util.get_visual_text()
	local input = vim.fn.input("Cchar for "..visual_text[1].." >> ")
	if input ~= "" then
		M.new_conceal(visual_text[1])
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
