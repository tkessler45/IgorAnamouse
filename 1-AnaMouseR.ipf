#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.95

Menu "|| AnaMouse ||", dynamic
	MenuItem(1), StandardSetup() //Standard Setup
	help={"Runs the standard setup script..."}
	SubMenu "   Standard Setup Components"
		"Import Traces", ImportNQ()
		"Display Charts and Layouts", DisplayCartsandLayouts()
		"   Display Charts", DisplayChart()
		"   Make Layouts", MakeLayouts()
		"Make Waves and Lists", MakeWavesandLists()
		"   Make Waves", MakeWaves()
		"   Make Lists", MakeLists()
		"Light Intensity", LightIntensity()
	end
	MenuItem(8), StartOver()
	SubMenu MenuItem(9); //"   Start Over Components"
		"Kill All Windows", KillAllWindows()
		"Reset Values", ResetValues()
		"Run Standard Setup", StandardSetup()
	End
	"Seed and Setup", seedGlobals()
	"-"
	MenuItem(2), AveVarAll()
	MenuItem(3), MeasureDarkCurrent()
	MenuItem(4), TimeToPeak()
	MenuItem(5), MeanSquaredFit()
	MenuItem(6), SetupOther()
	SubMenu MenuItem(7); //"   Other Components"
		"Average and Variance", AveandVar()
		"Display List Of Waves", DisplayListOfWaves()
		"Flash Family", Family()
		"Check Linearity", CheckLinearlity()
		"Average P-diode", AvePdiode()
		"Make Taurec", TauRec()
		"Make Int Time", IntTime()
		"Intensity Response \"Io\"", IntensityResponse()
		"Make Pepp Tau", PeppTau()
		"Time in Saturation", Tsat()
	end
	"-"
	SubMenu "General Utilities"
		"AdaptDecay"
		"AddFlags"
		"AlignTop"
		"BaselineShift"
		"ChangeGain"
		"DarkCurrentCorrect"
		"Decompress"
		"DriftClamp"
		"ExciseWave"
		"FindRange"
		"LoadIndexWaves"
		"RemoveZeros"
		//"MeanSquared2"
		"MichaelisFits"
		"Normalize"
		"Recompress"
		"WeberFechner"
	End
	"-"
	SubMenu "Modeling"
		"cGConc"
		"CGHoleHomogeneous"
		"CyclaseActivity"
		"BetaSub"
		"PredictCyclaseActivity"
		"PDEActivity"
		"RhLifeTime"
	End
	"-"
	Submenu "Noise Analysis"
		"FiltPS"
		"PowerSpec"
		"PowerSpecCellNoise"
		"PowerSpecClamp"
		"PowerSpecVar"
	End
	"-"	
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
	"-"
	"Export Files",Exportlist()
End

//****************************************************************
//****************************************************************
//****************************************************************

Menu "Macros"
	"ImportNQ"
	"DisplayChart"
	"MakeLayouts"
	"MakeWaves"
	"MakeLists"
	"LightIntensity"
	SubMenu "General Utilities"
		"Family"
		"IntensityResponse"
		"MeasureDarkCurrent"
		"MeanSquaredFit"
		"TimetoPeak"
	End
	"-"
	SubMenu "AnaMouseR Utilities"
		"adaptexpfit"
		"adaptexpfind"
		"inittimecalc"
		"linefit"
		"expfit"
		"expzerobase"
		"expfind"
		"satexpfit"
		"ManualIoMax"
		"StandardSetup"
		"Intensityresponse"
		"TimeToPeak"
		"MeasureDarkCurrent"
		"MeanSquaredFit"
		"ScaleSlide"
		"Scaleup"
		"Scaledn"
		"CheckLinearity"
		"SetupOther"
		"MakeTauRec"
		"MakeIntTime"
		"SummaryLayout"
		"ExportList"
		"KillAllWindows"
		"ResetValues"
		"StartOver"
		"-"
	end
	"-"
	SubMenu "Modeling"
	End
	"-"
	Submenu "Noise Analysis"
	End
	"-"
	SubMenu "Single Photon"
	End
End

//****************************************************************
//****************************************************************
//****************************************************************

Function/S MenuItem(number) //Function for dynamic menu items...
	variable number
	newdatafolder/o root:globals
	variable/g root:globals:standardcomplete
	variable/g root:globals:AveVarcomplete
	variable/g root:globals:Idcomplete
	variable/g root:globals:TTPcomplete
	variable/g root:globals:SPRcomplete
	variable/g root:globals:othercomplete
	variable/g root:globals:adaptcomplete
	
	NVAR standardcomplete=root:globals:standardcomplete
	NVAR AveVarcomplete=root:globals:AveVarcomplete
	NVAR Idcomplete=root:globals:Idcomplete
	NVAR TTPcomplete=root:globals:TTPcomplete
	NVAR SPRcomplete=root:globals:SPRcomplete
	NVAR othercomplete=root:globals:othercomplete
	NVAR adaptcomplete=root:globals:adaptcomplete
	
	switch(number)	// numeric switch
		case 1:	// if(number==1)
			if(standardcomplete)
				return "\\M0:/1!"+num2char(165)+":Standard Setup"
			else
				return "Standard Setup/O1"
			endif
			break	// exit from switch
		case 2:
			if(AveVarcomplete)
				return "\\M0:/2!"+num2char(165)+":Average and Variance All"
			else
				if(standardcomplete)
					return "Average and Variance All/O2"
				else
					return "(Average and Variance All/O2"
				endif
			endif
			break
		case 3:
			if(Idcomplete)
				return "\\M0:/3!"+num2char(165)+":Measure Dark Current"
			else
				if(AveVarcomplete)
					return "Measure Dark Current/O3"
				else
					return "(Measure Dark Current/O3"
				endif
			endif
			break
		case 4:
			if(TTPcomplete)
				return "\\M0:/4!"+num2char(165)+":Time To Peak"
			else
				if(AveVarcomplete)
					return "Time To Peak/O4"
				else
					return "(Time To Peak/O4"
				endif
			endif
			break
		case 5:
			if(SPRcomplete)
				return "\\M0:/5!"+num2char(165)+":Mean Squared Fit"
			else
				if(AveVarcomplete)
					return "Mean Squared Fit/O5"
				else
					return "(Mean Squared Fit/O5"
				endif
			endif
			break
		case 6:
			if(othercomplete)
				return "\\M0:/6!"+num2char(165)+":Setup All Other Graphs"
			else
				if(AveVarcomplete)
					return "Setup All Other Graphs/O6"
				else
					return "(Setup All Other Graphs/O6"
				endif
			endif
			break
		case 7:
			if(othercomplete)
				return "   Other Components"
			else
				if(AveVarcomplete)
					return "   Other Components"
				else
					return "(   Other Components"
				endif
			endif
			break
		case 8:
			if(standardcomplete || adaptcomplete)
				return "Start Over"
			else
				return "(Start Over"
			endif
			break
		case 9:
			if(standardcomplete || adaptcomplete)
				return "   Start Over Components"
			else
				return "(   Start Over Components"
			endif
			break
		default:
			break
	endswitch
end

//****************************************************************
//****************************************************************
//****************************************************************

Window AdaptControlPanel() : Panel
	variable/g root:globals:expfixzero=0
	variable/g root:globals:satexpmax=0
	variable/g root:globals:expdatamask=0
	variable/g root:globals:peppauto=1
	variable/g root:globals:pepptau1=0
	variable/g root:globals:pepptau2=0
	variable/g root:globals:gPeppRadioVal=1
	variable/g root:globals:gIoRadioVal=1
	variable wint=375
	variable winb=468
	variable winr=str2num(stringfromlist(3, stringbykey("SCREEN1", igorinfo(0),":"),","))
	variable winl=winr-117
	variable panelfsize
	PauseUpdate; Silent 1 // building window
	DoWindow/F AdaptControlPanel
	if(V_Flag==1)
		DoWindow/K/W=AdaptControlPanel AdaptControlPanel
	endif
	DoWindow/F StdControlPanel
	if(V_Flag==1)
		DoWindow/K/W=StdControlPanel StdControlPanel
	endif
	NewPanel/FLT=1 /N=AdaptControlPanel /W=(winl,wint,winr,winb) /K=1 as "AdaptControlPanel"
	SetDrawLayer/W=AdaptControlPanel UserBack
	if(char2num(IgorInfo(2))==char2num("W"))
		panelfsize=12
	endif
	if(char2num(IgorInfo(2))==char2num("M"))
		panelfsize=11
	endif
	Button b1,win=AdaptControlPanel,pos={5,8},size={105,20},proc=adaptexpfit,title="Adapt Exp Fit",fsize=panelfsize,help={""}
	Checkbox c1,win=AdaptControlPanel,pos={25,38},value=0,variable=adaptexpfixzero,proc=adaptexpzerobase,title="Force Zero",fsize=panelfsize,help={"Holds baseline at 0 for the curve fit"}
	Groupbox box5,win=AdaptControlPanel,size={115,1}
	Button b8,win=AdaptControlPanel,pos={5,68},size={105,20},proc=SaveProcsMacro,title="Save Procedures",fsize=panelfsize,help={"Saves Procedures to a notebook"}
	SetActiveSubwindow _endfloat_
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Function adaptexpzerobase(ctrlName, checked) : CheckboxControl
	String ctrlName
	Variable checked
	Silent 1
	dowindow/F AdaptationSat
	if(V_Flag==1)
		if(exists("zero2")==0)
			GetAxis/W=AdaptationSat /Q bottom
			Make/N=(floor(V_max))/D/O zero2
		endif
		if(checked==1)
			appendtograph/W=AdaptationSat zero2
			ModifyGraph offset(zero2)={0,mean(adaptbasesatlist)}
			ModifyGraph rgb(zero2)=(0,0,65535)
		endif
		if(checked==0)
			removefromgraph/W=AdaptationSat /Z zero2
		endif
	endif
End

//****************************************************************
//****************************************************************
//****************************************************************

Function adaptexpfit(ctrlName) : ButtonControl
	String ctrlName
	Silent 1
	GetAxis/W=AdaptationSat /Q left
//	variable/g root:globals:adaptexpfixzero
	NVAR adaptexpfixzero=root:globals:adaptexpfixzero
	variable laxist=V_max
	variable laxisb=V_min
	variable i=0
	variable j=1
	string tinfo
	variable len
	variable finish
	variable start
	variable offset
	DoWindow/F AdaptationSat
	if(V_Flag==1)
		if(NumberByKey("ISFREE",CsrInfo(A,"AdaptationSat"))==0 && NumberByKey("ISFREE",CsrInfo(B,"AdaptationSat"))==0)
			//Single Exponential
			Make/D/N=3/O W_coef
			print "--Calculating Tau Adapt..."
			//First curvefit without /X so the R-square is properly calculated. Then redo curvefit with /X and set axis
			K0 = 0;
			
			string wavestr = WaveName("AdaptationSat",1,1)
			WAVE wave1 = $wavestr
			
			if(adaptexpfixzero==1)
				
				offset=GetTraceOffset("adaptationsat","zero2","y")
				
				K0=offset
				print "     Curve Fitting With Baseline Set To",offset
				CurveFit/q/L=(abs((NumberByKey("POINT",CsrInfo(B,"AdaptationSat"))-NumberByKey("POINT",CsrInfo(A,"AdaptationSat"))))+1)/H="100" exp  wave1[pcsr(A),pcsr(B)] /X=adaptlisttimes /D
			endif
			if(adaptexpfixzero==0)
				CurveFit/q/L=(abs((NumberByKey("POINT",CsrInfo(B,"AdaptationSat"))-NumberByKey("POINT",CsrInfo(A,"AdaptationSat"))))+1) exp wave1[pcsr(A),pcsr(B)] /X=adaptlisttimes /D
			endif
			
			wavestr = WaveName("AdaptationSat",2,1)
			WAVE wave2 = $wavestr
			
			wavestats/q wave2
			print "     Single Exp Adaptation Rec is: "+num2str(1/w_coef[2])+"s, Chi Square:", V_chisq, "/sqrt(n-1):", sqrt(V_chisq/(V_npnts-1))
			//Values[4]=num2str(1000/w_coef[2]) //Need to change to "AdaptValues" or something...and add adaptvalues wave to the Default import...
			Make/D/O nomask
			print "     Rsquare is:",Rsquare(wave1,wave2,pcsr(A),pcsr(B),nomask)
			//2nd curvefit with /X used...
			dowindow/F AdaptationSat
			if(adaptexpfixzero==1)
				K0 = offset
				CurveFit/q/X/H="100" exp wave1[pcsr(A),pcsr(B)] /X=adaptlisttimes /D ///L=(abs((NumberByKey("POINT",CsrInfo(B,"AdaptationSat"))-NumberByKey("POINT",CsrInfo(A,"AdaptationSat"))))+1)
			endif
			if(adaptexpfixzero==0)
				CurveFit/q/X exp wave1[pcsr(A),pcsr(B)] /X=adaptlisttimes /D ///L=(abs((NumberByKey("POINT",CsrInfo(B,"AdaptationSat"))-NumberByKey("POINT",CsrInfo(A,"AdaptationSat"))))+1)
			endif
			SetAxis/W=AdaptationSat left laxisb,laxist
			
			wavestr = "fit_"+Wavename("AdaptationSat",1,1)
			WAVE wave2 = $wavestr
			
			ModifyGraph rgb(wave2)=(0,0,0) //$(WaveName("TauRec",1,1))
			Tag/C/N=tautagA/F=1/H={0,2,10}/A=RB/X=-5.00/Y=10.00 wave1, xcsr(A),"A"
			Tag/C/N=tautagB/F=1/H={0,2,10}/A=MB/X=-1.00/Y=20.00 wave1, xcsr(B),"B"
		else
			Abort "ERROR: Place both cursors A and B on the adaptation plot!"
		endif
	else
		Abort "ERROR: Adaptation plot does not exist!!!"
	endif
End

//****************************************************************
//****************************************************************
//****************************************************************

Macro adaptexpfind(ctrlName) : ButtonControl //NOT WORKING....
	String ctrlName
	Silent 1
	variable i=0
	variable length
	variable lowpt
	variable lowcsr
	variable highpt
	variable highcsr
	variable midpt
	variable midptS
	variable midcsr
	variable midcsrS
	variable maxrlowpt //stored minimum pt (point A) for the highest calculated r value
	variable maxrlowcsr
	variable maxrhighpt //stored maximum pt (point B) for the highest calculated r value
	variable maxrhighcsr
	variable newr=0
	variable prevr=0 //previous r value
	variable V_fiterror=0
	Make/D/O nomask
	Make/N=1/D/O rsquarewave
	DoWindow/F AdaptationSat
	if(V_Flag==1)
		if(NumberByKey("ISFREE",CsrInfo(A,"AdaptationSat"))==0 && NumberByKey("ISFREE",CsrInfo(B,"AdaptationSat"))==0)
			//setup start points before do-loops...
			lowpt=NumberByKey("POINT",CsrInfo(A,"AdaptationSat"))
			lowcsr=pcsr(A)
			highcsr=pcsr(B)
			highpt=NumberByKey("POINT",CsrInfo(B,"AdaptationSat"))
			midpt=round((lowpt+highpt)*0.5+(highpt-lowpt)*0.0)
			midptS=round((midpt-(highpt-lowpt)*.2))-10 //Static midpoint for highpt-=1
			midcsr=round((lowcsr+highcsr)*0.5+(highcsr-lowcsr)*0.0)
			midcsrS=round((midcsr-(highcsr-lowcsr)*.2))
			Make/D/N=3/O W_coef
			print "--Calculating Tau Adapt..."
			do
				//setup new start points...
				midpt=round((lowpt+highpt)*0.5+(highpt-lowpt)*0.0)
				//midptS=midpt //Static midpoint for highpt-=1
				midcsr=round((lowcsr+highcsr)*0.5+(highcsr-lowcsr)*0.0)
				//midcsrS=midpt
				do
					V_fiterror=0 //prevent curve fit errors.
					CurveFit/q/N/L=(midpt-lowpt+1) exp $(WaveName("AdaptationSat",1,1))[lowcsr,midcsr] /D /X=adaptlisttimes
					newr=Rsquare($(WaveName("AdaptationSat",1,1)),$(WaveName("AdaptationSat",2,1)),lowcsr,midcsr,nomask)
					rsquarewave[i]=newr
					InsertPoints i+1,1, rsquarewave
					rsquarewave[i+1]=NaN
					i+=1
					if(newr>prevr)
						maxrlowpt=lowpt
						maxrhighpt=midpt
						maxrlowcsr=lowcsr
						maxrhighcsr=midcsr
						prevr=newr
					endif
					midcsr+=1
					//lowcsr+=1
					midpt+=1
					//lowpt+=1
				while(highcsr>=midcsr)
				lowcsr+=2
				lowpt+=2
			while($(WaveName("AdaptationSat",1,1))[lowcsr]>$(WaveName("AdaptationSat",1,1))[pcsr(A)]*.5) //previous --> lowcsr<=midcsrS
			CurveFit/q/L=(maxrhighpt-maxrlowpt+1) exp $(WaveName("AdaptationSat",1,1))[maxrlowcsr,maxrhighcsr] /D /X=adaptlisttimes
			ModifyGraph rgb($(WaveName("AdaptationSat",2,1)))=(0,0,0)
			wavestats/q $(WaveName("AdaptationSat",2,1))
			print "     Tau Adapt is: "+num2str(1/w_coef[2])+"s, Chi Square:", V_chisq
			//Values[4]=num2str(1000/w_coef[2])
			print "     Rsquare is:",Rsquare($(WaveName("AdaptationSat",1,1)),$(WaveName("AdaptationSat",2,1)),maxrlowcsr,maxrhighcsr,nomask)
		else
			Abort "ERROR: Place both cursors A and B on the adaptation plot!"
		endif
	else
		Abort "ERROR: Adaptation plot does not exist!!!"
	endif
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Window StdControlPanel() : Panel
	variable/g root:globals:expfixzero=0
	variable/g root:globals:satexpmax=0
	variable/g root:globals:expdatamask=0
	variable/g root:globals:peppauto=1
	variable/g root:globals:pepptau1=0
	variable/g root:globals:pepptau2=0
	variable/g root:globals:gPeppRadioVal=1
	variable/g root:globals:gIoRadioVal=1
	variable/g root:globals:Ioguess1=1
	variable/g root:globals:Ioguess2=0
	variable/g root:globals:dccorrectvar=0
	
	variable panelfsize
	variable winl=1163
	variable wint=374
	variable winr=1280
	variable winb=842
	string numstr//="0000"
	variable numstrindex=3
	PauseUpdate; Silent 1 // building window
	DoWindow/F StdControlPanel
	if(V_Flag==1)
		DoWindow/K/W=StdControlPanel StdControlPanel
	endif
	DoWindow/F AdaptControlPanel
	if(V_Flag==1)
		DoWindow/K/W=AdaptControlPanel AdaptControlPanel
	endif
	//Setup screen resolution
	winr=str2num(stringfromlist(3, stringbykey("SCREEN1", igorinfo(0),":"),","))
	winl=winr-117
	NewPanel/FLT=1 /N=StdControlPanel /W=(winl,wint,winr,winb) /K=1 as "StdControlPanel"// /W=(1163,374,1280,718) /K=1
	SetDrawLayer/W=StdControlPanel UserBack
	if(char2num(IgorInfo(2))==char2num("W"))
		panelfsize=12
	endif
	if(char2num(IgorInfo(2))==char2num("M"))
		panelfsize=11
	endif
	Button b4,pos={5,8},size={105,20},proc=inttimecalc,title="Integration Time",fsize=panelfsize,help={"Calculates Integration Time:\r\rIf needed, manually offset the black 'zero' line on the graph to where the integration levels off, and click this button."}
	setVariable b4val,pos={30,36},size={50,20},title=" ",noedit=1,noproc,value=Values[5],frame=0,valueBackColor=(64000,64000,64000) //(60909,60909,60909)
	Button b4clear,pos={90,33},size={18,20},title="\W501",proc=b4clear,fsize=panelfsize
	Groupbox box2, size={115,1}											
	Button b5,pos={5,68},size={105,20},proc=expfit,title="TauRec Fit",fsize=panelfsize,help={"Calculates Tau of Recovery:\r\rPlace cursors A and B on the graph and click the button. Optionally you may force the baseline to zero, and/or use an exponentially inclusive data mask."}
	Checkbox c1,pos={25,98},value=0,variable=root:globals:expfixzero,proc=expzerobase,title="Force Zero",fsize=panelfsize,help={"Holds baseline at 0 for the curve fit"}
	Checkbox c2,pos={25,118},value=0,variable=root:globals:expdatamask,title="Data Mask",fsize=panelfsize,help={"Use data mask wave for curve fitting"}
	setVariable b5val,pos={30,146},size={50,20},title=" ",noedit=1,noproc,value=Values[4],frame=0,valueBackColor=(64000,64000,64000)
	Button b5clear,pos={90,143},size={18,20},title="\W501",proc=b4clear,fsize=panelfsize
	Groupbox box3, size={115,1}
	Button b6,pos={5,178},size={105,20},proc=satexpfit,title="Io Fit",fsize=panelfsize,help={"Calculates Io:\r\rClick the button to automatically determine the saturation level and calculate Io. Optionally, enable manual determination of the saturation level, drag the 'zero' line to the desired saturation location, and click this button."}
	Checkbox c3,pos={25,208},value=0,variable=root:globals:satexpmax, proc=ManualIoMax,title="Manual Max",fsize=panelfsize,help={"Manual zero line for determining saturation maximum value"}
	Checkbox c7,pos={25,228},value=1,variable=root:globals:Ioguess1,proc=switchIo,title="0.01",mode=1,fsize=panelfsize,help={"Use the default value of 0.01 as the initial guess."}
	Checkbox c8,pos={25,248},value=0,variable=root:globals:Ioguess2,proc=switchIo,title="0.001",mode=1,fsize=panelfsize,help={"Use 0.001 as the initial guess."}
	setVariable b6val,pos={30,276},size={50,20},title=" ",noedit=1,noproc,value=Values[6],frame=0,valueBackColor=(64000,64000,64000)
	Button b6clear,pos={90,273},size={18,20},title="\W501",proc=b4clear,fsize=panelfsize
	Groupbox box4, size={115,1}
	Button b7,pos={5,308},size={105,20},proc=linefit,title="Pepptau Fit",fsize=panelfsize,help={"Calculates Pepperburg Tau:\r\rPlace cursors on graph to define regions of either peppttau 1 or pepptau2, and then click the button. If manual determination of pepp1 or pepp2 is needed, click the appropriate radio button."}
	Checkbox c4,pos={25,338},value=1,variable=root:globals:peppauto,proc=switchpepptau,title="Auto",mode=1,fsize=panelfsize,help={"Automatic determindation of Pepptau1 or Pepptau2."}
	Checkbox c5,pos={25,358},value=0,variable=root:globals:pepptau1,proc=switchpepptau,title="Pepp 1",mode=1,fsize=panelfsize,help={"Override automatic determination of Pepptau1 or Pepptau2 with manual designation"}
	Checkbox c6,pos={25,378},value=0,variable=root:globals:pepptau2,proc=switchpepptau,title="Pepp 2",mode=1,fsize=panelfsize,help={"Override automatic determination of Pepptau1 or Pepptau2 with manual designation"}
//	setVariable b7val,pos={30,406},size={50,20},title=" ",noedit=1,noproc,value=Values[7],valueBackColor=(60909,60909,60909)
	Button b7clear,pos={90,403},size={18,20},title="\W501",proc=b4clear,fsize=panelfsize
	Groupbox box5, size={115,1}
	Button b8,pos={5,438},size={105,20},proc=SaveProcsMacro,title="Save Procedures",fsize=panelfsize,help={"Saves Procedures to a notebook"}	
	SetActiveSubwindow _endfloat_
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Function b4clear(ctrlName) : ButtonControl
	String ctrlName
	WAVE/T Values=root:Values
	strswitch(ctrlName)
		case "b4clear":
			Values[5]=""
			break
		case "b5clear":
			Values[4]=""
			break
		case "b6clear":
			Values[6]=""
			break
		case "b7clear":
			Values[7]=""
			Values[8]=""
			break
		default:
			Print "NOTHING"
	endswitch
end

//****************************************************************
//****************************************************************
//****************************************************************

Function switchpepptau(name,value) //switch function for control panel pepptau radio buttons "Auto", "Pepp 1", and "Pepp 2" --> using example code
	String name
	Variable value
	NVAR gPeppRadioVal= root:globals:gPeppRadioVal
	strswitch (name)
		case "c4":
			gPeppRadioVal= 1
			break
		case "c5":
			gPeppRadioVal= 2
			break
		case "c6":
			gPeppRadioVal= 3
			break
	endswitch
	CheckBox c4,win=StdControlPanel,value= gPeppRadioVal==1
	CheckBox c5,win=StdControlPanel,value= gPeppRadioVal==2
	CheckBox c6,win=StdControlPanel,value= gPeppRadioVal==3
End

//****************************************************************
//****************************************************************
//****************************************************************

Function switchIo(name,value) //switch function for control panel pepptau radio buttons "Auto", "Pepp 1", and "Pepp 2" --> using example code
	String name
	Variable value
	NVAR gIoRadioVal= root:globals:gIoRadioVal
	strswitch (name)
		case "c7":
			gIoRadioVal= 1
			break
		case "c8":
			gIoRadioVal= 2
			break
	endswitch
	CheckBox c7,win=StdControlPanel,value= gIoRadioVal==1
	CheckBox c8,win=StdControlPanel,value= gIoRadioVal==2
End

//****************************************************************
//****************************************************************
//****************************************************************

Function inttimecalc(ctrlName) : ButtonControl
	String ctrlName
	
	WAVE/T Values=root:Values
	
	Silent 1
	Pauseupdate
	String tinfo
	variable offset
	String ndfstr=""
	String intwave
	String avefwave
	variable len
	variable i
	variable j=0
	variable start //start of number value in info string
	variable finish //finish of number value in info string
	variable cnt=0
	DoWindow/F IntTime
	if(V_Flag==1)
		print "--Calculating New Integration Time..."
		
		//GET Y OFFSET FROM TRACE
		offset=GetTraceOffset("inttime","zero","y") //str2num(stringfromlist(1,stringbykey("offset(x)",traceinfo("IntTime","zero",0),"="),","))
		print "     Integration Time Y Offset Value:",offset

		//figure out which NDF is used...
