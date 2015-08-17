#pragma rtGlobals=1		// Use modern global access method.

Function ERG()
	ResetExperiment()
	if(LoadNQWaves()) //load from saved file
		//setup variables for parsing, etc.
		variable baseline=1
		variable sweepLength=8
		string gain="2000"
		prompt baseline, "Baseline Length:"
		prompt sweeplength, "Sweep Length:"
		prompt gain, "Gain Value:", popup, "50000;20000;10000;5000;2000;1000;500;200;100;50;20;10"	
		DoPrompt "Enter Values:", baseline, sweeplength, gain
		if(V_flag)
			ResetExperiment()
			return 1
		else
			BuildNQCharts(ParseERG(baseline,sweeplength,str2num(gain)))
			//check code to go here
			AverageWavelists("wavelists")
			//further analysis calls go here
		endif
	endif
	return 0
end

Function/WAVE ParseERG(baselen,sweeplen,ampGain)
	variable baselen //seconds
	variable sweeplen //seconds
	variable ampGain
	variable resplen=sweeplen-baselen
	
	variable i
	
	WAVE NQ_Imem=root:NQ_Imem
	WAVE NQ_Pdiode=root:NQ_Pdiode
	WAVE NQ_Filter=root:NQ_FilterValue
	
	NQ_Imem*=2000*.00010432/ampGain //scaling factor from  calibration of 104.32uV per input unit at 2000x gain
	SetScale y,0,1,"V ("+num2str(ampGain)+"x)" NQ_Imem
	
	//determine pdiode threshold level
	wavestats/Q/R=[0,baselen/deltax(NQ_Pdiode)] NQ_Pdiode
	variable pdiodeThresh=V_max+(V_max-V_min)*2
	
	//determine filter wave base level
	wavestats/Q/R=[0,baselen/deltax(NQ_Filter)] NQ_Filter
	variable filterBase=V_avg
	
	//find locations of pdiode pulses
	FindLevels/EDGE=1/P/Q NQ_Pdiode pdiodeThresh
	WAVE Stims=root:W_FindLevels
	Stims=floor(Stims)
	
	//create pseudo stimulation wave (for aesthetics)
	duplicate/o NQ_Pdiode pPdiode
	WAVE pPdiode=root:pPdiode
	pPdiode=0
	for(i=0;i<numpnts(Stims);i+=1)
		pPdiode[Stims[i],Stims[i]+1]=(wavemax(NQ_Imem)-wavemin(NQ_Imem))*.1
	endfor
	
	//show wavelists window
	dowindow/k wavelists
	for(i=itemsinlist(wavelist("L*",";",""));i>0;i-=1)
		killwaves/z $(stringfromlist(0,wavelist("L*",";",""),";"))
	endfor
	if(!exists("wavelists"))
		edit/n=wavelists
	endif
	
	for(i=0;i<numpnts(Stims);i+=1)
		//cut individual waves
		duplicate/O/R=[Stims[i]-baselen/deltax(NQ_Imem),Stims[i]+resplen/deltax(NQ_Imem)] NQ_Imem $("Imem"+num2str(i+1))
		WAVE Imem=root:$("Imem"+num2str(i+1))
		duplicate/O/R=[Stims[i]-baselen/deltax(NQ_Pdiode),Stims[i]+resplen/deltax(NQ_Pdiode)] NQ_Pdiode $("Pdiode"+num2str(i+1))
		WAVE Pdiode=root:$("Pdiode"+num2str(i+1))
		duplicate/O/R=[Stims[i]-baselen/deltax(NQ_FilterValue),Stims[i]+resplen/deltax(NQ_FilterValue)] NQ_Filter $("FilterV"+num2str(i+1))
		WAVE FilterV=root:$("FilterV"+num2str(i+1))
		
		//rescale waves
		SetScale/P x 0, deltax(NQ_Imem), "S", Imem
		SetScale/P x 0, deltax(NQ_Pdiode), "S", Pdiode
		SetScale/P x 0, deltax(NQ_Filter), "S", FilterV
		
		//create filter value lookup function
//		string filterName=findFilterValue()
		wavestats/q FilterV
		FindLevels/P/Q/D=FilterSpan FilterV (V_max+V_min)/2
		wavestats/q/r=[FilterSpan[0],FilterSpan[1]] FilterV
		WAVE wList=root:$("L"+num2str(round((V_avg-filterBase)*100)))
			
		//create wavelist if not present
		if(!waveexists(wList))
			make/U/I/n=0 $("L"+num2str(round((V_avg-filterBase)*100)))			
			WAVE wList=root:$("L"+num2str(round((V_avg-filterBase)*100)))
			appendtotable/W=wavelists wList
		endif
		
		//place waves into wavelist
		InsertPoints numpnts(wList),1, wList
		wList[numpnts(wList)-1]=i+1
	endfor
	
	Return Stims
