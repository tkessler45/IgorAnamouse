#pragma rtGlobals=1		// Use modern global access method.

Menu "TracePopup" //"AllTracesPopup"
	"Concatenate Waves", ConcatWaves()
	"Cut Waves", CutGraphWaves()
End

Menu "Load Waves"
	"-"
	"Load Wave Folder/OC0", LoadWaveFolder()
	"Load Wave File/SC0", LoadWaveFile()
End

Menu "Analysis"
	"-"
	"Display Waves by Base Name", DispBaseByNum()
	"Average Waves by Base Name", AvgBaseByNum()
End

Menu "Data"
	"-"
	"Kill Waves By Name", RemoveWavesByBase()
	"Move Waves By Name", MoveWavesByBase()
End

Menu "Graph"
	"-"
	GraphMenuItem(1), /Q, ToggleGraphContextual()
End

Function/S GraphMenuItem(num)
	variable num
	if(itemsinlist(winlist("*",";","WIN:1"))) //dependent on a graph window existing
		GetWindow kwTopWin, hook
		if(stringmatch(S_Value,"GraphContextual"))
			return "!"+num2char(18)+"Graph Tools Contextual Menu/1"
		else
			return "Graph Tools Contextual Menu/1"
		endif
	endif
end

Function ToggleGraphContextual([Graph])
	String Graph
	if(numtype(strlen(Graph))==2)
		GetWindow kwTopWin, hook
	else
		GetWindow $Graph, hook
	endif
	if(stringmatch(S_Value,"GraphContextual"))
		if(numtype(strlen(Graph))==2)
			SetWindow kwTopWin hook=$""
		else
			SetWindow $Graph hook=$""
		endif
	else
		if(numtype(strlen(Graph))==2)
			SetWindow kwTopWin hook=GraphContextual, hookevents=1
		else
			SetWindow $Graph hook=GraphContextual, hookevents=1
		endif
	endif
end

Function LoadWaveFolder()
	DFREF currentFolder = GetDataFolderDFR()
	string newFolder=GetDataFolder(1)
	string type
	Prompt newFolder, "Type folder name for waves (Enter for current folder):"
	Prompt type, "Select File Type:", popup, "abf;atf;ibw"
	GetFileFolderInfo/D/Q/Z=2
	if(V_Flag==0)
		DoPrompt "Parent folder: "+ParseFilePath(0, S_Path, ":", 1, 1), newFolder, type
		if(!V_Flag)
			if(stringmatch(newFolder, "root:")) //conditional to manage root folder access
				SetDataFolder root:
			else
				NewDataFolder/O/S $newFolder
			endif
			
			NewPath/O loadPath S_Path
			String fileList
			if(stringmatch(type,"ibw"))
				fileList = IndexedFile(loadPath,-1,".ibw")
			elseif(stringmatch(type,"atf"))
				fileList = IndexedFile(loadPath,-1,".atf")
			elseif(stringmatch(type,"abf"))
				fileList = IndexedFile(loadPath,-1,".abf")
				DFREF dfSave=GetDataFolderDFR()
				ResetNM(0) //ensure Neuromatic is properly initialized
				SetDataFolder dfSave
				dowindow/k NMPanel //kill the neuromatic panel immediately (not needed)
			endif

			variable i
			
			NewPanel/FLT=1 /N=ProgressPanel /W=(300,200,800,300)
				TitleBox valtitle,title="Importing Files into the "+GetDataFolder(1)+" folder...",win=ProgressPanel,fsize=14,frame=0,pos={50,20},size={100,25}
				ValDisplay valdisp0,pos={50,50},size={400,25}
				ValDisplay valdisp0,limits={0,itemsinlist(fileList,";"),0},barmisc={0,0}
				ValDisplay valdisp0,value=_NUM:0
				ValDisplay valdisp0,mode=3
				ValDisplay valdisp0,highColor=(0,40000,0)
		
			DoUpdate /W=ProgressPanel /E=1
			
			for(i=0;i<itemsinlist(fileList,";");i+=1)
				if(stringmatch(type,"ibw"))
					LoadRenameIBW(S_Path+StringFromList(i,fileList,";"))
				elseif(stringmatch(type,"atf"))
					LoadRenameATF(S_Path+StringFromList(i,fileList,";"))
				elseif(stringmatch(type,"abf"))
					LoadRenameABF(S_Path+StringFromList(i,fileList,";"))
				endif
				ValDisplay valdisp0,value=_NUM:i+1,win=ProgressPanel
				DoUpdate /W=ProgressPanel
				
			endfor
			SetDataFolder currentFolder
			KillWindow ProgressPanel
		endif
	endif
