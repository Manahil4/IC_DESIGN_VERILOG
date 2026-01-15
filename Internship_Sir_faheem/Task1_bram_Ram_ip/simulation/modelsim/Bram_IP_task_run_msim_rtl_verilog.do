transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/Internship_Sir_faheem/Task1_bram_Ram_ip {D:/Internship_Sir_faheem/Task1_bram_Ram_ip/Bram_IP_task.v}
vlog -vlog01compat -work work +incdir+D:/Internship_Sir_faheem/Task1_bram_Ram_ip {D:/Internship_Sir_faheem/Task1_bram_Ram_ip/Bram_Ram_ip.v}

