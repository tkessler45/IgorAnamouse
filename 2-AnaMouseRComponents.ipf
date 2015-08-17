#pragma rtGlobals=1		// Use modern global access method.

Menu "Macros"
	SubMenu "AnaMouseR Utilities"
		"DisplayChart"
		"MakeLayouts"
		"DisplayChartsAndLayouts"
		"LightIntensity"
		"MakeWavesAndLists"
		"MakeWaves"
		"MakeLists"
	end

End

//****************************************************************
//****************************************************************
//****************************************************************

Macro DisplayChart(ampgain)
	variable ampgain = 100
	Silent 1; PauseUpdate
	//Duplicate source waves
	duplicate/o NQ_Imem Imemchart
	duplicate/o NQ_FBNDF ndfchart
	duplicate/o NQ_PDIODE pdiodechart
	//convert V to pA 
	//memchart*=-1000/ampgain
	SetScale d 0,0,"pA", imemchart
	//magnify and re-position pdiode trace for easier visualization
	pdiodechart*=10
	pdiodechart-=7
	//tstep = time interval between points
	variable tstep = 0.005
	//swlngth = length of sweep (in seconds) to display in one graph
	variable swplngth = 60
	variable tot = numpnts(imemchart)*tstep/swplngth
	variable cnt = 0
	do
		display imemchart pdiodechart
		setaxis bottom cnt*swplngth,swplngth*(cnt+1)
		ModifyGraph rgb(pdiodechart)=(0,0,0)
		cnt+=1
	while(cnt<tot)
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro MakeLayouts(numgrphs)
	Variable numgrphs; variable cnt=0
	Prompt numgrphs, "Number of graphs to layout:"
	Silent 1
	do //Display new layouts
		NewLayout
		do
			DoWindow/F $("Graph"+num2istr(cnt))
			if(V_Flag==1)
				AppendLayoutObject graph $("Graph"+num2istr(cnt))
			endif
			DoWindow/F $("Graph"+num2istr(cnt+1))
			if(V_Flag==1)
				AppendLayoutObject graph $("Graph"+num2istr(cnt+1))
			endif
			if((cnt+2)==2) //if dealing with graph number "2", skip it becaus it doesnt exist
				DoWindow/F $("Graph"+num2istr(cnt+3))
				if(V_Flag==1)
					AppendLayoutObject graph $("Graph"+num2istr(cnt+3))
				endif
				DoWindow/F $("Graph"+num2istr(cnt+4))
				if(V_Flag==1)
					AppendLayoutObject graph $("Graph"+num2istr(cnt+4))
				endif
				DoWindow/F $("Graph"+num2istr(cnt+5))
				if(V_Flag==1)
					AppendLayoutObject graph $("Graph"+num2istr(cnt+5))
				endif
				cnt+=1 //compensate for lack of graph2
			else
				DoWindow/F $("Graph"+num2istr(cnt+2))
				if(V_Flag==1)
					AppendLayoutObject graph $("Graph"+num2istr(cnt+2))
				endif
				DoWindow/F $("Graph"+num2istr(cnt+3))
				if(V_Flag==1)
					AppendLayoutObject graph $("Graph"+num2istr(cnt+3))
				endif
				DoWindow/F $("Graph"+num2istr(cnt+4))
				if(V_Flag==1)
					AppendLayoutObject graph $("Graph"+num2istr(cnt+4))
				endif
			endif
			Tile/A=(5,0)
			Break 	
		while(1)
		cnt+=5
	while(cnt<numgrphs)
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

