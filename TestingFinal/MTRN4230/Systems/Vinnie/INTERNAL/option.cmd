
sysdefs -logmem 1500000

task -path ./hpbin/hipts \
-slotname ltdis -slotid 35 -pri 110 -vwopt 0x1c -stcks 16000 \
-entp ltdists_main -auto

task -path ./hpbin/hipts \
-slotname ltdis2 -slotid 53 -pri 110 -vwopt 0x1c -stcks 16000 \
-entp ltdists_main -auto
