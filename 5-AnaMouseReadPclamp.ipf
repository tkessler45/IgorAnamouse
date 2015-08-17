#pragma rtGlobals = 1
#pragma IgorVersion = 5
#pragma version = 1.91

Menu "|| AnaMouse ||"
	"Open ABF 9", OpenABF()
End

//****************************************************************
//****************************************************************
//****************************************************************
//
//	Read PClamp Functions
//	To be run with NeuroMatic, v1.91
//	NeuroMatic.ThinkRandom.com
//	Code for WaveMetrics Igor Pro
//
//	By Jason Rothman (Jason@ThinkRandom.com)
//
//	Last modified 16 Oct 2004
//
//	PClamp file header details from Axon Instruments, Inc.
//
//****************************************************************
//****************************************************************
//****************************************************************

Macro OpenABF(NDF,ISI) //prompts for NDF and ISI used, and loads and labels waves, then creates an average wave...
	string NDF
	string ISI=""
	prompt NDF, "Enter NDF Value for File:"
	prompt ISI,"Enter ISI Value for File: (Leave blank if not using ISI)"
	
	string ISIstr
	if(strlen(ISI)==0)
		ISIstr=""
	else
		ISIstr="isi"+ISI
	endif
	
	Silent 1
	if(exists(("Avef"+NDF+ISIstr))) //if function has been run and waves exist...
		DoAlert 1, "NDF "+NDF+" with ISI "+ISI+" already loaded...\r\rContinue and replace data?"
		if(V_flag==2) //kill variables and abort macro execution...
			Abort
		endif
	endif
	
	
	variable ntraces=0
	variable/g FileFormat,NumChannels,TotalNumWaves,SamplesPerWave,SampleInterval,yScalef //variables for "Ana_ReadPClampHeader"
	variable/g AcqLength, DataPointer//additional variables used in "Ana_ReadPClampData()"
	string/g CurrentFile,AcqMode,xLabel //strings for "Ana_ReadPClampHeader"
	variable/g WaveBeg,WaveEnd,WaveInc,CurrentWave //additional variables for "Ana_ReadPClampData"
	variable/g flasht
	
//	variable scalingf=1/yScalef //scaling factor for waves....
	
	Ana_CheckNMwave("FileScaleFactors", 10, 1)
	Ana_CheckNMwave("MyScaleFactors", 10, 1)
	Ana_CheckNMtwave("yLabel", 10, "") // increase size
	
	GetFileFolderInfo/Q/P=Igor "???" //Define SVAR "S_path" for axon binary file...
	CurrentFile=S_path
	print CurrentFile
	
	if(Ana_ReadPClampHeader()) //run axon import (will save waves as WaveA0, WaveB0, WaveC0, etc...
		ntraces=Ana_ReadPClampData()
	endif
	
	variable i=0
	
	duplicate/o WaveA0 $("avef"+NDF+ISIstr)
	duplicate/o WaveB0 $("avetemp"+NDF+ISIstr)
	duplicate/o WaveC0 $("avepdiode"+NDF+ISIstr)
	$("avef"+NDF+ISIstr)=0
	$("avetemp"+NDF+ISIstr)=0
	$("avepdiode"+NDF+ISIstr)=0
	do
		//$("avef"+NDF+ISIstr)+=$("WaveA"+num2str(i))
		$("avepdiode"+NDF+ISIstr)+=$("WaveC"+num2str(i))
		if(exists(("f"+NDF+ISIstr+"trc"+num2str(i+1))))
			killwaves $("f"+NDF+ISIstr+"trc"+num2str(i+1))
		endif
		if(exists(("f"+NDF+ISIstr+"temp"+num2str(i+1))))
			killwaves $("f"+NDF+ISIstr+"temp"+num2str(i+1))
		endif
		if(exists(("f"+NDF+ISIstr+"pdiode"+num2str(i+1))))
			killwaves $("f"+NDF+ISIstr+"pdiode"+num2str(i+1))
		endif
		rename $("WaveA"+num2str(i)) $("f"+NDF+ISIstr+"trc"+num2str(i+1))
		$("f"+NDF+ISIstr+"trc"+num2str(i+1))/=yScalef //was *=scalingf
		$("avef"+NDF+ISIstr)+=$("f"+NDF+ISIstr+"trc"+num2str(i+1)) //add  all waves together....for average
		rename $("WaveB"+num2str(i)) $("f"+NDF+ISIstr+"temp"+num2str(i+1))
		$("f"+NDF+ISIstr+"temp"+num2str(i+1))/=-1.02107 //static scaling factor (-.0102107*100mV) for BAT12 thermocouple
		$("f"+NDF+ISIstr+"temp"+num2str(i+1))+=7.35 //static offset for BAT12 thermocouple
		$("avetemp"+NDF+ISIstr)+=$("f"+NDF+ISIstr+"temp"+num2str(i+1)) //average wave for temp values...defined after scaling and offset adjustment
		rename $("WaveC"+num2str(i)) $("f"+NDF+ISIstr+"pdiode"+num2str(i+1))
		