//		i=3
//		j=0
//		intwave=WaveName("IntTime",0,1)
//		len=strlen(WaveName("IntTime",0,1))
//		do
//			ndfstr[j]=intwave[i]
//			i+=1
//			j+=1
//		while(i<=len)

		NVAR ndf=root:globals:maxndfused
		ndfstr=num2str(ndf)

//		avefwave=("avef"+ndfstr)
//		wavestats/q $(avefwave)
		variable V_max=wavemax($("avef"+ndfstr))
		Print "     Integration Time (msec):", num2str(1000*offset/v_max)
		Values[5]=num2str(1000*offset/v_max) //Append calculated Integration Time to Values Table
	else
		Abort "ERROR: IntTime graph does not exist!!!"
	endif
End

//****************************************************************
//****************************************************************
//****************************************************************

Macro linefit(ctrlName) : ButtonControl
	String ctrlName
	Silent 1
	Pauseupdate
	variable length
	variable/g root:globals:peppauto
	variable/g root:globals:pepptau1
	variable/g root:globals:pepptau2
	DoWindow/F pepptau0
	if(V_Flag==1)
		if(NumberByKey("ISFREE",CsrInfo(A,"pepptau0"))==0 && NumberByKey("ISFREE",CsrInfo(B,"pepptau0"))==0) //Check for cursor placement on pepptau plot
			Make/D/N=2/O W_coef
			if(exists("fit_TimeSat")==1)
				if(exists("fit_TimeSatold")==1)
					removefromgraph/Z fit_TimeSatold
					killwaves fit_TimeSatold
				endif
				duplicate/O fit_TimeSat, fit_TimeSatold
				Append fit_TimeSatold
				ModifyGraph rgb(fit_TimeSatold)=(0,0,0)
			endif
//			print (abs((NumberByKey("POINT",CsrInfo(B,"pepptau0"))-NumberByKey("POINT",CsrInfo(A,"pepptau0"))))+1)
			CurveFit/q/L=(abs((NumberByKey("POINT",CsrInfo(B,"pepptau0"))-NumberByKey("POINT",CsrInfo(A,"pepptau0"))))+1) line  $(WaveName("pepptau0",0,1))[pcsr(A),pcsr(B)] /X=lnflstr /D
			ModifyGraph rgb(fit_TimeSat)=(0,0,0)
			if(root:globals:peppauto==1)
				if(pcsr(A)<4 && (pcsr(B)-pcsr(A))>0)
					print "--Calculating Pepp Tau 1..."
					Print "     Pepp Tau 1 (msec):", W_coef[1]*1000, "Chi Square:", V_chisq
					Values[7]= num2str(W_coef[1]*1000)
				endif
				if(pcsr(A)>=4 && (pcsr(B)-pcsr(A))>0)
					print "--Calculating Pepp Tau 2..."
					Print "     Pepp Tau 2 (msec):", W_coef[1]*1000, "Chi Square:", V_chisq
					Values[8]= num2str(W_coef[1]*1000)
				endif
			else
				if(root:globals:pepptau1==1)
					print "--Calculating Pepp Tau 1...(Manually Designated)"
					Print "     Pepp Tau 1 (msec):", W_coef[1]*1000, "Chi Square:", V_chisq
					Values[7]= num2str(W_coef[1]*1000)
				endif
				if(root:globals:pepptau2==1)
					print "--Calculating Pepp Tau 2...(Manually Designated)"
					Print "     Pepp Tau 2 (msec):", W_coef[1]*1000, "Chi Square:", V_chisq
					Values[8]= num2str(W_coef[1]*1000)
				endif
			endif
			Make/O/D nomask
			print "     Rsquare is:",Rsquare($(WaveName("pepptau0",0,1)),$(WaveName("pepptau0",1,1)),pcsr(A),pcsr(B),nomask)
		else
			Abort "ERROR: Place both cursors A and B on the pepperburg plot!"
		endif
	else
		Abort "ERROR: pepperburg plot does not exist!!!"
	endif
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro expfit(ctrlName) : ButtonControl
	String ctrlName
	Silent 1
	Pauseupdate
	GetAxis/W=TauRec /Q left
	variable/g root:globals:expfixzero
	variable/g root:globals:expdatamask
	variable laxist=V_max
	variable laxisb=V_min
	variable i=0
	variable j=1
	DoWindow/F TauRec
	if(V_Flag==1)
		if(NumberByKey("ISFREE",CsrInfo(A,"TauRec"))==0 && NumberByKey("ISFREE",CsrInfo(B,"TauRec"))==0)
			//Single Exponential
			Make/D/N=3/O W_coef
			print "--Calculating Tau Rec..."
			if(root:globals:expdatamask==1)
				//Create data mask wave for fitting...
				duplicate/o $(WaveName("taurec",0,1)) maskwave//Duplicate data wave
				wavestats/q maskwave
				do
					if(i>=pcsr(A) && i<=pcsr(B))
						maskwave[i]=1
						//DATA MASK OPTIONS AND MODIFICATIONS
						//if(maskwave[i-1]==1 && i>(pcsr(A)+pcsr(B))/2) //set every other point after middle to be zero....
						//	maskwave[i]=0
						//endif
						if(i>=(pcsr(A)+pcsr(B))/2) //set an exponentially inclusive data mask for points after middle of cursors A and B
							maskwave[i]=0
							if(i==round((pcsr(A)+pcsr(B))/2+j^1.4)) //the exponential determines the number of points after the middle to be included...
								maskwave[i]=1
								j+=1
							endif					
						endif
						//maskwave[i]=0 //set an exponentially inclusive data mask 
						//if(i==round((pcsr(A)+j^2))) //the exponential determines the number of points after the middle to be included...
						//	maskwave[i]=1
						//	j+=1
						//endif
					else
						maskwave[i]=0
					endif
					i+=1
				while(i<=V_npnts)
			endif
			//First curvefit without /X so the R-square is properly calculated. Then redo curvefit with /X and set axis
			K0 = 0;
			if(root:globals:expfixzero==1)
				print "     Curve Fitting With Baseline Set To 0..."
				if(root:globals:expdatamask==1)
					CurveFit/q/L=(abs((NumberByKey("POINT",CsrInfo(B,"TauRec"))-NumberByKey("POINT",CsrInfo(A,"TauRec"))))+1)/H="100" exp  $(WaveName("TauRec",0,1))[pcsr(A),pcsr(B)] /D /M=maskwave //Curvefit using y0 set to 0
				else
					CurveFit/q/L=(abs((NumberByKey("POINT",CsrInfo(B,"TauRec"))-NumberByKey("POINT",CsrInfo(A,"TauRec"))))+1)/H="100" exp  $(WaveName("TauRec",0,1))[pcsr(A),pcsr(B)] /D
				endif
			endif
			if(root:globals:expfixzero==0)
				if(root:globals:expdatamask==1)
					CurveFit/q/L=(abs((NumberByKey("POINT",CsrInfo(B,"TauRec"))-NumberByKey("POINT",CsrInfo(A,"TauRec"))))+1) exp $(WaveName("TauRec",0,1))[pcsr(A),pcsr(B)] /D /M=maskwave
				else
					CurveFit/q/L=(abs((NumberByKey("POINT",CsrInfo(B,"TauRec"))-NumberByKey("POINT",CsrInfo(A,"TauRec"))))+1) exp $(WaveName("TauRec",0,1))[pcsr(A),pcsr(B)] /D
				endif
			endif
			//Setup for double exponential...
			//if(exists("exp_fit")==1)
			//	removefromgraph/Z exp_fit
			//	killwaves exp_fit
			//endif
			//duplicate/o $(WaveName("TauRec",1,1)) exp_fit
			//appendtograph exp_fit
			//ModifyGraph rgb(exp_fit)=(0,0,0)
			wavestats/q $(WaveName("taurec",1,1))
			print "     Single Exp TauRec is (msec):", 1000/w_coef[2], "Chi Square:", V_chisq, "/sqrt(n-1):", sqrt(V_chisq/(V_npnts-1))
			Values[4]=num2str(1000/w_coef[2])
			if(root:globals:expdatamask==0) //cancel out masking wave if mask isnt enabled...
				Make/D/O maskwave
			endif
			print "     Rsquare is:",Rsquare($(WaveName("TauRec",0,1)),$(WaveName("TauRec",1,1)),pcsr(A),pcsr(B),maskwave)
			//2nd curvefit with /X used...
			dowindow/F TauRec
			K0 = 0;
			if(root:globals:expfixzero==1)
				if(root:globals:expdatamask==1)
					CurveFit/q/X/H="100" exp  $(WaveName("TauRec",0,1))[pcsr(A),pcsr(B)] /D /M=maskwave ///L=(abs((NumberByKey("POINT",CsrInfo(B,"TauRec"))-NumberByKey("POINT",CsrInfo(A,"TauRec"))))+1)
				else
					CurveFit/q/X/H="100" exp  $(WaveName("TauRec",0,1))[pcsr(A),pcsr(B)] /D ///L=(abs((NumberByKey("POINT",CsrInfo(B,"TauRec"))-NumberByKey("POINT",CsrInfo(A,"TauRec"))))+1)
				endif
			endif
			if(root:globals:expfixzero==0)
				if(root:globals:expdatamask==1)
					CurveFit/q/X exp $(WaveName("TauRec",0,1))[pcsr(A),pcsr(B)] /D /M=maskwave ///L=(abs((NumberByKey("POINT",CsrInfo(B,"TauRec"))-NumberByKey("POINT",CsrInfo(A,"TauRec"))))+1)
				else
					CurveFit/q/X exp $(WaveName("TauRec",0,1))[pcsr(A),pcsr(B)] /D ///L=(abs((NumberByKey("POINT",CsrInfo(B,"TauRec"))-NumberByKey("POINT",CsrInfo(A,"TauRec"))))+1)
				endif
			endif
			SetAxis/W=TauRec left laxisb,laxist
			ModifyGraph rgb($("fit_"+Wavename("taurec",0,1)))=(0,0,0) //$(WaveName("TauRec",1,1))
			//Double Exponential...
			//Make/D/N=5/O W_coef
			//CurveFit/q/X/L=(abs((NumberByKey("POINT",CsrInfo(B,"TauRec"))-NumberByKey("POINT",CsrInfo(A,"TauRec"))))+1) dblexp $(WaveName("TauRec",0,1))[pcsr(A),pcsr(B)] /D
			//ModifyGraph rgb($(WaveName("TauRec",1,1)))=(0,0,65535)
			//wavestats/q $(WaveName("taurec",1,1))
			//print "     Double Exp TauRec 1 is:", 1000/w_coef[2],"Taurec 2 is:", 1000/w_coef[4],"Chi Square:", V_chisq
			//print "     Rsquare is:",Rsquare($(WaveName("TauRec",0,1)),$(WaveName("TauRec",1,1)),pcsr(A),pcsr(B))
			Tag/C/N=tautagA/F=1/H={0,2,10}/A=LB/X=5.00/Y=5.00 $(WaveName("taurec",0,1)), xcsr(A),"A"
			Tag/C/N=tautagB/F=1/H={0,2,10}/A=LB/X=5.00/Y=20.00 $(WaveName("taurec",0,1)), xcsr(B),"B"
		else
			Abort "ERROR: Place both cursors A and B on the taurec plot!"
		endif
	else
		Abort "ERROR: taurec plot does not exist!!!"
	endif
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro expzerobase(ctrlName, checked) : CheckboxControl
	String ctrlName
	Variable checked
	Silent 1
	Pauseupdate
	dowindow/F Taurec
	if(V_Flag==1)
		if(checked==1)
			appendtograph/W=TauRec zero
			ModifyGraph rgb(zero)=(0,0,65535)
		endif
		if(checked==0)
			removefromgraph/W=TauRec /Z zero
		endif
	endif
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro expfind(ctrlName) : ButtonControl
	String ctrlName
	Silent 1
	Pauseupdate
	variable i=0
	variable length
	variable lowpt
	variable lowcsr
	variable highpt
	variable highcsr
	variable midpt
	variable midptS
	variable midcsr
	variable midcsrS
	variable maxrlowpt //stored minimum pt (point A) for the highest calculated r value
	variable maxrlowcsr
	variable maxrhighpt //stored maximum pt (point B) for the highest calculated r value
	variable maxrhighcsr
	variable newr=0
	variable prevr=0 //previous r value
	variable V_fiterror=0
	Make/D/O nomask
	Make/N=1/D/O rsquarewave
	DoWindow/F TauRec
	if(V_Flag==1)
		if(NumberByKey("ISFREE",CsrInfo(A,"TauRec"))==0 && NumberByKey("ISFREE",CsrInfo(B,"TauRec"))==0)
			//setup start points before do-loops...
			lowpt=NumberByKey("POINT",CsrInfo(A,"TauRec"))
			lowcsr=pcsr(A)
			highcsr=pcsr(B)
			highpt=NumberByKey("POINT",CsrInfo(B,"TauRec"))
			midpt=round((lowpt+highpt)*0.5+(highpt-lowpt)*0.0)
			midptS=round((midpt-(highpt-lowpt)*.2))-10 //Static midpoint for highpt-=1
			midcsr=round((lowcsr+highcsr)*0.5+(highcsr-lowcsr)*0.0)
			midcsrS=round((midcsr-(highcsr-lowcsr)*.2))
			Make/D/N=3/O W_coef
			print "--Calculating Tau Rec..."
			do
				//setup new start points...
				midpt=round((lowpt+highpt)*0.5+(highpt-lowpt)*0.0)
				//midptS=midpt //Static midpoint for highpt-=1
				midcsr=round((lowcsr+highcsr)*0.5+(highcsr-lowcsr)*0.0)
				//midcsrS=midpt
				do
					V_fiterror=0 //prevent curve fit errors.
					CurveFit/q/N/L=(midpt-lowpt+1) exp $(WaveName("TauRec",0,1))[lowcsr,midcsr] /D
					newr=Rsquare($(WaveName("TauRec",0,1)),$(WaveName("TauRec",1,1)),lowcsr,midcsr,nomask)
					rsquarewave[i]=newr
					InsertPoints i+1,1, rsquarewave
					rsquarewave[i+1]=NaN
					i+=1
					if(newr>prevr)
						maxrlowpt=lowpt
						maxrhighpt=midpt
						maxrlowcsr=lowcsr
						maxrhighcsr=midcsr
						prevr=newr
					endif
					midcsr+=1
					//lowcsr+=1
					midpt+=1
					//lowpt+=1
				while(highcsr>=midcsr)
				lowcsr+=2
				lowpt+=2
			while($(WaveName("TauRec",0,1))[lowcsr]>$(WaveName("TauRec",0,1))[pcsr(A)]*.5) //previous --> lowcsr<=midcsrS
			CurveFit/q/L=(maxrhighpt-maxrlowpt+1) exp $(WaveName("TauRec",0,1))[maxrlowcsr,maxrhighcsr] /D
			ModifyGraph rgb($(WaveName("TauRec",1,1)))=(0,0,0)
			wavestats/q $(WaveName("taurec",1,1))
			print "     TauRec is:", 1000/w_coef[2], "Chi Square:", V_chisq
			Values[4]=num2str(1000/w_coef[2])
			print "     Rsquare is:",Rsquare($(WaveName("TauRec",0,1)),$(WaveName("TauRec",1,1)),maxrlowcsr,maxrhighcsr,nomask)
		else
			Abort "ERROR: Place both cursors A and B on the taurec plot!"
		endif
	else
		Abort "ERROR: taurec plot does not exist!!!"
	endif
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro satexpfit(ctrlName) : ButtonControl
	String ctrlName
	Silent 1
	Pauseupdate
	variable i
	variable/g root:globals:satexpmax //if 1 then use zero2 line offset for fitting, ensuring cursors are set, etc...
	variable/g root:globals:Ioguess1
	variable/g root:globals:Ioguess2
	variable V_fiterror=0
	DoWindow/F intensresp
	if(V_Flag>0 && root:globals:satexpmax==0)
		print "--Calculating Intensity Response Best-Fit and Io..."
		wavestats/q resp
		i=0
		do //delete Nan points on either int or resp and the corresponding value on the paired wave. 
			if(numtype(resp[i])==2)
				DeletePoints i,1, int //12==first point, 1==number of points, int==wavename  //int[i]=NaN
				DeletePoints i,1, resp
			endif
			if(numtype(int[i])==2)
				DeletePoints i,1, resp  //resp[i]=NaN
				DeletePoints i,1, int
			endif
			i+=1
		while(i<=V_npnts)
		wavestats/q resp
		print "     Response maximum:", v_max
		resp/=v_max
		Make/D/N=2/O W_coef
		if(root:globals:Ioguess1==1)
			W_coef[0] = {1,0.01}
		endif
		if(root:globals:Ioguess2==1)
			W_coef[0] = {1,0.001}
		endif
		if(NumberByKey("ISFREE",CsrInfo(A,"intensresp"))==0 && NumberByKey("ISFREE",CsrInfo(B,"intensresp"))==0)
			FuncFit/Q/H="10" satexp W_coef  resp[pcsr(A),pcsr(B)] /X=int /D
			make/o/n=(abs((NumberByKey("POINT",CsrInfo(B,"intensresp"))-NumberByKey("POINT",CsrInfo(A,"intensresp"))))+1) SSW_resp //make Sum of Squares wave for Rsquare calcs...
			wavestats/q SSW_resp
			i=0
			do
				SSW_resp[i]=Satexpfunc(int[i],W_coef[0],W_coef[1])
				i+=1
			while(i<=V_npnts)
			wavestats/q $(WaveName("intensresp",2,1))
			print "     Io (Photons/µm^2) is:", 0.693147/w_coef[1], "Chi Square:", V_chisq
			wavestats/q SSW_resp
			Make/O/D nomask
			print "     Rsquare is:",Rsquare($(WaveName("intensresp",0,1)),SSW_resp,pcsr(A),pcsr(B),nomask)
		else
			FuncFit/Q/H="10" satexp W_coef  resp /X=int /D
			duplicate/O int SSW_resp //duplicate int to a Sum of Square Wave for Rsquare calculations...
			wavestats/q SSW_resp
			i=0
			do
				SSW_resp[i]=Satexpfunc(int[i],W_coef[0],W_coef[1])
				i+=1
			while(i<=V_npnts)
			wavestats/q $(WaveName("intensresp",2,1))
			print "     Io (Photons/µm^2) is:", 0.693147/w_coef[1], "Chi Square:", V_chisq
			wavestats/q SSW_resp
			Make/O/D nomask
			print "     Rsquare is:",Rsquare($(WaveName("intensresp",0,1)),SSW_resp,0,V_npnts,nomask)
		endif
		ModifyGraph rgb(fit_resp)=(0,0,0)
		Label left "r/r\Bmax"
		Values[6]=num2str(0.693147/w_coef[1])
	endif
	if(V_Flag==1 && root:globals:satexpmax==1)
		if(zero2[0]!=0)
			zero2=0
			Abort "Zero Value Reset. Redo Calculation!"
		endif
		print "--Calculating Intensity Response Best-Fit and Io With Manual Maximum..."
		wavestats/q resp
		i=0
		do //delete Nan points on either int or resp and the corresponding value on the paired wave. 
			if(numtype(resp[i])==2)
				DeletePoints i,1, int //12==first point, 1==number of points, int==wavename  //int[i]=NaN
				DeletePoints i,1, resp
			endif
			if(numtype(int[i])==2)
				DeletePoints i,1, resp  //resp[i]=NaN
				DeletePoints i,1, int
			endif
			i+=1
		while(i<=V_npnts)

		variable offset = gettraceoffset("intensresp","zero2","y")
		//Start finding the manually set offset value for the blue "zero" line

		print "     Manual Determined Maximum:",offset
		//END finding the manual offset value...
		resp/=offset
		ModifyGraph offset(zero2)={0,1}
		Make/D/N=2/O W_coef
		if(root:globals:Ioguess1==1)
			W_coef[0] = {1,0.01}
		endif
		if(root:globals:Ioguess2==1)
			W_coef[0] = {1,0.001}
		endif
		if(NumberByKey("ISFREE",CsrInfo(A,"intensresp"))==0 && NumberByKey("ISFREE",CsrInfo(B,"intensresp"))==0)
			FuncFit/Q/H="10" satexp W_coef  resp[pcsr(A),pcsr(B)] /X=int /D
			make/o/n=(abs((NumberByKey("POINT",CsrInfo(B,"intensresp"))-NumberByKey("POINT",CsrInfo(A,"intensresp"))))+1) SSW_resp //make Sum of Squares wave for Rsquare calcs...
			wavestats/q SSW_resp
			i=0
			do
				SSW_resp[i]=Satexpfunc(int[i],W_coef[0],W_coef[1])
				i+=1
			while(i<=V_npnts)
			wavestats/q $(WaveName("intensresp",2,1))
			print "     Io (Photons/µm^2) is:", 0.693147/w_coef[1], "Chi Square:", V_chisq
			wavestats/q SSW_resp
			Make/O/D nomask
			print "     Rsquare is:",Rsquare($(WaveName("intensresp",0,1)),SSW_resp,pcsr(A),pcsr(B),nomask)
		else
			FuncFit/Q/H="10" satexp W_coef  resp /X=int /D
			duplicate/O int SSW_resp //duplicate int to a Sum of Square Wave for Rsquare calculations...
			wavestats/q SSW_resp
			i=0
			do
				SSW_resp[i]=Satexpfunc(int[i],W_coef[0],W_coef[1])
				i+=1
			while(i<=V_npnts)
			wavestats/q $(WaveName("intensresp",2,1))
			print "     Io (Photons/µm^2) is:", 0.693147/w_coef[1], "Chi Square:", V_chisq
			wavestats/q SSW_resp
			Make/O/D nomask
			print "     Rsquare is:",Rsquare($(WaveName("intensresp",0,1)),SSW_resp,0,V_npnts,nomask)
		endif
		ModifyGraph rgb(fit_resp)=(0,0,0)
		Label left "r/r\Bmax"
		Values[6]=num2str(0.693147/w_coef[1])
	endif
	if(V_Flag==0)
		Abort "ERROR: intensity response plot does not exist!!!"
	endif
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro ManualIoMax(ctrlName,checked) : checkboxcontrol
	string ctrlName
	variable checked
	Silent 1
	Pauseupdate
	DoWindow/F intensresp
	//make "zero2" based on X-axis length, set to zeroes, and append to graph...
	if(V_Flag==1)
		if(exists("zero2")==0)
			getaxis/W=intensresp/Q bottom
			Make/N=(floor(V_max))/D/O zero2
		endif
		removefromgraph/W=intensresp/Z zero2
		if(checked==1)
			appendtograph/W=intensresp zero2
			wavestats/q resp
			ModifyGraph offset(zero2)={0,V_max}
			ModifyGraph rgb(zero2)=(0,0,65535)
		endif
	endif
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Function Satexpfunc(x,a,b) //Used for creating "fit curve" from the curvefit coeficients to compare against the data curve for R2 values in macro above.
	variable x
	variable a
	variable b
	return(a - exp(-b * x))
end

//****************************************************************
//****************************************************************
//****************************************************************

Function StandardSetup()//anatype,ampgainstr,powFB, powBB,sweeplength,baselinelength,tsteplocal,fdur,useold,usetemp)
	string anatype="Standard"
	string ampgainstr="Auto"
	variable sweeplength=5
	variable baselinelength=1
	string tsteplocal="Auto"
	variable powFB; variable powBB; variable fdur=10
	string useold="no"
	string usetemp="no"
	
	prompt anatype, "Analysis Type:",popup,"Standard;Adaptation;ERG;Flicker"
	prompt ampgainstr, "Amplifier Gain:",popup,"500;200;100;50;Auto;20;10;5;2;1;0.5"
	prompt powFB, "Power of 500nm Front Beam (µW):"
	prompt powBB, "Power of 520nm Back Beam (µW):"
	prompt sweeplength, "Sweep Length (seconds):"
	prompt baselinelength, "Baseline Length (seconds):"
	prompt tsteplocal, "Sampling Time (seconds or Hz):"
	prompt fdur, "Flash Duration (milliseconds):"
	prompt useold, "Use currently loaded waves?", popup,"no;yes"
	prompt usetemp, "Calculate temperatures?", popup,"no;yes"
	
	doprompt "Variables" anatype,ampgainstr,powFB,powBB,sweeplength,baselinelength,tsteplocal,fdur,useold,usetemp
	if(V_Flag)
		Abort
	endif
	
	if(stringmatch(anatype,"Flicker"))
		Variable flickerlength
		prompt flickerlength, "Length of Flicker stimulation (s):"
		doprompt "Flicker Variables" flickerlength
		variable/g root:globals:numflickerstim
	endif
	
	variable/g root:globals:fdur=fdur
	variable/g root:globals:sweeplength=sweeplength
	variable/g root:globals:baselinelength=baselinelength
	variable/g root:globals:pdiodeshift=0
	
