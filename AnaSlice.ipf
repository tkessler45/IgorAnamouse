#pragma rtGlobals=1		// Use modern global access method.

//Menu "|| AnaSlice ||"
//	"Load Axon File", AnaSlice()
//	submenu "    Components"
//		"Import ABF", ImportABF()
//		"Concatenate Epochs", concatEpochs()
//		"Cut Waves", cutWaves(2,1,5)
//		"Parse Waves into Lists", parsePdiode()
//		"Average Everything", avgAll()
//	end
//	"Display \"Resp\" Averages", displayAverages("Resp")
//	"Display \"Stim\" Averages", displayAverages("Stim")
//	"Sensitivity Curve", Sensitivity()
//End

Function AnaSlice()
	//Globals
	variable/g flashdur=10 //keep some positive value here to avoid endless loops
	variable/g radioval
	variable/g baselen=0.5
	variable/g swlen=1.5
	variable/g binpercentage=.125
	variable/g stimchannel=2
	variable/g loadnumber
	variable/g pdiodeoffset=0
	variable i
	variable wmax
	
	dowindow/k Console
	
	if(!ImportABF())
		ConcatEpochs() //replace by default...change with variable...
	
		NVAR NumChannels=root:NumChannels
		make/o/T/n=16 ChanNames
		ChanNames={"Resp","","Stim","","","","","","","","","","","","",""}
		
		duplicate/o root:Channel0 threshold
		threshold=0
//		wmax=wavemax(root:Channel2) //stim channel
//		threshold=round(wmax/100)

		//Panel for input values...
		execute "Console()"
		
		for(i=0;i<16;i+=1)
			if(i>=numchannels)
				CheckBox $("check"+num2str(i)),disable=2
				SetVariable $("SetChan"+num2str(i)),disable=2
			else
				CheckBox $("check"+num2str(i)),disable=0
				SetVariable $("SetChan"+num2str(i)),disable=0
			endif
		endfor
		
		loadnumber+=1
	else
		Print "Import failed!"
	endif
end

Window Console() : Panel
	variable i
	variable/g numChannels
	variable/g radioval
	variable/g loadnumber
	
	i=0
	do
		variable $("checkval"+num2str(i))
		if(i==radioval && loadnumber)
			$("checkval"+num2str(i))=1
		else
			$("checkval"+num2str(i))=0
		endif
		i+=1
	while(i<16)

	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(358,390,934,843)
	ModifyPanel frameStyle=1
