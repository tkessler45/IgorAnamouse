#pragma rtGlobals=1		// Use modern global access method.
//#include <FTMagPhase> 
//#include <FTMagPhaseThreshold>
//#include <DFTMagPhase>
//#include <CmplxToMagPhase>

Menu "Macros"
	SubMenu "General Utilities"
		"AdaptDecay"
		"AveandVar"
		"AvePdiode"
		"AddFlags"
		"AlignTop"
		"BaselineShift"
		"ChangeGain"
		"DarkCurrentCorrect"
		"Decompress"
		"DisplayListOfWaves"
		"DriftClamp"
		"ExciseWave"
		"Family"
		"FindRange"
		"LoadIndexWaves"
		"IntensityResponse"
		"RemoveZeros"
		"MeasureDarkCurrent"
		"MeanSquaredFit"
		"MeanSquared2"
		"MichaelisFits"
		"Normalize"
		"Recompress"
		"TimetoPeak"
		"Tsat"
		"WeberFechner"
	End
	SubMenu "Modeling"
		"cGConc"
		"CGHoleHomogeneous"
		"CyclaseActivity"
		"BetaSub"
		"PredictCyclaseActivity"
		"PDEActivity"
		"RhLifeTime"
	End
	Submenu "Noise Analysis"
		"FiltPS"
		"PowerSpec"
		"PowerSpecCellNoise"
		"PowerSpecClamp"
		"PowerSpecVar"
	End
	SubMenu "Single Photon"
		"CheckFit"
		"CompShape"
		"DimFlashFit"
		"DimPk"
		"MakeHisto"
		"PiezoSlope"
		"PiezoSort"
		"QHist"
		"ResponseAmps"
		"ResponseAreas"
		"ResponseAves"
		"ResponsePeaks"
	End
End

//****************************************************************
//****************************************************************
//****************************************************************

// Macros
// Sorted into following categories:
// (1) file input
// (2) single photon
// (3) noise analysis
// (4) general utilities 	

// GENERAL UTILITIES

//Macro AveandVar(wavelist)
//	String wavelist="darkhist"
//	Prompt wavelist,"Wavelist?"
//	Variable navesweep
//	Silent 1; PauseUpdate
//	navesweep=numpnts($(wavelist))
//	Duplicate/O $("Imem"+ num2istr($(wavelist)[0])) avew	
//	iterate(navesweep-1)
//		avew +=  $("Imem"+ num2istr($(wavelist)[i+1]))
//	loop	
//	avew/=navesweep
//	Duplicate/O $("Imem"+ num2istr($(wavelist)[0])) varw
//	varw = 0	
//	iterate(navesweep)
//		varw +=  ($("Imem"+ num2istr($(wavelist)[i]))  - avew) * ($("Imem"+ num2istr($(wavelist)[i]))  - avew)
//	loop	
//	varw /= navesweep
//	duplicate/o avew $("ave" + wavelist)	
//	duplicate/o varw $("var" + wavelist)
//EndMacro

Function AveandVar(wlist)
	String wlist//="darkhist"
	WAVE listw = $wlist
	string tempstr
	Variable navesweep
	variable i
	Silent 1; PauseUpdate
	navesweep=numpnts(listw)

	//imem waves
	tempstr = "Imem"+ num2istr(listw[0])
	Duplicate/O $tempstr avew
	avew = 0
	for(i=0;i<navesweep;i+=1)
		tempstr = "Imem"+ num2istr(listw[i])
		WAVE tempw = $tempstr
		avew += tempw
	endfor
	avew/=navesweep
	tempstr = "Imem"+ num2istr(listw[0])
	Duplicate/O $tempstr varw
	varw = 0
	for(i=0;i<navesweep;i+=1)
		tempstr = "Imem"+ num2istr(listw[i])
		WAVE tempw = $tempstr
		varw += (tempw - avew)^2
	endfor
	varw /= navesweep
	tempstr = "ave" + wlist
	RemoveNanTrail(avew)
	duplicate/o avew $tempstr
	tempstr = "var" + wlist
	RemoveNanTrail(varw)
	duplicate/o varw $tempstr

	//pdiode waves
	tempstr = "pdiode"+ num2istr(listw[0])
	Duplicate/O $tempstr avew
	avew = 0
	for(i=0;i<navesweep;i+=1)
		tempstr = "pdiode"+ num2istr(listw[i])
		WAVE tempw = $tempstr
		avew += tempw
	endfor
	avew/=navesweep
	tempstr = "pdiode"+ num2istr(listw[0])
	Duplicate/O $tempstr varw
	varw = 0
	for(i=0;i<navesweep;i+=1)
		tempstr = "pdiode"+ num2istr(listw[i])
		WAVE tempw = $tempstr
		varw += (tempw - avew)^2
	endfor
	varw /= navesweep

	tempstr = "avep" + wlist
//	wavestats/q avew
//	avew-=v_avg
	RemoveNanTrail(avew)
	duplicate/o avew $tempstr
	tempstr = "varp" + wlist
	RemoveNanTrail(varw)
	duplicate/o varw $tempstr
End

Function RemoveNanTrail(wavenm)
	WAVE wavenm
	variable i=numpnts(wavenm)
	variable flag=0
	if(numtype(wavenm[i-1])==2)
		flag=1
		do
			i=i-1
			if(i==0)
				print "RemoveNanTrail: Error in counting number of points to remove for wave "+nameofwave(wavenm)
				return 1
			endif
		while(numtype(wavenm[i])==2)
		DeletePoints i+1,numpnts(wavenm)-1-i, wavenm
	endif
end

//****************************************************************
//****************************************************************
//****************************************************************

//Macro AvePdiodeM(wavelist)
//	String wavelist="f45"
//	Prompt wavelist,"Wavelist?"
//	Variable navesweep
//	Silent 1; PauseUpdate
//	navesweep=numpnts($(wavelist))
//	Duplicate/O $("pdiode"+ num2istr($(wavelist)[0])) avew	
//	iterate(navesweep-1)
//		avew +=  $("pdiode"+ num2istr($(wavelist)[i+1]))
//	loop	
//	avew/=navesweep
//	Duplicate/O $("pdiode"+ num2istr($(wavelist)[0])) varw
//	varw = 0	
//	iterate(navesweep)
//		varw +=  ($("pdiode"+ num2istr($(wavelist)[i]))  - avew) * ($("pdiode"+ num2istr($(wavelist)[i]))  - avew)
//	loop	
//	varw /= navesweep
//	duplicate/o avew $("avepdiode" + wavelist)	
//	duplicate/o varw $("varpdiode" + wavelist)
//EndMacro

Function AvePdiode(startnum, endnum, list) //generaes pdiodeavg for indices "startnum" through "endnum" for wavelist "list". If "list" is "all", then run on all pdiode waves between "startnum" and "endnum"
	variable startnum
	variable endnum
	string list //wave list, or "all" for all used waves
	variable i
	string tempstr
	
	if(stringmatch(list,"all")) //if "all" list mentioned, calculate for all used flashes
		if(waveexists(pdiodelist))
			Print "--Calculating average pdiode wave (pdiodeavg) for ALL used flashes"
			WAVE pdiodelist=root:pdiodelist
			startnum=0
			endnum=numpnts(pdiodelist)
	
			tempstr="pdiode"+num2str(pdiodelist[i])
			WAVE wv=root:$("pdiode"+num2str(pdiodelist[i]))
			if(exists(nameofwave(wv))) //do not perform if no pdiode waves exist (other functions use pdiodeshift value)
				Duplicate/O $tempstr avew
				avew=0
				for(i=startnum;i<=endnum;i+=1)
					tempstr="pdiode"+num2str(pdiodelist[i])
					WAVE tempw=$tempstr
					avew+=tempw
				endfor
				avew/=endnum
	
				tempstr = "pdiode"+num2str(pdiodelist[i])
				Duplicate/O $tempstr varw
				varw=0
				for(i=startnum;i<=endnum;i+=1)
					tempstr="pdiode"+num2str(pdiodelist[i])
					WAVE tempw=$tempstr
					varw+=(tempw-avew)^2
				endfor
				varw/=endnum
	
				duplicate/o avew pdiodeavg
				duplicate/o varw pdiodevar
				killwaves/z avew, varw
			endif
		else
			Abort "Run \"AveVarAll\" before running this macro"
		endif
	else
		if(waveexists($list))
			Print "--Calculating average pdiode wave (pdiodeavg) for pdiode list: "+list
			WAVE pdiodelist=$list
			startnum=0
			endnum=numpnts(pdiodelist)
			
			tempstr="pdiode"+num2str(pdiodelist[i])
			WAVE wv=root:$("pdiode"+num2str(pdiodelist[i]))
			if(exists(nameofwave(wv))) //do not perform if no pdiode waves exist (other functions use pdiodeshift value)
				Duplicate/O $tempstr avew
				avew=0
				for(i=startnum;i<=endnum;i+=1)
					tempstr="pdiode"+num2str(pdiodelist[i])
					WAVE tempw=$tempstr
					avew+=tempw
				endfor
				avew/=(endnum-startnum)
	
				tempstr = "pdiode"+num2str(pdiodelist[i])
				Duplicate/O $tempstr varw
				varw=0
				for(i=startnum;i<=endnum;i+=1)
					tempstr="pdiode"+num2str(pdiodelist[i])
					WAVE tempw=$tempstr
					varw+=(tempw-avew)^2
				endfor
				varw/=(endnum-startnum)
	
				duplicate/o avew pdiodeavg
				duplicate/o varw pdiodevar
				killwaves/z avew, varw
			endif
		else
			if(stringmatch(list,"") && startnum>0 && endnum>0)
				Print "--Calculating average pdiode wave (pdiodeavg) for pdiode"+num2str(startnum)+" to "+num2str(endnum)
				// code for averaging any pdiode waves in sequence...
//				startnum
//				endnum
			
				tempstr="pdiode"+num2str(startnum)
				WAVE wv=root:$("pdiode"+num2str(startnum))
				if(exists(nameofwave(wv))) //do not perform if no pdiode waves exist (other functions use pdiodeshift value)
					Duplicate/O $tempstr avew
					avew=0
					for(i=startnum;i<=endnum;i+=1)
						tempstr="pdiode"+num2str(i)
						WAVE tempw=$tempstr
						avew+=tempw
					endfor
					avew/=(endnum-startnum)
	
					tempstr = "pdiode"+num2str(i)
					Duplicate/O $tempstr varw
					varw=0
					for(i=startnum;i<=endnum;i+=1)
						tempstr="pdiode"+num2str(i)
						WAVE tempw=$tempstr
						varw+=(tempw-avew)^2
					endfor
					varw/=(endnum-startnum)
	
					duplicate/o avew pdiodeavg
					duplicate/o varw pdiodevar
					killwaves/z avew, varw
				endif
			else
				Abort "Specified wave list \""+list+"\" does not exist, or range ("+num2str(startnum)+" to "+num2str(endnum)+") includes zeros"
			endif
		endif
	endif
End

//****************************************************************
//****************************************************************
//****************************************************************