//	variable ampgain = str2num(ampgainstr)
	variable/g root:globals:adaptflag
	string dates="Jan;Feb;Mar;Apr;May;Jun;Jul;Aug;Sep;Oct;Nov;Dec"
	string yearstr= stringfromlist(5,replacestring(" ",date(),","),",")
	string monthstr = num2str(whichlistitem(stringfromlist(2,replacestring(" ",date(),","),","),dates,";")+1)
	if (strlen(monthstr)==1)
		monthstr = "0"+monthstr
	endif
	string daystr = stringfromlist(3,replacestring(" ",date(),","),",")
	if (strlen(daystr)==1)
		daystr = "0"+daystr
	endif
	MakeDefaultWaves(str2num(yearstr+monthstr+daystr)) //replaces default waves with fresh ones every time...
	
	NVAR adaptflag=root:globals:adaptflag
	NVAR adaptcomplete=root:globals:adaptcomplete
	NVAR standardcomplete=root:globals:standardcomplete
	standardcomplete=0
	adaptcomplete=0
	
	//bind local wave references to global ones...
	WAVE/T Measurements=root:Measurements
	WAVE ndfvoltage=root:ndfvoltage
	WAVE ndflist=root:ndflist
	WAVE bbndfvoltage=root:bbndfvoltage
	WAVE ndftrue=root:ndftrue
	WAVE bbndftrue=root:bbndftrue
	
	if(stringmatch(tsteplocal,"Auto")==0 && char2num(num2str(str2num(tsteplocal))[0])==char2num("N")) //check if tsteplocal is not a valid number...
		Abort "ERROR: improper number \""+tsteplocal+"\" used for sampling time"
	endif
	
	Silent 1
	Pauseupdate
	variable oldimems = 0
	if(stringmatch(useold,"no"))
		oldimems=0
	else
		oldimems=1
		KillAllWindows()
		
		NewDataFolder/o root:temp
		if(exists("root:NQ_Imem"))
			movewave root:NQ_Imem, root:temp:
		endif
		if(exists("root:NQ_PDIODE"))
			movewave root:NQ_PDIODE, root:temp:
		endif
		if(exists("root:NQ_BBNDF"))
			movewave root:NQ_BBNDF, root:temp:
		endif
		if(exists("root:NQ_FBNDF"))
			movewave root:NQ_FBNDF, root:temp:
		endif
		if(exists("root:NQ_Temp"))
			movewave root:NQ_Temp, root:temp:
		endif
		if(exists("root:Imemchart"))
			movewave root:Imemchart, root:temp:
		endif
		if(exists("root:pdiodechart"))
			movewave root:pdiodechart, root:temp:
		endif
		if(exists("root:ndfchart"))
			movewave root:ndfchart, root:temp:
		endif
		if(exists("root:Measurements"))
			movewave root:Measurements, root:temp:
		endif
		if(exists("root:Values"))
			movewave root:Values, root:temp:
		endif
		
		setdatafolder root:
		killwaves/A/Z
		
		if(exists("root:temp:NQ_Imem"))
			movewave root:temp:NQ_Imem, root:
		endif
		if(exists("root:temp:NQ_PDIODE"))
			movewave root:temp:NQ_PDIODE, root:
		endif
		if(exists("root:temp:NQ_BBNDF"))
			movewave root:temp:NQ_BBNDF, root:
		endif
		if(exists("root:temp:NQ_FBNDF"))
			movewave root:temp:NQ_FBNDF, root:
		endif
		if(exists("root:temp:NQ_Temp"))
			movewave root:temp:NQ_Temp, root:
		endif
		if(exists("root:temp:Imemchart"))
			movewave root:temp:Imemchart, root:
		endif
		if(exists("root:temp:pdiodechart"))
			movewave root:temp:pdiodechart, root:
		endif
		if(exists("root:temp:ndfchart"))
			movewave root:temp:ndfchart, root:
		endif
		if(exists("root:temp:Measurements"))
			movewave root:temp:Measurements, root:
		endif
		if(exists("root:temp:Values"))
			movewave root:temp:Values, root:
		endif
		
		killdatafolder/z root:temp
	endif
	variable ampgain
	if(oldimems==0)
		if(stringmatch(anatype,"ERG"))
			//Load waves
			LoadWave/G/D/O/N=wave ""
			//rename to NQ_Imem, etc...
			SetScale/P x 0,0.0005, "s", wave0, wave1
			duplicate/o wave0 NQ_PDIODE
			duplicate/o wave1 NQ_Imem
			duplicate/o wave1 NQ_FBNDF //make false ndf wave
			NQ_FBNDF=0
			killwaves wave0 wave1
		else
			GetFileFolderInfo/Q/P=Igor "???" //??? is a nonexistant file to invoke the same behavior in cross-platform applications of this command.
			LoadData/j="NQ_Imem;NQ_PDIODE;NQ_BBNDF;NQ_FBNDF;NQ_Gain" S_Path
			if(stringmatch(ampgainstr,"Auto"))
				if(waveexists(NQ_Gain))
					make/o/n=10 ampgainw = {0.5,1,2,5,10,20,50,100,200,500}
					ampgain = ampgainw[2*(round(10*mean(NQ_Gain))/10-2)]
					killwaves ampgainw, NQ_Gain
					//print "Amplifier gain set to: "+num2str(ampgain)
				else
					//dopromt for no gain
					doprompt "Amplifier gain not detected", ampgainstr
					ampgain = str2num(ampgainstr)
				endif
			else
				ampgain = str2num(ampgainstr)
			endif
			//get date and pass to MakeDefaultWaves
			string theFile=stringfromlist(itemsinlist(S_Path,":")-1,S_Path,":")[0,9]
			print "making defaults from loaded file"
			MakeDefaultWaves(str2num(stringfromlist(0,theFile,"-")+stringfromlist(1,theFile,"-")+stringfromlist(2,theFile,"-"))) //replaces default waves with fresh ones every time...
			
			//bind local wave references to global ones...
			WAVE/T Measurements=root:Measurements
			WAVE ndfvoltage=root:ndfvoltage
			WAVE ndflist=root:ndflist
			WAVE bbndfvoltage=root:bbndfvoltage
			WAVE ndftrue=root:ndftrue
			WAVE bbndftrue=root:bbndftrue
		endif
		if(stringmatch(usetemp,"yes"))
			LoadData/j="NQ_Temp" S_Path
			if(exists("NQ_Temp")==0)
				Print "     No temperature information present..."
				DoAlert 1, "ERROR: This file does not contain any temperature information. Continue without?"
				if(V_flag==2)
					Print "     PROCEDURE ABORTED..."
					Abort
				else
					Print "     NOTE: Continuing without temperature information."
				endif
			else
				Print "     Including temperature information."
			endif
		endif
	endif
	if(exists("NQ_Imem")==0 || exists("NQ_PDIODE")==0 || exists("NQ_FBNDF")==0)
		Abort "ERROR: The appropriate required waves could not be located"
	endif
	
	print "     Using setup values:",anatype,ampgainstr,powFB,powBB,sweeplength,baselinelength,tsteplocal,fdur,useold,usetemp
	
	//set tstep based on deltax value of wave for dynamic tstep setting...
	if(stringmatch(tsteplocal,"Auto"))
		tsteplocal=num2str(1/round(1/deltax(NQ_Imem)))
		Print "     Setting time scale to "+tsteplocal+"s ("+num2str(1/str2num(tsteplocal))+"Hz), based on imported wave scale value."
	endif
	
	variable/g root:globals:tstep
	NVAR tstep=root:globals:tstep
	tstep=str2num(tsteplocal)
	
	//ampgain=str2num(ampgainstr) defined above
	if(stringmatch(anatype,"Adaptation"))
		adaptflag=1
	else
		adaptflag=0
	endif

	variable tablefsize
	if(powFB==0)
		Abort "ERROR: Enter 500nm light calibration power in µW!"
	endif
	dowindow/K Table0 //get rid of default table0....
	if(adaptflag==1)
		execute "AdaptControlPanel()"
	endif
	if(stringmatch(IgorInfo(2),"Windows")) //Microsoft Windows
		tablefsize=10 //appropriate table font size for respective OS...
	endif
	if(stringmatch(IgorInfo(2),"Macintosh")) //Apple Macintosh
		tablefsize=9 //was 9pt for "Geneva" font...changed to Arial to keep things consistent with Windows.
	endif
//	if(exists("ndfvoltage")==0 || exists("ndflist")==0 || exists("Measurements")==0 || exists("Values")==0 || exists("bbndftrue")==0 || exists("bbndfvoltage")==0 || exists("ndftrue")==0)
	
	if(adaptflag==0)
		Edit/n=summarytable Measurements,Values
		ModifyTable/W=summarytable alignment(Point)=1,width(Point)=29,width(Measurements)=160,width(Values)=120,size=tablefsize,showParts=6
	endif
	if(oldimems==0)
		Measurements[0]=ParseFilePath(3, S_Path, ":", 0, 0)	// Appends File Name to Table 1
	endif
	Print "     Amplifier Gain of "+num2str(ampgain)+" Used."
	//DISPLAYCHARTS
	Silent 1; PauseUpdate
	if(oldimems==0)
		//Duplicate source waves
		duplicate/o NQ_Imem imemchart
		duplicate/o NQ_PDIODE pdiodechart
//		killwaves NQ_Imem NQ_PDIODE
		//convert V to pA 
		Imemchart*=-1000/ampgain
		SetScale d 0,0,"pA", imemchart
		//Scale X axes according to rounded Hz sampling rate (calculated above)
		SetScale/P x 0,tstep,"s", imemchart, NQ_FBNDF, NQ_BBNDF, pdiodechart
		//magnify and re-position pdiode trace for easier visualization
		pdiodechart*=10
		pdiodechart-=7
	endif
	
	WAVE pdiodechart=root:pdiodechart
	//tstep = time interval between points
	//swlngth = length of sweep (in seconds) to display in one graph
	variable swplngth = 60 //Seconds on the X-axis per layout graph
	variable tot = numpnts(imemchart)*tstep/swplngth
	variable cnt = 0
	variable numgrphs
//	variable num = 0 //Starting number for wave counts...
	variable scan = 0
	variable fbscan = 0 //temp scan variable used when finding front beam times
	variable bbscan = 0 //temp scan variable used when finding back beam times
	variable baseline = 0
	variable/g root:globals:numwaves = 0 //Starting number for wave counts...(was "num")
	variable pdiodebase = mean(pdiodechart,pnt2x(pdiodechart,scan), pnt2x(pdiodechart,scan+200))
	variable fblvl=-6.5 //-6.5 = default!!!!
	variable/g fbthresh=-6.3 //was -5.9
	variable fbfound = 0
	variable bblvl=-6.8
	variable/g bbthresh=-6.7 //-6.85  //was -6.9
	variable flshtype = 0
	variable bbfound = 0
	variable fbstatus=0
	variable bbstatus=0
	variable fbcount=0
	variable bbcount=0
	variable i=0
	variable/g root:globals:adaptflag
	//variables for Tsat measurements....
	variable basestart=0.5
	variable baseend=1.0
	variable satstart=1.1 //saturation time for Id calc...
	variable satend=1.2 //saturation time for Id calc...yields a minimum of 100ms for the flash duration.
	variable tsat
	variable darki
	variable base, sat
	variable ftime=1.045 //was 1.025...doesnt matter because we're finding the start of the saturation time instead of fixing it...
	variable a
	variable j
	variable bboffval //temp variable for storing when the bb is turned off (updated for each graph)
	variable flashval //temp variable for storing when next flash occurs...to compare to bboffval
	variable fbendtime
	variable bbendtime //stored value of when the bb is turned off (same value as bboffval)
	variable fbstarttime
	variable bbstarttime //stored value of when the bb is turned on...to subtract from bbendtime when labeling the BB endpoint.
	variable halfmax
	variable pdiodestart
	variable pdiodeend
	variable startcut
	variable endcut
	variable overlapdist
	variable overlapflag=0
	string wavenm=""
	string pdiodenm=""
	cnt=0
	NVAR numwaves=root:globals:numwaves
	NVAR numflickerstim=root:globals:numflickerstim
	variable flickerrflag=0
	
	string imemSTR
	string pdiodeSTR
	string fbndfSTR
	string bbndfSTR
	
	//SETUP PDIODE THRESHOLDS (FBTHRESH AND BBTHRESH)
////	Make/o/n=(3*numpnts(pdiodechart)) fbthreshW bbthreshW
////	duplicate/o pdiodechart fbthreshW bbthreshW
//	fbthreshW=0
//	bbthreshW=0
//	setscale/P x, -numpnts(pdiodechart)*deltax(pdiodechart), deltax(pdiodechart), "s", fbthreshW, bbthreshW
//	display/n=thresh/w=(300,100,800,400) pdiodechart fbthreshW bbthreshW
//		SetAxis bottom 0,numpnts(pdiodechart)*deltax(pdiodechart)
//		Button threshaccept, win=thresh, size={65,25},pos={420,70},proc=threshaccept,title="Accept",fColor=(50000,50000,50000)
//		Button threshdefault, win=thresh, size={65,25},pos={420,100},proc=threshdefault,title="Reset",fColor=(50000,50000,50000)
//		Button threshcancel, win=thresh, size={65,25},pos={420,130},proc=threshcancel,title="Cancel",fColor=(50000,50000,50000)
//		ModifyGraph rgb(fbthreshW)=(0,65535,0),offset(fbthreshW)={0,fbthresh},lsize(fbthreshW)=5,quickdrag(fbthreshW)=1,live(fbthreshW)=1
//		ModifyGraph rgb(bbthreshW)=(0,0,65535),offset(bbthreshW)={0,bbthresh},lsize(bbthreshW)=5,quickdrag(bbthreshW)=1,live(bbthreshW)=1
//		ModifyGraph margin(right)=108
//		ModifyGraph mirror=2
//		ModifyGraph noLabel(bottom)=1
//		ModifyGraph wbRGB=(60000,60000,60000)
//		Legend/E/X=0/Y=0/C/N=Legend/J/A=RT "\\s(fbthreshW) Front Beam\r\\s(bbthreshW) Back Beam"
//		TextBox/C/N=title/A=LT/E=2/X=5/Y=3 "\\f01Set Photodiode Thresholds"
//	pauseforuser thresh //clicking buttons on graph 
//	killwaves fbthreshW bbthreshW

	//Manually check and adjust NDF voltage and beam threshold levels
	threshcheck()
	
	silent 1;pauseupdate
	if(adaptflag) //If we're in adapt mode, make proper lists and tables for adaptation data...
		if(exists("bbstart")==0 || exists("bbend")==0 || exists("bbflist")==0 || exists("adaptbaselist")==0 || exists("adaptlist")==0)
			Make/N=0/D/O bbstart,bbend,bbflist,adaptbaselist,adaptbaseIdlist,adaptbasesatlist,adaptbaselisttimes,adaptlist,adaptIdlist,adaptsatlist,adaptlisttimes //waves to contain lists of base and adaptation waves..."imem1", etc for base, and "~imem6+" for 
			Make/N=0/D/O fbstart, fbend, fbflist
			edit/n=bbinfo bbstart,bbend,bbflist,adaptbaselist,adaptbaseIdlist,adaptbasesatlist,adaptbaselisttimes,adaptlist,adaptIdlist,adaptsatlist,adaptlisttimes
			edit/n=fbinfo fbstart,fbend,fbflist,adaptbaselist,adaptbaseIdlist,adaptbasesatlist,adaptbaselisttimes,adaptlist,adaptIdlist,adaptsatlist,adaptlisttimes
		endif
	endif
	
	//declared for graph window loops...
	variable pdiodepnts=numpnts(pdiodechart)
	variable V_avg=0
	variable V_max=0
	
	//Display new graph windows
	NewPanel/FLT=1 /N=ProgressPanel /W=(300,200,800,300)
		TitleBox valtitle,title="Processing Waves...",win=ProgressPanel,fsize=14,frame=0,pos={50,20},size={100,25}
		ValDisplay valdisp0,pos={50,50},size={400,25}
		ValDisplay valdisp0,limits={0,numpnts(NQ_PDIODE),0},barmisc={0,0}
		ValDisplay valdisp0,value=_NUM:0
		ValDisplay valdisp0,mode=3
		ValDisplay valdisp0,highColor=(0,40000,0)
		
	DoUpdate /W=ProgressPanel /E=1
	
	for(cnt=0;cnt<tot;cnt+=1)
		display/HIDE=1 imemchart pdiodechart
		setaxis bottom cnt*swplngth,swplngth*(cnt+1)
		ModifyGraph rgb(pdiodechart)=(0,0,0)
		
		//iterate through graph0, graph1, etc...and label waves in the respective graph...pdiode location variable = "scan"
		for(scan=scan;scan<(swplngth/tstep*(cnt+1));scan+=0.025/tstep) //was "10", now is 25msec based on tstep and +/- 25msec "flash window" used in "flashtype" function. //scan=swplngth/tstep*(cnt)
			
			ValDisplay valdisp0,value=_NUM:scan,win=ProgressPanel
			DoUpdate /W=ProgressPanel
			
			//Find if and where FB or BB is turned on during the current graph's range
			
			//findvalue/V=-6.9/T=0.1/S=(scan) pdiodechart //find the next value where BB changes
			findlevel/P/Q/R=[scan,swplngth/tstep*(cnt+1)] pdiodechart, bbthresh // reserve this: /R=[scan,swplngth/tstep*(cnt+1)] 
			if(V_flag==0) //level found...
				bbscan=floor(V_LevelX) //not adding 2 points centers the scan at the peak of the pdiode pulse
			else
				bbscan=pdiodepnts
			endif
			
			//findvalue/V=-5.9/T=0.5/S=(scan) pdiodechart //find the next value where FB changes
			findlevel/P/Q/R=[scan,swplngth/tstep*(cnt+1)] pdiodechart, fbthresh //EDGE=1 <-- using scan adjustment instead
			if(V_flag==0) //level found...
				fbscan=floor(V_LevelX) //was "+2"....see above...
			else
				fbscan=pdiodepnts
			endif
			
			//if fbscan and bbscan are both set to the maximum number of points in the wave (no more points found), scanning is over and we break out of the loop and move to the next graph
			//The "cnt" will increase by one and meet the terms for cancelling the parent do/while loop, ending the display of new graphs.
			if(fbscan==pdiodepnts && bbscan==pdiodepnts)
				break
			endif
			
			//set scan value to point value where first "pdiode change" was found
			if(bbscan<fbscan)
				scan=bbscan
			else
				scan=fbscan
			endif
			
			//Characterize flashtype (return values: 1 = FB flash, 2 = FB on, -2 = FB off, 3 = BB flash, 4 = BB on, -4 = BB off, 5 = FB flicker, 6 = BB flicker, 0 = unknown)
			flshtype = flashtype(pdiodechart, scan, fbthresh, bbthresh, str2num(tsteplocal))
			
			if(flshtype==0)
				Tag/F=0/Z=1/L=0 /B=1 /A=MT /X=0 /Y=100 pdiodechart, (scan-5)*tstep, "\f01?"
			endif

			//if FB pdiode spike is found that is of SHORT duration, regardless of baseline pdiode level...(flash)
			if(flshtype==1) //FB flash
			
				//in X
				startcut=pnt2x(pdiodechart,scan)-baselinelength
				endcut=startcut+sweeplength
				
				//find next FB change (flash) if in the cut sweep length
				findlevel/P/Q/EDGE=1/R=[fbscan+fdur,x2pnt(pdiodechart, endcut)] pdiodechart, fbthresh
				//if next flash location is less than sweep length, set points after flast to nan
				if(V_flag==0) //level found...
					overlapflag=1
					overlapdist=floor(V_LevelX)-fbscan //in points
				endif
				
				V_avg=mean(NQ_FBNDF,pnt2x(NQ_FBNDF,scan-5),pnt2x(NQ_FBNDF,scan+5)) //find ndf of flash (front beam) -- 10pt average to beat down noise...
				FindLevel/Q ndfvoltage, V_avg
				if(V_avg<ndfvoltage[0]) //Added check in to compensate for when ndf0 "rawfbndf" values are lower than the lowest in the ndfvoltage table
					V_LevelX=0
				endif
//				Tag/F=0/Z=1/L=0 /B=1 /A=MT /X=0 /Y=100 pdiodechart, (scan-5)*root:globals:tstep, "\JC\f01"+num2str(num+1)+"\r("+num2str(ndflist[round(V_LevelX)])+")"
				if(exists("NQ_Temp")==1 && char2num(usetemp[0])==char2num("y"))  //find temperature of bath at flash
					Tag/F=0/Z=1/L=0 /B=1 /A=MT /X=0 /Y=100 pdiodechart, (scan-5)*tstep, "\JC\f01"+num2str(numwaves+1)+"\r("+num2str(ndflist[round(V_LevelX)])+")\r"+num2str(TempC(mean(NQ_Temp,pnt2x(NQ_Temp,scan-5),pnt2x(NQ_Temp,scan+5))))
				else
					Tag/F=0/Z=1/L=0 /B=1 /A=MT /X=0 /Y=100 pdiodechart, (scan-5)*tstep, "\JC\f01"+num2str(numwaves+1)+"\r("+num2str(ndflist[round(V_LevelX)])+")"
				endif
				
				imemSTR = "imem"+num2str(numwaves+1)
				pdiodeSTR = "pdiode"+num2str(numwaves+1)
				fbndfSTR = "fbndf"+ num2str(numwaves+1)
				bbndfSTR = "bbndf"+ num2str(numwaves+1)
				
				duplicate/o/r=(startcut,endcut) pdiodechart $pdiodeSTR
				WAVE pdiode = root:$pdiodeSTR
				SetScale/P x 0,tstep,"s", pdiode //$pdiodeSTR
				baseline = mean(pdiode, 0, baselinelength) //baseline offset to zero for imem wave
				pdiode-=baseline
				if(overlapflag)
					pdiode[overlapdist, numpnts(pdiode)]=nan
				endif
				duplicate/o/r=(startcut,endcut) imemchart $imemSTR
				WAVE imem = root:$imemSTR
				SetScale/P x 0,tstep,"s", imem //$imemSTR
				baseline = mean(imem, 0, baselinelength) //baseline offset to zero for imem wave
				imem-=baseline
				if(overlapflag)
					imem[overlapdist, numpnts(imem)]=nan
				endif
				duplicate/o/r=(startcut,endcut) NQ_FBNDF $fbndfSTR
				WAVE fbndf = root:$fbndfSTR
				if(overlapflag)
					fbndf[overlapdist, numpnts(fbndf)]=nan
				endif
				//cut this and put it with the "BB on" value below?
				//only do if bbstatus==1?
				if(exists("NQ_BBNDF")==1) //only dupicate and deal with the BB NDF trace if we're using the BB in the current experiment.
					duplicate/o/r=(startcut,endcut) NQ_BBNDF $bbndfSTR
					WAVE bbndf = root:$bbndfSTR
					if(overlapflag)
						bbndf[overlapdist, numpnts(bbndf)]=nan
					endif
				endif
				
				overlapflag=0
				
//				if(V_flag==0)
//					pdiode[V_LevelX,numpnts(pdiode)]=0
//					imem[V_LevelX,numpnts(imem)]=0
//					fbndf[V_LevelX,numpnts(fbndf)]=0
//					if(exists("NQ_BBNDF")==1)
//						bbndf[V_LevelX,numpnts(bbndf)]=0
//					endif
//				endif
				
				//make wavelists. V_LevelX is from the FindLevel function above, run on the ndfvoltage wave
				if(exists("f"+num2str(ndflist[round(V_LevelX)]))==0)
					make/n=1 $("f"+num2str(ndflist[round(V_LevelX)]))
					if(wintype("wavelists")==0)
						edit/n=wavelists/HIDE=1 as "wavelists"
					endif
					appendtotable/w=wavelists $("f"+num2str(ndflist[round(V_LevelX)]))
				else
					insertpoints numpnts($("f"+num2str(ndflist[round(V_LevelX)]))), 1, $("f"+num2str(ndflist[round(V_LevelX)]))
				endif
				
				WAVE fnum = $("f"+num2str(ndflist[round(V_LevelX)]))
				fnum[numpnts(fnum)]=numwaves+1
				
	//--------------------------------------ADAPTATION SATURATION TIMES (adaptflag)
				if(adaptflag) //If we're in adapt mode, measure tsat and id and time of occurence for the above-identified and created wave...
					if(bbstart[0]>0) //if start of adapting light has been identified...
						InsertPoints i+1,1,adaptlist
						adaptlist[i]=numwaves+1
						InsertPoints i+1,1,adaptlisttimes
						adaptlisttimes[i]=scan*tstep
						InsertPoints i+1,1,adaptsatlist
						InsertPoints i+1,1,adaptIdlist
						wavenm = "imem"+num2str(adaptlist[i])
						pdiodenm = "pdiode"+num2str(adaptlist[i])
						if(exists(wavenm)==1) //Tsat measurements for spikes after adaptation light....
							//compute dark current for wave
							darki=darkcurrent($wavenm,basestart,baseend,satstart,satend)
							
							//CALCULATE ftime BASED ON FILTER DELAY AND MIDPOINT OF PDIODE 'FWHM' -- instead of after "findlevels" below...
							if(exists(pdiodenm)==0) //redo avef and varf waves, creating pdiode ave/var waves if they don't exist.
								Print"--Recalculating average and variance for pdiode traces..."
								AveVarAll()
							endif
							halfmax=0.5*wavemax($pdiodenm,0.95,1.05)
							FindLevels/P/Q $pdiodenm, halfmax //0.95 to 1.05 covers the location of the pulse...
							if(V_LevelsFound==2)
								FindLevel/EDGE=1/Q $pdiodenm, halfmax
								pdiodestart=V_LevelX
								FindLevel/EDGE=2/Q $pdiodenm, halfmax
								pdiodeend=V_LevelX
							else
								Print "ERROR: Pdiode center not found"
							endif
			
							ftime=0.51/30+(pdiodestart+pdiodeend)/2
							
							//Find where spike first passes 90% of the Dark Current
//							FindLevel/B=5/Q $wavenm,(0.9*darki)
//							ftime=round(1000*V_LevelX)/1000

							//compute saturation time for wave
							tsat=sattime($wavenm,darki,0.9)
