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
set coutingDays  [lindex $::argv 1]
set logFileList ""
set outputFile [open "RX_Diversity_Count.csv" "w"]

set collectionDateSecond [clock scan $collectionDate -format "%Y-%m-%d"]
set collectionDateList $collectionDate
set itemCounter 0
set alarmSiteCounter 0

for {set i 1} {$i < [expr $coutingDays + 1]} {incr i} {
  set collectionDateSecond [expr $collectionDateSecond - 86400]
  set tempDate [clock format $collectionDateSecond -format "%Y-%m-%d"]
  lappend collectionDateList $tempDate  
}
set collectionDateList [lsort -unique $collectionDateList]
set collectionDateString [join $collectionDateList ","]
#puts "collectionDateString=$collectionDateString\n"

puts $outputFile "Item,Site,$collectionDateString,Total,SW Version"

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
  set totalCounter 0
  set loadedSW ""
  set rbsName [string trim [lindex [split $logFile "."] 0]]
  set lostConnectionFlag 0
  array set dateAlarmCountArray ""
  incr itemCounter  

  set firstDate ""
  set i 1
  
  # Parsing and storing raw data from input log file
  foreach line [split $content "\n"] {
    set line [string trim $line "\r"]
    set line [string trim $line " "]
    if {$line != "" && [regexp -nocase "Checking ip contact...Not OK" $line] } {
	  set lostConnectionFlag 1
	  #puts "lostConnectionFlag=$lostConnectionFlag" 
	  break
	} elseif {$line != "" && [regexp {^Executing:\s+[A-Za-z0-9\/\\._\%-]+\s+[A-Za-z0-9\/\\._\%-]+\s+([A-Za-z0-9\/\\._\%-]+)} $line ignore loadedSW] } {	  
    } elseif {[regexp {^([0-9]+\-[0-9]+\-[0-9]+)\s[0-9]+\:[0-9]+\:[0-9]+.*Carrier_RxDiversityLost} $line ignore date]} {
	  incr totalCounter
      if {$i==1} {
	    set firstDate $date
		set dateAlarmCountArray($date) $i
		incr i
	  } elseif {$date == $firstDate} {
	    set dateAlarmCountArray($date) $i
	    incr i
	  } elseif {$date != $firstDate} {
	    set i 1	
		set firstDate $date
        set dateAlarmCountArray($date) $i
        incr i
	  }
	}
  }
  set alarmCountString ""
  set noContactString ""
  set alarmCountList ""
  set noContactList ""
  set alarmFlag 0
  foreach collectionDate $collectionDateList {
    if {[array names dateAlarmCountArray -exact $collectionDate] != ""} {
      lappend alarmCountList $dateAlarmCountArray($collectionDate)
	  set alarmFlag 1
    } else {
	  lappend alarmCountList 0
	}
	
	lappend noContactList "No connection" 
  }
  set alarmCountString [join $alarmCountList ","]
  set noContactString [join $noContactList ","]
  if {$alarmFlag} {
	incr alarmSiteCounter
    puts $outputFile "$alarmSiteCounter,$rbsName,$alarmCountString,$totalCounter,$loadedSW"
  }  elseif {$lostConnectionFlag} {
  incr alarmSiteCounter
    puts $outputFile "$alarmSiteCounter,$rbsName,$noContactString,No connection,No connection"  
  } 
  unset dateAlarmCountArray
}
puts "\n$itemCounter sites statisticed in total, and $alarmSiteCounter sites were found Carrier_RxDiversityLost alarm in the log files.\n"
puts "Please find the detailed report in file RX_Diversity_Count.csv."
