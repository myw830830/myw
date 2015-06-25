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
# Created: Steven Mu, 2014-04-08
# Changes: Initial version
# 

set collectionDate  [lindex $::argv 0]
set logFileList ""
set outputFile [open "RBS_SW_Version_Report.csv" "w"]
set itemCounter 0

puts $outputFile "Item,RNC,Site,SW Version,Ever upgraded"

# Start to open RBS log files for alarm statistic
foreach myFile [glob -nocomplain *] {
  set postName [string trim [lindex [split $myFile "."] 1]]
  if {$postName!="" && $postName=="log"} {
    lappend logFileList $myFile
  }
}
#puts "logFileList=$logFileList"
foreach logFile $logFileList {
  set content [read [open $logFile "r"]]
  set lostConnectionFlag 0
  set everUpgradedFlag 0
  set loadedSW ""
  set rbsName [string trim [lindex [split $logFile "."] 0]]
  incr itemCounter  
  
  # Parsing and storing raw data from input log file
  foreach line [split $content "\n"] {
    set line [string trim $line "\r"]
    set line [string trim $line " "]
	if {$line != "" && [regexp -nocase "Checking ip contact...Not OK" $line] } {
	  set lostConnectionFlag 1
	  #puts "lostConnectionFlag=$lostConnectionFlag" 
	  break
	} elseif {$line != "" && [regexp {.*SubNetwork=Rnc([0-9]+),} $line ignore rncNum] } {
	  #puts "rncNum=$rncNum" 
    } elseif {$line != "" && [regexp {^Executing:\s+[A-Za-z0-9\/\\._\%-]+\s+[A-Za-z0-9\/\\._\%-]+\s+([A-Za-z0-9\/\\._\%-]+)} $line ignore loadedSW] } {	  
	  #puts "loadedSW=$loadedSW" 
    } elseif {$line != "" && [regexp -nocase "CXP9021719_R5D/1" $line] } {	
      set everUpgradedFlag 1	
	  #puts "loadedSW=$loadedSW" 
    } elseif {$line != "" && [regexp -nocase "CXP9023078_R3E06" $line] } {	
      set everUpgradedFlag 1	
	  #puts "loadedSW=$loadedSW" 
    }
  }

  if {$lostConnectionFlag} {
    puts $outputFile "$itemCounter,NA,$rbsName,No conection,No connection"  
  } elseif {$everUpgradedFlag} {
    puts $outputFile "$itemCounter,Rnc$rncNum,$rbsName,$loadedSW,Yes"  
  } else {
    puts $outputFile "$itemCounter,Rnc$rncNum,$rbsName,$loadedSW,No"  
  }
}
puts "Please find the detailed report in file RBS_SW_Version_Report.csv."