//							print "   Adapt:","|  Tsat:",tsat+ftime,"-",ftime,"=", tsat, "seconds  |  Dark current:", darki, "pA for:",wavenm //tsat+ftime is because sattime() function computes and outputs "tsat-ftime"
							printf "     Adapt:  |  Tsat:  %2.3f  -  %2.3f  =  %2.3f  seconds  |  Dark current:  %2.3f pA for:  %s\r",tsat+ftime,ftime,tsat,darki,wavenm
							adaptIdlist[i]=darki
							adaptsatlist[i]=tsat
						else
							adaptIdlist[i]=NaN
							adaptsatlist[i]=NaN
						endif
					else //if start of adapting light has NOT been identified...
						InsertPoints i+1,1,adaptbaselist
						adaptbaselist[i]=numwaves+1
						InsertPoints i+1,1,adaptbaselisttimes
						adaptbaselisttimes[i]=scan*tstep
						InsertPoints i+1,1,adaptbasesatlist
						InsertPoints i+1,1,adaptbaseIdlist
						wavenm = "imem"+num2str(adaptbaselist[i])
						if(exists(wavenm)==1) //Tsat measurements for spikes before adaptation light....
							//compute dark current for wave
							darki=darkcurrent($wavenm,basestart,baseend,satstart,satend)
							
							//CALCULATE ftime BASED ON FILTER DELAY AND MIDPOINT OF PDIODE 'FWHM' -- instead of after "findlevels" below...
							if(exists(pdiodenm)==0) //redo avef and varf waves, creating pdiode ave/var waves if they don't exist.
								Print"--Recalculating average and variance for pdiode traces..."
								AveVarAll()
							endif
							halfmax=0.5*wavemax($pdiodenm,0.95,1.05)
							FindLevels/P/Q $pdiodenm, halfmax //0.95 to 1.05 covers the location of the pulse...
							if(V_LevelsFound==2)
								FindLevel/EDGE=1/Q $pdiodenm, halfmax
								pdiodestart=V_LevelX
								FindLevel/EDGE=2/Q $pdiodenm, halfmax
								pdiodeend=V_LevelX
							else
								Print "ERROR: Pdiode center not found"
							endif
			
							ftime=0.51/30+(pdiodestart+pdiodeend)/2
							
							//Find where spike first passes 90% of the Dark Current
							FindLevel/B=5/Q $wavenm,(0.9*darki)
							ftime=round(1000*V_LevelX)/1000
							//compute saturation time for wave
							tsat=sattime($wavenm,darki,0.9)
//							print "   Baseline: ","|  Tsat:",tsat+ftime,"-",ftime,"=", tsat, "seconds  |  Dark current:", darki, "pA for:",wavenm //tsat+ftime is because sattime() function computes and outputs "tsat-ftime"
							printf "     Baseline:  |  Tsat:  %2.3f  -  %2.3f  =  %2.3f  seconds  |  Dark current:  %2.3f pA for:  %s\r",tsat+ftime,ftime,tsat,darki,wavenm
							adaptbaseIdlist[i]=darki
							adaptbasesatlist[i]=tsat
						else
							adaptbaseIdlist[i]=NaN
							adaptbasesatlist[i]=NaN
						endif
					endif
				endif
	//--------------------------------------
				i+=1
				numwaves+=1 //imem or "flash" number found...
			endif
			
			if(flshtype==4) //BB turned on
				bbstatus=1 //might CHANGE to a value system instead of signal shape...
				if(adaptflag)
					InsertPoints bbcount,1, bbstart,bbend,bbflist
					bbstart[bbcount]=scan
				endif
				bbstarttime=scan //to subtract from bbendtime to get time bb is on...for end label.
				
				if(exists("NQ_BBNDF"))
					V_avg=mean(NQ_BBNDF,pnt2x(NQ_BBNDF,scan+1),pnt2x(NQ_BBNDF,scan+10)) //find ndf of flash (back beam)
					//wavestats/Q/R=[scan+1, scan+10] NQ_BBNDF	
					FindLevel/Q bbndfvoltage, V_avg
					if(V_avg<bbndfvoltage[0]) //Added check in to compensate for when ndf0 "rawfbndf" values are lower than the lowest in the ndfvoltage table
						V_LevelX=0
					endif
					Tag/F=0/Z=1/L=0 /B=1 /A=LT /X=0 /Y=100 pdiodechart, (scan-5)*tstep, "\f01|BB"+num2str(bbcount+1)+" ("+num2str(ndflist[round(V_LevelX)])+")\r|--›"
				else
					//V_LevelX=0
					Tag/F=0/Z=1/L=0 /B=1 /A=LT /X=0 /Y=100 pdiodechart, (scan-5)*tstep, "\f01|BB"+num2str(bbcount+1)+" (?)\r|--›"
				endif
				
			endif

			if(flshtype==-4) //BB turned off
				bbstatus=0
				if(adaptflag)
					bbend[bbcount]=scan
					Tag/C/N=bbendtag/F=0/Z=1/L=0 /B=1 /A=RT /X=0 /Y=100 pdiodechart, bbend[bbcount]*tstep, "\JR\f01"+num2str((bbend[bbcount]-bbstart[bbcount])*tstep)+"s|\r‹--|" //may need to change end times to take into account gaps...
				else
					bbendtime=scan
					Tag/F=0/Z=1/L=0 /B=1 /A=RT /X=0 /Y=100 pdiodechart, (scan-5)*tstep, "\JR\f01"+num2str((bbendtime-bbstarttime)*tstep)+"s|\r‹--|"
				endif
				bbcount+=1
			endif

			if(flshtype==2) //FB turned on
				fbstatus=1 //might CHANGE to a value system instead of signal shape...
				if(adaptflag)
					InsertPoints fbcount,1, fbstart,fbend,fbflist
					fbstart[fbcount]=scan
				endif
				fbstarttime=scan //to subtract from bbendtime to get time bb is on...for end label.
				
				V_avg=mean(NQ_FBNDF,pnt2x(NQ_FBNDF,scan+1),pnt2x(NQ_FBNDF,scan+10)) //find ndf of flash (front beam)
				//wavestats/Q/R=[scan+1, scan+10] NQ_FBNDF	
				FindLevel/Q ndfvoltage, V_avg
				if(V_avg<ndfvoltage[0]) //Added check in to compensate for when ndf0 "rawfbndf" values are lower than the lowest in the ndfvoltage table
					V_LevelX=0
				endif
		
				Tag/F=0/Z=1/L=0 /B=1 /A=LT /X=0 /Y=100 pdiodechart, (scan-5)*tstep, "\f01|FB"+num2str(fbcount+1)+" ("+num2str(ndflist[round(V_LevelX)])+")\r|--›"
			endif

			if(flshtype==-2) //FB turned off
				fbstatus=0
				if(adaptflag)
					fbend[fbcount]=scan
					Tag/C/N=fbendtag/F=0/Z=1/L=0 /B=1 /A=RT /X=0 /Y=100 pdiodechart, fbend[fbcount]*tstep, "\JR\f01"+num2str((fbend[fbcount]-fbstart[fbcount])*tstep)+"s|\r‹--|" //may need to change end times to take into account gaps...
				else
					fbendtime=scan
					Tag/F=0/Z=1/L=0 /B=1 /A=RT /X=0 /Y=100 pdiodechart, (scan-5)*tstep, "\JR\f01"+num2str((fbendtime-fbstarttime)*tstep)+"s|\r‹--|"
				endif
				fbcount+=1
			endif
			
			if(flshtype==5) //FB flicker
				flickerrflag+=1
//				print "Front Beam Flicker"
				//need total flicker stim length
				//power spec of pdiode for length
					//get dominant frequency, to nearest 100Hz
				//in X
				variable flickerend = flashtype(pdiodechart, scan+(flickerlength-2)/tstep, fbthresh, bbthresh, tstep) //determine if end of flicker length also contains flicker (not halted half-way through)
				if(flickerend==5)
					flickerrflag=0
					startcut=pnt2x(pdiodechart,scan)-baselinelength
					endcut=startcut+flickerlength+sweeplength
					
					V_avg=mean(NQ_FBNDF,pnt2x(NQ_FBNDF,scan-5),pnt2x(NQ_FBNDF,scan+5)) //find ndf of flash (front beam) -- 10pt average to beat down noise...
					FindLevel/Q ndfvoltage, V_avg
					if(V_avg<ndfvoltage[0]) //Added check in to compensate for when ndf0 "rawfbndf" values are lower than the lowest in the ndfvoltage table
						V_LevelX=0
					endif
	//				Tag/F=0/Z=1/L=0 /B=1 /A=MT /X=0 /Y=100 pdiodechart, (scan-5)*root:globals:tstep, "\JC\f01"+num2str(num+1)+"\r("+num2str(ndflist[round(V_LevelX)])+")"
					if(exists("NQ_Temp")==1 && char2num(usetemp[0])==char2num("y"))  //find temperature of bath at flash
						Tag/F=0/Z=1/L=0 /B=1 /A=LT /X=0 /Y=100 pdiodechart, (scan)*tstep, "\JL\f10"+num2str(numflickerstim+1)+"-Flicker\r(F"+num2str(ndflist[round(V_LevelX)])+", "+num2str(flickerlength)+"s, "+num2str(domfreq(pdiodechart,scan,flickerlength))+"Hz)\r"+num2str(TempC(mean(NQ_Temp,pnt2x(NQ_Temp,scan-5),pnt2x(NQ_Temp,scan+5))))
					else
						Tag/F=0/Z=1/L=0 /B=1 /A=LT /X=0 /Y=100 pdiodechart, (scan)*tstep, "\JL\f10"+num2str(numflickerstim+1)+"-Flicker\r(F"+num2str(ndflist[round(V_LevelX)])+", "+num2str(flickerlength)+"s, "+num2str(domfreq(pdiodechart,scan,flickerlength))+"Hz)"
					endif
					
					imemSTR = "F_imem"+num2str(numflickerstim+1)
					pdiodeSTR = "F_pdiode"+num2str(numflickerstim+1)
					fbndfSTR = "F_fbndf"+ num2str(numflickerstim+1)
					bbndfSTR = "F_bbndf"+ num2str(numflickerstim+1)
					
					duplicate/o/r=(startcut,endcut) pdiodechart $pdiodeSTR
					WAVE pdiode = root:$pdiodeSTR
					SetScale/P x 0,tstep,"s", pdiode //$pdiodeSTR
					baseline = mean(pdiode, 0, baselinelength) //baseline offset to zero for imem wave
					pdiode-=baseline
					
					duplicate/o/r=(startcut,endcut) imemchart $imemSTR
					WAVE imem = root:$imemSTR
					SetScale/P x 0,tstep,"s", imem //$imemSTR
					baseline = mean(imem, 0, baselinelength) //baseline offset to zero for imem wave
					imem-=baseline
	
					duplicate/o/r=(startcut,endcut) NQ_FBNDF $fbndfSTR
					WAVE fbndf = root:$fbndfSTR

					//cut this and put it with the "BB on" value below?
					//only do if bbstatus==1?
					if(exists("NQ_BBNDF")==1) //only dupicate and deal with the BB NDF trace if we're using the BB in the current experiment.
						duplicate/o/r=(startcut,endcut) NQ_BBNDF $bbndfSTR
						WAVE bbndf = root:$bbndfSTR
					endif
					
					//make wavelists. V_LevelX is from the FindLevel function above, run on the ndfvoltage wave
					if(exists("F_f"+num2str(ndflist[round(V_LevelX)]))==0)
						make/n=1 $("F_f"+num2str(ndflist[round(V_LevelX)]))
						make/n=1 $("F_f"+num2str(ndflist[round(V_LevelX)])+"Hz")
						make/n=1 $("F_f"+num2str(ndflist[round(V_LevelX)])+"Pow")
						if(wintype("wavelists")==0)
							edit/n=wavelists/HIDE=1 as "Wavelists"
						endif
						appendtotable/w=wavelists $("F_f"+num2str(ndflist[round(V_LevelX)])) $("F_f"+num2str(ndflist[round(V_LevelX)])+"Hz") $("F_f"+num2str(ndflist[round(V_LevelX)])+"Pow")
					else
						insertpoints numpnts($("F_f"+num2str(ndflist[round(V_LevelX)]))), 1, $("F_f"+num2str(ndflist[round(V_LevelX)])), $("F_f"+num2str(ndflist[round(V_LevelX)])+"Hz"), $("F_f"+num2str(ndflist[round(V_LevelX)])+"Pow")
					endif
					
					WAVE fnum = $("F_f"+num2str(ndflist[round(V_LevelX)]))
					WAVE ffreq = $("F_f"+num2str(ndflist[round(V_LevelX)])+"Hz")
					WAVE fpow = $("F_f"+num2str(ndflist[round(V_LevelX)])+"Pow")
						
					fnum[numpnts(fnum)]=numflickerstim+1
					ffreq[numpnts(ffreq)]=domfreq(pdiode,baselinelength/deltax(pdiode),flickerlength)
					fpow[numpnts(fpow)]=domfreqpow(imem,(baselinelength+1)/deltax(imem),flickerlength-1)
//					ffreq[numpnts(ffreq)]=domfreq(pdiodechart,scan,flickerlength)
//					fpow[numpnts(fpow)]=domfreqpow(imemchart,scan+1,flickerlength-1)
					
					//generate power waves
					pspecf(imem,(baselinelength+1)/deltax(imem),flickerlength-1)
					
					//Adaptation stuff goes here...
					
					i+=1
					numflickerstim+=1 //imem or "flash" number found...
					
					scan+=flickerlength/tstep
				else
					if(flickerrflag==1)
						Tag/F=0/Z=1/L=0 /B=1 /A=LT /X=0 /Y=100 pdiodechart, (scan)*tstep, "\JL\f10Flicker Error Skipped\r"
					endif
					scan+=1/tstep //advance by 1 second and retry flicker stim check routine...
				endif
			endif
			
			if(flshtype==6) //BB flicker
				print "Back Beam Flicker"
			endif
		endfor
		numgrphs=cnt+1 //add 1 for lack of graph2 compensation in MAKELAYOUTS loops.
	endfor
	resumeupdate
	print  "     Made waves Imem1 - Imem"+num2str(numwaves)
	if(adaptflag)
		//wavestats/q/z bbend
		V_max=wavemax(bbend)
		if(V_max>0) //only if bbend was found and identified...
			variable adaptend=V_max*tstep //convert the last point of the bbend wave to the bb shutoff time (time zero)
			print "     Final Adaptation End Time: "+num2str(adaptend)+" seconds."
		endif
	endif
	
	KillWindow ProgressPanel
	
	//MAKELAYOUTS
	
	NewPanel/FLT=1 /N=ProgressPanel /W=(300,200,800,300)
		TitleBox valtitle,title="Building Layouts...",win=ProgressPanel,fsize=14,frame=0,pos={50,20},size={100,25}
		ValDisplay valdisp0,pos={50,50},size={400,25}
		ValDisplay valdisp0,limits={0,numgrphs,0},barmisc={0,0}
		ValDisplay valdisp0,value=_NUM:0
		ValDisplay valdisp0,mode=3
		ValDisplay valdisp0,highColor=(0,40000,0)
		
	DoUpdate /W=ProgressPanel /E=1
	
	variable layoutnum=0
	variable menuwidth
	if(stringmatch(IgorInfo(2),"Windows")) //Microsoft Windows
		menuwidth=0 //no menu at the top of screen
	endif
	if(stringmatch(IgorInfo(2),"Macintosh")) //Apple Macintosh
		menuwidth=44 //menu is 44px wide
	endif
	for(cnt=0;cnt<numgrphs;layoutnum+=1) //Display new layouts
		NewLayout/n=$("Layout"+num2str(layoutnum))/W=(layoutnum*100,menuwidth+layoutnum*20,700+layoutnum*100,menuwidth+800+layoutnum*20)/HIDE=1
		ModifyLayout/W=$("Layout"+num2str(layoutnum)) mag=1 //change default zoom level of the layouts.
		Printsettings/W=$("Layout"+num2str(layoutnum)) margins={0.25,0.25,0.25,0.25}
		
		i=0
		for(i=0;i<5;i+=1)
			if(stringmatch(winlist("Graph"+num2str(cnt),"","WIN:1"),"Graph"+num2str(cnt))) //if graph exists (by matching an existing graph window list search)
				AppendLayoutObject graph $("Graph"+num2istr(cnt)) //include it on the current layout
				ValDisplay valdisp0,value=_NUM:cnt+1,win=ProgressPanel
				DoUpdate /W=ProgressPanel
			endif
			cnt+=1
		endfor
		execute "Tile/A=(5,0)"
	endfor
	
	//Show Relevant Windows
	for(i=0;i<layoutnum;i+=1)
		DoWindow/HIDE=0 $("Layout"+num2str(i))
	endfor
	DoWindow/HIDE=0 wavelists
	
	//LIGHT INTENSITY CALCULATIONS
	flstrCalc(powFB, powBB, fdur)
	
	if(adaptflag) //Display adaptation graphs and do calculations, if any...
		//Time in Saturation Graphs and Calculations...
		display/N=AdaptationSat adaptbasesatlist vs adaptbaselisttimes
		appendtograph/W=AdaptationSat adaptsatlist vs adaptlisttimes
		ModifyGraph/W=AdaptationSat mode=3,marker=19
		ModifyGraph/W=AdaptationSat minor(bottom)=1;DelayUpdate
		Label/W=AdaptationSat left "Time In Saturation (s)";DelayUpdate
		Label/W=AdaptationSat bottom "Time (s)"
		ShowInfo/W=AdaptationSat
		//Dark Current Graphs and Calculations...
		display/N=AdaptationId adaptbaseIdlist vs adaptbaselisttimes
		appendtograph/W=AdaptationId adaptIdlist vs adaptlisttimes
		ModifyGraph/W=AdaptationId mode=3,marker=19
		ModifyGraph/W=AdaptationId minor(bottom)=1;DelayUpdate
		Label/W=AdaptationId left "Dark Current (pA)";DelayUpdate
		Label/W=AdaptationId bottom "Time (s)"
		ShowInfo/W=AdaptationId
		//Layout of Relevant Graphs
		NewLayout/N=AdaptationSummary /P=Landscape
		printsettings/W=AdaptationSummary margins={0.25,0.25,0.25,0.25}
		DoWindow/F AdaptationSummary
		AppendLayoutObject graph AdaptationId
		AppendLayoutObject graph AdaptationSat
		execute "Tile"
		SaveProcs(1)
	endif
	
	displaypdiodes(1,numwaves,"")
	
	KillWindow ProgressPanel
	
	//CREATE AVEWSTR AND NDFSTR FOR LATER MACROS
	//...in progress
	
	if(adaptflag)
		adaptcomplete=1
	else
		standardcomplete=1
	endif
End

//****************************************************************
//****************************************************************
//****************************************************************

Function flstrCalc(powFB, powBB, fdur)
	variable powFB, powBB, fdur

	variable intensFB;
	variable intensBB;
	variable flstrength;
	variable i
	
	// Convert pow to W
	powFB*=1e-6
	powBB*=1e-6
	// Convert fdur to seconds
	fdur*=1e-3
	// Conversion factor for converting W to photon density (see MB lab notebook #1, page 43); there is not UDT differential sens at 500!
	intensFB=powFB*4.2355e13
	flstrength=intensFB*fdur
	print "   ",intensFB, "photons/µm2 s unattenuated at 500 nm" 
	// Conversion factor for converting W to intensity (MB notebook #1, p. 67), with UDT differential 500/520 nm sensitivity	
	intensBB=powBB*4.4046e13
	intensBB*=0.9948  //UDT corr
	
	WAVE flstrtrue=root:flstrtrue
	WAVE intenstrue=root:intenstrue
	
	// Make wave for holding true flstrength values
	duplicate/o ndftrue flstrtrue
	duplicate/o bbndftrue intenstrue
	
	WAVE ndftrue=root:ndftrue
	WAVE bbndftrue=root:bbndftrue
	
	for(i=0;i<numpnts(ndftrue);i+=1)
		flstrtrue[i] = flstrength*(10^-ndftrue[i])
		intenstrue[i]=intensBB*(10^-bbndftrue[i])
	endfor
end

//****************************************************************
//****************************************************************
//****************************************************************

Function TempC(pt)
	variable pt
	
	//Physitemp BAT-9 temperature probe calibration data...
	variable offset=0.076372
	variable slope=0.010262
	
	if(pt==0)
		if(exists("NQ_Temp"))
			return round(10*((offset - mean(NQ_Temp))/slope))/10
		else
			return NaN
		endif
	else
		return round(10*((offset - pt)/slope))/10
	endif
end

Function TTemp()
	
	variable offset=0.076372
	variable slope=0.010262
	
		if(exists("NQ_Temp"))
			return round(10*((offset - mean(NQ_Temp))/slope))/10
		else
			return NaN
		endif
end

//****************************************************************
//****************************************************************
//****************************************************************

Function darkcurrent(wavenm, basestart, baseend, satstart, satend)
	wave wavenm
	variable basestart, baseend, satstart, satend
	return mean(wavenm,satstart,satend)-mean(wavenm,basestart,baseend)
End

//****************************************************************
//****************************************************************
//****************************************************************

Function sattime(wavenm, darki, percent)
	wave wavenm
	variable darki, percent
	variable ftime,tsat
	
	NVAR tstep=root:globals:tstep
	
	if(percent>1)
		percent/=100
	endif
	FindLevel/B=5/Q wavenm,(percent*darki)
	ftime=round(1000*V_LevelX)/1000
	//Find where spike falls below 90% of the Dark Current...
	variable i=0
	do
		FindLevels/B=5/Q/R=(V_LevelX+tstep) wavenm,(percent*darki) //find the total number of times where the signal passes 90% of the dark current
		if(V_LevelsFound>0) //If we have not reached the end of the number of levels found, then find the next level...
			FindLevel/B=5/Q/R=(V_LevelX+tstep) wavenm,(percent*darki)
		endif
		//Print V_LevelsFound
		if(V_LevelsFound==0)
			V_LevelsFound=1
		endif
		i+=1
	while(V_LevelsFound!=1 && i<numpnts(wavenm)) //mean($wavenm,V_LevelX,(V_LevelX+0.025))>0.9*darki)
	tsat=round(1000*(V_LevelX))/1000
	return tsat-ftime
end

//****************************************************************
//****************************************************************
//****************************************************************

function flashtype(pdiodewave, flashloc, fbthresh, bbthresh, tstep)
	wave pdiodewave //pdiode wave name
	variable flashloc //point location on the pdiode wave
	variable fbthresh //Front Beam pdiode threshold
	variable bbthresh //Back Beam pdiode threshold
	variable tstep //data acquisition rate (in seconds or Hz)
	
	//convert tstep to Hz from any input
	if(tstep<1)
		tstep=1/tstep
	endif
	
	//set adjustment variable for "findlevels" window...default is 50msec
	variable tstepadj = round(0.025*tstep) //tstepadj = 5 for 200Hz (0.025sec)
	
	//return 1 for front beam short flash
	findlevels/P/Q/R=[flashloc-tstepadj, flashloc+tstepadj] pdiodewave, fbthresh
	if(V_levelsfound==2)
		return 1
	endif
	
	//return 3 for back beam short flash
	findlevels/P/Q/R=[flashloc-tstepadj, flashloc+tstepadj] pdiodewave, bbthresh
	if(V_levelsfound==2)
		return 3
	endif
	
	//return 5 for front beam flicker
	findlevels/P/Q/R=[flashloc-tstepadj, flashloc+round(2*tstep)] pdiodewave, fbthresh
	if(V_levelsfound>2)
		return 5
	endif
	
	//return 6 for back beam flicker
	findlevels/P/Q/R=[flashloc-tstepadj, flashloc+round(2*tstep)] pdiodewave, bbthresh
	if(V_levelsfound>2)
		return 6
	endif
	
	variable V_max=wavemax(pdiodewave,pnt2x(pdiodewave,flashloc-tstepadj),pnt2x(pdiodewave,flashloc+tstepadj))
//	wavestats/q/r=[flashloc-tstepadj, flashloc+tstepadj] pdiodewave
	//return 2 for front beam long flash on
	if(V_max>fbthresh)
		findlevels/EDGE=2/P/Q/R=[flashloc-tstepadj, flashloc+tstepadj] pdiodewave, fbthresh
		if(V_flag==2) //if no DECREASING level crossings are found (2 = no thresholds found)
			return 2 //therefore returns positive 2 on a finding of where the threshold has been positively passed.
		else
			return -2 //return -2 if waveform is descending, indicating the end of the long FB stimulus
		endif
	endif
	
	//return 4 for back beam long flash on
	if(V_max<fbthresh && V_max>bbthresh)
		findlevels/EDGE=2/P/Q/R=[flashloc-tstepadj, flashloc+tstepadj] pdiodewave, bbthresh
		if(V_flag==2) //if no DECREASING level crossings are found
			return 4 //therefore returns positive 2 on a finding of where the threshold has been positively passed.
		else
			return -4 //return -2 if waveform is descending, indicating the end of the long BB stimulus
		endif
	endif
	
	//return 0 if all other conditions fail --> unknown flash type....skip
	return 0
	
end

//****************************************************************
//****************************************************************
//****************************************************************

//Adjusts full length of wave by the given "pointslope" change, or by endpoints if pointslope is 0.
function dccorrect(wavenm, pointslope,endpercent)
	wave wavenm
	variable pointslope
	variable endpercent //default was 0.01
//	variable returnflag=0
	
//	if(pointslope!=0)
//		returnflag=1
//	endif
	
	wave imemchart=root:imemchart
	
	variable start
	variable finish
	variable length
	
	wavestats/q wavenm
	length=V_npnts
	
	if(pointslope==0) //find slope based on end points
		wavestats/q/r=[0,endpercent*(length-1)] wavenm
		start=V_avg
		wavestats/q/r=[length-endpercent*(length-1),length] wavenm
		finish=V_avg
		
		pointslope=(finish-start)/length
		
	endif
	
	variable i=0
	
	for(i=0;i<length;i+=1)
		wavenm[i]-=i*pointslope
	endfor
	
	//re-align baseline
	wavestats/q/r=(0,0.5) wavenm
	wavenm-=V_avg
	if(waveexists(imemchart))
		if(wavenm==imemchart)
			wavestats/q imemchart
			imemchart-=(V_max+V_min)/2
		endif
	endif
	
	setnote(wavenm,"Slope Adjustment",num2str(pointslope))
	
//	if(returnflag)
		return pointslope
//	endif
	
end

function getpointslope(wavenm)
	wave wavenm
	variable csrA=pcsr(A)
	variable csrB=pcsr(B)
	
end

