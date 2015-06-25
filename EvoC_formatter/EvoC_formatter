#!/bin/expect

#
# COPYRIGHT
# ---------
# Copyright (C) 2008 by
# Ericsson AB
# SWEDEN
# The program may be used and/or copied only with the written
# permission from Ericsson AB, or in accordance with the terms
# and conditions stipulated in the agreement/contract under which
# the program has been supplied.
# All rights reserved.
# 
# REVISION HISTORY
# ----------------
#
# Created: Steven Mu, 2013-12-30
# Changes: Initial version
# 

############################################################
# Private processes
############################################################
proc get_cli_argument {search {var_ref ignore}} {
  upvar $var_ref variable2set
  set index [lsearch $::argv "$search"]
  if {$index!=-1} {
    incr index
    set variable2set [lindex $::argv $index ]
    return 1
  } else {
    return 0
  }
}

proc getBoardInfo { telnet_spawn_id smn apn } {
	#puts "getBoardInfo: ENTER $smn $apn"
	global timeout target_timeout dollar_prompt board_info
	global noboard_indicator
	set timeout_indicator "TIMEOUT99"

	#set spawn_id $telnet_spawn_id
	set result ""
	expect "*"

	set old_timeout $timeout
	set timeout $target_timeout

	
	if {[lsearch $board_info(node,smns) $smn] == -1} {
		lappend board_info(node,smns)  $smn
		set board_info(node,$smn,apns) ""
	}
	if {[lsearch $board_info(node,$smn,apns) $apn] == -1} {
		lappend board_info(node,$smn,apns) $apn
		set board_info(node,$smn,$apn)     ""
	}

	sleep 1
    set ret_val ok

	send -i $telnet_spawn_id "hwpid $smn $apn\r"
	
	expect {
		-i $telnet_spawn_id "Welcome to OSE" {
			send_user "ERROR : Restart message captured! Exiting!\n"
			exit -1
		}
		-i $telnet_spawn_id -re "Plug-in Unit Product Name: (\[^\r\]*)\r\n" {
			set board_info(node,$smn,$apn,name) [string trim $expect_out(1,string)]
			#send_user "\nGot 1'$expect_out(1,string)'\n"
			exp_continue
		}
		-i $telnet_spawn_id -re "Plug-in Unit Product No: (\[^\r\]*)\r\n" {
			set board_info(node,$smn,$apn,no) [string trim $expect_out(1,string)]
			#send_user "\nGot 2'$expect_out(1,string)'\n"
			exp_continue
		}
		-i $telnet_spawn_id -re "Plug-in Unit Product rev: (\[^\r\]*)\r\n" {
			set board_info(node,$smn,$apn,rev) [string trim $expect_out(1,string)]
			#send_user "\nGot 3'$expect_out(1,string)'\n"
			exp_continue
		}
		-i $telnet_spawn_id -re "Plug-in Unit Product Date: (\[^\r\]*)\r\n" {
			set board_info(node,$smn,$apn,date) [string trim $expect_out(1,string)]
			#send_user "\nGot 4'$expect_out(1,string)'"
			exp_continue
		}
		-i $telnet_spawn_id -re "Plug-in Unit Product Serial: (\[^\r\]*)\r\n" {
			set board_info(node,$smn,$apn,serial) [string trim $expect_out(1,string)]
			#send_user "\nGot 5'$expect_out(1,string)'\n"
			send_user "$board_info(node,$smn,$apn,name) $board_info(node,$smn,$apn,no) $board_info(node,$smn,$apn,rev) found in $smn:$apn\n"
			set ret_val ok
			exp_continue
		}
		-i $telnet_spawn_id -re "Error in pid server" {
			set board_info(node,$smn,$apn,name)   "No or wrong board"
			set board_info(node,$smn,$apn,no)     "No or wrong board"
			set board_info(node,$smn,$apn,rev)    "No or wrong board"
			set board_info(node,$smn,$apn,date)   "No or wrong board"
			set board_info(node,$smn,$apn,serial) "No or wrong board"

			if {$apn == 0 || $apn == 1 || $apn == 2 || $apn == 27} {
				set CMXBCommand "getAttrObj slot -d "
				set productNo ""
				if {$apn == 0} {
					set apn 28
				}
				append CMXBCommand [format "%02d" $smn] [format "%02d" $apn] 00 \r
				
				#Because there is a $ left in the buffer, which will affect the regexp in the follow step. To avoid that we use expect * to give up the buffer.
				expect "*"

				send $CMXBCommand
				sleep 1
				if {$apn == 28} {
					set apn 0
				}
				expect {
					"Welcome to OSE" {
						send_user "ERROR : Restart message captured! Exiting!\n"
						exit -1
					}
					-re "Request to get attribute for piu failed" {
						send_user "Board not found in $smn:$apn\n"
						set ret_val $noboard_indicator
					}
					-re {Product No([^\r]*)\t([^\r]*)\r\n} {
						set productNo [join $expect_out(1,string) {}]
						set board_info(node,$smn,$apn,no) $productNo 
						set board_info(node,$smn,$apn,rev) [string trim $expect_out(2,string)]
						exp_continue
					}
					-re {Product Name([^\r]*)\r\n} {
						set board_info(node,$smn,$apn,name) [string trim $expect_out(1,string)]
						exp_continue
					}
					-re {Product Date([^\r]*)\r\n} {
						set board_info(node,$smn,$apn,date) [string trim $expect_out(1,string)]
						if { $board_info(node,$smn,$apn,date) == ""} {
							set board_info(node,$smn,$apn,date) "NA"
						}
						exp_continue
					}
					-re {Product Ser. No([^\r]*)\r\n} {
						set board_info(node,$smn,$apn,serial) [string trim $expect_out(1,string)]
						if { $board_info(node,$smn,$apn,serial) == ""} {
							set board_info(node,$smn,$apn,serial) "NA"
						}
						send_user "$board_info(node,$smn,$apn,name) $board_info(node,$smn,$apn,no) $board_info(node,$smn,$apn,rev) found in $smn:$apn\n"
						set ret_val ok				
					}
					-re "Unknown command 'getAttrObj'" {
						send_user "getAttrObj piu command does not work in forced backup, i.e. if core EPB has been restarted with reload --.\nYou can get the information of this board manually\n"
						set ret_val $noboard_indicator
					}
					-re "Unknown command" {
						send_user "\n\nUnknown command.\n\n"
						set ret_val $noboard_indicator
					}
					timeout {
						send_error "Timeout while for waiting for '$CMXBCommand'.\n"
						set ret_val $noboard_indicator
					}
				}
			} else {
				send_user "Board not found in $smn:$apn\n"
				set ret_val $noboard_indicator
			}
			exp_continue
		}
		-i $telnet_spawn_id -re "Unknown command" {
			send_user "\n\nUnknown command.\n\n"
			set ret_val $noboard_indicator
		}
		-i $telnet_spawn_id "$dollar_prompt" { 
			#puts "got prompt $smn:$apn"
		}
		-i $telnet_spawn_id timeout {
			send_error "Timeout while for waiting for 'hwpid $smn $apn'.\n"
			send_error "hwpid command does not work in forced backup, i.e. if core EPB has been restarted with reload --.\n"
			set ret_val $noboard_indicator
		}
	}
  return $ret_val
  #puts "getBoardInfo: RETURN"
}