//	ShowTools/A
	SetDrawLayer UserBack
	DrawText 36,20,"Channel Setup"
	SetDrawEnv fsize= 9
	DrawText 532,352,"Log"
	SetDrawEnv fsize= 9,textxjust= 2
	DrawText 549,375,"Subtract Baseline"
	GroupBox group0,pos={6,23},size={146,315}
	SetVariable SetChan0,pos={11,30},size={113,15},bodyWidth=60,title="Channel _0"
	SetVariable SetChan0,value= ChanNames[0]
	SetVariable SetChan1,pos={11,49},size={113,15},bodyWidth=60,title="Channel _1"
	SetVariable SetChan1,value= ChanNames[1]
	SetVariable SetChan2,pos={11,68},size={113,15},bodyWidth=60,title="Channel _2"
	SetVariable SetChan2,value= ChanNames[2]
	SetVariable SetChan3,pos={11,87},size={113,15},bodyWidth=60,title="Channel _3"
	SetVariable SetChan3,value= ChanNames[3]
	SetVariable SetChan4,pos={11,106},size={113,15},bodyWidth=60,title="Channel _4"
	SetVariable SetChan4,value= ChanNames[4]
	SetVariable SetChan5,pos={11,125},size={113,15},bodyWidth=60,title="Channel _5"
	SetVariable SetChan5,value= ChanNames[5]
	SetVariable SetChan6,pos={11,144},size={113,15},bodyWidth=60,title="Channel _6"
	SetVariable SetChan6,value= ChanNames[6]
	SetVariable SetChan7,pos={11,163},size={113,15},bodyWidth=60,title="Channel _7"
	SetVariable SetChan7,value= ChanNames[7]
	SetVariable SetChan8,pos={11,182},size={113,15},bodyWidth=60,title="Channel _8"
	SetVariable SetChan8,value= ChanNames[8]
	SetVariable SetChan9,pos={11,201},size={113,15},bodyWidth=60,title="Channel _9"
	SetVariable SetChan9,font="Geneva",value= ChanNames[9]
	SetVariable SetChan10,pos={11,220},size={113,15},bodyWidth=60,title="Channel 10"
	SetVariable SetChan10,font="Geneva",value= ChanNames[10]
	SetVariable SetChan11,pos={11,239},size={113,15},bodyWidth=60,title="Channel 11"
	SetVariable SetChan11,font="Geneva",value= ChanNames[11]
	SetVariable SetChan12,pos={11,258},size={113,15},bodyWidth=60,title="Channel 12"
	SetVariable SetChan12,font="Geneva",value= ChanNames[12]
	SetVariable SetChan13,pos={11,277},size={113,15},bodyWidth=60,title="Channel 13"
	SetVariable SetChan13,font="Geneva",value= ChanNames[13]
	SetVariable SetChan14,pos={11,296},size={113,15},bodyWidth=60,title="Channel 14"
	SetVariable SetChan14,font="Geneva",value= ChanNames[14]
	SetVariable SetChan15,pos={11,315},size={113,15},bodyWidth=60,title="Channel 15"
	SetVariable SetChan15,font="Geneva",value= ChanNames[15]
	CheckBox check0,pos={130,29},size={16,14},title="",value= checkval0,mode=1,proc=switchRadio
	CheckBox check1,pos={130,49},size={16,14},title="",value= checkval1,mode=1,proc=switchRadio
	CheckBox check2,pos={130,68},size={16,14},title="",value= checkval2,mode=1,proc=switchRadio
	CheckBox check3,pos={130,87},size={16,14},title="",value= checkval3,mode=1,proc=switchRadio
	CheckBox check4,pos={130,106},size={16,14},title="",value= checkval4,mode=1,proc=switchRadio
	CheckBox check5,pos={130,125},size={16,14},title="",value= checkval5,mode=1,proc=switchRadio
	CheckBox check6,pos={130,144},size={16,14},title="",value= checkval6,mode=1,proc=switchRadio
	CheckBox check7,pos={130,163},size={16,14},title="",value= checkval7,mode=1,proc=switchRadio
	CheckBox check8,pos={130,182},size={16,14},title="",value= checkval8,mode=1,proc=switchRadio
	CheckBox check9,pos={130,201},size={16,14},title="",value= checkval9,mode=1,proc=switchRadio
	CheckBox check10,pos={130,220},size={16,14},title="",value= checkval10,mode=1,proc=switchRadio
	CheckBox check11,pos={130,239},size={16,14},title="",value= checkval11,mode=1,proc=switchRadio
	CheckBox check12,pos={130,258},size={16,14},title="",value= checkval12,mode=1,proc=switchRadio
	CheckBox check13,pos={130,277},size={16,14},title="",value= checkval13,mode=1,proc=switchRadio
	CheckBox check14,pos={130,296},size={16,14},title="",value= checkval14,mode=1,proc=switchRadio
	CheckBox check15,pos={130,315},size={16,14},title="",value= checkval15,mode=1,proc=switchRadio
	Button Go,pos={477,387},size={87,54},title="Go!",proc=go,fColor=(49151,65535,49151)
	SetVariable setvar0,pos={53,354},size={115,15},bodyWidth=60,title="Baseline (s)",limits={0,inf,0.5}
	SetVariable setvar0,value= baselen
	SetVariable setvar1,pos={27,376},size={141,15},bodyWidth=60,title="Sweep Length (s)",limits={0,inf,0.5}
	SetVariable setvar1,value= swlen
	SetVariable setvar2,pos={9,398},size={159,15},bodyWidth=60,title="Flash Duration (msec)",limits={1,100,1}
	SetVariable setvar2,value= flashdur
	SetVariable setvar3,pos={174,354},size={115,15},bodyWidth=60,title="rate (msec)",limits={0,inf,0.005}
	SetVariable setvar3,value= SampleInterval
	SetVariable setvar4,pos={173,376},size={116,15},bodyWidth=60,title="bin size (%)",limits={0.015625,10,0.015625}
	SetVariable setvar4,value= binpercentage
	Button Up,pos={319,341},size={49,24},title="Up",proc=threshup
	Button Down,pos={375,341},size={49,24},title="Down",proc=threshdown
	CheckBox logstatus,pos={551,340},size={16,14},title="",value= 0,proc=changegraph
	CheckBox basesubtract,pos={551,363},size={16,14},title="",value= 1
	Button load,pos={407,410},size={56,31},proc=loadnew,title="Load"
	Display/W=(163,24,564,335)/HOST=#  
	i=0
	do
		Appendtograph $("Channel"+num2str(i))
//		ModifyGraph hideTrace($("Channel"+num2str(i)))=1
		i+=1
	while(i<numChannels)
//	ModifyGraph hideTrace(Channel2)=0 //default "stim" channel
	Appendtograph threshold
	ModifyGraph hideTrace=1
	ModifyGraph frameStyle=5
	ModifyGraph lSize(threshold)=2
	ModifyGraph rgb(threshold)=(0,0,0)
//	ModifyGraph log(left)=1
	RenameWindow #,G0
	SetActiveSubwindow ##
	
//	if(loadnumber)
		i=0
		do
			if($("checkval"+num2str(i)))
				switchRadio("check"+num2str(i),$("checkval"+num2str(i)))
			endif
			i+=1
		while(i<16)
//	endif
EndMacro

Function loadnew(ctrlName) : ButtonControl
	String ctrlName
	AnaSlice()
end

Function changegraph(ctrlName, value) : ButtonControl
	string ctrlName
	variable value
	NVAR radioval=root:radioval
	strswitch (ctrlName)
		case "logstatus":
			if(value)
	//			ControlInfo/W=Console ctrlName
				wavestats/q root:$("Channel"+num2str(radioval))
				SetAxis/W=Console#G0 left V_Avg,*
			else
				SetAxis/W=Console#G0 left *,*
			endif
			ModifyGraph/W=Console#G0 log(left)=value
			doupdate
			break
	endswitch
end

Function go(ctrlName) : ButtonControl
	String ctrlName
	NVAR baselen=root:baselen
	NVAR swlen=root:swlen
	NVAR stimchannel=root:stimchannel
	
	clearwaves()
	cutWaves(stimchannel,baselen,swlen)
	parsePdiode()
	avgAll()
	displayAverages("Resp")
	Execute("AnalysisPanel()")
