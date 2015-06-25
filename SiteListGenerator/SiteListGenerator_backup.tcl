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
# Updated: Steven Mu, 2014-04-07
# Changes: Add new functions to generate SMO selection file based on CSV 
#
# Created: Steven Mu, 2014-04-04
# Changes: Initial version
# 

set selFileNameFull  [lindex $::argv 0]
set selFileGenerate  [lindex $::argv 1]

if {$selFileGenerate == "selGen"} {
  puts "\nWelcome to use SiteListGenerator to generate your SMO selection files :)\n"  
} else {
  puts "\nWelcome to use SiteListGenerator to generate your site list Excel & Mobatch files :)\n"  
}

set content [read [open $selFileNameFull]]
array set siteArray ""
set i 1

# Parsing and storing raw data from input file
foreach line [split $content "\n"] {
  set line [string trim $line "\r"]
  set line [string trim $line " "]
  if {$line != ""} {
    if {$selFileGenerate == "selGen"} {
      # User choose to generate SMO site selection file from CSV file.
	  if {$i == 1} {
	    incr i
	    continue
	  }
	  
	  # line: RNC08,4500_Lengkok_Bahru_Blk55,FAJ1211320; SRB on HSDPA,1000,CXC4020025,Feature,N/A,N/A,Mar 16 2014,May 23 2014,NEVER_USED,
      set siteInfoList [split $line ","]
	  # siteRncName: RNC08 
      set siteRncName [string trim [lindex $siteInfoList 0]]
	  # siteNoNameRaw: 4500_Lengkok_Bahru_Blk55 
      set siteNoNameRaw [string trim [lindex $siteInfoList 1]]
	
	  if {![info exist siteArray($siteNoNameRaw)]} {
        set siteArray($siteNoNameRaw) $siteRncName
      } else {
        #lappend siteArray($siteNoNameRaw) $siteRncName
      }
    } else {
	  # User choose to generate Excel & MObatch files from SMO site selection file.
	
      # line: SubNetwork=STM,SubNetwork=Rnc15,MeContext=83463_JurongWestBlk461,ManagedElement=1
      set siteInfoList [split $line ","]
	  # siteNoNameRaw: MeContext=83463_JurongWestBlk461 
      set siteNoNameRaw [string trim [lindex $siteInfoList 2]]
	
      set siteNoNameRawList [split $siteNoNameRaw "="]
	  # siteNoName: 83463_JurongWestBlk461 
      set siteNoName [string trim [lindex $siteNoNameRawList 1]]
	
	  set siteNoNameList [split $siteNoName "_"]
	  # siteNo: 83463 
      set siteNo [string trim [lindex $siteNoNameList 0]]
	  # siteName: JurongWestBlk461
	  set siteName [string trim [lindex $siteNoNameList 1]]
	
	  if {![info exist siteArray($siteNo)]} {
        set siteArray($siteNo) $siteName
      } else {
        #lappend siteArray($siteNo) $siteName
      }
    }
  }
}

#parray siteArray

# Generate ouput files from the filled array
if {$selFileGenerate == "selGen"} {
  # User choose to generate SMO site selection file from CSV file.
  
  # selFileNameFull: License_audit.csv
  set selFileNameList [split $selFileNameFull "."]
  # selFileName: License_audit
  set selFileName [string trim [lindex $selFileNameList 0]]

  puts "Generating SMO site selection file siteList_$selFileName.sel...\n"  
  set outputFile [open "$selFileName.sel" "w"]
  foreach key [array names siteArray] {
    puts $outputFile "SubNetwork=STM,SubNetwork=$siteArray($key),MeContext=$key,ManagedElement=1"
  }
  puts "Done.\n"
} else {
  # User choose to generate Excel & MObatch files from SMO site selection file.
  # parray siteArray

  # selFileNameFull: RNS15_6K_W13B.sel
  set selFileNameList [split $selFileNameFull "."]
  # selFileName: RNS15_6K_W13B
  set selFileName [string trim [lindex $selFileNameList 0]]

  puts "Generating Mobatch site list file siteList_$selFileName...\n"  
  set outputFile [open "siteList_$selFileName" "w"]
  foreach key [lsort -integer [array names siteArray]] {
    puts $outputFile "rbs$key"
  }
  puts "Done.\n"

  puts "Generating Excel site list file siteList_$selFileName.csv...\n" 
  set outputFile [open "siteList_$selFileName.csv" "w"]
  set i 1
  puts $outputFile "Item,RBS ID,Site Name"
  foreach key [lsort -integer [array names siteArray]] {
    puts $outputFile "$i,$key,$siteArray($key)"
    incr i
  }
  puts "Done.\n"
}

