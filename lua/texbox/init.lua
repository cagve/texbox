package.loaded['texbox'] = nil
package.loaded['texbox.latex'] = nil
package.loaded['texbox.telescope_latex'] = nil

local telescope = require('texbox.telescope_latex')


return {
	labels = telescope.labels_telescope()
}
