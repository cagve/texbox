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

local function telescope_labels()
	telescope.labels_telescope()
end

local function add_labels()
	latex.add_labels()
end

local function extract_section()
	local preamble = latex.get_preamble()
	local document = latex.get_section()
	local text = table.merge(preamble,document)
	latex.create_document(text)
end

local function new_command()
	latex.new_command()
end

return {
	extract_section = extract_section,
	telescope_labels = telescope_labels,
	add_labels = add_labels,
	new_command = new_command
}