end

Function LoadWaveFile()
	DFREF currentFolder = GetDataFolderDFR()
	string newFolder=GetDataFolder(1)
	Prompt newFolder, "Type folder name for any parsed waves (Enter for current folder):"
	GetFileFolderInfo/Q/Z=2
	if(V_Flag==0)
		DoPrompt "Parent folder: "+ParseFilePath(0, S_Path, ":", 1, 1), newFolder
		if(!V_Flag)
			if(stringmatch(newFolder, "root:")) //conditional to manage root folder access
				SetDataFolder root:
			else
				NewDataFolder/O/S $newFolder
			endif
			
			Print "path: "+ParseFilePath(1, S_Path, ":", 1, 0)
//			Print "path: "+removelistitem(itemsinlist(S_Path,":")-1,S_Path,":") //mimick NewPath output for LoadWaveFolder()
			if(stringmatch(ParseFilePath(4, S_Path, ":", 0, 0),"ibw"))
				LoadRenameIBW(S_Path)
			elseif(stringmatch(ParseFilePath(4, S_Path, ":", 0, 0),"atf"))
				LoadRenameATF(S_Path)
			elseif(stringmatch(ParseFilePath(4, S_Path, ":", 0, 0),"abf"))
				DFREF dfSave=GetDataFolderDFR()
				ResetNM(0) //ensure Neuromatic is properly initialized
				setDataFolder dfSave
				dowindow/k NMPanel //kill the neuromatic panel immediately (not needed)
				LoadRenameABF(S_Path)
			else
				Print "Error: unknown file type (only .ibw or .atf are supported)"
			endif
		
			SetDataFolder currentFolder
		endif
	endif
end

Function LoadRenameABF(filePath) // main data import function (From Neuromatic)
	String filePath
	
	Variable success, amode, saveprompt, totalNumWaves, numChannels
	String acqMode, wPrefix, wList, prefixFolder
	String df=ImportDF()
	String folder=GetDataFolder(1) // import into current data folder
	
	Variable importPrompt=NMVarGet("ImportPrompt")
	String saveWavePrefix=StrVarOrDefault("WavePrefix", NMStrGet("WavePrefix"))
	
	if(FileExistsAndNonZero(filePath)==0)
		NMDoAlert("Error: external data file has not been selected.")
		return -1
	endif
	
	success=CallNMImportFileManager(filePath, df, "", "header")
	
	if(success<=0)
		return -1
	endif
	
	totalNumWaves=NumVarOrDefault(df+"TotalNumWaves", 0)
	numChannels=NumVarOrDefault(df+"NumChannels", 1)
	
	SetNMvar(df+"WaveBgn", 0)
	SetNMvar(df+"WaveEnd", ceil(totalNumWaves/numChannels)-1)
	CheckNMstr(df+"WavePrefix", NMStrGet("WavePrefix"))
	
	if(importPrompt==1)
		NMImportPanel() // open panel to display header info and request user input
	endif
	
	if(NumVarOrDefault(df+"WaveBgn", -1)<0) // user aborted
		return -1
	endif
	
	wPrefix=StrVarOrDefault(df+"WavePrefix", NMStrGet("WavePrefix"))
	
	SetNMvar("WaveBgn", NumVarOrDefault(df+"WaveBgn", 0))
	SetNMvar("WaveEnd", NumVarOrDefault(df+"WaveEnd", -1))
	
	SetNMstr("WavePrefix", wPrefix)
	SetNMstr("CurrentFile", filePath)
	
	success=CallNMImportFileManager(filePath, folder, StrVarOrDefault(df+"DataFileType",""),"Data") // now read the data
	
	if(success<0) // user aborted
		return -1
	endif
	
	prefixFolder=CurrentNMPrefixFolder()
	acqMode=StrVarOrDefault(df+"AcqMode", "")
	amode=str2num(acqMode[0])
	if((numtype(amode)==0) && (amode==3)) // gap free
		if(NumVarOrDefault(df+"ConcatWaves",0)==1)
			NMChanSelect("All")
			wList=NMConcatWaves("C_Record")
			if(ItemsInList(wList)==NMNumWaves() * NMNumChannels())
				NMDeleteWaves(noAlerts=1)
			else
				NMDoAlert("Alert: waves may have not been properly concatenated.")
			endif
			NMSet(wavePrefixNoPrompt="C_Record")
		else
			NMTimeScaleMode(1) // make continuous
		endif
	endif
	
	NVAR nChannels=root:NumChannels
	NVAR nWaves=root:NumWaves
	
	//convert to our naming scheme
	ParseABFImport(nChannels,nWaves)
	NMCleanup()
	
	return 1
