-- ABS_2_REL.lua
-- By Sublime 2014 https://github.com/Intrinsically-Sublime
-- Convert Cura Absolute extrusion gcode to Relative extrusion

-- Licence:  GPL v3
-- This library is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-----------------------------------------------------------------------------------

-- Threshold to determine if it is a retraction or E reset
R_THRESHOLD = 8
-- Retraction speed
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
	local m92 = line:match("M92+")
	
	-- Find M82 set Absolute E
	local m82 = line:match("M82")
	
	-- Find ABSOLUTE E value and filter out E
	local E_value = string.match(line, "E%d+%.%d+")
	if E_value then
		current_E_value = string.match(E_value, "%d+%.%d+")
	end
	
	-- Ignore M92 Ennn set E steps per mm
	if m92 then
		fout:write(line .. "\r\n")
		current_E_value = "0"

	-- Delete G92 E0 reset E
	elseif reset_E then
	
	-- Replace M82 Absolute E with M83 Relative E
	elseif m82 then
		fout:write("M83 \r\n")
		
	-- Replace Absolute E value with Relative E value
	elseif current_E_value then
		local E = (current_E_value - last_E_value)
		local new_E_value = (math.floor((E*100000)+0.25))*0.00001 -- Round up to the 6th digit after the decimal
		
		if new_E_value > 0 then
			local line_start = string.match(line, ".-E")
			fout:write(line_start .. new_E_value .. "\r\n")
		elseif current_E_value < last_E_value and new_E_value < R_THRESHOLD then
			fout:write("G1 E" .. new_E_value .. " F" .. R_SPEED .. "\r\n")
		else
			fout:write( line .. "\r\n" )
		end

	-- Write out any line that did not need modifying
	else
		fout:write( line .. "\r\n" )
	end
	
	-- Store the last E value for the next time through the loop
	last_E_value = current_E_value
end

-- done
fin:close()
fout:close()
print "done"
