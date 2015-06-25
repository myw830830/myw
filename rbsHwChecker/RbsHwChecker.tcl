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
# Created: Steven Mu, 2014-04-17
# Changes: Initial version
# 

set hwType2Check  [lindex $::argv 0]
set outputFileName "RBS_3K_$hwType2Check-Type_Summary"
set outputFile [open $outputFileName.csv "w"]
set logFileList ""
set itemCounter 0
set raxR2List {1 2 3 4 5 6 7 8 10 11 12 13}
set raxR2eList {14 15}
set cap128CeList {1 4 10 11 14}
set cap64CeList {2 5 7 12 15}
set cap32CeList {3 6 8 13}
set raxType "Unknown"
set capacityCe "Unknow"

puts $outputFile "RNC,Site,Board,Board Type,Capacity_CE,Product Number,Revision,SMN,APN"

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
  set rbsName [string trim [lindex [split $logFile "."] 0]]
    
  # Parsing and storing raw data from input log file
  foreach line [split $content "\n"] {
    set line [string trim $line "\r"]
    set line [string trim $line " "]
	
	#Connected to 10.247.150.205 (SubNetwork=STM_R,SubNetwork=Rnc07,MeContext=3130_KatongExchangeII,ManagedElement=1)
	if {$line != "" && [regexp {.*SubNetwork=Rnc([0-9]+),} $line ignore rncNum] } {
	  #puts "rncNum=$rncNum" 
	}
	# 0   4  RAX       OFF    ON     16HZ    ROJ1192187/14  R1D    B117247509 20100521  
    if {$line != "" && [regexp {.*([0-9]+)\s+([0-9]+)\s+RAX\s+[A-Za-z0-9]+\s+[A-Za-z0-9]+\s+[A-Za-z0-9]+\s+([A-Za-z0-9\/\%]+)\s+([A-Za-z0-9\/\%]+)} $line ignore smn apn prodNum rev] } {	  
      incr itemCounter
	  set prodNumPost [string trim [lindex [split $prodNum "\/"] 1]]
	  #puts "prodNumPost=$prodNumPost"
      if {[lsearch $raxR2eList $prodNumPost] != -1} {	
	    set raxType "R2e"
	  } elseif {[lsearch $raxR2List $prodNumPost] != -1} {
	    set raxType "R2"
	  }
	  if {[lsearch $cap128CeList $prodNumPost] != -1} {	
	    set capacityCe "128"
	  } elseif {[lsearch $cap64CeList $prodNumPost] != -1} {
	    set capacityCe "64"
	  } elseif {[lsearch $cap32CeList $prodNumPost] != -1} {
	    set capacityCe "32"
	  }
	  puts $outputFile "Rnc$rncNum,$rbsName,RAX,$raxType,$capacityCe,$prodNum,$rev,$smn,$apn"
	}
  }
}
puts "Found $itemCounter RAX boards, please find the detailed report in file $outputFileName.csv."