end

Function clearwaves()
	NVAR numchannels=root:numchannels
	WAVE/T vgrouplist=root:vgrouplist
	WAVE/T channames=root:channames
	NVAR levelindex=root:levelindex 

	variable i
	variable j
	variable k
	
	//clear relevant windows so waves can be killed
	string wlist=winlist("*",";","WIN:7")
	for(i=0;i<itemsinlist(wlist,";");i+=1)
		doWindow/k $(stringfromlist(i,wlist,";")) //vgrouptable
	endfor
	
	//iterate through channames list
	for(i=0;i<numchannels;i+=1)
		//use vgrouplist to remove group and _avg waves
		for(j=0;j<numpnts(vgrouplist);j+=1)
			killwaves/Z root:$(channames[i]+vgrouplist[j]+"_avg"), root:$(vgrouplist[j])
		endfor
		//use levelindex to remove individual waves
		for(k=0;k<levelindex;k+=1)
			killwaves/Z root:$(channames[i]+num2str(k))
		endfor
	endfor
end

Function threshup(ctrlName) : ButtonControl
	String ctrlName
	WAVE thresh=root:threshold
	variable level=thresh[0]
	thresh+=10^(log(level/10))
end

Function threshdown(ctrlName) : ButtonControl
	String ctrlName
	WAVE thresh=root:threshold
	variable level=thresh[0]
	thresh-=10^(log(level/10))
end

Function switchRadio(name,value)
	String name
	Variable value
	NVAR radioval=root:radioval
	NVAR stimchannel=root:stimchannel
	WAVE threshold=root:threshold
	strswitch (name)
		case "check0":
			radioval=0
			stimchannel=0
			wavestats/q Channel0
			threshold=round((V_max-V_min)/20+V_min)
			ModifyGraph/W=Console#G0 hideTrace=1
			ModifyGraph/W=Console#G0 hideTrace(Channel0)=0,hideTrace(threshold)=0
			SetActiveSubwindow Console
			doupdate
			break
		case "check1":
			radioval=1
			stimchannel=1
			wavestats/q Channel1
			threshold=round((V_max-V_min)/20+V_min)
			ModifyGraph/W=Console#G0 hideTrace=1
			ModifyGraph/W=Console#G0 hideTrace(Channel1)=0,hideTrace(threshold)=0
			SetActiveSubwindow Console
			doupdate
			break
		case "check2":
			radioval=2
			stimchannel=2
			wavestats/q Channel2
			threshold=V_max/20 //removed V_min because trace is centered around 0, and removed rounding to contend with small numbers...
			ModifyGraph/W=Console#G0 hideTrace=1
			ModifyGraph/W=Console#G0 hideTrace(Channel2)=0,hideTrace(threshold)=0
			SetActiveSubwindow Console
			doupdate
			break
		case "check3":
			radioval=3
			stimchannel=3
			wavestats/q Channel3
			threshold=round((V_max-V_min)/20+V_min)
			ModifyGraph/W=Console#G0 hideTrace=1
			ModifyGraph/W=Console#G0 hideTrace(Channel3)=0,hideTrace(threshold)=0
			SetActiveSubwindow Console
			doupdate
			break
		case "check4":
			radioval=4
			stimchannel=4
			wavestats/q Channel4
			threshold=round((V_max-V_min)/20+V_min)
			ModifyGraph/W=Console#G0 hideTrace=1
			ModifyGraph/W=Console#G0 hideTrace(Channel4)=0,hideTrace(threshold)=0
			SetActiveSubwindow Console
			doupdate
			break
		case "check5":
			radioval=5
			stimchannel=5
			wavestats/q Channel5
			threshold=round((V_max-V_min)/20+V_min)
			ModifyGraph/W=Console#G0 hideTrace=1
			ModifyGraph/W=Console#G0 hideTrace(Channel5)=0,hideTrace(threshold)=0
			SetActiveSubwindow Console
			doupdate
			break
		case "check6":
			radioval=6
			stimchannel=6
			wavestats/q Channel6
			threshold=round((V_max-V_min)/20+V_min)
			ModifyGraph/W=Console#G0 hideTrace=1
			ModifyGraph/W=Console#G0 hideTrace(Channel6)=0,hideTrace(threshold)=0
			SetActiveSubwindow Console
			break
		case "check7":
			radioval=7
			stimchannel=7
			wavestats/q Channel7
			threshold=round((V_max-V_min)/20+V_min)
			ModifyGraph/W=Console#G0 hideTrace=1
			ModifyGraph/W=Console#G0 hideTrace(Channel7)=0,hideTrace(threshold)=0
			SetActiveSubwindow Console
			break
		case "check8":
			radioval=8
			stimchannel=8
			wavestats/q Channel8
			threshold=round((V_max-V_min)/20+V_min)
			ModifyGraph/W=Console#G0 hideTrace=1
			ModifyGraph/W=Console#G0 hideTrace(Channel8)=0,hideTrace(threshold)=0
			SetActiveSubwindow Console
			break
		case "check9":
			radioval=9
			stimchannel=9
			wavestats/q Channel9
			threshold=round((V_max-V_min)/20+V_min)
			ModifyGraph/W=Console#G0 hideTrace=1
			ModifyGraph/W=Console#G0 hideTrace(Channel9)=0,hideTrace(threshold)=0
			SetActiveSubwindow Console
			break
		case "check10":
			radioval=10
			stimchannel=10
			wavestats/q Channel10
			threshold=round((V_max-V_min)/20+V_min)
			ModifyGraph/W=Console#G0 hideTrace=1
			ModifyGraph/W=Console#G0 hideTrace(Channel10)=0,hideTrace(threshold)=0
			SetActiveSubwindow Console
			break
		case "check11":
			radioval=11
			stimchannel=11
			wavestats/q Channel11
			threshold=round((V_max-V_min)/20+V_min)
			ModifyGraph/W=Console#G0 hideTrace=1
			ModifyGraph/W=Console#G0 hideTrace(Channel11)=0,hideTrace(threshold)=0
			SetActiveSubwindow Console
			break
		case "check12":
			radioval=12
			stimchannel=12
			wavestats/q Channel12
			threshold=round((V_max-V_min)/20+V_min)
			ModifyGraph/W=Console#G0 hideTrace=1
			ModifyGraph/W=Console#G0 hideTrace(Channel12)=0,hideTrace(threshold)=0
			SetActiveSubwindow Console
			break
		case "check13":
			radioval=13
			stimchannel=13
			wavestats/q Channel13
			threshold=round((V_max-V_min)/20+V_min)
			ModifyGraph/W=Console#G0 hideTrace=1
			ModifyGraph/W=Console#G0 hideTrace(Channel13)=0,hideTrace(threshold)=0
			SetActiveSubwindow Console
			break
		case "check14":
			radioval=14
			stimchannel=14
			wavestats/q Channel14
			threshold=round((V_max-V_min)/20+V_min)
			ModifyGraph/W=Console#G0 hideTrace=1
			ModifyGraph/W=Console#G0 hideTrace(Channel14)=0,hideTrace(threshold)=0
			SetActiveSubwindow Console
			break
		case "check15":
			radioval=15
			stimchannel=15
			wavestats/q Channel15
			threshold=round((V_max-V_min)/20+V_min)
			ModifyGraph/W=Console#G0 hideTrace=1
			ModifyGraph/W=Console#G0 hideTrace(Channel15)=0,hideTrace(threshold)=0
			SetActiveSubwindow Console
			break
	endswitch
	CheckBox check0,win=Console,value=radioval==0
	CheckBox check1,win=Console,value=radioval==1
	CheckBox check2,win=Console,value=radioval==2
	CheckBox check3,win=Console,value=radioval==3
	CheckBox check4,win=Console,value=radioval==4
	CheckBox check5,win=Console,value=radioval==5
	CheckBox check6,win=Console,value=radioval==6
	CheckBox check7,win=Console,value=radioval==7
	CheckBox check8,win=Console,value=radioval==8
	CheckBox check9,win=Console,value=radioval==9
	CheckBox check10,win=Console,value=radioval==10
	CheckBox check11,win=Console,value=radioval==11
	CheckBox check12,win=Console,value=radioval==12
	CheckBox check13,win=Console,value=radioval==13
	CheckBox check14,win=Console,value=radioval==14
	CheckBox check15,win=Console,value=radioval==15
