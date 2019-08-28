
invoke2 -entry caplog_init -format void
invoke2 -entry capproc_init_root -format int -int1 66559

# Add capproc pgraph dump to system dump service
sysdmp_add -source capproc_pgraph -save capproc_save_pgraph_status