//		findvalue/V=0.5/T=0.1 $("f"+NDF+ISIstr+"pdiode"+num2str(i+1))
//		flasht=pnt2x($("f"+NDF+ISIstr+"pdiode"+num2str(i+1)),V_value)
		
		i+=1
	while(i<ntraces)
	
	$("avef"+NDF+ISIstr)/=ntraces
	$("avetemp"+NDF+ISIstr)/=ntraces
	$("avepdiode"+NDF+ISIstr)/=ntraces
	
	wavestats/q $("avepdiode"+NDF+ISIstr)
	
	findlevel/q $("avepdiode"+NDF+ISIstr), V_max/(SampleInterval*100) //100 converts from msec to usec...units for flash duration.
	flasht=V_LevelX
//	flashp=x2pnt($("avepdiode"+NDF+ISIstr), flasht
	
	//multiply waves by 200 (scaling factor to represent uV amplitudes)
	//rename waves with pdiode, trace#, and ndf...
		//Wave Names: "ND##", "ISImsec","Trc#"
		//average waves and label as "AveND##", "ISImsec"
	
	print "Flash Time:",flasht
	
	KillVariables/z FileFormat,NumChannels,TotalNumWaves,SamplesPerWave,SampleInterval,AcqLength,DataPointer,WaveBeg,WaveEnd,WaveInc,CurrentWave
	KillVariables/z ADCResolution,ADCRange,DataFormat,yScalef
	KillStrings/z CurrentFile,AcqMode,xLabel
endmacro

//****************************************************************
//****************************************************************
//****************************************************************

Function Ana_ReadPClampHeader() // read pClamp file header
	Variable ccnt, amode, icnt, ActualEpisodes, tempvar
	Variable /G ADCResolution, ADCRange, DataPointer, AcqLength // create new globabl variables
	String yl
	NVAR FileFormat, NumChannels, TotalNumWaves, SamplesPerWave, SampleInterval, yScalef
	SVAR CurrentFile,AcqMode, xLabel //CurrentFile is "path" to an igor binary file...using SVAR S_path defined below...
//	GetFileFolderInfo/Q/P=Igor "???"
//	SVAR S_path //was "currentFile" defined above...used instead....
	Wave FileScaleFactors
	Wave /T yLabel
	
	Make /O DumWave0 // where GBLoadWave puts data

	//
	// file ID and size info
	//
	
	Execute /Z "GBLoadWave/O/B/Q/N=DumWave/T={16,4} CurrentFile" // read short integers (16 bits)

	if (V_Flag != 0)
		DoAlert 0, " Load File Aborted: error in reading pClamp file."
		return 0
	endif

	FileFormat = DumWave0[18] // should be "1" for ABF filetype

	if (FileFormat != 1)
		DoAlert 0, "Abort: PClamp file format is not ABF (format = " + num2str(FileFormat) + ")"
		return 0
	endif

