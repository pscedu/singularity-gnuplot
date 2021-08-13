--
-- gnuplot 5.4 modulefile
--
-- "URL: https://www.psc.edu/resources/software"
-- "Category: Other"
-- "Description: gnuplot is a command-line and GUI program that can generate two- and three-dimensional plots of functions, data, and data fits."
-- "Keywords: singularity utilities"

whatis("Name: gnuplot")
whatis("Version: 5.4")
whatis("Category: Other")
whatis("URL: https://www.psc.edu/resources/software")
whatis("Description: gnuplot is a command-line and GUI program that can generate two- and three-dimensional plots of functions, data, and data fits.")

help([[
gnuplot is a command-line and GUI program that can generate two- and three-dimensional plots of functions, data, and data fits.

To load the module type

> module load gnuplot/5.4

To unload the module type

> module unload gnuplot/5.4

Documentation
-------------
For help, type

> gnuplot --help

Tools included in this module are

* gnuplot
]])

local package = "gnuplot"
local version = "5.4"
local base    = pathJoin("/opt/packages",package,version)
prepend_path("PATH", base)