end

Function ReadPClamp(filePath)
	string filePath
	//Import axon waves and save as WaveA0, Wave B0, WaveC0, etc... -- Wave "Channel" "Epoch"
	//print ntraces
	variable/g status
	variable localstatus
	execute("ABFFileClose")
	execute( "ABFFileOpen \""+filePath+"\",status")
	localstatus=status
	
	//read epochs
	
	Variable/g episodeCount
	Variable/g channelCount
	Variable currentEpisode
	Variable/g episodeSize
	Variable/g currentChannel
	
	Variable/g SamplesPerWave
	Variable/g SampleDuration
	Variable/g SampleInterval
	
//	make/T/o/n=26 alpha
//	alpha={"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}

	string alpha="ABCDEFGHIJKLMNOPQRSTUVWXYZ"

	execute("ABFEpisodeGetCount episodeCount, status")
	execute("ABFChannelGetCount channelCount, status")
	
	NVAR TotalNumWaves=root:TotalNumWaves
	TotalNumWaves=episodeCount*channelCount
	NVAR NumChannels = root:NumChannels
	NumChannels=channelCount
	
	Variable/g type
	Variable/g amp
	Variable/g ampInc
	Variable/g dur
	Variable/g durInc
	Variable/g actualAmp
	Variable/g actualDur
	Variable/g pulsePeriod
	Variable/g pulseWidth
	Variable/g holdingDur
	String/g errorString
	Variable/g sweepCount
	Variable/g sampleCount
	String/g technique
	
	variable i

	if (episodeCount > 0)
		if(channelCount > 0)
			for(currentEpisode = 0;currentEpisode<episodeCount;currentEpisode+=1)
				execute("ABFEpisodeSet "+num2str(currentEpisode)+", status")
				execute("ABFEpisodeGetSampleCount episodeSize, status")
			
				for(currentChannel = 0;currentChannel<channelCount;currentChannel+=1)
					Make/O/D/N=(episodeSize) $("Wave"+alpha[currentChannel]+num2str(currentEpisode))
					WAVE dataWave=root:$("Wave"+alpha[currentChannel]+num2str(currentEpisode))
					execute("ABFEpisodeRead "+num2str(currentChannel)+","+num2str(0)+","+num2str(episodeSize)+","+nameofWave(dataWave)+",status")
					
					execute("AcquireSweepGetTechnique technique, status")
					if(status)
						execute("ABFGetStatusText "+num2str(status)+", errorString")
						Print "Acquire Technique Status Error:", errorString
					else
						Print "Acquire Technique:", technique
					endif
					
					execute("AcquireSweepSet 0, status")
					if(status)
						execute("ABFGetStatusText "+num2str(status)+", errorString")
						Print "Acquire Sweep Set Status Error:", errorString
					endif
					
					execute("ABFEpisodeGetSampleCount sampleCount, status")
					Print "Sample Count:", sampleCount, status
					if(status)
						execute("ABFGetStatusText "+num2str(status)+", errorString")
						Print "Get Sample Count Status Error:", errorString
					endif
					
					execute("AcquireSweepGetCount sweepCount, status")
					Print "Sweep Count:", sweepCount
					
					
					execute("ABFHoldingInitialGetDuration 0, holdingDur, status")
					if(status) 
						execute("ABFGetStatusText "+num2str(status)+", errorString")
						Print "Holding Status Error:", errorString
					else
						Print "Holding Duration:", holdingDur, status
					endif
					
					for(i=0;i<10;i+=1)
						execute("ABFEpochGetPrototype "+num2str(currentChannel)+", "+num2str(i)+", type, amp, ampInc, dur, durInc, pulsePeriod, pulseWidth, status")
						
						if(type)
							//Print "Info: ", type, amp, ampInc, dur, durInc, pulsePeriod, pulseWidth
							//Print "Actual Amplitude:", amp+(currentEpisode-1)*ampInc
							//Print "Actual Duration:", dur+(currentEpisode-1)*durInc
						endif
					endfor
					
				endfor
				
				execute("ABFEpisodeGetSampleCount SamplesPerWave, status")
				execute("ABFEpisodeGetDuration SampleDuration, status")