//	NMProgressStr("Reading Pclamp Header...")
//	CallProgress(-1)

	amode = DumWave0[4] // acquisition/operation mode

	switch(amode)
	case 1:
		AcqMode = "1 (Event-Driven)"
		break
	case 2:
		AcqMode = "2 (Oscilloscope, loss free)"
		break
	case 3:
		AcqMode = "3 (Gap-Free)"
		break
	case 4:
		AcqMode = "4 (Oscilloscope, high-speed)"
		break
	case 5:
		AcqMode = "5 (Episodic)"
		break
	endswitch
	
	Execute /Z "GBLoadWave/O/B/Q/N=DumWave/T={32,4}/S=10 CurrentFile" // read long integers (32 bits)
	AcqLength = DumWave0[0] // actual number of ADC samples in data file
	
	Execute /Z "GBLoadWave/O/B/Q/N=DumWave/T={32,4}/S=16 CurrentFile" // read long integers (32 bits)
	ActualEpisodes = DumWave0[0]
	
	//
	// File Structure info
	//
	
	Execute /Z "GBLoadWave/O/B/Q/N=DumWave/T={32,4}/S=40 CurrentFile" // read long integers (32 bits)
	DataPointer = DumWave0[0] // block number of start of Data section
	
	Execute /Z "GBLoadWave/O/B/Q/N=DumWave/T={16,4}/S=100 CurrentFile" // read long integers (32 bits)
	Ana_SetNMVar("DataFormat", DumWave0[0]) // data representation (0) 2-byte integer (1) IEEE 4-byte float
	
//	if (CallProgress(-2) == 1)
//		return 0 // cancel
//	endif
		
	//
	// Trial Hierarchy info
	//
	
	Execute /Z "GBLoadWave/O/B/Q/N=DumWave/T={16,4}/S=120 CurrentFile" // read short integers (16 bits)
	NumChannels = DumWave0[0] // nADCNumChannels
	TotalNumWaves = ActualEpisodes*NumChannels
	
	Execute /Z "GBLoadWave/O/B/Q/N=DumWave/T={2,4}/S=122 CurrentFile" // single precision floating (32 bits)
	SampleInterval = (DumWave0[0]*NumChannels)/1000 // fADC sample interval (convert to milliseconds here)
	
	if (DumWave0[1] != 0) // SecondSampleInterval
		DoAlert 0, "Warning: data contains split-clock recording, which is not supported by this version of NeuroMatic."
	endif
	
	Execute /Z "GBLoadWave/O/B/Q/N=DumWave/T={32,4}/S=138 CurrentFile" // read long integers (32 bits)
	SamplesPerWave = DumWave0[0]/NumChannels // sample points per wave
	//Variable /G PreTriggerSamples = DumWave0[1]
	//Variable /G EpisodesPerRun = DumWave0[2]
	//Variable /G RunsPerTrial = DumWave0[3]
	//Variable /G NumberOfTrials = DumWave0[4]
	
	//Execute /Z "GBLoadWave/O/B/Q/N=DumWave/T={2,4}/S=178 CurrentFile" // single precision floating (32 bits)
	//Variable /G EpisodeStartToStart = DumWave0[0]
	//Variable /G RunStartToStart = DumWave0[1]
	//Variable /G TrialStartToStart = DumWave0[2]
	
	//Execute /Z "GBLoadWave/O/B/Q/N=DumWave/T={32,4}/S=194 CurrentFile" // read long integers (32 bits)
	//Variable /G ClockChange = DumWave0[0]
	
	//
	// Hardware Info
	//
	
	Execute /Z "GBLoadWave/O/B/Q/N=DumWave/T={2,4}/S=244 CurrentFile" // single precision floating (32 bits)
	ADCRange = DumWave0[0] // ADC positive full-scale input (volts)
	//Variable /G DACRange = DumWave0[1]
	
	Execute /Z "GBLoadWave/O/B/Q/N=DumWave/T={32,4}/S=252 CurrentFile" // read long integers (32 bits)
	ADCResolution =  DumWave0[0] // number of ADC counts in ADC range
	//Variable /G DACResolution = DumWave0[1]
	