############################################################
# EvoC formatter starts here
############################################################

set dollar_prompt "\\$"
set sql_prompt "SQL>"
set timeout 20
set boards(node,rows) ""
set board_info(node,smns) ""
set target_timeout    20
set timeout_indicator "TIMEOUT99"
set error_indicator   "ERROR99"
set noboard_indicator "NOBOARD99"

if { [get_cli_argument "-ip" node_ip]} {

} else {
    puts "Error! -ip is missing.\n"
	puts "Usage: ./EvoC_formatter -ip 10.185.65.21 -user rnc -pw rnc -rncType 8200"
    exit -1
}

if { [get_cli_argument "-user" node_user]} {
    
} else {
    puts "Error! -user is missing."
	puts "Usage: ./EvoC_formatter -ip 10.185.65.21 -user rnc -pw rnc -rncType 8200 -subracks 3"
    exit -1
}

if { [get_cli_argument "-pw" node_pw] } {
    
} else {
    puts "Error! -pw is missing."
	puts "Usage: ./EvoC_formatter -ip 10.185.65.21 -user rnc -pw rnc -rncType 8200 -subracks 3"
    exit -1
}

if { [get_cli_argument "-rncType" rnc_type] } {
    
} else {
    puts "Error! -rncType is missing."
	puts "Usage: ./EvoC_formatter -ip 10.185.65.21 -user rnc -pw rnc -rncType 8200 -subracks 3"
    exit -1
}

if { [get_cli_argument "-subracks" subrack_number] } {
    
} else {
    puts "Error! -subracks is missing."
	puts "Usage: ./EvoC_formatter -ip 10.185.65.21 -user rnc -pw rnc -rncType 8200 -subracks 3"
    exit -1
}

spawn telnet $node_ip
set telnet_spawn_id spawn_id
sleep 2