//COMBINED CHARTS AND LAYOUTS
Macro DisplayChartsandLayouts(ampgain)
	variable ampgain = 100
	Silent 1; PauseUpdate
	//Duplicate source waves
	duplicate/o NQ_Imem Imemchart
	duplicate/o NQ_FBNDF ndfchart
	duplicate/o NQ_PDIODE pdiodechart
	//convert V to pA 
	//memchart*=-1000/ampgain
	SetScale d 0,0,"pA", imemchart
	//magnify and re-position pdiode trace for easier visualization
	pdiodechart*=10
	pdiodechart-=7
	//tstep = time interval between points
	variable tstep = 0.005
	//swlngth = length of sweep (in seconds) to display in one graph
	variable swplngth = 60
	variable tot = numpnts(imemchart)*tstep/swplngth
	variable cnt = 0
	variable numgrphs
	do
		display imemchart pdiodechart
		setaxis bottom cnt*swplngth,swplngth*(cnt+1)
		ModifyGraph rgb(pdiodechart)=(0,0,0)
		cnt+=1
		numgrphs=cnt
	while(cnt<tot)
	cnt=0
	do //Display new layouts
		NewLayout
		do
			DoWindow/F $("Graph"+num2istr(cnt))
			if(V_Flag==1)
				AppendLayoutObject graph $("Graph"+num2istr(cnt))
			endif
			DoWindow/F $("Graph"+num2istr(cnt+1))
			if(V_Flag==1)
				AppendLayoutObject graph $("Graph"+num2istr(cnt+1))
			endif
			if((cnt+2)==2) //if dealing with graph number "2", skip it becaus it doesnt exist
				DoWindow/F $("Graph"+num2istr(cnt+3))
				if(V_Flag==1)
					AppendLayoutObject graph $("Graph"+num2istr(cnt+3))
				endif
				DoWindow/F $("Graph"+num2istr(cnt+4))
				if(V_Flag==1)
					AppendLayoutObject graph $("Graph"+num2istr(cnt+4))
				endif
				DoWindow/F $("Graph"+num2istr(cnt+5))
				if(V_Flag==1)
					AppendLayoutObject graph $("Graph"+num2istr(cnt+5))
				endif
				cnt+=1 //compensate for lack of graph2
			else
				DoWindow/F $("Graph"+num2istr(cnt+2))
				if(V_Flag==1)
					AppendLayoutObject graph $("Graph"+num2istr(cnt+2))
				endif
				DoWindow/F $("Graph"+num2istr(cnt+3))
				if(V_Flag==1)
					AppendLayoutObject graph $("Graph"+num2istr(cnt+3))
				endif
				DoWindow/F $("Graph"+num2istr(cnt+4))
				if(V_Flag==1)
					AppendLayoutObject graph $("Graph"+num2istr(cnt+4))
				endif
			endif
			Tile/A=(5,0)
			Break 	
		while(1)
		cnt+=5
	while(cnt<numgrphs)
EndMacro
//END COMBINED CHARTS AND LAYOUTS

//****************************************************************
//****************************************************************
//****************************************************************

Macro LightIntensity(powFB, powBB, fdur)
	Variable powFB; variable powBB; variable fdur=10; variable intensFB; variable intensBB; variable flstrength; variable i=0
	Prompt powFB, "Power of FB 500 nm light in microW"
	Prompt powBB, "Power of BB 520 nm light in microW"
	Prompt fdur, "Flash duration in milliseconds"
	Silent 1
	// Convert pow to W
	powFB*=1e-6
	powBB*=1e-6
	// Convert fdur to seconds
	fdur*=1e-3
	// Conversion factor for converting W to photon density (see MB lab notebook #1, page 43); there is not UDT differential sens at 500!
	intensFB=powFB*4.2355e13
	flstrength=intensFB*fdur
	print intensFB, "photons/um2 s unattenuated at 500 nm" 
	// Conversion factor for converting W to intensity (MB notebook #1, p. 67), with UDT differential 500/520 nm sensitivity	
	intensBB=powBB*4.4046e13
	intensBB*=0.9948  //UDT corr
	// Make wave for holding true flstrength values
	duplicate/o ndftrue flstrtrue
	duplicate/o bbndftrue intenstrue
	do
		flstrtrue[i] = flstrength*(10^-ndftrue[i])
		intenstrue[i]=intensBB*(10^-bbndftrue[i])
		i+=1
	while(i<numpnts(ndftrue))
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