//	if (CallProgress(-2) == 1)
//		return 0 // cancel
//	endif
	
	//
	// Multi-channel Info
	//
	
	if (strlen(yLabel[ccnt]) == 0)
	
		Execute /Z "GBLoadWave /O/Q/N=DumWave/T={8,8}/S=442 CurrentFile" // read characters (1 byte)
	
		for (ccnt = 0; ccnt < NumChannels; ccnt += 1)
			yl = ""
			for (icnt = 0; icnt < 10; icnt += 1)
				tempvar = DumWave0[icnt + ccnt*8]
				if (tempvar != 32)
					yl += num2char(tempvar)
				endif
			endfor
			yLabel[ccnt] = yl + " ("
		endfor
		
		Execute /Z "GBLoadWave /O/Q/N=DumWave/T={8,8}/S=602 CurrentFile" // read characters (1 byte)
		
		for (ccnt = 0; ccnt < NumChannels; ccnt += 1)
			yl = ""
			for (icnt = 0; icnt < 8; icnt += 1)
				tempvar = DumWave0[icnt + ccnt*8]
				if (tempvar != 32)
					yl += num2char(tempvar)
				endif
			endfor
			yLabel[ccnt] += yl+ ")"
		endfor
	
	endif
	
	Execute /Z "GBLoadWave/O/B/Q/N=DumWave/T={2,4}/S=922 CurrentFile" // single precision floating (32 bits)

	//At this point, DumWave0[3]=inverse of mV/V scaling factor for y-axis...	
	yScalef=DumWave0[3]
	
	for (ccnt = 0; ccnt < NumChannels; ccnt += 1)
		FileScaleFactors[ccnt] = ADCRange/(ADCResolution*DumWave0[ccnt])
		//print "chan" + num2str(ccnt) + " gain:", DumWave0[ccnt]
	endfor
	
//	if (CallProgress(-2) == 1)
//		return 0 // cancel
//	endif
	
	//
	// Extended Environmental Info
	//
	
	Execute /Z "GBLoadWave/O/B/Q/N=DumWave/T={16,4}/S=4512 CurrentFile" // telegraph enable (short)
	Variable TelegraphEnable = DumWave0[0]
	//Print "Telegraph Enable:", TelegraphEnable
	
	Execute /Z "GBLoadWave/O/B/Q/N=DumWave/T={16,4}/S=4544 CurrentFile" // telegraph instrument (short)
	//Variable /G TelegraphInstrument = DumWave0[0]
	
	Execute /Z "GBLoadWave/O/B/Q/N=DumWave/T={2,4}/S=4576 CurrentFile" // single precision floating (32 bits)
	
	for (ccnt = 0; ccnt < NumChannels; ccnt += 1)
		if ((numtype(DumWave0[ccnt]) == 0) && (DumWave0[ccnt] > 0))
			FileScaleFactors[ccnt] /= DumWave0[ccnt]
			//print "chan" + num2str(ccnt) + " telegraph gain:", DumWave0[ccnt]
		endif
	endfor
	
	// finish up things here...
	
	if (amode == 3) // gap free
		TotalNumWaves = ceil(AcqLength/SamplesPerWave)
	endif
	
	if (strlen(xLabel) == 0)
		xLabel = "msec"
	endif
	
	KillWaves /Z DumWave0
	
//	if (CallProgress(1) == 1)
//		return 0 // cancel
//	endif
	
	return 1

End // ReadPClampHeader

//****************************************************************
//****************************************************************
//****************************************************************