//****************************************************************
//****************************************************************
//****************************************************************

Function IntensityResponse(hide)
	variable hide
	Variable i=0; Variable j=0; Variable ndf=0; Variable l=0
	Variable pntr
	Silent 1
	Pauseupdate
	print "--Generating Intensity Response Table and Graph..."
	duplicate/o ndflist resp int
	resp=0; int=0
	WAVE flstrtrue=root:flstrtrue
	do
		string wname="avef"+num2istr((8.1-i*0.2999)*10)
		if(WaveExists($wname)==1)
			wavestats/Q $wname
			resp[j]=V_max
			// find the point number of the ndf in ndflist
			FindLevel/Q ndflist, (81-i*3)
			pntr=V_LevelX
			int[j]=flstrtrue[pntr]
			j+=1
		endif
		i+=1
	while(i<28)
	do
		if(resp[l]==0)
			deletepoints l,1000, resp
			deletepoints l,1000, int
			break
		EndIf
		l+=1
	while(l<28)
	DoWindow/K intensityresponse //Check for intensity response table
	DoWindow/K intensityresponse0
	Edit/N=intensityresponse/HIDE=(hide) resp int
	DoWindow/K intensresp
	display/N=intensresp/M/W=(18,0,30,10)/HIDE=(hide) resp vs int as "intensresp"
	ModifyGraph/W=intensresp log(bottom)=1
	ModifyGraph/W=intensresp mode(resp)=3,marker(resp)=19
	Label/W=intensresp bottom " Flash Strength (photons/\\F'Symbol'm\\F'Geneva'm\\S2\\M)"
	Label/W=intensresp left "Resp Amplitude"
	// Display "normal" mouse Int-Resp relation
	make/o/n=5000 fitynormal, fitxnormal
	fitxnormal = 0.1 + alog(0.0009*x)
	make/o/n=2 coef
	coef = {1, ln(2)/70}
	fitynormal = satexp(coef, fitxnormal)
	AppendtoGraph/W=intensresp fitynormal vs fitxnormal
	ModifyGraph/W=intensresp lstyle(fitynormal)=2
	ModifyGraph/W=intensresp rgb(fitynormal)=(3,52428,1)
	Tag/C/N=WTtrace/O=6/AO=1/F=0/G=(3,52428,1)/B=1/A=MB/L=0/TL=0/X=1.00/Y=1.00 fitynormal, 200,"WT"
	ShowInfo/W=intensresp
End

//****************************************************************
//****************************************************************
//****************************************************************

Macro TimeToPeak(ndfin, filter)
	variable ndfin=root:globals:maxndfused //passed from linearity check, so no default value will be different from the maximum actual NDF used in the experiment.
	variable filter=30
	Prompt ndfin, "NDF list used (Sets default NDF value for upcoming procedures):"
	Prompt filter, "Cutoff frequency of 8-pole Bessel filter (Hz):"
	variable/g root:globals:besselfilter=filter
	Silent 1
	Pauseupdate
	variable/g root:globals:maxndfused
	root:globals:maxndfused=ndfin //change maxndfused to actual ndf used in the analysis...
	variable/g root:globals:TTPcomplete=0
	//Prompt imemname, "Wave of flash response:"
	//Prompt pdiodename, "Wave of mean pdiode trace:"
	string imemname = "avef"+num2str(ndfin)
	variable halfmax
	variable pdiodestart
	variable pdiodeend
	
	if(filter<0)
		avepdiode(0,0,"all")
		string pdiodenm = "pdiodeavg" //from "avepdiode" function
	else
		string pdiodenm = "avepf"+num2str(ndfin) //from "aveandvar" function...
	endif
	
	string wlist="f"+num2str(ndfin)
	AvePdiode(0,0,wlist) //asdf
	variable tflash = 0
	variable peak=0
	variable timetopeak=0
	//Correction for filter delay (8-pole Bessel falls as 0.51/f-3; Axon Guide, p. 143)
	variable filterdelay=0.51/filter
//	wavestats/Q $(pdiodename)
//	tflash=V_maxloc+filterdelay

	//calculate midpoint of pdiode based on FWHM of pdiode average
	halfmax=0.5*wavemax($pdiodenm,floor(0.95*root:globals:baselinelength),ceil(1.05*root:globals:baselinelength))
	FindLevels/P/Q $pdiodenm, halfmax //0.95 to 1.05 covers the location of the pulse...
	if(V_LevelsFound==2)
		FindLevel/EDGE=1/Q $pdiodenm, halfmax
		pdiodestart=V_LevelX
		FindLevel/EDGE=2/Q $pdiodenm, halfmax
		pdiodeend=V_LevelX
	else
		Print "ERROR: Pdiode center not found. Using manual pdiode shift."
		pdiodestart=root:globals:pdiodeshift
		pdiodeend=root:globals:pdiodeshift
	endif
	
	print "     Midpoint of flash (msec -- including "+num2str(root:globals:baselinelength)+"sec baseline): "+num2str((pdiodestart+pdiodeend)*500)
	print "     Filter Delay (msec): "+num2str(filterdelay*1000)
	
	tflash=(pdiodestart+pdiodeend)/2+filterdelay

	wavestats/Q $(imemname)
	peak=V_maxloc
	timetopeak=peak-tflash
	print "     Time to peak (msec):", timetopeak*1000 
	Values[2]=num2str(timetopeak*1000)
	root:globals:TTPcomplete=1
	Values[0]="f"+num2str(ndfin)+": "+num2str(V_max/str2num(Values[1])*100)+"% of Id"
	if(V_max/str2num(Values[1])*100>20)
		print "     WARNING: Using An Intensity That Is",V_max/str2num(Values[1])*100,"% of Id!!!"
	endif
	variable threshcheck=wavesabovethresh(0.2*str2num(Values[1]),0.1,ndfin=ndfin)
	Print num2str(threshcheck/numpnts($("F"+num2str(ndfin)))*100)+"% of F"+num2str(ndfin)+" waves are above 20% of Id!"
EndMacro

Function WavesAboveThresh(thresh,tolerance,[ndfin])
	variable thresh
	variable tolerance //percentage allowed above the threshold
	variable ndfin
	if(numtype(ndfin)==2)
		NVAR maxndfused=root:globals:maxndfused
		ndfin=maxndfused
	else
		Prompt ndfin, "NDF list to use (number only)"
	endif
	WAVE wlist = root:$("f"+num2str(ndfin))
	variable i
	NVAR baselinelength = root:globals:baselinelength
	variable base
	variable count
	WAVE/T Values=Values
	NVAR filter = root:globals:besselfilter
	NVAR pdiodestart = root:globals:pdiodestart
	NVAR pdiodeend = root:globals:pdiodeend
	variable TTP = str2num(Values[2])/1000+0.51*filter/1000+(pdiodestart+pdiodeend)/2
	for (i=0;i<numpnts(wlist);i+=1)
		WAVE theWave=$("imem"+num2str(wlist[i]))
		wavestats/q/r=(0,baselinelength) theWave
		base = v_avg
		wavestats/q/r=(TTP-TTP/20,TTP+TTP/20) theWave
		if(v_avg-base>thresh)
			print "Trace number "+num2str(wlist[i])+" is above the "+num2str(thresh)+" threshold value"
			count+=1
		endif
	endfor
	return count
end

//****************************************************************
//****************************************************************
//****************************************************************

Macro MeasureDarkCurrent(wavenm,satend,satstart,baseend,basestart)
	string wavenm
	Variable basestart=0.5*root:globals:baselinelength, baseend=root:globals:baselinelength, satstart=.1+root:globals:baselinelength, satend
	Prompt wavenm, "Name of sweep:"
	Prompt satend, "End saturating response at:"
	Prompt satstart, "Start saturating response at:"
	Prompt baseend, "End baseline at:"
	Prompt basestart, "Start baseline at:"
	variable/g root:globals:Idcomplete=0
	variable ndfin=root:globals:maxndfused
	Silent 1
	Pauseupdate
	if(waveexists($wavenm))
		if(satend==0 | satend<=satstart)
			Abort "Enter a value betwen the start saturating response and 5 for the end saturating response"
		endif
		if(baseend<=basestart | baseend>1)
			Abort "Baseline value either above 1 second or endpoint is higher than startpoint"
		endif
		Values[1]=num2str(darkcurrent($wavenm,basestart,baseend,satstart,satend))
		print "     Dark Current (pA): "+Values[1]
		CheckLinearity()
		root:globals:Idcomplete=1
		dowindow/F index_list //$("f"+num2str(ndfin)+"_list")
		ModifyGraph offset(zero)={0,str2num(Values[1])}
		Tag/C/N=Idtag/F=0/X=4.91/Y=5.00/L=0 zero, 3.5,"Calculated Dark Current"
	else
		print "     ERROR: The named wave does not exist."
	endif
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro MeanSquaredFit(ndfin)
	Variable ndfin=root:globals:maxndfused
	Variable/g root:globals:maxndfused
	Variable/g root:globals:SPRcomplete=0
	Variable varmax
	Variable avemax
	variable/g root:globals:scalingf
	variable/g root:globals:SPRulimit
	variable ticknum
	variable i=0
	variable j=0
	variable/g root:globals:changesprflg=0
	variable/g root:globals:changesprbtn=0 //flag for toggling button changes on the Mean Square Panel
	variable/g root:globals:sweeplength
	variable/g root:globals:baselinelength
	variable xmin=root:globals:baselinelength-0.05
	variable xmax=2+xmin
	Silent 1
	Pauseupdate
	
	duplicate/o/r=(xmin,xmax) $("avef"+num2str(ndfin)) $("avef"+num2str(ndfin)+"2") 
	duplicate/o/r=(xmin,xmax) $("varf"+num2str(ndfin)) $("varf"+num2str(ndfin)+"2")
	variable offset = mean($("varf"+num2str(ndfin)),xmin,1) //Offset is mean of variance wave baseline before flash...
	$("varf"+num2str(ndfin)+"2")-=offset
	$("avef"+num2str(ndfin)+"2") *= $("avef"+num2str(ndfin)+"2")  //square of average wave
//	wavestats/q/r=(0.95,2) $("varf"+num2str(ndfin)+"2")
		varmax=wavemax($("varf"+num2str(ndfin)+"2"),xmin,xmax) //V_max
//	wavestats/q/r=(0.95,2) $("avef"+num2str(ndfin)+"2")
		avemax=wavemax($("avef"+num2str(ndfin)+"2"),xmin,xmax) //V_max
	root:globals:scalingf=(varmax/avemax)
	$("avef"+num2str(ndfin)+"2")*=(root:globals:scalingf)
	DoWindow/K MeanSquaredFit //check if meansquaredfit window exists
	DoWindow/K MeanSquaredFit0
	DoWindow/K MeanSquaredFitPanel //check if meansquaredfit panel window exists
	DoWindow/K MeanSquaredFitPanel0
	root:globals:SPRulimit=root:globals:scalingf*2

	NewPanel/N=MeanSquaredFitPanel /W=(0,0,1240,641)
		ModifyPanel/W=MeanSquaredFitPanel fixedSize=1, frameStyle=0, noEdit=1
		Slider scaleslider, win=MeanSquaredFitPanel, variable=scalingf, value=root:globals:scalingf, vert=0, live=0, size={775,30},pos={5,570}, proc=scaleslide, limits={0.0001,root:globals:SPRulimit,0}, ticks=20, fsize=9, help={""}, side=1
//		TitleBox sprtitle, win=MeanSquaredFitPanel,size={50,20},pos={205,58},title="Slider Upper Limit:",frame=0
		Button scaleup, win=MeanSquaredFitPanel,size={25,20},pos={785,563},proc=scaleup,title="»",help={"Increase range"}
		Button scaledn, win=MeanSquaredFitPanel,size={25,20},pos={785,585},proc=scaledn,title="«",help={"Decrease range"}
		Button newvals, win=MeanSquaredFitPanel,size={56,20},pos={345,614},disable=2,proc=newvals,title="Output",help={"Calculate and load newly fitted values."}
		Button nospr, win=MeanSquaredFitPanel,size={56,20},pos={415,614},disable=0,proc=nospr,title="No SPR",help={"Removes calculated SPR values"}
		
	duplicate/o/R=(xmin,xmax) $("avepf"+num2str(ndfin)) Flash
	Flash=round(100*Flash)/100
//	meansquarepdiode/=meansquarepdiode //square it off by normalizing after setting "off" values to 0
	
	display/N=MeanSquaredFit/HOST=MeanSquaredFitPanel /W=(10,10,820,560)/L=L1 Flash as "MeanSquaredFit"
		appendtograph/W=MeanSquaredFitPanel#MeanSquaredFit $("avef"+num2str(ndfin)+"2") $("varf"+num2str(ndfin)+"2")
		SetAxis/W=MeanSquaredFitPanel#MeanSquaredFit L1 0,2*wavemax(Flash)
		ModifyGraph/W=MeanSquaredFitPanel#MeanSquaredFit freePos(L1)=-500,tick(L1)=0,mirror(L1)=3,freePos(L1)=500
		ModifyGraph/W=MeanSquaredFitPanel#MeanSquaredFit axRGB(L1)=(32769,65535,32768),tlblRGB(L1)=(32769,65535,32768),alblRGB(L1)=(32769,65535,32768)
		ModifyGraph/W=MeanSquaredFitPanel#MeanSquaredFit rgb($("varf"+num2str(ndfin)+"2"))=(0,0,0)
		ModifyGraph/W=MeanSquaredFitPanel#MeanSquaredFit rgb(Flash)=(0,65000,6500), lstyle(Flash)=0, lsize(Flash)=0, hbFill(Flash)=5, mode(Flash)=7
		ModifyGraph/W=MeanSquaredFitPanel#MeanSquaredFit manTick=0
		ModifyGraph/W=MeanSquaredFitPanel#MeanSquaredFit framestyle=2
		SetAxis/W=MeanSquaredFitPanel#MeanSquaredFit /A=2 left
		SetAxis/W=MeanSquaredFitPanel#MeanSquaredFit bottom xmin,(root:globals:baselinelength+1.5*str2num(Values[2])/1000) //was 0.95, 1.2
	
	DisplayListOfWaves("f"+num2str(ndfin), "f"+num2str(ndfin)+"_list", 10, 10,"MeanSquaredFitPanel",0)
	SetAxis/W=$("MeanSquaredFitPanel#f"+num2str(ndfin)+"_list") bottom xmin, root:globals:baselinelength+2*str2num(Values[2])/1000
	
	appendtograph/W=$("MeanSquaredFitPanel#f"+num2str(ndfin)+"_list") Flash// $("avepf"+num2str(ndfin))
		ModifyGraph/W=$("MeanSquaredFitPanel#f"+num2str(ndfin)+"_list") rgb(Flash)=(0,65535,0), lstyle(Flash)=2, lsize(Flash)=1, hbFill(Flash)=0, mode(Flash)=0
		MoveSubWindow/W=$("MeanSquaredFitPanel#f"+num2str(ndfin)+"_list") fnum=(830,10,1230,260)
		
	Displaypdiodes($("f"+num2str(ndfin))[numpnts($("f"+num2str(ndfin)))],$("f"+num2str(ndfin))[0],"MeanSquaredFitPanel")
		MoveSubWindow/W=$("MeanSquaredFitPanel#pdiodes") fnum=(830,270,1230,530)
//	if(root:globals:scalingf*2>root:globals:SPRulimit)
//		root:globals:SPRulimit=3*root:globals:scalingf
//	endif
	ticknum=root:globals:SPRulimit*10
	if(ticknum>100)
		ticknum=100
	endif
	print "     Calculated Scaling Factor:",num2str(root:globals:scalingf)
	print "     Calculated Photoisomerizations per Flash:",(avemax/varmax)
	wavestats/Q $("avef"+num2str(ndfin))
	print "     Calculated SPR (pA):",num2str((root:globals:scalingf)*V_max)
	Values[3]=num2str((root:globals:scalingf)*V_max)
	//Collecting Area
	do
		if(ndfin==ndflist[i])
			print "     Calculated Rod Collecting Area 1/(flstrtrue["+num2str(i)+"]*(scaling factor)):", (1/root:globals:scalingf)/flstrtrue[i]
			Values[9]=num2str((1/root:globals:scalingf)/flstrtrue[i])
		endif
		i+=1
	while(i<=27)
	root:globals:SPRcomplete=1
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

//Slider for SPR
Function scaleslide(scalename,value,event) : ButtonControl
	string scalename
	variable event
	variable value
	NVAR scalingf=root:globals:scalingf
	NVAR maxndfused=root:globals:maxndfused
	NVAR changesprflg=root:globals:changesprflg
	
	NVAR changesprbtn=root:globals:changesprbtn
	
	wave wavenm=root:$("avef"+num2str(maxndfused)+"2")
	Silent 1
	pauseupdate
	if(scalingf>0)
		wavenm/=scalingf
		scalingf=value
		wavenm*=scalingf
	endif
	resumeupdate
	if(changesprbtn==0)
		Button newvals,fstyle=1,disable=0,fColor=(65535,0,0)
		Button nospr,fstyle=0,disable=0,fColor=(65535,65535,0)
		changesprbtn=1
	endif
	
	WAVE pdiode=root:Flash

//	GetAxis/W=MeanSquaredFitPanel#MeanSquaredFit/Q left
//	variable wavescaling=(V_max/2)/Wavemax(pdiode)
//	pdiode*=wavescaling
	
	changesprflg=1
End

//****************************************************************
//****************************************************************
//****************************************************************

//Button Controls for SPR
Macro scaleup(buttonname) : ButtonControl
	string buttonname
	variable/g root:globals:SPRulimit
	root:globals:SPRulimit*=1.1
	Slider scaleslider limits={0.0001,root:globals:SPRulimit,0}
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro scaledn(buttonname) : ButtonControl
	string buttonname
	variable/g root:globals:SPRulimit
	root:globals:SPRulimit/=1.1
	Slider scaleslider limits={0.0001,root:globals:SPRulimit,0}
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Function newvals(buttonname) : ButtonControl
	string buttonname
	variable/g root:globals:scalingf
	variable/g root:globals:maxndfused
	variable/g root:globals:changesprflg
	variable/g root:globals:changesprbtn

	NVAR scalingf=root:globals:scalingf
	NVAR maxndfused=root:globals:maxndfused
	NVAR changesprflg=root:globals:changesprflg
	NVAR changesprbtn=root:globals:changesprbtn
	
	WAVE/T Values=root:Values
	WAVE ndflist=root:ndflist
	WAVE flstrtrue=root:flstrtrue

	variable i=0
	variable V_max
	Silent 1
	Pauseupdate
	if(changesprflg==1)
		print "     New Scaling Factor:", scalingf
		print "     New Photoisomerizations per Flash:",(1/scalingf)
		//wavestats/Q $("avef"+num2str(maxndfused))
		V_max=wavemax($("avef"+num2str(maxndfused)))
		print "     New SPR:",num2str((scalingf)*V_max)
		Values[3]=num2str((scalingf)*V_max)
		//Collecting Area
		do
			if(maxndfused==ndflist[i])
				print "     New Rod Collecting Area (1/scaling factor)/flstrtrue["+num2str(i)+"]:", (1/scalingf)/flstrtrue[i]
				Values[9]=num2str((1/scalingf)/flstrtrue[i])
			endif
			i+=1
		while(i<=27)
		Button newvals,fstyle=0,fColor=(0,0,0),disable=2
		Button nospr,fstyle=0,fColor=(0,0,0)
		changesprflg=0
	Endif
//	MakeSPRwave(maxndfused, 1/scalingf, 0, 0)
	changesprbtn=0
End

//****************************************************************
//****************************************************************
//****************************************************************

Macro nospr(buttonname) : ButtonControl
	string buttonname
	Button newvals,fstyle=0,fColor=(0,0,0),disable=2
	Button nospr,fstyle=0,fColor=(0,0,0),disable=2
	Values[3]=""
	Values[9]=""
	print "--NO SPR: All previously calculated SPR-based measurements have been removed..."
	root:globals:changesprbtn=0
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Function MakeSPRwave(ndf, rstar, cellnum, export)
	variable ndf //NDF number of average wave to convert to SPR trace
	variable rstar //photoisomerizations per flash...
	variable cellnum //reording cell number
	variable export //flag for exporting...
	
	string savepath=""
	string savename=""
	string datestr=""
	
	string ndwavenm="avef"+num2str(ndf)
	string newnm="SPR"+num2str(ndf)
	WAVE ndwave=root:$ndwavenm
	
	if(waveexists(ndwave))
		if(!waveexists($newnm))
			duplicate ndwave $newnm
			WAVE SPRwave=root:$newnm
			SPRwave/=rstar
		endif
		if(export)
			WAVE/T Measurements=root:Measurements
			datestr=Measurements[0]//savename[0,9]
			GetFileFolderInfo/Q/D "???"
			if(V_Flag!=0)
				Abort "Select an existing folder"
			endif
			NewPath/O savepath S_Path //Defining savepath from selected folder pathname
			 
			savename="SPR"+datestr[0,3]+datestr[5,6]+datestr[8,9]+"c"+num2str(cellnum)+"f"+num2str(ndf)
			
			rename $newnm, $savename
			Save/O/P=savepath $savename
			rename $savename, $newnm
		endif
	endif
end

Function ExportPepp(cellnum, col)
	variable cellnum //reording cell number
	variable col //flag for exporting...
	
	string savepath=""
	string Xsavename=""
	string Ysavename=""
	string datestr=""
	
	string Ywavenm="TimeSat"
	string Xwavenm="flstrtrue1"
	
	WAVE TimeSat=root:$Ywavenm
	WAVE lnflstr=root:$Xwavenm
	
	if(waveexists(TimeSat))
			WAVE/T Measurements=root:Measurements
			datestr=Measurements[0]//savename[0,9]
			GetFileFolderInfo/Q/D "???"
			if(V_Flag!=0)
				Abort "Select an existing folder"
			endif
			NewPath/O savepath S_Path //Defining savepath from selected folder pathname
			 
			Ysavename="TimeSat"+datestr[0,3]+datestr[5,6]+datestr[8,9]+"c"+num2str(cellnum)
			Xsavename="Rstar"+datestr[0,3]+datestr[5,6]+datestr[8,9]+"c"+num2str(cellnum)
			
			rename $Ywavenm, $Ysavename
			rename $Xwavenm, $Xsavename
			WAVE Xwave = root:$Xsavename
			Xwave*=col
			Xwave=ln(Xwave)
			Save/O/P=savepath $Ysavename
			Save/O/P=savepath $Xsavename
			Xwave=e^(Xwave)
			Xwave/=col
			rename $Ysavename, $Ywavenm
			rename $Xsavename, $Xwavenm
	endif
end

//****************************************************************
//****************************************************************
//****************************************************************

Function AveVarAll()
	Silent 1
	Pauseupdate
	variable/g root:globals:avevarcomplete=0
	NVAR avevarcomplete=root:globals:avevarcomplete
	variable/g root:globals:dccorrectval=0
	NVAR dccorrectval=root:globals:dccorrectval
	NVAR tstep=root:globals:tstep
	NVAR numwaves=root:globals:numwaves
	
	Make/o/n=0 pdiodelist, pdiodelist2
	WAVE pdiodelist=root:pdiodelist
	WAVE pdiodelist2=root:pdiodelist2
	make/o/t/n=0 ndfstr
	variable i=0
	
	string dcstatus
	Prompt dcstatus, "Apply DC Correction to this analysis?", popup, "No;Yes"
	doPrompt "DC Correction" dcstatus
	variable/g dcflag
	if(stringmatch(dcstatus,"Yes"))
		dcflag=1
	else
		dcflag=0
	endif
	
	//set DC to 0
	dccorrectval=0
	
	// 1. create complist wave (based on "numwaves")
	make/o/n=(numwaves) complist
	variable compareindex //for iterating through countlist
	
	variable j=0
	//populate countlist
	for(j=0;j<numwaves;j+=1)
		complist[j]=j+1
	endfor
	
	//run average commands...
	for(j=81;j>=0;j-=3)
		duplicate/o complist countlist //duplicate complist ("Compare" list) to create counting wave for "for" command.
		if(waveexists($("f"+num2str(j))))
			for(compareindex=0;compareindex<=numpnts(countlist);compareindex+=1)
				findvalue/V=(countlist[compareindex]) $("f"+num2str(j))
				if(V_value>-1)
					complist[compareindex]=nan
				endif
			endfor
			print "     aveandvar(\"f"+num2str(j)+"\")"
			aveandvar("f"+num2str(j))
			if(dcflag)
				if(!dccorrectval)
					//grab DC adjustment slope for smallest response (assumes return to baseline before end of sweep)
					dccorrectval+=dccorrect($("avef"+num2str(j)),0,0.001)
				else
					//apply DC adjustment slope to remaining responses
					dccorrect($("avef"+num2str(j)),dccorrectval,0.001)	
				endif
			endif
//			WAVE fnum=root:$("f"+num2str(j))
			pdiodelist2=pdiodelist
			concatenate/o {pdiodelist2,$("f"+num2str(j))}, pdiodelist
			
			//add to list of avef waves (ndfs used)
			insertpoints i,1,ndfstr
			if(j==18)
				//set variable to automatically set "avelist" to F18...
				variable dfault=i
			endif

			ndfstr[i]="f"+num2str(j)
			i+=1			
		endif
	endfor

	//Print out removed wave numbers (from "complist" routines above)
	for(compareindex=0;compareindex<=numpnts(countlist);compareindex+=1)
		if(complist[compareindex]>=0)
			Print "     Wave "+num2str(complist[compareindex])+ " not included in analysis..."
		endif
	endfor
	
	family("Family")
	if(dcflag)
		TextBox/W=Family0/C/N=warnings/F=0/X=-10.00/Y=-10.00/Z=1 "\JR* DC *" // adjusted by "+num2str(-1*dccorrectval/tstep)+"pA/s *"
		Print "     DC Offset of "+num2str(-1*dccorrectval/tstep)+"pA/s applied to all \"avef\" traces"
	endif
	
	//kill all *_list waves
	i=0
	string wlist=winlist("*_list",";","WIN:1")
	string wname
	for(i=0;i<itemsinlist(wlist,";");i+=1)
		wname=stringfromlist(i,wlist,";")
		dowindow/k $wname
	endfor
	
	newpanel/n=aveflist/w=(400,200,590,410)
		ListBox avelist listwave=ndfstr,pos={5,5},size={100,200},win=aveflist,mode=2,row=dfault,selrow=dfault
		Button avevarok proc=avevarok,pos={110,5},size={75,25},win=aveflist,title="NDF list"
	pauseforuser aveflist
	killwaves ndfstr, pdiodelist2
	avevarcomplete=1