end

Function BuildNQCharts(stimsList)
	WAVE stimsList
	
	WAVE Imem=root:NQ_Imem
	WAVE Pdiode=root:NQ_Pdiode
	WAVE Filter=root:NQ_FilterValue
	WAVE pPdiode=root:pPdiode
	
	variable chartLength=60 //seconds
	variable chartStart=0
	variable nCharts=ceil(numpnts(Imem)*deltax(Imem)/chartLength)
	variable nPanes=4
	variable nLayouts=ceil(nCharts/nPanes)
	variable currentStim,currentChart,currentLayout,currentPane
	
	pauseupdate
	for(currentChart=0;currentChart<nCharts;currentChart+=1)
		dowindow/k $("chart"+num2str(currentChart))
		display/n=$("chart"+num2str(currentChart))/HIDE=1 Imem pPdiode //using pseudo dipde chart...
		ModifyGraph/W=$("chart"+num2str(currentChart)) lsize=0.1,rgb(pPdiode)=(0,0,0)
//		Label/W=$("chart"+num2str(currentChart)) left "µV"
		SetAxis/w=$("chart"+num2str(currentChart)) bottom chartStart,chartStart+chartLength
		for(currentStim=0;currentStim<numpnts(stimsList);currentStim+=1)
			if(stimsList[currentStim]>x2pnt(Imem,chartStart) && stimsList[currentStim]<x2pnt(Imem,chartStart+chartLength))
				Tag/W=$("chart"+num2str(currentChart))/C/N=$("p"+num2str(currentStim))/F=0/B=1/I=1/L=0/TL=0/X=0.00/Y=22 bottom, pnt2x(Imem, stimsList[currentStim]), "\Z08\f02"+num2str(currentStim+1)
			endif
		endfor
		chartStart+=chartLength
	endfor
	
	for(currentLayout=0;currentLayout<nlayouts;currentLayout+=1)
		dowindow/k $("charts"+num2str(currentLayout+1))
		NewLayout/n=$("charts"+num2str(currentLayout+1))
		ModifyLayout/W=$("charts"+num2str(currentLayout+1)) mag=1,fidelity=1
		for(currentPane=0;currentPane<nPanes;currentPane+=1)
			if(stringmatch(winlist("chart*",";",""),"*chart"+num2str(currentLayout*nPanes+currentPane)+"*"))
				appendlayoutobject/D=1/F=1/T=0/W=$("charts"+num2str(currentLayout+1)) graph $("chart"+num2str(currentLayout*nPanes+currentPane))
			endif
		endfor
		execute("Tile/A=("+num2str(nPanes)+",1)")
	endfor
	doupdate
end

Function AverageWavelists(tableName)
	string tableName //="wavelists"
	variable nColumns=str2num(stringbykey("COLUMNS",TableInfo(tableName,-2)))-2
	variable col, i
	
	NVAR baselen=root:baselen
	
	for(col=0;col<=nColumns;col+=1)
		WAVE wlist=$stringbykey("WAVE", TableInfo(tableName,col))
		for(i=0;i<numpnts(wlist);i+=1)
			if(i==0)
				WAVE Imem=root:$("Imem"+num2str(wlist[i]))
				duplicate/o Imem $("Avg_"+nameofwave(wlist))
				WAVE Avg=root:$("Avg_"+nameofwave(wlist))
			else
				WAVE Imem=root:$("Imem"+num2str(wlist[i]))
				Avg+=Imem
			endif
		endfor
		Avg/=numpnts(wlist)
		wavestats/q/R=[0,baselen/deltax(Avg)] Avg
		Avg-=V_avg
	endfor
end

Function LoadNQWaves()
	variable i
	LoadData/Q/I/L=1/T=RawData
	if(V_Flag>=0)
		SetDataFolder root:RawData
	
		string NQwaves=Wavelist("NQ_*",";","")
		Make/O/T/n=(itemsinlist(NQwaves)) root:ImportedWaves
		WAVE/T nameWave=root:ImportedWaves
	
		for(i=0;i<itemsinlist(NQwaves);i+=1)
			WAVE wavenm=$stringfromlist(i,NQwaves)
			MoveWave wavenm root:
			nameWave[i]=nameofwave(wavenm)
		endfor
		KillDataFolder root:RawData
	
		if(!WinType("Imported"))
			Edit/n=Imported ImportedWaves
		endif
		return 1
	else
		return 0
	endif
end

Function ResetExperiment()
	variable i
	//kill all windows
	string wlist=winlist("*",";","WIN:87") //87 = all panels, notebooks, layouts, tables, and graphs
	for(i=0;i<itemsinlist(wlist);i+=1)
		dowindow/k $stringfromlist(i,wlist)
	endfor
	//kill all waves
	KillWaves/A/Z
end