//				SampleInterval=SampleDuration/SamplesPerWave
//				print "Sample Duration:",SampleDuration
//				print "Samples Per Wave:",SamplesPerWave

			endfor
		else
			print "The file has no channels"
			return 1
		endif
	else
		print "The file has no episodes"
		return 1
	endif
	execute("ABFFileClose")
	return 0
end

Function ImportABF()
	variable ntraces=0
	variable/g flasht, NumChannels, TotalNumWaves
	string/g filepath, CurrentFile
	//import the file
	SVAR filepath=root:filepath
	if(stringmatch("",filepath))
		//start in Igor folder
		GetFileFolderInfo/Q/Z=2/P=Igor "???" //Define SVAR "S_path" for axon binary file...
	else
		GetFileFolderInfo/Q/Z=2 "???"
	endif
	filepath=parsefilepath(1,S_path,":",1,0)
	
	//define ntraces (number of imported traces)
	//return 1
	if(!V_Flag)
		CurrentFile=S_path	
		if(!ReadPClamp(S_path)) //run axon import (will save waves as WaveA0, WaveB0, WaveC0, etc... -- Wave "Channel" "Epoch"
			ntraces=TotalNumWaves //Ana_ReadPClampData()
			print CurrentFile
			print "Number of traces:",ntraces
			return 0
		else
			Print "File could not be read"
			return 1		
		endif
	else
		Print "File does not exist"
		return 1
	endif

	//********************************
	// OLD IMPORT FUNCTIONS
	//********************************
//	variable ntraces=0
//	variable/g FileFormat,NumChannels,TotalNumWaves,SamplesPerWave,SampleInterval,yScalef //variables for "Ana_ReadPClampHeader"
//	variable/g AcqLength, DataPointer//additional variables used in "Ana_ReadPClampData()"
//	string/g CurrentFile,AcqMode,xLabel //strings for "Ana_ReadPClampHeader"
//	variable/g WaveBeg,WaveEnd,WaveInc,CurrentWave //additional variables for "Ana_ReadPClampData"
//	variable/g flasht
//	string/g filepath
	
//	variable scalingf=1/yScalef //scaling factor for waves....
	
//	CheckNMwave("FileScaleFactors", 10, 1)
//	CheckNMwave("MyScaleFactors", 10, 1)
//	CheckNMtwave("yLabel", 10, "") // increase size
	
//	SVAR filepath=root:filepath
//	if(stringmatch("",filepath))
//		//start in Igor folder
//		GetFileFolderInfo/Q/Z=2/P=Igor "???" //Define SVAR "S_path" for axon binary file...
//	else
//		GetFileFolderInfo/Q/Z=2 "???"
//	endif
//	filepath=parsefilepath(1,S_path,":",1,0)
//	if(!V_Flag)
//		CurrentFile=S_path	
//		if(Ana_ReadPClampHeader()) //run axon import (will save waves as WaveA0, WaveB0, WaveC0, etc...
//			ntraces=Ana_ReadPClampData()
//			print CurrentFile
//			return 0
//		else
//			return 1		
//		endif
//	else
//		return 1
//	endif
	//********************************
	// OLD IMPORT FUNCTIONS
	//********************************
End

Function calcNumEpochs()
	NVAR NumChannels=root:NumChannels
	NVAR TotalNumWaves=root:TotalNumWaves
	return TotalNumWaves/NumChannels
End

Function concatEpochs()
	NVAR NumChannels=root:NumChannels
	NVAR pdiodeOffset=root:pdiodeOffset //offset for photodiode levels so they can be viewed in the Console's logarithmic view

