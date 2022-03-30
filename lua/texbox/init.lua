package.loaded['texbox'] = nil
package.loaded['texbox.latex'] = nil
package.loaded['texbox.telescope_latex'] = nil

local telescope = require('texbox.telescope_latex')
local latex = require('texbox.latex')

function table.merge(t1, t2)
   for _,v in ipairs(t2) do
      table.insert(t1, v)
   end
   return t1
end

local function extract_section()
	local preamble = latex.get_preamble()
	local document = latex.get_section()
	local text = table.merge(preamble,document)
	latex.create_document(text)
end

return {
	extract_section = extract_section
}