Macro AddFlags(Start, Stop, HeaderPos, Var)
	Variable start = 1; Variable stop = 100; Variable Headerpos = 10 ; Variable Var = 2;
	Prompt start, "Start with Imem"
	Prompt stop, "Stop with Imem"
	Prompt headerpos, "Cell to edit"
	Prompt var, "Change to"
	Silent 1; PauseUpdate
	iterate(stop - start+1)
		$("imemhead"+num2str(i+start))[Headerpos] = var
	loop
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro AlignTop(list, ref)
	String list =  "f36"
	Variable ref = 1; Variable num; Variable point; Variable top; Variable max1
	Prompt list, "List of waves to align:"
	Prompt ref, "With repect to which Imem?"
	Silent 1; PauseUpdate
	num = numpnts($(list))
	wavestats/r=(1,1.5) $(("Imem") + num2str(ref))
	top = V_max
	make/n=(num) $("offset" + list) 
	iterate(num)
		point  = ($(list)[i])
		wavestats/Q/r=(1,1.5) $(("Imem") + num2str(point))
		max1 = V_max
		if (max1<top)
			$("offset"+list) [i] = top-max1
			$(("Imem") + num2str(point))+= (top-max1)
		endif
		if (max1>top)
			$("offset"+list) [i] = max1-top
			$(("Imem") + num2str(point))+= (max1-top)
		endif
	loop
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro BaseLineClamp(StartPos,EndPos, NumWaves)
	Variable StartPos = 0; Variable EndPos = 1; variable Numwaves = 0
	Prompt StartPos, "Start baseline at"
	Prompt EndPos, "End baseline at"
	Prompt NumWaves, "Number of waves? "
	variable bsln
	Silent 1; PauseUpdate
	iterate(NumWaves)
		bsln = mean($("Imem" + num2str(i+1)), StartPos, EndPos)
		$("Imem" + num2str(i+1)) -= bsln
	loop
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro ChangeGain(fact,first,numw)
	Variable fact,first=1,numw=1,factor
	Prompt fact, "Multiplication factor"
	Prompt first, "First wave "
	Prompt numw, "Number of waves "
	Silent 1
	iterate(numw)
		$("Imem" + num2str(first+i))*=fact
	loop
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro DarkCurrentCorrect(InitWave, FinWave, InitDarkCurrent, FinDarkCurrent)
	variable initwave, finwave, initdarkcurrent, findarkcurrent
	prompt initwave, "Begin correction at wave #"
	prompt finwave, "End correction at wave #"
	prompt initdarkcurrent, "Initial dark current"
	prompt findarkcurrent, "Final dark current"
	variable fracpntr
	variable scale
	Silent 1; PauseUpdate
	iterate(Finwave-initwave)
		fracpntr = i / (finwave - initwave)
		scale = fracpntr * findarkcurrent + (1 - fracpntr) * initdarkcurrent
		scale /= initdarkcurrent
		$("imem" + num2istr(i+InitWave)) /= scale
	loop
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro Decompress(wavename, darki)
	String wavename="imem1"
	Variable darki=10
	Prompt wavename, "Wave to decompress?"
	Prompt darki, "Dark current (pA)"
	Silent 1
	Duplicate/o $(wavename) decomp
	decomp/=darki
	decomp=-ln(1-decomp)
	duplicate/o decomp $("decomp" + wavename)
End

//****************************************************************
//****************************************************************
//****************************************************************

Macro Recompress(wavename, darki)
	String wavename="fit1"
	Variable darki=10
	Prompt wavename, "Wave to recompress?"
	Prompt darki, "Dark current (pA)"
	Silent 1
	Duplicate/o $(wavename) recomp
	recomp=exp(-recomp)
	recomp-=1
	recomp*=-1
	recomp*=darki
	duplicate/o recomp $("recomp" +wavename)	
End

//****************************************************************
//****************************************************************
//****************************************************************
	
Macro DisplayListOfWaves(wlist, graphname,xpos,ypos,hoststr,hide)
	String wlist="f18"
	String graphname="list"
	variable xpos=0
	variable ypos=0
	String hoststr="" //host window for the list
	variable hide=0 //default show the graphs...	
	Prompt wlist,"Wavelist?"
	Prompt graphname, "Graph Name:"
	Prompt xpos, "Horizontal window position:"
	Prompt ypos, "Vertical window position:"
	Prompt hoststr, "Host window for graph (leave blank for none):"
	Prompt hide, "Hide traces (1=yes,0=no)?"
	
	variable step = floor(65535/numpnts($wlist))
	variable red = 0+step
	variable green = 0
	variable blue = 65535-step
	string nm
	
	if(strlen(hoststr))
		nm = hoststr+"#"+graphname
	else
		nm = graphname
	endif
		
	Silent 1
	Duplicate/o imem1 zero
	Zero = 0
	DoWindow/K $graphname
	if(hide)
		Display/W=(xpos,ypos,xpos+400,ypos+250)/n=$graphname/HIDE=1/HOST=$hoststr zero
	else
		Display/W=(xpos,ypos,xpos+400,ypos+250)/n=$graphname/HIDE=0/HOST=$hoststr zero
	endif
	ModifyGraph/W=$(nm) rgb(zero)=(0,0,0)
	SetAxis/W=$(nm)/A=2 left
	
//	if(str2num(Values[1])>0)
//		ModifyGraph offset(zero)={0,str2num(Values[1])}
//	endif
	
	Silent 1; PauseUpdate
//	WaveStats/Q $(wlist)
	variable i=numpnts($wlist)-1//0
	do
		AppendToGraph/W=$(nm)/C=(red,green,blue) $("Imem"+num2istr($(wlist)[i]))
//		ModifyGraph/W=$(nm) rgb($("Imem"+num2istr($(wlist)[i])))=(red,green,blue)
		red+=step
		green=0
		blue-=step
		i-=1
	while(i>=0)//<numpnts($wlist))
	i=numpnts($wlist)-1//0
	Legend/W=$(nm)/C/N=legnd/J/A=RT/H={7,10,10}/F=0/Z=1/X=0.00/Y=25.0 "\\s("+nameofwave(waverefindexed(nm,i,3))+") First\r\\s("+nameofwave(waverefindexed(nm,round(3*(i)/4),3))+")    ·\r\\s("+nameofwave(waverefindexed(nm,round((i)/2),3))+")    ·\r\\s("+nameofwave(waverefindexed(nm,round((i)/4),3))+")    ·\r\\s("+nameofwave(waverefindexed(nm,1,3))+") Last"
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************
	
Function Displaypdiodes(startnum, endnum, hoststr)
	variable startnum
	variable endnum
	string hoststr
	
	variable red = 65535
	variable green = 0
	variable blue = 0
	variable step = floor(65535/(endnum-startnum))
	variable endwave=0
	
	Silent 1; PauseUpdate
	
	string nm
	if(strlen(hoststr))
		nm = hoststr+"#pdiodes"
	else
		nm = "pdiodes"
	endif
	
	DoWindow pdiodes
	if(V_Flag)
		killwindow pdiodes
	endif
	Display/n=pdiodes/HOST=$hoststr
	
	do
		if(waveexists($("pdiode"+num2str(startnum))))
			AppendtoGraph/W=$nm $("pdiode"+num2str(startnum))
			ModifyGraph/W=$nm rgb($("pdiode"+num2str(startnum)))=(red,green,blue)
			red-=step
			green=0
			blue+=step
			endwave+=1
		endif
		startnum+=1
	while(startnum<=endnum)
	NVAR baselinelength=root:globals:baselinelength
	NVAR sweeplength=root:globals:sweeplength
	NVAR fdur=root:globals:fdur
	getaxis/W=$nm/q bottom
	if(!V_flag)
		SetAxis/W=$nm bottom baselinelength-fdur/1000,baselinelength+fdur/500+fdur/1000
		endwave-=1
		Legend/W=$nm/C/N=legnd/J/H={7,10,10}/F=0/Z=1/X=0.00/Y=0.00 "\\s("+nameofwave(waverefindexed(nm,0,3))+") First\r\\s("+nameofwave(waverefindexed(nm,round(endwave/4),3))+")    ·\r\\s("+nameofwave(waverefindexed(nm,round(endwave/2),3))+")    ·\r\\s("+nameofwave(waverefindexed(nm,round(3*endwave/4),3))+")    ·\r\\s("+nameofwave(waverefindexed(nm,endwave-1,3))+") Last"
		//return 0
	else
		textbox/W=$nm/C/N=pdiodeErr/F=0/X=40.00/Y=40.00 "No Pdiode Waves"
		//return 1
	endif
	return 0
End

//****************************************************************
//****************************************************************
//****************************************************************

Macro DriftClamp(Prepts, Fwin, Twin, WaveList)
	Variable Prepts = 100
	variable fwin = 100
	variable twin = 100
	string WaveList = "Wavelist"
	Prompt Prepts, "Prepts"
	Prompt fwin, "Front window"
	prompt twin, "Tail window"
	Prompt wavelist, "Wavelist"
	Silent 1
	duplicate/o $("imem" + num2istr($(wavelist)[0])) base
	// base = x - pnt2x($("imem" + num2istr($(wavelist)[0])), prepts)
	base = x
	variable numpts = numpnts($("imem" + num2istr($(wavelist)[0])))
	deletepoints prepts, numpts - twin - prepts, base
	deletepoints 0, prepts - fwin, base
	duplicate/o base temp
	temp = base^2
	wavestats/q temp
	variable xxsum
	variable slo
	xxsum = v_avg
	duplicate/o base temp
	Silent 1; PauseUpdate
	variable numwaves = numpnts($(wavelist))
	iterate(NumWaves)
		base[0,fwin-1] = $("imem" + num2istr($(wavelist)[i]))[prepts - fwin + p]
		base[fwin, fwin + twin-1] = $("imem" + num2istr($(wavelist)[i]))[numpts - twin - fwin + p]
		base *= temp
		wavestats/q base
		slo = v_avg / xxsum
		$("imem" + num2istr($(wavelist)[i])) -= x * slo
		print $(wavelist)[i], slo
		slo = mean($("imem" + num2istr($(wavelist)[i])), pnt2x($("imem" + num2istr($(wavelist)[i])),prepts-fwin), pnt2x($("imem" + num2istr($(wavelist)[i])),prepts))
		$("imem" + num2istr($(wavelist)[i])) -=  slo
	loop
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro FindRange(wavename,LowLimit, UpLimit)
	String wavename
	Prompt wavename, "Wave to be sorted? "
	Variable LowLimit, UpLimit
	Prompt LowLimit, "Find values above what limit? "
	Prompt UpLimit, "Find values below what limit?"
	Silent 1
	Duplicate/O $(wavename)  sorted_value, sorted_index
	WaveStats/Q $(wavename)
	variable count = 0
	Silent 1; PauseUpdate
	iterate(V_npnts)
		if ( $(wavename)[i] > lowlimit )
			if ( $(wavename)[i] < uplimit)
				sorted_value[count] = $(wavename)[i]
				sorted_index[count] = dimlist[i]
				count=count+1
			endif
		endif
	loop
	DeletePoints (count), (V_npnts-count) , sorted_value
	DeletePoints (count), (V_npnts-count) , sorted_index
End

//****************************************************************
//****************************************************************
//****************************************************************

Macro RemoveZeros(wavelist)
	string wavelist
	Prompt wavelist, "Name of list to clean?"
	Silent 1
	Variable cnt
	cnt = numpnts($(wavelist))
	iterate(cnt)
		if ($(wavelist)[i]==0)
			Deletepoints (i), 1000, $(wavelist)
		endif
	loop
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

//Macro MeanSquared2(avewavename,varwavename)
//	String avewavename="avef45a"
//	String varwavename="varf45a"
//	Prompt avewavename, "what is the name of the average response to square and scale?"
//	Prompt varwavename, "what is the name of the variance wave?"
//	Variable varmax
//	Variable avemax
//	duplicate/o $avewavename squared
//	variable offset = mean($varwavename,0.5,1)
//	$varwavename-=offset
//	squared *= squared
//	wavestats $varwavename
//		varmax=V_max
//	wavestats $avewavename
//		avemax=V_max
//	squared*=(varmax/avemax)
//	display squared $varwavename
//	print avewavename, "*=" , (varmax/avemax)
//	print (avemax/varmax) , "photoisomerizations per flash"
//EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

//Macro Normalize( npnts1,npnts2,newwave,wavelist)
//	Variable npnts1=2220,npnts2=2320
//	Variable nsweeps = 2
//	String newwave="imem",wavelist="avelist",dum
//	Prompt newwave, "What is the wave called?"
//	Prompt wavelist,"Name of Wave List?"
//	Prompt npnts1, "Starting Pnt:"
//	Prompt npnts2, "Ending Pnt:"
//	Silent 1; PauseUpdate
//	WaveStats/Q $(wavelist)
//	nsweeps=V_npnts
//	iterate(nsweeps)
//		Print i+1
//		dum=num2istr($(wavelist)[i])
//		print dum
//		Duplicate/O $("Imem"+ num2istr($(wavelist)[i])) base
//		DeletePoints (npnts2+1), (10000), base
//		DeletePoints 0,npnts1, base
//		strlincoef={1,0}
//		FuncFit/Q/H="01" straightlinefit strlincoef base
//		Duplicate/O $("Imem"+ num2istr($(wavelist)[i])) $("ImemN"+ num2istr($(wavelist)[i]))
//		$("ImemN"+ num2istr($(wavelist)[i]))/=strlincoef[0]	
//	loop
//EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