End

Function ParseABFImport(NumChannels, NumWaves)
	Variable NumChannels
	Variable NumWaves
	
	WAVE/T ChanNames=root:ABFHeader:sADCChannelName
	WAVE/T ChanUnits=root:ABFHeader:sADCUnits
	SVAR CurrentFile=root:CurrentFile
	//pull names from header strings and waves
	
	string baseName=ParseFilePath(3, CurrentFile, ":", 0, 0)
	string newName
	
	string alpha="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	string msStr="ms;msec;mseconds"
	
	Variable i, j
	for(i=0;i<numpnts(ChanNames);i+=1)
		if(!strlen(ChanNames[i]))
			deletepoints i,1, ChanNames
			deletepoints i,1, ChanUnits
		endif
	endfor
	for(i=0;i<NumChannels;i+=1)
		for(j=0;j<NumWaves;j+=1)
		
		WAVE wavenm=root:$("Record"+alpha[i]+num2str(j))
		//define newName
		if(char2num(basename[0])>122 || char2num(basename[0])<97)
			newName="w"+basename+"_"+ChanNames[i]
		else
			newName=basename+"_"+ChanNames[i]
		endif
		if(numWaves>1)
			newName+="_"+num2str(j)
		endif
		
		newName=ReplaceString("-",ReplaceString(" ",newName,""),"_")
		
		//duplicate to new wavename and kill
		duplicate/o wavenm $(newName)
		killwaves wavenm
		WAVE wavenm=$(newName)
		
		SetScale/P x,0,deltax(wavenm),stringbykey("XLabel",note(wavenm),":","\r"), wavenm
		
		//re-scale to Seconds
		if(findlistitem(stringbykey("XUNITS",waveinfo(wavenm,0)),msStr)>0)
			setscale/P x, 0,deltax(wavenm)/1000, "S", wavenm
		endif
		
		SetScale/P y,0,1,ChanUnits[i], wavenm		
		endfor
	endfor
	
//	killwaves
end

Function LoadRenameIBW(filePath)
	string filePath
	variable modifiedName=0
	LoadWave/H/Q filePath
	if(V_Flag)
		//Parse String
		S_fileName=ReplaceString(" ",S_fileName,"")
		S_fileName=ReplaceString(".ibw",S_fileName,"")
		if(!stringmatch(S_fileName,stringfromlist(0,S_waveNames)))
			if(char2num(S_fileName[0])>122 || char2num(S_fileName[0])<97)
				S_fileName="w"+S_fileName
				modifiedName=1
			endif
				
			wave wavenm=$S_fileName
			variable defaultBehavior=1
		
			if(waveexists(wavenm))
				DoAlert 1, "Wave \""+nameofwave(wavenm)+"\" exists in the \""+GetDataFolder(0)+"\" folder. Continue and overwrite?"
				defaultBehavior=V_Flag
			endif
			if(defaultBehavior==1)
				Duplicate/O $stringfromlist(0,S_waveNames) $S_fileName
				KillWaves $stringfromlist(0,S_waveNames)

				//if wave is 2D, then split it...
				if(DimSize($S_filename,1))
					Split2D($S_filename)
				endif
			
