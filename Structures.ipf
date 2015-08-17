#pragma rtGlobals=1		// Use modern global access method.

Structure w_stats
	variable npnts
	variable numNANs
	variable numINFs
	variable avg
	variable sum
	variable sdev
	variable sem
	variable rms
	variable adev
	variable skew
	variable kurt
	variable minloc
	variable maxloc
	variable min
	variable max
	variable minRowLoc
	variable maxRowLoc
	variable startRow
	variable endRow
endstructure

Function wstats(wavenm, w,[M,R])
	WAVE wavenm
	STRUCT w_stats &w
	variable M
	string R
	
	if(M)
	else
		M=2
	endif
	
	if(!stringmatch(R,""))
		variable points=0
		if(stringmatch(R[0],"["))
			points=1
		elseif(stringmatch(R[0],"("))
			points=0
		else
			Abort "Improper range specification. Use \"[start, stop]\" for points or \"(start, stop)\" for x values"
		endif
		R=R[1,strlen(R)-2]
		variable start=str2num(stringfromlist(0,R,","))
		variable fin=str2num(stringfromlist(1,R,","))
		if(points)
			Wavestats/Q/M=(M)/R=[start,fin] wavenm
		else
			Wavestats/Q/M=(M)/R=(start,fin) wavenm
		endif
	else
		Wavestats/Q/M=(M) wavenm
	endif
	
	w.npnts=V_npnts
	w.numNANs=V_numNANs
	w.numINFs=V_numINFs
	w.avg=V_avg
	w.sum=V_sum
	w.sdev=V_sdev
	w.sem=V_sem
	w.rms=V_rms
	w.adev=V_adev
	w.skew=V_skew
	w.kurt=V_kurt
	w.minloc=V_minloc
	w.maxloc=V_maxloc
	w.min=V_min
	w.max=V_max
	w.minRowLoc=V_minRowLoc
	w.maxRowLoc=V_maxRowLoc
	w.startRow=V_startRow
	w.endRow=V_endRow
end

Function teststr()
	make/o test
	test=x^2-8000
	STRUCT w_stats tt
	wstats(test, tt,R="[0,2]")
	
	w_stats2note(test,tt)
end

Function w_stats2note(wavenm, s)
	WAVE wavenm
	STRUCT w_stats &s
	
	SetNote(wavenm,"npnts",num2str(s.npnts))
	SetNote(wavenm,"numNANs",num2str(s.numNANs))
	SetNote(wavenm,"numINFs",num2str(s.numINFs))
	SetNote(wavenm,"avg",num2str(s.avg))
	SetNote(wavenm,"sum",num2str(s.sum))
	SetNote(wavenm,"sdev",num2str(s.sdev))
	SetNote(wavenm,"sem",num2str(s.sem))
	SetNote(wavenm,"rms",num2str(s.rms))
	SetNote(wavenm,"adev",num2str(s.adev))
	SetNote(wavenm,"skew",num2str(s.skew))
	SetNote(wavenm,"kurt",num2str(s.kurt))
	SetNote(wavenm,"minloc",num2str(s.minloc))
	SetNote(wavenm,"maxloc",num2str(s.maxloc))
	SetNote(wavenm,"min",num2str(s.min))
	SetNote(wavenm,"max",num2str(s.max))
	SetNote(wavenm,"minRowLoc",num2str(s.minRowLoc))
	SetNote(wavenm,"maxRowLoc",num2str(s.maxRowLoc))
	SetNote(wavenm,"startRow",num2str(s.startRow))
	SetNote(wavenm,"endRow",num2str(s.endRow))
end