// Take a list of numbers in a wave, e.g. 4,8,...,  and a basename, e.g. "sweep",
// Compute the areas of the waves named things like "sweep4", "sweep 8" etc.,
// between the limits begin and end.
// Create a wave to hold the resulting areas, and name it as specified
Macro ResponseAreas(waveindices,basename,resName,beginArea,endArea)
	String waveindices="nd"
	String basename="ave"
	String resName="areas"
	Variable beginArea=0.25
	Variable endArea=0.5
	Prompt waveindices,"Intensities"
	Prompt basename,"Base Name"
	Prompt resName,"Result Wave Name"
	Prompt beginArea,"beginAreaning of Area Computation"
	Prompt endArea,"endArea of Area Computation"
	Variable numint
	Silent 1
	numint=numpnts($(waveindices))
	duplicate /o $(waveindices) $(resName)
	iterate(numint)
		$(resName)[i] = mean( $( basename + num2istr($(waveindices)[i])),beginArea,endArea)
	loop
endMacro

//****************************************************************
//****************************************************************
//****************************************************************

// Take a list of numbers in a wave, e.g. 4,8,...,  and a basename, e.g. "sweep",
// Find maximum values of the waves named things like "sweep4", "sweep 8" etc.,
// Create a wave to hold the resulting peaks, and name it as specified
Macro ResponsePeaks(waveindices,basename,resName,smfact,numint)
	String waveindices="nd"
	String basename="ave"
	String resName="peaks"
	variable smfact=10
	variable numint = 6
	Prompt waveindices,"Intensities"
	Prompt basename,"Base Name"
	Prompt resName,"Result Wave Name"
	Prompt smfact, "Smoothing factor"
	Prompt numint, "Number intensities"
	Silent 1; PauseUpdate
	make/o/n=(numint) $(resName)
	duplicate/o $( basename + num2istr($(waveindices)[0])) foo
	iterate(numint)
		print (basename + num2istr($(waveindices)[i]))
		duplicate/o $(basename + num2istr($(waveindices)[i])) foo
		smooth smfact, foo
		deletepoints 0, 10, foo
		deletepoints 900, 100, foo
		wavestats/Q foo
		$(resName)[i] = V_max
	loop
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

// Take a list of numbers in a wave, e.g. 4,8,...,  and a basename, e.g. "sweep",
// Find amplitude of the waves named things like "sweep4", "sweep 8" etc.,
// using specified template for cross-correlation.
// Create a wave to hold the resulting peaks, and name it as specified
Macro ResponseAmps(waveindices,basename,resName,template, smfact,numint)
	String waveindices="nd"
	String basename="ave"
	String resName="peaks"
	String template="template"
	variable smfact=10
	variable numint = 6
	Prompt waveindices,"Intensities"
	Prompt basename,"Base Name"
	Prompt resName,"Result Wave Name"
	Prompt template,"template"
	Prompt smfact, "Smoothing factor"
	Prompt numint, "Number intensities"
	Silent 1; PauseUpdate
	make/o/n=(numint) $(resName)
	duplicate/o $( basename + num2istr($(waveindices)[0])) foo
	duplicate/o $(template) temp
	deletepoints 0, 10, temp
	deletepoints 900, 100, temp
	duplicate/o temp xx
	wavestats xx
	temp /= V_avg
	iterate(numint)
		print (basename + num2istr($(waveindices)[i]))
		duplicate/o $(basename + num2istr($(waveindices)[i])) foo
		smooth smfact, foo
		deletepoints 0, 10, foo
		deletepoints 900, 100, foo
		xx = foo * temp
		wavestats/Q xx
		$(resName)[i] = V_avg
	loop
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Function Tsat(wavename, ftime)
	string wavename//="avef0"
	variable ftime//=1.025
	variable i//=0
	variable tsat//=0
	Silent 1;PauseUpdate
	//Measure dark current as in "Measure Dark Current" 
	Variable darki
	Variable basestart//=0.5
	Variable baseend//=1.0
	Variable satstart//=1.1
	Variable satend//=1.2
	variable base, sat
	base = mean($(wavename), basestart, baseend)
	sat = mean($(wavename),satstart, satend)
	darki=sat - base
	//Measure Tsat	
	duplicate/o $wavename temp
	do
		if((mean(temp,pnt2x(temp,i),pnt2x(temp, i+5))> 0.9*darki) %& ((mean(temp,pnt2x(temp,i+5),pnt2x(temp,i+10))<0.9*darki)))
			print "     |", mean(temp,pnt2x(temp,i+5),pnt2x(temp, i+10))
			tsat=pnt2x(temp,i+5)
		endif
		i+=1
	while(tsat==0)
	print "     | Tsat:",tsat, "-", ftime,"=", tsat-ftime, "seconds; Dark current:", darki, "pA"
End

//****************************************************************
//****************************************************************
//****************************************************************

Macro WeberFechner(abs_sens, WFRes, num)
	string abs_sens = "wf_raw"
	string WFRes= "wf"
	variable num = 0
	prompt abs_sens, "Wave containing sensitivity data"
	prompt WFRes, "Result wave"
	prompt num, "Number of points"
	make/o/n=(num) $(WFRes)
	Silent 1; PauseUpdate
	iterate(num)
		$(WFRes)[i] = ($(abs_sens)[2*i+1] * 2) / ($(abs_sens)[2*i] + $(abs_sens)[2*i+2])
		print i, $(WFRes)[i], $(abs_sens)[2*i+1], $(abs_sens)[2*i], $(abs_sens)[2*i+2]
	loop
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro MichaelisFits(base, CoefWave, num)
	string base="p520_"
	string CoefWave="mich_coef"
	variable num=20
	Prompt base, "Base name"
	Prompt CoefWave, "Coefficient Wave for Michaelis fits"
	Prompt num, "Number of intensity response relations to fit"
	Silent 1; PauseUpdate
	make/o/n=(num) mich_amp
	make/o/n=(num) mich_sens
	variable fitnum
	iterate(num)
		fitnum = numpnts( $(base + num2istr(i)) )
		make/o/n=(fitnum) ndfwave
		ndfwave[0,fitnum-1] = ndf[p]
		FuncFit/H="100" michaelis $(CoefWave) $(base + num2istr(i)) /X=ndfwave
		mich_amp[i] = $(CoefWave)[2]
		mich_sens[i] = $(CoefWave)[1]
		print mich_amp[i], mich_sens[i]
	loop
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro LoadIndexWaves(nd_list, base, startnum, increment,cnt)
	string nd_list = "nd"
	string base = "r520_0_"
	variable startnum = 0, increment = 4,cnt=6
	Prompt nd_list, "List of ndfs"
	Prompt base, "Base name"
	Prompt startnum, "Star numbering at"
	Prompt increment, "Numbering increment"
	Prompt cnt, "Number of ndfs"
	Silent 1; PauseUpdate
	string CurWaveName
	iterate(cnt)
		CurWaveName = base + num2istr($(nd_list)[i])
		print CurWaveName
		make/o/n=(increment) $(CurWaveName)
		iterate(increment)
			$(CurWaveName)[i] = startnum + i
		loop
		startnum += increment
		if (i == 0) then 
		 	edit $(CurWaveName)
		else
		 	append $(CurWaveName)
		endif
	loop
	print startnum
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro MakeIndexWaves(waveindices,basename,num)
	String waveindices="nd"
	String basename="r_"
	Variable num=4 // number of waves indexed by each index wave
	Prompt waveindices,"Wave Indices"
	Prompt basename,"Base Name"
	Prompt num,"Number of Indices"
	Variable numwaves
	String names
	Silent 1
	numwaves=numpnts($(waveindices))
	iterate(numwaves)
		make /o/n=(num) $(basename + num2istr($(waveindices)[i]))
		names +=  (basename + num2istr($(waveindices)[i])) 
		if (i<numwaves-1) 
			names += ","
		endif
	loop  
	print names
endMacro

//****************************************************************
//****************************************************************
//****************************************************************

// Take a list of numbers (e.g. neutral densities (4,8,...)) and a basename, e.g. r. 
// Look up the index waves called things like r4, r8, etc, which are lists of sweep numbers.
// Average all the sweeps listed in each index wave, and create averaged waves
// with the names definted by the original and result baseName, e.g. aver8.. 
Macro ResponseAves(wavelist,basename,resBaseName,numint)
	String wavelist="nd"
	String basename="r"
	String resBaseName="ave"
	variable numint=6
	Prompt wavelist,"Intensities"
	Prompt basename,"Base Name"
	Prompt resbasename,"Result Base Name"
	Prompt numint, "Number of conditions" 
	Variable numwaves
	String theWave,resWave
	// numint=numpnts($(wavelist))
	Silent 1
	iterate(numint)
		theWave = basename + num2istr($(wavelist)[i]) // name of wave containing sweep numbers
		print theWave
		resWave =  resBaseName + theWave    // name of the averaged wave corresponding to above
		numwaves=numpnts($(theWave))
		duplicate /o $(  "Imem" + num2istr($(theWave)[0]) )   $(resWave)
		iterate (numwaves-1)
			$(resWave) += $(  "Imem" + num2istr($(theWave)[i]) )
		loop
		$(resWave) /= numwaves 
		if (i == 0) then
			display $(reswave)
		else
			append $(reswave)
		endif
	loop
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

// MODELING

// Calculate time-dependent profile of 
// hole in cGMP concentration cut by PDE
// activity x=x0 created by Rh* activity 
// whose time course is described in input
// wave.  Profile calculated by linearizing 
// differential equations for PDE, cGMP and Ca
// and solving by Fourier transforms.

Macro CGHoleHomogeneous(PDEDecay, PDE, RhDecay, RhtoPDE, Numpts, cGdark, CurOutput)
	variable PDEDecay = 2.0
	variable pde = 0.3
	variable RhDecay = 0.5
	variable RhtoPDE
	variable numpts = 2048
	variable cgdark = 14
	string CurOutput = "cur"
	Prompt PDEDecay, "PDE decay rate"
	Prompt PDE, "Basal PDE activity"
	Prompt RhDecay, "Rh* decay rate"
	Prompt RhtoPDE, "Gain of rhodopsin - PDE interaction"
	prompt numpts, "Number of points in output wave"
	prompt cgdark, "Dark cgmp concentration"
	Prompt CurOutput, "Wave for current output"
	Silent 1; PauseUpdate
	variable cgmp2cur = 8e-3
	variable prepts = 200
	make/o/n=(numpts) rh
	setscale/p x, 0, .01, "", rh
	duplicate/o rh $(CurOutput)
	duplicate/o rh temp
	deletepoints 0, prepts, rh
	rh = RhtoPDE * exp(-RhDecay * x)
	insertpoints 0, prepts, rh
	fft temp
	duplicate/o temp temprel
	duplicate/o temp tempimg
	duplicate/o temp temp2
	Redimension/R temprel
	Redimension/R tempimg
	duplicate/o temprel temppow
	temprel = pde 
	tempimg = -2 * pi * x 
	temp2 = cmplx(temprel, tempimg)
	temp2 = 1 / temp2
	temprel = PDEDecay
	tempimg = -2 * pi * x
	temp = cmplx(temprel, tempimg)
	temp = 1 / temp
	temp = -temp * temp2
	ifft temp
	Redimension/R temp
	duplicate/o temp temp2
	convolve rh temp
	temp += cgdark
	duplicate/o temp $(CurOutput)
	$(CurOutput) = cgmp2cur * (cgdark^3 - temp^3)
	duplicate/o $(CurOutput) temp
