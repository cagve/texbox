local M = {}

M.check_if_exists = function (lines, pattern)
	for _,line in ipairs(lines) do
		if string.find(line, pattern) then
			return  true, line
		end
	end
	return false, nil
end

M.get_visual_text = function ()
  local start_row = vim.fn.getpos("'<")[2]
  local start_col = vim.fn.getpos("'<")[3]-1
  local end_row = vim.fn.getpos("'>")[2]
  local end_col = vim.fn.getpos("'>")[3]
  local lines = vim.api.nvim_buf_get_text(0,start_row, start_col, end_row ,end_col, {})
  return lines
end

M.merge_table = function (t1, t2)
		for _,v in ipairs(t2) do
			table.insert(t1, v)
		end
		return t1
end

M.is_tex = function ()
	if(vim.bo.filetype == 'tex') then
		return true
	else
		return false
	end
end

M.get_bib = function ()
	local bib = vim.api.nvim_get_var("bib_file")
	local lines = {}
	for line in io.lines(bib) do
		lines[#lines + 1] = line
	end
	return table.concat(lines,'\n')
end

return M