End

Function avevarok(buttonname) : ButtonControl
	string buttonname
	controlinfo/w=aveflist avelist
	
	WAVE/T ndf=root:$s_value
	WAVE/T Values=root:Values
	Execute "displaylistofwaves(\""+ndf[v_value]+"\",\"index_list\",450,0,\"\",0)"
	
	dowindow/k aveflist
end

//****************************************************************
//****************************************************************
//****************************************************************

Function CheckLinearity() //checks the linearity of the last four NDFs used...
	Silent 1
	
	WAVE/T Values=root:Values
	
	variable/g root:globals:maxndfused
	NVAR maxndfused=root:globals:maxndfused
	//wave values=root:values
	variable i=0
	variable j=0
	variable k=0
	variable V_max
	do //set up value of "j" so avef values are printed in ascending order instead of decending order in the next do-while loop...
		if(exists("avef"+num2str(maxndfused-j))==1)
			i+=1
		endif
		j+=3
		k+=1 //check to ensure loop doesnt continue forever...
	while(i<4 || k>30)
	i=0
	j-=3 //undo last addition of "3" to "j" in previous do-while loop...
	k=0
	do
		if(exists("avef"+num2str(maxndfused-j))==1)
			if(str2num(Values[1])>0)
				V_max=wavemax($("avef"+num2str(maxndfused-j)))
//				wavestats/Q $("avef"+num2str(maxndfused-j))
				print "     avef",(maxndfused-j),":",(V_max/str2num(Values[1]))*100,"% of Id ("+num2str(numpnts($"f"+num2str(maxndfused-j)))+" waves)"
				i+=1
			endif
		endif
		j-=3
		k+=1 //check to ensure loop doesnt continue forever...
	while(i<4 || k>30)
	if(V_max/str2num(Values[1])*100>20)
		print "     WARNING: No Intensities Are In The Linear Range!!!"
	endif
End

//****************************************************************
//****************************************************************
//****************************************************************

Function Family(familyname)
	string familyname
	Silent 1
	Pauseupdate
	variable/g root:globals:maxndfused=0 //defining for linearity check macro
	
	NVAR maxndfused=root:globals:maxndfused
	
	variable ndf
	variable j=0
	//Kill Existing Family Windows
	DoWindow/K $(familyname+"0")
	display/N=$familyname as familyname
	for(j=0;j<=81;j+=3)
		if(exists("avef"+num2str(j))==1)
			string flash="avef"+num2str(j)
			wave wv=$flash
			appendtograph wv
			if(j>maxndfused)
				maxndfused=j
			endif
		endif
	endfor
End

//****************************************************************
//****************************************************************
//****************************************************************

Macro ImportNQ()
	Silent 1
	GetFileFolderInfo/Q
	LoadData/j="NQ_Imem;NQ_PDIODE;NQ_BBNDF;NQ_FBNDF" S_Path
	Measurements[0]=ParseFilePath(3, S_Path, ":", 0, 0)	// Appends File Name to Table 1	
	//TODO: create new panel with a text input box and pause for user on that panel...conditions for evoking: Measurements[0] longer than 30 characters...
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Macro SetupOther(ndfin,smoothing,peppStart,peppEnd,peppSatLim,peppPercent,dcstatus) //master script for displaying all relevant graphs after meansquaredfit calculation is performed
	Variable ndfin=root:globals:maxndfused
	variable peppStart=root:globals:baselinelength+0.07
	variable peppEnd=root:globals:baselinelength+0.17
	variable peppPercent=90
	variable peppSatLim=100
	string smoothing="no"
	string dcstatus="Yes"
	prompt ndfin "Enter ndf filter value:"
	prompt peppStart "Start of Saturation for Pepp Tau:"
	prompt peppEnd "End of Saturation for Pepp Tau:"
	prompt peppSatLim "Min sat time for Pepp Tau (ms):"
	prompt peppPercent "Percent of Id for Pepp Tau:"
	prompt smoothing, "Smoothing?", popup,"no;yes"
	prompt dcstatus, "Apply special DC slope to avef"+num2str(ndfin)+"?", popup, "No;Yes"
	
	variable hide=1
	
	if(stringmatch(dcstatus,"Yes"))
		root:globals:dccorrectval+=dccorrect($("avef"+num2str(ndfin)),0,0.001)
		variable/g dcflag=1
	endif
	
	Silent 1
//	Pauseupdate
	NewPanel/FLT=1 /N=ProgressPanel /W=(300,200,800,300)
		TitleBox valtitle,title="Setting Up Other Graphs...",win=ProgressPanel,fsize=14,frame=0,pos={50,20},size={100,25}
		ValDisplay valdisp0,pos={50,50},size={400,25}
		ValDisplay valdisp0,limits={0,6,0},barmisc={0,0}
		ValDisplay valdisp0,value=_NUM:0
		ValDisplay valdisp0,mode=3
		ValDisplay valdisp0,highColor=(0,40000,0)
		
	DoUpdate /W=ProgressPanel /E=1
//	ProgressWindow open=progress,win=(500,500)
	variable/g root:globals:maxndfused
	variable/g root:globals:othercomplete=0
//	ProgressWindow frac=0.2
	MakeTaurec(ndfin,hide)
		ValDisplay valdisp0,value=_NUM:1,win=ProgressPanel
		DoUpdate /W=ProgressPanel
//	ProgressWindow frac=0.4
	MakeIntTime(ndfin,hide)
		ValDisplay valdisp0,value=_NUM:2,win=ProgressPanel
		DoUpdate /W=ProgressPanel
//	ProgressWindow frac=0.6
	IntensityResponse(hide)
		ValDisplay valdisp0,value=_NUM:3,win=ProgressPanel
		DoUpdate /W=ProgressPanel
//	ProgressWindow frac=0.8
	PeppTau(smoothing,peppPercent,peppStart,peppEnd,peppSatLim,hide)
		ValDisplay valdisp0,value=_NUM:4,win=ProgressPanel
		DoUpdate /W=ProgressPanel

//	if(char2num(smoothing[0])==char2num("n"))
//		PeppTau("no",90,1.1,1.2)
//	endif
//	if(char2num(smoothing[0])==char2num("y"))
//		PeppTau("yes",90,1.1,1.2)
//	endif

//	ampall(str2num(Values[1]),str2num(Values[9]),24)
//	ProgressWindow frac=1
//	ProgressWindow close
	SummaryLayout(hide)
		ValDisplay valdisp0,value=_NUM:5,win=ProgressPanel
		DoUpdate /W=ProgressPanel
	DoWindow/F Summary
	SaveProcs(hide)
		ValDisplay valdisp0,value=_NUM:6,win=ProgressPanel
		DoUpdate /W=ProgressPanel
	KillWindow ProgressPanel
	root:globals:othercomplete=1
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Function MakeTaurec(ndfin,hide) //graphs taurec chart
	Variable ndfin
	Variable hide
	Variable/g dcflag
	NVAR dccorrectval = root:globals:dccorrectval
	NVAR tstep = root:globals:tstep
	Silent 1
	Pauseupdate
	DoWindow/K TauRec
	DoWindow/K TauRec0
	Display/N=TauRec/HIDE=(hide) as "TauRec"
	appendtograph $("avef"+num2str(ndfin))
	Showinfo
	if(dcflag)
		TextBox/W=TauRec/C/N=warnings/F=0/X=-10.00/Y=-10.00/Z=1/B=1 "\JR* Slope adjusted by "+num2str(-1*dccorrectval/tstep)+"pA/s *"
		Print "     DC Offset of "+num2str(-1*dccorrectval/tstep)+"pA/s applied to \"avef"+num2str(ndfin)+"\""
	endif
End

//****************************************************************
//****************************************************************
//****************************************************************

Macro MakeIntTime(ndfin,hide) //graphs integration time chart
	Variable ndfin
	Variable hide
	Variable intmax
	Variable V_max
	Variable/g dcflag
	Silent 1
	Pauseupdate
	string avefnm="avef"+num2str(ndfin)
	string intnm="int"+num2str(ndfin)
	duplicate/O $avefnm $intnm
	integrate $intnm
	DoWindow/K IntTime
	DoWindow/K IntTime0
	Display/N=IntTime/HIDE=(hide) as "IntTime"
	appendtograph/W=IntTime $intnm
	appendtograph/W=IntTime zero
	ModifyGraph/W=IntTime quickdrag(zero)=1
	//Auto-calculation of Int Time
//	wavestats/q $intnm
	intmax=wavemax($intnm,1,2)//v_max //Assume max is between 1 and 2 seconds.
//	wavestats/q $avefnm
	V_max=wavemax($avefnm)
	print "     Calculated Integration Time (msec):", (intmax/v_max)*1000
	Values[5]=num2str((intmax/v_max)*1000)
	ModifyGraph/W=IntTime rgb(zero)=(0,0,0)
	ModifyGraph/W=IntTime offset(zero)={0,intmax}
	if(dcflag)
		TextBox/W=IntTime/C/N=warnings/F=0/X=-10.00/Y=-10.00/Z=1/B=1 "\JR* DC *"
	endif
EndMacro

//****************************************************************
//****************************************************************
//****************************************************************

Function PeppTau(smoothstring, percent, satstart, satend, satlimit, hide) //calculates and graphs satruation time and dark current for pepptau traces.
	//Smoothstring is either "n" or "y" for smoothing or no smoothing.
	//Percent is the percent of dark current to measure
	string smoothstring
	variable percent
	variable satstart
	variable satend
	variable satlimit //minimum limit for accepting a saturation response
	variable hide
	
	NVAR pdiodeshift=root:globals:pdiodeshift
	
	Silent 1
	Pauseupdate
	if(percent>1)
		percent/=100 //convert to normalized value if percentage is given in actual values
	endif
	variable smoothing
	if(char2num(smoothstring[0])==char2num("n"))
		smoothing=0
	elseif(char2num(smoothstring[0])==char2num("y"))
		smoothing=1
	endif
	variable j
	variable i
	variable k=0
	variable tsat
	variable darki
	variable basestart=0.5
	variable baseend=1.0
	variable base, sat
	string wavenm=""
	string pdiodenm=""
	variable ftime=1.025
	variable pdiodestart
	variable pdiodeend
	variable halfmax
	variable/g root:globals:tstep //defined in standard setup...
	wave flstrtrue
	variable a
	variable boxsize=5 //set findlevel(s) moving box average to 5 by default (for unsmoothed waves)
	variable wavelngth
	variable saterror=0
	
	NVAR filter=root:globals:besselfilter
	print "--Generating PeppTau Table and Graph..."
	print "     Measuring at "+num2str(100*percent)+"% of the Dark Current"
	DoWindow/K pepptautable
	DoWindow/K pepptautable0
	DoWindow/K pepptau
	DoWindow/K pepptau0
	Make/O/N=9/D ndfilter,Id,TimeSat,flstrtrue1,lnflstr
	Edit/N=pepptautable/HIDE=(hide) ndfilter,Id,TimeSat,flstrtrue1,lnflstr  as "pepptautable"
	ndfilter=0
	
	avepdiode(0,0,"all") //run pdiode averaging function on all used pdiodes -- generates "pdiodeavg" wave
	
	WAVE ndflist=root:ndflist
	
	for(j=0;j<9;j+=1)
		saterror=0 //flag for error in saturation calculation (for appending tags)
		i=0
		tsat=0
		ndfilter[j]=k
		k+=3
		flstrtrue1[j]= flstrtrue[j]
		wavenm = "avef"+num2str(ndfilter[j])
//		avepdiode(0,0,"f"+num2str(ndfilter[j])) //function run before loop for all pdiodes used, not on a per-list basis
		pdiodenm = "pdiodeavg" //AVERAGE PDIODE WAVE FOR ALL USED FLASHES, from "avepdiode" function -- was: "avepf"+num2str(ndfilter[j]) ...for individual flashes
		if(exists(wavenm)==1)
			//get maximum x value of the graph for the findlevel(s) endpoint and smoothing endpoints
			wavelngth=pnt2x($wavenm, numpnts($wavenm))

			//split temp wave into rise and fall, smooth each phase, and reassemble.
			if(smoothing==1)
				//Copy wave to temp wave and do smoothing for noise.
				duplicate/o $wavenm temp
				wavenm="temp"
				duplicate/o/r=(0,1) temp, peppbase
				duplicate/o/r=(1, 1.2) temp, pepprise
				duplicate/o/r=(1.2,wavelngth) temp, peppfall
				Smooth/B/E=3 50, peppbase
				Smooth/B/E=3 5, pepprise
				Smooth/B/E=3 50, peppfall
				concatenate/o {peppbase,pepprise,peppfall},temp //CHANGE NAME TO "smoothed" and set $wavenm="smoothed"....
				killwaves/z peppbase pepprise peppfall
				boxsize=1 //set findlevel(s) moving box average to 1 for smoothed waves
			endif
						
			base = mean($(wavenm), basestart, baseend)
			sat = mean($(wavenm),satstart, satend)
			darki=sat - base

//CALCULATE ftime BASED ON FILTER DELAY AND MIDPOINT OF PDIODE 'FWHM' -- instead of after "findlevels" below...
//			if(waveexists($pdiodenm)==0) //redo avef and varf waves, creating pdiode ave/var waves if they don't exist.
//				Print"--Recalculating average and variance for pdiode traces..."
//				AveVarAll()
//			endif
			halfmax=0.5*wavemax($pdiodenm,0.95,1.05)
			FindLevels/P/Q $pdiodenm, halfmax //0.95 to 1.05 covers the location of the pulse...
			if(V_LevelsFound==2)
				FindLevel/EDGE=1/Q $pdiodenm, halfmax
				pdiodestart=V_LevelX
				FindLevel/EDGE=2/Q $pdiodenm, halfmax
				pdiodeend=V_LevelX
			else
				Print "ERROR: Pdiode center not found. Using manual pdiode shift."
				//pdiodeshift compensation...
				pdiodestart=pdiodeshift
				pdiodeend=pdiodeshift
			endif
			
			//MIDPOINT OF FLASH, TAKING INTO ACCOUNT 30HZ BESSEL FILTER DELAY --> CHANGE TO GLOBAL FOR DYNAMIC FLASH/FILTER ADJUSTMENTS???
			ftime=0.51/filter+(pdiodestart+pdiodeend)/2
			
			//Find where spike first passes 90% of the Dark Current
			//wavestats/q/r=(0,1) $wavenm //used if you're subtracting V_sdev from 90% Id in the FindLevel(s) commands to manage noise level.

			FindLevel/P/B=(boxsize)/Q $wavenm,(percent*darki) //using V_sdev as a measure of noise level. If noise is great then this will compensate for it.
//NOT USED --
//			ftime=round(1000*(leftx($wavenm)+deltax($wavenm)*V_LevelX))/1000 //was "pnt2x($wavenm,V_LevelX)", but changed to include fractional X point values


			//Find where spike last crosses 90% of the Dark Current
			variable first=0
			do
				FindLevels/B=(boxsize)/Q/P/R=[V_LevelX+1, numpnts($wavenm)] $wavenm,(percent*darki)
				if(V_LevelsFound==0 && first==0)
					print "     Pepptau:  |  The "+num2str(round(wavelngth))+"-sec sweep length is too short for measuring the saturation time of avef"+num2str(ndfilter[j])+"."
					saterror=1
					break
				endif
				if(V_LevelsFound>0) //If we have not reached the end of the number of levels found, then find the next level...
					FindLevel/B=(boxsize)/Q/P/R=[V_LevelX+1, numpnts($wavenm)] $wavenm,(percent*darki)				
				endif
				//Print V_LevelsFound
				if(V_LevelsFound==0)
					V_LevelsFound=1
				endif
				first+=1
			while(V_LevelsFound!=1) //mean($wavenm,V_LevelX,(V_LevelX+0.025))>0.9*darki)
			
			tsat=round(1000*(leftx($wavenm)+deltax($wavenm)*V_LevelX))/1000 //see above for explanation, previous code: //round(1000*pnt2x($wavenm,V_LevelX))/1000 //rounding gets rid of 4th decimal place values
			
			//Old Code...
//			do
//				if((mean($wavenm,pnt2x($wavenm,i),pnt2x($wavenm, i+5))> 0.9*darki) %& ((mean($wavenm,pnt2x($wavenm,i+5),pnt2x($wavenm,i+10))<0.9*darki)))
//					a=mean($wavenm,pnt2x($wavenm,i+5),pnt2x($wavenm, i+10))
//					tsat=pnt2x($wavenm,i+5)
//				endif
//				i+=1
//				if(i>1000)
//					tsat=NaN
//					break
//				endif
//			while(tsat==0)
			if(first>0)
				printf "     Pepptau:  |  Tsat:  %2.3f  -  %2.3f  =  %2.3f  seconds  |  Dark current: %2.3f pA for avef%1.0f\r",tsat,ftime,tsat-ftime,darki,ndfilter[j]
			endif
			Id[j]=darki
			if((tsat-ftime)>=(satLimit/1000)) //if saturation is over the specified threshold...
				TimeSat[j]=(tsat-ftime)
			else
				TimeSat[j]=NaN
				print "     Pepptau:  |  avef"+num2str(ndfilter[j])+" is below the "+num2str(satLimit)+"-sec saturation threshold."
			endif
		else
			Id[j]=NaN
			TimeSat[j]=NaN
		endif
		if(saterror==0) //if saturation has been properly calculated
			if(waveexists($("avef"+num2str(ndfilter[j]))))
				Tag/W=Family0/C/N=$("avef"+num2str(ndfilter[j]))/A=MT/F=0/Z=1/X=0.00/Y=100.00/L=2/TL=0/P=0 $("avef"+num2str(ndfilter[j])), tsat, num2str(ndfilter[j])
			endif
		else
			Tag/W=Family0/K/N=$("avef"+num2str(ndfilter[j]))
			Id[j]=NaN
			TimeSat[j]=NaN
		endif
	endfor
	//flip pepptau table waves so values ascend for easy fitting calculations (Rsquared)...
	wavetransform/O flip ndfilter
	wavetransform/O flip Id
	wavetransform/O flip TimeSat
	wavetransform/O flip flstrtrue1
	wavetransform/O flip lnflstr
	lnflstr=ln(flstrtrue1)
	Display/N=pepptau/HIDE=(hide) TimeSat vs lnflstr as "pepptau"
	ModifyGraph/W=pepptau0 mode=3,marker=19,msize=3
	Label/W=pepptau0 left "Time in Saturation"
	Label/W=pepptau0 bottom "ln[Flash Strength] (photons/\\F'Symbol'm\\F'Geneva'm\\S2\\M)"
	Showinfo/W=pepptau0
	//Future feature...add horizontal line set to average of 90% cutoff for all traces...
	//wavestats/q Id
	//dowindow/F Family0
	//if(exists
	appendtograph/W=family0 zero
	wavestats/q Id
	ModifyGraph/W=family0 offset(zero)={0,V_avg*percent},lStyle(zero)=3,rgb(zero)=(0,0,0)
End

//****************************************************************
//****************************************************************
//****************************************************************

Function SummaryLayout(hide) : Layout //Makes tiled layout of relevant graphs and tables
	variable hide
	NVAR ndfin = root:globals:maxndfused
	Silent 1
	Pauseupdate
	DoWindow/K Summary
	DoWindow/F StdControlPanel
	if(V_Flag==1)
		DoWindow/K/W=StdControlPanel StdControlPanel
	endif
	//Layout/T summarytable,pepptau0,intensresp,IntTime,TauRec,MeanSquaredFit0,Family0,f18_list as "Summary"

	variable menuwidth
	if(stringmatch(IgorInfo(2),"Windows")) //Microsoft Windows
		menuwidth=0 //no menu at the top of screen
	endif
	if(stringmatch(IgorInfo(2),"Macintosh")) //Apple Macintosh
		menuwidth=44 //menu is 44px wide
	endif
	
	//Following code is for persistent windows
	NewLayout/N=Summary/W=(0,menuwidth,700,menuwidth+800)/HIDE=(hide)
	ModifyLayout/W=Summary mag=1 //change default zoom level of the layouts.
	Printsettings/W=Summary margins={0.25,0.25,0.25,0.25}
	AppendLayoutObject/W=Summary table summarytable
	AppendLayoutObject/W=Summary graph pepptau0
	AppendLayoutObject/W=Summary graph intensresp
	AppendLayoutObject/W=Summary graph IntTime
	AppendLayoutObject/W=Summary graph TauRec
	
	//Get Wavenames on MeanSquaredFit Graph and set graph axis values depending on maximum and minimum wave values
	Variable ymax
	Variable ymin
	Variable tickinc
	Variable dp=1
	wavestats/q $stringfromlist(0, tracenamelist("MeanSquaredFitPanel#MeanSquaredFit",":",1),":")
	ymax=V_max
	ymin=V_min
	wavestats/q $stringfromlist(1, tracenamelist("MeanSquaredFitPanel#MeanSquaredFit",":",1),":")
	if(V_max>ymax)
		ymax=V_max
	endif
	if(V_min<ymin)
		ymin=V_min
	endif
	
	if(ymax-ymin<0.6)
		tickinc=0.05
		dp=2
	endif
	if(ymax-ymin>=0.6 && ymax-ymin<1.2)
		tickinc=0.1
	endif
	if(ymax-ymin>=1.2 && ymax-ymin<2.1)
		tickinc=0.3
	endif
	if(ymax-ymin>=2.1 && ymax-ymin<3)
		tickinc=0.5
	endif
	if(ymax-ymin>=3 && ymax-ymin<6)
		tickinc=1
	endif
	if(ymax-ymin>=6)
		tickinc=2
	endif
	
	ModifyGraph/W=MeanSquaredFitPanel#MeanSquaredFit manTick(left)={0,tickinc,0,dp}
//	ModifyGraph/W=SPRList manTick(left)={0,2,0,dp} //The last digit "...,x}" is the number of decimal places in the labels.
	ModifyGraph/W=MeanSquaredFitPanel#MeanSquaredFit manMinor(left)={0,0}
	
	WAVE/T Values=root:Values
	NVAR ndfin=root:ndfin
	WAVE dimlist=root:$("f"+num2str(ndfin))
	NVAR baselinelength=root:globals:baselinelength
	variable xmin=baselinelength-0.05
	variable i=0
	GetAxis/Q/W=MeanSquaredFitPanel#MeanSquaredFit bottom
	dowindow/k SummaryMeanSquaredFit
	display/N=SummaryMeanSquaredFit/HIDE=1 /W=(10,10,820,560)/L=L2 $("imem"+num2str(dimlist[i])) as "MeanSquaredFit"
	ModifyGraph/W=SummaryMeanSquaredFit rgb($("imem"+num2str(dimlist[i])))=(65535,57311,53970)
	for(i=1;i<numpnts($("f"+num2str(ndfin)));i+=1)
		appendtograph/W=SummaryMeanSquaredFit/L=L2 $("imem"+num2str(dimlist[i]))
		ModifyGraph/W=SummaryMeanSquaredFit rgb($("imem"+num2str(dimlist[i])))=(65535,57311,53970)
	endfor
	appendtograph/W=SummaryMeanSquaredFit/L=L1 Flash
	SetAxis/W=SummaryMeanSquaredFit/A=2 L2
	ModifyGraph/W=SummaryMeanSquaredFit noLabel(L1)=2,axThick(L1)=0 //L2
	appendtograph/W=SummaryMeanSquaredFit $("avef"+num2str(ndfin)+"2") $("varf"+num2str(ndfin)+"2")
	SetAxis/W=SummaryMeanSquaredFit L1 0,2*wavemax(Flash)
	ModifyGraph/W=SummaryMeanSquaredFit freePos(L2)=-500,tick(L2)=0,mirror(L2)=3,freePos(L2)=500
//	ModifyGraph axRGB(L1)=(32769,65535,32768),tlblRGB(L1)=(32769,65535,32768), alblRGB(L1)=(32769,65535,32768)
	ModifyGraph axRGB(L2)=(65535,57311,53970), tlblRGB(L2)=(65535,57311,53970), alblRGB(L2)=(65535,57311,53970)
	ModifyGraph/W=SummaryMeanSquaredFit rgb($("varf"+num2str(ndfin)+"2"))=(0,0,0)
	ModifyGraph/W=SummaryMeanSquaredFit rgb(Flash)=(0,65000,6500), lstyle(Flash)=0, lsize(Flash)=0, hbFill(Flash)=5, mode(Flash)=7
	ModifyGraph/W=SummaryMeanSquaredFit manTick=0
//	ModifyGraph/W=SummaryMeanSquaredFit framestyle=0
	SetAxis/W=SummaryMeanSquaredFit /A=2 left
	SetAxis/W=SummaryMeanSquaredFit bottom xmin,(baselinelength+1.5*str2num(Values[2])/1000) //was 0.95, 1.2

	AppendLayoutObject/W=Summary graph SummaryMeanSquaredFit
	AppendLayoutObject/W=Summary graph Family0
	AppendLayoutObject/W=Summary graph index_list
	
	DoWindow/HIDE=0 Summary
	execute "Tile/G=4"
//	DoWindow/HIDE=(hide) Summary
	
	DoWindow/F Summary
	
	execute "StdControlPanel()"
End

//****************************************************************
//****************************************************************
//****************************************************************