EndMacro

Macro cGConc(pdeac)
	string pdeac
	Prompt pdeac, "PDE activity"
	Silent 1; PauseUpdate
	duplicate/o $(pdeac) cg2
	cg2[0] = 1
	variable pts
	variable alpha = 0.4 * .01
	pts = numpnts(cg2)
	iterate(pts -1)
		cg2[i+1] = cg2[i] + alpha - $(pdeac)[i] * cg2[i] * .01
	loop
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

// Calculate cyclase activity from basal pde activity, basal_pde, 
// dark current at normal dark Ca concentration, darkcur, 
// normal dark cG conc, cgmp, and wave containing dark currents
// measured at different Ca concentrations (e.g. when 
// Ca clamped at different times during flash response)

Macro CyclaseActivity(idark, cgmp, basal_pde, darkcur)
	string idark
	variable cgmp, basal_pde, darkcur
	Prompt idark "Wave containing dark currents"
	Prompt cgmp, "Normal dark cGMP concentration"
	Prompt basal_pde, "Basal PDE rate"
	Prompt darkcur, "Normal dark current"
	variable npts
	npts = numpnts($(idark))
	duplicate/o $(idark) cyclase
	variable cur_con
	cur_con =  darkcur/cgmp^3
	iterate(npts)
		cyclase[i] = basal_pde * ($(idark)[i] / cur_con)^(1/3)
	loop
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro Betasub(source, id)
	string source
	variable id
	prompt source, "Mean response wave:"
	prompt id, "Dark current:"
	Silent 1; PauseUpdate
	duplicate/o $(source) beta
	beta = ln(1-beta/id)
	differentiate beta
	beta*=-1/3
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro PredictCyclaseActivity(calcium, coop, half_act, cyc_max)
	string calcium
	variable coop, half_act, cyc_max
	Prompt calcium, "Time dependent Calcium concentration"
	prompt coop, "Cooperativity of Ca on cyclase"
	prompt half_act, "Half activation of Ca effect on cyclase"
	prompt cyc_max, "Maximum cyclase activity"
	variable npts
	npts = numpnts($(calcium))
	duplicate/o $(calcium) cyclase_predict
	Silent 1; PauseUpdate
	iterate(npts)
		cyclase_predict[i] = cyc_max * (1 / (1 + ($(calcium)[i] / half_act)^coop))
	loop
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro PDEActivity(rhlp)
	string rhlp
	Prompt rhlp, "Low pass Rh activity"
	Silent 1; PauseUpdate
	variable alpha = 2 * 0.01
	duplicate/o $(rhlp) pde2
	variable pts
	pts = numpnts($rhlp)
	pde2[0] = 0
	iterate (pts-1)
		pde2[i+1]  = pde2[i] * (1 - alpha) + $(rhlp)[i]
	loop
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

// Macro to compute rhodopsin activity from experiment
// in which gain switched during flash response.
// Inputs three responses: one flash response in which gain switched, 
// one control flash response, and one response in which 
// gain switched without flash.  Each is corrected for
// compression and the extra component of the current
// change caused by the Rh* activity present at the time
// of the gain switch is isolated.
// Puts out waves with name
// like cntrlxx, switchxx, diffxx, sansxx
// where xx specified on command line.

Macro RhLifeTime(SwitchGain, Control, SansFlash1, SansFlash2, Idark, SwitchTime,OutputSuffix)
	variable SwitchGain, Control, SansFlash1, sansflash2
	variable Idark, SwitchTime, OutputSuffix
	Prompt SwitchGain, "Flash response in which gain switched"
	Prompt Control, "Control flash response"
	Prompt SansFlash1, "Gain change without flash before"
	Prompt SansFlash2, "Gain change without flash after"
	Prompt Idark, "Dark current"
	Prompt switchtime, "Time of solution switch"
	Prompt OutputSuffix, "Suffix for output waves"
	variable deadtime = 4.5
	variable slotime = 0.5
	variable baseln = 2
	variable sc1, sc2
	Silent 1; PauseUpdate
	// make working waves 
	duplicate/o $("imem" + num2istr(switchgain)) switch
	duplicate/o $("imem" + num2istr(control)) cntrl
	duplicate/o switch sans
	sans = $("imem" + num2istr(sansflash1))
	sans += $("imem" + num2istr(sansflash2))
	sans /= 2
	// scale control response to match response in which gain switched
	sc1 = mean(cntrl, baseln, switchtime + baseln)
	sc2 = mean(switch, baseln, switchtime + baseln)
	print "Scaling control response by ", sc2 / sc1
	print sc1, sc2
	cntrl *= sc2 / sc1
	// correct for compression assuming exponential saturation
	duplicate/o switch temp
	temp  = ln(1- switch/idark)
	temp -= ln(1- cntrl/idark)
	temp -= ln(1-sans/idark)
	temp *= -idark
	// normalize to flash strength 
	duplicate/o switch diff
	diff = temp
	temp = -ln(1- cntrl/idark)
	wavestats/q temp
	diff /= V_max
	// calculate maximum slope
	duplicate/o diff temp
	differentiate temp
	switchtime += deadtime
	print mean(temp, switchtime , switchtime + slotime) / idark
	duplicate/o switch $("switch" + num2istr(OutputSuffix))
	duplicate/o diff $("diff" + num2istr(OutputSuffix))
	duplicate/o sans $("sans" + num2istr(OutputSuffix)) 
	duplicate/o cntrl $("cntrl" + num2istr(OutputSuffix))
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

// NOISE ANALYSIS

Macro FiltPS(wname, spnts, epnts, avepnts)
	string wname
	Prompt wname, "Name of sweep"
	variable spnts = 10, epnts = 1000, avepnts = 5
	prompt spnts, "Start at point #"
	prompt epnts, "End at point #"
	prompt avepnts, "Average how many points"
	Silent 1; PauseUpdate
	variable tpnts
	tpnts = numpnts($(wname))
	Duplicate/O $(wname) spow
	smooth/B avepnts, spow
	$(wname)[spnts, epnts - spnts] = spow[p]
	variable nind = (epnts - spnts) / avepnts
	print nind
	spow = nan
	spow[0,spnts] = 1
	spow[epnts, tpnts-1] = 1
	iterate(nind)
		spow[spnts + i * avepnts] = 1
	loop
	$(wname) *= spow
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro PowerSpecClamp(wavelist)
	String wavelist="avelist"
	Prompt wavelist,"Wavelist?"
	Variable navesweep
	navesweep=numpnts($(wavelist))
	Silent 1; PauseUpdate
	Duplicate/O $("Imem"+ num2istr($(wavelist)[0])) resp
	deletepoints 0, 10, resp
	deletepoints 4096, 10000, resp
	make/o/n=2048 foo	
	fft resp
	Duplicate/O resp pow
	pow = 0
	duplicate/O pow pow2
	Redimension/R pow2
	iterate(navesweep)
		Duplicate/O $("Imem" + num2istr($(wavelist)[i])) resp
		deletepoints 0, 800, resp
		foo[0,2047] = resp[p]
		curvefit line foo
		foo -= (w_coef[0] + w_coef[1] * x)
		duplicate/o foo foo2
		fft foo2
		pow += foo2 * conj(foo2)
		foo[0,2047] = resp[p + 2048]
		curvefit line foo
		foo -= (w_coef[0] + w_coef[1] * x)
		duplicate/o foo foo2
		fft foo2
		pow += foo2 * conj(foo2)
		pow2 = real(pow)
		Print ($(wavelist)[i]),strlincoef[0]
		DoUpdate
	loop	
	Redimension/R pow
	pow /= (2 * navesweep)
	// convert to spectral density
	pow *= 2048 * 0.01 / (2048^2)
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro PowerSpec(wavelist, npts, prepts,tstp,drift)
	String wavelist="avelist"
	variable npts = 2048
	variable prepts = 10
	variable tstp = 0.01
	variable drift = 1
	Prompt wavelist,"Wavelist?"
	Prompt npts, "Number of points"
	Prompt prepts, "Pre points"
	Prompt tstp, "Sampling step"
	Prompt drift, "Correct for drifts (0/1)"
	Variable navesweep
	navesweep=numpnts($(wavelist))
	Silent 1; PauseUpdate
	Duplicate/O $("Imem"+ num2istr($(wavelist)[0])) resp
	deletepoints 0, prepts, resp
	deletepoints npts, 10000, resp	
	fft resp
	Duplicate/O resp pow
	pow = 0
	duplicate/O pow pow2
	Redimension/R pow2
	iterate(navesweep)
		Duplicate/O $("Imem" + num2istr($(wavelist)[i])) resp
		deletepoints 0, prepts, resp
		duplicate/o resp foo
		deletepoints npts, 10000, foo
		if (drift)
			curvefit/q line foo
			foo -= (w_coef[0] + w_coef[1] * x)
		endif
		fft foo
		pow += foo * conj(foo)
		pow2 = real(pow)
		Print $(wavelist)[i],strlincoef[0]
		DoUpdate
	loop	
	Redimension/R pow
	pow /= (navesweep)
	// convert to spectral density
	pow *= 2 * npts * tstp / (npts^2)
EndMacro

//set length
//determine number of fft samples in length
//adjust sample for drift
	//linear curve fit
//fft on adjusted sample
//powerWave += sampleFFT * conj(sampleFFT) for each sample
//pow2 = real(pow) ---not used?

//redimension/R powerWave
//powerWave /= numSamples
//spectral density

Function/WAVE MSpecF(wavenm, startpt, length)
	WAVE wavenm
	variable startpt //in points (can be referenced from a curson position)
	variable length //seconds
	
	string msStr="ms;msec;"
	
	//re-scale to Seconds
	if(findlistitem(stringbykey("XUNITS",waveinfo(wavenm,0)),msStr)>0)
		setscale/P x, 0,deltax(wavenm)/1000, "S", wavenm
	endif
	
	//	variable endpt=length/deltax(wavenm)+startpt
	variable endpt=startpt+length/deltax(wavenm)
	if((endpt-startpt-1)/2-trunc((endpt-startpt-1)/2)>0)
		endpt-=1
	endif
	
	// do fft
	fft/OUT=3/RP=[startpt,endpt]/DEST=$(nameofwave(wavenm)+"_FFT") wavenm
	WAVE W_FFT=root:$(nameofwave(wavenm)+"_FFT")

	// scale fft
	W_FFT/=((endpt-startpt)/2) //for 2-sided spectrum, knowing that the x(o) point will be off by 2X
	Setscale/P x 0, deltax(W_FFT), "Hz", W_FFT
	Setscale/P y 0, 1, stringbykey("DUNITS",waveinfo(wavenm,0)), W_FFT
	
	SetNote(W_FFT, "FFT Source Wave", nameofwave(wavenm))
	SetNote(W_FFT, "FFT Start Point", num2str(startpt))
	SetNote(W_FFT, "FFT Start Time", num2str(startpt*deltax(wavenm)))
	SetNote(W_FFT, "FFT Length", num2str(length))
	SetNote(W_FFT, "FFT Frequency Resolution", num2str(1/length))
	SetNote(W_FFT, "FFT DC Level", num2str(W_FFT[0]/2))

	return W_FFT
end

Function/WAVE GenMag(wavenm, startpt, length, [inputHz])
	wave wavenm
	variable startpt
	variable length
	variable inputHz
	
	WAVE mag=MSpecF(wavenm,startpt,length)
	
	// append FFT info to wave
	wavestats/Q mag
	
	SetNote(mag, "FFT Maximum Magnitude", num2str(V_max))
	SetNote(mag, "FFT Magnitude Units", stringbykey("DUNITS",waveinfo(mag,0)))
	SetNote(mag, "FFT Maximum Magnitude Frequency", num2str(V_maxloc))
	
	print num2str(mag[0]/2)+" at 0Hz (DC level)" //note that this is an absolute value
	print "Maximum Magnitude = "+num2str(V_max)+stringbykey("DUNITS",waveinfo(mag,0))+" at frequency "+num2str(V_maxloc)+"Hz"
	print "Frequency Resolution = "+num2str(1/length)+"Hz"
	if(inputHz)
		print "Magnitude at "+num2str(inputHz)+"Hz is "+num2str(mag[x2pnt(mag,inputHz)])
	endif
	
	mag[0]=nan // effectively delete the DC level since it will usually dominate the spectrum
	
	return mag	