//START COMBINED WAVES AND LISTS
//To be used after "Display chart" to break up the chart into epochs
Macro MakeWavesandLists(sweeplength, baselinelength,tstep)
	variable sweeplength = 5
	variable baselinelength = 1
	variable tstep = 0.005
	variable num = 0
	variable scan = 0
	variable baseline = 0
	variable numwaves = 0
	variable pdiodebase = mean(pdiodechart,pnt2x(pdiodechart,scan), pnt2x(pdiodechart,scan+200))
	Silent 1; PauseUpdate
	do
		if(pdiodechart[scan]>-6.5) & (pdiodechart[scan+1]>-6.5) & (pdiodechart[scan+2]>-6.5)  // grab wave when pdiode signal exceeds absolute value of 0.06 volts for three consecutive points
			duplicate/o/r=(pnt2x(pdiodechart,scan)-baselinelength,pnt2x(pdiodechart,scan)+sweeplength-baselinelength) pdiodechart $("pdiode"+ num2str(num+1))
			SetScale/P x 0,0.005,"s", $("pdiode"+ num2str(num+1))
			duplicate/o/r=(pnt2x(pdiodechart,scan)-baselinelength,pnt2x(pdiodechart,scan)+sweeplength-baselinelength) imemchart $("imem"+ num2str(num+1))
			SetScale/P x 0,0.005, "s", $("imem"+ num2str(num+1))
			baseline = mean( $("imem"+ num2str(num+1)), 0, baselinelength) //baseline offset to zero for imem wave
			 $("imem"+ num2str(num+1))-=baseline
			duplicate/o/r=(pnt2x(pdiodechart,scan)-baselinelength,pnt2x(pdiodechart,scan)+sweeplength-baselinelength) NQ_FBNDF $("fbndf"+ num2str(num+1))
			duplicate/o/r=(pnt2x(pdiodechart,scan)-baselinelength,pnt2x(pdiodechart,scan)+sweeplength-baselinelength) NQ_BBNDF $("bbndf"+num2str(num+1))
			scan+=(sweeplength-baselinelength)/0.005-10
			num+=1
		endif
		scan+=1
	while(scan<numpnts(pdiodechart))
	print  "Made waves Imem1 - Imem"+num2str(num+1)
	numwaves=num+1
	Variable fbndfval; Variable bbndfval; Variable ndfnum = 28
	Variable i=0; Variable j=0; Variable k=0; Variable m=0; Variable n=0; Variable p=0; Variable q=0; Variable r=0; 
	Variable rawfbndf  
	Variable rawbbndf
	baseline=1
	Variable Imemnum=1	
	Silent 1; PauseUpdate
	//Make waves for lists
	do
		make/o/n=(numwaves) $("f"+num2istr((8.1-i*0.2999)*10))=0
		i+=1
	while(i<ndfnum)
	i=0; j=0
	do
		do
			make/o/n=(numwaves) $("bb"+num2istr((8.1-j*0.2999)*10)+"_f"+num2istr((8.1-i*0.2999)*10))=0
			j+=1 
		while(j<ndfnum)
		j=0
		i+=1
	while(i<ndfnum)
	imemnum=1
	do
		wavestats/Q/R=[100, 300] $("fbndf"+num2istr(Imemnum))	//find ndf of flash (front beam)
		rawfbndf=V_avg
		FindLevel/Q ndfvoltage, rawfbndf
		if(rawfbndf<ndfvoltage[0]) //Added check in to compensate for when ndf0 "rawfbndf" values are lower than the lowest in the ndfvoltage table
			V_LevelX=0
		endif
		k=round(V_LevelX)
		fbndfval = ndflist[k]
		fbndfval*=10
		if(mean($("pdiode"+num2istr(Imemnum)),0,baseline)>-6.8) //check to see if background light was on and find bbndf
			wavestats/Q/R=[100,300] $("bbndf"+num2istr(Imemnum))
			rawbbndf=V_avg
			FindLevel/Q bbndfvoltage, rawbbndf
			q=round(V_LevelX)
			bbndfval=ndflist[q]
			bbndfval*=10
			$("bb"+num2istr(bbndfval)+"_f"+num2istr(fbndfval))[Imemnum-1]=Imemnum
		else
			$("f"+num2istr(fbndfval))[Imemnum-1] = Imemnum		
		endif
		Imemnum+=1
	while(Imemnum<numwaves)
	DoWindow/K wavelists //Check for wavelist table
	edit/n=wavelists
	//delete empty fX waves and remove zeros
	do
		Sort/R $("f"+num2istr((8.1-m*0.2999)*10)), $("f"+num2istr((8.1-m*0.2999)*10))
		WaveStats/Q $("f"+num2istr((8.1-m*0.2999)*10))
		if (V_max<1) then
			KillWaves $("f"+num2istr((8.1-m*0.2999)*10))
		endif
		if(V_max>=1)
			n=0
			do
				if($("f"+num2istr((8.1-m*0.2999)*10))[n]==0)
					Deletepoints n,1000, $("f"+num2istr((8.1-m*0.2999)*10))
					break
				endif
				n+=1
			while(n<numwaves)
			appendtotable $("f"+num2istr((8.1-m*0.2999)*10))
		endif
		m+=1
	while(m<ndfnum)
	//delete empty bb_fX waves and remove zeros
	j=0
	do
		i=0
		do
			//	print i,j
			Sort/R $("bb"+num2istr((8.1-j*0.2999)*10)+"_f"+num2istr((8.1-i*0.2999)*10)),$("bb"+num2istr((8.1-j*0.2999)*10)+"_f"+num2istr((8.1-i*0.2999)*10))
			WaveStats/Q $("bb"+num2istr((8.1-j*0.2999)*10)+"_f"+num2istr((8.1-i*0.2999)*10))
			if (V_max<1) then
				KillWaves $("bb"+num2istr((8.1-j*0.2999)*10)+"_f"+num2istr((8.1-i*0.2999)*10))
			endif
			if(V_max>=1)
				n=0
				do
					if($("bb"+num2istr((8.1-j*0.2999)*10)+"_f"+num2istr((8.1-i*0.2999)*10))[n]==0)
						Deletepoints n,1000, $("bb"+num2istr((8.1-j*0.2999)*10)+"_f"+num2istr((8.1-i*0.2999)*10))
						break
					endif
				n+=1
				while(n<numwaves)
				appendtotable $("bb"+num2istr((8.1-j*0.2999)*10)+"_f"+num2istr((8.1-i*0.2999)*10))
			endif
			i+=1
		while(i<ndfnum)
		j+=1
	while(j<ndfnum)