expect {
  -re "sername:" {
    send "$node_user\r"
    exp_continue
  }
  -re "assword:" {
    send "$node_pw\r"
    exp_continue
  }
  -re "$dollar_prompt" {
    puts "LOGIN: Connected to target via $node_ip !\n"
  }  
  -re "ogin failed" {
    puts "Please check if you input the correct username and password !\n"
    exit -1
  }  
  default {
    send "exit\r"
    puts "Warning: unexpected response from node; aborting...\n"
  }
}

send_user "Starting board scan...\n"

for {set apn 0} {$apn < 28} {incr apn} {
  getBoardInfo $telnet_spawn_id 0 $apn
}

# Get slot for SCB/SXB board, used to calculate subrack SMN
set scb_number 0
set sxb_number 0
set scxb_number 0
set scxb_apns ""

foreach apn $board_info(node,0,apns) {
  if {[string first "SCB" $board_info(node,0,$apn,name)] != -1} {
    incr scb_number
    if {$apn%2 == 0} {
      lappend scxb_apns $apn
    }
  }
  if {[string first "SXB" $board_info(node,0,$apn,name)] != -1} {
    incr sxb_number
    if {$apn%2 == 0} {
      lappend scxb_apns $apn
    }
  }
  if {[string first "SCXB" $board_info(node,0,$apn,name)] != -1} {
    incr scxb_number
    if {$apn%2 == 1} {
      lappend scxb_apns $apn
    }
  }
}
if {$scb_number == 0 && ($scxb_number == 0 || $rnc_type != "8200")} {
  # Ask the user what to do if no SCB-board was found.
  send_user "Warning! Did not find any SCB boards.\n Do you want to continue and save this scanning? "
  expect_user -re .*
  set timeout -1
  expect_user -re "(.*)\n"
  
  if {[regexp -nocase -- "^y" $expect_out(1,string)]} {
    send_user "Continuing.\n"
    send_user "Scanning finished."
    return
  } else {
    send_user "Bye\n"
    exit -1
  }
}

#Scanning the extension subracks
set smnList ""
for {set i [expr $subrack_number-1]} {$i > 0} {incr i -1} {
  lappend smnList $i
}
foreach smn [lsort -integer $smnList] {
	set missing_scb_counter 0
	for {set apn 0} {$apn < 28} {incr apn} {
		set result [getBoardInfo $telnet_spawn_id $smn $apn]
		if {$result == $noboard_indicator && ($apn == 0 || $apn == 1)} {
			incr missing_scb_counter
		}
		if {$apn > 0 && $missing_scb_counter == 2} {
			send_user "There is no subrack on this SMN\n"
			break
		}
	}
	send_user "\n"      
}
send_user "Scanning Finished.\r"

if {$rnc_type != "8200"} {
  send_user "Starting GPB board formatting...\r"
} else {
  send_user "Starting EPB board formatting...\r"
}
foreach smn_index $board_info(node,smns) {
  foreach apn_index $board_info(node,$smn_index,apns) {
    set formatFlag 0
    switch -exact --  $rnc_type {
      "3810" {
        if {[string first "GPB" $board_info(node,$smn_index,$apn_index,name)] != -1 && ( $smn_index != 0 || $apn_index != 10 ) } {
          set formatFlag 1
        } else {
		  continue
		}
      }
      "3820" {
        if {[string first "GPB" $board_info(node,$smn_index,$apn_index,name)] != -1 && ( $smn_index != 0 || $apn_index != 5 ) } {
          set formatFlag 1
		} else {
		  continue
        }
      }
      "8200" {
        if {[string first "EPB" $board_info(node,$smn_index,$apn_index,name)] != -1 && ( $smn_index != 0 || $apn_index != 3 ) } {
          set formatFlag 1
		} else {
		  continue
		}
      }
	}
    set lhsh_name [join [list [format "%02d" $smn_index] [format "%02d" $apn_index] [format "%02d" 0]] ""]
    if {$formatFlag} {        
      set command "lhsh $lhsh_name formathd /d"
      send "$command\r"
      expect {
        -re "formathd /d\r(.*)Continue"  {
          send "y\r"
          exp_continue
        }
        -re "Formatting Hard Disk(.*)$dollar_prompt" {
          send_user "\t(ddrive_format) Formatting of /d successfully done for board : $board_info(node,$smn_index,$apn_index,name) in $smn_index:$apn_index\n"
        }
        -re "All data on volume will be destroyed. Continue(.*)" {
          send "y\r"
          exp_continue
        }
        -re "You are in basic. Continue(.*)" {
          send "y\r"
          exp_continue
        }
        timeout {
          send_user "time out\n"
        }
      }
    }
  }
}
if {$rnc_type != "8200"} {
  send_user "All GPB boards formatted successfully.\r"
} else {
  send_user "All EPB boards formatted successfully.\r"
}
send "exit\r"