//	TextBox/C/N=info/X=0.00/Y=0.00/A=MC num2str(mag[0]/2)+" at 0Hz (DC level)\rMaximum magnitude = "+num2str(V_max)+stringbykey("DUNITS",waveinfo(mag,0))+" at frequency "+num2str(V_maxloc)+"Hz\rFrequency resolution = "+num2str(1/((startpt+length/deltax(wavenm)-startpt)*deltax(wavenm)))+"Hz"
end

Function/WAVE PSpecF(origwave, startpt, length)
	WAVE origwave
	variable length
	variable startpt
	
	string msStr="ms;msec;"
	
	//re-scale to Seconds
	if(findlistitem(stringbykey("XUNITS",waveinfo(origwave,0)),msStr)>0)
		setscale/P x, 0,deltax(origwave)/1000, "S", origwave
	endif
	
	Duplicate/O origwave wavenm
	WAVE wavenm=root:wavenm
	
	//identify scaling
	if(stringmatch("ms",stringbykey("XUNITS",waveinfo(origwave,0))))
		//set scale to S
		SetScale/P x 0,deltax(wavenm)/1000, "S", wavenm
	endif
	
	variable endpt = startpt+length/deltax(wavenm)
	if((endpt-startpt-1)/2-trunc((endpt-startpt-1)/2)>0)
		endpt-=1
	endif
	
//	curvefit/q line wavenm
//	wavenm -= (w_coef[0] + w_coef[1]*x)
	
	fft/OUT=1/RP=[startpt,endpt]/DEST=$(nameofwave(origwave)+"_FFT") wavenm
	WAVE/C W_FFT=root:$(nameofwave(origwave)+"_FFT")
	duplicate/o/c W_FFT $(nameofwave(origwave)+"_pow")
	WAVE/C pow=root:$(nameofwave(origwave)+"_pow")
	
	pow=W_FFT*conj(W_FFT)
	pow/=1 //placeholder
	variable delta=deltax(wavenm)
	pow*=2*length/((length/delta)^2)
	
	redimension/R pow
	
	SetNote(pow, "FFT Source Wave", nameofwave(origwave))
	SetNote(pow, "FFT Start Point", num2str(startpt))
	SetNote(pow, "FFT Start Time", num2str(startpt*deltax(origwave)))
	SetNote(pow, "FFT Length", num2str(length))
	SetNote(pow, "FFT Frequency Resolution", num2str(1/length))
	SetNote(mag, "FFT DC Level", num2str(W_FFT[0]/2))
	
//	pow=real(pow)
	pow[0]=nan
	killwaves/Z W_FFT, wavenm

	return pow
end

Function DomFreq(wavenm, startpt, length) //find dominant frequency
	WAVE wavenm
	variable startpt
	variable length
	
	variable endpt = startpt+length/deltax(wavenm)
	if((endpt-startpt-1)/2-trunc((endpt-startpt-1)/2)>0)
		endpt-=1
	endif
	
	fft/OUT=1/RP=[startpt,endpt]/DEST=W_FFT wavenm
	WAVE/C W_FFT=root:W_FFT
	duplicate/o/c W_FFT pow
	WAVE/C pow=root:pow
	
	pow=W_FFT*conj(W_FFT)
	pow/=1 //placeholder
	variable delta=deltax(wavenm)
	pow*=2*length/((length/delta)^2)
	
	redimension/R pow
//	pow=real(pow)
	pow[0]=nan
	
	Findlevel/Q pow wavemax(pow, pnt2x(pow,1),+inf)

	killwaves/Z pow, W_FFT
	return round(V_LevelX*100)/100
end

Function DomFreqPow(wavenm, startpt, length) //find dominant frequency
	WAVE wavenm
	variable startpt //points
	variable length //seconds
	
	variable endpt = startpt+length/deltax(wavenm)
	if((endpt-startpt-1)/2-trunc((endpt-startpt-1)/2)>0)
		endpt-=1
	endif
	
	fft/OUT=1/RP=[startpt,endpt]/DEST=W_FFT wavenm
	WAVE/C W_FFT=root:W_FFT
	duplicate/o/c W_FFT pow
	WAVE/C pow=root:pow
	
	pow=W_FFT*conj(W_FFT)
	pow/=1 //placeholder
	variable delta=deltax(wavenm)
	pow*=2*length/((length/delta)^2)
	
	redimension/R pow
//	pow=real(pow)
	pow[0]=nan
	
	wavestats/q/R=(1,+inf) pow
	variable power = V_max//wavemax(pow, pnt2x(pow,1),+inf)
	killwaves/Z pow, W_FFT
	return power
end

//****************************************************************
//****************************************************************
//****************************************************************

Macro PowerSpecVar(wavelist)
	String wavelist="avelist"
	Prompt wavelist,"Wavelist?"
	Variable navesweep
	navesweep=numpnts($(wavelist))
	Silent 1; PauseUpdate
	Duplicate/O $("Imem"+ num2istr($(wavelist)[0])) resp
	deletepoints 0, 10, resp
	deletepoints 2048, 10000, resp	
	fft resp
	Duplicate/O resp pow
	pow = 0
	duplicate/O pow pow2
	Redimension/R pow2
	duplicate/o pow2 powvar
	iterate(navesweep)
		Duplicate/O $("Imem" + num2istr($(wavelist)[i])) resp
		deletepoints 0, 10, resp
		duplicate/o resp foo
		deletepoints 2048, 10000, foo
		curvefit line foo
		foo -= (w_coef[0] + w_coef[1] * x)
		fft foo
		pow += foo * conj(foo)
		pow2 = real(pow)
		Print $(wavelist)[i]
		DoUpdate
	loop	
	Redimension/R pow
	pow /= (navesweep)
	iterate(navesweep)
		Duplicate/O $("Imem" + num2istr($(wavelist)[i])) resp
		deletepoints 0, 10, resp
		duplicate/o resp foo
		deletepoints 2048, 10000, foo
		curvefit line foo
		foo -= (w_coef[0] + w_coef[1] * x)
		fft foo
		foo = foo * conj(foo)
		pow2= real(foo)
		powvar += (pow2 - pow)^2
		Print $(wavelist)[i]
		DoUpdate
	loop	
	Redimension/R pow
	Redimension/R powvar
	powvar /= (navesweep * (navesweep-1))
	// convert to spectral density
	pow *= 2 * 2048 * 0.01 / (2048^2)
	powvar *= (2 * 2048 * 0.01 / (2048^2))^2
	powvar = powvar^(1/2)
EndMacro


Macro PowerSpecVar2(wavelist) //for LDnoise macro...
	String wavelist="avelist"
	Prompt wavelist,"Wavelist?"
	Variable navesweep
	Variable i=0
	navesweep=numpnts($(wavelist))
	Silent 1; PauseUpdate
	Duplicate/O $("Imem"+ num2istr($(wavelist)[0])) resp
	//tempcode
	wavestats/q resp
//	deletepoints 0, 10, resp
//	deletepoints 2048, 10000, resp	
	fft resp
	Duplicate/O resp pow
	pow = 0
	duplicate/O pow pow2
	Redimension/R pow2
	duplicate/o pow2 powvar
//	iterate(navesweep)
		Duplicate/O $("Imem" + num2istr($(wavelist)[i])) resp
//		deletepoints 0, 10, resp
		duplicate/o resp foo
//		deletepoints 2048, 10000, foo
		curvefit line foo
		foo -= (w_coef[0] + w_coef[1] * x)
		fft foo
		pow += foo * conj(foo)
		pow2 = real(pow)
		Print $(wavelist)[i]
		DoUpdate
//	loop	
	Redimension/R pow
	pow /= (navesweep)
//	iterate(navesweep)
		Duplicate/O $("Imem" + num2istr($(wavelist)[i])) resp
//		deletepoints 0, 10, resp
		duplicate/o resp foo
//		deletepoints 2048, 10000, foo
		curvefit line foo
		foo -= (w_coef[0] + w_coef[1] * x)
		fft foo
		foo = foo * conj(foo)
		pow2= real(foo)
		powvar += (pow2 - pow)^2
		Print $(wavelist)[i]
		DoUpdate
//	loop	
	Redimension/R pow
	Redimension/R powvar
	powvar /= (navesweep * (navesweep-1))
	// convert to spectral density
	pow *= 2 * V_npnts * 0.005 / (V_npnts^2) //V_npnts was 2048...changed with wavestats/q resp code above...0.005 was 0.01
	powvar *= (2 * V_npnts * 0.005 / (V_npnts^2))^2 //V_npnts was 2048...changed with wavestats/q resp code above...0.005 was 0.01
	powvar = powvar^(1/2)
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

// SINGLE PHOTON

Macro CheckFit(nwave)
	Variable nwave
	Prompt nwave, "Number of Wave to check:"
	Variable prepts = 50
	Variable fitpts = 600
	Variable tailwin
	Variable bxxsum
	Variable bxysum
	Variable totpts
	Silent 1; PauseUpdate
	Duplicate/O $("Imem"+ num2istr(nwave)) dim
	totpts = numpnts(dim)
	tailwin = totpts - prepts - fitpts
	Duplicate/O dim basetemp
	basetemp =  x
	bxxsum = 0
	iterate(prepts)
		bxxsum += basetemp[i] * basetemp[i]
	loop
	iterate(totpts - tailwin)
		bxxsum += basetemp[tailwin + i] * basetemp[tailwin + i]
	loop
	// fit baseline drift
	bxysum = 0
	iterate(prepts)
		bxysum += basetemp[i] * dim[i]
	loop
	iterate(totpts - tailwin)
		bxysum += basetemp[tailwin + i] * dim[tailwin + i]
	loop
	// dim -= x * bxysum / bxxsum
	DeletePoints 0,prepts,dim
	DeletePoints fitpts,totpts - fitpts - prepts, dim
	Duplicate/O dim pfit
	FuncFit/Q/H="001" poisson_filter sfcoef dim /D = pfit
	Duplicate/O dim temp
	temp = dim - pfit
	temp = temp * temp
	WaveStats/Q temp
	print V_avg
	display dim, pfit
EndMacro	

//****************************************************************
//****************************************************************
//****************************************************************

Macro CompShape()
	Variable numswp
	Variable prepts = 100
	Variable fitpts = 400
	Variable tailwin = 100
	Variable bxxsum
	Variable bxysum
	Variable totpts
	Silent 1; PauseUpdate
	numswp = numpnts(positives)
	Duplicate/O  positives posamp
	Duplicate/O positives postau
	Duplicate/O positives posint
	Duplicate/O positives poschi2
	Duplicate/O positives postpk
	Duplicate/O $("Imem"+ num2istr(positives[0])) dim
	totpts = numpnts(dim)
	tailwin = totpts - prepts - fitpts
	Duplicate/O dim basetemp
	Duplicate/O dim pfit
	Duplicate/O dim temp
	DeletePoints 0,prepts,pfit
	DeletePoints fitpts,totpts - fitpts - prepts, pfit
	make/O/N=(prepts + tailwin) base
	iterate(numswp-1)
		base[0,prepts-1] = dim[p]
		base[prepts, prepts + tailwin - 1] = dim[p + totpts - tailwin - prepts]
		WaveStats/Q base
		dim -= V_avg
		DeletePoints 0,prepts,dim
	  	DeletePoints fitpts,totpts - fitpts - prepts, dim
		FuncFit/Q/H="001" poisson_filter sfcoef dim /D=pfit
		temp = dim
		Integrate temp
		posint[i] = temp[fitpts - 1]
		temp = dim
		Smooth 50, temp
		WaveStats/Q temp
		postpk[i] = V_MaxLoc
		dim = dim - pfit
		dim = dim * dim
		WaveStats/Q dim
		posamp[i] = sfcoef[0]
		postau[i] = sfcoef[1]
		poschi2[i] = V_avg  
		Print positives[i],posamp[i],postau[i],postpk[i],posint[i],poschi2[i]
		Duplicate/O $("Imem"+ num2istr(positives[i+1])) dim 	
	loop