//	make/T/o/n=26 alpha
//	alpha={"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
	string alpha="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	
	variable NumEpochs=calcNumEpochs()
	string waveliststr
	variable i
	variable j
	variable wmin
	for(i=0;i<NumChannels;i+=1)
		for(j=0;j<NumEpochs;j+=1)
			WAVE wavenm=root:$("Wave"+alpha[i]+num2str(j))
			if(i==2) //channel 2 for Stim wave -- converts from V to mV
				wavestats/Q/R=[0,trunc(numpnts(wavenm)/64)] wavenm
				wavenm-=(V_avg-pdiodeOffset)
			endif
			if(j==0)
				waveliststr=nameofwave(wavenm)
			else
				waveliststr+=";"+nameofwave(wavenm)
			endif
		endfor
		waveliststr+=";"
		concatenate/KILL/NP/DL waveliststr, $("Channel"+num2str(i))
	endfor
End

Function cutWaves(indexChan,baselength,sweeplength)
	variable indexChan
	variable baselength
	variable sweeplength
	
	NVAR SampleInterval=root:SampleInterval //in msec
	NVAR pdiodeOffset=root:pdiodeOffset
	variable tstep=SampleInterval/1000 //in sec
	variable pdiodethresh=mean(root:threshold)
	variable scan=0
	variable basemean //for subtracting baseline
	variable/g pdiodeScale=0
	NVAR pdiodeScale=root:pdiodeScale
	
	NVAR flashdur=root:flashdur //msec
	variable flashpoints=flashdur/SampleInterval //flash length in points
	
	NVAR NumChannels=root:NumChannels
	variable i
	
	WAVE/T ChanNames=root:ChanNames
	
	WAVE pdiode=root:$("Channel"+num2str(indexChan))
	
	variable/g levelindex=1
	make/o/n=0 pdiodeLevels
	
	do
		findlevel/EDGE=1/P/Q/R=[scan+floor(flashpoints),numpnts(pdiode)] pdiode, pdiodethresh
		if(V_flag==0)
			scan=floor(V_LevelX) //V_LevelX is in points...
			
			if(baselength>pnt2x(pdiode, scan)/1000) //divide by 1000 to put in seconds--the same as baselength variable
				print "changing baseline from "+num2str(baselength)+" to "+num2str(pnt2x(pdiode, scan)/1000)
				baselength=pnt2x(pdiode, scan)/1000
				NVAR baselen=root:baselen
				baselen=baselength
			endif

			insertpoints numpnts(pdiodeLevels), 1, pdiodeLevels
			pdiodeLevels[levelindex-1]=mean(pdiode,pnt2x(pdiode,scan+1),pnt2x(pdiode,scan+floor(flashpoints)))
			
			//find scaling factor based on smallest pdiode size
			if(log(pdiodeLevels[levelindex-1])<pdiodeScale)
				pdiodeScale=trunc(log(pdiodeLevels[levelindex-1]))
			endif
		
			for(i=0;i<NumChannels;i+=1)
				if(!stringmatch("",ChanNames(i)))
					duplicate/o/r=[scan-baselength/tstep, scan-baselength/tstep+sweeplength/tstep] $("Channel"+num2str(i)) $(ChanNames[i]+num2str(levelindex))
					setscale/P x 0,tstep, "S", $(ChanNames[i]+num2str(levelindex))
					controlinfo/W=Console basesubtract
					if(V_Value)//if panel control is active (baseline subtract)
						WAVE chan=root:$(ChanNames[i]+num2str(levelindex))
						if(stringmatch("Resp",ChanNames(i)))
							wavestats/Q/R=[0,baselen/tstep] chan
//							basemean=mean(chan,x2pnt(chan,0),x2pnt(chan,baselength/tstep))
							chan-=V_avg //basemean
						endif
					endif
				endif
			endfor
			levelindex+=1
		else
			scan=numpnts(pdiode)
		endif
	while(scan<numpnts(pdiode))
	
	//if any pdiode is less than 1 in size, then multiply pdiode levels by the scaling factor to get integer numbers for Histogram
	if(pdiodeScale<0)
		print "Scaling all pdiode values by: "+num2str(100*10^abs(pdiodeScale))
		pdiodeLevels*=100*10^abs(pdiodeScale)
	endif
	pdiodeLevels=round(pdiodeLevels)-pdiodeoffset //reverting offset from displaying pdiode trace in the console, defined in concatEpochs function CAN REMOVE OFFSET!!!!
end

Function parsePdiode()
	WAVE pdiodeLevels=root:pdiodeLevels
	WAVE/T ChanNames=root:ChanNames
	NVAR baselen=root:baselen
	variable/g levelindex
	
	NVAR numChannels=root:NumChannels
	NVAR SampleInterval=root:SampleInterval //in msec
	variable tstep=SampleInterval/1000 //in sec
	
	NVAR flashdur=root:flashdur //msec
	variable flashpoints=flashdur/SampleInterval //flash length in points
	
	variable i
	variable j
	variable scan=0
	variable histsize=round(wavemax(root:pdiodeLevels)+1) //adding in 1 to accommodate voltages at the maximum...
	NVAR binpercentage=root:binpercentage
	variable binsize=round(histsize*binpercentage/100) //binpercentage was 1% of voltage range used for binning size (base this on variance of voltage inputs...)--now set in main setup panel
	variable pdiodelevel
	variable num=0
	NVAR pdiodeScale=root:pdiodeScale
	
	Make/N=(histsize)/O pdiodeHist
	Histogram/B={0,binsize,histsize} pdiodeLevels,pdiodeHist
