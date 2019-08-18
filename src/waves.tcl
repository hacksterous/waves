#(c) 2015 Anirban Banerjee
#GPL version 3
#
set winTitle "Waves Editor v0.543"

#running variables
set CanvasMouseX [winfo rootx .]
set CanvasMouseY [winfo rooty .]
#config variables
set textLines 10
set prevcharpos 0
set charpos 0
set waveheight 20
set waveunitdelay 40
set waveTransitionTime 6
set signamecolwidth 100
set signameFont "Courier"
set menuFont "Cambria"
set signalwaveXoffset 15
set signalwaveYoffset 30
set signalwaveYspacing 15
set fontheightadjust 10
set arrowheight 2
set arrowlength 6
set datafontheightadjust [expr $waveheight/2]
set canvastextfontheightadjust 15
set tristatedatafontheightadjust [expr 1.6*$datafontheightadjust]
set prevwave {}
set hatchdistance 6
set signameFontsize 8
set datawidth 40
set bezheight 5
set bezwidth 8
set topline 1
set bottomline 10

proc drawsigwaves {line signame sigwaves sigdata} {
	global waveheight
	global waveunitdelay
	global signamecolwidth
	global signameFont
	global signalwaveXoffset
	global signalwaveYoffset
	global signalwaveYspacing
	global waveTransitionTime
	global prevwave
	global hatchdistance
	global signameFont
	global fontheightadjust
	global datafontheightadjust
	global canvastextfontheightadjust
	global tristatedatafontheightadjust
	global signameFontsize
	global datawidth
	global arrowheight
	global arrowlength
	global bezheight
	global bezwidth
	set enableGrid 0
	set topArrow 0
	set wavecount 0
	set prevwave {}
	.c delete "rectangle$line"
	.c delete "wave$line"
	.c delete "arrow$line"
	set noninvertedclockheight $waveheight
	set invertedclockheight 0
	set wavepointerdata ""
	set match ""
	
	if {$signame == "" && $sigwaves == ""} {
		.c create text [expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
			[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing)*$line - $waveheight] \
			-font {$signameFont 12} -width 9999 -anchor w -text $sigdata -tags "wave$line"
		return
	}

	set match {}
	regexp {(.*)\^(.*)} $sigwaves match sigwaves wavepointerdata
	if {$match != {}} {
		.c delete "wavepointertext$line"
		foreach {x0 y0 data} [split $wavepointerdata {,}] {
				#add some text
			if {$x0 == {} || $y0 == {}} {break}
			if {[string is integer $x0] && [string is integer $y0]} {
				set startx [expr $signamecolwidth + $signalwaveXoffset + $x0]
				set starty [expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line + $y0]
				.c create text $startx $starty -anchor w -text $data -tags "wavepointertext$line"
			}
		}
	} else {
		.c delete "wavepointertext$line"
	}
	set match {}
	regexp {(.*)\+(.*)} $sigwaves match sigwaves wavepointerdata
	if {$match != {}} {
		#puts "match found wavepointerdata = $wavepointerdata"
		.c delete wavepointerarrow$line
		foreach {x0 y0 x1 y1} [split $wavepointerdata {,}] {

			set x0 [string trim $x0]
			set y0 [string trim $y0]
			set x1 [string trim $x1]
			set y1 [string trim $y1]
			#puts "Coords are $x0 $y0 $x1 $y1"
			#if the whole arrow is complete, delete the arrowstart circle
			#only x0 might have some junk characters from the end of the line
			if {$y0 == {} && $x1 == {} && $y1 == {}} {.c delete wavepointerarrowstart$line}

			if {$x0 == {} || $y0 == {} ||$x1 == {} || $y1 == {}} {break}

			if {[string is integer $x0] && [string is integer $y0] && [string is integer $x1] && [string is integer $y1]} {
				set Dx  [expr $x1 - $x0]
				set Dy  [expr $y1 - $y0]
				#puts "Non zero Coords are $x0 $y0 $x1 $y1"

				set startx [expr $signamecolwidth + $signalwaveXoffset + $x0]
				set starty [expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line + $y0]

				.c create oval [expr $startx - 3] [expr $starty - 3] \
					[expr $startx + 3] [expr $starty + 3] -outline black -fill yellow -tags "wavepointerarrow$line"

				if {([expr abs($Dx)] > 1) && ([expr abs($Dy)] > 1) && ([expr abs($Dy / $Dx)] >= 0)} {
					set xx [expr $signamecolwidth + $signalwaveXoffset  + $x0 + $Dx/2]
					set yy [expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line + $y0 + $Dy/5]

					set xxx [expr $signamecolwidth + $signalwaveXoffset  + $x0 + 3*$Dx/4]
					set	yyy [expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line + $y0 + 4*$Dy/5]
					.c create line 	[expr $signamecolwidth + $signalwaveXoffset + $x0] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line + $y0] \
								$xx		$yy \
								$xxx	$yyy \
								[expr $signamecolwidth + $signalwaveXoffset + $x1] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line + $y1] \
							   	-tags wavepointerarrow$line -smooth true -arrow last

				} else {
					.c create line 	[expr $signamecolwidth + $signalwaveXoffset + $x0] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line + $y0] \
								[expr $signamecolwidth + $signalwaveXoffset + $x1] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line + $y1] \
							   	-tags wavepointerarrow$line -smooth true -arrow last
				}
			}
		}
	} else {
		.c delete "wavepointerarrow$line"
	}

	foreach unitwave [split $sigwaves {}] {
		#puts "executing foreach sigwaves ============= $sigwaves"
		#puts "==sigwaves is $sigwaves"
		#puts "==unitwave is $unitwave"
		#puts "==prevwave is $prevwave"

		#comment
		if {$unitwave == "#"} break
		if {$unitwave == "~"} {
			if  {$noninvertedclockheight != 0} {
				#current is non-inv, do inverted
				set noninvertedclockheight 0
				set invertedclockheight $waveheight
			} else {
				#current is inv, do non-inverted
				set noninvertedclockheight $waveheight
				set invertedclockheight 0
			}
			#puts "Found ~: noninvertedclockheight = $noninvertedclockheight, invertedclockheight = $invertedclockheight"
		}
		if {$unitwave == "|"} {
			set enableGrid 1
		} elseif {$unitwave == "!"} {
			set enableGrid 0
		}
		if {$enableGrid == 1} {
			.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * ($line - 1)] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line + $signalwaveYspacing] \
							-tags "wave$line" -stipple gray50
		}
		if {$unitwave == "/"} {
			.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount + 2*$waveunitdelay/5)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight - $bezheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount - $bezwidth + 2*$waveunitdelay/5)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount + $bezheight + 2*$waveunitdelay/5)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount + 2*$waveunitdelay/5)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line + $bezheight] \
							-tags "wave$line" \
							-smooth true

			.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount + 3*$waveunitdelay/5)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight - $bezheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount - $bezwidth + 3*$waveunitdelay/5)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount + $bezheight + 3*$waveunitdelay/5)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount + 3*$waveunitdelay/5)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line + $bezheight] \
							-tags "wave$line" \
							-smooth true

			incr wavecount 1
		} elseif {$unitwave == "<" || $unitwave == "-"} {
			#puts "++++unitwave is $unitwave"
			if {$unitwave == "<"} {
				.c create poly	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount + $arrowlength)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight - $arrowheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount + $arrowlength)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight + $arrowheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
							\
							-outline black -tags "wave$line"
			}
			.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
				[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
				\
				[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
				[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line" 

			set offset 6
			set datawidth $waveunitdelay
			#puts "++++SigData is $sigdata"
			set data [lindex $sigdata 0] 
			set sigdata [lrange $sigdata 1 end]
			#puts "++++++++++++++++++++SigData iswhite$sigdata"
			set offsetfound [regexp {(.*)\*([0-9]+)} $data match data offset]

			#puts "++++++++++++++ data is $data"
			if {$data != {}} {
				set arrowtext [.c create text [expr ($signamecolwidth + $signalwaveXoffset + $offset)] \
						[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing)*$line - $waveheight] \
						-font {$signameFont 8} -width 9999 -anchor w -text $data -tags "arrow$line"]
				.c create rectangle [.c bbox $arrowtext] -fill white -outline white -tags "rectangle$line"
				.c raise $arrowtext
			}
			incr wavecount 1
	
		} elseif {$unitwave == ">"} {
			#puts "++++unitwave is $unitwave"

			.c create poly	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount - $arrowlength)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight - $arrowheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount - $arrowlength)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight + $arrowheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
							\
							-outline black -tags "arrow$line"

		} elseif {$unitwave == "P" } {
			for {set i 0} {$i < 10} {incr i 2} {
			.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount + $waveunitdelay*$i/10)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $invertedclockheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount + $waveunitdelay*$i/10)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $noninvertedclockheight] -tags "wave$line" 

			.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount + $waveunitdelay*$i/10)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $noninvertedclockheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount + $waveunitdelay*($i+1)/10 )] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $noninvertedclockheight]  -tags "wave$line"

			.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount + $waveunitdelay*($i+1)/10)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $noninvertedclockheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount +  $waveunitdelay*($i+1)/10)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $invertedclockheight]  -tags "wave$line"

			.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount  + $waveunitdelay*($i+1)/10)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $invertedclockheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount  + $waveunitdelay*($i+2)/10)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $invertedclockheight]  -tags "wave$line"
			}
			incr wavecount 1
		} elseif {$unitwave == "c" || $unitwave == "p" || $unitwave == "C" || $unitwave == "k" || $unitwave == "K"} {
			if {$unitwave == "c"} {
				set risearrowtype "last"
				set fallarrowtype "none"
			} elseif {$unitwave == "C" || $unitwave == "K"} {
				set risearrowtype "last"
				set fallarrowtype "last"
			} elseif {$unitwave == "k"} {
				set risearrowtype "none"
				set fallarrowtype "last"
			} else {
				set risearrowtype "none"
				set fallarrowtype "none"
			}
			#puts "prevwave = $prevwave"
			if {$noninvertedclockheight > 0 || ($prevwave != "~" && $prevwave != "s")} {
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $invertedclockheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $noninvertedclockheight] -tags "wave$line" -arrow $risearrowtype
			}
			.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $noninvertedclockheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 0.5))] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $noninvertedclockheight]  -tags "wave$line"

			set datawidth $waveunitdelay
			set data [lindex $sigdata 0] 
			set sigdata [lrange $sigdata 1 end]
			set multfound [regexp {(.*)\*([0-9]+)} $data match data mult]
			if {$multfound == 1} {
				#puts "----mult found"
				set datawidth [expr $waveunitdelay*$mult]
			}
			.c create text [expr (2 + $signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
					[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing)*$line - $datafontheightadjust] \
					-font {$signameFont 8} -width [expr $datawidth] -anchor w -text $data -tags "wave$line"

			.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 0.5))] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $noninvertedclockheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 0.5))] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $invertedclockheight]  -tags "wave$line"  -arrow $fallarrowtype

			.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 0.5))] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $invertedclockheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $invertedclockheight]  -tags "wave$line"

			set data [lindex $sigdata 0] 
			set sigdata [lrange $sigdata 1 end]

			.c create text [expr (2 + $signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 0.5))] \
					[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing)*$line - $datafontheightadjust] \
					-font {$signameFont 8} -width [expr $datawidth] -anchor w -text $data -tags "wave$line"

			incr wavecount 1
		} elseif {$unitwave == "r"} {
			if {$prevwave == "x" || $prevwave == "X"} {
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount - $hatchdistance/3)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2 - $hatchdistance/3]  -tags "wave$line"

			} 
			if {$prevwave == "h" || $prevwave == "r"} {
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"

				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] -tags "wave$line"
			} elseif {$prevwave == "d" || $prevwave == "D"} {
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] -tags "wave$line"

				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"

			} elseif {$prevwave == "z" || $prevwave == "Z"} {
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] -tags "wave$line"
			} else {
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] -tags "wave$line"
			}
			.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"
			set datawidth $waveunitdelay
			set data [lindex $sigdata 0] 
			set sigdata [lrange $sigdata 1 end]
			set multfound [regexp {(.*)\*([0-9]+)} $data match data mult]
			if {$multfound == 1} {
				#puts "----mult found"
				set datawidth [expr $waveunitdelay*$mult]
			}
			regsub -all {\*\*} $data {\*} data
			.c create text [expr (2 + $signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
					[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing)*$line - $datafontheightadjust] \
					-font {$signameFont 8} -width [expr $datawidth - 2] -anchor w -text $data -tags "wave$line"

			incr wavecount 1

		} elseif {$unitwave == "h"} {
			if {$prevwave == "z" || $prevwave == "Z"} {
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] -tags "wave$line"

				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"
			} elseif {$prevwave == "l" || $prevwave == "f" || $prevwave == "P" || $prevwave == "c" || $prevwave == "p" || $prevwave == "C"} {
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"
			} elseif {$prevwave == "d" || $prevwave == "D"} {
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] -tags "wave$line"

				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"
			} else {
				if {$prevwave == "x" || $prevwave == "X"} {
					.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2]  -tags "wave$line"
					.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount + $hatchdistance/2)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2 - 1]  -tags "wave$line"

					.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount + $hatchdistance/2)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"
	
				}
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"
			}

			set datawidth $waveunitdelay
			set data [lindex $sigdata 0] 
			set sigdata [lrange $sigdata 1 end]
			set multfound [regexp {(.*)\*([0-9]+)} $data match data mult]
			if {$multfound == 1} {
				#puts "----mult found"
				set datawidth [expr $waveunitdelay*$mult]
			}
			regsub -all {\*\*} $data {\*} data
			.c create text [expr (2 + $signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
					[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing)*$line - $datafontheightadjust] \
					-font {$signameFont 8} -width [expr $datawidth - 2] -anchor w -text $data -tags "wave$line"

			incr wavecount 1

		} elseif {$unitwave == "f"} {
			if {$prevwave == "l" || $prevwave == "f"} {
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"

				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] -tags "wave$line"

				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"

			} elseif {$prevwave == "z" || $prevwave == "Z"} {
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] -tags "wave$line"


			} elseif {$prevwave == "x" || $prevwave == "X"} {
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2] -tags "wave$line"

				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] -tags "wave$line"
					
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"


			} else {
				if {$prevwave == "D" || $prevwave == "d"} {
					.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
									[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
									\
									[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
									[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"

					.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
									[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
									\
									[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount+1))] \
									[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] -tags "wave$line"

				}
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] -tags "wave$line"

				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"
			}

			set datawidth $waveunitdelay
			set data [lindex $sigdata 0] 
			set sigdata [lrange $sigdata 1 end]
			set multfound [regexp {(.*)\*([0-9]+)} $data match data mult]
			if {$multfound == 1} {
				#puts "----mult found"
				set datawidth [expr $waveunitdelay*$mult]
			}
			regsub -all {\*\*} $data {\*} data
			.c create text [expr (2 + $signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
					[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing)*$line - $datafontheightadjust] \
					-font {$signameFont 8} -width [expr $datawidth - 2] -anchor w -text $data -tags "wave$line"

			incr wavecount 1

		} elseif {$unitwave == "z" || $unitwave == "Z"} {

			if {$prevwave == "r" || $prevwave == "h"} {
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2]  -tags "wave$line"

				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line- $waveheight/2]  -tags "wave$line"
			} elseif {$prevwave == "f" || $prevwave == "l"} {
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2]  -tags "wave$line"

				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line- $waveheight/2]  -tags "wave$line"
			} elseif {$prevwave == "d" || $prevwave == "D" || $prevwave == "x" || $prevwave == "X"} {
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2]  -tags "wave$line"

				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2]  -tags "wave$line"

				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line- $waveheight/2]  -tags "wave$line"

			} else {
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line- $waveheight/2]  -tags "wave$line"

			}

			set datawidth $waveunitdelay
			set data [lindex $sigdata 0] 
			set sigdata [lrange $sigdata 1 end]
			set multfound [regexp {(.*)\*([0-9]+)} $data match data mult]
			if {$multfound == 1} {
				#puts "----mult found"
				set datawidth [expr $waveunitdelay*$mult]
			}
			regsub -all {\*\*} $data {\*} data
			.c create text [expr (2 + $signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
					[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing)*$line - $tristatedatafontheightadjust] \
					-font {$signameFont 8} -width [expr $datawidth - 2] -anchor w -text $data -tags "wave$line"

			incr wavecount 1

		} elseif {$unitwave == "l"} {
			if {$prevwave == "z" || $prevwave == "Z"} {
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] -tags "wave$line"

				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"

			} elseif {$prevwave == "x"} {
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2] -tags "wave$line"

				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] -tags "wave$line"

				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"
					
			} else { 
				if {$prevwave == "r" || $prevwave == "h"} {
				#continuous transitions
				#fall
					.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
									[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
									\
									[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
									[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"
		
				} elseif {$prevwave == "D" || $prevwave == "d"} {
					.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
									[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
									\
									[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
									[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"
				}
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"
			}
			set datawidth $waveunitdelay
			set data [lindex $sigdata 0] 
			set sigdata [lrange $sigdata 1 end]
			set multfound [regexp {(.*)\*([0-9]+)} $data match data mult]
			if {$multfound == 1} {
				#puts "----mult found"
				set datawidth [expr $waveunitdelay*$mult]
			}
			regsub -all {\*\*} $data {\*} data
			.c create text [expr (2 + $signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
					[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing)*$line - $datafontheightadjust] \
					-font {$signameFont 8} -width [expr $datawidth - 2] -anchor w -text $data -tags "wave$line"

			incr wavecount 1


		} elseif {$unitwave == "D"} {
			if {$prevwave == "z" || $prevwave == "Z" || $prevwave == {} || $prevwave == "s"} {
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] -tags "wave$line"

				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"					
			} elseif {$prevwave == "h" || $prevwave == "r"} {
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] -tags "wave$line"

				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"
		
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"
			} elseif {$prevwave == "l" || $prevwave == "f"} {
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] -tags "wave$line"

				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"
		
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"

			} else {

				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] -tags "wave$line"
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"
			}

			.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"

			.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
							\
							[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"

			set datawidth $waveunitdelay
			set data [lindex $sigdata 0] 
			set sigdata [lrange $sigdata 1 end]
			set multfound [regexp {(.*)\*([0-9]+)} $data match data mult]
			if {$multfound == 1} {
				#puts "----mult found"
				set datawidth [expr $waveunitdelay*$mult]
			}
			.c create text [expr (2 + $signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
					[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing)*$line - $datafontheightadjust] \
					-font {$signameFont 8} -width [expr $datawidth - 2] -anchor w -text $data -tags "wave$line"

			incr wavecount 1

		} elseif {$unitwave == "d"} {
			if {$prevwave == "z" || $prevwave == "Z" || $prevwave == {} || $prevwave == "s"} {
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] -tags "wave$line"

				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"

				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"
		
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"

			} elseif {$prevwave == "x" || $prevwave == "X"} {
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] -tags "wave$line"
		
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"
		
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"
		
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"
			} elseif {$prevwave == "h" || $prevwave == "r"} {
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] -tags "wave$line"

				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"
		
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"

			} elseif {$prevwave == "l" || $prevwave == "f"} {
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] -tags "wave$line"

				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"
		
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"

			} else {
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"
		
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"
			}

			set datawidth $waveunitdelay
			set data [lindex $sigdata 0] 
			set sigdata [lrange $sigdata 1 end]
			set multfound [regexp {(.*)\*([0-9]+)} $data match data mult]
			if {$multfound == 1} {
				#puts "----mult found"
				set datawidth [expr $waveunitdelay*$mult]
			}

			.c create text	[expr (2 + $signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing)*$line - $datafontheightadjust] \
							-font {$signameFont 8} -width [expr $datawidth - 2] -anchor w -text $data -tags "wave$line"

			incr wavecount 1

		} elseif {$unitwave == "s" || $unitwave == "s"} {
			#blank unitwave
			#puts "----unitwave 's' found"
			set datawidth $waveunitdelay
			set data [lindex $sigdata 0] 
			set sigdata [lrange $sigdata 1 end]
			set multfound [regexp {(.*)\*([0-9]+)} $data match data mult]
			if {$multfound == 1} {
				#puts "----mult found"
				set datawidth [expr $waveunitdelay*$mult]
			}
			if {$prevwave == "d" || $prevwave == "D" || $prevwave == "x"} {
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount+1)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2]  -tags "wave$line"

				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2]  -tags "wave$line"
			}

			.c create text	[expr (2 + $signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing)*$line  - $datafontheightadjust] \
							-font {$signameFont 8} -width [expr $datawidth - 2] -anchor w -text $data -tags "wave$line"

			incr wavecount 1
		} elseif {$unitwave == "x" || $unitwave == "X"} {

			if {$prevwave == "d" || $prevwave == "D"} {
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] -tags "wave$line"
		
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"

				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"
		
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"

				#make hatching
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 0.13))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - 4*$waveheight/5] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $hatchdistance + $waveunitdelay * ($wavecount + 0.1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  \
								-tags "wave$line" -stipple gray75

				for {set i 0.2} {$i < 0.9} {set i [expr ($i + 0.1)]} {
					.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + $i))] \
									[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
									\
									[expr ($signamecolwidth + $signalwaveXoffset + $hatchdistance + $waveunitdelay * ($wavecount + $i))] \
									[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  \
									-tags "wave$line" -stipple gray75
				}

			} elseif {$prevwave == {} || $prevwave == "z" || $prevwave == "Z"|| $prevwave == "|" || 
						$prevwave == "l" || $prevwave == "f" || $prevwave == "r" || $prevwave == "h" ||
						$prevwave == "s"} { ;#could put "/"
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] -tags "wave$line"
		
				if {$prevwave == "h" || $prevwave == "r"} {
					.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"
				} else {
					.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"
				}
				.c create line 	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"
		
				if {$prevwave == "l" || $prevwave == "f"} {
					.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"

				} else {
					.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line"
				}
				#make hatching
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 0.13))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - 4*$waveheight/5] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $hatchdistance + $waveunitdelay * ($wavecount + 0.1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  \
								-tags "wave$line" -stipple gray75

				for {set i 0.2} {$i < 0.9} {set i [expr ($i + 0.1)]} {
					.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + $i))] \
									[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
									\
									[expr ($signamecolwidth + $signalwaveXoffset + $hatchdistance + $waveunitdelay * ($wavecount + $i))] \
									[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  \
									-tags "wave$line" -stipple gray75
				}
			} else {
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight]  -tags "wave$line"  
				if {$prevwave == "h" || $prevwave == "r"} {
					.c create line	[expr ($signamecolwidth + $signalwaveXoffset +  $waveunitdelay * $wavecount + $hatchdistance)] \
									[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
									\
									[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
									[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line" 
				} else {
					.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * $wavecount)] \
									[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
									\
									[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 1))] \
									[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line" 
				}
				#make hatching
				for {set i 0} {$i < 0.9} {set i [expr ($i+0.1)]} {
					.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + $i))] \
									[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
									\
									[expr ($signamecolwidth + $signalwaveXoffset + $hatchdistance + $waveunitdelay * ($wavecount + $i))] \
									[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line]  -tags "wave$line" -stipple gray75
				}


			}
			if {$unitwave == "X"} {
				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount+1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * ($wavecount+1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2]  -tags "wave$line"

				.c create line	[expr ($signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount+1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line] \
								\
								[expr ($signamecolwidth + $signalwaveXoffset + $waveTransitionTime + $waveunitdelay * ($wavecount+1))] \
								[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $line - $waveheight/2]  -tags "wave$line"
			}

			set datawidth $waveunitdelay
			set data [lindex $sigdata 0] 
			set sigdata [lrange $sigdata 1 end]
			set multfound [regexp {(.*)\*([0-9]+)} $data match data mult]
			if {$multfound == 1} {
				#puts "----mult found"
				set datawidth [expr $waveunitdelay*$mult]
			}
			regsub -all {\*\*} $data {\*} data
			if {$data != {}} {
				set xXtext [.c create text	[expr (2 + $signamecolwidth + $signalwaveXoffset + $waveunitdelay * ($wavecount + 0.5))] \
							[expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing)*$line - $datafontheightadjust] \
							-font {$signameFont 8 bold} -width [expr $datawidth - 2] -anchor center -text $data -tags "wave$line"]
				.c create rectangle [.c bbox $xXtext] -fill white -outline white
				.c raise $xXtext
			}

			incr wavecount 1

		}
		if {$unitwave != {|} && $unitwave != {!}} {
			set prevwave $unitwave
		}
		if {[.c gettags arrow$line] != {}} {
			.c lower wave$line
		}
	}

}