EndMacro	

//****************************************************************
//****************************************************************
//****************************************************************

Macro DimFlashFit()
	String template = "fit"
	Variable numswp
	Variable xxsum
	Variable xysum
	Variable bxxsum
	Variable bxysum
	Variable prepts = 200
	Variable fitpts = 500
	Variable tailwin = 1
	Variable totpts
	Silent 1; PauseUpdate
	numswp = numpnts(avelist)
	Duplicate/O $("Imem"+ num2istr(avelist[0])) dim
	totpts = numpnts(dim)
	make/O/N=(prepts + tailwin) base
	Duplicate/O dim xx
	Duplicate/O dim resid
	Duplicate/O dim residvars
	Duplicate/O avelist dimamps
	DeletePoints numswp,1,dimamps
	Duplicate/O avelist dimvars
	Duplicate/O $template temp
	Duplicate/O dim basetemp
	Duplicate/O temp temp2
	DeletePoints 0,prepts,xx
	DeletePoints fitpts,totpts - fitpts - prepts, xx
	Duplicate/O xx xy
	DeletePoints 0,prepts,temp
	DeletePoints fitpts,totpts - fitpts - prepts, temp
	xx = temp * temp
	WaveStats/Q xx
	xxsum = V_avg
	resid = 0
	residvars = 0
	iterate(numswp-1)
		base[0,prepts-1] = dim[p]
		base[prepts, prepts + tailwin - 1] = dim[p + totpts - tailwin - prepts]
		WaveStats/Q base
		dim -= V_avg
		DeletePoints 0,prepts,dim
	  	DeletePoints fitpts,totpts - fitpts - prepts, dim
		xy = temp * dim
		WaveStats/Q xy
		xysum = V_avg
		dimamps[i] = xysum / xxsum
		temp2 = temp * dimamps[i]
		// Duplicate/O   dim  $("dim" + num2str(avelist[i]))
		// Duplicate/O   temp2  $("fit" + num2str(avelist[i]))
		temp2 -= dim
		resid += temp2
		temp2  = temp2 * temp2
		residvars += temp2
		WaveStats/Q temp2
		dimvars[i]  = V_avg
		Print avelist[i], dimamps[i],  dimvars[i]
		Duplicate/O $("Imem"+ num2istr(avelist[i+1])) dim 	
	loop
	Duplicate/O dimamps dimhist
	Histogram/B={-1,.05,80} dimamps dimhist
	resid /= numswp
	residvars /= numswp
	//display resid
EndMacro	

//****************************************************************
//****************************************************************
//****************************************************************

Macro MakeHisto(wavelist)
	String wavelist = "f48"
	Prompt wavelist, "List of dim flashes"
	Variable numswp
	Silent 1; PauseUpdate
	numswp = numpnts($(wavelist))
	duplicate/o $(wavelist) dimamps dimhisto
	iterate (numswp-1)
		Duplicate/O $("Imem"+ num2istr($(wavelist)[i])) dim 
		//dim=-ln(1-dim/22.8)
		Smooth 50, dim
		Wavestats/Q/R=(1,2) dim
		dimamps[i]= V_max
	loop
	Histogram/B={-0.3,0.1,80} dimamps, dimhisto
	Display dimhisto
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro DimPk(wavelist, totpts, prepts, tailwin)
	String wavelist = "f48"
	Variable prepts = 100
	Variable fitpts = 400
	Variable tailwin = 100
	Variable totpts = 500
	Prompt wavelist, "List of waves"
	Prompt totpts, "Total number of points per wave"
	Prompt prepts, "Number of prepts"
	Prompt tailwin, "Number of tail points"
	Variable numswp
	Silent 1; PauseUpdate
	numswp = numpnts($(wavelist))
	Duplicate/O $("Imem"+ num2istr($(wavelist)[0])) dim
	totpts = numpnts(dim)
	make/O/N=(prepts + tailwin) base
	Duplicate/O $(wavelist) dimamps
	DeletePoints numswp,1,dimamps
	Duplicate/O $(wavelist) dimvars
	iterate(numswp-1)
		base[0,prepts-1] = dim[p]
		base[prepts, prepts + tailwin - 1] = dim[p + totpts - tailwin - prepts]
		WaveStats/Q base
		dim -= V_avg
		smooth 50, dim
		DeletePoints 0,prepts,dim
	  	DeletePoints fitpts,totpts - fitpts - prepts, dim
	  	WaveStats/Q dim
	  	dimamps[i] = V_max
		Print $(wavelist)[i], dimamps[i]
		Duplicate/O $("Imem"+ num2istr($(wavelist)[i+1])) dim 	
	loop
	Duplicate/O dimamps dimhist
	Histogram/B={-1,.05,80} dimamps dimhist
	//resid /= numswp
	//residvars /= numswp
	//display resid
EndMacro	

//****************************************************************
//****************************************************************
//****************************************************************

Macro Piezoslope(ndfsort, ssize, deltat, wavelist)
	Variable ndfsort = 3
	Variable ssize = 0
	Variable deltat = 0.05
	String wavelist="list"
	Prompt ndfsort, "NDF?"
	Prompt ssize, "Piezo step size to sort?"
	Prompt deltat, "Piezo delay (sec)?"
	Prompt wavelist, "Basename of list to generate?"
	Make/o/n=(numwaves) singlea singleb bothab discard
	Duplicate/o imem1 avea aveb aveab abminusa avediscrd
	avea = 0
	aveb = 0
	aveab=0
	abminusa = 0
	avediscrd = 0
	Variable cnt0=0
	Variable cnt1=0
	Variable cnt2=0
	Variable cnt3=0
	//tflash = (prepts+piezodelaypts)*saminterval or (200 + 5)*0.01
	Variable tflash = 2.05
	Variable saminterval = 0.01
	Silent 1
	iterate(numwaves)
		if (AlmostEqual(ndfsort, $("imemhead" + num2istr (i +1))[2], 0.0001)==1) then 
			if  ($("imemhead" + num2istr (i +1))[4] == ssize)) then
				// remove corrupted responses from consideration and list them
				if ($("imemhead" +num2istr(i+1))[10] ==2) then
					discard[cnt0]=i+1
					cnt0+=1
					avediscrd +=  ($"imem"+num2istr(i+1))
				endif
				if (($("imemhead" +num2istr(i+1))[10] ==0) %& ($("imemhead" +num2istr(i+1))[6 ] != 0)) then
					if ($("imemhead" +num2istr(i+1))[5] == deltat*1000) then
						// sort responses by piezo position and average
						if ($("imemhead" +num2istr(i+1))[6 ] == 2)   then
							singlea[cnt1] = i+1
							cnt1 += 1
							avea +=($"imem"+num2istr(i+1))
						endif
						if ($("imemhead" +num2istr(i+1))[6 ] == 3) then
							singleb[cnt2]=i+1
							cnt2 += 1
							aveb +=($"imem"+num2istr(i+1))
						endif
						if ($("imemhead" +num2istr(i+1))[6 ] == 1) then
							bothab[cnt3]=i+1
							cnt3 += 1
							aveab +=($"imem"+num2istr(i+1))
						endif
					endif
				endif
			endif
		endif	
	loop
	avea /=cnt1
	aveb/=cnt2
	aveab /=cnt3
	//deletepoints cnt0, numwaves, discard
	deletepoints cnt1, numwaves, singlea
	deletepoints cnt2, numwaves, singleb
	deletepoints cnt3, numwaves, bothab
	duplicate/o singlea $((wavelist) + "a")
	duplicate/o singleb $((wavelist) + "b")
	duplicate/o bothab $((wavelist) + "ab")
	duplicate/o discard $((wavelist) + "discrd")
	//Normalize first individual response
	Variable normscale = 0
	Variable aveaa = 0
	Variable aveaab = 0
	Duplicate/o avea norma
	Duplicate/o aveab normab
	Deletepoints (tflash+deltat)/saminterval, 10000, norma
	Deletepoints (tflash+deltat)/saminterval, 10000, normab
	Deletepoints 0, tflash/saminterval, norma
	Deletepoints 0, tflash/saminterval, normab
	Duplicate/o norma atimesab
	atimesab *= normab
	norma *= norma
	integrate atimesab
	integrate  norma
	Wavestats/Q atimesab
	aveaab = V_avg
	Wavestats/Q norma
	aveaa = V_avg
	normscale = aveaab/aveaa
	avea *= normscale
	print "Normalized avea by factor", normscale
	variable basln
	variable fwin = 0.5
	abminusa = aveab-avea
	basln = mean(aveb, (tflash + deltat - fwin), (tflash + deltat))
	aveb -=  basln
	print basln, (tflash + deltat - fwin), (tflash + deltat) 
	basln = mean(abminusa, (tflash + deltat - fwin) , (tflash + deltat))
	abminusa -=  basln
	print basln
	duplicate/o avea $((wavelist) + "avea")
	duplicate/o aveb $((wavelist) + "aveb")
	duplicate/o aveab $((wavelist) + "aveab")
	duplicate/o abminusa $((wavelist) + "abminusa")
	duplicate/o avediscrd $((wavelist) + "avediscrd")
	KillWaves discard avediscrd
	//Display averaged responses	
	display/M/W=(18,0,30,10) $((wavelist)+"avea"), $((wavelist)+"aveb") , $((wavelist)+"aveab")
	AppendToGraph/C=(0,0,65535) $((wavelist)+"abminusa") 
	DoWindow/K inter
	DoWindow/C inter	
	//killwaves/Z singlea, singleb, bothab
	print cnt1, "responses of those specifications listed in" , wavelist, "a"
	print cnt2, "responses of those specifications listed in" , wavelist, "b"
	print cnt3, "responses of those specifications listed in" , wavelist, "ab"
	//Scale traces to determine degree of interaction	
	Variable scale = 0
	Variable sab = 0
	Variable sb = 0
	Duplicate/o aveb foo
	Duplicate/o abminusa moo
	Deletepoints (tflash+deltat + 0.8)/saminterval, 10000, foo
	Deletepoints (tflash+deltat + 0.8)/saminterval, 10000, moo
	Deletepoints 0, (tflash+deltat+0.3)/saminterval, foo
	Deletepoints 0, (tflash+deltat+0.3)/saminterval, moo
	Duplicate/o foo foomoo
	foomoo *= moo
	foo *= foo
	integrate foomoo
	integrate  foo
	Wavestats/Q foomoo
	sab = V_avg
	Wavestats/Q foo
	sb = V_avg
	scale = sb/sab
	duplicate/o abminusa $((wavelist)+"scaled")
	$((wavelist)+"scaled")*=scale
	AppendToGraph/C=(0,65535,0) $((wavelist)+"scaled") 
	Label left "pA"; Label bottom "sec"
	print "averaged sum of ", cnt1, " independent flashes (black)"
	print "averaged ", cnt2, " simultaneous flashes (blue)"
	print "Ndf: ", ndfsort,  "Stepsize:  " , ssize
	print "Delay:" , deltat
	print "Scaling factor = ", scale
	DoUpdate
End	

//****************************************************************
//****************************************************************
//****************************************************************