//				if(modifiedName)
//					Print S_fileName[1,strlen(S_fileName)]+".ibw"+" loaded into "+GetDataFolder(1)
//				else
//					Print S_fileName+".ibw"+" loaded into "+GetDataFolder(1)
//				endif
			else
				KillWaves $stringfromlist(0,S_waveNames)
			endif
		endif
	endif
end

Function LoadRenameATF(filePath)
	string filePath
	variable modifiedName=0
	LoadWave/G/H/Q/M filePath
	if(V_Flag)
		//Parse String
		S_fileName=ReplaceString(" ",S_fileName,"")
		S_fileName=ReplaceString(".atf",S_fileName,"")
		if(char2num(S_fileName[0])>122 || char2num(S_fileName[0])<97)
			S_fileName="w"+S_fileName
			modifiedName=1
		endif
		
		wave wavenm=$(stringfromlist(0,S_waveNames))
		rename wavenm $S_fileName
		
		variable i
		if(wavenm[1][0]>.01) //crude for identifying ms time units...
			setscale/P x,0,(wavenm[1][0])/1000, "S",wavenm
		else
			setscale/P x,0,wavenm[1][0], "S",wavenm
		endif
		
		//setscale based on first "time" wave
		
		deletepoints/M=1 0,1, wavenm
		if(dimsize(wavenm,1)==1)
			redimension/n=(-1,0) wavenm
		else
			//split...
			Split2D(wavenm)
		endif
			
//		if(modifiedName)
//			Print S_fileName[1,strlen(S_fileName)]+".atf"+" loaded into "+GetDataFolder(1)
//		else
//			Print S_fileName+".atf"+" loaded into "+GetDataFolder(1)
//		endif
	endif
end

Function Split2D(wavenm)
	WAVE wavenm
	variable i
	variable panelmadehere=0
	string splittitle="Splitting "+nameofwave(wavenm)+"..."
	
	If(!WinType("ProgressPanel")) //panel doesnt exist...
		panelmadehere=1
		NewPanel/FLT=1 /N=ProgressPanel /W=(300,200,800,300)
		TitleBox valtitle2D,title=splittitle,win=ProgressPanel,fsize=14,frame=0,pos={50,20},size={100,25}
		ValDisplay valdisp02D,pos={50,50},size={400,25}
		ValDisplay valdisp02D,limits={0,dimsize(wavenm,1),0},barmisc={0,0}
		ValDisplay valdisp02D,value=_NUM:0
		ValDisplay valdisp02D,mode=3
		ValDisplay valdisp02D,highColor=(0,40000,0)
	else
		//resize panel window...
		MoveWindow/W=ProgressPanel 300,200,800,370
		TitleBox valtitle2D,title=splittitle,win=ProgressPanel,fsize=14,frame=0,pos={50,85},size={100,25}
		ValDisplay valdisp02D,pos={50,115},size={400,25}
		ValDisplay valdisp02D,limits={0,dimsize(wavenm,1),0},barmisc={0,0}
		ValDisplay valdisp02D,value=_NUM:0
		ValDisplay valdisp02D,mode=3
		ValDisplay valdisp02D,highColor=(0,40000,0)
	endif
		
		
	DoUpdate /W=ProgressPanel /E=1
	
	for(i=0;i<dimsize(wavenm,1);i+=1)
		make/n=(dimsize(wavenm,0)) $(nameofwave(wavenm)+"_"+num2str(i))
		WAVE newWave = $(nameofwave(wavenm)+"_"+num2str(i))
		
		newWave = wavenm[p][i]
		//SetScale/P x 0, deltax(wavenm), "ms", newWave
		SetScale/P y 0, 1, "µV", newWave
		
		ValDisplay valdisp02D,value=_NUM:i+1,win=ProgressPanel
		DoUpdate /W=ProgressPanel
	endfor
	
	//kill off original 2D wave if only contains one wave
	if(dimsize(wavenm,1)==1)
		duplicate/O $(nameofwave(wavenm)+"_0") $(nameofwave(wavenm))
		killwaves $(nameofwave(wavenm)+"_0")
	endif
	
	if(panelmadehere)
		KillWindow Split2DProgress
	endif
	killwaves/z wavenm
end