proc renderwaveform {line signame sigwaves sigdata} {
	global waveheight
	global signamecolwidth
	global signameFont
	global signalwaveYoffset
	global signalwaveYspacing
	global fontheightadjust

	.c delete "canvastext$line"
	.c create text $signamecolwidth [expr $signalwaveYoffset + ($waveheight + $signalwaveYspacing)*$line - $fontheightadjust] \
		-anchor e -font {$signameFont 10} -justify right -width $signamecolwidth -text $signame -tags "canvastext$line"

	drawsigwaves $line $signame $sigwaves $sigdata

}

proc yscroll {args} {
	set upperfrac [expr [lindex [.f.ty get] 0]]
	set lowerfrac [expr [lindex [.f.ty get] 1]]
	if {[expr 1.0 - $lowerfrac] > 0.01} {
		.c yview moveto $upperfrac
	} else {
		.c yview moveto $lowerfrac
	}
}

proc textyscroll {args} {
	.f.fx.t yview {*}$args
	scan [.f.fx.t index insert] %d.%d line charpos
	scan [.f.fx.t index end] %d.%d maxline endcharpos
	set upperfrac [expr [lindex [.f.ty get] 0]]
	set lowerfrac [expr [lindex [.f.ty get] 1]]

	set topline [expr round(ceil($upperfrac*$maxline) + 1)]
	set bottomline [expr round(floor($lowerfrac*$maxline) - 1)]
	puts "line is $line ------- topline is $topline ------- $bottomline"
	if {$line < $topline} {
		#current insert line is above top line of the viewable area
		.f.fx.t mark set insert $topline.$charpos
	} elseif {$line > $bottomline} {
		.f.fx.t mark set insert $bottomline.$charpos
	}

	if {[expr 1.0 - $lowerfrac] > 0.01} {
		.c yview moveto $upperfrac
	} else {
		.c yview moveto $lowerfrac
	}
}