Macro Piezosort(ndfsort, ssize, wavelist)
	Variable ndfsort=3
	Variable ssize=0
	String wavelist="list"
	Prompt ndfsort, "NDF?"
	Prompt ssize, "Piezo step size to sort?"
	Prompt wavelist, "Basename of list to generate?"
	Make/o/n=(numwaves) singlea singleb bothab discard
	Make/o/n=(samplingpts) avea aveb aveab aveaplusb avediscrd
	avea = 0
	aveb = 0
	aveaplusb = 0
	avediscrd = 0
	Variable cnt0=0
	Variable cnt1=0
	Variable cnt2=0
	Variable cnt3=0
	Variable scale=0
	Silent 1
	//PauseUpdate
	display/M/W=(0,0,15,10)  
	iterate(numwaves)
		if  (($("imemhead" + num2istr (i +1))[2] == ndfsort) %& ($("imemhead" + num2istr (i +1))[4] == ssize)) then
			// remove corrupted responses from consideration and list them
			if ($("imemhead" +num2istr(i+1))[10] ==2) then
				discard[cnt0]=i+1
				cnt0+=1
				avediscrd +=  ($"imem"+num2istr(i+1))
			endif
			//Display individual responses for consideration
			if (($("imemhead" +num2istr(i+1))[10] ==0) %& ($("imemhead" +num2istr(i+1))[6 ] != 0)) then
				AppendToGraph/C=(0,0,65535)  $("imem"+num2istr(i+1))
				DoWindow/F/C resp
				//DoWindow/K resp
				Sleep/s 1
				RemovefromGraph $("imem"+num2istr(i+1))
				// sort responses by piezo position and average
				if ($("imemhead" +num2istr(i+1))[6 ] == 2)   then
					singlea[cnt1] = i+1
					cnt1 += 1
					avea +=($"imem"+num2istr(i+1))
				endif
				if ($("imemhead" +num2istr(i+1))[6 ] == 3) then
					singleb[cnt2]=i+1
					cnt2 += 1
					aveb +=($"imem"+num2istr(i+1))
				endif
				if ($("imemhead" +num2istr(i+1))[6 ] == 1) then
					bothab[cnt3]=i+1
					cnt3 += 1
					aveab +=($"imem"+num2istr(i+1))
				endif
			endif
		endif
	loop
	avea /=cnt1
	aveb/=cnt2
	aveab /=cnt3
	aveaplusb = avea+aveb
	//deletepoints cnt0, numwaves, discard
	deletepoints cnt1, numwaves, singlea
	deletepoints cnt2, numwaves, singleb
	deletepoints cnt3, numwaves, bothab
	duplicate/o singlea $((wavelist) + "a")
	duplicate/o singleb $((wavelist) + "b")
	duplicate/o bothab $((wavelist) + "ab")
	duplicate/o discard $((wavelist) + "discrd")
	duplicate/o avea $((wavelist) + "avea")
	duplicate/o aveb $((wavelist) + "aveb")
	duplicate/o aveab $((wavelist) + "aveab")
	duplicate/o aveaplusb $((wavelist) + "aplusb")
	duplicate/o avediscrd $((wavelist) + "avediscrd")
	KillWaves discard avediscrd
	//Display averaged responses	
	display/M/W=(18,0,30,10) $((wavelist)+"avea"), $((wavelist)+"aveb") , $((wavelist)+"aveab")
	AppendToGraph/C=(0,0,65535) $((wavelist)+"aplusb") 
	DoWindow/K inter
	DoWindow/C inter	
	//killwaves/Z singlea, singleb, bothab
	print cnt1, "responses of those specifications listed in" , wavelist, "a"
	print cnt2, "responses of those specifications listed in" , wavelist, "b"
	print cnt3, "responses of those specifications listed in" , wavelist, "ab"
	//Scale traces to determine degree of interaction	
	duplicate/O $((wavelist)+"aveab") foo moo
	foo=0
	moo=0
	foo=$((wavelist)+"aveab") * $((wavelist)+"aplusb")
	moo=$((wavelist)+"aveab")^2
	scale=(mean(foo, 200, 400)/mean(moo,200,400))
	duplicate/o aveab $((wavelist)+"scaled")
	$((wavelist)+"scaled")=aveab*scale
	AppendToGraph/C=(0,65535,0) $((wavelist)+"scaled") 
	SetScale/P x 0,0.01,"", $((wavelist)+"avea"), $((wavelist)+"aveb") , $((wavelist)+"aveab"), $((wavelist)+"aplusb"), $((wavelist)+"scaled") 
	print "ndf: ", ndfsort,  "Stepsize:  " , ssize
	print "Scaling factor:", scale
End

//****************************************************************
//****************************************************************
//****************************************************************

Macro QHist()
	Variable numswp
	Variable fwin = 80
	Variable prepts = 200
	Variable fitpts = 300
	Variable twin = 80
	Variable totpts
	Variable slo
	Variable xxsum
	Silent 1; PauseUpdate
	numswp = numpnts(avelist)
	Duplicate/O $("Imem"+ num2istr(avelist[0])) dim
	totpts = numpnts(dim)
	make/O/N=(fwin + twin) base
	Duplicate/O avelist dimqs
	Duplicate/O avelist dimqs2
	Duplicate/O avelist dimqs3
	DeletePoints numswp,1,dimqs
	Duplicate/O dim basetemp
	basetemp = x
	deletepoints prepts, fitpts, basetemp
	deletepoints 0, prepts-fwin, basetemp
	Deletepoints, fwin + twin, 1000, basetemp
	Duplicate/O basetemp xx
	xx *= xx
	WaveStats/Q xx
	xxsum = V_Avg
	iterate(numswp - 1)
		dimqs2[i] =  area(dim, 2.0, 5.0)
		dim -= mean(dim, 1.2, 2.0)
		dimqs3[i] = area(dim, 2.0, 5.0)
		base[0,fwin-1] = dim[prepts + fitpts + p]
		base[fwin, fwin + twin - 1] = dim[p + totpts - twin - fwin]
		base *= basetemp
		WaveStats/Q base
		slo = V_Avg / xxsum
		dim -= slo * x
		DeletePoints 0,prepts,dim
	  	DeletePoints fitpts,totpts - fitpts - prepts, dim
		// Duplicate/O   dim  $("dim" + num2str(avelist[i]))
		dimqs[i] = area(dim, 0, fitpts * .01)
		Print avelist[i], dimqs[i], dimqs2[i], dimqs3[i], slo
		Duplicate/O $("Imem"+ num2istr(avelist[i+1])) dim 	
	loop
	Histogram/B={-4,.25,40} dimqs dimhist
EndMacro	

//****************************************************************
//****************************************************************
//****************************************************************

//MACROS TO DO WITH FILTERING BY USE OF FFT
Function log2(val)
	variable val
	return ln(val)/ln(2)
end

//****************************************************************
//****************************************************************
//****************************************************************

Function CeilPwr2(x)
	variable x
	return 2^(ceil(log2(x)))
end

//****************************************************************
//****************************************************************
//****************************************************************

// brings the first graph window containing the given wave to the front.  If no such window is found
// then one is created.
Proc BringDestFront(w)
	string w
	string win
	variable winIndex,didit=0
	CheckDisplayed /A $w
	if(V_flag)					// if displayed somewhere, need to know if is graph & bring to front if so
		do
			win=WinName(winIndex, 1)		// name of top graph window
			if( cmpstr(win,"") == 0 )
				break;							// no more graph wndows
			endif
			DoWindow /F $win
			CheckDisplayed  $w
			if(V_Flag)
				didit= 1
				break
			endif
			winIndex += 1
		while(1)				// exit via break
	endif
	if(!didit)
		Display $w				// if not displayed anywhere then ok to create a new window
	endif
end

//****************************************************************
//****************************************************************
//****************************************************************

//ïïïïïïïïïïïïïï FFT based fast convolution & correlationïïïïïïïïïïïïï
// Correlate a source wave into a destination wave.
// Source wave is unchanged.  Source and dest can be the same for autocorrelation.
// Does only linear correlation.
// REQUIRES: CeilPwr2()
//
Macro Correlate1(srcw,destw)
	string srcw,destw
	Prompt srcw "source wave"
	Prompt destw "destination wave"
	Prompt srcw "source wave:",popup WaveList("*",";","")
	Prompt destw "destination wave",popup WaveList("*",";","")
	silent 1; PauseUpdate
	Make/O/N=2 dummyscales; CopyScales/P $destw dummyscales
	variable npFinal= numpnts($srcw)+numpnts($destw)-1
	variable npTmp= CeilPwr2(npFinal)
	Duplicate/o $srcw fctmp
	Redimension/n=(npTmp) fctmp,$destw
	FFT fctmp; FFT $destw
	$destw *= conj(fctmp)
	IFFT $destw
	CopyScales/P  dummyscales $destw
	rotate numpnts($srcw)-1,$destw
	Redimension/n=(npFinal) $destw
	KillWaves fctmp,dummyscales
end

//****************************************************************
//****************************************************************
//****************************************************************

Function mag(x)
	Variable x
	if(x<0)
		return (x*-1)
	else 
		return x
	endif
end

//****************************************************************
//****************************************************************
//****************************************************************

Macro Gaussian(freq, sd, fw)
	Variable freq = 100
	Variable sd = 10
	String fw = "filterx"
	Prompt freq "Sample freq (in Hz): "
	Prompt sd "SD of Gaussian (in ms): "
	Prompt fw "Store filter wave as: "
	Variable/G freq
	Variable/G sd
	String/G fw
	MakeFilter(freq, sd, fw)
	Convolve1()
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro MakeFilter(freq, sd, fw)
	Variable freq, sd
	String fw
	Variable num, int
	num = freq
	Make/O/N=(num) $fw
	SetScale/P x -0.5,(1/freq),$fw
	$fw = exp(-( ((x)/(sqrt(2)*(sd/1000)))^2))
	int = mean($fw, -0.5, 0.49)
	$fw/= (int*freq)
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

//deletes dirst and last 1sec of record to remove end-effects
Macro Convolve1(destw,mode, fw)
	string destw, fw
	Prompt destw "wave to filter",popup WaveList("*",";","")
	Prompt fw "filter wave:",popup WaveList("*",";","")
	variable mode=3
	Prompt mode "mode:",popup "Circular;Linear N1+N2-1 pts;acausal linear, N2 pts"
	silent 1; PauseUpdate
	variable npFinal,npTmp,start,npMax=2000,nSeg,tt
	variable nSrc= numpnts($fw), nDest= numpnts($destw)
	string sw="fctmp1",dw="fctmp2",fw="fctmp3"
	Make/O/N=2 dummyscales; CopyScales/P $destw dummyscales
	if( mode!=1 )
		npFinal= nDest+nSrc-1
		Redimension/N=(npFinal) $destw	// zero pad
	else
		npFinal=nDest
	endif
	if( npFinal > (2*npMax) )				// use segments?
		npTmp= CeilPwr2(nSrc+npMax)
		nSeg= npTmp-nSrc
		Duplicate/o $fw $sw,$dw,$fw
		Redimension/n=(npTmp) $sw,$dw
		Redimension/n=(nSrc) $fw			// front wave -- tmp storage for overwritten points
		if( mode==1 )
			$fw= $destw[nDest-nSrc+P]	// wrap tail around to start
		else
			$fw= 0
		endif
		FFT $sw
		start=0
		do
			tt= -nSrc+start
			$dw[0,nSrc-1]= $fw[P]
			$dw[nSrc, ]= $destw[tt+P]
			$fw= $destw[nSeg+tt+P]		// save data before overwrite
			FFT $dw; $dw *= $sw; IFFT $dw
			if( (start+nSeg) >= npFinal )
				$destw[start,]= $dw[p-start+nSrc]
				break
			else					
				$destw[start,start+nSeg-1]= $dw[p-tt]
			endif
			start += nSeg
		while( 1 )
		KillWaves $fw
	else			
		npTmp= CeilPwr2(nSrc+nDest)
		Duplicate/o $fw $sw
		Duplicate/o $destw $dw
		Redimension/n=(npTmp) $sw,$dw
		if( mode==1 )
			$dw= $destw[mod(nDest-nSrc+P,nDest)]
		endif
		FFT $sw; FFT $dw
		$dw *= $sw
		IFFT $dw
		if( mode==1 )
			$destw= $dw[P+nSrc]
		else
			$destw= $dw[P]
		endif
	endif
	if( mode==3 )
		tt= trunc(nSrc/2)
		$destw= $destw[tt+P]
		Redimension/n=(nDest) $destw
	endif
	CopyScales/P dummyscales $destw
	KillWaves $sw,$dw,dummyscales
end

//****************************************************************
//****************************************************************
//****************************************************************

