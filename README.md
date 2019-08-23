# GUI

The complete front end - backend for the robot studio programmers as well as the image processing for MATLAB  

## How to run  

Run the file `Start.mlapp`  

## Network Protocol    

| Field | Field Name | Field Type | Description | Binary Bytes |
|:-----:|:----------:|:----------:|:-------------------------------------------------------------------------------------------------------------------:|:------------:|
| 1 | Header | Char | "RS" | 2 |
| 2 | Flag | Int | 0 = Peripheral Status Update 1 = Program Operation 2 = Tool Speed 3 = Error Status 4 = Conveyor Movement Completed  | 4 |
| 3 | Status | Short | When Flag = 0 Status is 0-15 as a binary pattern (e,g 0010) | 1 |
| 4 | Flag | Int | When Flag = 1 0 1 2 3 4 | 4 |
| 5 | Flag | Int | When Flag = 2 Tool Speed Either 50 or 100 | 4 |
| 6 | Error | Char | When Flag = 3 0-7 Binary Bit Pattern | 1 |
| 7 |  -  | String | Error string E.g "Conveyor Empty, please refill blocks" | Max 75 |