proc canvasyscroll {args} {
	.c yview {*}$args

	set upperfrac [expr [lindex [.cy get] 0]]
	set lowerfrac [expr [lindex [.cy get] 1]]

	if {[expr 1.0 - $lowerfrac] > 0.01} {
		.f.fx.t yview moveto $upperfrac
	} else {
		.f.fx.t yview moveto $lowerfrac
	}
}

proc display {in} {
	global winTitle
	global fileName
	global prevcharpos
	global charpos
	global signamecolwidth
	global signalwaveXoffset
	global signalwaveYoffset
	global waveheight
	global signalwaveYspacing
	global textLines
	global topline
	global bottomline
	global basecanvasheight

	set prevcharpos $charpos
	scan [.f.fx.t index insert] %d.%d line charpos
	scan [.f.fx.t index $line.end] %d.%d line lineendcharpos
	scan [.f.fx.t index end] %d.%d maxline endcharpos

	if {$in == {Return} || $in == {Delete} 
			|| ($in == {BackSpace} && $prevcharpos == 0) || $in == {Control-x} || $in == {Control-v}} {
		.c delete all
		for {set i 1} {$i <= $maxline} {incr i 1} {
			refreshline $i
		}
	} else {
		refreshline $line
	}

	yscroll

}


proc refreshline {line} {
	global winTitle
	global fileName
	set signame ""
	set sigwaves ""
	set sigdata ""
	set validsig 0
	set validsigdata 0
	global taglist

	set linestr [.f.fx.t get $line.0 $line.end]
	#discard #s
	set linestr [split $linestr {#}]
	set linestr [lindex $linestr 0]
	set fullcommand [split $linestr {:}]
	set signame [lindex $fullcommand 0]
	set sigwaves [lindex $fullcommand 1]
	#puts "-- linestr is $linestr"

	#allow colon : to be used as data
	set lencmd [llength $fullcommand]
	#puts "Lencmd is $lencmd"
	if {$lencmd > 3} {
		set sigdata [join [lrange $fullcommand 2 [llength $fullcommand]] {:}]
	} else {
		set sigdata [lindex $fullcommand 2]
	}

	if {$signame != "" || $sigwaves != ""} {
		set sigdata [split $sigdata ","]
	}

	#puts "-- fullcommand is $fullcommand"
	#puts "-- signame is $signame"
	#puts "-- sigwaves is $sigwaves"
	#puts "-- sigdata is $sigdata"
	renderwaveform $line $signame $sigwaves $sigdata
	.c configure -scrollregion [.c bbox all]
	if {[.f.fx.t edit modified] == 1} {
		wm title . "$winTitle - $fileName - MODIFIED"
	} else {
		wm title . "$winTitle - $fileName"
	}

}

proc evaluateTextBuffer {} {

	global datafontheightadjust
	global tristatedatafontheightadjust
	global waveheight
	set datafontheightadjust [expr $waveheight/2]
	set tristatedatafontheightadjust [expr 1.6*$datafontheightadjust]
	scan [.f.fx.t index end] %d.%d maxline endcharpos
	for {set i 1} {$i <= $maxline} {incr i 1} { 
		refreshline $i
    }
}
# proc to open files or read a pipe
proc openOnInit {thefile} {

	global fileName 
	if [ file exists $thefile ] {
		set newnamefile [open $thefile r+]
    } else {
		set newnamefile [open $thefile w+]
    }

	.c delete all
	fconfigure $newnamefile 
	set line_count 1
	while { [gets $newnamefile line] >= 0 } {
		#puts "line is ... $line"
		.f.fx.t insert end "$line\n"
		refreshline $line_count
		incr line_count 1
    }
	close $newnamefile
	set fileName $thefile
	settitle 

	.f.fx.t mark set insert 1.0
}


# generic case switcher for message box
proc confirmBufferRemoval {yesfn nofn} {
    if {[.f.fx.t edit modified] == 1 } { 
		set answer [tk_messageBox -message "The contents of this file may have changed, do you wish to to save your changes?" \
			-title "Confirm Text Remove" -type yesnocancel -icon question]
		case $answer {
			yes {if {[eval $yesfn] == 1} {.f.fx.t edit modified 0; $nofn}}
			no {.f.fx.t edit modified 0; $nofn}
		}
    } else {
		$nofn
    }
	
}

proc eraseCanvas {} {
	setTextTitleAsNew
	.c delete all
	.f.fx.t delete 1.0 end
	.f.fx.t edit modified 0
}

proc fileNew {} {
	global winTitle
	global fileName
	if {[.f.fx.t edit modified] == 1} {
		confirmBufferRemoval fileSave eraseCanvas
	} else {
		eraseCanvas
	}
	.f.fx.t insert insert ":|sssssssss.:    1,     2,     3,     4,     5,     6,     7,     8,    9\nclk:|ppppppppp.:  1,,  2,,  3,,  4,,  5,,  6,,  7,,  8,,  9\n"
	refreshline 1
	refreshline 2
	.f.fx.t edit modified 1
	set fileName "Untitled0"
	set ext ".tim"
	set filecountiter 0
	set tempfilename "Untitled"
    while {[file exists $tempfilename$filecountiter$ext]} {
		incr filecountiter 1
	}
	set fileName $tempfilename$filecountiter$ext
	wm title . "$winTitle - $fileName - MODIFIED"
	.f.fx.t edit reset
	.f.fx.t edit separator
}

proc setTextTitleAsNew {} {
	global winTitle fileName
	.f.fx.t delete 1.0 end
	set fileName ""
	wm title . $winTitle

	.f.fx.t mark set insert 1.0
}

# bring up open win
proc showopenwin {} {
	set types {
		{"All files"    {*}}
		{"Timing files"		{*.tim}}
	}
	set myfile [tk_getOpenFile -filetypes $types -parent .]
	if [string compare $myfile ""] {
		setTextTitleAsNew
		openOnInit $myfile
	}
}

#open an existing file
proc fileOpen {} {
  	confirmBufferRemoval fileSave showopenwin
}

# about menu
proc about {} {
	global winTitle 
	tk_messageBox -title "About" -type ok -message "$winTitle \n by Anirban Banerjee (anirbax@gmail.com) (c) 2015" 
}

#canvas2Photo by George Petasis
proc canvas2Photo {canvas image} {
    ## Ensure that the window is on top of everything else, so as not to get
    ## white ranges in the image, due to overlapped portions of the window with
    ## other windows...
    raise [winfo toplevel $canvas]
    update
    set border [expr {[$canvas cget -borderwidth] +
                      [$canvas cget -highlightthickness]}]
    set view_height [expr {[winfo height $canvas]-2*$border}]
    set view_width  [expr {[winfo width  $canvas]-2*$border}]
    foreach {x1 y1 x2 y2} [$canvas bbox all] {break}
    set x1 [expr {int($x1-10)}]
    set y1 [expr {int($y1-10)}]
    set x2 [expr {int($x2+10)}]
    set y2 [expr {int($y2+10)}]
    set width  [expr {$x2-$x1}]
    set height [expr {$y2-$y1}]
    image create photo $image \
         -height $height -width $width
    ## Arrange the scrollregion of the canvas to get the whole window visible,
    ## so as to grab it into an image...
    set scrollregion [$canvas cget -scrollregion]
    set xscrollcommand [$canvas cget -xscrollcommand]
    set yscrollcommand [$canvas cget -yscrollcommand]
    $canvas configure -xscrollcommand {}
    $canvas configure -yscrollcommand {}
    set grabbed_x $x1
    set grabbed_y $y1
    set image_x 0
    set image_y 0
    while {$grabbed_y < $y2} {
      while {$grabbed_x < $x2} {
        $canvas configure -scrollregion [list $grabbed_x $grabbed_y \
          [expr {$grabbed_x + $view_width}] [expr {$grabbed_y + $view_height}]]
        update
        ## Take a screenshot of the visible canvas part...
        image create photo ${image}_tmp \
          -format window -data $canvas
        ## Copy the screenshot to the target image...
        $image copy ${image}_tmp \
          -to $image_x $image_y -from $border $border
        incr grabbed_x $view_width
        incr image_x   $view_width
      }
      set grabbed_x $x1
      set image_x 0
      incr grabbed_y $view_height
      incr image_y   $view_height
    }
    $canvas configure -scrollregion $scrollregion
    $canvas configure -xscrollcommand $xscrollcommand
    $canvas configure -yscrollcommand $yscrollcommand
    lower [winfo toplevel $canvas]
    return $image
 }

proc canvasSave {} {

	foreach dll {tkimg143.dll tkimggif143.dll tkimgwindow143.dll} {
		if [file exists $dll] {
			load $dll
		} else {
			tk_messageBox -title "DLL Missing" -type ok -message "$dll is missing. Ping Anirban Banerjee (anirbax@gmail.com) to get the DLL." 
			return
		}
	}
	set canvascoords [.c bbox all]
	set xmin [lindex $canvascoords 0]
	set xmax [lindex $canvascoords 2]
	set ymin [lindex $canvascoords 1]
	set ymax [lindex $canvascoords 3]

	set xsize [expr $xmax + $xmin]
	set ysize [expr $ymax + $ymin]

	#puts "########### xsize is $xmax, ysize is $ymax"
	
    #set im [image create photo -width 1000 -height 2000 -data .c]
    set im [image create photo]
	set im [canvas2Photo .c $im]
    set timingdiagfilename [tk_getSaveFile -defaultextension .gif \
                      -filetypes {{"All files" *} {"GIF" *.gif}}]
    if {$timingdiagfilename != {}} {
        $im write $timingdiagfilename -format GIF
    }
    image delete $im
}

#source file write
proc writeFile {} {
	global fileName 
	set FileNameToSave [open $fileName w+]
    fconfigure $FileNameToSave
	puts $FileNameToSave [.f.fx.t get 1.0 end] 
	close $FileNameToSave
}

# this proc just sets the title to what it is passed
proc settitle {} {
	global winTitle fileName
	.f.fx.t edit modified 0
	wm title . "$winTitle - $fileName"
}

wm protocol . WM_DELETE_WINDOW {
	exitApp
}

#save a file as
proc fileSaveAs {} {
	global fileName
    set types {
		{"All files"    {*}}
		{"Timing files"		{*.tim}}
    }
    set myfile [tk_getSaveFile -filetypes $types -parent . -initialfile $fileName]
    if { $myfile != "" } {
		set fileName $myfile
		writeFile
		settitle 
        return 1
    }
    return 0
}

#save a source file
proc fileSave {} {
    global winTitle fileName
    #check if file exists file
    if {[file exists $fileName]} {
		writeFile
		.f.fx.t edit modified 0
		wm title . "$winTitle - $fileName"
        return 1
    } else {
		return [eval fileSaveAs]
    }
}

# kill main window
proc killWin {} {
	destroy .
}

# exit app
proc exitApp {} { 
	confirmBufferRemoval fileSave killWin
}

proc handleRightMouseButtonClick {x y} {
	global CanvasMouseX
	global CanvasMouseY
	#Get mouse cursor relative to Tk window
	#Add  window position to get absolute cursor position
	set finalx [expr $x+[winfo rootx .c]]
	set finaly [expr $y+[winfo rooty .c]]
	set CanvasMouseX $x
	set CanvasMouseY $y
	# Create a menu
	#puts "handleRightMouseButtonClick == X is $x ++ Y is $y"

	tk_popup .popupMenu [expr $x+[winfo rootx .]] [expr $y+[winfo rooty .]]
}

proc insertMouseCoords { } {
	global CanvasMouseX
	global CanvasMouseY
	global signamecolwidth
	global signalwaveXoffset
	global signalwaveYoffset
	global waveunitdelay
	global waveheight
	global signalwaveYspacing
	global wavecount

	scan [.f.fx.t index insert] %d.%d myline charpos
	set linestr [.f.fx.t get $myline.0 $myline.end]
	set plusposition [string first "+" $linestr]
	set caretposition [string first "^" $linestr]
	puts "insertMouseCoords -- plusposition is $plusposition, caretposition is $caretposition"
	#this line does not have the "+" required for an arrow, or the current insert character is to the left of the arrow
	if {$plusposition == -1 || ($plusposition >= $charpos)} {
		if {$caretposition == -1 || ($caretposition >= $charpos)} {
			return
		}
	} else {
		puts "For Arrow insertMouseCoords -- CanvasMouseX is $CanvasMouseX"
		set myx [expr $CanvasMouseX - $signamecolwidth - $signalwaveXoffset + int([.c canvasx 0])]
		set myy [expr $CanvasMouseY - ($signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $myline) + int([.c canvasy 0])]
		set xwithoutadj [expr $CanvasMouseX + int([.c canvasx 0]) - 3]
		set ywithoutadj [expr $CanvasMouseY + int([.c canvasy 0]) - 3]
		.c create oval  $xwithoutadj $ywithoutadj \
			[expr $xwithoutadj + 6] [expr $ywithoutadj + 6] -outline black -fill yellow -tags "wavepointerarrowstart$myline"
		puts " ---- xwithoutadj is $xwithoutadj == ywithoutadj is $ywithoutadj"
		.f.fx.t insert insert "$myx, $myy, "
		refreshline $myline
		return
	}
	if {$caretposition == -1 || ($caretposition >= $charpos)} {
		return 
	} else {
		#puts "For Floating Tag insertMouseCoords -- CanvasMouseX is $CanvasMouseX"
		set myx [expr $CanvasMouseX - $signamecolwidth - $signalwaveXoffset + int([.c canvasx 0])]
		set myy [expr $CanvasMouseY - ($signalwaveYoffset + ($waveheight + $signalwaveYspacing) * $myline) + int([.c canvasy 0])]
		set xwithoutadj [expr $CanvasMouseX + int([.c canvasx 0]) - 3]
		set ywithoutadj [expr $CanvasMouseY + int([.c canvasy 0]) - 3]
		.f.fx.t insert insert "$myx, $myy, "
		refreshline $myline
	}

}


set fileName "Untitled0"
set ext ".tim"

set filecountiter 0
set tempfilename "Untitled"
while {[file exists $tempfilename$filecountiter$ext]} {
	#puts "File $tempfilename$filecountiter$ext exists..."
	incr filecountiter 1
}
set fileName $tempfilename$filecountiter$ext

wm title . $winTitle
wm iconname . $winTitle

set canvasheight [expr ($waveheight + $signalwaveYspacing) * $textLines]
set canvasincrement [expr ($waveheight + $signalwaveYspacing)]
scrollbar .cx -relief sunken -command ".c xview" -orient horizontal
scrollbar .cy -relief sunken -command "canvasyscroll"
canvas .c	-background white -bd 2	-height $canvasheight -width 500 \
			-yscrollincrement $canvasincrement \
			-relief sunken \
			-xscrollcommand ".cx set" \
			-yscrollcommand ".cy set"
frame  .f
	frame .f.fx
		scrollbar .f.fx.tx -relief sunken -command ".f.fx.t xview" -orient horizontal
		text .f.fx.t -relief sunken -bd 2 -height $textLines -wrap none -font {Courier 10} \
			-yscrollcommand ".f.ty set" \
			-xscrollcommand ".f.fx.tx set" -undo 1
		pack .f.fx.tx -side bottom -fill both 
		pack .f.fx.t -side bottom -fill both 
	#scrollbar .f.ty -relief sunken -command ".f.fx.t yview"
	scrollbar .f.ty -relief sunken -command "textyscroll"
    pack .f.ty -side right -fill both 
    pack .f.fx -side right -fill both  -expand 1
pack .f -fill both -side bottom
pack .cy -side right -fill y 
pack .cx -side bottom -fill x
pack .c -side bottom -fill both -expand 1


menu .m -tearoff 0 -font $menuFont
#file menu
menu .m.files -tearoff 0
.m  add cascade -label "File" -underline 0 -menu .m.files
.m add cascade -label "Options" -underline 0 -menu .m.options
.m add cascade -label "Help" -underline 0 -menu .m.help

.m.files add command -label "New Source"  -command "fileNew"
.m.files add command -label "Open Source" -command "fileOpen"
.m.files add command -label "Save Source Ctrl+s" -underline 1 -command "fileSave"
.m.files add command -label "Save Source As" -command "fileSaveAs"
.m.files add command -label "Export GIF" -command "canvasSave"
.m.files add separator
.m.files add command -label "Exit" -underline 1 -command "exitApp" -accelerator Ctrl+q

menu .m.options -tearoff 0
.m.options add cascade -label "Signal Column" -menu .m.options.signamewidth
.m.options add cascade -label "Arrow Colour" -menu .m.options.arrowcolour
#.m.options add cascade -label "Clock Width" -menu .m.options.clockwidth
#
menu .m.options.signamewidth -tearoff 0 
.m.options.signamewidth add radiobutton -label "Narrow"	-variable signamecolwidth -value 40 -command "evaluateTextBuffer"
.m.options.signamewidth add radiobutton -label "Normal"	-variable signamecolwidth -value 80 -command "evaluateTextBuffer"
.m.options.signamewidth add radiobutton -label "Wide"	-variable signamecolwidth -value 120 -command "evaluateTextBuffer"
#
menu .m.options.arrowcolour -tearoff 0
.m.options.arrowcolour add radiobutton -label "Black"	-command {scan [.f.fx.t index insert] %d.%d line charpos; .c itemconfigure "wavepointerarrow$line" -fill black}
.m.options.arrowcolour add radiobutton -label "Red"	-command {scan [.f.fx.t index insert] %d.%d line charpos; .c itemconfigure "wavepointerarrow$line" -fill red}
.m.options.arrowcolour add radiobutton -label "Blue"	-command {scan [.f.fx.t index insert] %d.%d line charpos; .c itemconfigure "wavepointerarrow$line" -fill blue}

#menu .m.options.clockwidth -tearoff 0
#.m.options.clockwidth add radiobutton -label "Normal"	-variable waveunitdelay -value 40 -command "evaluateTextBuffer"
#.m.options.clockwidth add radiobutton -label "Wide"	-variable waveunitdelay -value 60 -command "evaluateTextBuffer"


menu .m.help -tearoff 0
.m.help add command -label "About" -underline 0 -command "about"

#make the menu visible
. configure -menu .m 

menu .popupMenu -tearoff 0
.popupMenu add command -label "Insert Coords into source" -command {insertMouseCoords}

bind . <Control-equal> {incr textLines 1; .f.fx.t configure -height $textLines; break}
bind . <Control-plus> {incr textLines 1; .f.fx.t configure -height $textLines; break}
bind . <Control-minus> {incr textLines -1; .f.fx.t configure -height $textLines; break}
bind . <Control-underscore> {incr textLines -1; .f.fx.t configure -height $textLines; break}
bind . <Control-s> {fileSave; break}
bind . <Control-q> {exitApp; break}
bind . <Control-x> {display %K; break}
bind . <Control-V> {display %K; break}
bind . <Control-v> {display %K; break}
bind . <Control-X> {display %K; break}
bind . <Control-x> {display %K; break}
bind . <Control-z> {display %K; break}
bind . <Control-Z> {display %K; break}
bind . <Key> {display %K; break}
bind . <KeyRelease> {break}
bind .f.fx.t <MouseWheel> {textyscroll}
bind .c <ButtonPress-2> {%W scan mark   %x %y}
bind .c <B2-Motion>     {%W scan dragto %x %y 1}
bind .c <ButtonPress-3> {handleRightMouseButtonClick %x %y;break}
bind . <Configure> {display %K;break}
wm resizable . 1 1
wm focusmodel . active
focus -force .f.fx.t
#destroy .c; destroy .f; destroy .m; destroy .cx; destroy .cy; destroy .popupMenu source waves.tcl
#c:pppppppp;1, 2, 3, , ,,4,5,6,7 
#data:xxddDdDdDdDdDdDd
#dat0:xxddDdDdDdDdDdDd;,,                 d1*3,,,,,,,,,,,,,               d2*3
#sig1: lrflllrhflrhhhlr
#sig1: lrhhhhhhhhfllllr
#destroy .c; destroy .t; destroy .m; destroy .cx; destroy .cy; source waves.tcl

#c:pppppppp;1, 2, 3, , ,,4,5,6,7 
#data:xxddDdDdDdDdDdDd
#dat0:xxddDdDdDdDdDdDd;,,                 d1*3,,,,,,,,,,,,,               d2*3
#sig1: lrflllrhflrhhhlr
#sig1: lrhhhhhhhhfllllr
#
#d:xxDDdd;,,1,,3*2,,
#ss:llrh;1,,2,3
#c:pppppppp;1, 2, 3, , ,,4,5,6,7 
#data:xxddDdDdDdDdDdDd
#dat0:xxddDdDdDdDdDdDd;,,,d,d,d,d,d,d,d,,d
#sig1: lrflllrhflrhhhlr
#sig1: lrhhhhhhhhfllllr
#clk:cccccccc;1,2,3,4,5
#
#s:xxxdxxxxxxxxxxxx
#c:pppppppp;1, 2, 3, , ,,4,5,6,7 
#data:xxddDdDdDdDdDdDd
#dat0:xxddddDdDdDdDdDdDd;,,,                 this is a wide comment*5,,,,,,,,,,,,,               d2*3
#sig1: lrhhhhhhhhfllllr
#clk:cccccccc;1,2,3,4,5

