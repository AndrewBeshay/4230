# GUI

The complete front end - backend for the robot studio programmers as well as the image processing for MATLAB  

## How to run 

Open RobotStudio and load all the `.mod` files  
`T_COM` takes all communication/server related files  
`T_ROB` takes all robot movement functions  

Once the server is started run the file `Start.mlapp`  

## Network Protocol    
##### MATLAB -> RobotStudio  
| Field | Field Name | Field Type | Description | Binary Bytes |
|:-----:|:----------:|:----------:|:------------------------------------------------------------------------------------------------------------------------------------------------:|:------------:|
| 1 | Header | Char | "ML" | 2 |
| 2 | Flag | Int | 0 = Normal Operation  1 = Toggle Peripheral   2 = Function Specific Data   3 = Special Operation Toggle   4 = Conveyor Request 5 = Dummy Error Trigger | 4 |
| 3 | Status | Short | When Flag = 1  Status is 0-15 as a binary pattern (e,g 0010) | 1 |
| 4 | Struct | String | When Flag = 2 Arrays of data in form of For Ink Printing X000.000Y000.000Z000.000HB100  For Cake Decoration X000.000Y000.000Z000.000A000.00 | 8-32 |
| 5 | Flag | Bool | When Flag = 3 0 = Halt 1 = Shutdown | 1 |
| 6 | Error | String | "Blocked Ink Ejector" | Max 75 |  

##### RobotStudio -> MATLAB 
| Field | Field Name | Field Type | Description | Binary Bytes |
|:-----:|:----------:|:----------:|:-------------------------------------------------------------------------------------------------------------------:|:------------:|
| 1 | Header | Char | "RS" | 2 |
| 2 | Flag | Int | 0 = Peripheral Status Update 1 = Program Operation 2 = Tool Speed 3 = Error Status 4 = Conveyor Movement Completed  | 4 |
| 3 | Status | Short | When Flag = 0 Status is 0-15 as a binary pattern (e,g 0010) | 1 |
| 4 | Flag | Int | When Flag = 1 0 1 2 3 4 | 4 |
| 5 | Flag | Int | When Flag = 2 Tool Speed Either 50 or 100 | 4 |
| 6 | Error | Char | When Flag = 3 0-7 Binary Bit Pattern | 1 |
| 7 |  -  | String | Error string E.g "Conveyor Empty, please refill blocks" | Max 75 |