Function Ana_ReadPClampData() // read pClamp file

	Variable strtnum, numwaves, amode, scale
	Variable ccnt, wcnt, scnt, pcnt, pflag, smpcnt, npnts1, npnts2, lastwave
	String wName, wNote
	
	Variable /G column, NumSamps // these variables must be global for GBLoadWave to run properly
	
	NVAR NumChannels, SamplesPerWave, SampleInterval, AcqLength, DataPointer
	NVAR WaveBeg, WaveEnd, WaveInc, CurrentWave
	
	NVAR TotalNumWaves,NumChannels
	WaveInc = 1; WaveBeg = 1; WaveEnd = floor(TotalNumWaves/NumChannels)
	
	SVAR CurrentFile, AcqMode, xLabel
	
	Wave FileScaleFactors, MyScaleFactors
	Wave /T yLabel
	
	Variable DataFormat = NumVarOrDefault("DataFormat", 0)
	
	strtnum = CurrentWave
	
	if ((WaveBeg > WaveEnd) || (WaveInc < 0) || (strtnum < 0) || (numtype(WaveBeg*WaveEnd*WaveInc*strtnum) != 0))
		return 0 // options not allowed
	endif
	
	Make /O DumWave0, DumWave1 // where GBLoadWave puts data
	
	lastwave = floor(AcqLength/(NumChannels*SamplesPerWave))
	
	if (WaveEnd > lastwave)
		WaveEnd = lastwave
	endif
	
	numwaves = floor((WaveEnd - WaveBeg + 1)/ WaveInc)
	amode = str2num(AcqMode[0])
	
	NumSamps = SamplesPerWave*NumChannels
	
	if (amode == 3)
		for (ccnt = 0; ccnt < NumChannels; ccnt += 1)
			Variable /G $("xbeg" + num2str(ccnt))
			Variable /G $("xend" + num2str(ccnt))
			Make /O/N=(AcqLength/NumChannels) $Ana_GetWaveName("default", ccnt, strtnum) = NAN
		endfor
	endif
	
//	CallProgress(0) // bring up progress window
	
	for (wcnt = WaveBeg; wcnt <= WaveEnd; wcnt += WaveInc) // loop thru waves
	
		column = wcnt - 1 // compute column index to read

		if (DataFormat == 0) // 2 bytes integer
			Execute /Z "GBLoadWave/O/Q/B/N=DumWave/T={16,2}/S=(512*DataPointer+NumSamps*2*column)/W=1/U=(NumSamps) CurrentFile"
		elseif (DataFormat == 1) // 4 bytes float
			Execute /Z "GBLoadWave/O/Q/B/N=DumWave/T={2,2}/S=(512*DataPointer+NumSamps*4*column)/W=1/U=(NumSamps) CurrentFile"
		endif
			
		if (V_Flag != 0)
			DumWave0 = NAN
			DoAlert 0, "WARNING: Unsuccessfull read on Wave #" + num2str(wcnt)
		endif
		
		for (ccnt = 0; ccnt < NumChannels; ccnt += 1) // loop thru channels and extract channel waves
		
			Redimension /N=(NumSamps/NumChannels) DumWave1
			
			if (NumChannels == 1)
				Duplicate /O DumWave0 DumWave1
			else
				for (smpcnt = 0; smpcnt < SamplesPerWave; smpcnt += 1)
					DumWave1[smpcnt]=DumWave0[smpcnt*NumChannels+ccnt]
				endfor
			endif
			
			scale = FileScaleFactors[ccnt]*MyScaleFactors[ccnt]
			
			if (numtype(scale) == 0)
				DumWave1 *= scale
			endif
			
			if (amode == 3) // Gap-Free acquisition mode
			
				Wave DumWave = $Ana_GetWaveName("default", ccnt, strtnum)
				
				NVAR xbeg = $("xbeg" + num2str(ccnt))
				NVAR xend = $("xend" + num2str(ccnt))
			
				xend = xbeg + numpnts(DumWave1) - 1
				DumWave[xbeg,xend] = DumWave1[x-xbeg]
				xbeg = xend + 1

			else // all other acqusition modes
			
				wName = Ana_GetWaveName("default", ccnt, (scnt + strtnum))
				
				Duplicate /O DumWave1, $wName
				Setscale /P x 0, SampleInterval, $wName
				
				wNote = "Folder:" + GetDataFolder(0)
				wNote += "\rChan:" + Ana_ChanNum2Char(ccnt)
				wNote += "\rScale:" + num2str(scale)
				wNote += "\rFile:" + Ana_NMNoteCheck(CurrentFile)

				Ana_NMNoteType(wName, "Pclamp", xLabel, yLabel[ccnt], wNote)
				
			endif
			
		endfor
		
		scnt += 1
		pcnt += 1
		
//		pflag = CallProgress(pcnt/numwaves)
		
		if (pflag == 1) // cancel
			break
		endif
			
	endfor
	
