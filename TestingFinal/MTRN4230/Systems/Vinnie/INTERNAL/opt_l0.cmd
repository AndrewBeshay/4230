
ifvc -label VC_SKIP_DL1
iomgrinstall -entry DNLEFBC -name /DNLEFBC -errlabel ERROR_DLFBC

creat -name /DNLEFBC/DNLE_PCI1: -pmode 0 -errlabel ERROR_DLFBC
task -slotname DLread1 -entp read_ts -pri 72 -vwopt 0x1c -stcks 15000 -nosync -auto

readparam -devicename /DNLE_PCI1:/bus_read -rmode 1 -buffersize 100

# Add DeviceNet Lean to system dump service
sysdmp_add -show dnle_sysdmp

goto -label VC_SKIP_DL2 

#VC_SKIP_DL1
creat -name /simfbc/DNLE_PCI1: -pmode 0

#VC_SKIP_DL2
#ERROR_DLFBC
