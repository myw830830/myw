set nFlag  [lindex $::argv 0]
if {$nFlag == "-n"} {
  puts "\n~~欢迎使用本软件查看您本月考勤记录的总结呦，亲~~\n"  
} else {
  puts "\n~~欢迎使用本软件查看您本月考勤异常检测结果呦，亲~~"
  puts "\n~~如发现异常情况别忘了及时跟室主任补假呦：）~~\n"
}
set content [read [open 本月考勤记录.txt]]
set currentYear ""
set currentMonth ""
set signedDaysList ""
array set dateArray ""
array set dateCheckArray ""
array set monthDays { 01 31 02 28 03 31 04 30 05 31 06 30 07 31 08 31 09 30 10 31 11 30 12 31 }

# Parsing and storing raw data
foreach line [split $content "\n"] {
  set line [string trim $line "\r"]
  set line [string trim $line " "]
  if {$line != ""} {
    set signedTimeList [split $line " "]
    set signedDate [string trim [lindex $signedTimeList 4]]
    set signedTime [string trim [lindex $signedTimeList 5]]
	if {$currentYear == "" || $currentMonth == ""} {
	  set currentYear [lindex [split $signedDate "-"] 0]
	  set currentMonth [lindex [split $signedDate "-"] 1]
	}
    lappend signedDaysList [lindex [split $signedDate "-"] 2]	
	
	set signedDateSecond [clock scan $signedDate -format "%Y-%m-%d"]	
	set signedTimeSecond [clock scan $signedTime -format "%H:%M:%S"]	    

	if {![info exist dateArray($signedDateSecond)]} {
      set dateArray($signedDateSecond) $signedTimeSecond
    } else {
      lappend dateArray($signedDateSecond) $signedTimeSecond
    }
  }
}

# Missing signed during working days checking
set currentMonthDays ""
foreach {mon days} [array get monthDays] {
  #puts "$mon -> $days"
  if {$mon == $currentMonth} {
    set currentMonthDays $days
  }  
}

set signedDaysList [lsort -unique $signedDaysList]  
for {set i 1} {$i < [expr $currentMonthDays + 1]} {incr i} {
  set day [format "%02d" $i]
  if {[lsearch $signedDaysList $day] == -1} {    
	set unsignedDateSecond [clock scan "$currentYear-$currentMonth-$day" -format "%Y-%m-%d"]
	set formatUnsignedDate [clock format $unsignedDateSecond -format "%Y-%m-%d %a" -locale zh_cn]
	set unsignedDay [clock format $unsignedDateSecond -format "%a"]
	if {$unsignedDay != "Sat" && $unsignedDay != "Sun"} {
	  # “0” means there is no signed record in the working day
	  set dateCheckArray($unsignedDateSecond) 0	   
	}
  }
}

# Signed time checking for each day
set nineClock [clock scan "09:00:00" -format "%H:%M:%S"]
set sixteenAndHalf [clock scan "16:30:00" -format "%H:%M:%S"]
set twelveAndHalf [clock scan "12:30:00" -format "%H:%M:%S"]

foreach date [array names dateArray] {
  if { [llength $dateArray($date)] < 2 } {
    # “1” means there is only 1 signed record in the working day 
	set onlySignedTime $dateArray($date)
    set dateCheckArray($date) 1 
	lappend dateCheckArray($date) $onlySignedTime
	if {$onlySignedTime < $twelveAndHalf && $onlySignedTime > $nineClock} {
	  # Arrived office too late on the day
	  lappend dateCheckArray($date) "late"      
	} elseif {$onlySignedTime > $twelveAndHalf && $onlySignedTime < $sixteenAndHalf} {
      # Left office too early on the day	  
	  lappend dateCheckArray($date) "early"	  
	} else {
	  # Arrive or Left office at proper time on the day	  
	  lappend dateCheckArray($date) "normal"
	}
  } else {
    # Calculating the working interval of the working day
    set signedTimeList [lsort $dateArray($date)]
	set earliestRecord [lindex $signedTimeList 0]
	set latestRecord [lindex $signedTimeList end]
    set dateCheckArray($date) 2
	lappend dateCheckArray($date) [expr $latestRecord - $earliestRecord]  
	
	# Validation for late arriving and early leaving
	if {$earliestRecord > $nineClock} {
	  # Arrived office too late on the day
      lappend dateCheckArray($date) "late"
      lappend dateCheckArray($date) $earliestRecord	  
	} elseif {$latestRecord < $sixteenAndHalf} {
	  # Left office too early on the day	  
	  lappend dateCheckArray($date) "early"
	  lappend dateCheckArray($date) $latestRecord
	} else {
	  # Arrive & Left office at proper time on the day	  
	  lappend dateCheckArray($date) "normal"
	}	
  }
}

# Print the checking result of each day to user
set sortedDateList [lsort [array names dateCheckArray]]
foreach date $sortedDateList {
  set formatDate [clock format $date -format "%Y年%m月%d日 %a" -locale zh_cn]
  set dateCheckList $dateCheckArray($date)
  if { [lindex $dateCheckList 0] == 0 } {
    puts "$formatDate  ！！此工作日没有刷卡记录！！\n" 
  } elseif { [lindex $dateCheckList 0] == 1 } {
    set onlySignedTime [clock format [lindex $dateCheckArray($date) 1] -format "%H点%M分%S秒"]
    puts "$formatDate  ！！仅刷卡一次于 $onlySignedTime！！\n"
	switch -- [lindex $dateCheckList 2] {
      "late" {
        puts "$formatDate  ！！此工作日唯一刷卡记录 $onlySignedTime 晚于早上9点！！\n"
      }
      "early" {      
        puts "$formatDate  ！！此工作日唯一刷卡记录 $onlySignedTime 早于下午16点半！！\n"
      }
	  "normal" {
	    if { $nFlag=="-n" } {
	      puts "$formatDate  此工作日没有迟到早退情况\n"
		}
      }
    }
  } elseif { [lindex $dateCheckList 0] == 2 } {
    switch -- [lindex $dateCheckList 2] {
      "late" {
        puts "$formatDate  ！！此工作日最早刷卡记录 [clock format [lindex $dateCheckArray($date) 3] -format "%H点%M分%S秒"] 晚于早上9点！！\n"
      }
      "early" {      
        puts "$formatDate  ！！此工作日最晚刷卡记录 [clock format [lindex $dateCheckArray($date) 3] -format "%H点%M分%S秒"] 早于下午16点半！！\n"
      }
	  "normal" {
	    if { $nFlag=="-n" } {
	      puts "$formatDate  此工作日没有迟到早退情况\n"
		}
      }
    }
    if {[lindex $dateCheckList 1] < [expr 9*60*60] } {
      puts "$formatDate  ！！刷卡间隔小于9小时，总计 [clock format [expr [lindex $dateCheckList 1]-7*60*60] -format "%H小时%M分%S秒"]！！\n"
	} elseif { $nFlag=="-n" } {
      puts "$formatDate  刷卡间隔正常，总计 [clock format [expr [lindex $dateCheckList 1]-7*60*60] -format "%H小时%M分%S秒"]\n"  
    }
  } 
} 