//Concatenate waves in graph
Function ConcatWaves()
//	string namestr=TraceNameList("",";",3) //3 = omit hidden traces
//	namestr[strlen(namestr)-1,strlen(namestr)]=""
	string wavenm=GetBasename(nameofwave(tracenametowaveref("",stringfromlist(0,TraceNameList("",";",3)))), nameofwave(tracenametowaveref("",stringfromlist(1,TraceNameList("",";",3)))))+"cat"
	prompt wavenm, "Name of concatenated wave:"
	DoPrompt "Wave Naming", wavenm
	
//	Concatenate/KILL/NP TraceNameList("",";",3), $wavenm
	
	variable i
	string sourceStr=""
	string nameList=TraceNameList("",";",3)
	for(i=0;i<itemsinlist(nameList);i+=1)
		sourceStr+=getwavesdatafolder(tracenametowaveref("",stringfromlist(i,tracenamelist("",";",3))),2)+";" //getwavesdatafolder($nameofwave(source),2)+";"
		//if kill, then remove waves from graph...
			//not work for multiple graphs...
	endfor
	Concatenate/KILL/NP/O sourceStr, $wavenm
	//now for a long fucking command...
	//Concatenate/KILL/NP/O GetWavesDataFolder(tracenametowaveref("",stringfromlist(1,TraceNameList("",";",3))),1)+ReplaceString(";",TraceNameList("",";",3),  ";"+GetWavesDataFolder(tracenametowaveref("",stringfromlist(1,TraceNameList("",";",3))),1),0,itemsinlist(TraceNameList("",";",3))-1), $wavenm
end

//compares two strings and returns the common base
Function/S GetBasename(first, second)
	string first
	string second
	string base=""
	
	variable i
	for(i=0;i<strlen(first);i+=1)
		if(cmpstr(first[i],second[i])==0)
			base+=first[i]
		else
			return base
		endif
	endfor
	return base
end

Function AllBaseNames()
	//get all waves in folder
	string wlist=wavelist("*",";","")
	//make factorial of wavelist size
	make/O/T/n=0 BaseNames
	
	NewPanel/FLT=1 /N=ProgressPanel /W=(300,200,800,300)
		TitleBox valtitle,title="Calculating Basenames...",win=ProgressPanel,fsize=14,frame=0,pos={50,20},size={100,25}
		ValDisplay valdisp0,pos={50,50},size={400,25}
		ValDisplay valdisp0,limits={0,itemsinlist(wlist)^2,0},barmisc={0,0}
		ValDisplay valdisp0,value=_NUM:0
		ValDisplay valdisp0,mode=3
		ValDisplay valdisp0,highColor=(0,40000,0)
	
	variable j, k,prog
	for(j=0;j<itemsinlist(wlist);j+=1)
		for(k=0;k<itemsinlist(wlist);k+=1)
			if(!CountTextInstances(basenames,GetBasename(stringfromlist(j,wlist,";"),stringfromlist(k,wlist,";"))))
				insertpoints 0,1,basenames
				BaseNames[0]=GetBasename(stringfromlist(j,wlist,";"),stringfromlist(k,wlist,";"))
			endif
			prog+=1
		endfor
		ValDisplay valdisp0,value=_NUM:prog,win=ProgressPanel
		DoUpdate /W=ProgressPanel
	endfor
	killwindow ProgressPanel
end

Function CountTextInstances(wavenm, str)
	wave/T wavenm
	string str
	
	variable num
	variable i
	for(i=0;i<numpnts(wavenm);i+=1)
		if(stringmatch(wavenm[i],str))
			num+=1
		endif
	endfor
	return num
end

//Concatenate corresponding Pdiode and BAT12 waves (based on wave name)

