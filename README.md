Absolute-E_2_Relative-E_post-processor
=========================

Works with Cura gcode files. (should work with other slicers but untested as they all have options for Relative)

Convert Absolute extrusion gcode to Relative extrusion

The script is written in lua so you will need lua installed or an executable copy in the same folder as the script 
and the slicer. 

To use with Cura you will have to run it as a seperate process from the command line with the following command.
`lua "ABS_2_REL.lua" "example.gcode"`

Note: The script creates a second gcode file marked processed.