//	CallProgress(1) // close progress window
	
	if (amode == 3) // Gap-Free acqusition mode
	
		scnt = 1 // loaded one wave
		
		for (ccnt = 0; ccnt < NumChannels; ccnt += 1)
		
			wName = Ana_GetWaveName("default", ccnt, strtnum)
			
			NVAR xend = $("xend" + num2str(ccnt))
			
			Redimension /N=(xend+1) $wName
			Setscale /P x 0, SampleInterval, $wName
			
			wNote = "Folder:" + GetDataFolder(0)
			wNote += "\rChan:" + Ana_ChanNum2Char(ccnt)
			wNote += "\rScale:" + num2str(scale)
			wNote += "\rFile:" + Ana_NMNoteCheck(CurrentFile)

			Ana_NMNoteType(wName, "Pclamp", xLabel, yLabel[ccnt], wNote)
			
		endfor
		
	endif
	
	KillVariables /Z NumSamps, column, DataPointer
	KillWaves /Z DumWave0, DumWave1
	
	return scnt // return count

End // ReadPClampData

//****************************************************************
//****************************************************************
//****************************************************************

Function Ana_SetNMvar(varName, value) // set variable to passed value within folder
	String varName
	Variable value
	
	if (strlen(varName) == 0)
		return -1
	endif
	
	String path = Ana_GetPathName(varName, 1)

	if ((StringMatch(path, "") == 0) && (DataFolderExists(path) == 0))
		return -1
	endif

	if (exists(varName) == 2)
		NVAR tempVar = $varName
		tempVar = value
	else
		Variable /G $varName = value
	endif
	
	return 0

End // SetNMvar

//****************************************************************
//
//	GetWaveName()
//	return NM wave name string, given prefix, channel and wave number
//
//****************************************************************

Function /S Ana_GetWaveName(prefix, chanNum, waveNum)
	String prefix // wave prefix name (pass "default" to use data's WavePrefix)
	Variable chanNum // channel number (pass -1 for none)
	Variable waveNum // wave number
	
	String name
	
	if ((StringMatch(prefix, "default") == 1) || (StringMatch(prefix, "Default") == 1))
		prefix = StrVarOrDefault("WavePrefix", "Wave")
	endif
	
	if (chanNum == -1)
		name = prefix + num2str(waveNum)
	else
		name = prefix + Ana_ChanNum2Char(chanNum) + num2str(waveNum)
	endif
	
	return name

End // GetWaveName

//****************************************************************
//****************************************************************
//****************************************************************
//
//	Channel Functions
//
//****************************************************************
//****************************************************************
//****************************************************************

Function /S Ana_ChanNum2Char(chanNum)
	Variable chanNum
	
	return num2char(65+chanNum)

End // ChanNum2Char

//****************************************************************
//****************************************************************
//****************************************************************

Function /S Ana_NMNoteCheck(noteStr)
	String noteStr
	
	noteStr = Ana_NMReplaceChar(":", noteStr, ",")
	
	return noteStr
	
End // NMNoteCheck

//****************************************************************
//
//	NMStringReplace()
//	replace a string in a string expression
//
//****************************************************************

Function /S Ana_NMReplaceChar(findchar, str, repchar)
	String findchar // search char
	String str // string expression
	String repchar // replace char
	
	Variable icnt
	
	for (icnt = 0; icnt < strlen(str); icnt += 1)
		if (StringMatch(str[icnt,icnt], findchar) == 1)
			str[icnt,icnt] = repchar
		endif
	endfor
	
	return str

End // NMReplaceChar

//****************************************************************
//****************************************************************
//****************************************************************

Function Ana_NMNoteType(wName, wType, xLabel, yLabel, wNote)
	String wName, wType, xLabel, yLabel, wNote
	
	String xyLabel = ""
	
	if (WaveExists($wName) == 1)
	
		Note /K $wName
		Note $wName, "Source:" + Ana_GetPathName(wName, 0)
		
		if (strlen(wType) > 0)
			Note $wName, "Type:" + wType
		endif
		
		if (strlen(yLabel) > 0)
			xyLabel = "YLabel:" + yLabel
		endif
		
		if (strlen(xLabel) > 0)
			if (strlen(xyLabel) > 0)
				xyLabel += ";XLabel:" + xLabel + ";"
			else
				xyLabel = "XLabel:" + xLabel
			endif
		endif
		
		if (strlen(xyLabel) > 0)
			Note $wName, xyLabel
		endif
		
		if (strlen(wNote) > 0)
			Note $wName, wNote
		endif
		
	endif