//	Histogram/B=1 pdiodeLevels,pdiodeHist
	
	make/t/o/n=0 vgrouplist
	
	string namestr
	string prefix
	
	for(i=0;i<=numpnts(pdiodeHist);i+=1) //for each histogram point
		if(pdiodeHist[i]) // if the peak exists, make list wave for histogram value
//			if(round(pnt2x(pdiodeHist,i))<1)
//				namestr=num2istr(round(pnt2x(pdiodeHist,i))/1000)
//				prefix="mV"
//			else
				namestr=num2istr(round(pnt2x(pdiodeHist,i)))
				prefix="V"
//			endif
			make/o/n=0 $(prefix+namestr+"group") //make wave list
			//add group name to grouplist for average function
			insertpoints numpnts(vgrouplist),1,vgrouplist
			WAVE/T vgrouplist=root:vgrouplist
			WAVE/T vgroupname=root:$(prefix+namestr+"group")
			vgrouplist[i]=nameofwave(vgroupname)
			//iterate through pdiode waves
			for(j=0;j<levelindex-1;j+=1) //levelindex==numwaves
				//check max value of pdiode after baseline. If matches within "binsize" of histogram value, append to average wave and increase "num"
				pdiodelevel=mean($("Stim"+num2str(j+1)),pnt2x($("Stim"+num2str(j+1)),baselen/tstep+1),pnt2x($("Stim"+num2str(j+1)),baselen/tstep+floor(flashpoints)))
				//if any pdiode was found to be less than 1 in size, the pdiode was scaled, so we scale here as well for proper name match.
				if(pdiodeScale<0)
					pdiodelevel=round(pdiodeLevel*100*10^abs(pdiodeScale))
				endif
				if(pdiodelevel<=(pnt2x(pdiodeHist,i)+binsize) && pdiodelevel>=(pnt2x(pdiodeHist,i)-binsize))
					insertpoints numpnts($(prefix+namestr+"group")), 1, $(prefix+namestr+"group")
					WAVE list=$(prefix+namestr+"group")
					list[numpnts($(prefix+namestr+"group"))] = j+1
				endif
			endfor
		endif
	endfor
	
	//Make table -- done here so it can be sized properly
	string info
	variable vpad=3 //vertical padding for each table cell (Mac = 3)
	variable voffset=81 //vertical offset for tables--static components (Mac = 81)
	variable hoffset=80 //horizontal offset for tables--static components (Mac=80)
	dowindow/k vgrouptable
	for(i=0;i<=numpnts(vgrouplist);i+=1)
		if(!i)
			Edit/N=test $vgrouplist[i]
			info=TableInfo("test",0)
			Dowindow/K test
			Edit/N=vgrouptable/W=(0,0,numpnts(vgrouplist)*str2num(stringbykey("WIDTH",info))+hoffset,voffset+(vpad+str2num(stringbykey("SIZE",info)))*wavemax(pdiodeHist)) $vgrouplist[i]
		else
			appendtotable/W=vgrouptable $vgrouplist[i]
		endif
	endfor
end

Function avgAll()
	WAVE/T vgrouplist=root:vgrouplist
	WAVE/T chanNames=root:chanNames

	variable i
	variable j
	variable k
	NVAR numChannels=root:numChannels
	NVAR SampleInterval=root:SampleInterval //in msec
	NVAR baselen=root:baselen
	variable basemean
	variable tstep=SampleInterval/1000 //in sec
	
	for(j=0;j<numpnts(vgrouplist);j+=1)
		WAVE vgroup=root:$(vgrouplist[j])
		//for the vgroup input, iterate through channels
		for(i=0;i<numChannels;i+=1)
			//make average wave per channel
			if(!stringmatch("",ChanNames(i)))
				for(k=0;k<numpnts(vgroup);k+=1)
					if(!k)
						duplicate/o $(ChanNames[i]+num2str(vgroup[k])) $(chanNames[i]+nameofwave(vgroup)+"_avg")
						WAVE average=root:$(chanNames[i]+nameofwave(vgroup)+"_avg")
					else
						WAVE component=$(chanNames[i]+num2str(vgroup[k]))
						average+=component
					endif
				endfor
				if(k>1)
					average/=numpnts(vgroup)
//					print nameofwave(average)+" averaged with "+num2str(numpnts(vgroup))+" points."
				endif
				if(stringmatch("Resp",ChanNames(i)))
					Wavestats/Q/R=[0,baselen/tstep] average
//					basemean=mean(average,x2pnt(average,0),x2pnt(average,baselen/tstep))
					average-=V_avg//basemean
				endif
			endif
		endfor
	endfor
end

Function displayAverages(ChanName)
	string ChanName
	WAVE/T vgrouplist
	WAVE/T ChanNames
	NVAR numChannels=root:numChannels
	NVAR baselen=root:baselen
	variable i, j
	
	for(j=0;j<numChannels;j+=1)
		if(stringmatch(chanName, ChanNames[j]))
			for(i=0;i<numpnts(vgrouplist);i+=1)
				WAVE avg=root:$(ChanName+vgrouplist[i]+"_avg")
				if(!i)
					DoWindow/K $(ChanName+"_avg")
					Display/N=$(ChanName+"_avg") avg
				else
					Appendtograph/W=$(ChanName+"_avg") avg
					
				endif
			endfor
		endif
	endfor
	
	duplicate/o avg zero
	doupdate
	getaxis/w=Resp_avg/q left
	zero=nan
	zero[x2pnt(zero,baselen)-1,x2pnt(zero,baselen)+1]=0
	zero[x2pnt(zero,baselen)]=V_max-V_min