// Convolve a source wave into a destination wave.
// Source wave is unchanged.  Source is usually short, i.e. a filter coefficient wave.
// 
// Parameter mode:
//	1 -> circular, Nfinal= npts(dest)
//	2 -> linear, Nfinal= npts(src)+npts(dest)-1
//	3 -> acausal linear,  ends use zero padding, Nfinal= npts(dest)
//
//	The algorithm used here uses segmentation if the destination quite long.  This is
//	faster and uses less memory but is more complex.
//REQUIRES: CeilPwr2()
//
Macro ConvolveA(srcw,destw,mode)
	string srcw,destw
	Prompt srcw "source wave:",popup WaveList("*",";","")
	Prompt destw "destination wave",popup WaveList("*",";","")
	variable mode=1
	Prompt mode "mode:",popup "Circular;Linear N1+N2-1 pts;acausal linear, N2 pts"
	silent 1; PauseUpdate
	variable npFinal,npTmp,start,npMax=2000,nSeg,tt
	variable nSrc= numpnts($srcw), nDest= numpnts($destw)
	string sw="fctmp1",dw="fctmp2",fw="fctmp3"
	Make/O/N=2 dummyscales; CopyScales/P $destw dummyscales
	if( mode!=1 )
		npFinal= nDest+nSrc-1
		Redimension/N=(npFinal) $destw	// zero pad
	else
		npFinal=nDest
	endif
	if( npFinal > (2*npMax) )				// use segments?
		npTmp= CeilPwr2(nSrc+npMax)
		nSeg= npTmp-nSrc
		Duplicate/o $srcw $sw,$dw,$fw
		Redimension/n=(npTmp) $sw,$dw
		Redimension/n=(nSrc) $fw			// front wave -- tmp storage for overwritten points
		if( mode==1 )
			$fw= $destw[nDest-nSrc+P]	// wrap tail around to start
		else
			$fw= 0
		endif
		FFT $sw
		start=0
		do
			tt= -nSrc+start
			$dw[0,nSrc-1]= $fw[P]
			$dw[nSrc, ]= $destw[tt+P]
			$fw= $destw[nSeg+tt+P]		// save data before overwrite
			FFT $dw; $dw *= $sw; IFFT $dw
			if( (start+nSeg) >= npFinal )
				$destw[start,]= $dw[p-start+nSrc]
				break
			else					
				$destw[start,start+nSeg-1]= $dw[p-tt]
			endif
			start += nSeg
		while( 1 )
		KillWaves $fw
	else			
		npTmp= CeilPwr2(nSrc+nDest)
		Duplicate/o $srcw $sw
		Duplicate/o $destw $dw
		Redimension/n=(npTmp) $sw,$dw
		if( mode==1 )
			$dw= $destw[mod(nDest-nSrc+P,nDest)]
		endif
		FFT $sw; FFT $dw
		$dw *= $sw
		IFFT $dw
		if( mode==1 )
			$destw= $dw[P+nSrc]
		else
			$destw= $dw[P]
		endif
	endif
	if( mode==3 )
		tt= trunc(nSrc/2)
		$destw= $destw[tt+P]
		Redimension/n=(nDest) $destw
	endif
	CopyScales/P dummyscales $destw
	KillWaves $sw,$dw,dummyscales
end

//****************************************************************
//****************************************************************
//****************************************************************

//MACRO THAT MAKES GAUSSIAN FILTERS OF VARIOUS SD TO CONVOLVE WITH DATA
//BASED ON PROVIDED SMOOTH OPERATION
Macro Filter2(sd, freq, fwave)
	Variable freq = 100
	Variable sd = 10
	String fwave
	Prompt fwave "Wave to filter:",popup WaveList("*",";","")
	Prompt freq, "Sample frequency of wave (Hz): "
	Prompt sd, "Standard deviation of Gaussian filter for convolution (ms): "
	Variable nsmooth, npoints, max, true =1
	max = floor(sqrt(5)*1.7895*10)
	string prompt
	if(sd>max)
		prompt = "The maximum sd allowable is (ms) :"+ num2istr(max) 
		DoAlert 1, prompt
		sd=max
	endif
	npoints = sd/(1000/freq)
	nsmooth = round(10*((npoints/1.7895)^2))
	Smooth (nsmooth), $fwave 
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro AdaptDecay()
	variable i=0
	variable j=0
	variable k
	Variable basestart=.5, baseend=1, satstart=1.1, satend=1.3
	variable base, sat
	variable Id
	variable sattime
	variable sattimereal
	variable tatflash
	variable fttime=1.035
	Silent 1;PauseUpdate
	do
	    k=100	
	    sattime=0
	    sattimereal=0
	    tatflash=0
	    if (WaveExists($("imem"+num2istr(i))))
	    		base = mean($("imem"+num2istr(i)), basestart, baseend)
			sat = mean($("imem"+num2istr(i)),satstart, satend)
			Id = sat-base
			if  (Id>3)
		 		duplicate/o $("imem"+num2istr(i)) temp
//			 	duplicate/o $("ndf"+num2istr(i)) tempndf
			 	do
			 		if ((mean(temp,pnt2x(temp,k),pnt2x(temp,k+5))>0.9*Id) %& (mean(temp,pnt2x(temp,k+5),pnt2x(temp,k+10))<0.9*Id)))
				 		sattime=pnt2x(temp,k+5)
		 			endif
			 		k+=1
			 		if (k==999)
				 		sattime=9999
		 			endif
			 	while(sattime==0)	
		 		if  (sattime!=9999)
			 		make/o/n= 100 tsats
					make/o/n= 100 times
					make/o/n= 100 ids
			 		sattimereal=sattime-fttime
			 		tsats[j]=sattimereal
//			 		tatflash=pnt2x(tempndf,207)
		 			times[j]=tatflash
		 			ids[j]=Id
			 		j+=1	
		 		endif
				print "imem", i, Id,sattimereal,   "time:", tatflash
		      endif
		endif
		i+=1
	while((WaveExists($("imem"+num2istr(i)))))
	variable l
	do
		if (tsats[l]==0)
			Deletepoints l, 1000, tsats
			break
		endif		
		 l+=1
	 while(l<101)
	 variable m
	do
		if (times[m]==0)
			Deletepoints m, 1000, times
			break
		endif		
		m+=1
	while(m<101)
 	variable n
	do
		if (ids[n]==0)
			Deletepoints n, 1000, ids
			break
		endif		
		n+=1
	while(n<101)
	display tsats vs times
	ModifyGraph mode=3,marker=16,msize=4
	display ids vs times
	ModifyGraph mode=3,marker=16,msize=4
endmacro

//****************************************************************
//****************************************************************
//****************************************************************

//Calculates the difference spectrum from "dark" and "light" waves
Macro PowerSpecCellNoise()
	Variable ndark=0
	Variable nlight=0
	Variable nints
	ndark=numpnts(dark)
	nlight=numpnts(light)
	Silent 1; PauseUpdate
	//set source waves the same length
	if(ndark>nlight)
		deletepoints nlight, 20000000, $"dark"
	endif
	if(nlight>ndark)
		deletepoints ndark, 20000000, $"light"
	endif
	//zero baseline and standardize time axis
	$"dark"-=mean($"dark", 0, 100)
	$"light"-=mean($"light", 0, 100)
	SetScale/P x 0,0.005,"s", $"light"
	SetScale/P x 0,0.005,"s", $"dark"
	Duplicate/O $"dark" resp
	fft resp
	Duplicate/O resp powdark
	powdark = 0
	duplicate/O powdark powdark2
	Redimension/R powdark2
	Duplicate/O $"dark" foo
	curvefit line foo
	foo -= (w_coef[0] + w_coef[1] * x)
	fft foo
	powdark = foo * conj(foo)
	powdark2 = real(powdark)
	Duplicate/O $"light" resp
	fft resp
	Duplicate/O resp powlight
	powlight = 0
	duplicate/O powlight powlight2
	Redimension/R powlight2
	Duplicate/O $"light" foo
	curvefit line foo
	foo -= (w_coef[0] + w_coef[1] * x)
	fft foo
	powlight = foo * conj(foo)
	powlight2 = real(powlight)
	Redimension/R powlight
	Redimension/R powdark
	// convert to spectral density
	powdark *= 2 * ndark * 0.005 / (ndark^2)
	powlight *= (2 * nlight * 0.005 / (nlight^2))
	Display powdark powlight
	SetAxis left 1e-16,1 
	Label left "\\u#2pA\\S2\\M/Hz"
	ModifyGraph log=1;DelayUpdate
	Duplicate/o powdark diff
	diff-=powlight
	Display diff
	Label left "\\u#2pA\\S2\\M/Hz"
	ModifyGraph log=1;DelayUpdate
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

//MACRO THAT DUPLICATES THE DATA BETWEEN THE CURSORS ON THE TOP GRAPH 
Macro ExciseWave(srcwave, destwave)
	String srcwave = "imemchart"
	String destwave = "dark"
	Prompt srcwave "Wave from which to create new wave"
	Prompt destwave "Name of new wave"
	if(xcsr(A)<xcsr(B))
		Duplicate/o/R=(xcsr(A), xcsr(B)) $srcwave $destwave
	else
		Duplicate/o/R=(xcsr(B), xcsr(A)) $srcwave $destwave
	endif
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

//Generates average and error waves for all the waves in a given project folder
//Waves must be in a single data subfolder
//generated waves are saved to the root folder
Function WaveAvgErr(foldernm)
	string foldernm
	
	string fullpath = "root:"+foldernm
	string wavenm

	SetDataFolder root:$foldernm
	print "Number of Waves: "+num2str(CountObjects(fullpath,1))
	
	wavenm = "WaveAvg"+foldernm
	duplicate/o $GetIndexedObjName(fullpath,1,0) root:$wavenm
	WAVE WaveAvg = root:$wavenm
	WaveAvg=0
	
	//Make Average Wave
	variable i
	for(i=0;i<CountObjects(fullpath,1);i+=1)
		WAVE nm = $GetIndexedObjName(fullpath,1,i)
		WaveAvg+=nm
	endfor
	WaveAvg/=(CountObjects(fullpath,1))
	
	wavenm = "WaveErr"+foldernm
	duplicate/o $GetIndexedObjName(fullpath,1,0)root:$wavenm
	WAVE WaveErr = root:$wavenm
	WaveErr=0
	
	//Make Error Wave
	for(i=0;i<CountObjects(fullpath,1);i+=1)
		WAVE nm = $GetIndexedObjName(fullpath,1,i)
		//Generate E[X-mean]^2
		WaveErr+=(nm-WaveAvg)^2
	endfor
	//Complete STD Deviation: sqrt(Sum/(n-1))
	WaveErr=sqrt(WaveErr/(CountObjects(fullpath,1)-1))
	//Complete STD Err: stdev/sqrt(n-1)
	WaveErr/=sqrt(CountObjects(fullpath,1)-1)
end

Menu "Data"
	"-"
	"Check SPR Traces", CheckSPR()
End

Macro CheckSPR(fnum)
	variable fnum = root:globals:maxndfused
	prompt fnum, "Enter filter number:"
	displaylistofwaves("f"+num2str(fnum),"F"+num2str(fnum)+"List",0,0,"",0);SetAxis bottom 0.95,2
end

Menu "Edit"
	"-"
	"Copy Values", copyvalues()
End

Function CopyValues()
	WAVE/T Values=root:Values
//	string str=Values[1]+"$'\t'"+Values[2]+"$'\t'"+Values[3]+"$'\t'"+Values[4]+"$'\t'"+Values[5]+"$'\t'"+Values[6]+"$'\t'"+Values[7]+"$'\t'"+Values[8]+"$'\t'"+Values[9]
//	ExecuteScriptText/Z "do shell script \"echo "+str+" | pbcopy\""
	putscraptext Values[1]+"	"+Values[2]+"	"+Values[3]+"	"+Values[4]+"	"+Values[5]+"	"+Values[6]+"	"+Values[7]+"	"+Values[8]+"	"+Values[9]
//	return str
End
