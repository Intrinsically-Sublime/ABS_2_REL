-- ABS_2_REL.lua
-- By Sublime 2014
-- Convert Cura Absolute extrusion gcode to Relative extrusion

-- Licence:  GPL v3
-- This library is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-----------------------------------------------------------------------------------

R_THRESHOLD = 8
R_SPEED = 60000

-- open files
collectgarbage()  -- ensure unused files are closed
local fin = assert( io.open( arg[1] ) ) -- reading
local fout = assert( io.open( arg[1] .. ".processed", "wb" ) ) -- writing must be binary

last_E_value = 0

-- read lines
for line in fin:lines() do
	
	-- Find E reset
	local reset_E = line:match( "G92 E0")
	
	-- Find M92 set E steps
	local skip = line:match("M92+")
	
	-- Find ABSOLUTE E value
	local E_value = string.match(line, "E%d+%.%d+")

	if E_value then
		current_E_value = string.match(E_value, "%d+%.%d+")
	end
	
	if skip then
		fout:write(line .. "\r\n")
		current_E_value = "0"

	elseif reset_E then
		
	elseif current_E_value then
		local E = (current_E_value - last_E_value)
		local new_E_value = (math.floor((E*100000)+0.25))*0.00001
		
		if new_E_value > 0 then
			local line_start = string.match(line, ".-E")
			fout:write(line_start .. new_E_value .. "\r\n")
		elseif current_E_value < last_E_value and new_E_value < R_THRESHOLD then
			fout:write("G1 E" .. new_E_value .. " F" .. R_SPEED .. "\r\n")
		else
			fout:write( line .. "\r\n" )
		end

	else
		fout:write( line .. "\r\n" )
	end
	last_E_value = current_E_value or 0
end

-- done
fin:close()
fout:close()
print "done"