end

//*****************************************************************
//*****************************************************************
//*****************************************************************

Function Sensitivity()
	WAVE/T vgrouplist=root:vgrouplist
	variable i
	variable midpoint
	NVAR baselen=root:baselen
	
	String direction
	DoWindow AnalysisFunc
	if(V_Flag)
		controlinfo/w=AnalysisFunc direction
		direction=S_Value
	else
		prompt direction, "Direction", popup, "Up;Down"
		doprompt "Response Direction", direction
	endif
	
	make/o/n=(numpnts(vgrouplist)) maxlevels,maxvoltage
	for(i=0;i<numpnts(vgrouplist);i+=1)
		maxvoltage[i]=str2num(replacestring("group",replacestring("V",vgrouplist[i],""),""))
		WAVE data=root:$("Resp"+vgrouplist[i]+"_avg")
		if(stringmatch("Up",direction))
			if(stringmatch("zero",nameofwave(tracenametowaveref("Resp_avg","zero"))))
				midpoint=GetTraceOffset("Resp_avg","zero","x")+baselen
			else
				Findlevel/Q data wavemax(data)
				midpoint=V_LevelX
			endif
			maxlevels[i]=mean(data,midpoint-0.001,midpoint+0.001)//wavemax(data)
		else
			if(stringmatch("zero",nameofwave(tracenametowaveref("Resp_avg","zero"))))
				midpoint=GetTraceOffset("Resp_avg","zero","x")+baselen
			else
				Findlevel/Q data wavemin(data)
				midpoint=V_LevelX
			endif
			maxlevels[i]=mean(data,midpoint-0.001,midpoint+0.001)//wavemin(data)
		endif
	endfor
	
	variable maximum
	if(stringmatch("Up",direction))
		maximum=wavemax(maxlevels)
	else
		maximum=wavemin(maxlevels)
	endif
	maxlevels/=maximum
	
	GetWindow/Z Resp_avg wsize
	
	dowindow/k sensitivity0
	display/N=sensitivity/W=(V_right,V_top,2*V_right-V_left,V_bottom) maxlevels vs maxvoltage
	ModifyGraph mode=3,marker=19
	setaxis bottom 1,*
	setaxis left 0,1
	ModifyGraph log(bottom)=1
	
	//Sat_Exp
//	Make/D/N=2/O W_coef
//	W_coef[0] = {1,.1}
//	FuncFit/Q/X=1/H="10"/NTHR=0 satexp W_coef  maxlevels /X=maxvoltage /D 

	//Hill
	K0 = 0;K1 = 1;
	CurveFit/X=1/H="1100"/NTHR=0 HillEquation  maxlevels /X=maxvoltage /D 

	//get max of vgroup average response --> maxlist entry
	//get group voltage from vgroup name -->maxlistvoltage entry
	//normalize maxlist
	//display maxlist vs maxlistvoltage
	//modify graph accordingly
end

Window AnalysisPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	DoWindow/K AnalysisFunc
	GetWindow Console wsize
	NewPanel/N=AnalysisFunc /W=(V_right, V_top,V_right+(1081-869),V_top+(457-133))
	Button Sensitivity,pos={11,11},size={75,40},title="Sensitivity\r Graph",proc=sensitivitybutton
	PopupMenu direction,pos={96,11},size={90,20},title="Direction:"
	PopupMenu direction,mode=1,popvalue="Up",value= #"\"Up;Down\""
	Button right,pos={159,36},size={25,20},proc=centerlocation,title="\\W649",disable=2
	Button left,pos={105,36},size={25,20},proc=centerlocation,title="\\W646",disable=2
	CheckBox manual,pos={138,39},size={16,14},title="",value= 0,side= 1,proc=centerlocationcheck
EndMacro

Function CenterLocation(Name) : ButtonControl
	String Name
	variable/g xoffset=GetTraceOffset("Resp_avg","zero","x")
	getaxis/w=Resp_avg/q bottom
	variable range=V_max-V_min
	strswitch(Name)
		case "Left":
			xoffset-=range/200
			ModifyGraph/W=Resp_avg offset(zero)={xoffset,*}
			SetAxis/W=Resp_avg bottom V_min,V_max
			break
		case "Right":
			xoffset+=range/200
			ModifyGraph/W=Resp_avg offset(zero)={xoffset,*}
			SetAxis/W=Resp_avg bottom V_min,V_max
			break
	endswitch
end

Function CenterLocationCheck(Name, Value) : ButtonControl
	String Name
	variable Value
	variable/g xoffset
	if(value)
		Button right disable=0
		Button left disable=0
		
		Appendtograph/W=Resp_avg zero
		getaxis/w=Resp_avg/q left
		ModifyGraph/W=Resp_avg offset(zero)={xoffset,V_min}
		ModifyGraph/W=Resp_avg lsize(zero)=2,lstyle(zero)=1,rgb(zero)=(0,0,0)
	else
		Button right disable=2
		Button left disable=2
		Removefromgraph/W=Resp_avg zero
	endif
End

Function SensitivityButton(Name) : ButtonControl
	String Name
	Sensitivity()
end
