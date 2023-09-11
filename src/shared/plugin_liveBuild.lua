local Library = require "CoronaLibrary"

local lib = Library:new{ name='liveBuild', publisherId='com.coronalabs' }

lib.run = function()
	local title = "Corona SDK"
	local message = "The 'liveBuild' plugin is designed to be used directly. Please, make 'Live Build' in with Corona Simulator."
	local buttonLabels = { 'OK' }

	native.showAlert( title, message, buttonLabels )
	print( 'Warning', message )
end

return lib