EndMacro
//END COMBINED WAVES AND LISTS

//****************************************************************
//****************************************************************
//****************************************************************

//To be used after "Display chart" to break up the chart into epochs
Macro MakeWaves(sweeplength, baselinelength,tstep)
	variable sweeplength = 5
	variable baselinelength = 1
	variable tstep = 0.005
	variable num = 0
	variable scan = 0
	variable baseline = 0
	variable numwaves = 0
	variable pdiodebase = mean(pdiodechart,pnt2x(pdiodechart,scan), pnt2x(pdiodechart,scan+200))
	Silent 1; PauseUpdate
	do
		if(pdiodechart[scan]>-6.5) & (pdiodechart[scan+1]>-6.5) & (pdiodechart[scan+2]>-6.5)  // grab wave when pdiode signal exceeds absolute value of 0.06 volts for three consecutive points
			duplicate/o/r=(pnt2x(pdiodechart,scan)-baselinelength,pnt2x(pdiodechart,scan)+sweeplength-baselinelength) pdiodechart $("pdiode"+ num2str(num+1))
			SetScale/P x 0,0.005,"s", $("pdiode"+ num2str(num+1))
			duplicate/o/r=(pnt2x(pdiodechart,scan)-baselinelength,pnt2x(pdiodechart,scan)+sweeplength-baselinelength) imemchart $("imem"+ num2str(num+1))
			SetScale/P x 0,0.005, "s", $("imem"+ num2str(num+1))
			baseline = mean( $("imem"+ num2str(num+1)), 0, baselinelength) //baseline offset to zero for imem wave
			 $("imem"+ num2str(num+1))-=baseline
			duplicate/o/r=(pnt2x(pdiodechart,scan)-baselinelength,pnt2x(pdiodechart,scan)+sweeplength-baselinelength) NQ_FBNDF $("fbndf"+ num2str(num+1))
			duplicate/o/r=(pnt2x(pdiodechart,scan)-baselinelength,pnt2x(pdiodechart,scan)+sweeplength-baselinelength) NQ_BBNDF $("bbndf"+num2str(num+1))
			scan+=(sweeplength-baselinelength)/0.005-10
			num+=1
		endif
		scan+=1
	while(scan<numpnts(pdiodechart))
	print  "Made waves Imem1 - Imem"+num2str(num+1)
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro MakeLists(numwaves)
	Variable numwaves
	Prompt  numwaves, "Number of Imem waves to sort"
	Variable fbndfval; Variable bbndfval; Variable ndfnum = 28
	Variable i=0; Variable j=0; Variable k=0; Variable m=0; Variable n=0; Variable p=0; Variable q=0; Variable r=0; 
	Variable rawfbndf  
	Variable rawbbndf
	Variable baseline=1
	Variable Imemnum=1	
	Silent 1; PauseUpdate
	//Make waves for lists
	do
		make/o/n=(numwaves) $("f"+num2istr((8.1-i*0.2999)*10))=0
		i+=1
	while(i<ndfnum)
	i=0; j=0
	do
		do
			make/o/n=(numwaves) $("bb"+num2istr((8.1-j*0.2999)*10)+"_f"+num2istr((8.1-i*0.2999)*10))=0
			j+=1 
		while(j<ndfnum)
		j=0
		i+=1
	while(i<ndfnum)
	imemnum=1
	do
		wavestats/Q/R=[100, 300] $("fbndf"+num2istr(Imemnum))	//find ndf of flash (front beam)
		rawfbndf=V_avg
		FindLevel/Q ndfvoltage, rawfbndf
		if(rawfbndf<ndfvoltage[0]) //Added check in to compensate for when ndf0 "rawfbndf" values are lower than the lowest in the ndfvoltage table
			V_LevelX=0
		endif
		k=round(V_LevelX)
		fbndfval = ndflist[k]
		fbndfval*=10
		if(mean($("pdiode"+num2istr(Imemnum)),0,baseline)>-6.8) //check to see if background light was on and find bbndf
			wavestats/Q/R=[100,300] $("bbndf"+num2istr(Imemnum))
			rawbbndf=V_avg
			FindLevel/Q bbndfvoltage, rawbbndf
			q=round(V_LevelX)
			bbndfval=ndflist[q]
			bbndfval*=10
			$("bb"+num2istr(bbndfval)+"_f"+num2istr(fbndfval))[Imemnum-1]=Imemnum
		else
			$("f"+num2istr(fbndfval))[Imemnum-1] = Imemnum		
		endif
		Imemnum+=1
	while(Imemnum<numwaves)
	edit
	//delete empty fX waves and remove zeros
	do
		Sort/R $("f"+num2istr((8.1-m*0.2999)*10)), $("f"+num2istr((8.1-m*0.2999)*10))
		WaveStats/Q $("f"+num2istr((8.1-m*0.2999)*10))
		if (V_max<1) then
			KillWaves $("f"+num2istr((8.1-m*0.2999)*10))
		endif
		if(V_max>=1)
			n=0
			do
				if($("f"+num2istr((8.1-m*0.2999)*10))[n]==0)
					Deletepoints n,1000, $("f"+num2istr((8.1-m*0.2999)*10))
					break
				endif
				n+=1
			while(n<numwaves)
			appendtotable $("f"+num2istr((8.1-m*0.2999)*10))
		endif
		m+=1
	while(m<ndfnum)
	//delete empty bb_fX waves and remove zeros
       j=0
	do
		i=0
		do
			//	print i,j
			Sort/R $("bb"+num2istr((8.1-j*0.2999)*10)+"_f"+num2istr((8.1-i*0.2999)*10)),$("bb"+num2istr((8.1-j*0.2999)*10)+"_f"+num2istr((8.1-i*0.2999)*10))
			WaveStats/Q $("bb"+num2istr((8.1-j*0.2999)*10)+"_f"+num2istr((8.1-i*0.2999)*10))
			if (V_max<1) then
				KillWaves $("bb"+num2istr((8.1-j*0.2999)*10)+"_f"+num2istr((8.1-i*0.2999)*10))
			endif
			if(V_max>=1)
				n=0
				do
					if($("bb"+num2istr((8.1-j*0.2999)*10)+"_f"+num2istr((8.1-i*0.2999)*10))[n]==0)
						Deletepoints n,1000, $("bb"+num2istr((8.1-j*0.2999)*10)+"_f"+num2istr((8.1-i*0.2999)*10))
						break
					endif
					n+=1
				while(n<numwaves)
				appendtotable $("bb"+num2istr((8.1-j*0.2999)*10)+"_f"+num2istr((8.1-i*0.2999)*10))
			endif
			i+=1
		while(i<ndfnum)
		j+=1
	while(j<ndfnum)
EndMacro