Function KillAllWindows()
	Silent 1
	Pauseupdate
	variable i=0
	do //Kill all graphs and layouts
		DoWindow/K $("Graph"+num2str(i))
		DoWindow/K $("Layout"+num2str(i))
		i+=1
	while(i<100)
	//pepptau0,intensresp,IntTime,TauRec,MeanSquaredFit0,Family0,list,summary
	DoWindow/K pepptau0
	DoWindow/K intensresp
	DoWindow/K IntTime
	DoWindow/K TauRec
	DoWindow/K MeanSquaredFit0
	DoWindow/K Family0
	DoWindow/K list
	DoWindow/K MeanSquaredFitPanel
	DoWindow/F StdControlPanel
	if(V_Flag==1)
		DoWindow/K/W=StdControlPanel StdControlPanel
	endif
	DoWindow/K pepptautable
	DoWindow/K intensityresponse0
	DoWindow/K wavelists
	DoWindow/K summary
	DoWindow/K summarytable
	DoWindow/K bbinfo
	DoWindow/K fbinfo
	DoWindow/K AdaptationSat
	DoWindow/K AdaptationId
End

//****************************************************************
//****************************************************************
//****************************************************************

Function ResetValues()
	Silent 1
	
	WAVE/T Values=root:Values
	WAVE/T Measurements=root:Measurements
	
	Pauseupdate
	variable i=0
	if(exists("Values")==1)
		wavestats/q Values
		Measurements[i]=""
		do
			Values[i]=""
			i+=1
		while(i<V_npnts)
	endif
end

//****************************************************************
//****************************************************************
//****************************************************************

Macro StartOver(verify)
	string verify
	prompt verify, "Do you want to proceed?",popup,"no;yes"
	Silent 1
	Pauseupdate
	if(char2num($("verify")[0])==char2num("y"))
		Print "- - - - - - - - - - STARTING OVER - - - - - - - - - -"
		variable/g root:globals:standardcomplete=0
		variable/g root:globals:AveVarcomplete=0
		variable/g root:globals:Idcomplete=0
		variable/g root:globals:TTPcomplete=0
		variable/g root:globals:SPRcomplete=0
		variable/g root:globals:othercomplete=0
		KillAllWindows()
		killwaves/A/Z
		//Execute "ResetValues()" ...not needed...standard setup replaces values with "makedefaultwaves" execution...
		StandardSetup()
	endif
endmacro

//****************************************************************
//****************************************************************
//****************************************************************

Function MakeDefaultWaves(recdate)
	variable recdate //recording date...
	variable cutoffdate = 20140607 //June 7 cutoff date
	variable ratio
	sscanf fullnum2str(recdate/cutoffdate), "%f", ratio
	variable usenew = trunc(ratio)
	prompt usenew, "Use ND calibrations after June 7, 2014?", popup, "No;Yes"
	
	string dates="Jan;Feb;Mar;Apr;May;Jun;Jul;Aug;Sep;Oct;Nov;Dec"
	string yearstr= stringfromlist(5,replacestring(" ",date(),","),",")
	string monthstr = num2str(whichlistitem(stringfromlist(2,replacestring(" ",date(),","),","),dates,";")+1)
	if (strlen(monthstr)==1)
		monthstr = "0"+monthstr
	endif
	string daystr = stringfromlist(3,replacestring(" ",date(),","),",")
	if (strlen(daystr)==1)
		daystr = "0"+daystr
	endif
	
	if(numtype(recdate)!=0 || recdate < 20000000 || recdate > str2num(yearstr+monthstr+daystr))
		doprompt "Cannot determine recording date", usenew
		usenew-=1
	endif
	Silent 1
	Pauseupdate
	Make/O/N=28 ndfvoltage
		ndfvoltage[0]=0.0101
		ndfvoltage[1]=0.0410131
		ndfvoltage[2]=0.0720834
		ndfvoltage[3]=0.103923
		ndfvoltage[4]=0.134377
		ndfvoltage[5]=0.166627
		ndfvoltage[6]=0.197917
		ndfvoltage[7]=0.230506
		ndfvoltage[8]=0.385962
		ndfvoltage[9]=0.419349
		ndfvoltage[10]=0.450812
		ndfvoltage[11]=0.484313
		ndfvoltage[12]=0.890786
		ndfvoltage[13]=0.926017
		ndfvoltage[14]=0.957533
		ndfvoltage[15]=0.992879
		ndfvoltage[16]=1.90253
		ndfvoltage[17]=1.94136
		ndfvoltage[18]=1.97288
		ndfvoltage[19]=2.01143
		ndfvoltage[20]=2.77632
		ndfvoltage[21]=10
		ndfvoltage[22]=10
		ndfvoltage[23]=10
		ndfvoltage[24]=10
		ndfvoltage[25]=10
		ndfvoltage[26]=10
		ndfvoltage[27]=10
	Make/O/N=28 ndflist
		ndflist[0]=0
		ndflist[1]=3
		ndflist[2]=6
		ndflist[3]=9
		ndflist[4]=12
		ndflist[5]=15
		ndflist[6]=18
		ndflist[7]=21
		ndflist[8]=24
		ndflist[9]=27
		ndflist[10]=30
		ndflist[11]=33
		ndflist[12]=36
		ndflist[13]=39
		ndflist[14]=42
		ndflist[15]=45
		ndflist[16]=48
		ndflist[17]=51
		ndflist[18]=54
		ndflist[19]=57
		ndflist[20]=60
		ndflist[21]=63
		ndflist[22]=66
		ndflist[23]=69
		ndflist[24]=72
		ndflist[25]=75
		ndflist[26]=78
		ndflist[27]=81
	Make/O/N=10/T Measurements
//		Measurements[0]=""
		Measurements[1]="Id (pA)"
		Measurements[2]="Time to Peak (ms)"
		Measurements[3]="SPR Amplitude (pA)"
		Measurements[4]="Taurec (ms)"
		Measurements[5]="Int Time (ms)"
		Measurements[6]="Io (photons/µm2)"
		Measurements[7]="Pepp Tau 1 (ms)"
		Measurements[8]="Pepp Tau 2 (ms)"
		Measurements[9]="Rod Collecting Area"
	Make/O/N=10/T Values
		Values[0]=""
		Values[1]=""
		Values[2]=""
		Values[3]=""
		Values[4]=""
		Values[5]=""
		Values[6]=""
		Values[7]=""
		Values[8]=""
		Values[9]=""
	Make/O/N=24 bbndftrue
	if(usenew) //new calibration values...
		print "Using ND calibration values after June 7, 2014"
		bbndftrue[0]=0
		bbndftrue[1]=0.386633
		bbndftrue[2]=0.650037
		bbndftrue[3]=1.03311
		bbndftrue[4]=1.43078
		bbndftrue[5]=1.83603
		bbndftrue[6]=2.07719
		bbndftrue[7]=2.46051
		bbndftrue[8]=2.77616
		bbndftrue[9]=3.16237
		bbndftrue[10]=3.4262
		bbndftrue[11]=3.81283
		bbndftrue[12]=4.02836
		bbndftrue[13]=4.41499
		bbndftrue[14]=4.6784
		bbndftrue[15]=5.06503
		bbndftrue[16]=5.32992
		bbndftrue[17]=5.71656
		bbndftrue[18]=5.97996
		bbndftrue[19]=6.36659
		bbndftrue[20]=6.8027
		bbndftrue[21]=7.18933
		bbndftrue[22]=7.45273
		bbndftrue[23]=7.83937
	else
		print "Using ND calibration values before June 7, 2014"
		bbndftrue[0]=0
		bbndftrue[1]=0.3844
		bbndftrue[2]=0.6316
		bbndftrue[3]=0.9932
		bbndftrue[4]=1.394
		bbndftrue[5]=1.7805
		bbndftrue[6]=2.014
		bbndftrue[7]=2.394
		bbndftrue[8]=2.7142
		bbndftrue[9]=3.0986
		bbndftrue[10]=3.3458
		bbndftrue[11]=3.7074
		bbndftrue[12]=4.1058
		bbndftrue[13]=4.4902
		bbndftrue[14]=4.7374
		bbndftrue[15]=5.099
		bbndftrue[16]=5.4078
		bbndftrue[17]=5.7922
		bbndftrue[18]=6.0394
		bbndftrue[19]=6.4238
		bbndftrue[20]=6.7667
		bbndftrue[21]=7.1511
		bbndftrue[22]=7.3983
		bbndftrue[23]=7.7599
	endif
	Make/O/N=24 bbndfvoltage
		bbndfvoltage[0]=0.0106269
		bbndfvoltage[1]=0.0409581
		bbndfvoltage[2]=0.0714339
		bbndfvoltage[3]=0.102079
		bbndfvoltage[4]=0.132001
		bbndfvoltage[5]=0.163038
		bbndfvoltage[6]=0.193536
		bbndfvoltage[7]=0.224918
		bbndfvoltage[8]=0.376418
		bbndfvoltage[9]=0.408676
		bbndfvoltage[10]=0.439306
		bbndfvoltage[11]=0.471809
		bbndfvoltage[12]=0.867392
		bbndfvoltage[13]=0.901604
		bbndfvoltage[14]=0.932279
		bbndfvoltage[15]=0.966596
		bbndfvoltage[16]=1.85133
		bbndfvoltage[17]=1.88915
		bbndfvoltage[18]=1.91993
		bbndfvoltage[19]=1.95766
		bbndfvoltage[20]=2.75472
		bbndfvoltage[21]=2.75472
		bbndfvoltage[22]=2.75472
		bbndfvoltage[23]=2.75472
	Make/O/N=24 ndftrue
	if(usenew) //new values as of July 2014
		ndftrue[0]=0
		ndftrue[1]=0.277148
		ndftrue[2]=0.592846
		ndftrue[3]=0.839129
		ndftrue[4]=1.14192
		ndftrue[5]=1.42008
		ndftrue[6]=1.71012
		ndftrue[7]=1.98996
		ndftrue[8]=2.233
		ndftrue[9]=2.506
		ndftrue[10]=2.8293
		ndftrue[11]=3.07665
		ndftrue[12]=3.32991
		ndftrue[13]=3.60705
		ndftrue[14]=3.92275
		ndftrue[15]=4.1999
		ndftrue[16]=4.43169
		ndftrue[17]=4.70884
		ndftrue[18]=5.02453
		ndftrue[19]=5.30168
		ndftrue[20]=5.5459
		ndftrue[21]=5.82304
		ndftrue[22]=6.13874
	else
		ndftrue[0]=0
		ndftrue[1]=0.2718
		ndftrue[2]=0.525
		ndftrue[3]=0.7987
		ndftrue[4]=1.124
		ndftrue[5]=1.407
		ndftrue[6]=1.654
		ndftrue[7]=1.927
		ndftrue[8]=2.16
		ndftrue[9]=2.432
		ndftrue[10]=2.685
		ndftrue[11]=2.959
		ndftrue[12]=3.242
		ndftrue[13]=3.514
		ndftrue[14]=3.767
		ndftrue[15]=4.041
		ndftrue[16]=4.289
		ndftrue[17]=4.561
		ndftrue[18]=4.814
		ndftrue[19]=5.088
		ndftrue[20]=5.383
		ndftrue[21]=5.6548
		ndftrue[22]=5.908
		ndftrue[23]=6.1798
	endif
	Make/O/N=2 zero
		zero=0
		SetScale/I x 0,5,"s", zero
End

//****************************************************************
//****************************************************************
//****************************************************************

//R-square function for best-fit....hope it's correct...
Function Rsquare(datawave,fitwave,start,stop,datamask)
	wave datawave
	wave fitwave
	wave datamask
	variable start
	variable stop
	Silent 1
	Pauseupdate
	variable grandmean
	variable sumw=0
	variable sumpts=0
	variable i=0
	variable a=0
	variable b=0
	variable c=0
	wavestats/q datawave
	variable datlength=V_npnts
	wavestats/q datamask
	duplicate/o datawave calcwave
	if(datlength==V_npnts) //checks if datawave and datamask waves are compatible...
		do
			if(datamask[i]==0)
				calcwave[i]=0 //calcwave used in cases you want "Nan" inputted instead of 0....potential probs with nan...
			else
				sumw+=calcwave[i]
				sumpts+=1
			endif
			i+=1
		while(i<=V_npnts)
		grandmean=sumw/sumpts
	else
		grandmean=mean(calcwave,start,stop)
	endif
	variable SSE=0
	variable SSR=0
	variable SST=0
	variable j=0 //iteration variable for fit-wave, which wont have same x-offset as the datawave
	for(i=start;i<=stop;i+=1)
		if(calcwave[i]!=0)
			SSE+=(calcwave[i]-fitwave[j])^2 //Explained Sum of Squares
			SSR+=(fitwave[j]-grandmean)^2 //Residual Sum of Squares
			SST+=(calcwave[i]-grandmean)^2 //Total Sum of Squares
		endif
		j+=1
	endfor
//	print ""
//	print "start:",start
//	print "stop:",stop
//	print "mean:",grandmean
//	print "SST:",SST
//	print "SSR:",SSR
//	print "SSE:",SSE
//	print "Diff:",(SST-(SSR+SSE))
//	print "SSR/SST", SSR/SST
//	print "SSR/(SSR+SSE)", SSR/(SSR+SSE)
//	print "1-(SSE/SST)",1-(SSE/SST)
	if(0<SSR/SST && SSR/SST<=1)
		a=1
	endif
	if(0<SSR/(SSR+SSE) && SSR/(SSR+SSE)<=1)
		b=1
	endif
	if(0<(1-(SSE/SST)) && (1-(SSE/SST))<=1)
		c=1
	endif
	if(a+b+c>0)
		return(((SSR/SST)*a+(SSR/(SSR+SSE))*b+(1-(SSE/SST))*c)/(a+b+c))
	else
		return(Nan)
	endif
End

//****************************************************************
//****************************************************************
//****************************************************************

Function SaveProcs(hide) : ButtonControl
	variable hide
	string mflist=MacroList("*",";","KIND:6")+FunctionList("*",";","KIND:2")

	DoWindow/F Procedures
	If(V_Flag)
	Print "--Rewriting Saved Procedures in Existing Notebook..."
		Notebook Procedures selection={startOfFile, endOfFile}
		Notebook Procedures text=""
	else
	Print "--Saving Procedures in New Notebook..."
		NewNotebook/F=0/N=Procedures as "Procedures Used..."
	endif
	
	//Create Menus scripts...
	Notebook Procedures selection={endOfFile, endOfFile}
	Notebook Procedures text="#pragma rtGlobals=1\t\t// Use modern global access method.\r#pragma version=1.95\r\rMenu \"|| AnaMouse ||\", dynamic\r\tMenuItem(1), StandardSetup() //Standard Setup\r\thelp={\"Runs the standard setup script...\"}"
	Notebook Procedures selection={endOfFile, endOfFile}
	Notebook Procedures text="\r\tSubMenu \"   Standard Setup Components\"\r\t\t\"Import Traces\", ImportNQ()\r\t\t\"Display Charts and Layouts\", DisplayCartsandLayouts()\r\t\t\"   Display Charts\", DisplayChart()\r\t\t\"   Make Layouts\", MakeLayouts()\r\t\t\"Make Waves and Lists\", MakeWavesandLists()\r\t\t\"   Make Waves\", MakeWaves()"
	Notebook Procedures selection={endOfFile, endOfFile}
	Notebook Procedures text="\r\t\t\"   Make Lists\", MakeLists()\r\t\t\"Light Intensity\", LightIntensity()\r\tend\r\tMenuItem(8), StartOver()\r\tSubMenu MenuItem(9); //\"   Start Over Components\"\r\t\t\"Kill All Windows\", KillAllWindows()\r\t\t\"Reset Values\", ResetValues()"
	Notebook Procedures selection={endOfFile, endOfFile}
	Notebook Procedures text="\r\t\t\"Run Standard Setup\", StandardSetup()\r\tEnd\r\t\"-\"\r\tMenuItem(2), AveVarAll()\r\tMenuItem(3), MeasureDarkCurrent()\r\tMenuItem(4), TimeToPeak()\r\tMenuItem(5), MeanSquaredFit()\r\tMenuItem(6), SetupOther()\r\tSubMenu MenuItem(7); //\"Other Components\"\r\t\t\"Average and Variance\", AveandVar()\r\t\t\"Display List Of Waves\", DisplayListOfWaves()"
	Notebook Procedures selection={endOfFile, endOfFile}
	Notebook Procedures text="\r\t\t\"Flash Family\", Family()\r\t\t\"Check Linearity\", CheckLinearlity()\r\t\t\"Average P-diode\", AvePdiode()\r\t\t\"Make Taurec\", TauRec()\r\t\t\"Make Int Time\", IntTime()\r\t\t\"Intensity Response \\\"Io\\\"\", IntensityResponse()\r\t\t\"Make Pepp Tau\", PeppTau()"
	Notebook Procedures selection={endOfFile, endOfFile}
	Notebook Procedures text="\r\t\t\"Time in Saturation\", Tsat()\r\tend\r\t\"-\"\r\tSubMenu \"General Utilities\"\r\t\t\"AdaptDecay\"\r\t\t\"AddFlags\"\r\t\t\"AlignTop\"\r\t\t\"BaselineShift\"\r\t\t\"ChangeGain\"\r\t\t\"DarkCurrentCorrect\"\r\t\t\"Decompress\"\r\t\t\"DriftClamp\"\r\t\t\"ExciseWave\"\r\t\t\"FindRange\"\r\t\t\"LoadIndexWaves\"\r\t\t\"RemoveZeros\"\r\t\t//\"MeanSquared2\""
	Notebook Procedures selection={endOfFile, endOfFile}
	Notebook Procedures text="\r\t\t\"MichaelisFits\"\r\t\t\"Normalize\"\r\t\t\"Recompress\"\r\t\t\"WeberFechner\"\r\tEnd\r\t\"-\"\r\tSubMenu \"Modeling\"\r\t\t\"cGConc\"\r\t\t\"CGHoleHomogeneous\"\r\t\t\"CyclaseActivity\"\r\t\t\"BetaSub\"\r\t\t\"PredictCyclaseActivity\"\r\t\t\"PDEActivity\"\r\t\t\"RhLifeTime\"\r\tEnd\r\t\"-\""
	Notebook Procedures selection={endOfFile, endOfFile}
	Notebook Procedures text="\r\tSubmenu \"Noise Analysis\"\r\t\t\"FiltPS\"\r\t\t\"PowerSpec\"\r\t\t\"PowerSpecCellNoise\"\r\t\t\"PowerSpecClamp\"\r\t\t\"PowerSpecVar\"\r\tEnd\r\t\"-\"\r\tSubMenu \"Single Photon\"\r\t\t\"CheckFit\"\r\t\t\"CompShape\"\r\t\t\"DimFlashFit\"\r\t\t\"DimPk\"\r\t\t\"MakeHisto\"\r\t\t\"PiezoSlope\"\r\t\t\"PiezoSort\"\r\t\t\"QHist\"\r\t\t\"ResponseAmps\""
	Notebook Procedures selection={endOfFile, endOfFile}
	Notebook Procedures text="\r\t\t\"ResponseAreas\"\r\t\t\"ResponseAves\"\r\t\t\"ResponsePeaks\"\r\tEnd\r\t\"-\"\r\t\"Export Files/0\",Exportlist()\rEnd\r\r//****************************************************************\r//****************************************************************"
	Notebook Procedures selection={endOfFile, endOfFile}
	Notebook Procedures text="\r//****************************************************************\r\rMenu \"Macros\"\r\t\"ImportNQ\"\r\t\"DisplayChart\"\r\t\"MakeLayouts\"\r\t\"MakeWaves\"\r\t\"MakeLists\"\r\t\"LightIntensity\"\r\tSubMenu \"General Utilities\"\r\t\t\"Family\"\r\t\t\"IntensityResponse\"\r\t\t\"MeasureDarkCurrent\"\r\t\t\"MeanSquaredFit\"\r\t\t\"TimetoPeak\""
	Notebook Procedures selection={endOfFile, endOfFile}
	Notebook Procedures text="\r\tEnd\r\t\"-\"\r\tSubMenu \"AnaMouseR Utilities\"\r\t\t\"adaptexpfit\"\r\t\t\"adaptexpfind\"\r\t\t\"inittimecalc\"\r\t\t\"linefit\"\r\t\t\"expfit\"\r\t\t\"expzerobase\"\r\t\t\"expfind\"\r\t\t\"satexpfit\"\r\t\t\"ManualIoMax\"\r\t\t\"StandardSetup\"\r\t\t\"Intensityresponse\"\r\t\t\"TimeToPeak\"\r\t\t\"MeasureDarkCurrent\""
	Notebook Procedures selection={endOfFile, endOfFile}
	Notebook Procedures text="\r\t\t\"MeanSquaredFit\"\r\t\t\"ScaleSlide\"\r\t\t\"Scaleup\"\r\t\t\"Scaledn\"\r\t\t\"CheckLinearity\"\r\t\t\"SetupOther\"\r\t\t\"MakeTauRec\"\r\t\t\"MakeIntTime\"\r\t\t\"SummaryLayout\"\r\t\t\"ExportList\"\r\t\t\"KillAllWindows\"\r\t\t\"ResetValues\"\r\t\t\"StartOver\"\r\t\t\"-\"\r\tend\r\t\"-\""
	Notebook Procedures selection={endOfFile, endOfFile}
	Notebook Procedures text="\r\tSubMenu \"Modeling\"\r\tEnd\r\t\"-\"\r\tSubmenu \"Noise Analysis\"\r\tEnd\r\t\"-\"\r\tSubMenu \"Single Photon\"\r\tEnd\rEnd\r"

	//Output procedure text for each macro/function, followed by separator bars
	variable i
	for(i=itemsinlist(mflist);i>=0;i-=1)
		Notebook Procedures selection={endOfFile, endOfFile}
		Notebook Procedures text=ProcedureText(stringfromlist(i, mflist))
		Notebook Procedures selection={endOfFile, endOfFile}
		Notebook Procedures text="\r//****************************************************************\r//****************************************************************\r//****************************************************************\r\r"
	endfor
	DoWindow/B Procedures
end

Macro SaveProcsMacro(ctrlName) : ButtonControl
	string ctrlName
	SaveProcs()
endmacro

//****************************************************************
//****************************************************************
//****************************************************************

//Function amp_old(ndf, id, col)  // Calculates the amplification constant.
//	variable ndf //filter number
//	variable id //dark current
//	variable col //collecting area
//	
//	variable biochemdelay = 0 //innate biochemical delay of phototransduction (msec) -- NOT NEEDED
//	variable filterdelay = 17.5 //based on delay of 8-pole bessel at 30Hz (msec)
//	variable flshoffsetdelay = 0 //middle of 10msec pulse...questionable (msec)
//	variable baseline = 1000
//	variable totaldelay=baseline+biochemdelay+filterdelay+flshoffsetdelay
//	
//	variable d1=0, d2=0, intensity=0, ndfnum=0, xx=0
////	print "Dark current =", id
//	variable ampc
//	string ampstr="avef"+num2str(ndf)
//	wave ndflist, flstrtrue
////	duplicate/o $ampstr ampwave
//	duplicate/o $("avef"+num2str(ndf)) ampwave
//						
//	ampwave/=id			// Makes R(t) wave and fits with quadratic up to 1/2 of the amp.
//	
//	deletepoints 0, round(totaldelay/(deltax(ampwave)*1000)), ampwave //convert to points, rounding to nearest value...might want "floor"?
//	
//	//205 POINTS ARE REMOVED FROM WAVES AT 200HZ
//	//205 points from point 0 need to be removed, which means that the first time point is equivalent to t=1.025 rather than 0.0. 
//	//This is to account for the 17.5 msec
//	//delay from the 8-pole bessel filter at 30Hz, and to account for a 2.5 msec biochem
//	//delay as well as to offset the output wave over the 10 msec stimulus pulse, which
//	//means another 5 msec delay to account for. Overall this is 25 msec of delay, which
//	//at 200Hz acquisition rate is 5 points. Therefore the 205th point in the graph (starting
//	//from 1) needs to be removed, which means we have to remove 206 points total,
//	//starting from 0.
//
//	duplicate/o ampwave, ampwave2, ampfit2
//	wavestats/q ampwave
//	findlevel/q ampwave, (1/3*v_max)
//	d1=x2pnt(ampwave, v_levelx)
////	print d1,"WAHOO!!!"
////	d1=15
//	d2=(numpnts(ampwave)-d1)
//
//	deletepoints d1+1, d2-1, ampwave
////	deletepoints 15+1, (numpnts(ampwave)-15)-1, ampwave
//	//display ampwave
//	
//	K0=0
//	K1=0
//	CurveFit/Q/H="110" poly 3, ampwave /D
//
//	//ndfnum=ndf	// Calculates amp constant from K2, assumingcollecting area of 0.29.
//	wavestats/q ndflist
////	print "Maximum NDF in ndflist:",V_max
//	if(V_max<10)
//		findlevel/q ndflist, ndf/10
//	else
//		findlevel/q ndflist, ndf
//	endif
//	xx=v_levelx
//	intensity=flstrtrue[xx]
////	print "Flash Intensity is:",intensity
//	AmpC = 2*K2/(col*intensity)
//	ampfit2 = k0+k2*x^2
////	deletepoints d1*3/2, (d2), ampfit2
//
//	deletepoints d1*20,d2, ampwave2
//	duplicate/o ampfit2 $("ampfit"+num2str(ndf))
//	duplicate/o ampwave2 $("amp"+num2str(ndf))	
//	appendtograph $("amp"+num2str(ndf)), $("ampfit"+num2str(ndf))
//	ModifyGraph rgb($("ampfit"+num2str(ndf)))=(0,0,0)
//	SetAxis left *,1.05 //+abs(0.05)
//	SetAxis bottom 0,0.3
//		
////	print "Wave amplification constant =",ampc
//	return ampc
//End

Function amp(ndf, id, col, delay, fdur)  // Calculates the amplification constant.
	variable ndf //filter number
	variable id //dark current
	variable col //collecting area
	variable delay //total delay in the system (from flash to response, in msec), including baseline (~1000msec)
	variable fdur
	
	duplicate/o $("avef"+num2str(ndf)) $("amp"+num2str(ndf))
	wave ampwave=$("amp"+num2str(ndf))
	ampwave/=id
	deletepoints 0, floor(delay/(deltax(ampwave)*1000)), ampwave //convert to points, rounding to nearest value...might want "floor"?

	findlevel/q ampwave, (wavemax(ampwave)/3)

	//built-in polynomial function fit...