//Cut into individual stim epochs
Function CutGraphWaves()
	//Select Index Wave
	string indexWavenm
	string baseName="Imem"
	variable baseLine=1
	variable length=5
	prompt indexWavenm, "Select Index Wave (ie, Pdiode)", popup, TraceNameList("",";",3)
	prompt baseName, "Enter Base name (ie, \"Imem\")"
	prompt baseLine, "Enter Baseline length (S)"
	prompt length, "Enter Sweep Length (S)"
	DoPrompt "Index Selection", indexWavenm, baseName, baseLine, length
	
	Wave indexWave=root:$indexWavenm
	
	variable thresh=0.1 //make dynamic
	variable i, j
	//find threshold crossings and generate waves
	FindLevels/D=StimTimes/EDGE=1 indexWave, thresh
	for(j=0;j<ItemsInList(TraceNameList("",";",3));j+=1)
		for(i=0;i<V_LevelsFound;i+=1)
			Wave source = WaveRefIndexed("",j,3)
			if(!StringMatch(nameofwave(WaveRefIndexed("",j,3)),nameofwave(indexWave)))
				Duplicate/O/R=(StimTimes[i]-baseline,StimTimes[i]-baseline+length) source $(baseName+num2str(i))
				Wave newWave = $(baseName+num2str(i))
			else
				Duplicate/O/R=(StimTimes[i]-baseline,StimTimes[i]-baseline+length) source $(nameofwave(source)+num2str(i))
				Wave newWave = $(nameofwave(source)+num2str(i))
			endif
			SetScale/P x 0, deltax(source), "S", newWave
			wavestats/q/r=(0,baseLine) newWave
			newWave-=V_avg
		endfor
	endfor
	//make charts and lists
end
//Create list of waves

Function AvgBaseByNum()
	string baseName="Imem"
	variable number
	string folder
	prompt baseName, "Enter Base name (ie, \"Imem\"):"
	prompt number, "Enter the number to average:"
	prompt folder, "Select the folder containing the waves:",popup," ;"+replaceString(",",replaceString(";",replaceString("FOLDERS:",datafolderdir(1),""),""),";")
	DoPrompt "Wave Average", baseName, number, folder
	if(!V_flag)
		variable i
		string avgnote
		for(i=0;i<number;i+=1)
			if(stringmatch(folder," "))
				Wave wavenm = root:$(baseName+num2str(i))
			else
				Wave wavenm = root:$(folder):$(baseName+num2str(i))
			endif
			if(i==0)
				Print "Waves averaged:"
				duplicate/o wavenm $(baseName+"_Avg")
				Wave avg=root:$(baseName+"_Avg")
				Print "     "+nameofwave(wavenm)
				//append note
				avgnote=GetNote(avg,"Average Sources")
				SetNote(avg,"Average Sources",avgnote+nameofwave(wavenm)+";")
			else
				avg+=wavenm
				Print "     "+nameofwave(wavenm)
				//append note
				avgnote=GetNote(avg,"Average Sources")
				SetNote(avg,"Average Sources",avgnote+nameofwave(wavenm)+";")
			endif
		endfor
		avg/=number
		Print "Average wave: "+nameofwave(avg)
	endif
end

Function DispBaseByNum()
	string baseName="Imem"
	variable number
	variable skip
	variable start
	string folder
	prompt baseName, "Enter Base name (ie, \"Imem\"):"
	prompt start, "Enter starting number:"
	prompt skip, "Skip every:"
	prompt number, "Enter the number to display:"
	prompt folder, "Select the folder containing the waves:",popup,"Current;"+replaceString(",",replaceString(";",replaceString("FOLDERS:",datafolderdir(1),""),""),";")
	DoPrompt "Wave Display", baseName, start, skip, number, folder
	if(!V_flag)
		variable i
		Display
		if(stringmatch(folder,"Current"))
			folder=""
		else
			folder=folder+":"
		endif
		for(i=start;i<(start+(number*(1+skip)));i+=(1+skip))
			Wave wavenm = $(getdatafolder(1)+folder+baseName+num2str(i))
			appendtograph wavenm
		endfor
	endif
end

Function RemoveWavesByBase([customName])
	string customName
	variable location=1
	prompt customName, "Enter wavename base"
	prompt location, "Name text is...", popup, "In Middle;At Start;At End;Custom"
	if(numtype(strlen(customName))==2)
		DoPrompt "Kill Waves by name", customName, location
	else
		location=4
		DoPrompt "Kill Waves by name: \""+customName+"\"", location
	endif
	
	if(!V_Flag)
		if(location==1)
			customName="*"+customName+"*"
		elseif(location==2)
			customName+="*"
		elseif(location==3)
			customName="*"+customName
		endif
	
		string wList=WaveList(customName,";","")
	
		variable i
		for(i=0;i<ItemsInList(wList,";");i+=1)
			WAVE wavenm=root:$(stringfromlist(i,wList,";"))
			killwaves/z wavenm
		endfor
		
		Print num2str(i)+" waves removed based on name \""+customName+"\"..."
	endif