End // NMNoteType

//****************************************************************
//****************************************************************
//****************************************************************

Function /S Ana_GetPathName(fullpath, option)
	String fullpath // full-path name (i.e. "root:folder0")
	Variable option // (0) return string containing folder or variable name (i.e. "folder0") (1) returns string containing path (i.e. "root:")
	
	Variable icnt
	
	fullpath = Ana_LastPathColon(fullpath, 0) // remove trailing colon if it exists
	
	//icnt = strsearch(fullpath,":",Inf,1)
	
	for (icnt = strlen(fullpath) - 2; icnt >= 0; icnt -= 1)  
		if (StringMatch(fullpath[icnt], ":") == 1) // found right-most colon within path name
			break
		endif
	endfor
	
	switch(option)
		case 0:
			if (icnt > 0)
				return fullpath[icnt+1, inf]
			else
				return fullpath
			endif
			break
		case 1:
			if (icnt > 0)
				return fullpath[0, icnt]
			else
				return ""
			endif
			break
	endswitch
	
	return ""

End // GetPathName

//****************************************************************
//****************************************************************
//****************************************************************

Function /S Ana_LastPathColon(fullpath, yes)
	String fullpath
	Variable yes // check path (0) has no trailing colon (1) has trailing colon
	
	Variable n = strlen(fullpath) - 1
	
	switch(yes)
	
		case 0:
			if (StringMatch(fullpath[n,n], ":") == 1)
				return fullpath[0,n-1]
			endif
			break
			
		case 1:
			if (StringMatch(fullpath[n,n], ":") == 0)
				return fullpath + ":"
			endif
			break
			
		default:
			return ""
			
	endswitch
	
	return fullpath

End // LastPathColon

//****************************************************************
//****************************************************************
//****************************************************************

Function Ana_CheckNMwave(wList, npnts, dflt)
	String wList // wave list
	Variable npnts // (-1) dont care
	Variable dflt
	
	String wName, path
	Variable wcnt, npnts2, error = 0
	
	for (wcnt = 0; wcnt < ItemsInList(wList); wcnt += 1)
	
		wName = StringFromList(wcnt, wList)
		
		npnts2 = numpnts($wName)
		
		path = Ana_GetPathName(wName, 1)
		
		if ((StringMatch(path, "") == 0) && (DataFolderExists(path) == 0))
			error = -1
		endif
		
		if (exists(wName) == 0)
		
			if (npnts < 0)
				Make $wName = dflt
			else
				Make /N=(npnts) $wName = dflt
			endif
			
		elseif ((exists(wName) == 1) && (npnts >= 0))
		
			npnts2 = numpnts($wName)
		
			if (npnts > npnts2)
				Redimension /N=(npnts) $wName
				Wave wtemp = $wName
				wtemp[npnts2,inf] = dflt
			elseif (npnts < npnts2)
				Redimension /N=(npnts) $wName
			endif
			
		endif
	
	endfor
	
	return error
	
End // CheckNMwave

//****************************************************************
//****************************************************************
//****************************************************************

Function Ana_CheckNMtwave(wName, npnts, dflt)
	String wName
	Variable npnts // (-1) dont care
	String dflt
	
	Variable npnts2
	
	String path = Ana_GetPathName(wName, 1)
	
	if ((StringMatch(path, "") == 0) && (DataFolderExists(path) == 0))
		return -1
	endif
	
	if (exists(wName) == 0)
	
		if (npnts < 0)
			npnts = 0
		endif
		
		Make /T/N=(npnts) $wName = dflt
		
	elseif ((exists(wName) == 1) && (npnts >= 0))
	
		npnts2 = numpnts($wName)
		
		if (npnts > npnts2)
			Redimension /N=(npnts) $wName
			Wave /T wtemp = $wName
			wtemp[npnts2,inf] = dflt
		elseif (npnts < npnts2)
			Redimension /N=(npnts) $wName
		endif
		
	endif
	
	return 0
	
End // CheckNMtwave