//	K0=0
//	K1=0
//	CurveFit/Q/H="110" poly 3, ampwave[0,x2pnt(ampwave,v_levelx)]
	
	//user-defined polynomial function fit...
	Make/D/N=4/O W_coef
	W_coef[0] = {0,0,1,0.00}
	Make/O/T/N=2 T_Constraints
//	T_Constraints[0] = {"K3 > 0","K3 < "+num2str(fdur/1000)} //constraint of 0 to 0.01 assumes 10msec flash is NOT accounted for in ANY delay settings (fit starts at very beginning of flash).
	FuncFit/Q/NTHR=0/H="1101" amppoly W_coef ampwave[0,6]//was 0,20 //x2pnt(ampwave,v_levelx)] //C=T_Constraints
	
	//re-fit by removing as many points before the base of the polynomial curve as possible
	if(W_coef[3]>deltax(ampwave))
		variable truncval=trunc(W_coef[3]/deltax(ampwave))*deltax(ampwave)
		Print num2str(1000*W_coef[3])+"msec First fit X-offset"
		FuncFit/Q/NTHR=0/H="1101" amppoly W_coef ampwave[0,6]//was 0,20 //x2pnt(ampwave,truncval),x2pnt(ampwave,v_levelx)] //C=T_Constraints
		Print num2str(1000*W_coef[3])+"msec X-offset for NDF "+num2str(ndf)+"; Curve fit not including first "+num2str(1000*truncval)+"msec"
	else
		Print num2str(1000*W_coef[3])+"msec X-offset for NDF",ndf
	endif
	
	Print "Fit between "+num2str(pnt2x(ampwave,0))+"msec and "+num2str(pnt2x(ampwave,6))+"msec of curve "+nameofwave(ampwave)
	
	//make fit wave be 10x the number of points, with scale set accordingly...
	Make/o/n=(numpnts(ampwave)*10) $("fit_amp"+num2str(ndf))
	wave ampfit=$("fit_amp"+num2str(ndf))
	setscale/P x 0, deltax(ampwave)/10, ampfit

//	ampfit=K0+K1*x+K2*x^2
//	ampfit=W_coef[0]+W_coef[1]*x+W_coef[2]*(x-W_coef[3])^2
	ampfit=amppoly(W_coef,x) //create fit wave based on curve fitting function.
	
	if(stringmatch(winlist("ampconst","","WIN:1"),"ampconst")) //if graph exists (by matching an existing graph window list search)
		appendtograph/w=ampconst ampwave, ampfit
		ModifyGraph/w=ampconst rgb($("fit_amp"+num2str(ndf)))=(0,0,0)
		SetAxis/w=ampconst left *,1.05 //+abs(0.05)
		SetAxis/w=ampconst bottom 0,0.3
	endif
	
	wave ndflist, flstrtrue
	if(wavemax(ndflist)<10)
		findlevel/q ndflist, ndf/10
	else
		findlevel/q ndflist, ndf
	endif
	
//	return 2*K2/(col*flstrtrue[v_levelx])
	return 2*W_coef[2]/(col*flstrtrue[v_levelx]) //for X-shift polynomial function
End

// 3-term polynomial with x-offset for measuring jitter and parabolic rise start time in the amplification constant analysis
Function amppoly(w,x) : FitFunc
	wave w; Variable x
	Return (w[0]+w[1]*x+w[2]*(x-w[3])^2)
End

Function ampall(id, col, lim) //"Values" wave is input... such as "ampall(str2num(Values[1]),str2num(Values[9]),18)"
	variable id //dark current
	variable col //collecting area
	variable lim //lower NDF limit
	
	variable biochemdelay = 0 //innate biochemical delay of phototransduction (msec) -- NOT NEEDED
	variable filterdelay = 17.5 //based on delay of 8-pole bessel at 30Hz (msec)
	variable flshoffsetdelay = 10 //middle of 10msec pulse...questionable (msec)
	variable baseline = 1000
	variable totaldelay=baseline+biochemdelay+filterdelay+flshoffsetdelay
	
	make/o/n=0 ampconstwave
	make/o/t/n=0 ampflist
	variable i=0
	
	NVAR fdur=root:globals:fdur
	
	Print "--Calculating Amplification Constant"
	
	if(numtype(col)!=0)
		Print "     ERROR: No SPR Data!!!"
	else

		dowindow/k ampconst
		display/n=ampconst
	
		for(i=lim;i<=81;i+=3)
			if(waveexists($("avef"+num2str(i))))
				InsertPoints 0,1, ampflist, ampconstwave
				ampflist[0]="f"+num2str(i)
				ampconstwave[0]=amp(i,id,col,totaldelay,fdur)
				WAVE fitwave=root:$("fit_amp"+num2str(i))
				WAVE ampwave=root:$("amp"+num2str(i))
				printf "     f"+num2str(i)+" amp constant: %2.4f  |  Fitwave Zero-intersect: %2.4f  |  Ampwave Zero-intersect: %2.4f\r",ampconstwave[0],fitwave[0],ampwave[0]
			endif
		endfor
	
		dowindow/k amptbl
		edit/n=amptbl ampflist, ampconstwave
		dowindow/f ampconst
		variable chartrate = 1/deltax(imemchart)
		Print "     Dark Current =", id, "  Collecting Area =", col, "  Flash Duration =", fdur
		Print "     Total Delay of "+num2str(totaldelay)+"msec rounded to the nearest "+num2str(1000/chartrate)+"msec (for "+num2str(chartrate)+"Hz) to "+num2str(floor(totaldelay*(chartrate/1000))*(1000/chartrate))+"msec"
		wavestats/q ampconstwave
		print "     Amp const mean =",V_avg
		print "     SEM =",V_sdev/sqrt(V_npnts-1)
	endif
End

//****************************************************************
//****************************************************************
//****************************************************************

Function GetTraceOffset(graphnm,tracenm,xy)
	string graphnm
	string tracenm
	string xy //axis -- x or y
	variable n
	
	make/o/n=2 offsetvarw
	
//		string tinfo=TraceInfo(graphnm, tracenm, 0)
//		string offsetstr
//		variable start //Start index number value in Traceinfo string
//		variable finish //Ending index number value in Traceinfo string
//		variable len=strlen(tinfo)
//		variable i=0
//		variable j=0
//		variable cnt=0
//		i=len
//		do //advance backwards to a given ";" in the string
//			i-=1
//			if(char2num(tinfo[i])==char2num(";"))
//				cnt+=1
//			endif
//		while(cnt<2)
//		do //find ",", then find "}" -- define start and finish for x offset value in info string
//			if(char2num(tinfo[i])==char2num("}"))
//				finish=i-1
//			endif
//			i-=1
//		while(char2num(tinfo[i])!=char2num(","))
//		start=i+1
//		len=finish-start
//		//build new string containing offset number value
//		i=start
//		do
//			offsetstr[j]=tinfo[i]
//			i+=1
//			j+=1
//		while(j<=len)
	
	execute "offsetvarw="+stringbykey("offset(x)",traceinfo(graphnm,tracenm,0),"=")
	
	if(stringmatch(xy,"x"))
		n=offsetvarw[0]
		killwaves offsetvarw
		return n //str2num(stringfromlist(1,stringbykey("offset(x)",traceinfo(graphnm,tracenm,0),"="),"{"))
	elseif(stringmatch(xy,"y"))
		n=offsetvarw[1]
		killwaves offsetvarw
		return n //str2num(stringfromlist(1,stringbykey("offset(x)",traceinfo(graphnm,tracenm,0),"="),","))
	else
		Print "ERROR: traceoffset -- Incorrect axis referenced"
		return NaN
	endif
end

//****************************************************************
//****************************************************************
//****************************************************************

Function threshCheck()
	WAVE ndfchart = root:NQ_FBNDF
	WAVE ndfvoltage = root:ndfvoltage
	variable tstep = 1/round(1/deltax(NQ_Imem))
	variable/g fbthresh=0.5 //was -5.9
	variable/g bbthresh=0.1 //-6.85  //was -6.9
	variable/g ndthreshscale
	variable/g NQGainAdjust=1
	
	Make/O/N=1000/O NQ_FBNDF_Hist
	WAVE ndfhist = root:NQ_FBNDF_Hist
	Histogram/B=1 ndfchart,ndfhist
	duplicate/O ndfvoltage ndfvoltage2
	WAVE ndfvoltage2=root:ndfvoltage2
	wavestats/q ndfhist;ndfvoltage2=V_max
	ndfvoltage2=4000;
	Make/O/T/N=28 ndflabels
	
	dowindow/k thresholds
	
	//Make threshold panel
	newpanel/w=(0,0,1130,810)/n=thresholds
	
	//SETUP NDF VOLTAGE THRESHOLDS
	display/n=NDFVoltageCheck/W=(10,10,610,800)/HOST=thresholds ndfchart
		ModifyGraph rgb(NQ_FBNDF)=(0,0,0)

	string wavenm

	variable i=0
	variable j=0
	for(i=0;i<=81;i+=3)
		wavenm = "NDF"+num2str(i)+"v"
		make/o/n=2 $wavenm
		WAVE zerowave = root:$wavenm
		SetScale/P x 0, numpnts(ndfchart)*tstep, "s", zerowave
		zerowave = ndfvoltage[j]
		j+=1
		appendtograph/W=thresholds#NDFVoltageCheck zerowave
	endfor
	SetAxis/W=thresholds#NDFVoltageCheck left 0,wavemax(ndfchart)*1.1
	ModifyGraph quickdrag=1
	ModifyGraph quickdrag(NQ_FBNDF)=0
	
	//SETUP PDIODE THRESHOLDS (FBTHRESH AND BBTHRESH)
	Make/o/n=(3*numpnts(pdiodechart)) fbthreshW, bbthreshW
//	duplicate/o pdiodechart fbthreshW bbthreshW
	fbthreshW=0
	bbthreshW=0
	setscale/P x, -numpnts(pdiodechart)*deltax(pdiodechart), deltax(pdiodechart), "s", fbthreshW, bbthreshW
	display/n=beamthresh/w=(620,10,1120,300)/HOST=thresholds pdiodechart fbthreshW bbthreshW
		SetAxis/W=thresholds#beamthresh bottom 0,numpnts(pdiodechart)*deltax(pdiodechart)
		GetAxis/W=thresholds#beamthresh left
		variable axisrange=V_max-V_min
		ModifyGraph/W=thresholds#beamthresh rgb(fbthreshW)=(0,65535,0),offset(fbthreshW)={0,fbthresh*axisrange+V_min},lsize(fbthreshW)=5,quickdrag(fbthreshW)=1,live(fbthreshW)=1
		ModifyGraph/W=thresholds#beamthresh rgb(bbthreshW)=(0,0,65535),offset(bbthreshW)={0,bbthresh*axisrange+V_min},lsize(bbthreshW)=5,quickdrag(bbthreshW)=1,live(bbthreshW)=1
//		ModifyGraph/W=thresholds#beamthresh margin(right)=108
		ModifyGraph/W=thresholds#beamthresh mirror=2
		ModifyGraph/W=thresholds#beamthresh noLabel(bottom)=1
		ModifyGraph/W=thresholds#beamthresh wbRGB=(60000,60000,60000)
		Legend/E/X=0/Y=0/C/N=Legend/J/A=RT "\\s(fbthreshW) Front Beam\r\\s(bbthreshW) Back Beam"
		TextBox/C/N=title/A=LT/E=2/X=5/Y=3 "\\f01Set Photodiode Thresholds"
	
	doupdate/W=thresholds
		
//	make/o/n=21 tickpos
//	tickpos={-0.02,-0.018,-0.016,-0.014,-0.012,-0.01,-0.008,-0.006,-0.004,-0.002,0,0.002,0.004,0.006,0.008,0.01,0.012,0.014,0.016,0.018,0.02}
//	make/o/t/n=21 tickname
//	tickname={"-0.02","","","","","-0.01","","","","","0","","","","","0.01","","","","","0.02"}
	Slider ndthresh, win=thresholds, variable=ndthreshscale, value=0, vert=1, live=1, size={30,360}, pos={630,370}, proc=NDthreshAlign, limits={-0.2,0.02,0}, ticks=20, fsize=9, side=1//, userTicks={tickpos,tickname}
	PopupMenu GainAdjust win=thresholds, value="0.25;0.5;1;2;4", size={50,15}, pos={700,450}, proc=GainAdjust, title="DAQ Gain Adjustment", mode=3
	
	//SAVE BUTTONS
	Button threshaccept, win=thresholds, size={100,50},pos={630,310},proc=threshaccept,title="Accept",fColor=(50000,50000,50000)
	Button threshdefault, win=thresholds, size={100,50},pos={740,310},proc=threshdefault,title="Reset",fColor=(50000,50000,50000)
	
	pauseforuser thresholds //clicking buttons on graph
	
end

Function threshCheckB()
	WAVE ndfchart = root:NQ_BBNDF
	WAVE ndfvoltage = root:bbndfvoltage
	variable tstep = 1/round(1/deltax(NQ_Imem))
	variable/g fbthresh=-6.3 //was -5.9
	variable/g bbthresh=-6.7 //-6.85  //was -6.9
	variable/g ndthreshscale
	variable/g NQGainAdjust=1
	
	dowindow/k thresholds
	
	//Make threshold panel
	newpanel/w=(0,0,1130,810)/n=thresholds
	
	//SETUP NDF VOLTAGE THRESHOLDS
	display/n=NDFVoltageCheck/W=(10,10,610,800)/HOST=thresholds ndfchart
		ModifyGraph rgb(NQ_BBNDF)=(0,0,0)

	string wavenm

	variable i=0
	variable j=0
	for(i=0;i<=81;i+=3)
		wavenm = "NDF"+num2str(i)+"v"
		make/o/n=2 $wavenm
		WAVE zerowave = root:$wavenm
		SetScale/P x 0, numpnts(ndfchart)*tstep, "s", zerowave
		zerowave = ndfvoltage[j]
		j+=1
		appendtograph/W=thresholds#NDFVoltageCheck zerowave
	endfor
	SetAxis/W=thresholds#NDFVoltageCheck left 0,wavemax(ndfchart)*1.1
	ModifyGraph quickdrag=1
	ModifyGraph quickdrag(NQ_FBNDF)=0
	
	//SETUP PDIODE THRESHOLDS (FBTHRESH AND BBTHRESH)
	Make/o/n=(3*numpnts(pdiodechart)) fbthreshW, bbthreshW
//	duplicate/o pdiodechart fbthreshW bbthreshW
	fbthreshW=0
	bbthreshW=0
	setscale/P x, -numpnts(pdiodechart)*deltax(pdiodechart), deltax(pdiodechart), "s", fbthreshW, bbthreshW
	display/n=beamthresh/w=(620,10,1120,300)/HOST=thresholds pdiodechart fbthreshW bbthreshW
		SetAxis/W=thresholds#beamthresh bottom 0,numpnts(pdiodechart)*deltax(pdiodechart)
		ModifyGraph/W=thresholds#beamthresh rgb(fbthreshW)=(0,65535,0),offset(fbthreshW)={0,fbthresh},lsize(fbthreshW)=5,quickdrag(fbthreshW)=1,live(fbthreshW)=1
		ModifyGraph/W=thresholds#beamthresh rgb(bbthreshW)=(0,0,65535),offset(bbthreshW)={0,bbthresh},lsize(bbthreshW)=5,quickdrag(bbthreshW)=1,live(bbthreshW)=1
//		ModifyGraph/W=thresholds#beamthresh margin(right)=108
		ModifyGraph/W=thresholds#beamthresh mirror=2
		ModifyGraph/W=thresholds#beamthresh noLabel(bottom)=1
		ModifyGraph/W=thresholds#beamthresh wbRGB=(60000,60000,60000)
		Legend/E/X=0/Y=0/C/N=Legend/J/A=RT "\\s(fbthreshW) Front Beam\r\\s(bbthreshW) Back Beam"
		TextBox/C/N=title/A=LT/E=2/X=5/Y=3 "\\f01Set Photodiode Thresholds"
	
	doupdate/W=thresholds
		
//	make/o/n=21 tickpos
//	tickpos={-0.02,-0.018,-0.016,-0.014,-0.012,-0.01,-0.008,-0.006,-0.004,-0.002,0,0.002,0.004,0.006,0.008,0.01,0.012,0.014,0.016,0.018,0.02}
//	make/o/t/n=21 tickname
//	tickname={"-0.02","","","","","-0.01","","","","","0","","","","","0.01","","","","","0.02"}
	Slider ndthresh, win=thresholds, variable=ndthreshscale, value=0, vert=1, live=1, size={30,420}, pos={630,370}, proc=NDthreshAlignB, limits={-0.2,0.5,0}, ticks=20, fsize=9, side=1//, userTicks={tickpos,tickname}
	PopupMenu GainAdjust win=thresholds, value="0.25;0.5;1;2;4", size={50,15}, pos={700,450}, proc=GainAdjust, title="DAQ Gain Adjustment", mode=3
	
	//SAVE BUTTONS
	Button threshaccept, win=thresholds, size={100,50},pos={630,310},proc=threshacceptB,title="Accept",fColor=(50000,50000,50000)
	Button threshdefault, win=thresholds, size={100,50},pos={740,310},proc=threshdefaultB,title="Reset",fColor=(50000,50000,50000)
	
	pauseforuser thresholds //clicking buttons on graph
	
end

Function GainAdjust(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	string popStr
	
	NVAR NQGainAdjust=root:NQGainAdjust
	
	WAVE Imem=root:NQ_Imem
	WAVE Pdiode=root:NQ_PDIODE
	WAVE Temp=root:NQ_Temp
	WAVE FBNDF=root:NQ_FBNDF
	WAVE BBNDF=root:NQ_BBNDF
	
	WAVE imemchart=root:imemchart
	WAVE pdiodechart=root:pdiodechart
	
	Imem/=NQGainAdjust
	Imem*=str2num(popStr)
	Pdiode/=NQGainAdjust
	Pdiode*=str2num(popStr)
	Temp/=NQGainAdjust
	Temp*=str2num(popStr)
	FBNDF/=NQGainAdjust
	FBNDF*=str2num(popStr)
	BBNDF/=NQGainAdjust
	BBNDF*=str2num(popStr)
	
	imemchart/=NQGainAdjust
	imemchart*=str2num(popStr)
	pdiodechart/=NQGainAdjust
	pdiodechart*=str2num(popStr)
	
	NQGainAdjust=str2num(popStr)
end

Function NDthreshAlign(scalename,value,event) : ButtonControl
	string scalename
	variable event
	variable value
	NVAR ndthreshscale=root:ndthreshscale
	
	WAVE ndfvoltage = root:ndfvoltage

	string wavenm

	variable i=0
	variable j=0
	for(i=0;i<=81;i+=3)
		wavenm = "NDF"+num2str(i)+"v"
		WAVE zerowave = root:$wavenm
		zerowave = ndfvoltage[j]*(ndthreshscale+1)
		j+=1
	endfor
end

Function NDthreshAlignB(scalename,value,event) : ButtonControl
	string scalename
	variable event
	variable value
	NVAR ndthreshscale=root:ndthreshscale
	
	WAVE ndfvoltage = root:bbndfvoltage

	string wavenm

	variable i=0
	variable j=0
	for(i=0;i<=81;i+=3)
		wavenm = "NDF"+num2str(i)+"v"
		WAVE zerowave = root:$wavenm
		zerowave = ndfvoltage[j]*(ndthreshscale+1)
		j+=1
	endfor
end

Function threshaccept(buttonname) : ButtonControl
	string buttonname
	
	NVAR ndthreshscale=ndthreshscale
	if(ndthreshscale)
		print "     Scaling all ND voltage values by: "+num2str(ndthreshscale)
	endif

	WAVE ndfvoltage = root:ndfvoltage
	variable i=0
	variable j=0
	for(i=0;i<=81;i+=3)
		//trace = trace+offsetvalue
		WAVE zerowave = root:$"NDF"+num2str(i)+"v"
		if(GetTraceOffset("thresholds#NDFVoltageCheck","NDF"+num2str(i)+"v","y"))
			print "     Unique voltage value set for ND"+num2str(i)
		endif
		ndfvoltage[j]= mean(zerowave) + GetTraceOffset("thresholds#NDFVoltageCheck","NDF"+num2str(i)+"v","y")
		j+=1
//		appendtograph/W=NDFVoltageCheck zerowave
		killwaves/Z zerowave		
	endfor
	
	NVAR fbthresh=fbthresh
	NVAR bbthresh=bbthresh
	if(round(1000*GetTraceOffset("thresholds#beamthresh","fbthreshW","y"))/1000-fbthresh || round(1000*GetTraceOffset("thresholds#beamthresh","bbthreshW","y"))/1000-bbthresh)	
		fbthresh=GetTraceOffset("thresholds#beamthresh","fbthreshW","y") //str2num(stringfromlist(1,stringbykey("offset(x)",traceinfo("thresh","fbthreshW",0),"="),","))
		bbthresh=GetTraceOffset("thresholds#beamthresh","bbthreshW","y") //str2num(stringfromlist(1,stringbykey("offset(x)",traceinfo("thresh","bbthreshW",0),"="),","))
		print "     Using user-defined pdiode threshold values..."
	endif
	
	print "     FB Threshold Value: "+num2str(fbthresh)
	print "     BB Threshold Value: "+num2str(bbthresh)
	
	dowindow/k thresholds
End

Function threshacceptB(buttonname) : ButtonControl
	string buttonname
	
	NVAR ndthreshscale=ndthreshscale
	if(ndthreshscale)
		print "     Scaling all ND voltage values by: "+num2str(ndthreshscale)
	endif

	WAVE ndfvoltage = root:bbndfvoltage
	variable i=0
	variable j=0
	for(i=0;i<=81;i+=3)
		//trace = trace+offsetvalue
		WAVE zerowave = root:$"NDF"+num2str(i)+"v"
		if(GetTraceOffset("thresholds#NDFVoltageCheck","NDF"+num2str(i)+"v","y"))
			print "     Unique voltage value set for ND"+num2str(i)
		endif
		ndfvoltage[j]= mean(zerowave) + GetTraceOffset("thresholds#NDFVoltageCheck","NDF"+num2str(i)+"v","y")
		j+=1
//		appendtograph/W=NDFVoltageCheck zerowave
		killwaves/Z zerowave		
	endfor
	
	NVAR fbthresh=fbthresh
	NVAR bbthresh=bbthresh
	if(round(1000*GetTraceOffset("thresholds#beamthresh","fbthreshW","y"))/1000-fbthresh || round(1000*GetTraceOffset("thresholds#beamthresh","bbthreshW","y"))/1000-bbthresh)	
		fbthresh=GetTraceOffset("thresholds#beamthresh","fbthreshW","y") //str2num(stringfromlist(1,stringbykey("offset(x)",traceinfo("thresh","fbthreshW",0),"="),","))
		bbthresh=GetTraceOffset("thresholds#beamthresh","bbthreshW","y") //str2num(stringfromlist(1,stringbykey("offset(x)",traceinfo("thresh","bbthreshW",0),"="),","))
		print "     Using user-defined pdiode threshold values..."
	endif
	
	print "     FB Threshold Value: "+num2str(fbthresh)
	print "     BB Threshold Value: "+num2str(bbthresh)
	
	dowindow/k thresholds
End

Function threshdefault(buttonname) : ButtonControl
	string buttonname
	variable/g fbthresh
	variable/g bbthresh
	NVAR ndthreshscale=root:ndthreshscale
	WAVE ndfvoltage = root:ndfvoltage
		
	ModifyGraph/W=thresholds#beamthresh offset(fbthreshW)={0,fbthresh}
	ModifyGraph/W=thresholds#beamthresh offset(bbthreshW)={0,bbthresh}
	ModifyGraph/W=thresholds#beamthresh offset(pdiodechart)={0,0}
	ndthreshscale=0
	Slider ndthresh, value=0
	
	string wavenm

	variable i=0
	variable j=0
	for(i=0;i<=81;i+=3)
		//set trace value to default
		wavenm = "NDF"+num2str(i)+"v"
		WAVE zerowave = root:$wavenm
		zerowave = ndfvoltage[j]*(ndthreshscale+1)
		//set trace offset to 0
		ModifyGraph/W=thresholds#NDFVoltageCheck offset($"NDF"+num2str(i)+"v")={0,0}
		j+=1
	endfor
	
	doupdate/W=thresholds#NDFVoltageCheck
	doupdate/W=thresholds#beamthresh
	
End

Function threshdefaultB(buttonname) : ButtonControl
	string buttonname
	variable/g fbthresh=0.5 //was -5.9
	variable/g bbthresh=0.1 //-6.85  //was -6.9
	NVAR ndthreshscale=root:ndthreshscale
	WAVE ndfvoltage = root:bbndfvoltage
		
	GetAxis/W=thresholds#beamthresh left
	variable axisrange=V_max-V_min
	
	ModifyGraph/W=thresholds#beamthresh offset(fbthreshW)={0,fbthresh*axisrange+V_min}
	ModifyGraph/W=thresholds#beamthresh offset(bbthreshW)={0,bbthresh*axisrange+V_min}
	ModifyGraph/W=thresholds#beamthresh offset(pdiodechart)={0,0}
	ndthreshscale=0
	Slider ndthresh, value=0
	
	string wavenm

	variable i=0
	variable j=0
	for(i=0;i<=81;i+=3)
		//set trace value to default
		wavenm = "NDF"+num2str(i)+"v"
		WAVE zerowave = root:$wavenm
		zerowave = ndfvoltage[j]*(ndthreshscale+1)
		//set trace offset to 0
		ModifyGraph/W=thresholds#NDFVoltageCheck offset($"NDF"+num2str(i)+"v")={0,0}
		j+=1
	endfor
	
	doupdate/W=thresholds#NDFVoltageCheck
	doupdate/W=thresholds#beamthresh
	
End