end

Function MoveWavesByBase([customName])
	string customName
	variable location=1
	string folder
	
	variable selection
	string folderlist="New Folder;root;"+getdatafolder(1)+replacestring(",",stringbykey("FOLDERS",datafolderdir(1)),";"+getdatafolder(1))+";"
	prompt folder, "Folder Name:"
	prompt selection, "Select folder",popup, folderlist
//	DoPrompt "...or move to:",selection,folder
	
	prompt customName, "Enter wavename base"
	prompt location, "Name text is...", popup, "In Middle;At Start;At End;Custom"
//	prompt folder,"Destination Folder:"
	if(numtype(strlen(customName))==2)
		DoPrompt "Move Waves by name", customName, location, selection, folder
	else
		location=4
		DoPrompt "Move Waves by name: \""+customName+"\"", location, selection, folder
	endif
	
	if(!V_Flag)
		if(location==1)
			customName="*"+customName+"*"
		elseif(location==2)
			customName+="*"
		elseif(location==3)
			customName="*"+customName
		endif
	
		string wList=WaveList(customName,";","")
		
		variable i
		if(!stringmatch(folder,""))
			newdatafolder/o $folder
		
			Print "Waves moved:"
			For(i=0;i<itemsinlist(wList);i+=1)
				WAVE wavenm=$stringfromlist(i,wList)
				if(itemsinlist(wlist)<20)
					Print "     "+nameofwave(wavenm)
				endif
				MoveWave wavenm, :$(folder):
			endfor
			Print "To Folder: "+folder
		elseif(selection>1)
			Print "Waves moved:"
			For(i=0;i<itemsinlist(wList);i+=1)
				WAVE wavenm=$stringfromlist(i,wList)
				if(itemsinlist(wlist)<20)
					Print "     "+nameofwave(wavenm)
				endif
				MoveWave wavenm, $(stringfromlist(selection-1,folderlist)+":")
			endfor
			Print "To Folder: "+stringfromlist(selection-1,folderlist)
		endif
		
		Print num2str(i)+" waves moved to "+""+" based on name \""+customName+"\"..."
	endif
end

Function NMCleanup()
	killwaves/z FileScaleFactors, yLabel, ABF_WaveTimeStamps, ABF_WaveStartTimes
	killvariables/z WaveBgn, WaveEnd, DataFormat, AcqLength, NumChannels, SamplesPerWave, NumWaves, TotalNumWaves, SampleInterval, SplitClock, ADCRange, ADCResolution
	killstrings/z AcqMode, ImportFileType, DataFileType, WavePrefix, CurrentFile
	killdatafolder/z nmFolder0
	killdatafolder/z ABFHeader
end

Function ExportATF(wavenm)
	WAVE wavenm
	
	string yname
	string xname
	
	variable i=0
	
	GetFileFolderInfo/D
	
	if(!V_Flag)
		NewPath/O savePath,S_Path
		make/O/T/n=0 ATFWave
		WAVE/T ATF=ATFWave
	
		insertpoints numpnts(ATF), 3+numpnts(wavenm), ATF
		ATF[0]="ATF     1.0"
		ATF[1]="0     2"
		ATF[2]="\"Time ("+stringbykey("XUNITS",waveinfo(wavenm,0),":",";")+")\"     \""+nameofwave(wavenm)+" ("+stringbykey("DUNITS",waveinfo(wavenm,0),":",";")+")\""

		variable delta=deltax(wavenm)
		
		for(i=0;i<numpnts(wavenm);i+=1)
			ATF[i+3]=num2str(delta*i)+"     "+num2str(wavenm[i])
		endfor
	
		Save/G/P=savePath ATF as nameofwave(wavenm)+".atf"
		
		killwaves ATF
		killpath savePath
	endif
end
