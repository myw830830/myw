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
# Created: Steven Mu, 2014-04-16
# Changes: Initial version
# 

set moDiffFileName [lindex $::argv 0]
set keyWordString [lindex $::argv 1]
set keyWordList [split $keyWordString ","]

puts "\nWelcome to use MoDiffFilter to filter your MO dump diff result file $moDiffFileName.csv :)\n"  

set content [read [open "$moDiffFileName.csv" r]]
append moDiffFileName "_Filtered.csv"
set outputFile [open "$moDiffFileName" "w"]
set startFlag 0
set addinFlag 1

# Parsing and storing raw data from input file
foreach line [split $content "\n"] {
  set addinFlag 1
  set line [string trim $line "\r"]
  set line [string trim $line " "]
  if {[regexp -nocase -- "MO;Attribute;" $line]} {
    set startFlag 1
  }
  foreach keyWord $keyWordList {
    if {[regexp -nocase -- $keyWord $line]} {
	  set addinFlag 0
	  break
	} else {
      continue
	}
  }
  if {$startFlag && $addinFlag} {
  	  regsub -all "," $line ">" line
	  regsub -all ";" $line "," line
	  puts $outputFile $line
  }
}
puts "\nFiltered MO dump diff result file has been generated, please find it as $moDiffFileName :)\n"  