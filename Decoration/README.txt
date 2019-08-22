- Replace any <> with actual values (don't include the actual < > brackets)
- Don't include the quotation "" marks
- Spaces are important
- Note that when sending data, it will also include the newLine character at the end

Send to this module:
"begin"
	Send this when images of the cake have been acquired and decorating can begin

"conv [<x>, <y>, <z>] <th>"
	Blocks to be taken from the conveyer to the table for examination
	x = x co-ordinate
	y = y co-ordinate
	z = z co-ordinate
	th = angle of rotation (should be 0)
	
"cake [<x>, <y>, <z>] <th>"
	Blocks to be taken from the examining spot to the cake
	x = x co-ordinate
	y = y co-ordinate
	z = z co-ordinate
	th = angle of rotation (should be 0)
	
"complete"
	Send this when the cake has been finished decorating. The robot arm will move away from the table in case other images need to be taken
	
Things sent by this module
"[<x1>, <y1>, <z1>] <th1> [<x2>, <y2>, <z2>] <th2>"
	The positions and orientations of the initial place at the conveyer and the placement on the cake/trash/nowhere respectively

"ERROR:Waiting_at_Conveyor"
	Sent when attempting to place blocks on cake while robot is waiting for blocks on the conveyor
	
"ERROR:Waiting_at_Cake"
	Sent when attempting to pick blocks from the conveyor while waiting to place blocks on the cake
	
"ERROR:Values_unreadable"
	Could not read block variables, either the data was corrupted or the data wasn't block data

"ERROR:Unknown"
	Some other error
