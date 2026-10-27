# =========================================================
# Synchronous FIFO - OpenSTA Timing Analysis
# Technology: SKY130HD
# =========================================================

# 1. Read the SKY130HD timing library
read_liberty /home/vinith/OpenROAD-flow-scripts/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# 2. Read the mapped FIFO netlist
read_verilog results/sync_fifo_sky130.v

# 3. Link the top-level design
link_design sync_fifo

# 4. Read timing constraints
read_sdc constraints/sync_fifo.sdc

# 5. Report timing units
report_units

# 6. Report the five worst maximum-delay paths
report_checks -path_delay max -group_path_count 5

# 7. Report the five worst minimum-delay paths
report_checks -path_delay min -group_path_count 5

# 8. Report worst setup slack
report_worst_slack -max

# 9. Report worst hold slack
report_worst_slack -min

