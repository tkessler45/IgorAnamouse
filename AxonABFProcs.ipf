#pragma rtGlobals=1		// Use modern global access method.

StrConstant NMDF = "root:Packages:NeuroMatic:"
StrConstant NMVersionStr = "2.7u"
StrConstant NMCR = "\r" // carriage return
StrConstant NMTabList = "Main;Stats;Spike;Event;Fit;"

StrConstant NMPrefixSubfolderPrefix = "NMPrefix_"
StrConstant NMPanelName = "NMPanel"
StrConstant NMChanWaveListPrefix = "Chan_WaveList"
StrConstant NMChanSelectVarName = "ChanSelect_List"
StrConstant NMWaveSelectVarName = "WaveSelect_List"
StrConstant NMMainDF = "root:Packages:NeuroMatic:Main:"
StrConstant NMSetsListSuffix = "_SetList"


StrConstant NMSetsListDefault = "Set1;Set2;SetX;"
StrConstant NMWavePrefixList = "Record;Wave;Avg_;Pulse_;ST_;SP_;EV_;Fit_;Histo_;Sort_;COp_;xScale_;Sim_;"
StrConstant NMChanPopupList = "Overlay;Grid;Drag;Markers;Errors;XLabel;YLabel;FreezeX;FreezeY;To Front;Reset Position;Off;"
StrConstant NMChanTransformList = "Baseline;Normalize;dF/Fo;Invert;Differentiate;Double Differentiate;Integrate;Running Average;Histogram;Clip Events;"
StrConstant NMPopupFolderList = "Open Data File(s);---;New;Close;Save;Duplicate;Rename;Merge;---;Save All;Close All;---;Set Open Path;Set Save Path;---;Edit FolderList;"

StrConstant NMRedStr = "52224,0,0"
StrConstant NMGreenStr = "0,39168,0"
StrConstant NMBlueStr = "0,0,65535"

StrConstant NMSetsPanelName = "NM_SetsPanel"
StrConstant NMGroupsPanelName = "NM_GroupsPanel"

Static Constant ErrorPointsLimit = 200
Static Constant Marker = 19 // closed circle
Static Constant GridsOn = 1 // channel graph grids ( 0 ) off ( 1 ) on

Static StrConstant NMChanGraphPrefix = "Chan"
Static StrConstant OverlayColor = "34800,34800,34800"

Constant NMPrefixFolderHistory = 0 // ( 0 ) do not ( 1 ) include current prefix folder name in command history
Constant NMPanelFsize = 11
Constant NMPanelWidth = 300
Constant NMPanelHeight = 640
Constant NMPanelTabY = 170
Constant NMFirstGroup = 0

Constant NMProgWinWidth = 260 // pixels
Constant NMProgWinHeight = 100 // pixels

Constant NMProgButtonX0 = 90
Constant NMProgButtonY0 = 70
Constant NMProgButtonXwidth = 80
Constant NMProgButtonYwidth = 20

Static Constant ABF_SCALEWAVES = 1 // ( 0 ) no ( 1 ) yes, scale waves by scale factor read from header file
Static Constant ABF_XOP_ON = 1 // ( 1 ) no, turn off XOP if it exists ( slooower ) ( 0 ) yes, use XOP to read data if it exists 

Static StrConstant ABF_SUBFOLDERNAME = "ABFHeader"
Static StrConstant ABF_WAVENAMETIME1 = "ABF_WaveTimeStamps"
Static StrConstant ABF_WAVENAMETIME2 = "ABF_WaveStartTimes"
StrConstant ABF_STRINGERROR = "CouldNotFindHeaderString"

Static Constant ABF_ADCCOUNT = 16
Static Constant ABF_DACCOUNT = 4
Static Constant ABF_EPOCHCOUNT = 10
Static Constant ABF_ADCUNITLEN = 8
Static Constant ABF_ADCNAMELEN = 10
Static Constant ABF_DACUNITLEN = 8
Static Constant ABF_DACNAMELEN = 10
Static Constant ABF_BLOCK = 512

Function ResetNM( killFirst [ history ] ) // use this function to re-initialize neuromatic
	Variable killfirst // kill variables first flag
	Variable history // print function command to history ( 0 ) no ( 1 ) yes
	
	String vlist = ""
	
	if ( !ParamIsDefault( history ) && history )
		vlist = NMCmdNum( killFirst, "" )
		NMCmdHistory( "", vlist )
	endif
	
	if ( killfirst == 1 )
	
		DoAlert 1, "Warning: this function will re-initialize all of NeuroMatic global variables. Do you want to continue?"
	
		if ( V_Flag != 1 )
			return -1
		endif
	
	endif
	
	CheckNMPackageFormat6()
	
	//CheckCurrentFolder() // must set this here, otherwise Igor is at root directory
	NMTabControlList()
	
	ChanGraphClose( -2, 0 ) // close all graphs
	
	if ( killfirst == 1 )
		NMKill() // this is hard kill, and will reset previous global variables to default values
	endif
	
	if ( CheckNM() < 0 )
		return -1
	endif
	
	SetNMvar( NMDF+"CurrentTab", 0 ) // set Main Tab as current tab
	
	CheckNMDataFolders()
	CheckNMFolderList()
	NMChanWaveListSet( 0 )
	
	SetNMstr( NMDF+"NMVersionStr", NMVersionStr )
	
//	MakeNMPanel()
	CheckCurrentFolder()
	
	if ( IsNMDataFolder( "" ) == 1 )
		UpdateCurrentWave()
	endif
	
	NMProceduresHideUpdate()
	
//	NMHistory( NMCR + "Initialized NeuroMatic " + NMVersionStr )
	
	return 0

End // ResetNM

Function /S ImportDF()

	if ( NMVarGet( "ImportPrompt" ) == 0 )
		return GetDataFolder( 1 )
	endif

	CheckImport()
	
	return "root:Packages:NeuroMatic:Import:"

End // ImportDF

Function NMVarGet( varName )
	String varName
	
	Variable defaultVal = Nan
	
	strswitch( varName )
	
		case "AutoStart":
			defaultVal = 1
			break
			
		case "AlertUser":
			defaultVal = 1
			break

		case "DeprecationAlert":
			defaultVal = 1
			break
			
		case "WriteHistory":
			defaultVal = 1
			break
		
		case "CmdHistory":
			defaultVal = 1
			break
			
		case "ConfigsDisplay":
			defaultVal = 0
			break
			
		case "ForceNMFolderPrefix":
			defaultVal = 1
			break
			
		case "ImportPrompt":
			defaultVal = 0
			break
			
		case "ABF_GapFreeConcat":
			defaultVal = 1
			break
			
		case "ABF_HeaderReadAll":
			defaultVal = 0
			break
			
		case "CreateOldFolderGlobals":
			defaultVal = 0
			break
			
		case "HideProcedureFiles":
			defaultVal = 1
			break
			
		case "WaveSkip":
			defaultVal = 1
			break
			
		case "NMon":
			defaultVal = 1
			break
			
		case "NMPanelUpdate":
			defaultVal = 1
			break
			
		case "CurrentTab":
			defaultVal = 0
			break
			
		case "Cascade":
			defaultVal = 0
			break
			
		case "NumActiveWaves":
			defaultVal = 0
			break
			
		case "CurrentWave":
			defaultVal = 0
			break
			
		case "CurrentGrp":
			defaultVal = 0
			break
			
		case "GroupsOn":
			defaultVal = 0
			break
			
		case "SumSet0":
			defaultVal = 0
			break
			
		case "SumSet1":
			defaultVal = 0
			break
			
		case "SumSet2":
			defaultVal = 0
			break
			
		case "ProgFlag":
			defaultVal = 1
			break
			
		case "xProgress":
			defaultVal = Nan // will be computed in NMProgressX
			break
			
		case "yProgress":
			defaultVal = Nan // will be computed in NMProgressY
			break
			
		case "ProgressTimerLimit":
			defaultVal = 5000 // msec
			break
			
		case "NMProgressCancel":
			defaultVal = 0
			break
			
		case "SetsAutoAdvance":
			defaultVal = 0
			break
			
		case "StimRetrieveAs":
			defaultVal = 1
			break
			
		case "PrefixSelectPrompt":
			defaultVal = 1
			break
			
		case "OrderWaves":
			defaultVal = 2
			break
			
		case "DragOn":
			defaultVal = 1
			break
			
		case "AutoDoUpdate":
			defaultVal = 1
			break
			
		case "ErrorPointsLimit":
			defaultVal = ErrorPointsLimit
			break
			
		case "GraphsAndTablesOn":
			defaultVal = 1
			break
			
		default:
			NMDoAlert( "NeuroMaticVar Error: no variable called " + NMQuotes( varName ) )
			return Nan
	
	endswitch
	
	return NumVarOrDefault( NMDF+varName, defaultVal )
	
End // NMVarGet

Function /S NMStrGet( strVarName )
	String strVarName
	
	String defaultStr = ""
	
	strswitch( strVarName )
	
		case "NMVersionStr":
			defaultStr = NMVersionStr
			break
	
		case "OrderWavesBy":
			defaultStr = "name"
			break
			
		case "WavePrefix":
			defaultStr = "Record"
			break
			
		case "PrefixList":
			defaultStr = ""
			break
			
		case "NMTabList":
			defaultStr = NMTabList
			break
			
		case "TabControlList":
			defaultStr = "" // DO NOT CHANGE
			break
			
		case "OpenDataPath":
			defaultStr = ""
			break
			
		case "SaveDataPath":
			defaultStr = ""
			break
			
		case "CurrentFolder":
			defaultStr = ""
			break
			
		case "WaveSelectAdded":
			defaultStr = ""
			break
			
		case "ProgressStr":
			defaultStr = ""
			break
			
		case "ErrorStr":
			defaultStr = ""
			
		default:
			NMDoAlert( "NeuroMaticStr Error: no variable called " + NMQuotes( strVarName ) )
			return ""
	
	endswitch
	
	return StrVarOrDefault( NMDF+strVarName, defaultStr )
			
End // NMStrGet

Function FileExistsAndNonZero( file ) // determine if file exists and contains bytes
	String file // file name
	
	Variable refnum
	Variable ok = 1
	
	if ( strlen( file ) == 0 )
		return 0
	endif
	
	Open /Z=1/R/T="????" refnum as file
	
	if ( refnum == 0 )
		
		return 0
	
	else
	
		FStatus refNum
		
		if ( V_logEOF == 0 )
			ok = 0
			NMHistory( "encountered empty file " + file )
		endif
	
	endif
	
	Close refnum
	
	return ok

End // FileExistsAndNonZero

Function NMDoAlert( promptStr )
	String promptStr
	
	Variable alert = NMVarGet( "AlertUser" )
	
	if ( strlen( promptStr ) == 0 )
		return -1
	endif
	
	switch( alert )
		case 0: // none
			break
		case 1: // DoAlert
			DoAlert /T="NeuroMatic Alert" 0, promptStr
			break
		case 2: // NM history
			NMHistory( promptStr )
			break
	endswitch
	
	return 0

End // NMDoAlert

Function CallNMImportFileManager( file, df, fileType, option ) // call appropriate import data function
	String file
	String df
	String fileType
	String option // "header", "data" or "test"
	
	Variable success = -1
	
	if ( strlen( fileType ) > 0 )
	
		success = NMImportFileManager( file, df, fileType, option )
	
	else
	
		if ( ReadPclampFormat( file ) > 0 )
			fileType = "Pclamp"
			success = NMImportFileManager( file, df, fileType, option )
		elseif ( ReadAxographFormat( file ) > 0 )
			fileType = "Axograph"
			success = NMImportFileManager( file, df, fileType, option )
		else
			NMDoAlert( "Abort NMImportFileManager: file format not recognized for " + file )
			fileType = ""
		endif
		
	endif
	
	SetNMstr( df+"DataFileType", fileType )
	
	return success

End // CallNMImportFileManager

Function SetNMvar( varName, value ) // set variable to passed value within folder
	String varName
	Variable value
	
	String path = GetPathName( varName, 1 )
	String vName = GetPathName( varName, 0 )
	
	if ( strlen( varName ) == 0 )
		NM2Error( 21, "varName", varName )
		return -1
	endif
	
	if ( strlen( vName ) > 31 )
		NM2Error( 22, "varName", vName )
		return -1
	endif

	if ( ( strlen( path ) > 0 ) && ( DataFolderExists( path ) == 0 ) )
		NM2Error( 30, "varName", varName )
		return -1
	endif

	if ( ( WaveExists( $varName ) == 1 ) && ( WaveType( $varName ) > 0 ) )
	
		NVAR tempVar = $varName
		
		tempVar = value
		
	else
	
		Variable /G $varName = value
		
	endif
	
	return 0

End // SetNMvar

Function CheckNMstr( strVarName, defaultValue )
	String strVarName
	String defaultValue
	
	return SetNMstr( strVarName, StrVarOrDefault( strVarName, defaultValue ) )
	
End // CheckNMstr

Function NMImportPanel()

	if ( CheckCurrentFolder() == 0 )
		return 0
	endif

	Variable x1, x2, y1, y2, yinc, height = 330, width = 280
	String df = ImportDF()
	
	Variable xPixels = NMComputerPixelsX()
	Variable waveEnd = NumVarOrDefault( df+"WaveEnd", 0 )
	Variable concat = NumVarOrDefault( df+"ConcatWaves", 0 )
	String acqmode = StrVarOrDefault( df+"AcqMode", "" )
	
	Variable amode = str2num( acqMode[0] )
	
	String fileType = StrVarOrDefault( df+"DataFileType", "UNKNOWN" )
	
	x1 = ( xPixels - width ) / 2
	y1 = 200
	x2 = x1 + width
	y2 = y1 + height
	
	DoWindow /K ImportPanel
	NewPanel /N=ImportPanel/W=( x1,y1,x2,y2 ) as "Import " + fileType + " File"
	
	x1 = 20
	y1 = 45
	yinc = 23
	
	SetDrawEnv fsize= 11
	DrawText x1, 30, "File: " + StrVarOrDefault( df+"FileName", "" )
	
	SetVariable NM_NumChannelSet, title="channels: ", limits={1,10,0}, pos={x1,y1}, size={250,50}, frame=0, value=$( df+"NumChannels" ), win=ImportPanel, proc=NMImportSetVariable
	SetVariable NM_SampIntSet, title="sample interval ( ms ): ", limits={0,10,0}, pos={x1,y1+1*yinc}, size={250,50}, frame=0, value=$( df+"SampleInterval" ), win=ImportPanel
	SetVariable NM_SPSSet, title="samples: ", limits={0,inf,0}, pos={x1,y1+2*yinc}, size={250,50}, frame=0, value=$( df+"SamplesPerWave" ), win=ImportPanel
	SetVariable NM_AcqModeSet, title="acquisition mode: ", pos={x1,y1+3*yinc}, size={250,50}, frame=0, value=$( df+"AcqMode" ), win=ImportPanel
	
	if ( ( numtype( amode ) == 0 ) && ( amode == 3 ) ) // gap free
		//CheckBox NM_ConcatWaves, title="concatenate waves", pos={x1+50,y1+4*yinc}, size={16,18}, value=( concat ), proc=NMImport//CheckBox, win=ImportPanel
		y1 += 15
	endif
	
	yinc = 28
	
	SetVariable NM_WavePrefixSet, title="wave prefix ", pos={x1,y1+4*yinc}, size={140,60}, frame=1, value=$( df+"WavePrefix" ), win=ImportPanel
	SetVariable NM_WaveBgnSet, title="wave beg ", limits={0,waveEnd-1,0}, pos={x1,y1+5*yinc}, size={140,60}, frame=1, value=$( df+"WaveBgn" ), win=ImportPanel
	SetVariable NM_WaveEndSet, title="wave end ", limits={0,waveEnd-1,0}, pos={x1,y1+6*yinc}, size={140,60}, frame=1, value=$( df+"WaveEnd" ), win=ImportPanel
	
	Button NM_AbortButton, title="Abort", pos={55,y1+8.5*yinc}, size={50,20}, win=ImportPanel, proc=NMImportButton
	Button NM_ContinueButton, title="Open File", pos={145,y1+8.5*yinc}, size={80,20}, win=ImportPanel, proc=NMImportButton
	
	PauseForUser ImportPanel

End // NMImportPanel

Function SetNMstr( strVarName, strValue ) // set string to passed value within NeuroMatic folder
	String strVarName, strValue
	
	String path = GetPathName( strVarName, 1 )
	String vName = GetPathName( strVarName, 0 )
	
	if ( strlen( strVarName ) == 0 )
		NM2Error( 21, "strVarName", strVarName )
		return -1
	endif
	
	if ( strlen( vName ) > 31 )
		NM2Error( 22, "strVarName", vName )
		return -1
	endif
	
	if ( ( strlen( path ) > 0 ) && ( DataFolderExists( path ) == 0 ) )
		NM2Error( 30, "strVarName", strVarName )
		return -1
	endif

	if ( ( WaveExists( $strVarName ) == 1 ) && ( WaveType( $strVarName ) == 0 ) )
	
		SVAR tempStr = $strVarName
		
		tempStr = strValue
		
	else
	
		if ( exists( strVarName ) == 2 )
		
			
		
		endif
	
		String /G $strVarName = strValue
		
	endif
	
	return 0

End // SetNMstr

Function /S CurrentNMPrefixFolder( [ fullPath ] )
	Variable fullPath // ( 0 ) folder name only ( 1 ) fullpath folder name, including root
	
	String folder, prefix, prefixFolder
	
	if ( ParamIsDefault( fullPath ) )
		fullPath = 1
	endif
	
	folder = CurrentNMFolder( 1 )
	prefix = StrVarOrDefault( folder + "CurrentPrefix", "" )
	
	if ( strlen( prefix ) == 0 )
		return ""
	endif
	
	if ( fullPath )
	
		prefixFolder = NMPrefixFolderDF( folder, prefix )
	
		if ( DataFolderExists( prefixFolder ) )
			return prefixFolder
		endif
	
	else
	
		return NMPrefixSubfolderPrefix + prefix
	
	endif
	
	return ""

End // CurrentNMPrefixFolder

Function NMChanSelect( chanStr, [ prefixFolder ] ) // set current channel
	String chanStr // "A" or "B" or "C" or "All" or "0" or "1" or "2" or ( "" ) for current channel
	String prefixFolder
	
	Variable chan, currentChan
	String chanCharList, chanNumList, chanList = ""
	
	chanStr = StringFromList( 0, chanStr )
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return NaN
	endif
	
	chanCharList = NMChanList( "CHAR", prefixFolder = prefixFolder )
	chanNumList = NMChanList( "NUM", prefixFolder = prefixFolder )
	
	if ( StringMatch( chanStr, "All" ) )
	
		chanList = chanNumList
		
	elseif ( strlen( chanStr ) == 0 )
	
		currentChan = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
	
		chanList = AddListItem( num2istr( currentChan ), "", ";", inf )
		
	elseif ( WhichListItem( chanStr, chanCharList ) >= 0 )
	
		chan = ChanChar2Num( chanStr )
		chanList = AddListItem( num2istr( chan ), "", ";", inf )
	
	elseif ( WhichListItem( chanStr, chanNumList ) >= 0 )
	
		chanList = AddListItem( chanStr, "", ";", inf )
		
	else
	
		NMDoAlert( "NMChanSelect Error: channel is out of range: " + chanStr )
		return Nan
		
	endif
	
	if ( ItemsInList( chanList ) == 0 )
		return Nan
	endif
	
	return NMChanSelectListSet( chanList, prefixFolder = prefixFolder )

End // NMChanSelect

Function /S NMConcatWaves( wavePrefix )
	String wavePrefix // output wave prefix
	
	Variable ccnt
	String wname, wSelectList, cList, wList = ""
	
	if ( strlen( wavePrefix ) == 0 )
		return NM2ErrorStr( 21, "wavePrefix", wavePrefix )
	endif
	
	for ( ccnt = 0; ccnt < NMNumChannels(); ccnt += 1 ) // loop thru channels
	
		if ( NMChanSelected( ccnt ) != 1 )
			continue // channel not selected
		endif
	
		wSelectList = NMWaveSelectList( ccnt )
		
		if ( strlen( wSelectList ) == 0 )
			continue
		endif
		
		wname = NextWaveName2( "", wavePrefix, ccnt, NMMainVarGet( "OverWriteMode" ) )
		
		Concatenate /O/NP wSelectList, $wname
		
		//cList = ConcatWaves( wSelectList, wname )""
		cList = wSelectList
		
		wList += cList
		
		NMMainHistory( "Concatenate " + wname, ccnt, cList, 0 )
		
	endfor
	
	NMPrefixAdd( wavePrefix )
	ChanGraphsUpdate()
	
	return wList

End // NMConcatWaves

Function NMNumWaves()
	
	Variable numWaves = NumVarOrDefault( CurrentNMPrefixFolder() + "NumWaves", 0 )
	
	return max( 0, numWaves )

End // NMNumWaves

Function NMNumChannels()
	
	Variable numChannels = NumVarOrDefault( CurrentNMPrefixFolder() + "NumChannels", 0 )

	return max( 0, numChannels )

End // NMNumChannels

Function /S NMDeleteWaves( [ noAlerts, checkPrefixWaveLists ] )
	Variable noAlerts // ( 0 ) no ( 1 ) yes
	Variable checkPrefixWaveLists // remove wave names from prefix subfolder wave lists ( 0 ) no ( 1 ) yes

	Variable ccnt, wcnt, failure
	String wName, wSelectList, cList, wList = ""
	
	if ( ParamIsDefault( checkPrefixWaveLists ) )
		checkPrefixWaveLists = 1
	endif
	
	Variable numChannels = NMNumChannels()
	
	if ( noAlerts == 0 )
	
		DoAlert 1, "NMDeleteWaves Alert: this function will attempt to permanently delete all of your currently selected waves. Do you want to continue?"
		
		if ( V_Flag != 1 )
			return "" // cancel
		endif
	
	endif
	
	if ( numChannels == 0 )
		return ""
	endif
	
	for ( ccnt = 0; ccnt < numChannels; ccnt += 1 ) // loop thru channels
	
		if ( NMChanSelected( ccnt ) != 1 )
			continue // channel not selected
		endif
	
		wSelectList = NMWaveSelectList( ccnt )
		
		if ( strlen( wSelectList ) == 0 )
			continue
		endif
		
		cList = DeleteWaves( wSelectList )
		
		if ( ItemsInList( cList ) != ItemsInList( wSelectList ) )
			failure = 1
		endif
		
		if ( checkPrefixWaveLists == 1 )
		
			for ( wcnt = 0 ; wcnt < ItemsInList( cList ) ; wcnt += 1 )
				wName = StringFromList( wcnt, cList )
				NMPrefixFoldersRenameWave( wName, "" )
			endfor
		
		endif
		
		wList += cList
		
		NMMainHistory( "Deleted", ccnt, cList, 0 )
		
	endfor
	
	if ( ( noAlerts == 0 ) && ( failure == 1 ) )
		NMDoAlert( "There was a failure to delete some of the currently selected waves. These waves may be currently displayed in a graph or table, or may be locked.." )
	endif
	
	UpdateNMWaveSelectLists()
	UpdateNMPanelSets( 1 )
	ChanGraphsUpdate()
	
	return wList

End // NMDeleteWaves

Function NMSet( [ on, tab, folder, wavePrefix, wavePrefixNoPrompt, PrefixSelectPrompt, OrderWavesBy, waveNum, waveInc, chanSelect, waveSelect, xProgress, yProgress, winCascade, configsDisplay, errorPointsLimit, openPath, savePath, prefixFolder, history ] )
	
	Variable on
	String tab
	String folder
	
	String wavePrefix, wavePrefixNoPrompt
	Variable PrefixSelectPrompt // config variable
	String OrderWavesBy // config string
	
	Variable waveNum, waveInc
	String chanSelect, waveSelect
	
	Variable xProgress, yProgress // config variables
	
	Variable winCascade
	Variable configsDisplay
	Variable errorPointsLimit
	
	String openPath, savePath
	
	String prefixFolder // used with waveNum, chanSelect, waveSelect
	
	Variable history // print function command to history ( 0 ) no ( 1 ) yes
	
	String vlist = "", vlist2 = ""
	
	if ( ParamIsDefault( prefixFolder ) )
	
		prefixFolder = CurrentNMPrefixFolder()
		
	else
	
		if ( strlen( prefixFolder ) > 0 )
			vlist2 = NMCmdStrOptional( "prefixFolder", prefixFolder, vlist2 )
		elseif ( NMPrefixFolderHistory && ( strlen( prefixFolder ) == 0 ) )
			prefixFolder = CurrentNMPrefixFolder()
			vlist2 = NMCmdStrOptional( "prefixFolder", prefixFolder, vlist2 )
		endif
		
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
		
	endif
	
	if ( !ParamIsDefault( on ) )
	
		vlist = NMCmdNumOptional( "on", on, vlist )
		
		NMon( BinaryCheck( on ) )
		
	endif
	
	if ( !ParamIsDefault( tab ) )
	
		vlist = NMCmdStrOptional( "tab", tab, vlist )
		
		NMTab( tab )
		
	endif
	
	if ( !ParamIsDefault( folder ) )
	
		vlist = NMCmdStrOptional( "folder", folder, vlist )
	
		if ( IsNMDataFolder( folder ) )
			NMFolderChange( folder )
		else
			NMFolderNew( folder )
		endif
		
	endif

	if ( !ParamIsDefault( wavePrefix ) )
	
		vlist = NMCmdStrOptional( "wavePrefix", wavePrefix, vlist )
	
		if ( NMVarGet( "PrefixSelectPrompt" ) )
			NMPrefixSelect( wavePrefix )
		else
			NMPrefixSelect( wavePrefix, noPrompts = 1 )
		endif
		
	endif
	
	if ( !ParamIsDefault( wavePrefixNoPrompt ) )
	
		vlist = NMCmdStrOptional( "wavePrefixNoPrompt", wavePrefixNoPrompt, vlist )
		
		NMPrefixSelect( wavePrefixNoPrompt, noPrompts = 1 )
		
	endif
	
	if ( !ParamIsDefault( PrefixSelectPrompt ) )
	
		vlist = NMCmdNumOptional( "PrefixSelectPrompt", PrefixSelectPrompt, vlist )
		
		NMConfigVarSet( "NM" , "PrefixSelectPrompt" , BinaryCheck( PrefixSelectPrompt ) )
		
	endif
	
	if ( !ParamIsDefault( OrderWavesBy ) )
	
		vlist = NMCmdStrOptional( "OrderWavesBy", OrderWavesBy, vlist )
	
		if ( !StringMatch( OrderWavesBy, "date" ) )
			OrderWavesBy = "name"
		endif
		
		NMConfigStrSet( "NM" , "OrderWavesBy" , OrderWavesBy )
		
	endif
	
	if ( !ParamIsDefault( waveNum ) )
	
		vlist = NMCmdNumOptional( "waveNum", waveNum, vlist )
		
		NMCurrentWaveSet( waveNum, prefixFolder = prefixFolder )
		
	endif
	
	if ( !ParamIsDefault( waveInc ) )
	
		vlist = NMCmdNumOptional( "waveInc", waveInc, vlist )
		
		NMWaveInc( waveInc )
		
	endif
	
	if ( !ParamIsDefault( chanSelect ) )
	
		vlist = NMCmdStrOptional( "chanSelect", chanSelect, vlist )
		
		NMChanSelect( chanSelect, prefixFolder = prefixFolder )
		
	endif
	
	if ( !ParamIsDefault( waveSelect ) )
	
		vlist = NMCmdStrOptional( "waveSelect", waveSelect, vlist )
		
		NMWaveSelect( waveSelect, prefixFolder = prefixFolder )
		
	endif
	
	if ( !ParamIsDefault( xProgress ) )
	
		vlist = NMCmdNumOptional( "xProgress", xProgress, vlist )
		
		if ( ( numtype( xProgress ) > 0 ) || ( xProgress < 0 ) )
			xProgress = NaN
		endif
		
		SetNMvar( NMDF + "xProgress", xProgress )
		
	endif
	
	if ( !ParamIsDefault( yProgress ) )
	
		vlist = NMCmdNumOptional( "yProgress", yProgress, vlist )
		
		if ( ( numtype( yProgress ) > 0 ) || ( yProgress < 0 ) )
			yProgress = NaN
		endif
		
		SetNMvar( NMDF + "yProgress", yProgress )
		
	endif
	
	if ( !ParamIsDefault( winCascade ) )
	
		vlist = NMCmdNumOptional( "winCascade", winCascade, vlist )
	
		if ( ( numtype( winCascade ) > 0 ) || ( winCascade < 0 ) )
			winCascade = 0
		endif
		
		SetNMvar( NMDF+"Cascade", floor( winCascade ) )
		
	endif
	
	if ( !ParamIsDefault( configsDisplay ) )
	
		vlist = NMCmdNumOptional( "configsDisplay", configsDisplay, vlist )
		
		NMConfigsDisplay( BinaryCheck( configsDisplay ) )
		
	endif
	
	if ( !ParamIsDefault( errorPointsLimit ) )
	
		vlist = NMCmdNumOptional( "errorPointsLimit", errorPointsLimit, vlist )
		
		if ( errorPointsLimit >= 0 )
			NMConfigVarSet( "NM" , "ErrorPointsLimit" , errorPointsLimit )
		endif
		
	endif
	
	if ( !ParamIsDefault( openPath ) )
		
		vlist = NMCmdStrOptional( "openPath", openPath, vlist )
	
		NewPath /Q/O/M="Set Open File Path" OpenDataPath, openPath
	
		if ( V_flag == 0 )
			NMConfigStrSet( "NM", "OpenDataPath", openPath )
		endif
		
	endif
	
	if ( !ParamIsDefault( savePath ) )
	
		vlist = NMCmdStrOptional( "savePath", savePath, vlist )
	
		NewPath /Q/O/M="Set Save File Path" SaveDataPath, savePath
		
		if ( V_flag == 0 )
			NMConfigStrSet( "NM", "SaveDataPath", savePath )
		endif
		
	endif
	
	if ( history )
		NMCmdHistory( "", vlist + vlist2 )
	endif
	
End // NMSet

Function /S NMTimeScaleMode( mode )
	Variable mode // ( 0 ) episodic ( 1 ) continuous
	
	Variable ccnt, wcnt, dx, xbgn
	String wname
	
	Variable numChannels = NMNumChannels()
	Variable numWaves = NMNumWaves()
	
	String prefixFolder = CurrentNMPrefixFolder()
	
	if ( numChannels == 0 )
		return ""
	endif
	
	for ( ccnt = 0; ccnt < numChannels; ccnt += 1 ) // loop thru all channels
		
		xbgn = NaN
		
		for ( wcnt = 0; wcnt < numWaves; wcnt += 1 ) // loop thru all waves
		
			wName = NMChanWaveName( ccnt, wcnt )
			
			if ( exists( wName ) == 0 )
				continue // wave does not exist, go to next wave
			endif
			
			if ( numtype( xbgn ) > 0 )
				xbgn = leftx( $wName )
			endif
			
			if ( mode == 1 ) // continuous
				dx = deltax( $wName )
				Setscale /P x xbgn, dx, $wName
				xbgn = rightx( $wName )
			else // episodic
				dx = deltax( $wName )
				Setscale /P x xbgn, dx, $wName
			endif
			
		endfor
		
	endfor
	
	ChanGraphsUpdate()
	
	KillVariables /Z $prefixFolder + "WaveStartX"
	
	ChanGraphsUpdate()
	UpdateNMPanel( 1 )
	
	return ""
	
End // NMTimeScaleMode

Function /S NMCmdNum( numVar, varList )
	Variable numVar
	String varList

	return AddListItem( num2str( numVar ), varList, ";", inf )

End // NMCmdNum

Function NMCmdHistory( fxnName, varList ) // print NM command to history
	String fxnName // e.g. "NMSpikeRasterPSTH"
	String varList // "5;8;10;\stest;" ( \s for string )
	
	Variable icnt, jcnt, comma, extraReturn = 0
	String bullet = "", cmd, varStr, listStr, returnStr = ""
	
	Variable history = NMVarGet( "WriteHistory" )
	Variable cmdhistory = NMVarGet( "CmdHistory" )
	
	String computer = NMComputerType()
	
	if ( strlen( fxnName ) == 0 )
		fxnName = GetRTStackInfo( 2 )
	endif
	
	if ( extraReturn == 1 )
		returnStr = NMCR
	endif
	
	strswitch( computer )
		case "pc":
			bullet = "ï"
			break
		default:
			bullet = "•"
	endswitch
	
	switch( cmdhistory )
		default:
			return 0
		case 1:
			cmd = returnStr + bullet + fxnName + "( "
			break
		case 2:
		case 3:
			cmd = returnStr + fxnName + "( "
			break
	endswitch
	
	for ( icnt = 0; icnt < ItemsInList( varList ); icnt += 1 )
	
		varStr = StringFromList( icnt, varList )
		
		if ( StringMatch( varStr[ 0, 1 ], "\s" ) == 1 ) // string variable
		
			varStr =  varStr[ 2, inf ]
			varStr = NMQuotes( varStr )
			
		elseif ( StringMatch( varStr[ 0, 1 ], "\l" ) == 1 ) // string list
		
			listStr =  varStr[ 2, inf ]
			listStr = ReplaceString( ",", listStr, ";" )
			varStr = NMQuotes( listStr )
			
		elseif ( StringMatch( varStr[ 0, 2 ], "\os" ) == 1 ) // optional string variable
		
			varStr =  varStr[ 3, inf ]
			
			jcnt = strsearch( varStr, " = ", 0 )
			
			if ( jcnt < 0 )
				continue
			endif
			
			jcnt += 2
			
			varStr = varStr[ 0, jcnt ] + NMQuotes( varStr[ jcnt + 1, inf ] )
			
		elseif ( StringMatch( varStr[ 0, 2 ], "\ol" ) == 1 ) // optional string list
		
			varStr =  varStr[ 3, inf ]
			
			jcnt = strsearch( varStr, " = ", 0 )
			
			if ( jcnt < 0 )
				continue
			endif
			
			jcnt += 2
			
			listStr = varStr[ jcnt + 1, inf ]
			listStr = ReplaceString( ",", listStr, ";" )
			
			varStr = varStr[ 0, jcnt ] + NMQuotes( listStr )
			
		endif
		
		if ( comma == 1 )
			cmd += ","
		endif
		
		cmd += " " + varStr + " "
		
		comma = 1
		
	endfor
	
	cmd += " )"
	
	cmd = ReplaceString( "  ", cmd, " " )
	cmd = ReplaceString( "  ", cmd, " " )
	cmd = ReplaceString( "( )", cmd, "()" )
	
	NMHistoryManager( cmd, -1 * cmdhistory )
	
End // NMCmdHistory

Function CheckNMPackageFormat6()

	Variable icnt
	String iName
	
	String moveList = "Configurations;Event;Fit;Import;Main;MyTab;Spike;Stats;Clamp;AMPAR;EPSC;RiseT;Model;"
	String deleteList = "Chan;"
	
	String cdf = ConfigDF( "" )
	
	for ( icnt = 0 ; icnt < ItemsInList( moveList ) ; icnt += 1 )
	
		iName = StringFromList( icnt, moveList )
		
		if ( DataFolderExists( "root:Packages:" + iName + ":" ) == 1 )
		
			if ( DataFolderExists( NMDF + iName + ":" ) == 0 )
				MoveDataFolder $( "root:Packages:" + iName ), $NMDF
				//Print "moved " + iName + " package folder to " + NMDF
			endif
			
		endif
		
	endfor
	
	for ( icnt = 0 ; icnt < ItemsInList( deleteList ) ; icnt += 1 )
	
		iName = StringFromList( icnt, deleteList )
		
		if ( DataFolderExists( "root:Packages:" + iName + ":" ) == 1 )
			KillDataFolder /Z $"root:Packages:" + iName
		endif
		
		if ( DataFolderExists(cdf + iName + ":" ) == 1 )
			KillDataFolder /Z $cdf + iName
		endif
		
	endfor

End // CheckNMPackageFormat6

Function /S NMTabControlList()
	
	Variable icnt
	String tabName, prefix
	
	String tabCntrlList = NMStrGet( "TabControlList" ) // current list of tabs in TabManager format
	String currentList = NMTabListConvert( tabCntrlList )
	String defaultList = NMStrGet( "NMTabList" )
	
	String win = TabWinName( tabCntrlList )
	String tab = TabCntrlName( tabCntrlList )
	
	if ( DataFolderExists( NMDF ) == 0 )
		return "" // nothing to do yet
	endif
	
	if ( ( StringMatch( win, NMPanelName ) == 1 ) && ( StringMatch( tab, "NM_Tab" ) == 1 ) )
		
		if ( StringMatch( defaultList, currentList ) == 0 )
			SetNMstr( NMDF+"NMTabList", currentList ) // defaultList has inappropriately changed
		endif
		
		return tabCntrlList // OK format
		
	endif
	
	// need to create tabCntrlList from defaultList
	
	if ( ItemsInList( defaultList ) == 0 )
	
		if ( ItemsInList( currentList ) > 0 )
			defaultList = currentList
		else
			defaultList = "Main;"
		endif
	
	endif
	
	tabCntrlList = ""
	
	for ( icnt = 0; icnt < ItemsInList( defaultList ); icnt += 1 )
	
		tabName = StringFromList( icnt, defaultList )
		prefix = NMTabPrefix( tabName )
		
		if ( strlen( prefix ) > 0 )
			tabCntrlList = AddListItem( tabName + "," + prefix, tabCntrlList, ";", inf )
		else
//			NMHistory( "NM Tab Entry Failure : " + tabName )
		endif
		
	endfor
	
	tabCntrlList = AddListItem( NMPanelName + ",NM_Tab", tabCntrlList, ";", inf )
	
	SetNMstr( NMDF+"TabControlList", tabCntrlList )

	return tabCntrlList

End // NMTabControlList

Function ChanGraphClose( channel, KillFolders )
	Variable channel // ( -1 ) for current channel ( -2 ) for all channels ( -3 ) for all unecessary channels
	Variable KillFolders // to kill global variables

	Variable ccnt, cbgn, cend
	String gName, cdf, ndf = NMDF
	
	if ( NumVarOrDefault( ndf+"ChanGraphCloseBlock", 0 ) )
		//KillVariables /Z $( ndf+"ChanGraphCloseBlock" )
		return 0
	endif
	
	Variable numChannels = NMNumChannels()
	
	if ( channel == -1 )
		cbgn = CurrentNMChannel()
		cend = cbgn
	elseif ( channel == -2 )
		cbgn = 0
		cend = 9 // numChannels - 1
	elseif ( channel == -3 )
		cbgn = numChannels
		cend = cbgn + 10
	elseif ( ( channel >= 0 ) && ( channel < numChannels ) )
		cbgn = channel
		cend = channel
	else
		//return NM2Error( 10, "channel", num2str( channel ) )
		return 0
	endif
	
	for ( ccnt = cbgn; ccnt <= cend; ccnt += 1 )
	
		cdf = ChanDF( ccnt )
		gName = ChanGraphName( ccnt )
		
		if ( WinType( gName ) == 1 )
			DoWindow /K $gName
		endif
		
		if ( KillFolders && ( strlen( cdf ) > 0 ) && DataFolderExists( cdf ) )
			KillDataFolder $RemoveEnding( cdf, ":" )
		endif
		
	endfor
	
	return 0

End // ChanGraphClose

Function NMKill() // use this with caution!

	String df

	DoWindow /K $NMPanelName

	KillTabs( NMTabControlList() ) // kill tab plots, tables and globals
	
	ChanGraphClose( -2, 0 ) // close all graphs
	
	if ( DataFolderExists( NMDF ) == 1 )
		KillDataFolder $NMDF
	endif

End // NMKill

Function CheckNM()

	Variable madeNMDF
	
	if ( NMVarGet( "NMon" ) == 0 )
		return 1
	endif
	
	if ( DataFolderExists( NMDF ) == 0 )
		madeNMDF = 1
	endif
	
	CheckNMPackageDF( "" )
	
	if ( DataFolderExists( NMDF ) == 0 )
		return -1
	endif
	
	if ( madeNMDF == 1 )
		CheckNeuroMatic()
		NMConfig( "NeuroMatic", -1 )
	else
		NMConfig( "NeuroMatic", 0 )
	endif
	
	NMProgressOn( NMProgFlagDefault() ) // test progress window

	CheckNMPaths()
	CheckFileOpen( "" )
	
	if ( madeNMDF == 1 )
		NMConfigOpenAuto()
		CheckNMPaths()
		AutoStartNM()
		KillGlobals( "root:", "V_*", "110" ) // clean root
		KillGlobals( "root:", "S_*", "110" )
	endif
	
	return madeNMDF

End // CheckNM

Function CheckNMDataFolders() // check all NM Data folders

	Variable icnt

	String fList = NMDataFolderList()
	
	for ( icnt = 0 ; icnt < ItemsInList( fList ) ; icnt += 1 )
		CheckNMDataFolder( StringFromList( icnt, fList ) )
	endfor
	
End // CheckNMDataFolders

Function CheckNMFolderList()

	Variable icnt, folders
	String folder
	
	String wname = NMFolderListWave()
	String folderList = NMFolderList( "root:","NMData" )
	
	folders = ItemsInList( folderList )

	CheckNMtwave( wname, -1, "" )
	
	if ( WaveExists( $wname ) == 0 )
		return 0
	endif
	
	Wave /T list = $wname
	
	for ( icnt = 0; icnt < numpnts( list ); icnt += 1 )
	
		folder = list[ icnt ]
		
		if ( IsNMDataFolder( folder ) == 0 )
			NMFolderListRemove( folder )
		endif
		
	endfor
	
	for ( icnt = 0; icnt < folders; icnt += 1 )
		NMFolderListAdd( StringFromList( icnt, folderList ) )
	endfor
	
End // CheckNMFolderList

Function NMChanWaveListSet( force, [ prefixFolder ] ) // update the list of channel wave names
	Variable force // ( 0 ) no ( 1 ) yes
	String prefixFolder
	
	Variable ccnt, icnt, jcnt = -1
	Variable wcnt, nwaves, nmax, strict, numChannels, numWaves
	
	String parent, currentPrefix, wName, strVarName, wList = "", allList = "", sList = ""
	
	String order = NMStrGet( "OrderWavesBy" )
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	parent = GetPathName( prefixFolder, 1 )
	
	currentPrefix = StrVarOrDefault( parent + "CurrentPrefix", "" )
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	numWaves = NumVarOrDefault( prefixFolder + "NumWaves", 0 )
	
	if ( numChannels == 0 )
		return 0
	endif
	
	DoWindow /K $NMChanWaveListTableName()
	
	if ( force )
		NMPrefixFolderStrVarKill( NMChanWaveListPrefix, prefixFolder = prefixFolder )
	endif
	
	for ( ccnt = 0; ccnt < numChannels; ccnt += 1 )
	
		strVarName = prefixFolder + NMChanWaveListPrefix + ChanNum2Char( ccnt )
	
		if ( ( force != 1 ) && ( ItemsInList( StrVarOrDefault( strVarName, "" ) ) > 0 ) )
			continue
		endif
		
		wList = ""
			
		if ( numChannels == 1 )
		
			wList = NMFolderWaveList( parent, currentPrefix + "*", ";", "Text:0", 0 )
			
		else
		
			if ( jcnt < 0 )
				wList = NMChanWaveListSearch( currentPrefix, ccnt )
			endif
			
			if ( ItemsInList( wList ) == 0 )
			
				jcnt = max( jcnt, ccnt )
		
				for ( icnt = jcnt; icnt < 10; icnt += 1 )
				
					wList = NMChanWaveListSearch( currentPrefix, icnt )
					
					if ( ItemsInList( wList ) > 0 )
						jcnt = icnt + 1
						break
					endif
					
				endfor
				
			endif
			
		endif

		if ( ItemsInList( wList ) == 0 ) // if none found, try most general name
			wList = NMFolderWaveList( parent, currentPrefix + "*", ";", "Text:0", 0 )
		endif
		
		for ( wcnt = 0; wcnt < ItemsInList( allList ); wcnt += 1 ) // remove waves already used
			wName = StringFromList( wcnt, allList )
			wList = RemoveFromList( wName, wList )
		endfor
		
		nwaves = ItemsInList( wList )
		
		if ( nwaves > nmax )
			nmax = nwaves
		endif
		
		if ( nwaves == 0 )
			continue
		elseif ( nwaves != NumWaves )
			//NMDoAlert( "Warning: located only " + num2istr( nwaves ) + " waves for channel " + ChanNum2Char( ccnt ) + "." )
		endif
		
		//strict = ChanWaveListStrict( wList, ccnt )
		
		slist = SortList( wList, ";", 16 ) // SortListAlphaNum( wList, currentPrefix )
		
		if ( StringMatch( order, "name" ) && !StringMatch( wList, slist ) )
			wList = slist
		endif
		
		//Print "Chan" + ChanNum2Char( ccnt ) + ": " + wList
	
		SetNMstr( strVarName, wList )
		
		allList += wList
		
	endfor
	
	NMChanWaveList2Waves( prefixFolder = prefixFolder )
	
	return 0

End // NMChanWaveListSet

Function MakeNMPanel()

	Variable x0, y0, x1, y1, yinc, icnt, lineheight
	String ctrlName, setName

	if (DataFolderExists( NMDF ) == 0)
		CheckNMVersion()
	endif
	
	CheckNMvar(NMDF+"SumSet0", 0)				// set counters
	CheckNMvar(NMDF+"SumSet1", 0)
	CheckNMvar(NMDF+"SumSet2", 0)
	
	CheckNMvar(NMDF+"NumActiveWaves", 0) 	// number of active waves to analyze
	
	CheckNMvar(NMDF+"CurrentWave", 0)			// current wave to display
	CheckNMvar(NMDF+"CurrentGrp", 0)			// current group number
	CheckNMstr(NMDF+"CurrentGrpStr", "0")		// current group number string
	
	Variable fs = NMPanelFsize
	
	String tabList = NMTabControlList()
	
	Variable xPixels = NMComputerPixelsX()
	
	Variable r = NMPanelRGB("r")
	Variable g = NMPanelRGB("g")
	Variable b = NMPanelRGB("b")
	
	x0 = xPixels - NMPanelWidth - 12
	y0 = 43
	x1 = x0 + NMPanelWidth
	y1 = y0 + NMPanelHeight
	
	DoWindow /K $NMPanelName
	NewPanel /K=1/N=$NMPanelName/W=(x0, y0, x1, y1) as "NeuroMatic v" + NMVersionStr
	
	SetWindow $NMPanelName, hook=NMPanelHook
	
	ModifyPanel cbRGB = (r, g, b)
	
	x0 = 40
	y0 = 6
	yinc = 29
	lineheight = y0 + 94
	
	//PopupMenu NM_FolderMenu, title=" ", pos={x0+240, y0+0*yinc}, size={0,0}, bodyWidth=260, help={"data folders"}, win=$NMPanelName
	//PopupMenu NM_FolderMenu, mode=1, value = "", proc=NMPopupFolder, fsize=fs, win=$NMPanelName
	
	//PopupMenu NM_PrefixMenu, title=" ", pos={x0+140, y0+1*yinc}, size={0,0}, bodyWidth=130, help={"wave prefix select"}, win=$NMPanelName
	//PopupMenu NM_PrefixMenu, mode=1, value="Wave Prefix", proc=NMPopupPrefix, fsize=fs, win=$NMPanelName
	
	//PopupMenu NM_SetsMenu, pos={x0+240, y0+1*yinc}, size={0,0}, bodyWidth=85, proc=NMPopupSets, help={"Set functions"}, win=$NMPanelName
	//PopupMenu NM_SetsMenu, value = " ", fsize=fs, win=$NMPanelName
	
	//PopupMenu NM_GroupMenu, title="G ", pos={x0, y0+2*yinc}, size={0,0}, bodyWidth=20, proc=NMPopupGroups, help={"Groups"}, win=$NMPanelName
	//PopupMenu NM_GroupMenu, mode=1, value = "", fsize=fs, win=$NMPanelName
	
	SetVariable NM_SetWaveNum, title= " ", pos={x0+20, y0+2*yinc+2}, size={55,50}, limits={0,inf,0}, value=$(NMDF+"CurrentWave"), win=$NMPanelName
	SetVariable NM_SetWaveNum, frame=1, fsize=fs, proc=NMSetVariable, help={"current wave"}, win=$NMPanelName
	
	SetVariable NM_SetGrpStr, title="Grp", pos={x0+80, y0+2*yinc+3}, size={55,50}, limits={0,inf,0}, value=$(NMDF+"CurrentGrpStr"), win=$NMPanelName
	SetVariable NM_SetGrpStr, frame=1, fsize=fs, proc=NMSetVariable, help={"current group"}, win=$NMPanelName
	
	Button NM_JumpBck, title="<", pos={x0+21, y0+3*yinc}, size={20,20}, proc=NMButton, help={"previous wave"}, win=$NMPanelName, fsize=14
	Button NM_JumpFwd, title=">", pos={x0+112, y0+3*yinc}, size={20,20}, proc=NMButton, help={"next wave"}, win=$NMPanelName, fsize=14
	
	Slider NM_WaveSlide, pos={x0+45, y0+3*yinc}, size={61,50}, limits={0,0,1}, vert=0, side=2, ticks=0, variable = $(NMDF+"CurrentWave"), proc=NMWaveSlide, win=$NMPanelName
	
	//PopupMenu NM_SkipMenu, title="+ ", pos={x0, y0+3*yinc-1}, size={0,0}, bodyWidth=20, help={"wave increment"}, proc=NMPopupSkip, win=$NMPanelName
	//PopupMenu NM_SkipMenu, mode=1, value=" ;Wave Increment = 1;Wave Increment > 1;As Wave Select;", fsize=14, win=$NMPanelName
	
	yinc = 31.5
	
	GroupBox NM_ChanWaveGroup, title = "", pos={0,y0+4*yinc-9}, size={NMPanelWidth, 39}, win=$NMPanelName, labelBack=(43520,48896,65280)
	
	//PopupMenu NM_ChanMenu, title="", pos={x0-20, y0+4*yinc}, bodywidth=50, value="", mode=1, proc=NMPopupChan, help={"limit channels to analyze"}, fsize=fs, win=$NMPanelName
	
	//PopupMenu NM_WaveMenu, title="", value ="Wave Select", mode=1, pos={x0+160, y0+4*yinc}, bodywidth=160, proc=NMPopupWaveSelect, help={"limit waves to analyze"}, fsize=fs, win=$NMPanelName
	
	SetVariable NM_WaveCount, title=" ", pos={x0+215, y0+4*yinc+2}, size={40,50}, limits={0,inf,0}, value=$(NMDF+"NumActiveWaves"), fsize=fs, win=$NMPanelName
	SetVariable NM_WaveCount, frame=0, help={"number of currently selected waves"}, win=$NMPanelName, labelBack=(43520,48896,65280), noedit=1
	
	y0 += yinc
	
	for ( icnt = 0 ; icnt <= 2 ; icnt += 1 )
	
		setName = NMSetsDisplayName( icnt )
		ctrlName = "NM_Set" + num2istr( icnt ) + "Check"
		
		//CheckBox $ctrlName, title=setName+" ", pos={x0+165, y0+28+18*icnt}, value=0, proc=NMSets//CheckBox, help={"include in "+setName}, fsize=fs, win=$NMPanelName
	
	endfor
	
	SetNMvar( NMDF+"ConfigsDisplay", 0 )
	
	NMConfigsListBoxMake( 1 )
	
	//CheckBox NM_Configs, title="Configs", pos={20,615}, size={16,18}, value=NMVarGet("ConfigsDisplay"), win=$NMPanelName
	//CheckBox NM_Configs, proc=NMConfigs//CheckBox, help={"display tab configurations"}, fsize=fs, win=$NMPanelName
	
	TabControl $NMTabControlName(), win=$NMPanelName, pos={0, NMPanelTabY}, size={NMPanelWidth*1.5, NMPanelHeight}, labelBack=(r, g, b), proc=NMTabControl, fsize=fs, win=$NMPanelName
	
	NMTabsMake( 1 )
	
	UpdateNMPanel( 1 )
	
	return 0
	
End // MakeNMPanel

Function CheckCurrentFolder() // check to make sure we are sitting in the current NM folder

	String currentFolder = CurrentNMFolder( 1 ) 
	
	if ( NMVarGet( "NMOn" ) == 0 )
		return 0
	endif

	if ( StringMatch( currentFolder, GetDataFolder( 1 ) ) == 1 )
		return 1 // OK
	endif
	
	if ( ( strlen( currentFolder ) > 0 ) && ( DataFolderExists( currentFolder ) == 1 ) )
		SetDataFolder $currentFolder
		UpdateNM( 0 )
		return 1
	endif
	
	return 0

End // CheckCurrentFolder

Function IsNMDataFolder( folder )
	String folder // full-path folder name
	
	return IsNMFolder( folder,"NMData" )
	
End // IsNMDataFolder

Function UpdateCurrentWave()

	//NMGroupUpdate()
	UpdateNMPanelSets( 0 )
	ChanGraphsUpdate()
	//NMWaveSelect( "update" )
	NMAutoTabCall()
	
End // UpdateCurrentWave

Function NMProceduresHideUpdate()
	
	if ( NMVarGet( "HideProcedureFiles" ) == 1 )
		Execute /Z "SetIgorOption IndependentModuleDev = 0"
	else
		Execute /Z "SetIgorOption IndependentModuleDev = 1"
	endif

End // NMProceduresHideUpdate

Function NMHistory( message ) // print notes to Igor history and/or notebook
	String message
	
	NMHistoryManager( message, NMVarGet( "WriteHistory" ) )

End // NMHistory

Function CheckImport()

	CheckNMPackageDF( "Import" )

End // CheckImport

Function /S NMQuotes( istring )
	String istring

	return "\"" + istring + "\""

End // NMQuotes

Function NMImportFileManager( file, df, filetype, option ) // call appropriate import data function
	String file
	String df // data folder to import to ( "" ) for current
	String filetype // data file type ( ie. "axograph" or "Pclamp" )
	String option // "header" to read data header
				// "data" to read data
				// "test" to test whether this file manager supports file type
	
	Variable /G success // success flag ( 1 ) yes ( 0 ) no; or the number of data waves read
	
	if ( strlen( df ) == 0 )
		df = GetDataFolder( 1 )
	endif
	
	df = LastPathColon( df, 1 )
	
	strswitch( filetype )
	
		default:
			return 0
	
		case "Axograph": // ( see ReadAxograph.ipf )
		
			strswitch( option )
				case "header":
					Execute "success = ReadAxograph( " + NMQuotes( file ) + "," + NMQuotes( df ) + ", 0 )"
					break
					
				case "data":
					Execute "success = ReadAxograph( " + NMQuotes( file ) + "," + NMQuotes( df ) + ", 1 )"
					break
					
				case "test":
					success = 1
					break
					
			endswitch
			
			break
		
		case "Pclamp": // ( see ReadPclamp.ipf )
		
			strswitch( option )
			
				case "header":
					Execute "success = ReadPclampHeader( " + NMQuotes( file ) + "," + NMQuotes( df ) + " )"
					break
					
				case "data":
					Execute "success = ReadPclampData( " + NMQuotes( file ) + "," + NMQuotes( df ) + " )"
					break
					
				case "test":
					success = 1
					break
					
			endswitch
			
			break
			
	endswitch
	
	Variable ss = success
	
	KillVariables /Z success
	
	return ss

End // NMImportFileManager

Function ReadPclampFormat( file )
	String file // external ABF data file
	
	String fileID = ReadPclampString( file, 0, 4 ) // file ID signature
	
	KillWaves /Z NM_ReadPclampWave0, NM_ReadPclampWave1
	
	strswitch( fileID )
		case "ABF ":
			return 1
		case "ABF2":
			return 2
	endswitch
	
	return -1
	
End // ReadPclampFormat

Function ReadAxographFormat( file )
	String file // file to read
	
	Variable format
	
	Variable /G AXO_POINTER = 0
	
	if ( FileExistsAndNonZero( file ) == 0 )
		return -1
	endif
	
	String fileID = ReadAxoString( file, 4 )
	
	KillWaves /Z DumWave0
	
	strswitch( fileID )
	
		case "AxGr":
		
			format = ReadAxoVar( file, "short" )
			
			KillWaves /Z DumWave0
			
			if ( ( format == 1 ) || ( format == 2 ) )
				return format
			else
				return -1 // unknown file type
			endif
			
		case "AxGx":
		
			format = ReadAxoVar(file, "long")
			
			KillWaves /Z DumWave0
			
			if ( format >= 3 )
				return format
			else
				return -1
			endif
	
	endswitch
	
	return -1
	
End // ReadAxographFormat

Function /S GetPathName( fullpath, option )
	String fullpath // full-path name (i.e. "root:folder0:stats")
	Variable option // (0) return string containing folder or variable name (i.e. "stats") ( 1 ) return string containing path (i.e. "root:folder0:")
	
	if ( option == 1 )
		return ParseFilePath( 1, fullpath, ":", 1, 0 )
	else
		return ParseFilePath( 0, fullpath, ":", 1, 0 )
	endif

End // GetPathName

Function NM2Error( errorNum, objectName, objectValue )
	Variable errorNum
	String objectName
	String objectValue
	
	String functionName = GetRTStackInfo( 2 )
	
	return NMError( errorNum, functionName, objectName, objectValue )
	
End // NM2Error

Function NMComputerPixelsX()

	Variable v1, v2, xPixels = 1000

	String s0 = IgorInfo( 0 )
	
	s0 = StringByKey( "SCREEN1", s0, ":" )
	
	sscanf s0, "%*[ DEPTH= ]%d%*[ ,RECT= ]%d%*[ , ]%d%*[ , ]%d%*[ , ]%d", v1, v1, v1, v1, v2
	
	if ( ( numtype( v1 ) == 0 ) && ( v1 > xPixels ) )
		xPixels = v1
	endif
	
	return xPixels

End // NMComputerPixelsX

Function /S CurrentNMFolder( path )
	Variable path // ( 0 ) no path ( 1 ) with path
	
	String currentFolder = NMStrGet( "CurrentFolder" )
	
	if ( strlen( currentFolder ) == 0 )
		return ""
	endif
	
	if ( DataFolderExists( currentFolder ) == 0 )
		return ""
	endif
	
	if ( IsNMDataFolder( currentFolder ) == 0 )
		return ""
	endif
	
	if ( path == 0 )
		return GetPathName( currentFolder, 0 )
	endif
	
	return currentFolder

End // CurrentNMFolder

Function /S NMPrefixFolderDF( parent, wavePrefix )
	String parent, wavePrefix
	
	parent = CheckNMFolderPath( parent )
	
	if ( ( strlen( parent ) == 0 ) || !DataFolderExists( parent ) )
		return ""
	endif
	
	if ( strlen( wavePrefix ) == 0 )
		wavePrefix = StrVarOrDefault( parent + "CurrentPrefix", "" )
	endif
	
	if ( strlen( wavePrefix ) == 0 )
		return ""
	endif
	
	return parent + NMPrefixSubfolderPrefix + wavePrefix + ":"

End // NMPrefixFolderDF

Function /S CheckNMPrefixFolderPath( prefixFolder )
	String prefixFolder
	
	String parent

	if ( strlen( prefixFolder ) == 0 )
		prefixFolder = CurrentNMPrefixFolder()
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	if ( !DataFolderExists( prefixFolder ) )
		return ""
	endif
	
	if ( strsearch( prefixFolder, NMPrefixSubfolderPrefix, 0, 2 ) < 0 )
		return "" // wrong type of folder
	endif
	
	parent = GetPathName( prefixFolder, 1 )
	
	if ( strlen( parent ) == 0 )
		return LastPathColon( GetDataFolder( 1 ) + prefixFolder, 1 )
	endif
	
	return LastPathColon( prefixFolder, 1 )
	
End // CheckNMPrefixFolderPath

Function /S NMChanList( type, [ prefixFolder ] )
	String type // "NUM" or "CHAR"
	String prefixFolder
	
	Variable ccnt, numChannels
	String chanList = ""
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	for ( ccnt = 0; ccnt < numChannels; ccnt += 1 )
	
		strswitch( type )
			case "NUM":
				chanList = AddListItem( num2istr( ccnt ) , chanList, ";", inf )
				break
			case "CHAR":
				chanList = AddListItem( ChanNum2Char( ccnt ) , chanList, ";", inf )
				break
			default:
				return ""
		endswitch
		
	endfor
	
	return chanlist // returns chan list ( e.g. "0;1;2;" or "A;B;C;" )

End // NMChanList

Function ChanChar2Num( chanChar )
	String chanChar
	
	return char2num( UpperStr( chanChar ) ) - 65

End // ChanChar2Num

Function NMChanSelectListSet( chanList, [ prefixFolder, updateNM ] )
	String chanList // e.g. "0" or "0;1;2" or "0;2"
	String prefixFolder
	Variable updateNM
	
	Variable ccnt, chan, numChannels
	String chanStr, chanNumList
	
	String TabList = NMTabControlList()
	
	Variable currentTab = NMVarGet( "CurrentTab" )
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return NaN
	endif
	
	if ( ParamIsDefault( updateNM ) )
		updateNM = 1
	endif
	
	chanNumList = NMChanList( "NUM", prefixFolder = prefixFolder )
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	if ( ( numChannels <= 0 ) || ( ItemsInList( chanList ) == 0 ) )
		return Nan
	endif
	
	for ( ccnt = 0 ; ccnt < ItemsInList( chanList ) ; ccnt += 1 )
	
		chanStr = StringFromList( ccnt, chanList )
	
		if ( WhichListItem( chanStr , chanNumList ) < 0 )
			NMDoAlert( "Abort NMChanSelectListSet: channel is out of range: " + chanStr )
			return Nan
		endif
		
	endfor
	
	chan = str2num( StringFromList( 0, chanList ) )
	
	SetNMvar( prefixFolder + "CurrentChan", chan )
	SetNMstr( prefixFolder + NMChanSelectVarName, chanList )
	
	if ( updateNM )
	
		UpdateNMWaveSelectLists( prefixFolder = prefixFolder )
		//UpdateNMPanelChannelSelect()
	
		UpdateNMPanel( 1 )
		
	endif
	
	return chan

End // NMChanSelectListSet

Function /S NM2ErrorStr( errorNum, objectName, objectValue )
	Variable errorNum
	String objectName
	String objectValue
	
	String functionName = GetRTStackInfo( 2 )
	
	NMError( errorNum, functionName, objectName, objectValue )
	
	//return "NMError " + num2istr( errorNum )
	return ""
	
End // NM2ErrorStr

Function NMChanSelected( channel, [ prefixFolder ] )
	Variable channel
	String prefixFolder
	
	String chanList
	
	if ( ( numtype( channel ) > 0 )|| ( channel < 0 ) )
		return 0
	endif
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return 0
	endif
	
	chanList = StrVarOrDefault( prefixFolder + NMChanSelectVarName, "" )
	
	if ( ItemsInList( chanList ) == 0 )
		return 0
	endif
	
	if ( WhichListItem( num2istr( channel ) , chanList ) >= 0 )
		return 1
	endif
	
	return 0
	
End // NMChanSelected

Function /S NMWaveSelectList( channel, [ prefixFolder ] ) // returns a list of all currently selected waves in a channel
	Variable channel // ( -1 ) for currently selected channel ( -2 ) for all channels
	String prefixFolder
	
	Variable ccnt, cbgn, cend, numChannels
	String strVarName, wList = ""
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	if ( channel == -1 )
		cbgn = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
		cend = cbgn
	elseif ( channel == -2 )
		cbgn = 0
		cend = numChannels - 1
	elseif ( ( channel >= 0 ) && ( channel < numChannels ) )
		cbgn = channel
		cend = channel
	else
		//return NM2ErrorStr( 10, "channel", num2str( channel ) )
		return ""
	endif
	
	UpdateNMWaveSelectLists( prefixFolder = prefixFolder )
	
	for ( ccnt = cbgn ; ccnt <= cend ; ccnt += 1 )
		strVarName = prefixFolder + NMWaveSelectVarName + ChanNum2Char( ccnt )
		wList += StrVarOrDefault( strVarName , "" )
	endfor
	
	return wList

End // NMWaveSelectList

Function /S NextWaveName2( datafolder, prefix, chanNum, overwrite ) 
	String datafolder // data folder ( enter "" for current data folder )
	String prefix // wave prefix name
	Variable chanNum // channel number ( pass -1 for none )
	Variable overwrite // overwrite flag: ( 1 ) return last name in sequence ( 0 ) return next name in sequence
	
	Variable waveNum = NextWaveNum( datafolder, prefix, chanNum, overwrite )
	
	return GetWaveName( prefix, chanNum, waveNum )
	
End // NextWaveName2

Function NMMainVarGet( varName )
	String varName
	
	Variable defaultVal = NaN
	
	strswitch( varName )
	
		case "OverWriteMode":
			defaultVal = 1
			break
	
		case "Bsln_Method":
			defaultVal = 1
			break
			
		case "Bsln_Bgn":
			defaultVal = 0
			break
		
		case "Bsln_End":
			defaultVal = 10
			break
		
		case "WaveDetailsOn":
			defaultVal = 1
			break
			
		default:
			NMDoAlert( "NMMainVar Error : no variable called " + NMQuotes( varName ) )
			return NaN
	
	endswitch
	
	return NumVarOrDefault( NMMainDF+varName, defaultVal )
	
End // NMMainVarGet

Function /S NMMainHistory( mssg, chan, wList, namesFlag )
	String mssg
	Variable chan
	String wList // wave list ";"
	Variable namesFlag // print wave names ( 0 ) no ( 1 ) yes
	
	String waveSelect = NMWaveSelectGet()
	
	strswitch( waveSelect )
		case "This Wave":
			waveSelect = "Wave " + num2istr( CurrentNMWave() )
			break
	endswitch
	
	if ( strlen( mssg ) == 0 )
		mssg = "Chan " + ChanNum2Char( chan ) + " : " + waveSelect + " : N = " + num2istr( ItemsInlist( wList ) )
	else
		mssg += " : Chan " + ChanNum2Char( chan ) + " : " + waveSelect + " : N = " + num2istr( ItemsInlist( wList ) )
	endif
	
	if ( namesFlag == 1 )
		mssg += " : " + wList
	endif
	
	NMHistory( mssg )
	
	return mssg

End // NMMainHistory

Function NMPrefixAdd( addList [ history ] )
	String addList // prefix list to add
	Variable history // print function command to history ( 0 ) no ( 1 ) yes
	
	String prefixList = NMStrGet( "PrefixList" )
	String vlist = ""
	
	if ( !ParamIsDefault( history ) && history )
		vlist = NMCmdStr( addList, vlist )
		NMCmdHistory( "", vlist )
	endif
	
	if ( ItemsInList( addList ) == 0 )
		return -1
	endif
	
	prefixList = NMAddToList( addList, prefixList, ";" )
	
	SetNMstr( NMDF+"PrefixList", prefixList )
	
	UpdateNMPanelPrefixMenu()
	
	return 0

End // NMPrefixAdd

Function ChanGraphsUpdate() // update channel display graphs

	Variable ccnt, numChannels = NMNumChannels()
	Variable makeChanWave = 1
	
	for ( ccnt = 0; ccnt < numChannels; ccnt+=1 )
		ChanGraphUpdate( ccnt, makeChanWave )
		ChanGraphControlsUpdate( ccnt )
	endfor
	
	if ( numChannels == 0 )
		ChanGraphClose( -3, 0 ) // close unnecessary graphs
	endif

End // ChanGraphsUpdate

Function /S DeleteWaves( wList )
	String wList // wave list ( seperator ";" )
	
	String wName, outList = "", badList = wList
	Variable wcnt, move
	
	Variable numWaves = ItemsInList( wList )
	
	if ( numWaves == 0 )
		return ""
	endif
	
	for ( wcnt = 0; wcnt < numWaves; wcnt += 1 )
	
		if ( NMProgressTimer( wcnt, numWaves, "Deleting Waves..." ) == 1 )
			break // cancel wave loop
		endif
	
		wName = StringFromList( wcnt, wList )
		
		if ( WaveExists( $wName ) == 0 )
			continue
		endif
		
		KillWaves /Z $wName
		
		if ( WaveExists( $wName ) == 0 )
			outList = AddListItem( wName, outList, ";", inf )
			badList = RemoveFromList( wName, badList )
		endif
	
	endfor
	
	//NMUtilityAlert( thisfxn, badList )
	
	return outList

End // DeleteWaves

Function NMPrefixFoldersRenameWave( oldName, newName ) // rename a wave in all the prefix folder wave lists
	String oldName // old wave name
	String newName // new wave name ( "" ) empty string to remove name
	
	Variable pcnt, ccnt, numChannels, scnt, newNamePrefixMatch
	String prefixName, prefixFolder
	String matchStr, strVarList, strVarName
	
	String prefixList = NMPrefixSubfolderList( 0 ) // prefix list in current folder
	
	for ( pcnt = 0 ; pcnt < ItemsInList( prefixList ) ; pcnt += 1 )
		
		prefixName = StringFromList( pcnt, prefixList )
		
		if ( ( strlen( newName ) > 0 ) && ( strsearch( newName, prefixName, 0, 2 ) == 0 ) )
			newNamePrefixMatch = 1
		else
			newNamePrefixMatch = 0
		endif
		
		//if ( ( strlen( newName ) > 0 ) && ( newNamePrefixMatch == 0 ) )
		//	continue // newName does not match this prefix
		//endif
		
		prefixFolder = NMPrefixFolderDF( "", prefixName )
		
		strVarName = prefixFolder + "PrefixSelect_WaveList"
		NMPrefixFoldersRenameWave2( strVarName, oldName, newName, newNamePrefixMatch )
		
		matchStr = "Chan_WaveList*"
		strVarList = NMFolderStringList( prefixFolder, matchStr, ";", 0 ) // list of all channel wave lists
		
		for ( scnt = 0 ; scnt < ItemsInList( strVarList ) ; scnt += 1 )
			strVarName = prefixFolder + StringFromList( scnt, strVarList )
			NMPrefixFoldersRenameWave2( strVarName, oldName, newName, newNamePrefixMatch )
		endfor
		
		matchStr = "*" + NMSetsListSuffix + "*"
		strVarList = NMFolderStringList( prefixFolder, matchStr, ";", 0 ) // list of all Sets

		for ( scnt = 0 ; scnt < ItemsInList( strVarList ) ; scnt += 1 )
			strVarName = prefixFolder + StringFromList( scnt, strVarList )
			NMPrefixFoldersRenameWave2( strVarName, oldName, newName, newNamePrefixMatch )
		endfor
		
	endfor
	
End // NMPrefixFoldersRenameWave

Function UpdateNMWaveSelectLists( [ prefixFolder ] )
	String prefixFolder

	Variable ccnt, icnt, OK, numChannels, currentWave
	Variable grpNum = Nan, and = -1, or = -1
	String strVarName, strVarList, wList, swList, swList2, gwList
	String chanList, setName, setName2, grpList, setList, waveSelect
	
	Variable grpsOn = NMVarGet( "GroupsOn" )
	Variable setXclude = NMSetXType()

	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return 0
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	currentWave = NumVarOrDefault( prefixFolder + "CurrentWave", 0 )
	
	setList = NMSetsList( prefixFolder = prefixFolder )

	waveSelect = StrVarOrDefault( prefixFolder + "WaveSelect", "NONE" )
	
	waveSelect = ReplaceString( " & ", waveSelect, " x " )
	waveSelect = ReplaceString( " && ", waveSelect, " x " )
	waveSelect = ReplaceString( " | ", waveSelect, " + " )
	waveSelect = ReplaceString( " || ", waveSelect, " + " )
	
	and = strsearch( waveSelect, " x ", 0 )
	or = strsearch( waveSelect, " + ", 0 )
	
	if ( grpsOn )
		grpNum = NMGroupsNumFromStr( waveSelect )
	endif
	
	NMPrefixFolderStrVarKill( NMWaveSelectVarName, prefixFolder = prefixFolder )
	
	if ( StringMatch( waveSelect, "This Wave" ) )
	
		for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
		
			if ( !NMChanSelected( ccnt, prefixFolder = prefixFolder ) )
				continue
			endif
			
			wList = NMChanWaveName( ccnt, currentWave, prefixFolder = prefixFolder ) + ";"
			wList = NMSetXcludeWaveList( wList, ccnt, prefixFolder = prefixFolder )
			strVarName = prefixFolder + NMWaveSelectVarName + ChanNum2Char( ccnt )
			SetNMstr( strVarName, wList )

		endfor
		
		OK = 1
	
	elseif ( StringMatch( waveSelect, "All" ) )
		
		for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
		
			if ( !NMChanSelected( ccnt, prefixFolder = prefixFolder ) )
				continue
			endif
			
			wList = NMChanWaveList( ccnt, prefixFolder = prefixFolder )
			wList = NMSetXcludeWaveList( wList, ccnt, prefixFolder = prefixFolder )
			strVarName = prefixFolder + NMWaveSelectVarName + ChanNum2Char( ccnt )
			SetNMstr( strVarName, wList )
			
		endfor
		
		OK = 1
		
	elseif ( WhichListItem( waveSelect, setList ) >= 0 )
	
		for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
			
			if ( !NMChanSelected( ccnt, prefixFolder = prefixFolder ) )
				continue
			endif
			
			swList = NMSetsWaveList( waveSelect, ccnt )
			
			if ( !StringMatch( waveSelect, "SetX" ) )
				swList = NMSetXcludeWaveList( swList, ccnt, prefixFolder = prefixFolder )
			endif
			
			strVarName = prefixFolder + NMWaveSelectVarName + ChanNum2Char( ccnt )
			SetNMstr( strVarName, swList )
			
		endfor
		
		OK = 1
	
	elseif ( StringMatch( waveSelect, "All Sets") )
		
		if ( setXclude )
			setList = RemoveFromList( "SetX", setList )
		endif
	
		for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
		
			if ( !NMChanSelected( ccnt, prefixFolder = prefixFolder ) )
				continue
			endif
		
			swList = ""
		
			for ( icnt = 0 ; icnt < ItemsInList( setList ) ; icnt += 1 )
				setName = StringFromList( icnt, setList )
				swList = NMAddToList( NMSetsWaveList( setName, ccnt ) , swList, ";" )
			endfor
			
			swList = NMSetXcludeWaveList( swList, ccnt, prefixFolder = prefixFolder )
			swList = OrderToNMChanWaveList( swList, ccnt, prefixFolder = prefixFolder )
			
			strVarName = prefixFolder + NMWaveSelectVarName + ChanNum2Char( ccnt )
			SetNMstr( strVarName, swList )
			
		endfor
		
		OK = 1
		
	elseif ( !grpsOn && StringMatch( waveSelect, "*Group*" ) )
	
		// error, nothing to do
		
	elseif ( grpsOn && StringMatch( waveSelect[0,4], "Group" ) )
	
		for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
		
			if ( !NMChanSelected( ccnt, prefixFolder = prefixFolder ) )
				continue
			endif
			
			gwList = NMGroupsWaveList( grpNum, ccnt )
			gwList = NMSetXcludeWaveList( gwList, ccnt, prefixFolder = prefixFolder )
			
			strVarName = prefixFolder + NMWaveSelectVarName + ChanNum2Char( ccnt )
			SetNMstr( strVarName, gwList )
			
		endfor
		
		OK = 1
		
	elseif ( grpsOn && StringMatch( waveSelect, "All Groups" ) )
	
		grpList = NMGroupsList( 0 )
		
		for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
		
			if ( !NMChanSelected( ccnt, prefixFolder = prefixFolder ) )
				continue
			endif
		
			gwList = ""
		
			for ( icnt = 0 ; icnt < ItemsInList( grpList ) ; icnt += 1 )
			
				grpNum = str2num( StringFromList( icnt, grpList ) )
				
				if ( numtype( grpNum ) > 0 )
					continue
				endif
				
				gwList = NMAddToList( NMGroupsWaveList( grpNum, ccnt ), gwList, ";" )
				
			endfor
			
			gwList = NMSetXcludeWaveList( gwList, ccnt, prefixFolder = prefixFolder )
			gwList = OrderToNMChanWaveList( gwList, ccnt, prefixFolder = prefixFolder )
			
			strVarName = prefixFolder + NMWaveSelectVarName + ChanNum2Char( ccnt )
			SetNMstr( strVarName, gwList )
			
		endfor
		
		OK = 1
		
	elseif ( grpsOn && ( strsearch( waveSelect, "Group", 0, 2 ) > 0 ) && ( ( and > 0 ) || ( or > 0 ) ) ) // Set && Group, Set || Group
	
		if ( and > 0 )
			setName = waveSelect[0, and-1]
		elseif ( or > 0 )
			setName = waveSelect[0, or-1]
		endif
		
		setName = ReplaceString( " ", setName, "" )
		
		grpList = ""
	
		if ( numtype( grpNum ) == 0 )
		
			grpList = num2istr( grpNum )
			
		elseif ( strsearch( waveSelect, "All Groups", 0, 2 ) > 0 )
		
			grpList = NMGroupsList( 0 )
			
		endif
		
		for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
		
			if ( !NMChanSelected( ccnt, prefixFolder = prefixFolder ) )
				continue
			endif
			
			wList = ""
			swList = NMSetsWaveList( setName, ccnt )
		
			for ( icnt = 0 ; icnt < ItemsInList( grpList ) ; icnt += 1 )
			
				grpNum = str2num( StringFromList( icnt, grpList ) )
				
				if ( numtype( grpNum ) > 0 )
					continue
				endif
				
				gwList = NMGroupsWaveList( grpNum, ccnt )
				
				if ( and > 0 )
					gwList = NMAndLists( swList, gwList, ";" )
				elseif ( or > 0 )
					gwList = NMAddToList( swList, gwList, ";" )
				endif
				
				wList = NMAddToList( gwList, wList, ";" )
				
			endfor
			
			wList = NMSetXcludeWaveList( wList, ccnt, prefixFolder = prefixFolder )
			wList = OrderToNMChanWaveList( wList, ccnt, prefixFolder = prefixFolder )
			
			strVarName = prefixFolder + NMWaveSelectVarName + ChanNum2Char( ccnt )
			SetNMstr( strVarName, wList )
			
		endfor
		
		NMWaveSelectAdd( waveSelect )
		
		OK = 1
		
	elseif ( ( and > 0 ) || ( or > 0 ) ) // Set && Set, Set || Set
	
		if ( and > 0 )
			setName = waveSelect[0, and-1]
			setName2 = waveSelect[and+3, inf]
		elseif ( or > 0 )
			setName = waveSelect[0, or-1]
			setName2 = waveSelect[or+3, inf]
		endif
		
		setName = ReplaceString( " ", setName, "" )
		setName2 = ReplaceString( " ", setName2, "" )
		
		for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
		
			if ( !NMChanSelected( ccnt, prefixFolder = prefixFolder ) )
				continue
			endif
			
			wList = ""
			swList = NMSetsWaveList( setName, ccnt )
			swList2 = NMSetsWaveList( setName2, ccnt )
				
			if ( and > 0 )
				swList2 = NMAndLists( swList, swList2, ";" )
			elseif ( or > 0 )
				swList2 = NMAddToList( swList, swList2, ";" )
			endif
			
			wList = NMAddToList( swList2, wList, ";" )
			
			wList = NMSetXcludeWaveList( wList, ccnt, prefixFolder = prefixFolder )
			wList = OrderToNMChanWaveList( wList, ccnt, prefixFolder = prefixFolder )
			
			strVarName = prefixFolder + NMWaveSelectVarName + ChanNum2Char( ccnt )
			SetNMstr( strVarName, wList )
			
		endfor
		
		NMWaveSelectAdd( waveSelect )
		
		OK = 1
		
	endif
	
	if ( OK )
		UpdateNMWaveSelectCount( prefixFolder = prefixFolder )
	endif
	
	NMPrefixFolderGetOldGlobals()
	
	return OK
	
End // UpdateNMWaveSelectLists

Function UpdateNMPanelSets( recount ) // udpate Sets display
	Variable recount
	
	Variable icnt, setValue, count, locked, r
	String ttle, setList, setName, ctrlName
	
	Variable NMr = str2num( StringFromList( 0, NMRedStr, "," ) )
	Variable NMg = str2num( StringFromList( 1, NMRedStr, "," ) )
	Variable NMb = str2num( StringFromList( 2, NMRedStr, "," ) )
	
	Variable dis = NMPanelDisable()
	
	Variable currentChan = CurrentNMChannel()
	Variable currentWave = CurrentNMWave()
	
	String wname = CurrentNMWaveName()
	
	//PopupMenu NM_SetsMenu, disable=dis, value=NMSetsMenu(), mode=1, win=$NMPanelName
	
	if ( recount == 1 )
		UpdateNMSetsDisplayCount()
		UpdateNMWaveSelectCount()
	endif
	
	for ( icnt = 0 ; icnt <= 2 ; icnt += 1 )
	
		setName = NMSetsDisplayName( icnt )
		
		locked = IsNMSetLocked( setName )
		
		if ( locked == 1 )
			r = NMr
		else
			r = 0
		endif
		
		ttle = " "
		setValue = 0
		dis = 2
		
		if ( ( strlen( setName ) > 0 ) && ( AreNMSets( setName ) == 1 ) )
		
			setList = NMSetsWaveList( setName, currentChan )
			
			count = NMVarGet( "SumSet" + num2istr( icnt ) )
		
			ttle = setName + " : " + num2str( count ) + " "
		
			if ( ( ItemsInList( setList ) > 0 ) && ( WhichListItem( wname, setList ) >= 0 ) )
				setValue = 1
			endif
			
			dis = 0
		
		endif
		
		ctrlName = "NM_Set" + num2istr( icnt ) + "Check"
		
		//CheckBox $ctrlName, title=ttle, value=(setValue), fcolor=(r,NMg,NMb), disable=dis, win=$NMPanelName
	
	endfor

End // UpdateNMPanelSets

Function /S NMCmdStrOptional( strVarName, strVar, varList )
	String strVarName
	String strVar, varList
	
	if ( strsearch( strVar, ",", 0 ) > 0 ) // this is a "," list
	
		return AddListItem( "\ol" + strVarName + " = " + strVar, varList, ";", inf )
		
	elseif ( strsearch( strVar, ";", 0 ) > 0 ) // this is a ";" list
		
		strVar = ReplaceString( ";", strVar, "," )
		
		return AddListItem( "\ol" + strVarName + " = " + strVar, varList, ";", inf )
		
	endif

	return AddListItem( "\os" + strVarName + " = " + strVar, varList, ";", inf )

End // NMCmdStrOptional

Function /S NMCmdNumOptional( varName, numVar, varList )
	String varName
	Variable numVar
	String varList

	return AddListItem( varName + " = " + num2str( numVar ), varList, ";", inf )

End // NMCmdNumOptional

Function NMon( on )
	Variable on // ( 0 ) off ( 1 ) on ( -1 ) toggle
	
	if ( on == -1 )
		on = BinaryInvert( NMVarGet( "NMon" ) )
	else
		on = BinaryCheck( on )
	endif
	
	SetNMvar( NMDF+"NMon", on )
	
	if ( on == 0 )
		DoWindow /K $NMPanelName
	else
//		MakeNMPanel()
		CheckCurrentFolder()
	endif
	
	return on

End // NMon

Function BinaryCheck( n )
	Variable n
	
	if ( n == 0 )
		return 0
	else
		return 1
	endif

End // BinaryCheck

Function NMTab( tabName ) // change NMPanel tab
	String tabName
	
	String tabList = NMTabControlList()
	
	Variable tab = TabNumber( tabName, tabList ) // NM_TabManager.ipf
	
	Variable configsOn = NMVarGet( "ConfigsDisplay" )
	
	if ( tab < 0 )
		return -1
	endif
	
	Variable lastTab = NMVarGet( "CurrentTab" )
	
	CheckCurrentFolder()
	
	if ( ( tab != lastTab ) || ( configsOn == 1 ) )
	
		SetNMvar( NMDF+"CurrentTab", tab )
		NMConfigsListBoxWavesUpdate( "" )
		
		if ( configsOn == 1 )
			Execute /Z "NM" + tabName + "ConfigEdit()"
		endif
		
		ChangeTab( lastTab, tab, tabList ) // NM_TabManager.ipf
		//ChanGraphsUpdate() // removed 29 March 2012 because it conflicted with Event Tab
		
	endif
	
	DoWindow /F $NMPanelName

End // NMTab

Function /S NMFolderChange( folderName, [ update, history ] ) // change the active folder
	String folderName
	Variable update
	Variable history // print function command to history ( 0 ) no ( 1 ) yes
	
	String vlist = NMCmdStrOptional( "folder", folderName, "" )
	
	if ( ParamIsDefault( update ) )
		update = 1
	else
		vlist = NMCmdNumOptional( "update", update, vlist )
	endif
	
	if ( !ParamIsDefault( history ) && history )
		NMCmdHistory( "", vlist )
	endif
	
	if ( strlen( folderName ) == 0 )
		return ""
	endif
	
	folderName = CheckNMFolderPath( folderName )
	
	if ( DataFolderExists( folderName ) == 0 )
		NMDoAlert( "Abort NMFolderChange: " + folderName + " does not exist." )
		return ""
	endif
	
	if ( IsNMFolder( folderName, "NMLog" ) == 1 )
		LogDisplayCall( folderName )
		return ""
	endif
	
	if ( IsNMDataFolder( folderName ) == 0 )
		return ""
	endif
	
	if ( strlen( NMFolderListName( folderName ) ) == 0 )
		NMFolderListAdd( folderName )
	endif
	
	ChanScaleSave( -1 )
	
	SetDataFolder $folderName
	
	SetNMstr( NMDF+"CurrentFolder", GetDataFolder( 1 ) )
	
	if ( update )
		ChanGraphsReset()
		NMChanWaveListSet( 0 ) // check channel wave names
		UpdateNM( 1 )
	endif
	
	return folderName

End // NMFolderChange

Function /S NMFolderNew( folderNameList, [ update, history ] )
	String folderNameList // list of folder names, or "" for next default name
	Variable update
	Variable history // print function command to history ( 0 ) no ( 1 ) yes
	
	Variable icnt
	String folderName, fList = ""
	
	String vlist = NMCmdStr( folderNameList, "" )
	
	if ( ParamIsDefault( update ) )
		update = 1
	else
		vlist = NMCmdNumOptional( "update", update, vlist )
	endif
	
	if ( !ParamIsDefault( history ) && history )
		NMCmdHistory( "", vlist )
	endif
	
	if ( ItemsInList( folderNameList ) == 0 )
		folderNameList = FolderNameNext( "" )
	endif
	
	for ( icnt = 0 ; icnt < ItemsInList( folderNameList ) ; icnt += 1 )
	
		folderName = StringFromList( icnt, folderNameList )
	
		if ( strlen( folderName ) == 0 )
			folderName = FolderNameNext( "" )
		else
			folderName = GetPathName( folderName, 0 )
		endif
		
		folderName = CheckFolderName( folderName )
		
		if ( strlen( folderName ) == 0 )
			continue
		endif
		
		folderName = "root:" + folderName + ":"
	
		if ( DataFolderExists( folderName ) == 1 )
			return "" // already exists
		endif
		
		NewDataFolder /S $RemoveEnding( folderName, ":" )
		
		SetNMstr( NMDF+"CurrentFolder", GetDataFolder( 1 ) )
		
		CheckNMDataFolder( folderName )
		NMFolderListAdd( folderName )
		
		fList = AddListItem( folderName, fList, ";", inf )
	
	endfor
	
	if ( update )
		ChanGraphsReset()
		UpdateNM( 1 )
	endif
	
	return fList

End // NMFolderNew

Function NMPrefixSelect( wavePrefix, [ noPrompts ] ) // change to a new wave prefix
	String wavePrefix // wave prefix name, or ( "" ) for current prefix
	Variable noPrompts // ( 0 ) no ( 1 ) yes
	
	Variable ccnt, ccnt2, wcnt, numChannels, oldNumChannels, numItems, numWaves
	Variable oldWaveListExists, madePrefixFolder, prmpt = 1
	Variable ss, seqnum
	
	String wlist, wName, wName2, newList, chanstr, chanList = "", oldList = "", prefix, prefixFolder
	
	String currentFolder = CurrentNMFolder( 1 )
	
	if ( strlen( wavePrefix ) == 0 )
		wavePrefix = StrVarOrDefault( currentFolder+"CurrentPrefix", "" )
	endif
	
	if ( strlen( wavePrefix ) == 0 )
		return -1
	endif
	
	prefixFolder = NMPrefixFolderDF( currentFolder, wavePrefix )
	
	newList = WaveList( wavePrefix + "*", ";", "Text:0" )
	numWaves = ItemsInList( newList )

	if ( numWaves <= 0 )
		NMDoAlert( "No waves detected with prefix " + NMQuotes( wavePrefix ) )
		return -1
	endif
	
	if ( strlen( prefixFolder ) > 0 )
		oldList = StrVarOrDefault( prefixFolder+"PrefixSelect_WaveList", "" )
		oldNumChannels = NumVarOrDefault( prefixFolder+"NumChannels", 0 )
	endif
	
	if ( StringMatch( newList, oldList ) == 1 )
	
		numChannels = NumVarOrDefault( prefixFolder+"NumChannels", 0 )
		numWaves = NumVarOrDefault( prefixFolder+"NumWaves", 0 )
		oldWaveListExists = 1
		prmpt = 0
		
	else
	
		numChannels = 0
	
		for ( ccnt = 0; ccnt <= 25; ccnt += 1 ) // detect multiple channels
		
			wlist = NMChanWaveListSearch( wavePrefix, ccnt )
			
			if ( ItemsInList( wlist ) > 0 )
			
				chanstr = ChanNum2Char( ccnt )
				
				for ( wcnt = 0 ; wcnt < ItemsInList( wlist ) ; wcnt += 1 )
				
					wName = StringFromList( wcnt, wList )
					
					ss = strsearch( wName, chanstr, inf, 3 )
					
					if ( ss < 0 )
						break // something is wrong
					endif
					
					prefix = wName[ 0, ss - 1 ]
					seqnum = str2num( wName[ ss + 1, inf ] )
					
					chanList = chanstr + ";"
					
					for ( ccnt2 = ccnt + 1; ccnt2 <= 25; ccnt2 += 1 )
					
						wName2 = prefix + ChanNum2Char( ccnt2 ) + num2str( seqnum )
					
						if ( WaveExists( $wName2 ) == 1 )
							chanList = AddListItem( ChanNum2Char( ccnt2 ), chanList, ";", inf )
						endif
					
					endfor
					
					if ( ItemsInList( chanList ) <= 1 )
						break
					endif
					
					if ( numChannels == 0 )
						numChannels = ItemsInList( chanList )
					elseif ( ItemsInList( chanList ) != numChannels )
						numChannels = -1
						break
					endif
				
				endfor
				
				break
				
			endif
			
		endfor
		
		if ( numChannels > 1 )
			numWaves = ItemsInList( wlist )
		endif
	
	endif
	
	if ( numChannels <= 0 )
		numChannels = 1
	endif
	
	if ( ( prmpt == 1 ) && ( numChannels > 1 ) && ( noPrompts == 0 ) )
	
		Prompt numChannels, "number of channels:"
		Prompt numWaves, "waves per channel:"
	
		DoPrompt "Check Channel Configuration", numChannels, numWaves
		
		if ( V_Flag == 1 )
			return -1 // cancel
		endif
		
		if ( numChannels == 1 )
			newList = WaveList( wavePrefix + "*", ";", "Text:0" )
			numWaves = ItemsInList( newList )
		endif
		
	endif
	
	SetNMstr( "CurrentPrefix", wavePrefix ) // change to new prefix
	
	if ( ( strlen( prefixFolder ) > 0 ) && ( DataFolderExists( prefixFolder ) == 1 ) )
	
		CheckNMPrefixFolder( prefixFolder, numChannels, numWaves )
		
	else
	
		prefixFolder = NMPrefixFolderMake( currentFolder, wavePrefix, numChannels, numWaves )
	
		if ( strlen( prefixFolder ) > 0 )
			madePrefixFolder = 1
		endif
	
	endif
	
	if ( DataFolderExists( prefixFolder ) == 0 )
		NMDoAlert( "Failed to create prefix subfolder for " + NMQuotes( wavePrefix ) )
		return -1
	endif
	
	SetNMstr( prefixFolder+"PrefixSelect_WaveList", newList )
	
	if ( oldWaveListExists == 0 )
		NMChanWaveListSet( 1 )
	endif
	
	if ( StringMatch( wavePrefix, "Pulse*" ) == 1 )
		NMChanUnits2Labels()
	endif
	
	CheckChanSubfolder( -2 )
	ChanGraphsReset()
	
	//UpdateNM( 1 ) // UPDATE TAB
	
	if ( oldNumChannels != numChannels )
	
		if ( ( oldNumChannels > 0 ) && ( numChannels != oldNumChannels ) )
		
			//DoAlert 1, "Alert: the number of channels for prefix " + NMQuotes( wavePrefix ) + " has changed. Do you want to update your Sets and Groups to correspond to the new number of channels?"
			
			//if ( V_Flag == 1 )
				NMSetsListsUpdateNewChannels()
				NMGroupsListsUpdateNewChannels()
			//endif
			
		endif
		
		NMChannelGraphSet( channel = -2, reposition = 1 )
		
	endif
	
	if ( madePrefixFolder == 1 )
	
		NMChanSelect( "A" )
		NMCurrentWaveSet( 0 )
		
		if ( noPrompts == 0 )
			//NMPrefixSelectCheckDeltaX()
		endif
		
	endif
	
	if ( CurrentNMChannel() >= numChannels )
		NMChanSelect( "A" )
	endif
	
	if ( strlen( NMWaveSelectGet() ) == 0 )
		NMWaveSelect( "All" )
	else
		NMWaveSelect( "Update" )
	endif 
	
	NMCurrentWaveSet( CurrentNMWave() )
	
	NMSetsPanelUpdate( 1 )
	NMGroupsPanelUpdate( 1 )
	
	return 0

End // NMPrefixSelect

Function NMConfigVarSet( tabName, varName, value )
	String tabName
	String varName
	Variable value
	
	if ( strlen( tabName ) == 0 )
		tabName = CurrentNMTabName()
	endif
	
	if ( StringMatch( tabName, "NM" ) )
		tabName = "NeuroMatic"
	endif
	
	String cdf = ConfigDF( tabName )
	String pdf = NMPackageDF( tabName )
	
	if ( exists( cdf + varName ) != 2 )
		return -1
	endif
	
	SetNMvar( cdf + varName, value )
	SetNMvar( pdf + varName, value )
	
	return 0
	
End // NMConfigVarSet

Function NMConfigStrSet( tabName, strVarName, strValue )
	String tabName
	String strVarName
	String strValue
	
	if ( strlen( tabName ) == 0 )
		tabName = CurrentNMTabName()
	endif
	
	if ( StringMatch( tabName, "NM" ) )
		tabName = "NeuroMatic"
	endif
	
	String cdf = ConfigDF( tabName )
	String pdf = NMPackageDF( tabName )
	
	if ( exists( cdf + strVarName ) != 2 )
		return -1
	endif
	
	SetNMstr( cdf + strVarName,strValue )
	SetNMstr( pdf + strVarName, strValue )
	
	return 0
	
End // NMConfigStrSet

Function NMCurrentWaveSet( waveNum [ prefixFolder, updateNM ] )
	Variable waveNum
	String prefixFolder
	Variable updateNM
	
	Variable grpNum, numWaves
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return NaN
	endif
	
	if ( ParamIsDefault( updateNM ) )
		updateNM = 1
	endif
	
	numWaves = NumVarOrDefault( prefixFolder + "NumWaves", 0 )
	
	if ( waveNum < 0 )
		waveNum = 0
	elseif ( waveNum >= numWaves )
		waveNum = numWaves - 1
	endif
	
	if ( numtype( waveNum ) > 0 )
		waveNum = NumVarOrDefault( prefixFolder + "CurrentWave", 0 )
	endif
	
	grpNum = NMGroupsNum( waveNum, prefixFolder = prefixFolder )
	
	SetNMvar( prefixFolder+"CurrentWave", waveNum )
	SetNMvar( prefixFolder+"CurrentGrp", grpNum )
	
	SetNMvar( NMDF+"CurrentWave", waveNum )
	SetNMvar( NMDF+"CurrentGrp", grpNum )
	SetNMstr( NMDF+"CurrentGrpStr", NMGroupsStr( grpNum ) )
	
	if ( updateNM )
		UpdateCurrentWave()
	endif
	
	return waveNum
	
End // NMCurrentWaveSet

Function NMWaveInc( waveInc )
	Variable waveInc // increment value or ( 0 ) for "As Wave Select"
	
	if ( ( numtype( waveInc ) > 0 ) || ( waveInc < 0 ) )
		waveInc = 1
	endif
	
	SetNMvar( NMDF+"WaveSkip", waveInc )
	
	return waveInc
	
End // NMWaveInc

Function NMWaveSelect( waveSelect, [ prefixFolder, updateNM ] )
	String waveSelect // wave select function (e.g. "All" or "Set1" or "Group1")
	String prefixFolder
	Variable updateNM
	
	String saveWaveSelect
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return NaN
	endif
	
	if ( ParamIsDefault( updateNM ) )
		updateNM = 1
	endif
	
	saveWaveSelect = StrVarOrDefault( prefixFolder + "WaveSelect", "All" )
	
	if ( ( strlen( waveSelect ) == 0 ) || StringMatch( waveSelect, "Update" ) )
		waveSelect = StrVarOrDefault( prefixFolder + "WaveSelect", "" )
	else
		SetNMstr( prefixFolder + "WaveSelect", waveSelect )
	endif
	
	if ( !UpdateNMWaveSelectLists( prefixFolder = prefixFolder ) )
		SetNMstr( prefixFolder+"WaveSelect", saveWaveSelect ) // something went wrong
		NMDoAlert( "Abort NMWaveSelect: bad wave selection: " + waveSelect )
	endif
	
	if ( updateNM )
		UpdateNMPanel(1 )
		//UpdateNMPanelWaveSelect()
		//NMAutoTabCall()
	endif
	
	return 0

End // NMWaveSelect

Function NMConfigsDisplay( on )
	Variable on // ( 0 ) off ( 1 ) tab configs on ( 2 ) NM configs on
	
	String tabName = CurrentNMTabName()
	String tabList = NMTabControlList()
	Variable tabNum = TabNumber( tabName, tabList )
	
	if ( on == 1 )
		EnableTab( tabNum, tabList, 0 ) // disable
		Execute /Z tabName + "Tab( 0 )" // run specific disable tab function
		Execute /Z "NM" + tabName + "ConfigEdit()" // extra tab function, may not exist
	elseif ( on == 2 )
		EnableTab( tabNum, tabList, 0 ) // disable
		Execute /Z tabName + "Tab( 0 )" // run specific disable tab function
	endif
	
	SetNMvar( NMDF+"ConfigsDisplay", on )
	
	if ( on > 0 )
		NMConfigsListBoxWavesUpdate( "" )
	endif
	
	UpdateNMPanel( 1 )
	
End // NMConfigsDispaly

Function /S NMChanWaveName( channel, waveNum, [ prefixFolder ] )
	Variable channel // ( -1 ) for current channel
	Variable waveNum // ( -1 ) for current wave
	String prefixFolder
	
	String wList
	
	// return name of wave from wave ChanWaveList, given channel and wave number
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif

	if ( channel == -1 )
		channel = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
	endif
	
	if ( waveNum == -1 )
		waveNum = NumVarOrDefault( prefixFolder + "CurrentWave", 0 )
	endif
	
	wList = NMChanWaveList( channel, prefixFolder = prefixFolder )
	
	return StringFromList( waveNum, wList )

End // NMChanWaveName

Function UpdateNMPanel( updateTab )
	Variable updateTab
	
	Variable icnt, dis
	String ctrlName
	
	if (WinType( NMPanelName ) == 0)
		return 0
	endif
	
	if ( !NMVarGet( "NMPanelUpdate" ) )
		return 0
	endif
	
	if ( updateTab == 1 )
		UpdateNMTab()
	endif
	
	UpdateNMPanelTabNames()
	UpdateNMPanelVariables()
	
	UpdateNMPanelFolderMenu()
	UpdateNMPanelGroupMenu()
	UpdateNMPanelSetVariables()
	UpdateNMPanelPrefixMenu()
	UpdateNMPanelChanSelect()
	UpdateNMPanelWaveSelect()
	UpdateNMPanelSets( 1 )
	
	//CheckBox NM_Configs, win=$NMPanelName, value=NMVarGet("ConfigsDisplay")

End // UpdateNMPanel

Function /S NMComputerType()

	String s0 = IgorInfo( 2 )
	
	strswitch( s0 )
		case "Macintosh":
			return "mac"
	endswitch
	
	return "pc"

End // NMComputerType

Function NMHistoryManager( message, where ) // print notes to Igor history and/or notebook
	String message
	Variable where // use negative numbers for command history
	
	String nbName
	
	if ( where == 0 )
		return 0
	endif
	
	if ( ( abs( where ) == 1 ) || ( abs( where ) == 3 ) )
		Print message // Igor History
	endif
	
	if ( ( where == 2 ) || ( where == 3 ) ) // results notebook
		nbName = NMNotebookName( "results" )
		NMNotebookResults()
		Notebook $nbName selection={endOfFile, endOfFile}
		NoteBook $nbName text=NMCR + message
	elseif ( ( where == -2 ) || ( where == -3 ) ) // command notebook
		nbName = NMNotebookName( "commands" )
		NMNotebookCommands()
		Notebook $nbName selection={endOfFile, endOfFile}
		NoteBook $nbName text=NMCR + message
	endif

End // NMHistoryManager

Function /S ConfigDF( fname ) // return Configurations full-path folder name
	String fname // config folder name ( i.e. "NeuroMatic", "Main", "Stats" )
	
	return NMPackageDF( "Configurations:" + fname )
	
End // ConfigDF

Function /S NMTabListConvert( tabCntrlList )
	String tabCntrlList // ( '' ) for current
	
	Variable icnt
	
	String simpleList = ""
	
	if ( strlen( tabCntrlList ) == 0 )
		tabCntrlList = NMStrGet( "TabControlList" )
	endif
	
	for ( icnt = 0; icnt < ItemsInList( tabCntrlList )-1; icnt += 1 )
		simpleList = AddListItem( TabName( icnt, tabCntrlList ), simpleList, ";", inf )
	endfor
	
	return simpleList
	
End // NMTabListConvert

Function /S TabWinName( tabList ) // extract window name from the tab list
	String tabList // list of tab names
	String name = ""
	
	name = StringFromList( ItemsInList( tabList, ";" )-1, tabList, ";" )
	name = StringFromList( 0, name, "," )
	
	return name

End // TabWinName

Function /S TabCntrlName( tabList ) // extract control name from the tab list
	String tabList // list of tab names
	String name = ""
	
	name = StringFromList( ItemsInList( tabList, ";" )-1, tabList, ";" )
	name = StringFromList( 1, name, "," )
	
	return name

End // TabCntrlName

Function /S NMTabPrefix( tabName )
	String tabName
	
	String fxn = "NM" + tabName + "TabPrefix"
	String prefix = StrVarOrDefault( NMDF+"TabPrefix" + tabName, "" )
	
	if ( strlen( prefix ) > 0 )
		return prefix
	endif
	
	if ( exists( fxn ) != 6 )
		fxn = tabName + "Prefix"
	endif
	
	if ( exists( fxn ) == 6 ) // attemp to create tab prefix string by calling tab prefix function
		Execute /Z "SetNMstr( " + NMQuotes( NMDF+"TabPrefix" + tabName ) + ", " + fxn + "() )"
	endif
		
	return StrVarOrDefault( NMDF+"TabPrefix" + tabName, "" )

End // NMTabPrefix

Function CurrentNMChannel()
	
	Variable currentChan = NumVarOrDefault( CurrentNMPrefixFolder() + "CurrentChan", 0 )
	
	return max( 0, currentChan )

End // CurrentNMChannel

Function /S ChanDF( channel [ prefixFolder ] ) // channel folder path
	Variable channel // ( -1 ) for current channel
	String prefixFolder
	
	String cdf
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	cdf = ChanDFname( channel, prefixFolder = prefixFolder )
	
	if ( ( strlen( cdf ) == 0 ) || !DataFolderExists( cdf ) )
		return ""
	endif
	
	return cdf
	
End // ChanDF

Function /S ChanGraphName( channel )
	Variable channel // ( -1 ) for current channel
	
	if ( channel == -1 )
		channel = CurrentNMChannel()
	endif
	
	return NMCheckStringName( NMChanGraphPrefix + ChanNum2Char( channel ) )
	
End // ChanGraphName

Function KillTabs( tabList ) // kill all tabs, no dialogue
	String tabList // list of tab names
	
	if ( TabExists( tabList ) == 0 )
		//DoAlert 0, "KillTabs Abort: tab control does not exist: " + TabCntrlName( tabList )
		return -1
	endif
	
	Variable icnt
	
	for ( icnt = 0; icnt < NumTabs( tabList ); icnt += 1 ) // kill each tab
		KillTab( icnt, tabList, 0 ) // no dialogue
	endfor

End // KillTabs

Function CheckNMPackageDF( subfolderName ) // check Package data folder exists
	String subfolderName // subfolder
	
	if ( DataFolderExists( "root:Packages:" ) == 0 )
		NewDataFolder root:Packages
	endif
	
	if ( DataFolderExists( NMDF ) == 0 )
		NewDataFolder $RemoveEnding( NMDF, ":" )
	endif
	
	if ( DataFolderExists( NMDF + "Configurations:" ) == 0 )
		NewDataFolder $NMDF + "Configurations"
	endif
	
	if ( ( strlen( subfolderName ) == 0 ) || ( StringMatch( subfolderName, "NeuroMatic" ) == 1 ) )
		return 0
	endif

	if ( ( strlen( subfolderName ) > 0 ) && ( DataFolderExists( NMDF + subfolderName + ":" ) == 0 ) )
		NewDataFolder $( NMDF + subfolderName )
		return 1 // yes, made the folder
	endif
	
	return 0 // did not make folder

End // CheckNMPackageDF

Function CheckNeuroMatic() // check main NeuroMatic globals

	CheckNMtwave( NMDF+"FolderList", 0, "" )	// wave of NM folder names

End // CheckNeuroMatic

Function NMConfig( fName, copyConfigs )
	String fName // package folder name
	Variable copyConfigs // ( -1 ) copy configs to folder ( 0 ) no copy ( 1 ) copy folder to configs
	
	CheckNMConfig( fName ) // create new config folder and variables
	
	if ( copyConfigs != 0 )
		NMConfigCopy( fname, copyConfigs )
	endif
	
End // NMConfig

Function NMProgressOn( pflag ) // set Progress flag
	Variable pflag // ( 0 ) off ( 1 ) use ProgWin XOP ( 2 ) use Igor Progress Window
	
	if ( pflag == 1 )
		
		Execute /Z "ProgressWindow kill"
		
		if ( V_flag != 0 )
		
			if ( IgorVersion() >= 6.1 )
				pflag = 2
			else
				NMDoAlert( "NM Alert: ProgWin XOP cannot be located. This XOP can be downloaded from www.wavemetrics.com/Support/ftpinfo.html." )
				pflag = 0
			endif
			
		endif
		
	endif
		
	if ( pflag == 2 )
	
		if ( IgorVersion() < 6.1 )
			NMDoAlert( "NM Alert: this version of Igor does not support Progress Windows." )
			pflag = 0
		endif
		
	endif
	
	SetNMvar( NMDF+"ProgFlag", pflag )
	
	return pflag

End // NMProgressOn

Function NMProgFlagDefault()

	if ( IgorVersion() >= 6.1 )
		return 2 // use Igor built-in Progress Window
	endif
	
	Execute /Z "ProgressWindow kill"
			
	if ( V_flag == 0 )
		return 1 // ProgWin XOP exists, so use this
	endif
	
	Execute /Z "ProgressWindow kill"
		
	if ( V_flag != 0 )
		NMDoAlert( "NM Alert: ProgWin XOP cannot be located. This XOP can be downloaded from www.wavemetrics.com/Support/ftpinfo.html." )
	endif
	
	return 0 // no progress window exists

End // NMProgFlagDefault

Function CheckNMPaths()
	
	String opath = NMStrGet( "OpenDataPath" )
	String spath = NMStrGet( "SaveDataPath" )
	
	if ( strlen( opath ) > 0 )
	
		PathInfo OpenDataPath
		
		if ( StringMatch( opath, S_path ) == 0 )
			NewPath /O/Q/Z OpenDataPath opath
		endif
		
	endif
	
	if ( strlen( spath ) > 0 )
	
		PathInfo SaveDataPath
		
		if ( StringMatch( spath, S_path ) == 0 )
			NewPath /O/Q/Z SaveDataPath spath
		endif
		
	endif

End // CheckNMPaths

Function /S CheckFileOpen( fileName )
	String fileName
	
	if ( !StringMatch( GetDataFolder( 0 ), "root" ) )
		return "" // not in root directory
	endif
	
	if ( strlen( fileName ) == 0 )
		fileName = GetDataFolder( 0 )
	endif

	if ( StringMatch( StrVarOrDefault( "FileType", "" ), "NMData" ) )
		return ( fileName ) // move everything to subfolder
	else
		return ""
	endif

End // CheckFileOpen

Function NMConfigOpenAuto()

	Variable icnt, error = -1
	String path, flist, fileName, ext = ".pxp"

	CheckNMPath()
	
	PathInfo NMPath
	
	if ( V_flag == 0 )
		return 0
	endif
	
	path = S_path
	
	flist = IndexedFile( NMPath, -1, "????" )
	
	flist = RemoveFromList( "NMConfigs.pxp", flist )
	flist = "NMConfigs.pxp;" + flist // open NMConfigs first
	
	for ( icnt = 0; icnt < ItemsInList( flist ); icnt += 1 )
	
		fileName = StringFromList( icnt, flist )
		
		if ( StrSearch( fileName, ".ipf", 0, 2 ) >= 0 )
			continue // skip procedure files
		endif
		
		if ( StrSearch( fileName, ext, 0, 2 ) >= 0 )
			error = NMConfigOpen( path + fileName )
		endif
		
	endfor
	
	//UpdateNMConfigMenu()
	
	CheckNMConfigsAll()
	
	KillNMPath()
	
	PathInfo /S Igor // reset path to Igor

End // NMConfigOpenAuto

Function AutoStartNM()

	if ( NMVarGet( "AutoStart" ) == 0 )
		return 0
	endif
	
	if ( IsNMDataFolder( "" ) == 0 )
		NMFolderNew( "" )
	else
		UpdateNM( 1 )
	endif

End // AutoStartNM

Function KillGlobals( folder, matchStr, select )
	String folder	// folder name ( "" ) current folder
	String matchStr	// variable/string name to match ( ie. "ST_*", or "*" for all )
	String select	// variable | string | wave ( i.e. "111" for all, or "001" for waves )
	
	Variable icnt
	String vList, sList, wList, saveDF
	
	if ( strlen( folder ) == 0 )
		folder = GetDataFolder( 1 )
	elseif ( DataFolderExists( folder ) == 0 )
		return -1
	endif
	
	saveDF = GetDataFolder( 1 )
	
	SetDataFolder $folder
	
	vList = VariableList( matchStr, ";", 4+2 )
	sList = StringList( matchStr, ";" )
	wList = WaveList( matchStr, ";", "" )
	
	if ( ( StringMatch( select[ 0,0 ], "1" ) == 1 ) && ( ItemsInList( vList ) > 0 ) )
		for ( icnt = 0; icnt < ItemsInList( vList ); icnt += 1 )
			KillVariables /Z $StringFromList( icnt, vList )
		endfor
	endif
	
	if ( ( StringMatch( select[ 1,1 ], "1" ) == 1 ) && ( ItemsInList( sList ) > 0 ) )
		for ( icnt = 0; icnt < ItemsInList( sList ); icnt += 1 )
			KillStrings /Z $StringFromList( icnt, sList )
		endfor
	endif
	
	if ( ( StringMatch( select[ 2,2 ], "1" ) == 1 ) && ( ItemsInList( wList ) > 0 ) )
		for ( icnt = 0; icnt < ItemsInList( wList ); icnt += 1 )
			KillWaves /Z $StringFromList( icnt, wList )
		endfor
	endif
	
	SetDataFolder $saveDF

End // KillGlobals

Function /S NMDataFolderList()

	String wname = NMFolderListWave()
	String fList = ""
	
	if ( WaveExists( $wname ) == 1 )
		fList = Wave2List( NMFolderListWave() )
	endif

	if ( ItemsInlist( fList ) == 0 )
		return NMFolderList( "root:","NMData" )
	endif
	
	return fList
	
End // NMDataFolderList

Function CheckNMDataFolder( folderName ) // check data folder globals
	String folderName
	
	Variable ccnt, changeFolder
	String wavePrefix, subfolder
	
	String versionStr = NMStrGet( "NMVersionStr" )
	
	String saveCurrentFolder = NMStrGet( "CurrentFolder" )
	
	folderName = CheckNMFolderPath( folderName )
	
	if ( DataFolderExists( folderName ) == 0 )
		return -1
	endif
	
	if ( StringMatch( folderName, saveCurrentFolder ) == 0 )
		changeFolder = 1
		SetNMstr( NMDF+"CurrentFolder", folderName )
	endif
 
	wavePrefix = StrVarOrDefault( folderName+"WavePrefix", "" )
	
	CheckNMFolderType( folderName )
	
	CheckNMvar( folderName+"FileFormat", NMVersionNum() )
	CheckNMstr( folderName+"FileFormatStr", versionStr )
	CheckNMvar( folderName+"FileDateTime", DateTime )
	
	CheckNMstr( folderName+"FileType", "NMData" )
	CheckNMstr( folderName+"FileDate", date() )
	CheckNMstr( folderName+"FileTime", time() )
	
	CheckOldNMDataNotes( folderName )
	
	NMPrefixFolderUtility( folderName, "rename" ) // new names for old prefix subfolders
	
	CheckNMDataFolderFormat6( folderName )
	
	NMPrefixFolderUtility( folderName, "check" ) // check for globals
	NMPrefixFolderUtility( folderName, "unlock" ) // remove old locks if they exist since they did not work well
	
	for ( ccnt = 0 ; ccnt < NMNumChannels() ; ccnt += 1 )
		ChanGraphSetCoordinates( ccnt )
	endfor
	
	//subfolder = NMPrefixFolderDF( folderName, wavePrefix )
	
	//if ( ( NumVarOrDefault( subfolder+"NumGrps", 0 ) == 0 ) && ( exists( "NumStimWaves" ) == 2 ) )
	//	SetNMvar( subfolder+"NumGrps", NumVarOrDefault( "NumStimWaves", 0 ) )
	//	SetNMvar( subfolder+"CurrentGrp", Nan )
	//	NMGroupSeqDefault() // set Groups for Nclamp data
	//endif
	
	if ( changeFolder == 1 )
		SetNMstr( NMDF+"CurrentFolder", saveCurrentFolder )
	endif
	
	return 0
	
End // CheckNMDataFolder

Function /S NMFolderListWave()

	return NMDF + "FolderList"

End // NMFolderListWave

Function /S NMFolderList( df, type )
	String df // data folder to look in ( "" ) for current
	String type // "NMData", "NMStim", "NMLog", ( "" ) any
	
	Variable index
	String objName, folderlist = ""
	
	if ( strlen( df ) == 0 )
		df = CurrentNMFolder( 1 )
	endif
	
	do
		objName = GetIndexedObjName( df, 4, index )
		
		if ( strlen( objName ) == 0 )
			break
		endif
		
		CheckNMFolderType( objName )
		
		if ( IsNMFolder( df+objName, type ) == 1 )
			folderlist = AddListItem( objName, folderlist, ";", inf )
		endif
		
		index += 1
		
	while( 1 )
	
	return folderlist

End // NMFolderList

Function CheckNMtwave( wList, nPoints, defaultValue )
	String wList
	Variable nPoints // ( -1 ) dont care
	String defaultValue
	
	Variable wcnt, init, error
	String wname, path
	
	if ( numtype( nPoints ) > 0 )
		return -1
	endif
	
	for ( wcnt = 0; wcnt < ItemsInList( wList ); wcnt += 1 )
		
		wname = StringFromList( wcnt, wList )
		path = GetPathName( wName, 1 )
		
		if ( ( strlen( path ) > 0 ) && ( DataFolderExists( path ) == 0 ) )
			error = -1
			continue
		endif
		
		init = 0
		
		if ( ( WaveExists( $wname ) == 0 ) && ( strlen( defaultValue ) > 0 ) )
			init = 1
		endif
		
		CheckNMwaveOfType( wname, nPoints, 0, "T" )
		
		if ( ( init == 1 ) && ( WaveType( $wname ) == 0 ) )
			Wave /T wtemp = $wname
			wtemp = defaultValue
		endif
	
	endfor
	
	return error
	
End // CheckNMtwave

Function NMFolderListRemove( folder )
	String folder
	
	Variable icnt, found, npnts
	
	String wname = NMFolderListWave()
	
	if ( WaveExists( $wname ) == 0 )
		return -1
	endif
	
	Wave /T list = $wname
	
	folder = GetPathName( folder, 0 )
	
	npnts = numpnts( list )
	
	for ( icnt = 0; icnt < npnts; icnt += 1 )
		if ( StringMatch( folder, list[ icnt ] ) == 1 )
			list[ icnt ] = ""
			return 1
		endif
	endfor
	
	return 0
	
End // NMFolderListRemove

Function NMFolderListAdd( folder )
	String folder
	
	Variable icnt, found, npnts
	
	String wname = NMFolderListWave()
	
	if ( WaveExists( $wname ) == 0 )
		return -1
	endif
	
	Wave /T list = $wname
	
	folder = GetPathName( folder, 0 )
	
	npnts = numpnts( list )
	
	for ( icnt = 0; icnt < npnts; icnt += 1 )
		if ( StringMatch( folder, list[ icnt ] ) == 1 )
			return 0 // already exists
		endif
	endfor
	
	for ( icnt = npnts-1; icnt >= 0; icnt -=1 )
		if ( strlen( list[ icnt ] ) > 0 )
			found = 1
			break
		endif
	endfor

	if ( found == 0 )
		icnt = 0
	else	
		icnt = icnt + 1
	endif
	
	if ( icnt < npnts )
		list[ icnt ] = folder
	else
		Redimension /N=( icnt+1 ) list
		list[ icnt ] = folder
	endif
	
	return icnt
	
End // NMFolderListAdd

Function /S NMChanWaveListTableName()

	return "NM_" + CurrentNMFolderPrefix() + "OrderWaveNames"

End // NMChanWaveListTableName

Function NMPrefixFolderStrVarKill( strVarPrefix, [ prefixFolder ] )
	String strVarPrefix // prefix name
	String prefixFolder

	Variable icnt, killedsomething
	String strVarName, strVarList
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	strVarList = NMFolderStringList( prefixFolder, strVarPrefix + "*", ";", 1 )
	
	for ( icnt = 0 ; icnt < ItemsInList( strVarList ) ; icnt += 1 )
	
		strVarName = StringFromList( icnt, strVarList )
		KillStrings /Z $strVarName
	
		if ( exists( strVarName ) == 0 )
			killedsomething = 1
		endif
		
	endfor
	
	return killedsomething

End // NMPrefixFolderStrVarKill

Function /S ChanNum2Char( chanNum )
	Variable chanNum
	
	if ( ( numtype( chanNum ) > 0 ) || ( chanNum < 0 ) )
		return ""
	endif
	
	return num2char( 65+chanNum )

End // ChanNum2Char

Function /S NMFolderWaveList( folder, matchStr, separatorStr, optionsStr, fullPath )
	String folder // ( "" ) for current folder
	String matchStr, separatorStr, optionsStr // see Igor WaveList
	Variable fullPath // ( 0 ) no, just wave name ( 1 ) yes, directory + wave name
	
	Variable icnt
	String wList, wName, oList = ""
	String saveDF = GetDataFolder( 1 ) // save current directory
	
	if ( strlen( folder ) == 0 )
		folder = GetDataFolder( 1 )
	endif
	
	if ( DataFolderExists( folder ) == 0 )
		//return NM2ErrorStr( 30, "folder", folder )
		return ""
	endif
	
	folder = NMCheckFullPath( folder )
	
	SetDataFolder $folder
	
	wList = WaveList( matchStr, separatorStr, optionsStr )
	
	SetDataFolder $saveDF // back to original data folder
	
	if ( fullPath == 1 )
	
		for ( icnt = 0 ; icnt < ItemsInList( wList ) ; icnt += 1 )
			wName = StringFromList( icnt, wList )
			oList = AddListItem( folder + wName , oList, separatorStr, inf ) // full-path names
		endfor
		
		wList = oList
	
	endif
	
	return wList

End // NMFolderWaveList

Function /S NMChanWaveListSearch( wavePrefix, channel, [ folder ] ) // return list of waves appropriate for channel
	String wavePrefix // wave prefix
	Variable channel
	String folder
	
	Variable wcnt, icnt, jcnt, seqnum, foundLetter
	String chanstr, wList, wName, seqstr, olist = ""
	
	if ( strlen( wavePrefix ) == 0 )
		return ""
	endif
	
	chanstr = ChanNum2Char( channel )
	
	if ( strlen( chanstr ) == 0 )
		return ""
	endif
	
	if ( ParamIsDefault( folder ) )
		folder = GetDataFolder( 1 )
	elseif ( !DataFolderExists( folder ) )
		return ""
	endif
	
	wList = NMFolderWaveList( folder, wavePrefix + "*" + chanstr + "*", ";", "Text:0", 0 )
	
	for ( wcnt = 0; wcnt < ItemsInList( wList ); wcnt += 1 )
	
		wName = StringFromList( wcnt, wList )
		
		for ( icnt = strlen( wName )-2; icnt > 0; icnt -= 1 )
		
			if ( StringMatch( wName[icnt,icnt], chanstr ) )
			
				seqstr = wName[icnt+1,inf]
				foundLetter = 0
				
				for ( jcnt=0; jcnt < strlen( seqstr ); jcnt += 1 )
					if ( numtype( str2num( seqstr[jcnt, jcnt] ) ) > 0 )
						foundLetter = 1
					endif
				endfor
				
				if ( foundLetter == 0 )
					olist = AddListItem( wName, olist, ";", inf ) // matches criteria
				endif
				
				break
				
			endif
			
		endfor
		
	endfor
	
	return olist

End // NMChanWaveListSearch

Function NMChanWaveList2Waves( [ prefixFolder ] )
	String prefixFolder

	Variable ccnt, icnt, numChannels, numWaves
	String strVarName, wList, wName
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	numWaves = NumVarOrDefault( prefixFolder + "NumWaves", 0 )
	
	NMPrefixFolderWaveKill( "ChanWaveNames", prefixFolder = prefixFolder )
	
	for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
	
		strVarName = prefixFolder + NMChanWaveListPrefix + ChanNum2Char( ccnt )
		
		wList = StrVarOrDefault( strVarName, "" )
		
		wName = prefixFolder + "ChanWaveNames" + ChanNum2Char( ccnt )
		
		Make /O/T/N=( numWaves ) $wName = ""
		
		Wave /T wtemp = $wName
		
		for ( icnt = 0 ; icnt < numWaves ; icnt += 1 )
		
			wtemp[ icnt ] = StringFromList( icnt, wList )
			
		endfor
		
	endfor
	
	return 0

End // NMChanWaveList2Waves

Function CheckNMVersion()

	String existingVersion = StrVarOrDefault( NMDF+"NMVersionStr", "" )
	
	if ( StringMatch( existingVersion, NMVersionStr ) == 0 )
		return ResetNM( 0 )
	endif
	
	return 0

End // CheckNMVersion

Function CheckNMvar( varName, defaultValue )
	String varName
	Variable defaultValue
	
	return SetNMvar( varName, NumVarOrDefault( varName, defaultValue ) )
	
End // CheckNMvar

Function NMPanelRGB(rgb)
	String rgb
	
	strswitch(rgb)
		case "r":
			return 43690
		case "g":
			return 43690
		case "b":
			return 43690
	endswitch

End // NMPanelRGB

Function /S NMSetsDisplayName( setListNum, [ prefixFolder ] )
	Variable setListNum
	String prefixFolder
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	return StringFromList( setListNum, NMSetsDisplayList( prefixFolder = prefixFolder ) )

End // NMSetsDisplayName

Function NMConfigsListBoxMake( force )
	Variable force
	
	Variable x0, y0, fs = NMPanelFsize
	
	String wName = NMConfigsListBoxWaveName()
	String wName2 = wName + "Select"
	String wName3 = wName + "Color"
	
	NMConfigsListBoxWavesUpdate( "" )
	
	ControlInfo /W=$NMPanelName CF_parameters
	
	if ( ( V_Flag != 0 ) && ( force == 0 ) )
		return 0 // controls exist
	endif
	
	DoWindow /F $NMPanelName
	
	x0 = 10
	y0 = NMPanelTabY + 40
	
	ListBox CF_parameters, title="Config Parameters", pos={x0,y0}, size={280,340}, fsize=fs, listWave=$wName, selWave=$wName2, colorWave=$wName3, disable=1, win=$NMPanelName
	ListBox CF_parameters, mode=1, userColumnResize=1, proc=NMConfigsListBoxInput, widths={120, 60, 35, 700}, win=$NMPanelName
	
	SetDimLabel 2, 1, foreColors, $wName2 // suppose to set color but does not seem to work on RGB rows
	
	Button CF_Save, pos={x0+15,y0+360}, size={70,20}, proc=NMConfigsButton, title="Save", fsize=fs, disable=1, win=$NMPanelName
	Button CF_Open, pos={x0+105,y0+360}, size={70,20}, proc=NMConfigsButton, title="Open", fsize=fs, disable=1, win=$NMPanelName
	Button CF_Reset, pos={x0+195,y0+360}, size={70,20}, proc=NMConfigsButton, title="Reset", fsize=fs, disable=1, win=$NMPanelName
	
End // NMConfigsListBoxMake

Function /S NMTabControlName()

	return TabCntrlName( NMStrGet( "TabControlList" ) )
	
End // NMTabControlName

Function NMTabsMake( force )
	Variable force // (0) check (1) make

	Variable icnt, tnum
	String tabName
	
	String tabCntrlList = NMStrGet( "TabControlList" )
	String currentList = NMTabListConvert( tabCntrlList )
	String defaultList = NMStrGet( "NMTabList" )
	
	//print currentList
	//print defaultList
	
	String ctrlName = NMTabControlName()
	Variable extraTabNum = NMTabsExtraNum()
	
	if ((force == 1) || (StringMatch(currentList, defaultList) == 0))
	
		for (icnt = 0; icnt < ItemsInList(currentList); icnt += 1)
		
			tabName = StringFromList(icnt, currentList)
			
			if (WhichListItem(tabName, defaultList, ";", 0, 0) < 0)
				tnum = WhichListItem(tabName, currentList, ";", 0, 0)
				KillTabControls(tnum, tabCntrlList)
			endif
			
		endfor
		
		ClearTabs(tabCntrlList) // clear old tabs
		SetNMstr( NMDF+"TabControlList", "" ) // clear old list
		tabCntrlList = NMTabControlList() // update control list
		MakeTabs( tabCntrlList )
		CheckNMTabs( 1 )
		
	endif
	
End // NMTabsMake

Function UpdateNM( force )
	Variable force
	
	Variable isNMfolder = IsNMDataFolder( GetDataFolder( 1 ) )

	if ( NumVarOrDefault( NMDF+"UpdateNMBlock", 0 ) == 1 )
		KillVariables /Z $( NMDF+"UpdateNMBlock" )
		return 0
	endif
	
	if ( WinType( NMPanelName ) == 0 )
	
		if ( force == 0 )
			return 0 // nothing to update
		endif
		
//		MakeNMPanel()
		
	else
	
		UpdateNMPanel( 1 )
		
	endif
	
	CheckCurrentFolder()
	CheckNMFolderList()
	NMSetsPanelUpdate( 1 )
	NMGroupsPanelUpdate( 1 )
	
	if ( isNMfolder == 1 )
		UpdateCurrentWave()
	endif
	
End // UpdateNM

Function IsNMFolder( folder, type ) // returns 0 or 1
	String folder // full-path folder name
	String type // "NMData", "NMStim", "NMLog", ( "" ) any
	
	String ftype
	
	if ( strlen( folder ) == 0 )
		folder = GetDataFolder( 1 )
	endif
	
	folder = CheckNMFolderPath( folder )
	
	if ( ( strlen( folder ) > 0 ) && DataFolderExists( folder ) )
	
		ftype = StrVarOrDefault( folder+"FileType", "No" )
	
		if ( StringMatch( type, ftype ) )
			return 1
		elseif ( ( strlen( type ) == 0 ) && !StringMatch( ftype, "No" ) )
			return 1
		endif
	
	endif
	
	return 0

End // IsNMFolder

Function NMAutoTabCall()
	
	Variable tabNum = NMVarGet( "CurrentTab" )
	
	String tName = TabName( tabNum, NMTabControlList() )
	
	String fxn = "NM" + tName + "Auto"
	
	if ( exists( fxn ) != 6 )
		fxn = "Auto" + tName
	endif
	
	Execute /Z fxn + "()"
		
	if ( V_Flag == 0 )
		return 0
	else	
		return -1
	endif

End // NMAutoTabCall

Function /S LastPathColon( fullpath, yes )
	String fullpath
	Variable yes // check path (0) has no trailing colon ( 1 ) has trailing colon
	
	if ( yes == 1 )
		return ParseFilePath( 2, fullpath, ":", 0, 0 )
	else
		return RemoveEnding( fullpath, ":" )
	endif

End // LastPathColon

Function /T ReadPclampString( file, pointer, numCharToRead )
	String file // external ABF data file
	Variable pointer // read file pointer in bytes
	Variable numCharToRead // number of characters to read
	
	Variable icnt
	String str = ""
	
	if ( !FileExistsAndNonZero( file ) )
		return ""
	endif
	
	pointer = ReadPclampFile( file, "char", pointer, numCharToRead )
	
	if ( numtype( pointer ) > 0 )
		return NM2ErrorStr( 10, "pointer", num2str( pointer ) )
	endif
	
	if ( !WaveExists( NM_ReadPclampWave0 ) )
		return NM2ErrorStr( 1, "NM_ReadPclampWave0", "" )
	endif
	
	Wave NM_ReadPclampWave0
	
	for ( icnt = 0 ; icnt < numCharToRead ; icnt += 1 )
		str += num2char( NM_ReadPclampWave0[ icnt ] )
	endfor
	
	return str

End // ReadPclampString

Function /T ReadAxoString(file, nchar)
	String file
	Variable nchar
	
	Variable icnt
	String str = ""
	
	ReadAxoFile(file, "char", nchar)
	
	if (WaveExists(DumWave0) == 0)
		return ""
	endif
	
	Wave DumWave0
	
	for (icnt = 0; icnt < nchar; icnt += 1)
		str += num2char(DumWave0[icnt])
	endfor
	
	return str

End // ReadAxoString

Function ReadAxoVar(file, type)
	String file
	String type
	
	ReadAxoFile(file, type, 1)
	
	if (WaveExists(DumWave0) == 0)
		return Nan
	endif
	
	Wave DumWave0
	
	return DumWave0[0]

End // ReadAxoVar

Function NMError( errorNum, functionName, objectName, objectValue )
	Variable errorNum
	String functionName
	String objectName
	String objectValue
	
	if ( strlen( functionName ) == 0 )
		functionName = GetRTStackInfo( 2 )
	endif
	
	String errorStr = "NM Error : " + functionName + " : " + objectName

	switch( errorNum )
	
		// case 0: // DO NOT USE, error 0 indicates there is no error
	
		// wave errors
	
		case 1:
			if ( strlen( objectValue ) > 0 )
				errorStr += " : wave " + NMQuotes( objectValue ) + " does not exist or is the wrong type."
			else
				errorStr += " : wave does not exist or is the wrong type."
			endif
			break
			
		case 2:
			errorStr += " : wave " + NMQuotes( objectValue ) + " already exists."
			break
			
		case 3:
			errorStr += " : wave name exceeds 31 characters : " + objectValue
			break
			
		case 4:
			errorStr += " : detected no waves to process."
			break
			
		case 5:
			errorStr += " : wave " + NMQuotes( objectValue ) + " has wrong dimensions."
			break
			
			
		// variable errors
		
		case 10:
			errorStr += " : variable has an unnacceptable value of " + objectValue
			break
			
		case 11:
			errorStr += " : variable has no value."
			break
			
		case 12:
			errorStr += " : variable name exceeds 31 characters : " + objectValue
			break
			
		case 13:
			errorStr += " : variable does not exist."
			break
		
		
		// string errors
		
		case 20:
			errorStr += " : string has an unnacceptable value of " + NMQuotes( objectValue )
			break
			
		case 21:
			errorStr += " : string has no value."
			break
			
		case 22:
			errorStr += " : string name exceeds 31 characters : " + NMQuotes( objectValue )
			break
			
		case 23:
			errorStr += " : string does not exist."
			break
		
		
		// folder errors
		
		case 30:
			errorStr += " : folder " + NMQuotes( objectValue ) + " does not exist."
			break
			
		case 31:
			errorStr += " : folder " + NMQuotes( objectValue ) + " already exists."
			break
			
		case 32:
			errorStr += " : folder name exceeds 31 characters : " + objectValue
			break
			
		// graph errors
		
		case 40:
			errorStr += " : graph " + NMQuotes( objectValue ) + " does not exist."
			break
			
		// table errors
			
		case 50:
			errorStr += " : table " + NMQuotes( objectValue ) + " does not exist."
			break
			
		
		case 90: // generic error
			break
			
		default:
			errorStr = "NMerror: unrecognized error number " + num2istr( errorNum )
	
	endswitch
	
	SetNMstr( NMDF+"ErrorStr", errorStr )

	NMDoAlert( errorStr )
	
	return errorNum

End // NMError

Function /S CheckNMFolderPath( folderName )
	String folderName
	
	if ( strlen( folderName ) == 0 )
		return CurrentNMFolder( 1 )
	endif
	
	if ( strlen( folderName ) == 0 )
		return ""
	endif
	
	if ( StringMatch( folderName[ 0,4 ], "root:" ) == 0 )
		folderName = "root:" + folderName + ":" // create full-path
	endif
	
	folderName = LastPathColon( folderName, 1 )
		
	return folderName

End // CheckNMFolderPath

Function NextWaveNum( df, prefix, chanNum, overwrite )
	String df // data folder
	String prefix // wave prefix name
	Variable chanNum // channel number ( pass -1 for none )
	Variable overwrite // overwrite flag: ( 1 ) return last name in sequence ( 0 ) return next name in sequence
	
	Variable count
	String wName
	
	if ( strlen( df ) > 0 )
		df = LastPathColon( df, 1 )
	endif
	
	for ( count = 0; count <= 9999; count += 1 ) // search thru sequence numbers
	
		if ( chanNum == -1 )
			wName = df + prefix + num2istr( count )
		else
			wName = df + prefix+ ChanNum2Char( chanNum ) + num2istr( count )
		endif
		
		if ( WaveExists( $wName ) == 0 )
			break
		endif
		
	endfor
	
	if ( ( overwrite == 0 ) || ( count == 0 ) )
		return count
	else
		return ( count-1 )
	endif

End // NextWaveNum

Function /S GetWaveName( prefix, chanNum, waveNum )
	String prefix // wave prefix name ( pass "default" to use data's WavePrefix )
	Variable chanNum // channel number ( pass -1 for none )
	Variable waveNum // wave number
	
	String name
	
	if ( ( StringMatch( prefix, "default" ) == 1 ) || ( StringMatch( prefix, "Default" ) == 1 ) )
		prefix = StrVarOrDefault( "WavePrefix", "Wave" )
	endif
	
	if ( chanNum == -1 )
		name = prefix + num2istr( waveNum )
	else
		name = prefix + ChanNum2Char( chanNum ) + num2istr( waveNum )
	endif
	
	return NMCheckStringName( name )

End // GetWaveName

Function /S NMWaveSelectGet( [ prefixFolder ] )
	String prefixFolder

	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	return StrVarOrDefault( prefixFolder + "WaveSelect", "" )

End // NMWaveSelectGet

Function CurrentNMWave()

	Variable currentWave = NumVarOrDefault( CurrentNMPrefixFolder() + "CurrentWave", 0 )
	
	return max( 0, currentWave )

End // CurrentNMWave

Function /S NMCmdStr( strVar, varList )
	String strVar, varList
	
	if ( strsearch( strVar, ",", 0 ) > 0 ) // this is a "," list
	
		return AddListItem( "\l"+strVar, varList, ";", inf )
		
	elseif ( strsearch( strVar, ";", 0 ) > 0 ) // this is a ";" list
	
		strVar = ReplaceString( ";", strVar, "," )
		
		return AddListItem( "\l" + strVar, varList, ";", inf )
		
	endif

	return AddListItem( "\s"+strVar, varList, ";", inf )

End // NMCmdStr

Function /S NMAddToList( itemOrListStr, listStr, listSepStr ) // add to list only if it is not in the list
	String itemOrListStr, listStr, listSepStr
	
	Variable icnt, items
	String itemStr = ""
	
	if ( strlen( itemOrListStr ) == 0 )
		return listStr
	endif
	
	strswitch( listSepStr )
		case ";":
		case ",":
			break
		default:
			return listStr
	endswitch
	
	items = ItemsInList( itemOrListStr, listSepStr )
	
	for ( icnt = 0 ; icnt < items ; icnt += 1 )
	
		itemStr = StringFromList( icnt, itemOrListStr, listSepStr )
		
		if ( WhichListItem( itemStr, listStr, listSepStr ) < 0 )
			listStr += itemStr + listSepStr
		endif
		
	endfor
	
	return listStr

End // NMAddToList

Function UpdateNMPanelPrefixMenu()
	
	if (WinType(NMPanelName) == 0)
		return 0
	endif
	
	String cPrefix = CurrentNMWavePrefix()
	String pList = NMPrefixList()
	
	if ((strlen(cPrefix) > 0) && (WhichListItem(cPrefix, pList, ";", 0, 0) == -1))
		pList = AddListItem(cPrefix, pList, ";", inf) // add prefix to list
		SetNMstr( NMDF+"PrefixList", pList )
	endif
	
	//PopupMenu NM_PrefixMenu, win=$NMPanelName, mode=1, value=NMPrefixMenu(), popvalue=CurrentNMWavePrefix()

End // UpdateNMPanelPrefixMenu

Function /S ChanGraphUpdate( channel, makeChanWave ) // update channel display graphs
	Variable channel // ( -1 ) for current channel
	Variable makeChanWave // ( 0 ) no ( 1 ) yes
	
	Variable autoscale, count, grid, dualDisplay, errorsOn, markers, md, waveNum
	String sName, dName, ddName, errorName, gName, fName
	String transform, info, cdf
	String axisName, histoName, histoNameX, histoNameXshort, wList
	
	fname = NMFolderListName( "" )
	
	if ( channel == -1 )
		channel = CurrentNMChannel()
	endif
	
	waveNum = CurrentNMWave()
	
	gName = ChanGraphName( channel )
	dName = ChanDisplayWave( channel ) // display wave
	ddName = GetPathName( dName, 0 )
	sName = NMChanWaveName( channel, waveNum ) // source wave
	
	CheckChanSubfolder( channel )
	
	cdf = ChanDF( channel )
	
	grid = NumVarOrDefault( cdf + "GridFlag", GridsOn )
	autoscale = NumVarOrDefault( cdf + "AutoScale", 1 )
	dualDisplay = NumVarOrDefault( cdf + "Histo_DualDisplay", 0 )
	markers = NumVarOrDefault( cdf + "Markers", 0 )
	errorsOn = NumVarOrDefault( cdf + "ErrorsOn", 1 )
	
	if ( strlen( cdf ) == 0 )
		return ""
	endif
	
	if ( !NumVarOrDefault( cdf + "On", 1 ) )
		ChanGraphClose( channel, 0 )
		return ""
	endif

	if ( Wintype( gName ) == 0 )
		ChanGraphMake( channel )
	else
		ChanScaleSave( channel )
	endif
	
	if ( Wintype( gName ) == 0 )
		return ""
	endif
	
	if ( strlen( fName ) > 0 )
		DoWindow /T $gName, fname + " : Ch " + ChanNum2Char( channel ) + " : " + sName
	else
		DoWindow /T $gName, "Ch " + ChanNum2Char( channel ) + " : " + sName
	endif

	if ( NumVarOrDefault( cdf + "Overlay", 0 ) > 0 )
		ChanOverlayUpdate( channel )
	endif
	
	if ( makeChanWave )
		ChanWaveMake( channel, sName, dName )
	endif
	
	//ChanGraphControlsUpdate( channel )
	
	//if ( numpnts( $dName ) < 0 ) // if waves have Nans, change mode to line+symbol
		
	//	WaveStats /Q $dName
		
	//	count = ( V_numNaNs * 100 / V_npnts )

	//	if ( ( numtype( count ) == 0 ) && ( count > 25 ) )
	//		ModifyGraph /W=$gName mode( $ddName )=4
	//	else
	//		ModifyGraph /W=$gName mode( $ddName )=0
	//	endif
	
	//endif
	
	ModifyGraph /W=$gName mode( $ddName )=NMChanMarkersMode( channel )
	
	if ( autoscale )
		SetAxis /A/W=$gName
	else
		ChanGraphAxesSet( channel )
	endif
	
	info = AxisInfo( gName, "bottom" )
	
	transform = NMChanTransformGet( channel )
	
	histoName = dName + "_histo"
	histoNameX = dName + "_histoX"
	histoNameXshort = ParseFilePath( 0, histoNameX, ":", 1, 0 )
	
	if ( ( StringMatch( transform, "Histogram" ) ) && dualDisplay )
	
		wList = TraceNameList( gName, ";", 1 )
		
		if ( WhichListItem( histoNameXshort, wList ) < 0 )
			AppendToGraph /W=$gName $histoNameX vs $histoName
			ModifyGraph /W=$gName mode($histoNameXshort)=6
		endif
		
	else
	
		RemoveFromGraph /W=$gName /Z $histoNameXshort
		
		KillWaves /Z $histoName, $histoNameX
		
	endif
	
	if ( strlen( info ) > 0 )
		
		strswitch( transform )
		
			case "Histogram":
			
				if ( dualDisplay )
					axisName = NMChanLabelX( channel = channel, waveNum = waveNum )
				else
					axisName = NMChanLabelY( channel = channel, waveNum = waveNum )
				endif
				
				break
				
			default:
			
				axisName = NMChanLabelX( channel = channel, waveNum = waveNum )
				
		endswitch
	
		Label /W=$gName bottom axisName
		
	endif
	
	info = AxisInfo( gName, "left" )
	
	if ( strlen( info ) > 0 )
	
		strswitch( transform )
		
			case "Differentiate":
			case "Double Differentiate":
			case "Integrate":
			case "Normalize":
			case "dF/Fo":
				axisName = transform
				break
				
			case "Histogram":
			
				if ( dualDisplay )
					axisName = NMChanLabelY( channel = channel, waveNum = waveNum )
				else
					axisName = "Count"
				endif
				
				break
				
			default:
			
				axisName = NMChanLabelY( channel = channel, waveNum = waveNum )
				
		endswitch
		
		Label /W=$gName left axisName
	
	endif
		
	ModifyGraph /W=$gName grid( bottom )=grid, grid( left )=grid, gridRGB=( 24576,24576,65535 )
	
	if ( errorsOn )
	
		errorName = NMWaveNameError( sName )
		
		if ( strlen( errorName ) > 0 )
		
			if ( strsearch( errorName, "STDV", 0, 2 ) >= 0 )
			
				Duplicate /O $errorName $dName + "_STDV"
				
				errorName = dName + "_STDV"
				
			elseif ( strsearch( errorName, "SEM", 0, 2 ) >= 0 )
			
				Duplicate /O $errorName $dName + "_SEM"
				
				errorName = dName + "_SEM"
				
			else
				
				errorName = ""
				
			endif
		
			if ( strlen( errorName ) > 0 )
				
				if ( numpnts( $errorName ) <= NMVarGet( "ErrorPointsLimit" ) )
					ErrorBars /W=$gName $ddName Y, wave=( $errorName, $errorName )
				else
					ErrorBars /L=0/W=$gName/Y=1 $ddName Y, wave=( $errorName, $errorName )
				endif
				
			endif
			
		else
		
			ErrorBars /W=$gName $ddName OFF
			
		endif
		
	else
	
		ErrorBars /W=$gName $ddName OFF
		
	endif
	
	ChanGraphMove( channel )
	
	if ( NMChanGraphToFront( channel ) )
		DoWindow /F $gName
	endif
	
	return gName

End // ChanGraphUpdate

Function ChanGraphControlsUpdate( channel )
	Variable channel // ( -1 ) for current channel
	
	Variable autoscale
	
	if ( channel == -1 )
		channel = CurrentNMChannel()
	endif
	
	String gName = ChanGraphName( channel )
	String cdf = ChanDF( channel )
	String cc = num2istr( channel )
	
	if ( strlen( cdf ) == 0 )
		return -1
	endif
	
	autoscale = NumVarOrDefault( cdf + "AutoScale", 1 )
	
	if ( ( strlen( cdf ) == 0 ) || ( winType( gName ) == 0 ) )
		return 0
	endif
	
	//CheckBox $( "ScaleCheck"+cc ), value=autoscale, win=$gName, proc=NMChan//CheckBox
	
	NMChanFilterSetVariableUpdate( channel )
	NMChanTransformCheckBoxUpdate( channel )
	
End // ChanGraphControlsUpdate

Function NMProgressTimer( currentCount, maxIterations, progressStr )
	Variable currentCount, maxIterations
	String progressStr
	
	Variable t, ref
	
	if ( currentCount == 0 )
	
		SetNMstr( NMDF+"ProgressStr", progressStr )
	
		ref = startMSTimer // start usec timer
		
		if ( ref > 0 )
			SetNMvar( NMDF+"ProgressLoopTimer", ref )
		endif
		
		return 0
		
	endif
	
	if ( exists( NMDF+"ProgressLoopTimer" ) == 0 )
	
		SetNMstr( NMDF+"ProgressStr", "" )
		
		return 0 // progress display is not on
		
	endif
		
	if ( currentCount == 1 )
	
		ref = NumVarOrDefault( NMDF+"ProgressLoopTimer", NaN )
		
		t = stopMSTimer( ref ) / 1000 // time in msec
		
		//Print "estimated function time:", ( t * maxIterations ), "ms"
		
		if ( t * maxIterations > NMVarGet( "ProgressTimerLimit" ) )
		
			NMProgress( 0, maxIterations, progressStr ) // open window
			
			return NMProgress( 1, maxIterations, progressStr ) // first increment
			
		else
		
			KillVariables /Z $NMDF+"ProgressLoopTimer"
		
		endif
		
	else
	
		if ( currentCount == maxIterations - 1 )
			KillVariables /Z $NMDF+"ProgressLoopTimer"
		endif
	
		return NMProgress( currentCount, maxIterations, progressStr )
		
	endif

End // NMProgressTimer

Function /S NMPrefixSubfolderList( withNMPrefix )
	Variable withNMPrefix // ( 0 ) without "NMPrefix_" ( 1 ) with "NMPrefix_"
	
	String folderPrefix = NMPrefixSubfolderPrefix
	
	String subfolderList = NMSubfolderList( folderPrefix, CurrentNMFolder( 1 ), 0 )
	
	if ( withNMPrefix == 1 )
		return subfolderList
	else
		return ReplaceString( folderPrefix, subfolderList, "" )
	endif
	
End // NMPrefixSubfolderList

Static Function NMPrefixFoldersRenameWave2( strVarName, oldName, newName, newNamePrefixMatch )
	String strVarName
	String oldName, newName
	Variable newNamePrefixMatch
	
	Variable wcnt
	String wName, wList2 = ""
	
	String wList = StrVarOrDefault( strVarName, "" )
	
	for ( wcnt = 0 ; wcnt < ItemsInList( wList ) ; wcnt += 1 )
		
		wName = StringFromList( wcnt, wList )
		
		if ( StringMatch( wName, oldName ) == 1 )
			if ( ( strlen( newName ) > 0 ) && ( newNamePrefixMatch == 1 ) )
				wList2 = AddListItem( newName, wList2, ";", inf )
			endif
		else
			wList2 = AddListItem( wName, wList2, ";", inf )
		endif
	
	endfor
	
	SetNMstr( strVarName, wList2 )
	
End // NMPrefixFoldersRenameWave2

Function /S NMFolderStringList( folder, matchStr, separatorStr, fullPath )
	String folder // ( "" ) for current folder
	String matchStr, separatorStr // see Igor StringList
	Variable fullPath // ( 0 ) no, just variable name ( 1 ) yes, directory + variable name
	
	Variable icnt
	String sList, sName, oList = ""
	String saveDF = GetDataFolder( 1 ) // save current directory
	
	if ( strlen( folder ) == 0 )
		folder = GetDataFolder( 1 )
	endif
	
	if ( DataFolderExists( folder ) == 0 )
		return NM2ErrorStr( 30, "folder", folder )
	endif
	
	SetDataFolder $folder
	
	sList = StringList( matchStr, separatorStr )
	
	SetDataFolder $saveDF // back to original data folder
	
	if ( fullPath == 1 )
	
		for ( icnt = 0 ; icnt < ItemsInList( sList ) ; icnt += 1 )
			sName = StringFromList( icnt, sList )
			oList = AddListItem( folder+sName, oList, separatorStr, inf ) // full-path names
		endfor
		
		sList = oList
	
	endif
	
	return sList

End // NMFolderStringList

Function NMSetXType( [ prefixFolder ] ) // determine if SetX is excluding
	String prefixFolder

	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return NaN
	endif
	
	if ( !AreNMSets( "SetX", prefixFolder = prefixFolder ) )
		return 1
	endif
	
	if ( NumVarOrDefault( prefixFolder + "SetXclude", 1 ) )
		return 1
	endif

	return 0

End // NMSetXType

Function /S NMSetsList( [ prefixFolder ] )
	String prefixFolder

	Variable scnt
	String setName, allList, setList = ""
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	allList = NMSetsListAll( prefixFolder = prefixFolder )
	
	for ( scnt = 0 ; scnt< ItemsInList( allList ) ; scnt += 1 )
	
		setName = StringFromList( scnt, allList )
		
		if ( !StringMatch( setName[0,4], "Group" ) ) // remove Groups
			setList = AddlistItem( setName, setList, ";", inf )
		endif
		
	endfor
	
	if ( ( NMSetXType( prefixFolder = prefixFolder ) == 1 ) && ( WhichListItem( "SetX", setList ) > 1 ) )
		setList = RemoveFromList( "SetX", setList )
		setList = AddListItem( "SetX", setList, ";", inf ) // place SetX at end of list
	endif
	
	return setList

End // NMSetsList

Function NMGroupsNumFromStr( groupStr )
	String groupStr // string containing group number (i.e. "Group0", or "Set1 x Group1" )
	
	Variable group, icnt
	
	Variable ibgn = strsearch( groupStr, "Group", 0, 2 )
	
	if ( strsearch( groupStr, "All Groups", 0, 2 ) >= 0 )
		return Nan
	endif
	
	if ( ibgn < 0 )
		return Nan
	endif
	
	ibgn += 5
	
	for ( icnt = ibgn; icnt < strlen( groupStr ); icnt += 1 )
		if ( numtype( str2num( groupStr[ibgn,ibgn] ) ) > 0 )
			break
		endif
	endfor
	
	group = str2num( groupStr[ ibgn, icnt-1 ] )
	
	return group
	
End // NMGroupsNumFromStr

Function /S NMSetXcludeWaveList( wList, chanNum, [ prefixFolder ] )
	String wList
	Variable chanNum
	String prefixFolder
	
	String strVarName, wListX
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return wList
	endif
	
	if ( NMSetXType( prefixFolder = prefixFolder ) == 0 )
		return wList
	endif
	
	strVarName = NMSetsStrVarName( "SetX", chanNum, prefixFolder = prefixFolder )
	
	wListX = StrVarOrDefault( strVarName, "" )
	
	return RemoveFromList( wListX, wList )
	
End // NMSetXcludeWaveList

Function /S NMChanWaveList( channel, [ prefixFolder ] )
	Variable channel // ( -1 ) for current channel ( -2 ) for all channels
	String prefixFolder
	
	Variable ccnt, cbgn, cend, numChannels
	String strVarName, wList = ""
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	if ( channel == -1 )
		cbgn = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
		cend = cbgn
	elseif ( channel == -2 )
		cbgn = 0
		cend = numChannels - 1
	elseif ( ( channel >= 0 ) && ( channel < numChannels ) )
		cbgn = channel
		cend = channel
	else
		//return NM2ErrorStr( 10, "channel", num2str( channel ) )
		return ""
	endif
	
	for ( ccnt = cbgn ; ccnt <= cend ; ccnt += 1 )
		strVarName = prefixFolder + NMChanWaveListPrefix + ChanNum2Char( ccnt )
		wList += StrVarOrDefault( strVarName, "" )
	endfor
	
	return wList
	
End // NMChanWaveList

Function /S NMSetsWaveList( setName, chanNum, [ prefixFolder ] )
	String setName
	Variable chanNum
	String prefixFolder
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	String strVarName = NMSetsStrVarName( setName, chanNum, prefixFolder = prefixFolder )
	
	if ( strlen( strVarName ) == 0 )
		return ""
	endif
	
	return StrVarOrDefault( strVarName, "" )
	
End // NMSetsWaveList

Function /S OrderToNMChanWaveList( wList, channel, [ prefixFolder ] )
	String wList // wave list to order
	Variable channel
	String prefixFolder
	
	Variable items, icnt, numChannels
	String chanList, item, outList = ""
	
	if ( ItemsInList( wList ) == 0 )
		return ""
	endif
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return wList
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	if ( ( channel < 0 ) || ( channel >= numChannels ) )
		return wList
	endif
	
	chanList = NMChanWaveList( channel, prefixFolder = prefixFolder )
	
	items = ItemsInList( chanList )
	
	for ( icnt = 0 ; icnt < items ; icnt += 1 )
		
		item = StringFromList( icnt, chanList )
		
		if ( WhichListItem( item, wList ) >= 0 )
			outList += item + ";"
		endif
		
	endfor
	
	return outList
	
End // OrderToNMChanWaveList

Function /S NMGroupsWaveList( group, chanNum, [ prefixFolder ] )
	Variable group // group number
	Variable chanNum // channel number
	String prefixFolder
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	return NMSetsWaveList( NMGroupsName( group ), chanNum, prefixFolder = prefixFolder )
	
End // NMGroupsWaveList

Function /S NMGroupsList( type, [ prefixFolder ] )
	Variable type // ( 0 ) e.g. "0;1;2;" ( 1 ) e.g. "Group0;Group1;Group2;"
	String prefixFolder
	
	Variable scnt
	String setName, setList, groupList = ""
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	setList = NMSetsListAll( prefixFolder = prefixFolder )
	
	for ( scnt = 0 ; scnt < ItemsInList( setList ) ; scnt += 1 )
	
		setName = StringFromList( scnt, setList )
		
		if ( StringMatch( setName[ 0, 4 ], "Group" ) == 1 )
		
			if ( type == 1 )
				groupList = AddListItem( setName, groupList, ";", inf )
			else
				groupList = AddListItem( setName[ 5, inf ], groupList, ";", inf )
			endif
			
		endif
		
	endfor
	
	if ( type == 1 )
		return SortList( groupList, ";", 16 )
	else
		return SortList( groupList, ";", 2 )
	endif

End // NMGroupsList

Function /S NMAndLists( listStr1, listStr2, listSepStr )
	String listStr1, listStr2, listSepStr
	
	Variable icnt, items
	String itemStr, andList = ""
	
	items = ItemsInList( listStr1, listSepStr )
	
	for ( icnt = 0 ; icnt < items ; icnt += 1 )
	
		itemStr = StringFromList( icnt, listStr1, listSepStr )
		
		if ( WhichListItem( itemStr, listStr2, listSepStr ) >= 0 )
			andList += itemStr + listSepStr
		endif
		
	endfor
	
	return andList

End // NMAndLists

Function NMWaveSelectAdd( waveSelect )
	String waveSelect
	
	String addedList = NMStrGet( "WaveSelectAdded" )
	
	addedList = NMAddToList( waveSelect, addedList, ";" )
	
	SetNMstr( NMDF+"WaveSelectAdded", addedList )
	
End // NMWaveSelectAdd

Function UpdateNMWaveSelectCount( [ prefixFolder, updateNM ] )
	String prefixFolder
	Variable updateNM

	Variable ccnt, count, numChannels
	String wList, strVarName
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return NaN
	endif
	
	if ( ParamIsDefault( updateNM ) )
		updateNM = 1
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )

		if ( NMChanSelected( ccnt, prefixFolder = prefixFolder ) )
			strVarName = prefixFolder + NMWaveSelectVarName + ChanNum2Char( ccnt )
			wList = StrVarOrDefault( strVarName, "" )
			count += ItemsInList( wList )
		endif
		
	endfor
	
	SetNMvar( prefixFolder + "NumActiveWaves", count )
	
	if ( updateNM )
		SetNMvar( NMDF + "NumActiveWaves", count ) // for NM Panel
	endif
	
	return count

End // UpdateNMWaveSelectCount

Function NMPrefixFolderGetOldGlobals( [ parent ] )
	String parent

	Variable icnt, channel, numChannels, currentChan, numWaves, currentWave, currentGrp
	String prefixFolder, setName, newName, wName, setList, chanSelectList

	if ( !NMVarGet( "CreateOldFolderGlobals" ) )
		return 0 // nothing to do
	endif
	
	if ( ParamIsDefault( parent ) )
		parent = CurrentNMFolder( 1 )
	else
		parent = CheckNMFolderPath( parent )
	endif
	
	if ( strlen( parent ) == 0 )
		return -1
	endif
	
	prefixFolder = NMPrefixFolderDF( parent, "" )
	
	if ( strlen( prefixFolder ) == 0 )
		return 0
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	currentChan = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
	
	numWaves = NumVarOrDefault( prefixFolder + "NumWaves", 0 )
	currentWave = NumVarOrDefault( prefixFolder + "CurrentWave", 0 )
	currentGrp = NMGroupsNum( currentWave, prefixFolder = prefixFolder )
	
	Variable /G $parent + "CurrentChan" = currentChan
	Variable /G $parent + "CurrentGrp" = currentGrp
	Variable /G $parent + "CurrentWave" = currentWave
	Variable /G $parent + "NumActiveWaves" = NumVarOrDefault( prefixFolder + "NumActiveWaves", 0 )
	Variable /G $parent + "NumChannels" = numChannels
	Variable /G $parent + "NumWaves" = numWaves
	Variable /G $parent + "TotalNumWaves" = numChannels * numWaves
	
	setList = NMSetsList( prefixFolder = prefixFolder )
	chanSelectList = StrVarOrDefault( prefixFolder + NMChanSelectVarName, "" )
	
	for ( icnt = 0 ; icnt < ItemsInList( setList ) ; icnt += 1 )
	
		setName = StringFromList( icnt, setList )
		newName = parent + setName
		
		KillWaves /Z $newName
		
		NMPrefixFolderListsToWave( NMSetsStrVarPrefix( setName ), newName, prefixFolder = prefixFolder )
		
		NMSetsWavesTag( newName )
		
	endfor
	
	newName = parent + "Group"
	
	KillWaves /Z $newName
	
	NMGroupsListsToWave( newName, prefixFolder = prefixFolder )
	
	newName = parent + "ChanSelect"
	
	Make /O/N=( numChannels ) $newName = 0
	
	Wave wtemp = $newName
	
	for ( icnt = 0 ; icnt < ItemsInList( chanSelectList ) ; icnt += 1 )
	
		channel = str2num( StringFromList( icnt, chanSelectList ) )
		
		if ( ( channel >= 0 ) && ( channel < numChannels ) )
			wtemp[ channel ] = 1
		endif
		
	endfor
	
	newName = parent + "ChanWaveList"
	
	Make /T/O/N=( numChannels ) $newName = ""
	
	Wave /T stemp = $newName
	
	for ( icnt = 0 ; icnt < numChannels ; icnt += 1 )
	
		stemp[ icnt ] = NMChanWaveList( icnt, prefixFolder = prefixFolder )
		
		wName = prefixFolder + "ChanWaveNames" + ChanNum2Char( icnt )
		newName = parent + "wNames_" + ChanNum2Char( icnt )
		
		if ( WaveExists( $wName ) )
			Duplicate /O $wName $newName
		endif
		
	endfor
	
	newName = parent + "WavSelect"
	
	Make /O/N=( numWaves ) $newName = 0
	
	Wave wtemp = $newName
	
	for ( icnt = 0 ; icnt < numWaves ; icnt += 1 )
		
		wName = NMWaveSelected( currentChan, icnt, prefixFolder = prefixFolder )
			
		if ( strlen( wName ) > 0 )
			wtemp[ icnt ] = 1
		endif
	
	endfor
	
	return 0

End // NMPrefixFolderGetOldGlobals

Function NMPanelDisable()
	
	if ( strlen( CurrentNMPrefixFolder() ) == 0 )
		return 2
	endif
	
	if ( NMNumChannels() <= 0 )
		return 2
	endif
	
	if ( NMNumWaves() <= 0 )
		return 2
	endif
	
	return 0
	
End // NMPanelDisable

Function /S CurrentNMWaveName()

	return NMChanWaveName( -1, -1 )

End // CurrentNMWaveName

Function /S NMSetsMenu()

	String wName, menuStr
	
	if ( strlen( CurrentNMPrefixFolder() ) == 0 )
		return " "
	endif
	
	menuStr = "Sets;---;Define;Equation;Convert;Invert;Clear;---;Edit Panel;---;New;Copy;Rename;Kill;---;Exclude SetX?;Auto Advance;Display;"
	
	wName = NMSetsEqLockWaveName()
	
	if ( WaveExists( $wName ) == 1 )
		menuStr += "Print Equations;"
	endif
	
	return menuStr

End // NMSetsMenu

Function UpdateNMSetsDisplayCount( [ prefixFolder ] ) // udpate count number for display Sets
	String prefixFolder

	Variable scnt, count, currentChan
	String setName
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return NaN
	endif
	
	currentChan = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
	
	for ( scnt = 0 ; scnt < 3 ; scnt += 1 )
	
		setName = NMSetsDisplayName( scnt, prefixFolder = prefixFolder )
		count = ItemsInList( NMSetsWaveList( setName, currentChan, prefixFolder = prefixFolder ) )
		
		SetNMvar( NMDF+"SumSet"+num2istr(scnt), count )
		
	endfor

End // UpdateNMSetsDisplayCount

Function IsNMSetLocked( setName, [ prefixFolder ] )
	String setName
	String prefixFolder
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return 0
	endif
	
	if ( strlen( NMSetsEqLockTableFind( setName, "all", prefixFolder = prefixFolder ) ) > 0 )
		return 1
	endif
	
	return 0
	
End // IsNMSetLocked

Function AreNMSets( setList, [ prefixFolder ] )
	String setList
	String prefixFolder
	
	Variable scnt
	String setName, setList2
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return 0
	endif
	
	for ( scnt = 0 ; scnt < ItemsInList( setList ) ; scnt += 1 )
	
		setName = StringFromList( scnt, setList )
		
		setList2 = NMSetsStrVarSearch( setName, 0, prefixFolder = prefixFolder )
		
		if ( ItemsInList( setList2 ) == 0 )
			return 0
		endif
		
	endfor
	
	return 1
	
End // AreNMSets

Function BinaryInvert( n )
	Variable n
	
	if ( n == 0 )
		return 1
	else
		return 0
	endif

End // BinaryInvert

Function TabNumber( tName, tabList ) // determine the tab number, given the tab's name
	String tName // tab name
	String tabList // list of tab names
	
	Variable icnt
	
	for ( icnt = 0; icnt < NumTabs( tabList ); icnt += 1 )
		if ( StringMatch( TabName( icnt, tabList ), tName ) == 1 )
			return icnt
		endif
	endfor
	
	return -1

End // TabNumber

Function NMConfigsListBoxWavesUpdate( tabName )
	String tabName

	Variable icnt, ocnt, varItems, strItems, items, value
	String varList, strList, objName, type, strValue, cdf, vList
	
	Variable configs = NMVarGet( "ConfigsDisplay" )
	
	String wName = NMConfigsListBoxWaveName()
	String wName2 = wName + "Select"
	String wName3 = wName + "Color"
	
	if ( strlen( tabName ) == 0 )
		tabName = CurrentNMTabName()
	endif
	
	cdf = ConfigDF( tabName )
	
	vList = StrVarOrDefault( cdf + "C_VarList", "" )
	
	varList = NMConfigVarList( tabName, 2 )
	
	if ( ItemsInList( varList ) == 0 )
	
		CheckNMConfig( tabName )
		
		varList = NMConfigVarList( tabName, 2 )
		
	endif
	
	strList = NMConfigVarList( tabName, 3 )
	
	varItems = ItemsInList( varList )
	strItems = ItemsInList( strList )
	
	items = varItems + strItems
	
	if ( WaveExists( $wName ) == 0 )
		Make /O/T/N=( items, 4 ) $wName = ""
	else
		Redimension /N=( items, 4 ) $wName
	endif
	
	if ( WaveExists( $wName2 ) == 0 )
		Make /O/N=( items, 4, 2 ) $wName2 = 0
	else
		Redimension /N=( items, 4, 2 ) $wName2
	endif
	
	if ( WaveExists( $wName3 ) == 0 )
		Make /O/N=( items, 3 ) $wName3 = 0
	else
		Redimension /N=( items, 3 ) $wName3
	endif
	
	Wave /T wtemp = $wName
	Wave stemp = $wName2
	Wave ctemp = $wName3
	
	for (ocnt = 0; ocnt < varItems ; ocnt += 1)
	
		objName = StringFromList( ocnt, varList )
		value = NumVarOrDefault( cdf + objName , Nan )
		type = StrVarOrDefault( cdf + "T_" + objName, "" )
		
		icnt = WhichListItem( objName, vList )
		
		if ( icnt < 0 )
			continue
		endif
		
		wtemp[ icnt ][ 0 ] = objName
		
		wtemp[ icnt ][ 2 ] = ""
		wtemp[ icnt ][ 3 ] = StrVarOrDefault( cdf + "D_" + objName, "" )
		
		strswitch( type )
		
			case "boolean":
			
				if ( value != 1 )
					value = 0
				endif
				
				wtemp[ icnt ][ 1 ] = ""
				
				stemp[ icnt ][ 1 ] = 2^5 + 2^4 * value // //CheckBox
				
				break
				
			default:
			
				wtemp[ icnt ][ 1 ] = num2str( value )
				
				if ( ItemsInList( type ) > 1)
					wtemp[ icnt ][ 2 ] = ""
					stemp[ icnt ][ 1 ] = 0
				else
					wtemp[ icnt ][ 2 ] = type
					stemp[ icnt ][ 1 ] = 2^1
				endif
				
				
		
		endswitch
		
		ctemp[ icnt ][ 0 ] = 0
		ctemp[ icnt ][ 1 ] = 0
		ctemp[ icnt ][ 2 ] = 0

		//icnt += 1
		
	endfor
	
	for (ocnt = 0; ocnt < strItems ; ocnt += 1)
	
		objName = StringFromList( ocnt, strList )
		strValue = StrVarOrDefault( cdf + objName , "" )
		type = StrVarOrDefault( cdf + "T_" + objName, "" )
		
		icnt = WhichListItem( objName, vList )
		
		if ( icnt < 0 )
			continue
		endif
		
		wtemp[ icnt ][ 0 ] = objName
		wtemp[ icnt ][ 1 ] = strValue
		wtemp[ icnt ][ 2 ] = ""
		wtemp[ icnt ][ 3 ] = StrVarOrDefault( cdf + "D_" + objName, "" )
		
		ctemp[ icnt ][ 0 ] = 0
		ctemp[ icnt ][ 1 ] = 0
		ctemp[ icnt ][ 2 ] = 0
		
		if ( ItemsInList( type ) > 1)
		
			wtemp[ icnt ][ 2 ] = ""
			stemp[ icnt ][ 1 ] = 0
			
		elseif ( StringMatch( type, "RGB" ) == 1 )
		
			wtemp[ icnt ][ 2 ] = "RGB"
			stemp[ icnt ][ 1 ] = 0
			
			ctemp[ icnt ][ 0 ] = NMColorListRGB( "red", strValue )
			ctemp[ icnt ][ 1 ] = NMColorListRGB( "green", strValue )
			ctemp[ icnt ][ 2 ] = NMColorListRGB( "blue", strValue )
			
		elseif ( StringMatch( type, "DIR" ) == 1 )
		
			wtemp[ icnt ][ 2 ] = "DIR"
			stemp[ icnt ][ 1 ] = 0
		
		else
		
			wtemp[ icnt ][ 2 ] = type
			stemp[ icnt ][ 1 ] = 2^1
			
		endif
		
		//icnt += 1
		
	endfor

End // NMConfigsListBoxWavesUpdate

Function ChangeTab( fromTab, toTab, tabList ) // change to new tab window
	Variable fromTab
	Variable toTab // tab number
	String tabList // list of tab names
	
	String fromTabName = TabName( fromTab, tabList )
	String toTabName = TabName( toTab, tabList )
	
	Variable configsOn = NMVarGet( "ConfigsDisplay" )
	
	if ( TabExists( tabList ) == 0 )
		//DoAlert 0, "ChangeTabs Abort: tab control does not exist: " + TabCntrlName( tabList )
		return -1
	endif
	
	if ( fromTab != toTab )
		EnableTab( fromTab, tabList, 0 ) // disable controls if they exist
		ExecuteUserTabEnable( fromTabName, 0 )
	endif
	
	EnableTab( toTab, tabList, 1 ) // enable controls if they exist
	
	if ( configsOn == 0 )
		ExecuteUserTabEnable( toTabName, 1 )
	endif
	
	TabControl $TabCntrlName( tabList ), win=$TabWinName( tabList ), value = toTab // reset control

End // ChangeTab

Function LogDisplayCall(ldf)
	String ldf
	
	String vlist = ""

	Variable select = 1
	Prompt select, "display log as:", popup "notebook;table;both;"
	DoPrompt "NeuroMatic Clamp Log File", select
	
	if (V_flag == 1)
		return 0 // cancel
	endif
	
	vlist = NMCmdStr(ldf, vlist)
	vlist = NMCmdNum(select, vlist)
	NMCmdHistory("LogDisplay", vlist)
	
	NMLogDisplay(ldf, select)

End // LogDisplayCall

Function /S NMFolderListName( folder )
	String folder // folder name ( "" ) for current
	
	String prefix = "F"
	
	if ( strlen( folder ) == 0 )
		folder = CurrentNMFolder( 0 )
	endif
	
	Variable id = NMFolderListNum( folder )
	
	if ( numtype( id ) == 0 )
		return prefix + num2istr( id )
	else
		return ""
	endif

End // NMFolderListName

Function ChanScaleSave( channel ) // save graph x-y ranges and graph positions
	Variable channel // ( -1 ) for current channel ( -2 ) for all channels
	
	Variable ccnt, cbgn, cend
	String gName, wList, cdf
	
	Variable numChannels = NMNumChannels()
	
	if ( channel == -1 )
		cbgn = CurrentNMChannel()
		cend = cbgn
	elseif ( channel == -2 )
		cbgn = 0
		cend = numChannels - 1
	elseif ( ( channel >= 0 ) && ( channel < numChannels ) )
		cbgn = channel
		cend = channel
	else
		//return NM2Error( 10, "channel", num2str( channel ) )
		return 0
	endif
	
	for ( ccnt = cbgn; ccnt <= cend; ccnt += 1 )
		
		cdf = ChanDF( ccnt )
		gName = ChanGraphName( ccnt )
		
		wList = TraceNameList( gName, ";", 1 )
		
		if ( ( strlen( cdf ) == 0 ) || ( WinType( gName ) != 1 ) || ( ItemsInList( wList ) == 0 ) )
			continue
		endif
		
		GetAxis /Q/W=$gName bottom
		
		if (V_max > V_min)
			SetNMvar( cdf + "Xmin", V_min )
			SetNMvar( cdf + "Xmax", V_max )
		endif
		
		GetAxis /Q/W=$gName left
		
		if (V_max > V_min)
			SetNMvar( cdf + "Ymin", V_min )
			SetNMvar( cdf + "Ymax", V_max )
		endif
		
		// save graph position
		
		GetWindow $gName wsize
		
		if ( ( V_right > V_left ) && ( V_top < V_bottom ) )
			SetNMvar( cdf + "GX0", V_left )
			SetNMvar( cdf + "GY0", V_top )
			SetNMvar( cdf + "GX1", V_right )
			SetNMvar( cdf + "GY1", V_bottom )
		endif
	
	endfor
	
	return 0
	
End // ChanScaleSave

Function ChanGraphsReset()

	ChanGraphClose( -3, 0 ) // close unnecessary graphs
	ChanOverlayKill( -2 ) // kill unecessary waves
	ChanGraphClear( -2 )
	ChanGraphsRemoveWaves()
	ChanGraphsAppendDisplayWave()
	ChanGraphTagsKill( -2 )
	ChanGraphMove( -2 )

End // ChanGraphsReset

Function /S FolderNameNext( folderName ) // return next unused folder name
	String folderName
	
	Variable fcnt, seqnum, iSeqBgn, iSeqEnd
	String testname, rname = ""
	
	if ( strlen( folderName ) == 0 )
		folderName = "nmFolder" + num2istr( NMFolderListNextNum() )
	else
		folderName = GetPathName( folderName, 0 )
	endif
	
	folderName = NMCheckStringName( folderName )
	
	seqnum = SeqNumFind( folderName )
	
	iSeqBgn = NumVarOrDefault( "iSeqBgn", 0 )
	iSeqEnd = NumVarOrDefault( "iSeqEnd", 0 )

	for ( fcnt = 0; fcnt <= 99; fcnt += 1 )
	
		if ( numtype( seqnum ) == 0 )
			testname = SeqNumSet( folderName, iSeqBgn, iSeqEnd, ( seqnum+fcnt ) )
		else
			testname = folderName + num2istr( fcnt )
		endif
		
		testname = testname[ 0,30 ]
		
		if ( ( strlen( testname ) > 0 ) && ( DataFolderExists( "root:" + testname ) == 0 ) )
			rname = testname
			break
		endif
		
	endfor

	KillVariables /Z iSeqBgn, iSeqEnd
	
	return rname
	
End // FolderNameNext

Function /S CheckFolderNameChar( fname )
	String fname
	
	NMDeprecatedAlert( "NMCheckStringName" )
	
	return NMCheckStringName( fname )
	
End // CheckFolderNameChar

Function /S CheckFolderName( folderName ) // if folder exists, request new folder name
	String folderName
	
	if ( strlen( folderName ) == 0 )
		return ""
	endif
	
	Variable icnt
	
	String parent = GetPathName( folderName, 1 )
	String fname = GetPathName( folderName, 0 )
	
	String lastname, savename = fname
	
	fname = NMCheckStringName( fname )
	
	if ( numtype( str2num( fname[ 0, 0 ] ) ) == 0 )
		fname = "nm" + fname
	endif
	
	do // test whether data folder already exists
	
		if ( DataFolderExists( parent+fname ) == 1 )
			
			lastname = fname
			fname = savename + "_" + num2istr( icnt )
			
			Prompt fname, "Folder " + NMQuotes( lastname ) + " already exists. Please enter a different folder name:"
			DoPrompt "Folder Name Conflict", fname
			
			if ( V_flag == 1 )
				return "" // cancel
			endif

		else
		
			break // name OK
			
		endif
		
	while ( 1 )
	
	return parent+fname

End // CheckFolderName

Function CheckNMPrefixFolder( prefixFolder, numChannels, numWaves ) // check prefix subfolder globals
	String prefixFolder
	Variable numChannels, numWaves
	
	String wName, waveSelect
	
	prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	if ( numtype( numChannels ) == 0 )
		SetNMvar( prefixFolder + "NumChannels", numChannels )
	endif
	
	if ( numtype( numWaves ) == 0 )
		SetNMvar( prefixFolder + "NumWaves", numWaves )
	endif
	
	CheckNMChanWaveLists( prefixFolder = prefixFolder )
	
	CheckNMSets( prefixFolder = prefixFolder )
	CheckNMGroups( prefixFolder = prefixFolder )
	
	CheckNMChanSelect( prefixFolder = prefixFolder )
	CheckNMWaveSelect( prefixFolder = prefixFolder )
	
	return 0

End // CheckNMPrefixFolder

Function /S NMPrefixFolderMake( parent, wavePrefix, numChannels, numWaves )
	String parent, wavePrefix
	Variable numChannels, numWaves
	
	String prefixFolder = NMPrefixFolderDF( parent, wavePrefix )
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	if ( DataFolderExists( prefixFolder ) )
		return "" // already exists
	endif
	
	NewDataFolder $RemoveEnding( prefixFolder, ":" )
	
	CheckNMPrefixFolder( prefixFolder, numChannels, numWaves )
	
	return prefixFolder
	
End // NMPrefixFolderMake

Function NMChanUnits2Labels( [ prefixFolder, updateNM ] )
	String prefixFolder
	Variable updateNM
	
	Variable ccnt, numChannels, numWaves
	String wName, s, x, y
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	if ( ParamIsDefault( updateNM ) )
		updateNM = 1
	endif
	
	numWaves = NumVarOrDefault( prefixFolder + "NumWaves", 0 )
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	if ( numWaves <= 0 )
		return 0
	endif
	
	for ( ccnt = 0; ccnt < numChannels; ccnt += 1 ) // loop thru channels
		
		wName = NMChanWaveName( ccnt, 0, prefixFolder = prefixFolder )
		
		s = WaveInfo( $wName, 0 )
		x = StringByKey( "XUNITS", s )
		y = StringByKey( "DUNITS", s )
		
		if ( strlen( x ) > 0 )
			NMChanLabelSet( ccnt, 2, "x", x, prefixFolder = prefixFolder, updateNM = updateNM )
		endif
		
		if ( strlen( y ) > 0 )
			NMChanLabelSet( ccnt, 2, "y", y, prefixFolder = prefixFolder, updateNM = updateNM )
		endif

	endfor
	
	return 0

End // NMChanUnits2Labels

Function CheckChanSubfolder( channel [ prefixFolder ] )
	Variable channel // ( -1 ) for current channel ( -2 ) for all channels
	String prefixFolder
	
	Variable snum, ft, ccnt, cbgn, cend, numChannels
	String cdf, transform
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return 0
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	if ( channel == -1 )
		cbgn = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
		cend = cbgn
	elseif ( channel == -2 )
		cbgn = 0
		cend = numChannels - 1
	elseif ( ( channel >= 0 ) && ( channel < numChannels ) )
		cbgn = channel
		cend = channel
	else
		//return NM2Error( 10, "channel", num2str( channel ) )
		return 0
	endif
	
	for ( ccnt = cbgn; ccnt <= cend; ccnt += 1 )
	
		cdf = ChanDFname( ccnt, prefixFolder = prefixFolder )
		
		if ( strlen( cdf ) == 0 )
			continue
		endif
		
		if ( !DataFolderExists( cdf ) )
			NewDataFolder $RemoveEnding( cdf, ":" )
		endif
		
		CheckNMvar( cdf + "SmoothN", 0 )
		CheckNMvar( cdf + "Overlay", 0 )
		
		ft = NumVarOrDefault( cdf + "Ft", NaN ) // this variable has been changed to a string variable called "TransformStr"
		
		if ( numtype( ft ) == 0 )
		
			transform = NMChanTransformName( ft )
			
			SetNMstr( cdf + "TransformStr", transform )
			
			KillVariables /Z $cdf + "Ft"
			
		endif
		
		if ( exists( cdf + "Transform" ) == 2 )
		
			transform = StrVarOrDefault( cdf + "Transform", "" )
			
			if ( strlen( transform ) > 0 )
				SetNMstr( cdf + "TransformStr", transform )
			endif
			
			KillVariables /Z $cdf + "Transform"
			KillStrings /Z $cdf + "Transform"
		
		endif
	
	endfor
	
	return 0

End // CheckChanSubfolder

Function NMSetsListsUpdateNewChannels( [ prefixFolder ] )
	String prefixFolder
	
	String setList

	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif

	setList = NMSetsList( prefixFolder = prefixFolder )
	
	NMSetsWavesKill( prefixFolder = prefixFolder )
	
	NMSetsListsToWaves( setList, prefixFolder = prefixFolder )
	
	NMSetsKill( setList, prefixFolder = prefixFolder, updateNM = 0 )
	NMSetsWavesToLists( setList, prefixFolder = prefixFolder )
	
	NMSetsWavesKill( prefixFolder = prefixFolder )
	
End // NMSetsListsUpdateNewChannels

Function NMGroupsListsUpdateNewChannels( [ prefixFolder ] )
	String prefixFolder
	
	String gwName
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif

	gwName = NMGroupsWaveName( prefixFolder = prefixFolder )

	KillWaves /Z $gwName
	
	NMGroupsListsToWave( gwName, prefixFolder = prefixFolder )
	
	NMGroupsWaveToLists( gwName, prefixFolder = prefixFolder )

	KillWaves /Z $gwName
	
	return 0

End // NMGroupsListsUpdateNewChannels

Function NMChannelGraphSet( [ channel, autoScale, freezeX, freezeY, xmin, xmax, ymin, ymax, overlayNum, overlayColor, grid, markers, errors, errorPointsLimit, toFront, drag, left, top, right, bottom, reposition, on, prefixFolder, history ] )
	
	Variable channel // ( -1 ) for current channel ( -2 ) for all channels
	
	Variable autoScale, freezeX, freezeY // auto-scaling
	Variable xmin, xmax, ymin, ymax // x-scale and y-scale min/max values
	
	Variable overlayNum // number of waves to overlay
	String overlayColor // overlay wave color (rgb list)
	
	Variable grid // ( 0 ) off ( 1 ) on
	Variable markers // marker types
	Variable errors // ( 0 ) off ( 1 ) on
	Variable errorPointsLimit // upper points limit for displaying errors
	Variable toFront // ( 0 ) off ( 1 ) on
	Variable drag // vertical drag waves ( 0 ) off ( 1 ) on
	
	Variable left, top, right, bottom // graph window coordinates
	Variable reposition // reset graph positions
	
	Variable on // ( 0 ) hide graph ( 1 ) show graph
	
	String prefixFolder
	
	Variable history // print function command to history ( 0 ) no ( 1 ) yes
	
	Variable update, updateall, ccnt, cbgn = 0, cend = -1
	Variable numChannels, currentChannel
	String gName, vlist = "", vlist2 = "", cdf = ""
	
	if ( ParamIsDefault( prefixFolder ) )
	
		prefixFolder = CurrentNMPrefixFolder()
		
	else
	
		if ( strlen( prefixFolder ) > 0 )
			vlist2 = NMCmdStrOptional( "prefixFolder", prefixFolder, vlist2 )
		elseif ( NMPrefixFolderHistory && ( strlen( prefixFolder ) == 0 ) )
			prefixFolder = CurrentNMPrefixFolder()
			vlist2 = NMCmdStrOptional( "prefixFolder", prefixFolder, vlist2 )
		endif
		
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
		
	endif
	
	numChannels =  NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	currentChannel = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
	
	if ( ParamIsDefault( channel ) )
		channel = currentChannel
	else
		vlist = NMCmdNumOptional( "channel", channel, vlist )
	endif
	
	if ( numtype( channel ) == 0 )
	
		if ( channel == -1 )
			cbgn = currentChannel
			cend = cbgn
		elseif ( channel == -2 )
			cbgn = 0
			cend = numChannels - 1
		elseif ( ( channel >= 0 ) && ( channel < numChannels ) )
			cbgn = channel
			cend = channel
		else
			//return NM2Error( 10, "channel", num2str( channel ) )
			return 0
		endif
		
		for ( ccnt = cbgn ; ccnt <= cend ; ccnt += 1 )
		
			cdf = ChanDF( ccnt, prefixFolder = prefixFolder )
			gName = ChanGraphName( ccnt )
			
			if ( !DataFolderExists( cdf ) )
				continue
			endif
			
			if ( !ParamIsDefault( autoscale ) )
			
				vlist = NMCmdNumOptional( "autoscale", autoscale, vlist )
			
				autoscale = BinaryCheck( autoscale )
			
				if ( !autoscale )
					ChanScaleSave( ccnt )
				endif
	
				SetNMvar( cdf + "AutoScale", autoscale )
				SetNMvar( cdf + "FreezeX", 0 ) // turn off
				SetNMvar( cdf + "FreezeY", 0 ) // turn off
				
				update = 1
			
			endif
			
			if ( !ParamIsDefault( freezeX ) )
			
				vlist = NMCmdNumOptional( "autoscale", autoscale, vlist )
			
				freezeX = BinaryCheck( freezeX )
	
				if ( freezeX )
					SetNMvar( cdf + "AutoScale", 0 )
					SetNMvar( cdf + "FreezeX", 1 )
					SetNMvar( cdf + "FreezeY", 0 )
				else
					SetNMvar( cdf + "AutoScale", 1 )
					SetNMvar( cdf + "FreezeX", 0 )
					SetNMvar( cdf + "FreezeY", 0 )
				endif
				
				update = 1
			
			endif
			
			if ( !ParamIsDefault( freezeY ) )
			
				vlist = NMCmdNumOptional( "freezeY", freezeY, vlist )
			
				freezeY = BinaryCheck( freezeY )
	
				if ( freezeY )
					SetNMvar( cdf + "AutoScale", 0 )
					SetNMvar( cdf + "FreezeX", 0 )
					SetNMvar( cdf + "FreezeY", 1 )
				else
					SetNMvar( cdf + "AutoScale", 1 )
					SetNMvar( cdf + "FreezeX", 0 )
					SetNMvar( cdf + "FreezeY", 0 )
				endif
				
				update = 1
			
			endif
			
			if ( !ParamIsDefault( xmin ) && !ParamIsDefault( xmax ) )
			
				vlist = NMCmdNumOptional( "xmin", xmin, vlist )
				vlist = NMCmdNumOptional( "xmax", xmax, vlist )
			
				if ( ( numtype( xmin * xmax ) == 0 ) && ( WinType( gName ) == 1 ) )
				
					SetAxis /W=$gName bottom xmin, xmax
					DoUpdate /W=$gName
	
					SetNMvar( cdf + "Xmin", xmin )
					SetNMvar( cdf + "Xmax", xmax )
					SetNMvar( cdf + "AutoScale", 0 )
					SetNMvar( cdf + "FreezeX", 1 )
					update = 1
					
				endif
			
			endif
			
			if ( !ParamIsDefault( ymin ) && !ParamIsDefault( ymax ) )
			
				vlist = NMCmdNumOptional( "ymin", ymin, vlist )
				vlist = NMCmdNumOptional( "ymax", ymax, vlist )
			
				if ( ( numtype( ymin * ymax ) == 0 ) && ( WinType( gName ) == 1 ) )
				
					SetAxis /W=$gName left ymin, ymax
					DoUpdate /W=$gName
					
					SetNMvar( cdf + "Ymin", ymin )
					SetNMvar( cdf + "Ymax", xmax )
					SetNMvar( cdf + "AutoScale", 0 )
					SetNMvar( cdf + "FreezeY", 1 )
					update = 1
					
				endif
			
			endif
			
			if ( !ParamIsDefault( overlayNum ) )
			
				vlist = NMCmdNumOptional( "overlayNum", overlayNum, vlist )
			
				if ( ( numtype( overlayNum ) > 0 ) || ( overlayNum < 0 ) )
					overlayNum = 0
				endif
	
				ChanOverlayClear( ccnt )
			
				SetNMvar( cdf + "Overlay", overlayNum )
				SetNMvar( cdf + "OverlayCount", 1 )
			
				ChanOverlayKill( ccnt )
				
			endif
			
			if ( !ParamIsDefault( overlayColor ) )
			
				vlist = NMCmdStrOptional( "overlayColor", overlayColor, vlist )
				
				ChanOverlayClear( ccnt )
				SetNMstr( cdf + "OverlayColor", overlayColor )
				
			endif
			
			if ( !ParamIsDefault( grid ) )
			
				vlist = NMCmdNumOptional( "grid", grid, vlist )
				
				SetNMvar( cdf + "GridFlag", BinaryCheck( grid ) )
				update = 1
				
			endif
			
			if ( !ParamIsDefault( markers ) )
	
				vlist = NMCmdNumOptional( "markers", markers, vlist )
			
				switch( markers )
					case 0: // lines only
					case 1: // markers only
					case 2: // lines + markers
						SetNMvar( cdf + "Markers", markers )
						update = 1
				endswitch
	
			endif
			
			if ( !ParamIsDefault( errors ) )
			
				vlist = NMCmdNumOptional( "errors", errors, vlist )
				
				SetNMvar( cdf + "ErrorsOn", BinaryCheck( errors ) )
				update = 1
				
			endif
			
			if ( !ParamIsDefault( toFront ) )
			
				vlist = NMCmdNumOptional( "toFront", toFront, vlist )
				
				SetNMvar( cdf + "ToFront", BinaryCheck( toFront ) )
				update = 1
				
			endif
			
			if ( !ParamIsDefault( left ) && !ParamIsDefault( top ) && !ParamIsDefault( right ) && !ParamIsDefault( bottom ) )
			
				vlist = NMCmdNumOptional( "left", left, vlist )
				vlist = NMCmdNumOptional( "top", top, vlist )
				vlist = NMCmdNumOptional( "right", right, vlist )
				vlist = NMCmdNumOptional( "bottom", bottom, vlist )
			
				if ( ( numtype( left * top * right * bottom ) == 0 ) && ( right > left ) && ( top < bottom ) ) 
					MoveWindow /W=$gName left, top, right, bottom
					update = 1
				endif
	
			endif
			
			if ( !ParamIsDefault( reposition ) && reposition )
			
				vlist = NMCmdNumOptional( "reposition", reposition, vlist )
			
				SetNMvar( cdf + "GX0", Nan )
				SetNMvar( cdf + "GY0", Nan )
				SetNMvar( cdf + "GX1", Nan )
				SetNMvar( cdf + "GY1", Nan )
			
				ChanGraphSetCoordinates( ccnt )
				ChanGraphMove( ccnt )
				update = 1
				
			endif
			
			if ( !ParamIsDefault( on ) )
			
				vlist = NMCmdNumOptional( "on", on, vlist )
				
				SetNMvar( cdf + "On", BinaryCheck( on ) )
				update = 1
				
			endif
			
		endfor
	
	endif
	
	if ( !ParamIsDefault( errorPointsLimit )  && ( errorPointsLimit >= 0 ) )
	
		vlist = NMCmdNumOptional( "errorPointsLimit", errorPointsLimit, vlist )
		
		NMConfigVarSet( "NM" , "ErrorPointsLimit" , errorPointsLimit )
		updateall = 1
		
	endif
	
	if ( !ParamIsDefault( drag ) )
	
		vlist = NMCmdNumOptional( "drag", drag, vlist )
			
		drag = BinaryCheck( drag )
		SetNMvar( NMDF + "DragOn", drag )

		if ( drag )
		
			Execute /Z CurrentNMTabName() + "Tab( 1 )" // should append drag waves for specific tab
			
		else
			
			for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
				gName = ChanGraphName( ccnt )
				NMDragGraphUtility( gName, "remove" )
			endfor
	
		endif

	endif
	
	if ( history )
		NMCmdHistory( "", vlist + vlist2 )
	endif
	
	if ( updateall )
	
		ChanGraphsUpdate()
		
	else
	
		for ( ccnt = cbgn ; ccnt <= cend ; ccnt += 1 )
			ChanGraphUpdate( ccnt, 1 )
			ChanGraphControlsUpdate( ccnt )
		endfor
		
	endif
	
End // NMChannelGraphSet

Function NMSetsPanelUpdate( updateTable )
	Variable updateTable // ( 0 ) no ( 1 ) yes
	
	Variable numWaves, grpsOn, md, dis, disableAll = 2
	String txt, setList, displayList, parent = "", prefix = ""
	
	String prefixFolder = CurrentNMPrefixFolder()
	
	if ( WinType( NMSetsPanelName ) != 7 )
		NMSetsWavesKill( prefixFolder = prefixFolder )
		return 0
	endif
	
	NMSetsWavesKill( prefixFolder = prefixFolder )
	NMSetsListsToWavesAll( prefixFolder = prefixFolder )
	
	setList = NMSetsPanelList()
	
	displayList = NMSetsDisplayList( prefixFolder = prefixFolder )
	
	grpsOn = NMVarGet( "GroupsOn" )
	
	numWaves = NumVarOrDefault( prefixFolder + "NumWaves", 0 )
	
	if ( strlen( prefixFolder ) > 0 )
	
		prefix = GetPathName( prefixFolder, 0 )
		prefix = ReplaceString( NMPrefixSubfolderPrefix, prefix, "" )
		
		parent = GetPathName( prefixFolder, 1 )
		parent = GetPathName( parent, 0 )
	
		CheckNMvar( prefixFolder+"SetsFromWave", 0 )
		CheckNMvar( prefixFolder+"SetsToWave", max( numwaves-1, 0 ) )
		CheckNMvar( prefixFolder+"SetsSkipWaves", 0 )
		
		disableAll = 0
		
	endif
	
	String setName = StrVarOrDefault( prefixFolder+"SetsDefineSelect", "" )
	
	Variable value = NumVarOrDefault( prefixFolder+"SetsDefineValue", 1 )
	
	Variable fxnOn = NumVarOrDefault( NMDF+"SetsFxnOn", 0 )
	String fxnArg1 = StrVarOrDefault( prefixFolder+"SetsFxnArg1", "" )
	String fxnOp = StrVarOrDefault( prefixFolder+"SetsFxnOp", " " )
	String fxnArg2 = StrVarOrDefault( prefixFolder+"SetsFxnArg2", "" )
	Variable fxnLocked = 0
	
	Variable autoSave = NumVarOrDefault( NMDF+"SetsPanelAutoSave", 1 )
	
	if ( strlen( setName ) == 0 )
		setName = StringFromList( 0, setList )
		SetNMstr( prefixFolder+"SetsDefineSelect", setName )
	endif
	
	if ( IsNMSetLocked( setName, prefixFolder = prefixFolder ) )
		fxnOn = 1
		fxnArg1 = NMSetsEqLockTableFind( setName, "arg1", prefixFolder = prefixFolder )
		fxnOp = NMSetsEqLockTableFind( setName, "op", prefixFolder = prefixFolder )
		fxnArg2 = NMSetsEqLockTableFind( setName, "arg2", prefixFolder = prefixFolder )
		fxnLocked = 1
	endif
	
	DoWindow /T $NMSetsPanelName, "Edit Sets : " + parent + " : " + prefix
	
	md = WhichListItem( setName, NMSetsPanelSelectMenu() )
	
	if ( md >= 0 )
		md += 1
	endif
	
	//PopupMenu NM_SetsSelect, win=$NMSetsPanelName, mode=max(md,1), disable=disableAll, value=NMSetsPanelSelectMenu()
	
	if ( fxnOn )
		dis = 2
	endif
	
	dis = z_Disable( dis, disableAll )
	
	GroupBox NM_SetsPanelGrp, win=$NMSetsPanelName, disable=dis
	
	SetVariable NM_SetsFromWave, win=$NMSetsPanelName, disable=dis, value=$( prefixFolder+"SetsFromWave" )
	SetVariable NM_SetsToWave, win=$NMSetsPanelName, disable=dis, value=$( prefixFolder+"SetsToWave" )
	SetVariable NM_SetsSkipWaves, win=$NMSetsPanelName, disable=dis, value=$( prefixFolder+"SetsSkipWaves" )
	
	md = WhichListItem( num2str( value ), "0;1;" )
	
	if ( md >= 0 )
		md += 1
	endif
	
	//PopupMenu NM_SetsDefineValue, win=$NMSetsPanelName, mode=max(md,1), value="0;1;", disable=dis
	
	dis = 2
	txt = "Equation"
	
	if ( fxnOn )
		dis = 0
		txt = setName + " ="
	endif
	
	GroupBox NM_SetsPanelGrp2, title=z_Grp2StrBlank( txt )
	//CheckBox NM_SetsPanelEqOn, win=$NMSetsPanelName, value=fxnOn, title=txt
	
	md = 1
	
	txt = NMSetsPanelArgMenu()
	
	if ( dis == 0 )
	
		md = WhichListItem( fxnArg1, txt )
		
		if ( md >= 0 )
			md += 1
		endif
	
	endif
	
	//PopupMenu NM_SetsArg1, win=$NMSetsPanelName, mode=max(md,1), disable=disableAll, value=NMSetsPanelArgMenu()
	
	md = 1
	
	if ( dis == 0 )
	
		md = WhichListItem( fxnOp, " ;AND;OR;" )
		
		if ( md >= 0 )
			md += 1
		endif
		
	endif
	
	//PopupMenu NM_SetsOp, win=$NMSetsPanelName, mode=max(md,1), value=" ;AND;OR;", disable=dis
	
	md = 1
	
	txt = NMSetsPanelArgMenu()
	
	if ( dis == 0 )
	
		md = WhichListItem( fxnArg2, txt )
		
		if ( md >= 0 )
			md += 1
		endif
	
	endif
	
	//PopupMenu NM_SetsArg2, win=$NMSetsPanelName, mode=max(md,1), disable=dis, value=NMSetsPanelArgMenu()
	
	//CheckBox NM_SetsPanelEqLock, win=$NMSetsPanelName, value=fxnLocked
	
	dis = 0
	
	if ( autoSave )
		dis = 2
	endif
	
	dis = z_Disable( dis, disableAll )
	
	Button NM_SetsPanelExecute, win=$NMSetsPanelName, disable=disableAll
	Button NM_SetsPanelClear, win=$NMSetsPanelName, disable=disableAll
	Button NM_SetsPanelInvert, win=$NMSetsPanelName, disable=disableAll
	
	Button NM_SetsPanelNew, win=$NMSetsPanelName, disable=disableAll
	
	Button NM_SetsPanelSave, win=$NMSetsPanelName, disable=dis
	
	//CheckBox NM_SetsPanelSaveAuto, win=$NMSetsPanelName, disable=disableAll, value=autoSave
	
	if ( updateTable )
		NMSetsPanelTable( 1 )
	endif

End // NMSetsPanelUpdate

Function NMGroupsPanelUpdate( updateTable )
	Variable updateTable // ( 0 ) no ( 1 ) yes
	
	Variable dis, disableAll = 0

	String prefixFolder = CurrentNMPrefixFolder()
	String currentPrefix = CurrentNMWavePrefix()

	if ( WinType( NMGroupsPanelName ) != 7 )
		KillWaves /Z $NMGroupsWaveName( prefixFolder = prefixFolder )
		return 0
	endif
	
	NMGroupsPanelDefaults()
	
	Variable autoSave = NumVarOrDefault( NMDF+"GroupsPanelAutoSave", 1 )
	
	if ( strlen( prefixFolder ) == 0 )
		disableAll = 2
	endif
	
	DoWindow /T $NMGroupsPanelName, "Edit Groups : " + CurrentNMFolder( 0 ) + " : " + currentPrefix
	
	GroupBox NM_GrpsPanelBox, win=$NMGroupsPanelName, disable=disableAll
	
	SetVariable NM_NumGroups, win=$NMGroupsPanelName, disable=disableAll, value=$( prefixFolder+"NumGrps" )
	
	SetVariable NM_FirstGroup, win=$NMGroupsPanelName, disable=disableAll, value=$( prefixFolder+"FirstGrp" )
	
	SetVariable NM_SeqStr, win=$NMGroupsPanelName, disable=disableAll, value=$( prefixFolder+"GroupsSeqStr" )
	
	SetVariable NM_WaveStart, win=$NMGroupsPanelName, disable=disableAll, value=$( prefixFolder+"GroupsFromWave" )
	
	SetVariable NM_WaveEnd, win=$NMGroupsPanelName, disable=disableAll, value=$( prefixFolder+"GroupsToWave" )
	
	SetVariable NM_WaveBlocks, win=$NMGroupsPanelName, disable=disableAll, value=$( prefixFolder+"GroupsWaveBlocks" )
	
	Button NM_Execute, win=$NMGroupsPanelName, disable=disableAll
	Button NM_Clear, win=$NMGroupsPanelName, disable=disableAll
	
	dis = 0
	
	if ( ( autoSave == 1 ) || ( disableAll == 2 ) )
		dis = 2
	endif
	
	Button NM_Save, win=$NMGroupsPanelName, disable=dis
	
	//CheckBox NM_SaveAuto, win=$NMGroupsPanelName, disable=disableAll
	
	if ( updateTable == 1 )
		NMGroupsPanelTable( 1 )
	endif

End // NMGroupsPanelUpdate

Function /S CurrentNMTabName()

	return TabName( NMVarGet( "CurrentTab" ), NMTabControlList() )

End // CurrentNMTabName

Function /S NMPackageDF( subfolderName )
	String subfolderName
	
	if ( StringMatch( subfolderName, "NeuroMatic" ) == 1 )
		return NMDF
	endif
	
	return LastPathColon( NMDF + subfolderName, 1 )
	
End // NMPackageDF

Function NMGroupsNum( waveNum, [ prefixFolder ] ) // determine group number from wave number
	Variable waveNum // wave number, or ( -1 ) for current
	String prefixFolder
	
	Variable gcnt, ccnt, group, numChannels, numWaves
	String groupList, groupSeqStr, wList, wName
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return NaN
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	if ( numChannels <= 0 )
		return NaN
	endif
	
	if ( ( numtype( waveNum ) > 0 ) || ( waveNum < 0 ) )
		waveNum = NumVarOrDefault( prefixFolder + "CurrentWave", 0 )
	endif
	
	numWaves = NumVarOrDefault( prefixFolder + "NumWaves", 0 )
	
	if ( numWaves <= 0 )
		return NaN
	endif
	
	if ( ( waveNum < 0 ) || ( waveNum >= numWaves ) )
		return Nan
	endif
	
	groupList = NMGroupsList( 0, prefixFolder = prefixFolder )
	
	if ( ItemsInList( groupList ) == 0 )
		return Nan
	endif
	
	for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
	
		wName = NMChanWaveName( ccnt, waveNum, prefixFolder = prefixFolder )
		
		groupSeqStr = NMGroupsNumStrWaveNote( wName )
		
		if ( strlen( groupSeqStr ) > 0 )
	
			return str2num( groupSeqStr )
			
		else
		
			for ( gcnt = 0 ; gcnt < ItemsInList( groupList ) ; gcnt += 1 )
	
				group = str2num( StringFromList( gcnt, groupList ) )
				
				wList = NMGroupsWaveList( group, ccnt, prefixFolder = prefixFolder )
				
				if ( WhichListItem( wName, wList ) >= 0 )
					return group
				endif
				
			endfor
		
		endif
	
	endfor
	
	return Nan
	
End // NMGroupsNum

Function /S NMGroupsStr( group )
	Variable group
	
	if ( numtype( group ) == 0 )
		 return num2istr( group )
	else
		return ""
	endif

End // NMGroupsStr

Function EnableTab( tabNum, tabList, enable ) // enable/disable a tab window
	Variable tabNum // tab number
	String tabList // list of tab names
	Variable enable // 1 - enable; 0 - disable
	
	Variable configsOn = NMVarGet( "ConfigsDisplay" )
	
	String cList
	String windowName = TabWinName( tabList )
	
	if ( TabExists( tabList ) == 0 )
		//DoAlert 0, "EnableTabs Abort: tab control does not exist: " + TabCntrlName( tabList )
		return -1
	endif
	
	DoWindow /F $windowName
	
	cList = ControlList( windowName, "CF_*", ";" )
	
	if ( configsOn > 0 )
		EnableTabList( windowName, cList, 1 )
		enable = 0
	else
		EnableTabList( windowName, cList, 0 )
	endif
	
	cList = ControlList( windowName, TabPrefix( tabNum, tabList ) + "*", ";" )
	
	EnableTabList( windowName, cList, enable )

End // EnableTab

Function UpdateNMTab()

	Variable thisTab = NMVarGet( "CurrentTab" )
	
	NMTabsMake( 1 ) // checks if tablist has changed
	
	ChangeTab( thisTab, thisTab, NMTabControlList() )

End // UpdateNMTab

Function UpdateNMPanelTabNames()

	Variable configs = NMVarGet("ConfigsDisplay")
	
	String ctrlName = NMTabControlName()
	
	Variable extraTabNum = NMTabsExtraNum()
	
	if ( configs == 1 )
		TabControl $ctrlName, win=$NMPanelName, tabLabel( extraTabNum )="NM"
	else
		TabControl $ctrlName, win=$NMPanelName, tabLabel( extraTabNum )="+"
	endif
	
End // UpdateNMPanelTabNames

Function UpdateNMPanelVariables()

	Variable currentWave, currentGroup
	
	String prefixFolder = CurrentNMPrefixFolder()
	
	if ( strlen( prefixFolder ) == 0 )
		
		SetNMvar( NMDF+"SumSet0", 0 )
		SetNMvar( NMDF+"SumSet1", 0 )
		SetNMvar( NMDF+"SumSet2", 0 )
		SetNMvar( NMDF+"NumActiveWaves", 0 )
		SetNMvar( NMDF+"CurrentWave", 0 )
		SetNMvar( NMDF+"CurrentGrp", 0)
		SetNMstr( NMDF+"CurrentGrpStr", "0")
	
	else
	
		currentWave = CurrentNMWave()
		currentGroup = NMGroupsNum( -1 )
	
		//SetNMvar( NMDF+"NumActiveWaves", NumVarOrDefault(prefixFolder+"NumActiveWaves", 0) )
		SetNMvar( NMDF+"CurrentWave", currentWave )
		SetNMvar( NMDF+"CurrentGrp", currentGroup )
		SetNMstr( NMDF+"CurrentGrpStr", NMGroupsStr( currentGroup ) )
	
	endif

End // UpdateNMPanelVariables

Function UpdateNMPanelFolderMenu()

	if (WinType(NMPanelName) == 0)
		return 0
	endif
	
	String item = NMFolderListName("") + " : " + CurrentNMFolder( 0 )
	
	Variable md = max(1, 1 + WhichListItem(item, NMFolderMenu()))

	//PopupMenu NM_FolderMenu, mode=md, value=NMFolderMenu(), win=$NMPanelName

End // UpdateNMPanelFolderMenu

Function UpdateNMPanelGroupMenu()

	//PopupMenu NM_GroupMenu, mode=1, value=NMGroupsMenu(), win=$NMPanelName

End // UpdateNMPanelGroupMenu

Function UpdateNMPanelSetVariables()

	Variable numWaves, numWavesMax, x0 = 40, y0 = 6, yinc = 29
	
	String prefixFolder = CurrentNMPrefixFolder()

	Variable grpsOn = NMVarGet( "GroupsOn" )
	
	Variable dis = NMPanelDisable()
	
	if ( strlen( prefixFolder ) > 0 )
		numWaves = NMNumWaves()
		numWavesMax = max( 0, numWaves - 1 )
	else
		grpsOn = 0
	endif
	
	if (grpsOn == 1)
		SetVariable NM_SetWaveNum, win=$NMPanelName, limits={0,numWavesMax,0}, pos={x0+20, y0+2*yinc+3}, disable=dis
		SetVariable NM_SetGrpStr, win=$NMPanelName, disable=0
	else
		SetVariable NM_SetWaveNum, win=$NMPanelName, limits={0,numWavesMax,0}, pos={x0+49, y0+2*yinc+3}, disable=dis
		SetVariable NM_SetGrpStr, win=$NMPanelName, disable=1
	endif
	
	Slider NM_WaveSlide, win=$NMPanelName, limits={0,numWavesMax,1}, disable=dis
	
	Button NM_JumpBck, win=$NMPanelName, disable=dis
	Button NM_JumpFwd, win=$NMPanelName, disable=dis

End // UpdateNMPanelSetVariables

Function UpdateNMPanelChanSelect()

	Variable cmode
	
	Variable numChannels = NMNumChannels()
	Variable dis = NMPanelDisable()
	
	String chanStr = NMChanSelectStr()
	String chanMenu = NMChanSelectMenu()
	
	cmode = WhichListItem( chanStr , chanMenu )
	
	cmode = max( cmode, 0 )
	
	//PopupMenu NM_ChanMenu, win=$NMPanelName, mode=(cmode+1), value=NMChanSelectMenu(), disable=dis

End // UpdateNMPanelChanSelect

Function UpdateNMPanelWaveSelect()

	Variable modenum
	
	Variable dis = NMPanelDisable()
	
	String waveSelect = NMWaveSelectGet()
	String wmenu = NMWaveSelectMenu()
	
	if ( StringMatch( wmenu, "Wave Select" ) == 1 )
		waveSelect = "Wave Select"
	endif
	
	modenum = WhichListItem(waveSelect, wmenu, ";", 0, 0)
			
	if (modenum == -1) // not in list
		waveSelect = "Wave Select"
		modenum = WhichListItem(waveSelect, wmenu, ";", 0, 0)
	endif
	
	modenum = max( modenum , 0 )
	
	//PopupMenu NM_WaveMenu, win=$NMPanelName, mode=(modenum+1), value=NMWaveSelectMenu(), disable=dis

End // UpdateNMPanelWaveSelect

Function /S NMNotebookName( select )
	String select // "results" or "commands"
	
	strswitch( select )
		case "results":
			return "NM_ResultsHistory"
		case "commands":
			return "NM_CommandHistory"
	endswitch
	
	return ""

End // NMNotebookName

Function NMNotebookResults()

	String nbName = NMNotebookName( "results" )
		
	if ( WinType( nbName ) == 5 ) // create new notebook
		return 0
	endif
	
	NewNotebook /F=0/N=$nbName/W=( 0,0,0,0 ) as "NeuroMatic Results Notebook"
	NMWinCascade( nbName )
	
	NoteBook $nbName text="Date: " + date()
	NoteBook $nbName text=NMCR + "Time: " + time()
	NoteBook $nbName text=NMCR

End // NMNotebookResults

Function NMNotebookCommands()

	String nbName = NMNotebookName( "commands" )

	if ( WinType( nbName ) == 5 ) // create new notebook
		return 0
	endif
	
	NewNotebook /F=0/N=$nbName/W=( 400,100,800,400 ) as "NeuroMatic Command Notebook"
	
	NoteBook $nbName text="Date: " + date()
	NoteBook $nbName text=NMCR + "Time: " + time()
	NoteBook $nbName text=NMCR + NMCR + "**************************************************************************************"
	NoteBook $nbName text=NMCR + "**************************************************************************************"
	NoteBook $nbName text=NMCR + "***\tNote: the following commands can be copied to an Igor procedure file"
	NoteBook $nbName text=NMCR + "***\t( such as NM_MyTab.ipf ) and used in your own macros or functions."
	NoteBook $nbName text=NMCR + "***\tFor example:"
	NoteBook $nbName text=NMCR + "***"
	NoteBook $nbName text=NMCR + "***\t\tMacro MyMacro()"
	NoteBook $nbName text=NMCR + "***\t\t\tNMChanSelect( \"A\" )"
	NoteBook $nbName text=NMCR + "***\t\t\tNMWaveSelect( \"Set1\" )"
	NoteBook $nbName text=NMCR + "***\t\t\tNMPlot( \"rainbow\" , 0 , 0 )"
	NoteBook $nbName text=NMCR + "***\t\t\tNMBaselineWaves( 1 , 0 , 15 )"
	NoteBook $nbName text=NMCR + "***\t\t\tNMWavesStats( 2 , 0 , 1 , 1 , 0 , 0 , 1 , 1 )"
	NoteBook $nbName text=NMCR + "***\t\tEnd"
	NoteBook $nbName text=NMCR + "***"
	NoteBook $nbName text=NMCR + "**************************************************************************************"
	NoteBook $nbName text=NMCR + "**************************************************************************************"

End // NMNotebookCommands

Function /S TabName( tabNum, tabList ) // extract tab name from the tab list
	Variable tabNum // tab number
	String tabList // list of tab names
	String name = ""
	
	name = StringFromList( tabNum, tabList, ";" )
	name = StringFromList( 0, name, "," )
	
	return name

End // TabName

Function /S ChanDFname( channel [ prefixFolder ] )
	Variable channel // ( -1 ) for current channel
	String prefixFolder
	
	String gName
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	gName = ChanGraphName( channel )
	
	return prefixFolder + gName + ":"
	
End // ChanDFname

Function /S NMCheckStringName( strName )
	String strName
	
	if ( strlen( strName ) == 0 )
		return ""
	endif
	
	strName = CleanupName( strName, 0 )
	
	strName = ReplaceString( "__", strName, "_" )
	strName = ReplaceString( "__", strName, "_" )
	strName = ReplaceString( "__", strName, "_" )
	
	strName = RemoveEnding( strName , "_" )
	
	return strName[ 0, 30 ] // max 31 characters

End // NMCheckStringName

Function TabExists( tabList ) // determine if tab control exists, as defined by tab list
	String tabList // list of tab names
	
	ControlInfo /W=$TabWinName( tabList ) $TabCntrlName( tabList )
	
	if ( V_Flag == 8 )
		return 1
	else
		return 0
	endif
	
End // TabExists

Function NumTabs( tabList ) // compute the number of tabs defined by tab list
	String tabList // list of tab names
	
	return ItemsInList( tabList, ";" )-1

End // NumTabs

Function KillTab( tabNum, tabList, dialogue ) // kill global variables, controls and windows related to a tab
	Variable tabNum // tab number
	String tabList // list of tab names
	Variable dialogue // call dialogue flag ( 1 - yes; 0 - no )
	
	String prefix = TabPrefix( tabNum, tabList ) + "*"
	String tname = TabName( tabNum, tabList )
	
	if ( TabExists( tabList ) == 0 )
		//DoAlert 0, "KillTabs Abort: tab control does not exist: " + TabCntrlName( tabList )
		return -1
	endif
	
	if ( ExecuteUserTabEnable( tName, 0 ) < 0 )
		return -1
	endif
	
	If ( dialogue == 1 )
		DoAlert 1, "Kill " + TMQuotes( tname ) + " plots and tables?"
	endif
		
	if ( ( V_Flag == 1 ) || ( dialogue == 0 ) )
		KillWindows( prefix )
	endif
	
	If ( dialogue == 1 )
		DoAlert 1, "Kill " + TMQuotes( tname ) + " output waves?"
	endif
		
	if ( ( V_Flag == 1 ) || ( dialogue == 0 ) )
	
		KillGlobals( GetDataFolder( 1 ), prefix, "001" ) // kill waves
		
		ExecuteUserTabKill( tName, "waves" )
		
	endif
	
	If ( dialogue == 1 )
		DoAlert 1, "Kill " + TMQuotes( tname ) + " strings and variables?"
	endif
	
	if ( ( V_Flag == 1 ) || ( dialogue == 0 ) )
	
		KillGlobals( GetDataFolder( 1 ), prefix, "110" ) // kill variables and strings in current folder
		
		ExecuteUserTabKill( tName, "folder" )
		
	endif
	
End // KillTab

Function CheckNMConfig( fname )
	String fname // config folder name ( "NeuroMatic", "Chan", "Stats"... )
	
	CheckNMConfigDF( fname )
	
	NMConfigListReset( fname )
	
	Execute /Z "NM" + fname + "Configs()" // run particular configs function if it exists
	
	if ( V_Flag == 2003 )
		Execute /Z fname + "Configs()" // try another name
	endif
	
	NMConfigCleanUp( fname )
	
	//UpdateNMConfigMenu()
	
End // CheckNMConfig

Function NMConfigCopy( flist, direction ) // set configurations
	String flist // config folder name list or "All"
	Variable direction // ( -1 ) config to package folder ( 1 ) package folder to config
	
	Variable icnt, fcnt
	String fname, objName, cdf, df, objList
	
	if ( StringMatch( flist, "All" ) == 1 )
		flist = NMConfigList()
	endif
	
	for ( fcnt = 0; fcnt < ItemsInList( flist ); fcnt += 1 )
	
		fname = StringFromList( fcnt, flist )
		
		cdf = ConfigDF( fname ) // config data folder
		df = NMPackageDF( fname ) // package data folder
		
		if ( DataFolderExists( cdf ) == 0 )
			continue
		endif
		
		if ( direction == -1 )
			CheckNMPackageDF( fname )
		endif
		
		objList = NMConfigVarList( fname, 2 ) // numbers
		
		for ( icnt = 0; icnt < ItemsInList( objList ); icnt += 1 )
		
			objName = StringFromList( icnt, objList )
			
			if ( ( direction == 1 ) && ( exists( df+objName ) == 2 ) )
				SetNMvar( cdf+objName, NumVarOrDefault( df+objName, Nan ) )
			elseif ( direction == -1 )
				SetNMvar( df+objName, NumVarOrDefault( cdf+objName, Nan ) )
			endif
			
		endfor
		
		objList = NMConfigVarList( fname, 3 ) // strings
		
		for ( icnt = 0; icnt < ItemsInList( objList ); icnt += 1 )
		
			objName = StringFromList( icnt, objList )
			
			if ( ( direction == 1 ) && ( exists( df+objName ) == 2 ) )
				SetNMstr( cdf+objName, StrVarOrDefault( df+objName, "" ) )
			elseif ( direction == -1 )
				SetNMstr( df+objName, StrVarOrDefault( cdf+objName, "" ) )
			endif
			
		endfor
		
		objList = NMConfigVarList( fname, 5 ) // numeric waves
		
		for ( icnt = 0; icnt < ItemsInList( objList ); icnt += 1 )
		
			objName = StringFromList( icnt, objList )
			
			if ( ( direction == 1 ) && ( WaveExists( $( df+objName ) ) == 1 ) )
				Duplicate /O $( df+objName ), $( cdf+objName )
			elseif ( direction == -1 )
				Duplicate /O $( cdf+objName ), $( df+objName )
			endif
			
		endfor
		
		objList = NMConfigVarList( fname, 6 ) // text waves
		
		for ( icnt = 0; icnt < ItemsInList( objList ); icnt += 1 )
		
			objName = StringFromList( icnt, objList )
			
			if ( ( direction == 1 ) && ( WaveExists( $( df+objName ) ) == 1 ) )
				Duplicate /O $( df+objName ), $( cdf+objName )
			elseif ( direction == -1 )
				Duplicate /O $( cdf+objName ), $( df+objName )
			endif
			
		endfor
	
	endfor
	
	if ( direction == -1 )
		UpdateNM( 0 )
	endif
	
	return 0

End // NMConfigCopy

Function /S FileOpenFix2NM( fileName ) // move opened NM folder to new subfolder
	String fileName
	
	Variable icnt
	String list, name
	
	if ( strlen( fileName ) == 0 )
		return "" // not allowed
	endif

	//String folder = "root:" + NMFolderNameCreate( fileName )
	String folder = "root:" + WinName( 0, 0 )
	
	folder = CheckFolderName( folder ) // get unused folder name

	if ( DataFolderExists( folder ) )
		return "" // not allowed
	endif
	
	list = FolderObjectList( "", 4 ) // df
	
	list = RemoveFromList( "WinGlobals;Packages;", list )
	
	NewDataFolder /O $RemoveEnding( folder, ":" )
	
	for ( icnt = 0; icnt < ItemsInList( list ); icnt += 1 )
		MoveDataFolder $StringFromList( icnt, list ), $folder
	endfor
	
	list = FolderObjectList( "", 1 ) // waves
	
	for ( icnt = 0; icnt < ItemsInList( list ); icnt += 1 )
		name = StringFromList( icnt, list )
		MoveWave $name, $( LastPathColon( folder, 1 ) + name )
	endfor
	
	list = FolderObjectList( "", 2 ) // variables
	
	for ( icnt = 0; icnt < ItemsInList( list ); icnt += 1 )
		name = StringFromList( icnt, list )
		MoveVariable $name, $( LastPathColon( folder, 1 ) + name )
	endfor
	
	list = FolderObjectList( "", 3 ) // strings
	
	for ( icnt = 0; icnt < ItemsInList( list ); icnt += 1 )
		name = StringFromList( icnt, list )
		MoveString $name, $( LastPathColon( folder, 1 ) + name )
	endfor
	
	NMFolderChange( folder )
	
	return folder
	
End // FileOpenFix2NM

Function /S CheckNMPath() // find path to NeuroMatic Procedure folder

	Variable icnt
	String flist, fname, igor, path = ""
	
	PathInfo NMPath
	
	if ( V_flag == 1 )
		return S_path
	endif

	PathInfo Igor
	
	if ( V_flag == 0 )
		return ""
	endif
	
	igor = S_path + "Igor Procedures:"
	
	NewPath /O/Q NMPath, igor
	
	flist = IndexedDir( NMPath, -1, 0 ) // look for NM folder
	
	for ( icnt = 0; icnt < ItemsInList( flist ); icnt += 1 )
	
		fname = StringFromList( icnt, flist )
		
		if ( StrSearch( fname, "NeuroMatic", 0, 2 ) >= 0 )
			path = igor + fname + ":" // found it
			break
		endif
		
	endfor
	
	if ( strlen( path ) == 0 ) // try to locate NM alias
	
		flist = IndexedFile( NMPath, -1, "????" )
		
		for ( icnt = 0; icnt < ItemsInList( flist ); icnt += 1 )
		
			fname = StringFromList( icnt, flist )
			
			if ( StrSearch( fname, "NeuroMatic", 0, 2 ) >= 0 )
			
				//if ( IgorVersion() < 5 )
				//	NMDoAlert( "NM path cannot be determined. Try putting NM folder ( rather than alias ) in Igor Procedures folder." )
				//	break
				//endif
				
				GetFileFolderInfo /P=NMPath /Q/Z fname
				
				if ( V_isAliasShortcut == 1 )
					path = S_aliasPath
					break
				endif
				
			endif
			
		endfor
	
	endif
	
	NewPath /O/Q NMPath, path
	
	PathInfo /S Igor
	
	return path

End // CheckNMPath

Function NMConfigOpen( file )
	String file
	
	Variable icnt, dialogue = 0, error = -1
	String flist, fname, folder, odf, cdf, df = ConfigDF( "" )
	
	Variable nmPrefix = 0 // leave folder name as is
	
	CheckNMPath()
	
	if ( strlen( file ) == 0 )
		dialogue = 1
	endif
	
	folder = NMFileBinOpen( dialogue, ".pxp", "root:", "NMPath", file, 0, nmPrefix = nmPrefix ) // NM_FileManager.ipf
	
	KillNMPath()

	if ( strlen( folder ) == 0 )
		return error // cancel
	endif
	
	if ( IsNMFolder( folder, "NMConfig" ) == 1 )
	
		flist = FolderObjectList( folder, 4 ) // subfolder list
		
		for ( icnt = 0; icnt < ItemsInList( flist ); icnt += 1 )
		
			fname = StringFromList( icnt, flist )
			
			odf = folder + ":" + fname
			cdf = df + fname
		
			if ( DataFolderExists( cdf ) == 1 )
				KillDataFolder $cdf // kill config folder
			endif
			
			DuplicateDataFolder $odf, $cdf
			
			NMConfigCopy( fname, -1 ) // set config values
		
		endfor
		
		
		error = 0
		
		CheckNMConfigsAll()
		CheckNMPaths()
		
	else
	
		NMDoAlert( "Open File Error: file is not a NeuroMatic configuration file." )
		
	endif
	
	if ( DataFolderExists( folder ) == 1 )
		KillDataFolder $folder
	endif
	
	//UpdateNMConfigMenu()
	
	return error

End // NMConfigOpen

Function CheckNMConfigsAll()

	Variable icnt
	String fname, flist = NMConfigList()
	
	for ( icnt = 0; icnt < ItemsInList( flist ); icnt += 1 )
		CheckNMConfig( StringFromList( icnt, flist ) )
	endfor

End // CheckNMConfigsAll

Function KillNMPath()
	
	PathInfo igor
	
	if ( V_flag == 0 )
		return -1
	endif
	
	NewPath /O/Q NMPath, S_path
	
	KillPath /Z NMPath

End // KillNMPath

Function /S Wave2List( wName )
	String wName // wave name
	
	Variable icnt, npnts, numObj
	String strObj, strList = ""
	
	if ( WaveExists( $wName ) == 0 )
		return NM2ErrorStr( 1, "wName", wName )
	endif
	
	if ( WaveType( $wName ) == 0 ) // text wave
	
		Wave /T wtext = $wName
		
		npnts = numpnts( wtext )
		
		for ( icnt = 0; icnt < npnts; icnt += 1 )
			
			strObj = wtext[icnt]
			
			if ( strlen( strObj ) > 0 )
				strList = AddListItem( strObj, strList, ";", inf )
			endif
			
		endfor
		
	else // numeric wave
	
		Wave wtemp = $wName
		
		npnts = numpnts( wtemp )
	
		for ( icnt = 0; icnt < npnts; icnt += 1 )
			strList = AddListItem( num2str( wtemp[icnt] ), strList, ";", inf )
		endfor
	
	endif
	
	return strList

End // Wave2List

Function CheckNMFolderType( folderName )
	String folderName
	
	folderName = CheckNMFolderPath( folderName )
	
	if ( DataFolderExists( folderName ) == 0 )
		return -1
	endif
	
	if ( exists( folderName+"FileType" ) == 0 )
		return -1
	endif

	String ftype = StrVarOrDefault( folderName+"FileType", "" )
	
	if ( StringMatch( ftype, "pclamp" ) == 1 )
	
		SetNMstr( folderName+"DataFileType", "pclamp" )
		SetNMstr( folderName+"FileType", "NMData" )
		
	elseif ( StringMatch( ftype, "axograph" ) == 1 )
	
		SetNMstr( folderName+"DataFileType", "axograph" )
		SetNMstr( folderName+"FileType", "NMData" )
		
	elseif ( strlen( ftype ) == 0 )
	
		SetNMstr( folderName+"FileType", "NMData" )
		
	endif
	
	return 0

End // CheckNMFolderType

Function NMVersionNum()

	String versionStr = NMVersionStr
	
	Variable ilength = strlen( versionStr )

	String numStr = versionStr[ 0, ilength-2 ]
	String suffix = num2str( char2num( versionStr[ ilength-1, ilength-1 ] ) ) // convert last character to ascii code

	return str2num( numStr + suffix ) 

End // NMVersionNum

Function CheckOldNMDataNotes( folderName ) // check data notes of old NM acquired data
	String folderName
	
	Variable ccnt, wcnt
	String wList, wNote, yl
	
	String wname = "ChanWaveList" // OLD WAVE
	String ywname = "yLabel"
	
	folderName = CheckNMFolderPath( folderName )
	
	if ( DataFolderExists( folderName ) == 0 )
		return 0
	endif
	
	String wavePrefix = StrVarOrDefault( folderName+"WavePrefix", "" )
	
	if ( strlen( wavePrefix ) == 0 )
		return 0 // nothing to do
	endif
	
	if ( ( WaveExists( $wname ) == 0 ) || ( WaveExists( $ywname ) == 0 ) )
		return 0
	endif
	
	String type = StrVarOrDefault( folderName+"DataFileType", "" )
	String file = StrVarOrDefault( folderName+"CurrentFile", "" )
	String fdate = StrVarOrDefault( folderName+"FileDate", "" )
	String ftime = StrVarOrDefault( folderName+"FileTime", "" )
	
	String xl = StrVarOrDefault( "xLabel", "" )
	
	String stim = SubStimName( folderName )
	
	Wave /T wtemp = $wname
	Wave /T ytemp = $ywname
	
	strswitch( type )
		case "IgorBin":
		case "NMBin":
			type = "NMData"
	endswitch
	
	for ( ccnt = 0; ccnt < numpnts( wtemp ); ccnt += 1 )
	
		wList = wtemp[ ccnt ]
		yl = ytemp[ ccnt ]
		
		for ( wcnt = 0; wcnt < ItemsInlist( wList ); wcnt += 1 )
		
			wname = StringFromList( wcnt, wList )
			
			if ( WaveExists( $folderName+wname ) == 0 )
				continue
			endif
			
			if ( strsearch( wname, wavePrefix, 0, 2 ) < 0 )
				continue
			endif
			
			if ( strlen( NMNoteStrByKey( folderName+wname, "Type" ) ) == 0 )
				wNote = "Stim:" + stim
				wNote += NMCR + "Folder:" + GetPathName( folderName, 0 )
				wNote += NMCR + "Date:" + NMNoteCheck( fdate )
				wNote += NMCR + "Time:" + NMNoteCheck( ftime )
				wNote += NMCR + "Chan:" + ChanNum2Char( ccnt )
				NMNoteType( folderName+wname, type, xl, yl, wNote )
			endif
			
			if ( strlen( NMNoteStrByKey( folderName+wname, "File" ) ) == 0 )
				Note $folderName+wname, "File:" + NMNoteCheck( file )
			endif
			
		endfor
	
	endfor
	
End // CheckOldNMDataNotes

Function NMPrefixFolderUtility( parent, select )
	String parent
	String select // "rename" or "check" or "unlock"
	
	Variable icnt
	String flist, prefixFolder
	
	parent = CheckNMFolderPath( parent )
	
	if ( ( strlen( parent ) == 0 ) || !DataFolderExists( parent ) )
		return -1
	endif
	
	flist = FolderObjectList( parent , 4 )
	
	for ( icnt = 0 ; icnt < ItemsInList( flist ) ; icnt += 1 )
	
		prefixFolder = StringFromList( icnt, flist )
	
		strswitch( select )
		
			case "rename":
				NMPrefixFolderRename( prefixFolder )
				break
				
			case "check":
				CheckNMPrefixFolder( LastPathColon( parent+prefixFolder, 1 ), Nan, Nan )
				break
				
			case "unlock":
				NMPrefixFolderLock( LastPathColon( parent+prefixFolder, 1 ), 0 )
				break
		
		endswitch
		
	endfor
	
	return 0

End // NMPrefixFolderUtility

Function CheckNMDataFolderFormat6( folderName )
	String folderName

	Variable icnt
	String vname, waveSelect
	
	if ( strlen( folderName ) == 0 )
		return -1
	endif
	
	String setList = NMSetsWavesList( folderName, 0 )
	
	String wlist = "ChanSelect;ChanWaveList;WavSelect;Group;"
	String vList = "NumChannels;CurrentChan;NumWaves;CurrentWave;"
	String kvList = "SumSet1;SumSet2;SumSetX;NumActiveWaves;CurrentChan;CurrentWave;CurrentGrp;FirstGrp;"
	
	String currentPrefix = StrVarOrDefault( folderName+"CurrentPrefix", "" )
	String prefixFolder = NMPrefixFolderDF( folderName, currentPrefix )
	
	Variable numChannels = NumVarOrDefault( folderName+"NumChannels", 0 )
	Variable numWaves = NumVarOrDefault( folderName+"NumWaves", 0 )
	
	if ( strlen( currentPrefix ) == 0 )
		return 0 // nothing to update
	endif
	
	String twList = NMFolderWaveList( folderName, "wNames_*", ";", "TEXT:1", 0 )
	
	vname = folderName+"WavSelect"
	
	if ( ( WaveExists( $folderName+"WaveSelect" ) == 1 ) && ( WaveExists( $vname ) == 0 ) )
		Rename $folderName+"WaveSelect" $vname // rename old wave
	endif

	if ( ( WaveExists( $folderName+"ChanSelect" ) == 0 ) && ( WaveExists( $vname ) == 0 ) )
		return 0 // nothing to do, must be new NM data folder format
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return 0
	endif
	
	if ( DataFolderExists( prefixFolder ) == 0 )
		NewDataFolder $RemoveEnding( prefixFolder, ":" )
	endif
	
	for ( icnt = 0 ; icnt < ItemsInList( vList ) ; icnt += 1 ) // copy old variables to new subfolder
	
		vname = StringFromList( icnt, vList )
		
		if ( exists( folderName+vname ) != 2 )
			continue
		endif
		
		Variable /G $prefixFolder+vname = NumVarOrDefault( folderName+vname, Nan )
		
	endfor
	
	for ( icnt = 0 ; icnt < ItemsInList( kvList ) ; icnt += 1 ) // kill unecessary old variables
	
		vname = StringFromList( icnt, kvList )
		
		if ( exists( folderName+vname ) == 2 )
			KillVariables /Z $folderName+vname
		endif

	endfor
	
	wList = NMAddToList( setList, wList, ";" )
	wList = NMAddToList( twList, wList, ";" )
	
	for ( icnt = 0 ; icnt < ItemsInList( wList ) ; icnt += 1 ) // copy old waves to new subfolder
	
		vname = StringFromList( icnt, wList )
		
		if ( WaveExists( $folderName+vname ) == 0 )
			continue
		endif
		
		Duplicate /O $folderName+vname $prefixFolder+vname
		
		if ( WaveExists( $prefixFolder+vname ) == 1 )
			KillWaves /Z $folderName+vname
		endif
		
	endfor
	
	for ( icnt = 0 ; icnt < numChannels ; icnt += 1 ) // copy channel graph folders to new subfolder
		
		vname = ChanGraphName( icnt ) // channel graph folder name
		
		if ( ( DataFolderExists( folderName+vname ) == 1 ) && ( DataFolderExists( prefixFolder+vname ) == 0 ) )
		
			DuplicateDataFolder $folderName+vname $prefixFolder+vname
			
			if ( DataFolderExists( prefixFolder+vname ) == 1 )
				KillDataFolder /Z $folderName+vname
			endif
			
		endif
		
	endfor
	
	folderName = ParseFilePath(0, folderName, ":", 1, 0)
	
	NMHistory( "Converted NM data folder " + NMQuotes( folderName ) + " to version " + NMVersionStr )

End // CheckNMDataFolderFormat6

Function ChanGraphSetCoordinates( channel ) // set default channel graph position
	Variable channel // ( -1 ) for current channel
	
	Variable yinc, width, height, ccnt, where
	Variable xoffset, yoffset // default offsets
	
	if ( channel == -1 )
		channel = CurrentNMChannel()
	endif
	
	String cdf = ChanDF( channel )
	
	if ( strlen( cdf ) == 0 )
		return -1
	endif
	
	Variable x0 = NumVarOrDefault( cdf + "GX0", Nan )
	Variable y0 = NumVarOrDefault( cdf + "GY0", Nan )
	Variable x1 = NumVarOrDefault( cdf + "GX1", Nan )
	Variable y1 = NumVarOrDefault( cdf + "GY1", Nan )
	
	Variable xPixels = NMComputerPixelsX()
	Variable yPixels = NMComputerPixelsY()
	String Computer = NMComputerType()
	
	Variable numChannels = NMNumChannels()
	
	for ( ccnt = 0; ccnt < numChannels; ccnt+=1 )
	
		cdf = ChanDF( ccnt )
		
		if ( ( strlen( cdf ) > 0 ) && !NumVarOrDefault( cdf + "On", 1 ) )
			numChannels -= 1
		endif
		
	endfor
	
	for ( ccnt = 0; ccnt < channel; ccnt+=1 )
		
		cdf = ChanDF( ccnt )
		
		if ( strlen( cdf ) == 0 )
			continue
		endif
		
		if ( NumVarOrDefault( cdf + "On", 1 ) )
			where += 1
		endif
		
	endfor
	
	cdf = ChanDF( channel )
	
	if ( numtype( x0 * y0 * x1 * y1 ) > 0 ) // compute graph coordinates
	
		width = xPixels / 2
		height = yPixels / ( numChannels + 2 )
	
		strswitch( Computer )
			case "pc":
				x0 = 5
				y0 = 42
				yinc = height + 26
				break
			default:
				x0 = 10
				y0 = 44
				yinc = height + 25
				break
		endswitch
		
		x0 += xoffset
		y0 += yoffset + yinc*where
		x1 = x0 + width
		y1 = y0 + height
		
		SetNMvar( cdf + "GX0", x0 )
		SetNMvar( cdf + "GY0", y0 )
		SetNMvar( cdf + "GX1", x1 )
		SetNMvar( cdf + "GY1", y1 )
	
	endif

End // ChanGraphSetCoordinates

Function CheckNMWaveOfType( wList, nPoints, defaultValue, wType ) // returns ( 0 ) did not make wave ( 1 ) did make wave
	String wList // wave list
	Variable nPoints // ( -1 ) dont care
	Variable defaultValue
	String wType // ( B ) 8-bit signed integer ( C ) complex ( D ) double precision ( I ) 32-bit signed integer ( R ) single precision real ( W ) 16-bit signed integer ( T ) text
	// ( UB, UI or UW ) unsigned integers
	
	String wName, path
	Variable wcnt, nPoints2, makeFlag, error = 0
	
	if ( numtype( nPoints ) > 0 )
		return -1
	endif
	
	if ( nPoints < 0 )
		nPoints = 128
	endif
	
	for ( wcnt = 0; wcnt < ItemsInList( wList ); wcnt += 1 )
	
		wName = StringFromList( wcnt, wList )
		
		nPoints2 = numpnts( $wName )
		
		path = GetPathName( wName, 1 )
		
		if ( ( strlen( path ) > 0 ) && ( DataFolderExists( path ) == 0 ) )
			error = -1
			continue
		endif
		
		makeFlag = 0
		
		if ( WaveExists( $wName ) == 0 )
		
			strswitch( wType )
				case "B":
					if ( ( WaveType( $wName ) & 0x08 ) != 1 )
						makeFlag = 1
					endif
					break
				case "UB":
					if ( ( ( WaveType( $wName ) & 0x08 ) != 1 ) && ( ( WaveType( $wName ) & 0x40 ) != 1 ) )
						makeFlag = 1
					endif
					break
				case "C":
					if ( ( WaveType( $wName ) & 0x01 ) != 1 )
						makeFlag = 1
					endif
					break
				case "D":
					if ( ( WaveType( $wName ) & 0x04 ) != 1 )
						makeFlag = 1
					endif
					break
				case "I":
					if ( ( WaveType( $wName ) & 0x20 ) != 1 )
						makeFlag = 1
					endif
					break
				case "UI":
					if ( ( ( WaveType( $wName ) & 0x20 ) != 1 ) && ( ( WaveType( $wName ) & 0x40 ) != 1 ) )
						makeFlag = 1
					endif
					break
				case "T":
					if ( WaveType( $wName ) != 0 )
						makeFlag = 1
					endif
					break
				case "W":
					if ( ( WaveType( $wName ) & 0x10 ) != 1 )
						makeFlag = 1
					endif
					break
				case "UW":
					if ( ( ( WaveType( $wName ) & 0x10 ) != 1 ) && ( ( WaveType( $wName ) & 0x40 ) != 1 ) )
						makeFlag = 1
					endif
					break
				case "R":
				default:
					if ( ( WaveType( $wName ) & 0x02 ) != 1 )
						makeFlag = 1
					endif
			endswitch
		
		endif
			
		if ( ( WaveExists( $wName ) == 0 ) || makeFlag )
		
			strswitch( wType )
				case "B":
					Make /B/O/N=( nPoints ) $wName = defaultValue
					break
				case "UB":
					Make /B/U/O/N=( nPoints ) $wName = defaultValue
					break
				case "C":
					Make /C/O/N=( nPoints ) $wName = defaultValue
					break
				case "D":
					Make /D/O/N=( nPoints ) $wName = defaultValue
					break
				case "I":
					Make /I/O/N=( nPoints ) $wName = defaultValue
					break
				case "T":
					Make /T/O/N=( nPoints ) $wName = ""
					break
				case "UI":
					Make /I/U/O/N=( nPoints ) $wName = defaultValue
					break
				case "W":
					Make /W/O/N=( nPoints ) $wName = defaultValue
					break
				case "UW":
					Make /W/U/O/N=( nPoints ) $wName = defaultValue
					break
				case "R":
				default:
					Make /O/N=( nPoints ) $wName = defaultValue
			endswitch
			
		elseif ( ( WaveExists( $wName ) == 1 ) && ( nPoints > 0 ) )
		
			strswitch( wType )
			
				case "T":
				
					nPoints2 = numpnts( $wName )
		
					if ( nPoints > nPoints2 )
					
						Redimension /N=( nPoints ) $wName
						
						Wave /T wtemp = $wName
						
						wtemp[ nPoints2,inf ] = ""
						
					elseif ( nPoints < nPoints2 )
					
						Redimension /N=( nPoints ) $wName
						
					endif
				
					break
			
				default:
		
					nPoints2 = numpnts( $wName )
				
					if ( nPoints > nPoints2 )
					
						Redimension /N=( nPoints ) $wName
						
						Wave wtemp2 = $wName
						
						wtemp2[ nPoints2,inf ] = defaultValue
						
					elseif ( nPoints < nPoints2 )
					
						Redimension /N=( nPoints ) $wName
						
					endif
				
			endswitch
			
		endif
	
	endfor
	
	return error
	
End // CheckNMWaveOfType

Function /S CurrentNMFolderPrefix()
	
	return NMFolderListName( "" ) + "_"

End // CurrentNMFolderPrefix

Function /S NMCheckFullPath( path )
	String path
	
	if ( StringMatch( path[0,4], "root:" ) == 0 )
		path = GetDataFolder( 1 ) + path
	endif
	
	return ParseFilePath( 2, path, ":", 0, 0 )
	
End // NMCheckFullPath

Function NMPrefixFolderWaveKill( wavePrefix, [ prefixFolder ] )
	String wavePrefix // prefix name
	String prefixFolder

	Variable icnt, killedsomething
	String wName, wList
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	wList = NMFolderWaveList( prefixFolder, wavePrefix + "*", ";", "", 1 )
	
	for ( icnt = 0 ; icnt < ItemsInList( wList ) ; icnt += 1 )
	
		wName = StringFromList( icnt, wList )
		KillWaves /Z $wName
	
		if ( !WaveExists( $wName ) )
			killedsomething = 1
		endif
		
	endfor
	
	return killedsomething

End // NMPrefixFolderWaveKill

Function /S NMSetsDisplayList( [ prefixFolder ] )
	String prefixFolder

	String setList = ""

	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) > 0 )
		setList = StrVarOrDefault( prefixFolder+"SetsDisplayList", "" )
	endif
	
	if ( ItemsInList( setList ) > 0 )
		return setList
	else
		return NMSetsListDefault
	endif

End // NMSetsDisplayList

Function /S NMConfigsListBoxWaveName()

	return NMDF + "ConfigVariables"

End // NMConfigsListBoxWaveName

Function NMTabsExtraNum()

	return NumTabs( NMStrGet( "TabControlList" ) )
	
End // NMTabsExtraNum

Function KillTabControls( tabNum, tabList ) // kill tab controls
	Variable tabNum // tab number
	String tabList // list of tab names
	
	String prefix = TabPrefix( tabNum, tabList ) + "*"
	String tname = TabName( tabNum, tabList )
	
	if ( TabExists( tabList ) == 0 )
		//DoAlert 0, "KillTabControls Abort: tab control does not exist: " + TabCntrlName( tabList )
		return -1
	endif

	KillControls( TabWinName( tabList ), prefix ) // kill controls
	
End // KillTabControls

Function ClearTabs( tabList ) // clear tab control
	String tabList	 // list of: tab name, tab prefix
					// followed by: window name, control name
					// for example: "Main,MN_;Stats,ST_;MyTab,MY_;MyPanel,myTabCntrl"
					
	Variable iend = NumTabs( tabList ) + 10
	
	if ( TabExists( tabList ) == 0 ) // "empty" tab control should have already been created
		//DoAlert 0, "ClearTabs Abort: tab control does not exist: " + TabCntrlName( tabList )
		return -1
	endif

	Variable icnt
	String tName = TabCntrlName( tabList )
	
	for ( icnt = iend; icnt >= 0; icnt -= 1 )
		TabControl $tName, win=$TabWinName( tabList ), tabLabel( icnt )=""
	endfor
	
End // ClearTabs

Function MakeTabs( tabList ) // set up tab controls
	String tabList	 // list of: tab name, tab prefix
					// followed by: window name, control name
					// for example: "Main,MN_;Stats,ST_;MyTab,MY_;MyPanel,myTabCntrl"
	
	if ( TabExists( tabList ) == 0 ) // "empty" tab control should have already been created
		//DoAlert 0, "MakeTabs Abort: tab control does not exist: " + TabCntrlName( tabList )
		return -1
	endif

	Variable icnt
	
	Variable nTabs = NumTabs( tabList )
	String tName = TabCntrlName( tabList )
	String windowName = TabWinName( tabList )
	
	for ( icnt = 0; icnt < nTabs; icnt += 1 ) // add tabs
		TabControl $tName, win=$windowName, tabLabel( icnt )=tabName( icnt, tabList )
	endfor
	
End // MakeTabs

Function CheckNMTabs( forceVariableCheck )
	Variable forceVariableCheck
	
	Variable icnt
	
	String tabList = NMTabControlList()
	
	for ( icnt = 0; icnt < NumTabs( tabList ); icnt += 1 ) // go through each tab and check variables
		SetNMvar( NMDF+"UpdateNMBlock", 1 ) // block UpdateNM()
		CheckNMPackage( TabName( icnt, tabList ), forceVariableCheck )
		SetNMvar( NMDF+"UpdateNMBlock", 0 ) // unblock UpdateNM()
	endfor

End // CheckNMTabs

Function ReadPclampFile( file, varType, pointer, numVarToRead )
	String file // external ABF data file
	String varType // variable type
	Variable pointer // read file pointer in bytes
	Variable numVarToRead // number of variables to read starting from pointer
	
	Variable bytes = 0
	
	if ( !FileExistsAndNonZero( file ) )
		return Nan
	endif
	
	if ( ( numtype( pointer ) > 0 ) || ( pointer < 0 ) )
		NM2Error( 10, "pointer", num2str( pointer ) )
		return Nan
	endif
	
	if ( ( numtype( numVarToRead ) > 0 ) || ( numVarToRead < 0 ) )
		NM2Error( 10, "numVarToRead", num2str( numVarToRead ) )
		return Nan
	endif
	
	strswitch( varType )
	
		case "char":
			bytes = 1
			GBLoadWave /B/N=NM_ReadPClampWave/O/S=(pointer)/T={8,8+64}/U=(numVarToRead)/W=1/Q file
			break
			
		case "unicode":
		case "short":
			bytes = 2
			GBLoadWave /B/N=NM_ReadPClampWave/O/S=(pointer)/T={16,2}/U=(numVarToRead)/W=1/Q file
			break
			
		case "uint": // unsigned integer
			bytes = 4
			GBLoadWave /B/N=NM_ReadPClampWave/O/S=(pointer)/T={32+64,32+64}/U=(numVarToRead)/W=1/Q file
			break
			
		case "long":
			bytes = 4
			GBLoadWave /B/N=NM_ReadPClampWave/O/S=(pointer)/T={32,2}/U=(numVarToRead)/W=1/Q file
			break
			
		case "float":
			bytes = 4
			GBLoadWave /B/N=NM_ReadPClampWave/O/S=(pointer)/T={2,2}/U=(numVarToRead)/W=1/Q file
			break
			
		case "double":
			bytes = 8
			GBLoadWave /B/N=NM_ReadPClampWave/O/S=(pointer)/T={4,4}/U=(numVarToRead)/W=1/Q file
			break
			
		default:
			NM2Error( 20, "varType", varType )
			return Nan
			
	endswitch
	
	return ( pointer + bytes * numVarToRead )
	
End // ReadPclampFile

Function ReadAxoFile(file, type, nread)
	String file
	String type
	Variable nread
	
	if ( FileExistsAndNonZero( file ) == 0 )
		return Nan
	endif
	
	if ( exists( "AXO_POINTER" ) != 2 )
		return NaN
	endif
	
	NVAR AXO_POINTER
	
	if (numtype(AXO_POINTER * nread) > 0)
		return Nan
	endif
	
	strswitch(type)
	
		case "char":
			GBLoadWave /O/N=DumWave/T={8,2}/S=(AXO_POINTER)/U=(nread)/W=1/Q file
			AXO_POINTER += 1 * nread
			break
			
		case "unicode":
		case "short":
			GBLoadWave /O/N=DumWave/T={16,2}/S=(AXO_POINTER)/U=(nread)/W=1/Q file
			AXO_POINTER += 2 * nread
			break
			
		case "long":
			GBLoadWave /O/N=DumWave/T={32,2}/S=(AXO_POINTER)/U=(nread)/W=1/Q file
			AXO_POINTER += 4 * nread
			break
			
		case "float":
			GBLoadWave /O/N=DumWave/T={2,2}/S=(AXO_POINTER)/U=(nread)/W=1/Q file
			AXO_POINTER += 4 * nread
			break
			
		case "double":
			GBLoadWave /O/N=DumWave/T={4,4}/S=(AXO_POINTER)/U=(nread)/W=1/Q file
			AXO_POINTER += 8 * nread
			break
			
	endswitch
	
	return Nan
	
End // ReadAxoFile

Function /S CurrentNMWavePrefix()

	String currentFolder = CurrentNMFolder( 1 )

	return StrVarOrDefault( currentFolder + "CurrentPrefix", "" )

End // CurrentNMWavePrefix

Function /S NMPrefixList()

	Variable icnt
	String wavePrefix, wList, findAny, prefixList2 = ""

	String prefixList = NMStrGet( "PrefixList" )
	String subfolderList = NMPrefixSubfolderList( 0 )
	
	for ( icnt = 0 ; icnt < ItemsInList( NMWavePrefixList ) ; icnt += 1 )
	
		wavePrefix = StringFromList( icnt, NMWavePrefixList )
		wList = WaveList( wavePrefix + "*", ";", "Text:0" )
		
		if ( ItemsInList( wList ) > 0 )
			prefixList2 = NMAddToList( wavePrefix, prefixList2, ";" )
		endif
		
	endfor
	
	for ( icnt = 0 ; icnt < ItemsInList( prefixList ) ; icnt += 1 )
	
		wavePrefix = StringFromList( icnt, prefixList )
		wList = WaveList( wavePrefix + "*", ";", "Text:0" )
		
		if ( ItemsInList( wList ) > 0 )
			prefixList2 = NMAddToList( wavePrefix, prefixList2, ";" )
		endif
		
	endfor
	
	wList = WaveList( "DF0_*", ";", "Text:0" ) // imported data
	
	if ( ItemsInList( wList ) > 0 )
		prefixList2 = NMAddToList( "DF", prefixList2, ";" )
	endif
	
	prefixList2 = NMAddToList( subfolderList, prefixList2, ";" )
	
	if ( ItemsInList( prefixList2 ) == 0 )
	
		findAny = NMPrefixFindFirst()
		
		if ( strlen( findAny ) > 0 )
			prefixList2 = NMAddToList( findAny, prefixList2, ";" )
		endif
		
	endif
	
	if ( ItemsInList( prefixList2 ) == 0 )
		return ""
	endif
	
	return SortList( prefixList2, ";", 16 )

End // NMPrefixList

Function /S NMPrefixMenu()
	
	return "Wave Prefix;---;" + NMPrefixList() + ";---;Other;Edit Default List;Kill Prefix Globals;User Prompts On/Off;---;Order Waves;Order Waves Preference;"

End // NMPrefixMenu

Function /S ChanDisplayWave( channel )
	Variable channel // ( -1 ) for current channel
	
	return ChanDisplayWaveName( 1, channel, 0 )
	
End // ChanDisplayWave

Function ChanGraphMake( channel ) // create channel display graph
	Variable channel // ( -1 ) for current channel

	Variable scale, grid, y0 = 8
	Variable gx0, gy0, gx1, gy1
	String cdf, tcolor
	
	Variable r = NMPanelRGB( "r" )
	Variable g = NMPanelRGB( "g" )
	Variable b = NMPanelRGB( "b" )
	
	if ( channel == -1 )
		channel = CurrentNMChannel()
	endif
	
	String cc = num2istr( channel )
	
	String computer = NMComputerType()
	
	String gName = ChanGraphName( channel )
	String wname = ChanDisplayWave( channel )
	String xWave = NMXwave()
	
	CheckChanSubfolder( channel )
	cdf = ChanDF( channel )
	
	if ( strlen( cdf ) == 0 )
		return -1
	endif
	
	tcolor = StrVarOrDefault( cdf + "TraceColor", "0,0,0" )
	
	ChanGraphSetCoordinates( channel )
	
	gx0 = NumVarOrDefault( cdf + "GX0", Nan )
	gy0 = NumVarOrDefault( cdf + "GY0", Nan )
	gx1 = NumVarOrDefault( cdf + "GX1", Nan )
	gy1 = NumVarOrDefault( cdf + "GY1", Nan )
	
	if ( numtype( gx0 * gy1 * gx1 * gy1 ) > 0 )
		return 0
	endif
	
	Make /O $wname = Nan
	
	// kill waves that conflict with graph name
	
	if ( WinType( gName ) != 0 )
		DoWindow /K $gName
	endif
	
	if ( WaveExists( $Xwave ) )
		Display /N=$gName/W=( gx0,gy0,gx1,gy1 )/K=1 $wname vs $xWave
	else
		Display /N=$gName/W=( gx0,gy0,gx1,gy1 )/K=1 $wname
	endif
	
	ModifyGraph /W=$gName marker=Marker
	ModifyGraph /W=$gName standoff( left )=0, standoff( bottom )=0
	ModifyGraph /W=$gName margin( left )=50, margin( right )=22, margin( top )=22, margin( bottom )=40
	Execute /Z "ModifyGraph /W=" + gName + " rgb=(" + tcolor + ")"
	ModifyGraph /W=$gName wbRGB = ( r, g, b ), cbRGB = ( r, g, b ) // set margins gray
	
	if ( StringMatch( computer, "mac" ) )
		y0 = 4
	endif
	
	//PopupMenu $( "PlotMenu"+cc ), pos={0,0}, size={15,0}, bodyWidth= 20, mode=1, value=" ;" + NMChanPopupList, proc=NMChanPopup, win=$gName
	SetVariable $( "SmoothSet"+cc ), title="Filter", pos={70,y0-1}, size={90,50}, limits={0,inf,1}, value=$( cdf + "SmoothN" ), proc=NMChanSetVariable, win=$gName
	//CheckBox $( "TransformCheck"+cc ), title="Transform", pos={200,y0}, size={16,18}, value=0, proc=NMChan//CheckBox, win=$gName
	//CheckBox $( "ScaleCheck"+cc ), title="Autoscale", pos={350,y0}, size={16,18}, value=1, proc=NMChan//CheckBox, win=$gName
	
End // ChanGraphMake

Function ChanOverlayUpdate( channel )
	Variable channel // ( -1 ) for current channel
	
	if ( channel == -1 )
		channel = CurrentNMChannel()
	endif
	
	String xWave = NMXWave()
	
	String cdf = ChanDF( channel )
	String gName = ChanGraphName( channel )
	
	if ( ( strlen( cdf ) == 0 ) || ( WinType( gName ) != 1 ) )
		return -1
	endif
	
	Variable overlay = NumVarOrDefault( cdf + "Overlay", 0 )
	Variable ocnt = NumVarOrDefault( cdf + "OverlayCount", 0 )
	
	String tcolor = StrVarOrDefault( cdf + "TraceColor", "0,0,0" )
	String ocolor = StrVarOrDefault( cdf + "OverlayColor", OverlayColor )
	
	if ( !overlay )
		return -1
	endif
	
	if ( ocnt == 0 )
		SetNMvar( cdf + "OverlayCount", 1 )
		return 0
	endif
	
	String dName = ChanDisplayWave( channel )
	
	String oName = ChanDisplayWaveName( 0, channel, ocnt )
	String odName = ChanDisplayWaveName( 1, channel, ocnt )
	
	String wList = TraceNameList( gName,";",1 )
	
	if ( StringMatch( dName, odName ) )
		return -1
	endif
	
	Duplicate /O $dName $odName
	
	RemoveWaveUnits( odName )
	
	if ( WhichListItem( oName, wList, ";", 0, 0 ) < 0 )
	
		if ( WaveExists( $xWave ) )
			AppendToGraph /W=$gName $odName vs $xWave
		else
			AppendToGraph /W=$gName $odName
		endif
	
		Execute /Z "ModifyGraph /W=" + gName + " rgb(" + oName + ")=(" + ocolor + ")"
		
		ModifyGraph /W=$gName marker( $oName )=Marker
		ModifyGraph /W=$gName mode( $oName )=NMChanMarkersMode( channel )
		
		oName = ChanDisplayWaveName( 0, channel, 0 )
		odName = ChanDisplayWaveName( 1, channel, 0 )
		
		RemoveFromGraph /W=$gName/Z $oName
		
		if ( WaveExists( $xWave ) )
			AppendToGraph /W=$gName $odName vs $xWave
		else
			AppendToGraph /W=$gName $odName
		endif
		
		Execute /Z "ModifyGraph /W=" + gName + " rgb(" + oName + ")=(" + tcolor + ")"
		
		ModifyGraph /W=$gName marker( $oName )=Marker
		ModifyGraph /W=$gName mode( $oName )=NMChanMarkersMode( channel )
		
	endif

	ocnt += 1
	
	if ( ocnt > overlay )
		ocnt = 1
	endif
	
	SetNMvar( cdf + "OverlayCount", ocnt )
	
	return 0

End // ChanOverlayUpdate

Function ChanWaveMake( channel, srcName, dstName [ prefixFolder ] )
	Variable channel // ( -1 ) for current channel
	String srcName // source wave name
	String dstName // destination wave name
	String prefixFolder
	
	Variable wcnt, filterNum, xbgn1, xend1, xbgn2, xend2, negone = -1
	Variable sfreq, fratio, numWaves
	
	String filterAlg, fxn1, fxn2, wName, wName2, transform, cdf, mdf = NMMainDF
	
	String avgList = "" // running avg wave list
	String avgList2 = "" // for filtering
	
	Variable bbgn = NumVarOrDefault( mdf+"Bsln_Bgn", 0 )
	Variable bend = NumVarOrDefault( mdf+"Bsln_End", 2 )
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	if ( channel == -1 )
		channel = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
	endif
	
	if ( StringMatch( srcName, dstName ) )
		return -1 // not to over-write source wave
	endif
	
	if ( WaveExists( $dstName ) )
		Wave wtemp = $dstName
		wtemp = Nan
	endif
		
	if ( !WaveExists( $srcName ) )
		return -1 // source wave does not exist
	endif

	if ( WaveType( $srcName ) == 0 )
		return -1 // text wave
	endif
	
	sfreq = 1 / deltax( $srcName ) // kHz
	
	cdf = NMChanTransformDF( channel, prefixFolder = prefixFolder )
	
	if ( strlen( cdf ) == 0 )
		return -1
	endif
	
	transform = NMChanTransformGet( channel, prefixFolder = prefixFolder  )
	
	filterNum = ChanFilterNumGet( channel, prefixFolder = prefixFolder  )
	filterAlg = ChanFilterAlgGet( channel, prefixFolder = prefixFolder  )
	
	Duplicate /O $srcName, $dstName
	
	RemoveWaveUnits( dstName )
	
	if ( StringMatch( transform, "Running Average" ) )
		
		if ( !StringMatch( srcName, NMChanWaveName( channel, -1 ) ) )
			return -1
		endif
		
		avgList = z_RunningAvgWaveList( channel, -1, -1, -1, prefixFolder = prefixFolder  )
		
		if ( ItemsInList( avgList ) < 2 )
			avgList = ""
		endif
		
		if ( filterNum > 0 )
		
			for ( wcnt = 0 ; wcnt < ItemsInList( avgList ) ; wcnt += 1 )
			
				wName = StringFromList( wcnt, avgList )
				
				if ( !WaveExists( $wName ) )
					continue
				endif
				
				wName2 = "CWM_" + wName
				
				Duplicate /O $wName $wName2
				
				avgList2 = AddListItem( wName2, avgList2, ";", inf )
				
			endfor
		
		endif
		
	endif
	
	if ( filterNum > 0 )
	
		strswitch( filterAlg )
		
			case "binomial":
			case "boxcar":
				
				if ( ItemsInList( avgList2 ) >= 2 )
					SmoothWaves( filterAlg, filterNum, avgList2 )
				else
					SmoothWaves( filterAlg, filterNum, dstName )
				endif
				
				break
				
			case "low-pass":
			case "high-pass":
			
				fratio = filterNum / sfreq // kHz
			
				if ( ( numtype( fratio ) > 0 ) || ( fratio > 0.5 ) )
					NMHistory( "Channel " + ChanNum2Char( channel ) + " warning: filter frequency cannot exceed " + num2str( sfreq * 0.5 ) + " kHz" )
				elseif ( ItemsInList( avgList2 ) >= 2 )
					FilterIIRwaves( filterAlg, fratio, 10, avgList2 )
				else
					FilterIIRwaves( filterAlg, fratio, 10, dstName )
				endif
			
				break
				
		endswitch
	
	endif
	
	strswitch( transform )
	
		default:
			break
			
		case "Differentiate":
			Differentiate $dstName
			break
			
		case "Double Differentiate":
			Differentiate $dstName
			Differentiate $dstName
			break
			
		case "Integrate":
			Integrate $dstName
			break
			
		case "Normalize":
		
			fxn1 = StrVarOrDefault( cdf + "Norm_Fxn1", "" )
			xbgn1 = NumVarOrDefault( cdf + "Norm_Xbgn1", NaN )
			xend1 = NumVarOrDefault( cdf + "Norm_Xend1", NaN )
			fxn2 = StrVarOrDefault( cdf + "Norm_Fxn2", "" )
			xbgn2 = NumVarOrDefault( cdf + "Norm_Xbgn2", NaN )
			xend2 = NumVarOrDefault( cdf + "Norm_Xend2", NaN )
			
			NormalizeWaves( fxn1, xbgn1, xend1, fxn2, xbgn2, xend2, dstName )
			
			break
			
		case "dF/Fo":
		
			bbgn = NumVarOrDefault( cdf + "DFOF_Bbgn", NaN )
			bend = NumVarOrDefault( cdf + "DFOF_Bend", NaN )
			
			DFOFWaves( bbgn, bend, dstName )
			
			break
			
		case "Baseline":
		
			bbgn = NumVarOrDefault( cdf + "Bsln_Bbgn", NaN )
			bend = NumVarOrDefault( cdf + "Bsln_Bend", NaN )
			
			BaselineWaves( 1, bbgn, bend, dstName )
			
			break
			
		case "Invert":
		
			Wave wtemp = $dstName
			
			MatrixOp /O wtemp = wtemp * negone
			
			break
			
		case "Running Average":
			
			Variable useChannelTransforms = -1 // DO NOT USE
			Variable ignoreNANs = 1 // ignore NANs in computation ( 0 ) no ( 1 ) yes
			Variable truncateToCommonXScale = 0 // ( 0 ) no, if necessary, waves are expanded to fit all min and max x-values ( 1 ) yes, waves are truncated to a common x-axis
			Variable interpToSameXScale = 1 // interpolate waves to the same x-scale (0) no (1) yes ( generally one should use interp ONLY if waves have different sample intervals )
			Variable saveMatrix = 0 // save list of waves as a 2D matrix called U_2Dmatrix ( 0 ) no ( 1 ) yes
			
			if ( ItemsInList( avgList2 ) > 0 )
				NMWavesStatistics( avgList2, useChannelTransforms, ignoreNANs, truncateToCommonXScale, interpToSameXScale, saveMatrix )
			elseif ( ItemsInList( avgList ) > 0 )
				NMWavesStatistics( avgList, useChannelTransforms, ignoreNANs, truncateToCommonXScale, interpToSameXScale, saveMatrix )
			else
				break
			endif
			
			if ( WaveExists( U_Avg ) )
				Duplicate /O U_Avg $dstName
			endif
			
			Killwaves /Z U_Avg, U_Sdv, U_Sum, U_SumSqr, U_Pnts, U_2Dmatrix // kill output waves from WavesStatistics
			
			for ( wcnt = 0 ; wcnt < ItemsInList( avgList2 ) ; wcnt += 1 )
				wName = StringFromList( wcnt, avgList2 )
				KillWaves /Z $wName
			endfor
			
			break
			
		case "Histogram":
		
			Variable scale
			Variable dualDisplayPercent = 0.25
			Variable extraBins = 5
			Variable xbgn = NumVarOrDefault( cdf + "Histo_Xbgn", NaN )
			Variable xend = NumVarOrDefault( cdf + "Histo_Xend", NaN )
			Variable binWidth = NumVarOrDefault( cdf + "Histo_BinWidth", NaN )
			Variable dualDisplay = NumVarOrDefault( cdf + "Histo_DualDisplay", NaN )
			
			Variable binStart, numBins
			
			String histoName, histoNameX
			
			if ( numtype( xbgn ) > 0 )
				xbgn = -inf
			endif
			
			if ( numtype( xend ) > 0 )
				xend = inf
			endif
			
			Duplicate /O/R=( xbgn, xend ) $dstName NMChanWaveMakeTemp
			
			WaveStats /Q NMChanWaveMakeTemp
			
			binStart = V_min - extraBins * binWidth
			
			numBins = abs( ( V_max + extraBins * binWidth ) - ( V_min - extraBins * binWidth ) ) / binWidth
			
			histoName = dstName + "_histo"
			histoNameX = dstName + "_histoX"
		
			Make /O/N=( numBins ) $histoName
			
			Histogram /B={ binStart, binWidth, numBins } NMChanWaveMakeTemp, $histoName
			
			if ( dualDisplay )
			
				WaveStats /Q NMChanWaveMakeTemp
				
				scale = dualDisplayPercent * abs( ( rightx( NMChanWaveMakeTemp ) - leftx( NMChanWaveMakeTemp ) ) )
			
				Duplicate /O $histoName, $histoNameX
				
				Wave wtemp = $histoNameX
				
				wtemp = x
				
				Wave wtemp = $histoName
				
				WaveStats /Q wtemp
				
				wtemp /= V_max
				wtemp *= -scale
				
				wtemp += leftx( NMChanWaveMakeTemp )
				
			else
			
				Duplicate /O $histoName $dstName
				KillWaves /Z $histoName
				
			endif
			
			KillWaves /Z NMChanWaveMakeTemp
		
			break
			
		case "Clip Events":
		
			Variable positiveEvents = NumVarOrDefault( cdf + "ClipEvents_Positive", NaN )
			Variable eventFindLevel = NumVarOrDefault( cdf + "ClipEvents_Level", NaN )
			Variable xwinBeforeEvent = NumVarOrDefault( cdf + "ClipEvents_XwinBefore", NaN )
			Variable xwinAfterEvent = NumVarOrDefault( cdf + "ClipEvents_XwinAfter", NaN )
			
			NMEventsClip( positiveEvents, eventFindLevel, xwinBeforeEvent, xwinAfterEvent, dstName )
			
			break
			
	endswitch

End // ChanWaveMake

Function NMChanMarkersMode( channel [ prefixFolder ] )
	Variable channel // ( -1 ) for current channel
	String prefixFolder
	
	Variable markers
	String cdf
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return 0
	endif
	
	if ( channel == -1 )
		channel = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
	endif
	
	cdf = ChanDF( channel, prefixFolder = prefixFolder )
	
	if ( strlen( cdf ) == 0 )
		return 0
	endif
	
	markers = NumVarOrDefault( cdf + "Markers", 0 )
	
	switch( markers )
		case 1: // markers only
			return 3
		case 2: // lines + markers
			return 4
		default: // lines only
			return 0
	endswitch
	
End // NMChanMarkersMode

Function ChanGraphAxesSet( channel ) // set channel graph size and placement
	Variable channel // ( -1 ) for current channel
	
	if ( channel == -1 )
		channel = CurrentNMChannel()
	endif
	
	String gName = ChanGraphName( channel )
	String wname = ChanDisplayWave( channel )
	String cdf = ChanDF( channel )
	
	if ( ( strlen( cdf ) == 0 ) || ( WinType( gName ) != 1 ) )
		return -1
	endif
	
	Variable freezeX = NumVarOrDefault( cdf + "FreezeX", 0 )
	Variable freezeY = NumVarOrDefault( cdf + "FreezeY", 0 )
	
	Variable xmin = NumVarOrDefault( cdf + "Xmin", 0 )
	Variable xmax = NumVarOrDefault( cdf + "Xmax", 1 )
	Variable ymin = NumVarOrDefault( cdf + "Ymin", 0 )
	Variable ymax = NumVarOrDefault( cdf + "Ymax", 1 )
	
	if ( freezeX && freezeY )
		freezeX = 0
		freezeY = 0
	endif
	
	if ( freezeY )
	
		SetAxis /W=$gName/A
		SetAxis /W=$gName left ymin, ymax
		
		return 0
		
	elseif ( freezeX )
	
		WaveStats /Q/R=( xmin, xmax ) $wname
		
		ymin = V_min
		ymax = V_max
		
	endif
	
	SetAxis /W=$gName bottom xmin, xmax
	SetAxis /W=$gName left ymin, ymax
		
End // ChanGraphAxesSet

Function /S NMChanTransformGet( channel [ prefixFolder ] )
	Variable channel // ( -1 ) for current channel
	String prefixFolder
	
	String cdf
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	if ( channel == -1 )
		channel = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
	endif
	
	cdf = NMChanTransformDF( channel, prefixFolder = prefixFolder )
	
	if ( strlen( cdf ) == 0 )
		return "Off"
	endif
	
	return StrVarOrDefault( cdf + "TransformStr", "Off" )
	
End // NMChanTransformGet

Function /S NMChanLabelX( [ folder, wavePrefix, prefixFolder, channel, waveNum, units ] )
	String folder // NM data folder, pass nothing for current data folder
	String wavePrefix // pass nothing for current wave prefix
	String prefixFolder // prefix subfolder ( passing this parameter will usurp folder and wavePrefix ) 
	Variable channel // channel number, pass nothing or -1 for current channel
	Variable waveNum // wave number, pass nothing or -1 for current wave
	Variable units // pass 1 to convert label to units, e.g. "mV" or "pA"
	
	Variable numChannels, numWaves
	String xLabel, wName, shortName, wList
	String defaultWavePrefix, defaultLabel = ""
	
	// BEGIN folder / wavePrefix / prefixFolder check
	
	if ( ParamIsDefault( prefixFolder ) )
	
		if ( ParamIsDefault( folder ) )
			folder = CurrentNMFolder( 1 )
		elseif ( !IsNMDataFolder( folder ) )
			return ""
		else
			folder = CheckNMFolderPath( folder )
		endif
		
		if ( !DataFolderExists( folder ) )
			return ""
		endif
		
		if ( ParamIsDefault( wavePrefix ) )
			wavePrefix = StrVarOrDefault( folder + "CurrentPrefix", "" )
		endif
		
		prefixFolder = NMPrefixFolderDF( folder,  wavePrefix )
		
		if ( strlen( prefixFolder ) == 0 )
			return ""
		endif
		
	else
	
		if ( strlen( prefixFolder ) == 0 )
			prefixFolder = CurrentNMPrefixFolder()
		else
			prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
		endif
		
		if ( strlen( prefixFolder ) == 0 )
			return ""
		endif
		
		prefixFolder = LastPathColon( prefixFolder, 1 )
	
		folder = GetPathName( prefixFolder, 1 )
		shortName = GetPathName( prefixFolder, 0 )
		
		if ( strsearch( shortName, NMPrefixSubfolderPrefix, 0 ) != 0 )
			return "" // this is not a NM prefix subfolder
		endif
		
		wavePrefix = ReplaceString( NMPrefixSubfolderPrefix, shortName, "" )
		
		if ( strlen( wavePrefix ) == 0 )
			return "" // something is wrong
		endif
	
	endif
	
	// END folder / wavePrefix / prefixFolder check
	
	// BEGIN chan / waveNum check
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	numWaves = NumVarOrDefault( prefixFolder + "NumWaves", 0 )
	
	if ( ( ParamIsDefault( channel ) ) || ( channel == -1 ) )
		channel = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
	endif
	
	if ( ( channel < 0 ) || ( channel >= numChannels ) )
		return ""
	endif
	
	if ( ParamIsDefault( waveNum ) )
		waveNum = 0 // use first channel wave as default
	endif
	
	if ( waveNum == -1 )
		waveNum = NumVarOrDefault( prefixFolder + "CurrentWave", 0 )
	endif
	
	if ( ( waveNum < 0 ) || ( waveNum >= numWaves ) )
		return ""
	endif
	
	// END chan / waveNum check
	
	defaultWavePrefix = StrVarOrDefault( folder + "WavePrefix", "" )
	
	if ( ( strlen( defaultWavePrefix ) > 0 ) && StringMatch( wavePrefix, defaultWavePrefix ) )
		defaultLabel = StrVarOrDefault( folder + "xLabel", "" )
	endif
	
	wList = StrVarOrDefault( prefixFolder + NMChanWaveListPrefix + ChanNum2Char( channel ), "" )
	
	if ( ItemsInList( wList ) == 0 )
	
		xLabel = defaultLabel
		
	else
	
		wName = StringFromList( waveNum, wList )
		
		xLabel = NMNoteLabel( "x", folder + wName, defaultLabel )
		
		if ( strlen( xLabel ) == 0 )
			xLabel = NMWaveUnits( "x", wName )
		endif
	
	endif
	
	if ( ( units == 1 ) && ( strlen( xLabel ) > 0 ) )
		return xLabel
	else
		return xLabel
	endif
	
End // NMChanLabelX

Function /S NMChanLabelY( [ folder, wavePrefix, prefixFolder, channel, waveNum, units ] )
	String folder // NM data folder, pass nothing for current data folder
	String wavePrefix // pass nothing for current wave prefix
	String prefixFolder // prefix subfolder ( passing this parameter will usurp folder and wavePrefix ) 
	Variable channel // channel number, pass nothing or -1 for current channel
	Variable waveNum // wave number, pass nothing or -1 for current wave
	Variable units // pass 1 to convert label to units, e.g. "mV" or "pA"
	
	Variable numChannels, numWaves
	String yLabel, strVarName, yName, wName, shortName, wList
	String defaultWavePrefix, defaultLabel = ""
	
	// BEGIN folder / wavePrefix / prefixFolder check
	
	if ( ParamIsDefault( prefixFolder ) )
	
		if ( ParamIsDefault( folder ) )
			folder = CurrentNMFolder( 1 )
		elseif ( !IsNMDataFolder( folder ) )
			return ""
		else
			folder = CheckNMFolderPath( folder )
		endif
		
		if ( !DataFolderExists( folder ) )
			return ""
		endif
		
		if ( ParamIsDefault( wavePrefix ) )
			wavePrefix = StrVarOrDefault( folder + "CurrentPrefix", "" )
		endif
		
		prefixFolder = NMPrefixFolderDF( folder,  wavePrefix )
		
		if ( strlen( prefixFolder ) == 0 )
			return ""
		endif
		
	else
	
		if ( strlen( prefixFolder ) == 0 )
			prefixFolder = CurrentNMPrefixFolder()
		else
			prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
		endif
		
		if ( strlen( prefixFolder ) == 0 )
			return ""
		endif
		
		prefixFolder = LastPathColon( prefixFolder, 1 )
	
		folder = GetPathName( prefixFolder, 1 )
		shortName = GetPathName( prefixFolder, 0 )
		
		if ( strsearch( shortName, NMPrefixSubfolderPrefix, 0 ) != 0 )
			return "" // this is not a NM prefix subfolder
		endif
		
		wavePrefix = ReplaceString( NMPrefixSubfolderPrefix, shortName, "" )
		
		if ( strlen( wavePrefix ) == 0 )
			return "" // something is wrong
		endif
	
	endif
	
	// END folder / wavePrefix / prefixFolder check
	
	// BEGIN chan / waveNum check
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	numWaves = NumVarOrDefault( prefixFolder + "NumWaves", 0 )
	
	if ( ( ParamIsDefault( channel ) ) || ( channel == -1 ) )
		channel = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
	endif
	
	if ( ( channel < 0 ) || ( channel >= numChannels ) )
		return ""
	endif
	
	if ( ParamIsDefault( waveNum ) )
		waveNum = 0 // use first channel wave as default
	endif
	
	if ( waveNum == -1 )
		waveNum = NumVarOrDefault( prefixFolder + "CurrentWave", 0 )
	endif
	
	if ( ( waveNum < 0 ) || ( waveNum >= numWaves ) )
		return ""
	endif
	
	// END chan / waveNum check
	
	defaultWavePrefix = StrVarOrDefault( folder + "WavePrefix", "" )
	
	if ( ( strlen( defaultWavePrefix ) > 0 ) && StringMatch( wavePrefix, defaultWavePrefix ) )
	
		yName = folder + "yLabel"
		
		if ( WaveExists( $yName ) && ( channel < numpnts( $yName ) ) )
		
			Wave /T ytemp = $yName
				
			defaultLabel = ytemp[ channel ]
			
		endif
		
	endif
	
	wList = StrVarOrDefault( prefixFolder + NMChanWaveListPrefix + ChanNum2Char( channel ), "" )
	
	if ( ItemsInList( wList ) == 0 )
	
		yLabel = defaultLabel
		
	else
	
		wName = StringFromList( waveNum, wList )
		
		yLabel = NMNoteLabel( "y", folder  + wName, defaultLabel )
		
		if ( strlen( yLabel ) == 0 )
			yLabel = NMWaveUnits( "y", wName )
		endif
	
	endif
	
	if ( ( units == 1 ) && ( strlen( yLabel ) > 0 ) )
		return UnitsFromStr( yLabel )
	else
		return yLabel
	endif
	
End // NMChanLabelY

Function /S NMWaveNameError( wName )
	String wName

	String wName2 = GetPathName( wName, 0 )
	String path = GetPathName( wName, 1 )
	
	String errorName = path + "STDV_" + wName2
	
	if ( WaveExists( $errorName ) == 1 )
		return errorName
	endif
	
	errorName = path + wName2 + "_STDV"
	
	if ( WaveExists( $errorName ) == 1 )
		return errorName
	endif
	
	errorName = path + "SEM_" + wName2
	
	if ( WaveExists( $errorName ) == 1 )
		return errorName
	endif
	
	errorName = path + wName2 + "_SEM"
	
	if ( WaveExists( $errorName ) == 1 )
		return errorName
	endif
	
	return ""
			
End // NMWaveNameError

Function ChanGraphMove( channel ) // set channel graph size and placement
	Variable channel // ( -1 ) for current channel ( -2 ) for all channels
	
	Variable ccnt, cbgn, cend, left, top, right, bottom
	String gName, cdf
	
	Variable numChannels = NMNumChannels()
	
	if ( channel == -1 )
		cbgn = CurrentNMChannel()
		cend = cbgn
	elseif ( channel == -2 )
		cbgn = 0
		cend = numChannels - 1
	elseif ( ( channel >= 0 ) && ( channel < numChannels ) )
		cbgn = channel
		cend = channel
	else
		//return NM2Error( 10, "channel", num2str( channel ) )
		return 0
	endif
	
	for ( ccnt = cbgn ; ccnt <= cend ; ccnt += 1 )
		
		cdf = ChanDF( ccnt )
		gName = ChanGraphName( ccnt )
		
		if ( ( strlen( cdf ) == 0 ) || ( WinType ( gName ) != 1 ) )
			continue
		endif
		
		left = NumVarOrDefault( cdf + "GX0", Nan )
		top = NumVarOrDefault( cdf + "GY0", Nan )
		right = NumVarOrDefault( cdf + "GX1", Nan )
		bottom = NumVarOrDefault( cdf + "GY1", Nan )
		
		if ( ( numtype( left * top * right * bottom ) == 0 ) && ( right > left ) && ( top < bottom ) ) 
			MoveWindow /W=$gName left, top, right, bottom
		endif
	
	endfor

End // ChanGraphMove

Function NMChanGraphToFront( channel )
	Variable channel // ( -1 ) for current channel
	
	Variable icnt, foundGraphInFront
	String gName2
	
	if ( channel == -1 )
		channel = CurrentNMChannel()
	endif
	
	String gName = ChanGraphName( channel )
	String cdf = ChanDF( channel )
	
	if ( ( strlen( cdf ) == 0 ) || ( WinType( gName ) == 0 ) )
		return 0
	endif
	
	Variable toFront = NumVarOrDefault( cdf + "ToFront", 1 )
	
	if ( !toFront )
		return 0
	endif
	
	String gList = WinList("*", ";", "Visible:1")
	
	for ( icnt = 0 ; icnt < ItemsInList( gList ) ; icnt += 1 )
	
		gName2 = StringFromList( icnt, gList )
		
		if ( StringMatch( gName2, gName ) )
			break
		endif
		
		if ( strsearch( gName2, NMChanGraphPrefix, 0 ) == 0 )
			continue
		endif
		
		return 1
		
	endfor
	
	return 0
	
End // NMChanGraphToFront

Function NMChanFilterSetVariableUpdate( channel )
	Variable channel // ( -1 ) for current channel
	
	if ( channel == -1 )
		channel = CurrentNMChannel()
	endif
	
	String gName = ChanGraphName( channel )
	String cc = num2istr( channel )
	String titlestr = "Filter"
	
	String cdf = ChanDF( channel )
	
	//Variable filterExists = ChanFilterFxnExists()
	
	String filterAlg = ChanFilterAlgGet( channel )
	
	ControlInfo /W=$gName $( "SmoothSet"+cc )
	
	if ( V_flag == 0 )
		return 0
	endif
	
	strswitch( filterAlg )
		case "binomial":
		case "boxcar":
			titlestr = "Smooth"
			break
		case "low-pass":
			titlestr = "Low"
			break
		case "high-pass":
			titlestr = "High"
			break
		default:
			titlestr = "Filter"
	endswitch
	
	SetVariable $( "SmoothSet"+cc ), win=$gName, title=titlestr, proc=$ChanFilterProc( channel ), value=$( cdf + "SmoothN" )
	
	return 0
	
End // NMChanFilterSetVariableUpdate

Function NMChanTransformCheckBoxUpdate( channel )
	Variable channel // ( -1 ) for current channel
	
	Variable v, numWaves
	String wList
	
	if ( channel == -1 )
		channel = CurrentNMChannel()
	endif
	
	String gName = ChanGraphName( channel )
	String cc = num2istr( channel )
	String transform = NMChanTransformGet( channel )
	
	if ( WinType( gName ) != 1 )
		return -1
	endif
	
	ControlInfo /W=$gName $( "TransformCheck"+cc )
	
	if ( V_flag == 0 )
		return 0
	endif
	
	if ( WhichListItem( transform, NMChanTransformList ) >= 0 )
		v = 1
	else
		transform = "Transform"
	endif
	
	if ( StringMatch( transform, "Running Average" ) )
	
		wList = z_RunningAvgWaveList( channel, -1, -1, -1 )
		
		numWaves = ItemsInList( wList )
		
		if ( numWaves == 0 )
			numWaves = 1
		endif
		
		transform = "Avg (n=" + num2istr( numWaves ) + ")"
		
	endif
	
	//CheckBox $( "TransformCheck"+cc ), value=v, title=transform, win=$gName, proc=$NMChanTransformProc( channel )
	
End // NMChanTransform//CheckBoxUpdate

Function NMProgress( currentCount, maxIterations, progressStr )
	Variable currentCount, maxIterations
	String progressStr
	
	Variable fraction = currentCount / ( maxIterations - 1 )
	
	return NMProgressCall( fraction, progressStr )
	
End // NMProgress

Function /S NMSubfolderList( folderPrefix, parentFolder, fullPath )
	String folderPrefix // e.g. "Spike_"
	String parentFolder // where to look for subfolders
	Variable fullPath // use full-path names ( 0 ) no ( 1 ) yes

	Variable icnt
	String subfolderList, folderName, outList = ""
	
	if ( strlen( parentFolder ) == 0 )
		parentFolder = CurrentNMFolder( 1 )
	endif
	
	subfolderList = FolderObjectList( parentFolder, 4 )
	
	for ( icnt = 0 ; icnt < ItemsInList( subfolderList ) ; icnt += 1 )
		
		folderName = StringFromList( icnt, subfolderList )
		
		if ( strsearch( folderName, folderPrefix, 0, 2 ) == 0 )
		
			if ( fullPath == 1 )
				outList = AddListItem( parentFolder + folderName + ":" , outList, ";", inf )
			else
				outList = AddListItem( folderName, outList, ";", inf )
			endif
			
		endif
	
	endfor
	
	return outList

End // NMSubfolderList

Function /S NMSetsListAll( [ prefixFolder ] ) // all sets + all groups
	String prefixFolder
	
	Variable scnt
	String matchStr, setName, strVarName, strVarList, outList = ""
	
	String defaultList = NMSetsListDefault
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	for ( scnt = 0 ; scnt < ItemsInList( defaultList ) ; scnt += 1 )
	
		setName = StringFromList( scnt, defaultList )
		
		if ( ( strlen( setName ) > 0 ) && AreNMSets( setName, prefixFolder = prefixFolder ) )
			outList += setName + ";"
		endif
		
	endfor
	
	matchStr = "*" + NMSetsListSuffix + "*"
	
	strVarList = NMFolderStringList( prefixFolder, matchStr, ";", 0 )
	
	for ( scnt = 0 ; scnt < ItemsInList( strVarList ) ; scnt += 1 )
	
		setName = StringFromList( scnt, strVarList )
		setName = NMSetsNameGet( setName )
		
		if ( strlen( setName ) > 0 )
			outList = NMAddToList( setName, outList, ";" )
		endif
		
	endfor
	
	return outList

End // NMSetsListAll

Function /S NMSetsStrVarName( setName, chanNum, [ prefixFolder ] )
	String setName
	Variable chanNum
	String prefixFolder
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif

	return prefixFolder + NMSetsStrVarPrefix( setName ) + ChanNum2Char( chanNum )

End // NMSetsStrVarName

Function /S NMGroupsName( group )
	Variable group
		
	if ( numtype( group ) == 0 )
		return "Group" + num2istr( group )
	endif
	
	return ""

End // NMGroupsName

Function NMPrefixFolderListsToWave( inputStrVarPrefix, outputWaveName, [ prefixFolder ] )
	String inputStrVarPrefix
	String outputWaveName
	String prefixFolder

	Variable ccnt, wcnt, wnum, numChannels, numWaves, alertUser = 0
	String wList, strVarName, chanList, wName 
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	if ( WaveExists( $outputWaveName ) )
	
		if ( alertUser )
	
			DoAlert 1, "NMPrefixFolderListsToWave Alert: wave " + NMQuotes( outputWaveName ) + " already exists. Do you want to overwrite it?"
			
			if ( V_flag != 1 )
				return -1 // cancel
			endif
		
		endif
		
		KillWaves /Z $outputWaveName // try to kill
		
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	numWaves = NumVarOrDefault( prefixFolder + "NumWaves", 0 )
	
	if ( numChannels == 0 )
		return -1
	endif
	
	CheckNMWave( outputWaveName, numWaves, 0 )
	
	if ( !WaveExists( $outputWaveName ) )
		return -1
	endif

	Wave output = $outputWaveName
	
	output = 0

	for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
	
		strVarName = prefixFolder + inputStrVarPrefix + ChanNum2Char( ccnt )
		
		wList = StrVarOrDefault( strVarName, "" )
		chanList= NMChanWaveList( ccnt, prefixFolder = prefixFolder )
	
		for ( wcnt = 0 ; wcnt < ItemsInList( wList ) ; wcnt += 1 )
			
			wName = StringFromList( wcnt, wList )
			wnum = WhichListItem( wName, chanList )
			
			if ( ( wnum >= 0 ) && ( wnum < numWaves ) )
				output[ wnum ] = 1
			endif
		
		endfor
	
	endfor
	
	return 0

End // NMPrefixFolderListsToWave

Function /S NMSetsStrVarPrefix( setName )
	String setName
	
	Variable numCharSuffix = strlen( NMSetsListSuffix ) + 1 // extra for chan character
	
	setName = setName[ 0, 30 - numCharSuffix ] // there is 31 char limit
	
	setName += NMSetsListSuffix
	
	setName = NMCheckStringName( setName )
	
	return setName
	
End // NMSetsStrVarPrefix

Function NMSetsWavesTag( setList, [ prefixFolder ] )
	String setList
	String prefixFolder
	
	Variable icnt
	String setName, wnote, prefix
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	prefix = GetPathName( prefixFolder, 0 )
	prefix = ReplaceString( NMPrefixSubfolderPrefix, prefix, "" )
	
	for ( icnt = 0; icnt < ItemsInList( setList ); icnt += 1 )
	
		setName = StringFromList( icnt, setList )
		
		if ( !WaveExists( $setName ) )
			continue
		endif
		
		if ( StringMatch( NMNoteStrByKey( setName, "Type" ), "NMSet" ) )
			continue
		endif
		
		wnote = "WPrefix:" + prefix
		
		if ( StringMatch( setName, "SetX" ) )
			wnote += NMCR + "Excluding:" + num2str( NMSetXType( prefixFolder = prefixFolder ) )
		endif
		
		NMNoteType( setName, "NMSet", "Wave#", "True ( 1 ) / False ( 0 )", wnote )
		
		Note $setName, "DEPRECATED: Set waves are no longer utilized by NeuroMatic. Please use Set list string variables instead."
		
	endfor
	
	return 0

End // NMSetsWavesTag

Function NMGroupsListsToWave( gwName, [ prefixFolder ] )
	String gwName
	String prefixFolder

	Variable wcnt, ccnt, gcnt, group, found, numChannels, numWaves, alertUser = 0
	String wName2, groupList, wList

	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	numWaves = NumVarOrDefault( prefixFolder + "NumWaves", 0 )
	
	if ( ( numChannels <= 0 ) || ( numWaves <= 0 ) )
		return 0
	endif
	
	if ( WaveExists( $gwName ) == 1 )
	
		if ( alertUser == 1 )
	
			DoAlert 1, "NMGroupsListsToWave Alert: wave " + NMQuotes( gwName ) + " already exists. Do you want to overwrite it?"
			
			if ( V_flag != 1 )
				return -1 // cancel
			endif
		
		endif
		
		KillWaves /Z $gwName // try to kill
		
	endif

	groupList = NMGroupsList( 0, prefixFolder = prefixFolder )
	
	Make /O/N=(numWaves) $gwName = Nan
	
	NMGroupsTag( gwName, prefixFolder = prefixFolder )
	
	if ( ItemsInList( groupList ) == 0 )
		return 0
	endif
	
	Wave wtemp = $gwName
	
	for ( wcnt = 0 ; wcnt < numWaves; wcnt += 1 )
	
		found = Nan
	
		for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
	
			wName2 = NMChanWaveName( ccnt, wcnt, prefixFolder = prefixFolder )
			
			for ( gcnt = 0 ; gcnt < ItemsInlist( groupList ) ; gcnt += 1 )
	
				group = str2num( StringFromList( gcnt, groupList ) )
				wList = NMGroupsWaveList( group, ccnt, prefixFolder = prefixFolder )
				
				if ( WhichListItem( wName2, wList ) >= 0 )
					found = group
					break
				endif
				
			endfor
			
			if ( numtype( found ) == 0 )
				break
			endif
			
		endfor
		
		wtemp[ wcnt ] = found
		
	endfor
	
	return 0

End // NMGroupsListsToWave

Function /S NMWaveSelected( channel, waveNum, [ prefixFolder ] ) // return wave name if it is currently selected
	Variable channel // ( -1 ) for current channel
	Variable waveNum // wave number or ( -1 ) for current
	String prefixFolder
	
	Variable currentChan, currentWave
	String wName, wList, waveSelect
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	currentChan = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
	currentWave = NumVarOrDefault( prefixFolder + "CurrentWave", 0 )
	
	if ( channel < 0 )
		channel = currentChan
	endif
	
	if ( waveNum < 0 )
		waveNum = currentWave
	endif
	
	if ( !NMChanSelected( channel, prefixFolder = prefixFolder ) )
		return ""
	endif
	
	wName = NMChanWaveName( channel, waveNum, prefixFolder = prefixFolder )
	
	waveSelect = StrVarOrDefault( prefixFolder + "WaveSelect", "" )
	
	if ( StringMatch( waveSelect, "This Wave" ) )
	
		if ( ( channel == currentChan ) && ( waveNum == currentWave ) )
			return wName
		else
			return ""
		endif
	
	endif
	
	wList = NMWaveSelectList( channel, prefixFolder = prefixFolder )
	
	if ( !WaveExists( $wName ) || ( WaveType( $wName ) == 0 ) )
		return ""
	endif
	
	if ( WhichListItem( wName, wList ) >= 0 )
		return wName
	endif
	
	return ""
	
End // NMWaveSelected

Function /S NMSetsEqLockWaveName( [ prefixFolder ] )
	String prefixFolder

	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	return prefixFolder + "SetsFxnsLocked"

End // NMSetsEqLockWaveName

Function /S NMSetsEqLockTableFind( setName, select, [ prefixFolder ] )
	String setName
	String select // see strswitch below
	String prefixFolder
	
	Variable icnt, ipnts
	String eq, txt, wName
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif

	wName = NMSetsEqLockWaveName( prefixFolder = prefixFolder )
	
	if ( ( strlen( wName ) == 0 ) || !WaveExists( $wName ) )
		return ""
	endif
	
	Wave /T wtemp = $wName
	
	ipnts = DimSize( wtemp, 0 )
	
	for ( icnt = 0 ; icnt < ipnts ; icnt += 1 )
	
		if ( strlen( wtemp[ icnt ][ 0 ] ) == 0 )
			continue
		endif
		
		if ( StringMatch( setName, wtemp[ icnt ][ 0 ] ) )
			
			strswitch( select )
			
				case "all":
					return wtemp[ icnt ][ 0 ] + " = " + wtemp[ icnt ][ 1 ] + " " + wtemp[ icnt ][ 2 ] + " " + wtemp[ icnt ][ 3 ]
			
				case "arg1":
					return wtemp[ icnt ][ 1 ]
				
				case "op":
				case "operation":
					return wtemp[ icnt ][ 2 ]
					
				case "arg2":
					return wtemp[ icnt ][ 3 ]
			
			endswitch
			
		endif
		
	endfor
	
	return ""
	
End // NMSetsEqLockTableFind

Function /S NMSetsStrVarSearch( setName, fullPath, [ prefixFolder ] )
	String setName
	Variable fullPath
	String prefixFolder
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	String setsPrefix = NMSetsStrVarPrefix( setName )

	return NMFolderStringList( prefixFolder, setsPrefix + "*", ";", fullPath )
	
End // NMSetsStrVarSearch

Function NMConfigVarListAdd( fname, varName )
	String fname // config folder name
	String varName
	
	String df = ConfigDF( fname )
	
	String vList = StrVarOrDefault( df + "C_VarList", "" )
	
	vList = AddListItem( varName, vList, ";", inf )
	
	SetNMstr( df + "C_VarList", vList )
	
End // NMConfigVarListAdd

Function /S NMConfigVarList( fname, objType )
	String fname // config folder name
	Variable objType // ( 1 ) waves ( 2 ) variables ( 3 ) strings ( 4 ) data folders ( 5 ) numeric wave ( 6 ) text wave
	
	Variable ocnt
	String objName, rlist = ""
	
	String objList = FolderObjectList( ConfigDF( fname ), objType )
	
	if ( objType == 3 ) // strings
	
		for ( ocnt = 0; ocnt < ItemsInList( objList ); ocnt += 1 )
		
			objName = StringFromList( ocnt, objList )
			
			if ( StringMatch( objName[ 0,1 ], "C_" ) == 1 )
				continue
			endif
			
			if ( StringMatch( objName[ 0,1 ], "D_" ) == 1 )
				continue
			endif
			
			if ( StringMatch( objName[ 0,1 ], "T_" ) == 1 )
				continue
			endif
			
			rlist += objName + ";"
			
		endfor
		
		objList = rlist
		
	endif
	
	objList = RemoveFromList( "FileType", objList )
	objList = RemoveFromList( "VarName", objList )
	objList = RemoveFromList( "StrValue", objList )
	objList = RemoveFromList( "NumValue", objList )
	objList = RemoveFromList( "Description", objList )
	
	return objList

End // NMConfigVarList

Function NMColorListRGB( select, colorList )
	String select // "red", "green" or "blue"
	String colorList
	
	Variable value
	
	strswitch( select )
	
		case "red":
			value = str2num( StringFromList( 0, colorList, "," ) )
			break
			
		case "green":
			value = str2num( StringFromList( 1, colorList, "," ) )
			break
			
		case "blue":
			value = str2num( StringFromList( 2, colorList, "," ) )
			break
			
	endswitch
	
	if ( numtype( value ) > 0 )
		return 0
	endif
	
	return min( max( value, 0 ), 65535 )
	
End // NMColorListRGB

Function ExecuteUserTabEnable( tabName, enable )
	String tabName
	Variable enable
	
	String fxnParams = "( " + num2str( enable ) + " )"
	String fxn = tabName + "Tab"
	
	if ( exists( fxn ) != 6 )
		fxn = tabName
	endif
	
	Execute /Z fxn + fxnParams
	
	if ( V_Flag == 0 )
		return 0
	else
		return -1 // no function execution
	endif
	
End // ExecuteUserTabEnable

Function NMLogDisplay(ldf, select)
	String ldf // log data folder
	Variable select // (1) notebook (2) table (3) both

	if ((select == 1) || (select == 3))
		LogNotebook(ldf)
	endif
	
	if ((select == 2) || (select == 3))
		LogTable(ldf)
	endif
	
End // NMLogDisplay

Function NMFolderListNum( folder )
	String folder
	
	Variable icnt, found, npnts
	
	String wname = NMFolderListWave()
	
	if ( WaveExists( $wname ) == 0 )
		return Nan
	endif
	
	if ( strlen( folder ) == 0 )
		folder = CurrentNMFolder( 0 )
	endif
	
	Wave /T list = $wname
	
	folder = GetPathName( folder, 0 )
	
	npnts = numpnts( list )
	
	for ( icnt = 0; icnt < npnts; icnt += 1 )
		if ( StringMatch( folder, list[ icnt ] ) == 1 )
			return icnt
		endif
	endfor
	
	return Nan
	
End // NMFolderListNum

Function ChanOverlayKill( channel )
	Variable channel // ( -1 ) for current channel ( -2 ) for all channels

	Variable cbgn, cend
	
	Variable wcnt, ccnt, overlay
	String wname, wList, cdf
	
	Variable numChannels = NMNumChannels()
	
	if ( channel == -1 )
		cbgn = CurrentNMChannel()
		cend = cbgn
	elseif ( channel == -2 )
		cbgn = 0
		cend = numChannels - 1
	elseif ( ( channel >= 0 ) && ( channel < numChannels ) )
		cbgn = channel
		cend = channel
	else
		//return NM2Error( 10, "channel", num2str( channel ) )
		return 0 // nothing to do
	endif

	for ( ccnt = cbgn; ccnt <= cend; ccnt += 1 )
	
		cdf = ChanDF( ccnt )
		
		if ( strlen( cdf ) == 0 )
			continue
		endif
	
		wList = NMFolderWaveList( cdf, "Display" + ChanNum2Char( ccnt ) + "*", ";", "", 0 )
	
		overlay = NumVarOrDefault( cdf + "Overlay", 0 )
	
		for ( wcnt = 0; wcnt <= overlay; wcnt += 1 )
			wname = ChanDisplayWaveName( 0, ccnt, wcnt )
			wList = RemoveFromList( wname, wList )
		endfor
		
		for ( wcnt = 0; wcnt < ItemsInList( wList ); wcnt += 1 )
			wname = cdf + StringFromList( wcnt, wList )
			KillWaves /Z $wname
		endfor
		
	endfor
	
	return 0

End // ChanOverlayKill

Function ChanGraphClear( channel )
	Variable channel // ( -1 ) for current channel ( -2 ) for all channels
	
	Variable ccnt, cbgn, cend
	String wname
	
	Variable numChannels = NMNumChannels()
	
	if ( channel == -1 )
		cbgn = CurrentNMChannel()
		cend = cbgn
	elseif ( channel == -2 )
		cbgn = 0
		cend = 9 // numChannels - 1
	elseif ( ( channel >= 0 ) && ( channel < numChannels ) )
		cbgn = channel
		cend = channel
	else
		//return NM2Error( 10, "channel", num2str( channel ) )
		return 0
	endif
	
	for ( ccnt = cbgn; ccnt <= cend; ccnt += 1 )
	
		wname = ChanDisplayWave( ccnt )
		
		ChanOverlayClear( ccnt )
		
		if ( WaveExists( $wname ) )
			Wave wtemp = $wname
			wtemp = Nan
		endif
		
	endfor

End // ChanGraphClear

Function ChanGraphsRemoveWaves()

	Variable ccnt, numChannels = NMNumChannels()
	
	for ( ccnt = 0; ccnt < numChannels; ccnt+=1 )
		ChanGraphRemoveWaves( ccnt )
	endfor

End // ChanGraphsRemoveWaves

Function ChanGraphsAppendDisplayWave()

	Variable ccnt, numChannels = NMNumChannels()
	
	for ( ccnt = 0; ccnt < numChannels; ccnt+=1 )
		ChanGraphAppendDisplayWave( ccnt )
	endfor

End // ChanGraphsAppendDisplayWave

Function ChanGraphTagsKill( channel )
	Variable channel // ( -1 ) for current channel ( -2 ) for all channels
	
	Variable icnt, ccnt, cbgn, cend
	String gName, aName, aList
	
	Variable numChannels = NMNumChannels()
	
	if ( channel == -1 )
		cbgn = CurrentNMChannel()
		cend = cbgn
	elseif ( channel == -2 )
		cbgn = 0
		cend = numChannels - 1
	elseif ( ( channel >= 0 ) && ( channel < numChannels ) )
		cbgn = channel
		cend = channel
	else
		//return NM2Error( 10, "channel", num2str( channel ) )
		return 0
	endif
	
	for ( ccnt = cbgn; ccnt <= cend; ccnt += 1 )
	
		gName = ChanGraphName( ccnt )
		
		if ( Wintype( gName ) == 0 )
			continue
		endif
		
		alist = AnnotationList( gName ) // list of tags
			
		for ( icnt = 0; icnt < ItemsInList( alist ); icnt += 1 )
			aName = StringFromList( icnt, alist )
			Tag /W=$gName /N=$aName /K // kill tags
		endfor
		
	endfor
	
	return 0
	
End // ChanGraphTagsKill

Function NMFolderListNextNum()

	Variable icnt, found, npnts
	
	String wname = NMFolderListWave()
	
	if ( WaveExists( $wname ) == 0 )
		return 0
	endif
	
	Wave /T list = $wname
	
	npnts = numpnts( list )
	
	for ( icnt = npnts-1; icnt >= 0; icnt -=1 )
		if ( strlen( list[ icnt ] ) > 0 )
			found = 1
			break
		endif
	endfor
	
	if ( found == 0 )
	
		return 0
		
	else
	
		icnt += 1
		
		return icnt
		
	endif

End // NMFolderListNextNum

Function SeqNumFind( file ) // determine file sequence number, and its string index boundaries
	String file // file name
	
	Variable icnt, ibeg, iend, seqnum = Nan
	
	for ( icnt = strlen( file ) - 1; icnt >= 0; icnt -= 1 )
		if ( numtype( str2num( file[ icnt ] ) ) == 0 )
			break // first appearance of number, from right
		endif
	endfor
	
	iend = icnt
	
	for ( icnt = iend; icnt >= 0; icnt -= 1 )
		if ( numtype( str2num( file[ icnt ] ) ) == 2 )
			break // last appearance of number, from right
		endif
	endfor
	
	ibeg = icnt + 1
	
	seqnum = str2num( file[ ibeg, iend ] )
	
	Variable /G iSeqBgn = ibeg	// store begin/end placement of seq number
	Variable /G iSeqEnd = iend
	
	return seqnum

End // SeqNumFind

Function /S SeqNumSet( file, ibeg, iend, seqnum ) // create new file name, with new sequence number
	String file // original file name
	Variable ibeg // begin string index of sequence number ( iSeqBgn )
	Variable iend // end string index of sequence number ( iSeqEnd )
	Variable seqnum // new sequence number
	
	Variable icnt, jcnt
	
	icnt = iend - ibeg + 1
	
	jcnt = strlen( num2istr( seqnum ) )
	
	if ( jcnt <= icnt )
		ibeg = iend - jcnt + 1
		file[ ibeg, iend ] = num2istr( seqnum )
	else
		file = "overflow" // new sequence number does not fit within allowed index boundaries
	endif
	
	return file

End // SeqNumSet

Function NMDeprecatedAlert( newfunction )
	String newfunction
	
	String oldfunction, alert

	if ( NMVarGet( "DeprecationAlert" ) == 0 )
		return 0
	endif
	
	oldfunction = GetRTStackInfo( 2 )
	
	alert = "Alert: NeuroMatic function " + NMQuotes( oldfunction ) + " has been deprecated. "
	
	if ( strlen( newfunction ) > 0 )
		alert += "Please use function " + NMQuotes( newfunction ) + " instead."
	endif
	
	NMHistory( alert )
	NMDeprecationNotebook( alert )

End // NMDeprecatedAlert

Function CheckNMChanWaveLists( [ prefixFolder ] )
	String prefixFolder

	Variable ccnt
	String strVarName
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return 0
	endif
	
	String wName = prefixFolder + "ChanWaveList" // OLD WAVE
	
	if ( !WaveExists( $wName ) )
		return 0
	endif

	Wave /T wtemp = $wName
	
	for ( ccnt = 0 ; ccnt < numpnts( wtemp ) ; ccnt += 1 )
		strVarName = prefixFolder + NMChanWaveListPrefix + ChanNum2Char( ccnt )
		SetNMstr( strVarName, wtemp[ ccnt ] )
	endfor
	
	KillWaves /Z $wName
	
	NMPrefixFolderWaveKill( "wNames_", prefixFolder = prefixFolder ) // kill old waves
	
	NMChanWaveList2Waves( prefixFolder = prefixFolder )

End // CheckNMChanWaveLists

Function CheckNMSets( [ prefixFolder ] )
	String prefixFolder

	Variable scnt
	String setList, setName, setDataList = ""

	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif

	setList = NMSetsWavesList( prefixFolder, 0 )
	
	if ( ItemsInList( setList ) > 0 )
	
		for ( scnt = 0 ; scnt < ItemsInList( setList ) ; scnt += 1 )
		
			setName = StringFromList( scnt, setList )
			
			if ( StringMatch( setName[0,7], "Set_Data" ) )
				setDataList = AddListItem( setName, setDataList, ";", inf )
			endif
			
		endfor
		
		if ( ItemsInList( setDataList ) == 1 )
		
			setName = StringFromList( 0, setDataList )
			
			if ( StringMatch( setName, "Set_Data0" ) )
				
				Wave wtemp = $prefixFolder+setName
				
				if ( sum( wtemp ) == numpnts( wtemp ) )
					KillWaves /Z $prefixFolder+setName // this wave is unecessary
					setList = RemoveFromList( setName, setList )
				endif
				
			endif
			
		endif
	
		OldNMSetsWavesToLists( setList, prefixFolder = prefixFolder )
		
	endif
	
	CheckNMSetsExist( NMSetsListDefault, prefixFolder = prefixFolder )

	return 0

End // CheckNMSets

Function CheckNMGroups( [ prefixFolder ] )
	String prefixFolder

	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif

	String gwName = NMGroupsWaveName( prefixFolder = prefixFolder )
	
	if ( WaveExists( $gwName ) == 1 )

		if ( NMGroupsWaveToLists( gwName, prefixFolder = prefixFolder ) >= 0 )
			KillWaves /Z $gwName
		endif
	
	endif
	
	return 0
	
End // CheckNMGroups

Function CheckNMChanSelect( [ prefixFolder ] )
	String prefixFolder
	
	Variable ccnt
	String wName, chanList = ""
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return 0
	endif
	
	wName = prefixFolder + "ChanSelect"
	
	if ( WaveExists( $wName ) )
		
		Wave wtemp = $wName

		for ( ccnt = 0 ; ccnt < numpnts( wtemp ) ; ccnt += 1 )
		
			if ( wtemp[ ccnt ] == 1 )
				chanList = AddListItem( num2istr( ccnt ), chanList, ";", inf )
			endif
		
		endfor
		
		KillWaves /Z $wName
		
	endif
	
	if ( ItemsInList( chanList ) == 0 )
	
		chanList = StrVarOrDefault( prefixFolder + NMChanSelectVarName, "" )
		
		if ( ItemsInList( chanList ) == 0 )
			chanList = "0;"
		else
			return 0
		endif
	
	endif
	
	SetNMstr( prefixFolder + NMChanSelectVarName, chanList )

End // CheckNMChanSelect

Function CheckNMWaveSelect( [ prefixFolder ] )
	String prefixFolder

	String wName, waveSelect = ""
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	wName = prefixFolder + "WavSelect"
	
	if ( WaveExists( $wName ) )
	
		waveSelect = note( $wName )
		
		KillWaves /Z $wName
		
	endif
	
	if ( strlen( waveSelect ) == 0 )
	
		waveSelect = StrVarOrDefault( prefixFolder + "WaveSelect", "" )
		
		if ( strlen( waveSelect ) == 0 )
			waveSelect = "All"
		else
			return 0
		endif
		
	endif
	
	SetNMstr( prefixFolder + "WaveSelect", waveSelect )
	
	UpdateNMWaveSelectLists( prefixFolder = prefixFolder )
	
	return 0
	
End // CheckNMWaveSelect

Function NMChanLabelSet( channel, waveSelect, xySelect, labelStr, [ prefixFolder, updateNM, history ] )
	Variable channel // ( -1 ) for current channel ( -2 ) for all channels
	Variable waveSelect // ( 1 ) selected waves ( 2 ) all channel waves
	String xySelect // "x" or "y"
	String labelStr
	String prefixFolder
	Variable updateNM
	Variable history // print function command to history ( 0 ) no ( 1 ) yes
	
	Variable wcnt, ccnt, cbgn, cend, numChannels
	String wName, wList, vlist = ""
	
	vList = NMCmdNum( channel, vList )
	vList = NMCmdNum( waveSelect, vList )
	vList = NMCmdStr( xySelect, vList )
	vList = NMCmdStr( labelStr , vList )
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		vlist = NMCmdStrOptional( "prefixFolder", prefixFolder, vlist )
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( ParamIsDefault( updateNM ) )
		updateNM = 1
	else
		vlist = NMCmdNumOptional( "updateNM", updateNM, vlist )
	endif
	
	if ( !ParamIsDefault( history ) && history )
		NMCmdHistory( "", vlist )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	if ( numtype( channel ) > 0 )
		return NM2Error( 10, "channel", num2str( channel ) )
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	if ( channel == -1 )
		cbgn = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
		cend = cbgn
	elseif ( channel == -2 )
		cbgn = 0
		cend = numChannels - 1
	elseif ( ( channel >= 0 ) && ( channel < numChannels ) )
		cbgn = channel
		cend = channel
	else
		return NM2Error( 10, "channel", num2str( channel ) )
	endif
	
	labelStr = StringFromList( 0, labelStr )
	
	for ( ccnt = cbgn ; ccnt <= cend ; ccnt += 1 )
	
		switch( waveSelect )
		
			case 1:
				wList = NMWaveSelectList( ccnt, prefixFolder = prefixFolder )
				break
				
			case 2:
				wList = NMChanWaveList( ccnt, prefixFolder = prefixFolder )
				break
				
			default:
				return NM2Error( 10, "waveSelect", num2istr( waveSelect ) )
				
		endswitch
		
		for ( wcnt = 0; wcnt < ItemsInList( wList ); wcnt += 1 )
		
			wName = StringFromList( wcnt, wList )
			
			strswitch( xySelect )
			
				case "x":
				case "y":
					NMNoteStrReplace( wName, xySelect+"Label", labelStr )
					RemoveWaveUnits( wName )
					break
					
				default:
					return NM2Error( 20, "xySelect", xySelect )
			
			endswitch
		
		endfor
		
	endfor
	
	if ( updateNM )
		ChanGraphsUpdate()
		UpdateNMPanel( 1 )
	endif
	
	return 0

End // NMChanLabelSet

Function /S NMChanTransformName( ft )
	Variable ft // ( 0 ) none ( > 0 ) see NMChanTransformList
	
	// old transform flag, not used anymore
	// one should use "Transform" string variable instead
	
	switch( ft )
		case 0:
			return "Off"
		case 1:
			return "Differentiate"
		case 2:
			return "Double Differentiate"
		case 3:
			return "Integrate"
		case 4:
			return "Normalize"
		case 5:
			return "dF/Fo"
		case 6:
			return "Baseline"
		case 7:
			return "Running Average"
		case 8:
			return "Histogram"
		case 9:
			return "Clip Events"
	endswitch
	
	return "Off"
	
End // NMChanTransformName

Function NMSetsWavesKill( [ prefixFolder ] )
	String prefixFolder

	Variable scnt, killedsomething
	String setName
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	NMSetsPanelTable( 0 ) // if table exists, remove Set waves

	String setList = NMSetsWavesList( prefixFolder, 0 )
	
	for ( scnt = 0 ; scnt <ItemsInList( setList ) ; scnt += 1 )
	
		setName = StringFromList( scnt, setList )
		
		if ( AreNMSets( setName, prefixFolder = prefixFolder ) )
			KillWaves /Z $prefixFolder+setName // kill only if Set string lists exist
		endif
		
		if ( !WaveExists( $prefixFolder+setName ) )
			killedsomething = 1
		endif
		
	endfor

	return killedsomething

End // NMSetsWavesKill

Function NMSetsListsToWaves( setList, [ prefixFolder ] )
	String setList
	String prefixFolder

	Variable scnt
	String setName, outputWaveName
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	for ( scnt = 0 ; scnt < ItemsInList( setList ) ; scnt += 1 )
	
		setName = StringFromList( scnt, setList )
		outputWaveName = prefixFolder+setName
		
		NMPrefixFolderListsToWave( NMSetsStrVarPrefix( setName ), outputWaveName, prefixFolder = prefixFolder )
		
		NMSetsWavesTag( outputWaveName, prefixFolder = prefixFolder )
		
	endfor
	
	return 0

End // NMSetsListsToWaves

Function NMSetsKill( setList, [ prefixFolder, updateNM, history ] )
	String setList // set name list, or "All"
	String prefixFolder
	Variable updateNM
	Variable history // print function command to history ( 0 ) no ( 1 ) yes
	
	Variable scnt, killedsomething
	String setName
	
	String vlist = NMCmdStr( setList, "" )
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		vlist = NMCmdStrOptional( "prefixFolder", prefixFolder, vlist )
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( ParamIsDefault( updateNM ) )
		updateNM = 1
	else
		vlist = NMCmdNumOptional( "updateNM", updateNM, vlist )
	endif
	
	if ( !ParamIsDefault( history ) && history )
		NMCmdHistory( "", vlist )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	if ( StringMatch( setList, "All" ) )
		setList = NMSetsList()
	endif
	
	NMSetsEqLockTableClear( setList, prefixFolder = prefixFolder )
	
	for ( scnt = 0; scnt < ItemsInList( setList ); scnt += 1 )
		setName = StringFromList( scnt, setList )
		killedsomething += NMPrefixFolderStrVarKill( NMSetsStrVarPrefix( setName ), prefixFolder = prefixFolder )
	endfor
	
	if ( updateNM )
		NMSetsEqLockTableUpdate( prefixFolder = prefixFolder )
		UpdateNMWaveSelectLists( prefixFolder = prefixFolder )
		UpdateNMPanelSets( 1 )
	endif
	
	return 0
	
End // NMSetsKill

Function NMSetsWavesToLists( setList, [ prefixFolder ] )
	String setList
	String prefixFolder
	
	Variable scnt
	String setName, inputWaveName
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	for ( scnt = 0 ; scnt < ItemsInList( setList ) ; scnt += 1 )
	
		setName = StringFromList( scnt, setList )
		inputWaveName = prefixFolder+setName
		
		NMPrefixFolderWaveToLists( inputWaveName, NMSetsStrVarPrefix( setName ), prefixFolder = prefixFolder )
	
	endfor
	
	return 0
	
End // NMSetsWavesToLists

Function /S NMGroupsWaveName( [ prefixFolder ] )
	String prefixFolder

	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif

	return prefixFolder + "Group"

End // NMGroupsWaveName

Function NMGroupsWaveToLists( gwName, [ prefixFolder ] )
	String gwName
	String prefixFolder

	Variable gcnt, ccnt, wcnt, group, numChannels
	String wName, groupSeqStr, groupName, groupList = "", wList = ""
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	if ( WaveExists( $gwName ) == 0 )
		return NM2Error( 10, "gwName", gwName )
	endif
	
	Wave wtemp = $gwName
	
	for ( wcnt = 0 ; wcnt < numpnts( $gwName ) ; wcnt += 1 )
	
		group = wtemp[ wcnt ]
		
		if ( ( numtype( group ) == 0 ) && ( group >= 0 ) )
			groupList = NMAddToList( num2istr( group ), groupList, ";" )
		endif
	
	endfor
	
	groupList = SortList( groupList, ";", 2 )
	
	NMGroupsClear( prefixFolder = prefixFolder, updateNM = 0 )
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	for ( gcnt = 0 ; gcnt < ItemsInList( groupList ) ; gcnt += 1 )
		
		groupSeqStr = StringFromList( gcnt, groupList )
		group = str2num( groupSeqStr )
		groupName = NMGroupsName( group )
		
		for ( ccnt = 0 ; ccnt < numChannels; ccnt += 1 )
		
			wList = ""
		
			for ( wcnt = 0 ; wcnt < numpnts( wtemp ) ; wcnt += 1 )
			
				if ( wtemp[ wcnt ] == group )
					wName = NMChanWaveName( ccnt, wcnt, prefixFolder = prefixFolder )
					wList += wName + ";"
				endif
				
			endfor
			
			NMSetsWaveListRemove( wList, groupName, ccnt, prefixFolder = prefixFolder )
			NMSetsWaveListAdd( wList, groupName, ccnt, prefixFolder = prefixFolder )
			
			for ( wcnt = 0 ; wcnt < ItemsInList( wList ) ; wcnt += 1 )
				wName = StringFromList( wcnt, wList )
				z_GroupSetWaveNote( wName, group )
			endfor
		
		endfor
	
	endfor
	
	return 0
	
End // NMGroupsWaveToLists

Function ChanOverlayClear( channel )
	Variable channel // ( -1 ) for current channel ( -2 ) for all channels
	
	Variable wcnt, ccnt, cbgn, cend
	String gName, wname, xName, wList, cdf
	
	Variable numChannels = NMNumChannels()
	
	if ( channel == -1 )
		cbgn = CurrentNMChannel()
		cend = cbgn
	elseif ( channel == -2 )
		cbgn = 0
		cend = numChannels - 1
	//elseif ( ( channel >= 0 ) && ( channel < numChannels ) )
	elseif ( channel >= 0 )
		cbgn = channel
		cend = channel
	else
		//return NM2Error( 10, "channel", num2str( channel ) )
		return 0 // nothing to do
	endif
	
	for ( ccnt = cbgn; ccnt <= cend; ccnt += 1 )
	
		wname = ChanDisplayWave( ccnt )
		xName = ChanDisplayWaveName( 0, ccnt, 0 )
		gName = ChanGraphName( ccnt )
		cdf = ChanDF( ccnt )
		
		if ( WinType( gName ) == 1 )
			
			wList = TraceNameList( gName,";",1 )
			wList = RemoveFromList( xName, wList )
			
			for ( wcnt = 0; wcnt < ItemsInList( wList ); wcnt += 1 )
				RemoveFromGraph /W=$gName/Z $StringFromList( wcnt, wList )
			endfor
		
		endif
		
		if ( strlen( cdf ) > 0 )
			SetNMvar( cdf + "OverlayCount", 0 )
		endif
		
	endfor
	
	return 0

End // ChanOverlayClear

Function NMDragGraphUtility( gName, select )
	String gName
	String select // "clear" or "remove" or "update"
	
	Variable wcnt
	String wList, yName, yNamePath, type, wPrefix
	
	if ( WinType( gName ) != 1 )
		return 0
	endif
	
	wList = TraceNameList( gName, ";", 1 )
	
	if ( ItemsInList( wList ) == 0 )
		return 0
	endif
	
	for ( wcnt = 0 ; wcnt < ItemsInList( wList ) ; wcnt += 1 )
	
		yName = StringFromList( wcnt, wList )
		yNamePath = NMDF+yName
		
		type = NMNoteStrByKey( yNamePath, "Type" )
		wPrefix = NMNoteStrByKey( yNamePath, "Wave Prefix" )
		
		if ( StringMatch( type, "Drag Wave Y" ) == 0 )
			continue
		endif
		
		strswitch( select )
		
			case "clear":
				if ( strlen( wPrefix ) > 0 )
					NMDragClear( wPrefix )
				endif
				break
				
			case "remove":
				RemoveFromGraph /Z/W=$gName $yName
				break
				
			case "update":
				if ( strlen( wPrefix ) > 0 )
					NMDragUpdate( wPrefix )
				endif
				break
				
		endswitch
	
	endfor
	
	return 0
	
End // NMDragGraphUtility

Function NMSetsListsToWavesAll( [ prefixFolder ] )
	String prefixFolder
	
	String setList
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif

	setList = NMSetsList( prefixFolder = prefixFolder )

	NMSetsListsToWaves( setList, prefixFolder = prefixFolder )
	
	NMSetsWavesTag( setList, prefixFolder = prefixFolder )
	
	return 0

End // NMSetsListsToWavesAll

Function /S NMSetsPanelList()

	return NMSetsWavesList( CurrentNMPrefixFolder(), 0 )

End // NMSetsPanelList

Function /S NMSetsPanelSelectMenu()

	String setList
	
	String prefixFolder = CurrentNMPrefixFolder()
	
	if ( strlen( prefixFolder ) > 0 )
	
		setList = NMSetsPanelList()
		
		if ( ItemsInList( setList ) > 0 )
			return " ;" + setList
		endif
	
	endif

	return " "

End // NMSetsPanelSelectMenu

Static Function z_Disable( dis, disableAll )
	Variable dis, disableAll
	
	if ( ( dis == 2 ) || ( disableAll == 2 ) )
		return 2
	endif
	
	return 0
	
End // z_Disable

Static Function /S z_Grp2StrBlank( str )
	String str
	
	Variable icnt
	
	String minStr = "                        "
	String outStr = ""
	
	for ( icnt = 0 ; icnt < strlen( str ) ; icnt += 1 )
		outStr += "  "
	endfor
	
	if ( strlen( outStr ) < strlen( minStr ) )
		return minStr
	endif
	
	return outStr
	
End // z_Grp2StrBlank

Function /S NMSetsPanelArgMenu()

	String setList
	
	String prefixFolder = CurrentNMPrefixFolder()
	
	if ( strlen( prefixFolder ) > 0 )
	
		setList = NMSetsPanelList() + NMGroupsList( 1, prefixFolder = prefixFolder )
	
		if ( ItemsInList( setList ) > 0 )
			return " ;" + setList
		endif
		
	endif

	return " "

End // NMSetsPanelArgMenu

Function NMSetsPanelTable( addWavesToTable )
	Variable addWavesToTable // ( 0 ) no ( 1 ) yes
	
	Variable numChannels, ccnt, wcnt, x1 = 350, x2 = 1500, y1 = 0, y2 = 1000
	String wlist, wName, txt, setList
	
	String currentPrefix = CurrentNMWavePrefix()
	
	String tname = NMSetsPanelName + "Table"
	String child = NMSetsPanelName + "#" + tname
	
	String prefixFolder = CurrentNMPrefixFolder()
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	if ( WinType( NMSetsPanelName ) != 7 )
		return -1
	endif
	
	String setName = StrVarOrDefault( prefixFolder+"SetsDefineSelect", "" )
	String arg1 = StrVarOrDefault( prefixFolder+"SetsFxnArg1", "" )
	String arg2 = StrVarOrDefault( prefixFolder+"SetsFxnArg2", "" )
	
	String clist = ChildWindowList( NMSetsPanelName )
	
	if ( WhichListItem( tname, clist ) < 0 )
	
		Edit /Host=$NMSetsPanelName/N=$tname/W=( x1, y1, x2, y2 )
		
	else
	
		setList = NMWindowWaveList( child, 1, 1 )
	
		for ( wcnt = 0; wcnt < ItemsInList( setList ); wcnt += 1 )
			RemoveFromTable /W=$child $StringFromList( wcnt, setList )
		endfor
	
	endif
	
	ModifyTable /W=$child title( Point )= currentPrefix
	
	if ( !addWavesToTable )
		return 0
	endif
	
	setList = AddListItem( setName, "", ";", inf )
	
	if ( StringMatch( arg1[0,4], "Group" ) )
		arg1 = "" // "Group"
	elseif ( StringMatch( arg2[0,4], "Group" ) )
		arg2 = "" // "Group"
	endif
	
	if ( strlen( arg1 ) > 0 )
		setList = AddListItem( arg1, setList, ";", inf )
	endif
	
	if ( strlen( arg2 ) > 0 )
		setList = AddListItem( arg2, setList, ";", inf )
	endif
	
	for ( wcnt = 0 ; wcnt < ItemsInList( setList ) ; wcnt += 1 )
	
		setName = prefixfolder + StringFromList( wcnt, setList )
		
		if ( WaveExists( $setName ) )
			AppendToTable /W=$child $setName
		endif
	
	endfor
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
	
		wName = NMChanWaveListName( ccnt, prefixFolder = prefixFolder )
		
		if ( WaveExists( $wName ) )
			AppendToTable /W=$child $wName
			ModifyTable /W=$child width($wName)=100
		endif
	
	endfor
	
	return 0

End // NMSetsPanelTable

Function NMGroupsPanelDefaults()

	Variable icnt
	
	String prefixFolder = CurrentNMPrefixFolder()
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	Variable numWaves = NumVarOrDefault( prefixFolder+"NumWaves", 0 )
	
	Variable numGroups = NMGroupsNumCount( prefixFolder = prefixFolder )
	Variable firstGroup = NMGroupsFirst( "", prefixFolder = prefixFolder )
	Variable fromWave = NumVarOrDefault( prefixFolder+"GroupsFromWave", Nan )
	Variable toWave = NumVarOrDefault( prefixFolder+"GroupsToWave", Nan )
	Variable blocks = NumVarOrDefault( prefixFolder+"GroupsWaveBlocks", Nan )
	
	String groupSeq = StrVarOrDefault( prefixFolder+"GroupsSeqStr", "" )
	
	if ( ( numtype( numGroups ) > 0 ) || ( numGroups < 1 ) )
		numGroups = NMGroupsNumDefault( prefixFolder = prefixFolder )
		groupSeq = ""
	endif
	
	if ( ( numtype( firstGroup ) > 0 ) || ( firstGroup < 0 ) )
		firstGroup = NMFirstGroup
		groupSeq = ""
	endif
	
	if ( ( numtype( fromWave ) > 0 ) || ( fromWave < 0 ) || ( fromWave >= numWaves ) )
		fromWave = 0
	endif
	
	if ( ( numtype( toWave ) > 0 ) || ( toWave < 0 ) || ( toWave >= numWaves ) )
		toWave = numWaves - 1
	endif
	
	if ( ( numtype( blocks ) > 0 ) || ( blocks < 1 ) )
		blocks = 1
	endif
	
	if ( strlen( groupSeq ) == 0 )
		groupSeq = num2istr( firstGroup ) + " - " + num2istr( firstGroup + numGroups - 1 )
		//group = RangeToSequenceStr( group )
	endif
	
	SetNMvar( prefixFolder+"NumGrps", numGroups )
	SetNMvar( prefixFolder+"FirstGrp", firstGroup )
	SetNMvar( prefixFolder+"GroupsFromWave", fromWave )
	SetNMvar( prefixFolder+"GroupsToWave", toWave )
	SetNMvar( prefixFolder+"GroupsWaveBlocks", blocks )
	
	SetNMstr( prefixFolder+"GroupsSeqStr", groupSeq )
	
	CheckNMvar( NMDF+"GroupsPanelAutoSave", 1 )

End // NMGroupsPanelDefaults

Function NMGroupsPanelTable( addWavesToTable )
	Variable addWavesToTable // ( 0 ) no ( 1 ) yes
	
	Variable numChannels, ccnt, wcnt, x1 = 300, x2 = 1500, y1 = 0, y2 = 1000
	String wname, wList
	
	String prefixFolder = CurrentNMPrefixFolder()
	String currentPrefix = CurrentNMWavePrefix()
	
	String gwName = NMGroupsWaveName( prefixFolder = prefixFolder )
	
	String tname = NMGroupsPanelName + "Table"
	String child = NMGroupsPanelName + "#" + tname
	
	if ( WinType( NMGroupsPanelName ) != 7 )
		return -1
	endif
	
	String clist = ChildWindowList( NMGroupsPanelName )
	
	if ( WhichListItem( tname, clist ) < 0 )
	
		Edit /Host=$NMGroupsPanelName/N=$tname/W=( x1, y1, x2, y2 )
		
	else
		
		wList = NMWindowWaveList( child, 1, 1 )
	
		for ( wcnt = 0; wcnt < ItemsInList( wList ); wcnt += 1 )
			RemoveFromTable /W=$child $StringFromList( wcnt, wList )
		endfor
		
	endif
	
	ModifyTable /W=$child title( Point )= currentPrefix
	
	if ( addWavesToTable == 0 )
		return 0
	endif
		
	if ( WaveExists( $gwName ) == 1 )
		AppendToTable /W=$child $gwName
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
	
		wname = NMChanWaveListName( ccnt, prefixFolder = prefixFolder )
		
		if ( WaveExists( $wname ) == 1 )
			AppendToTable /W=$child $wname
			ModifyTable /W=$child width($wname)=100
		endif
	
	endfor
	
	return 0

End // NMGroupsPanelTable

Function /S NMGroupsNumStrWaveNote( wName )
	String wName
	
	Variable icnt, group
	
	if ( WaveExists( $wName ) == 0 )
		return ""
	endif
	
	//return StringByKey( "Group", NMNoteString( wName ) )
	
	String noteStr = note( $wName )
	
	noteStr = noteStr[0, 1000] // make smaller
	
	icnt = strsearch( noteStr, "Group:", 0, 2 )
	
	if ( icnt < 0 )
		return ""
	endif
	
	group = GetNumFromStr( noteStr, "Group:" )
	
	return num2str( group )
	
End // NMGroupsNumStrWaveNote

Function /S ControlList( wName, mtchStr, listSepStr )
	String wName // window string
	String mtchStr // string match item
	String listSepStr // string list seperator
	
	String olist = ""
	String cList = ControlNameList( wName )
		
	if ( ItemsInList( cList ) == 0 )
		return ""
	endif
	
	Variable icnt
	String cname
	
	for ( icnt = 0; icnt < ItemsInList( cList ); icnt += 1 )
		cname = StringFromList( icnt, cList )
		if ( StringMatch( cname, mtchStr ) == 1 )
			olist = AddListItem( cname, olist, listSepStr, inf )
		endif
	endfor

	return olist
	
End // ControlList

Function EnableTabList( windowName, cList, enable )
	String windowName
	String cList // control name list
	Variable enable // 1 - enable; 0 - disable
	
	Variable icnt
	String cname
	
	if ( ItemsInList( cList ) == 0 )
		return 0
	endif
	
	for ( icnt = 0; icnt < ItemsInList( cList ); icnt += 1 )
	
		cname = StringFromList( icnt, cList )
		
		ControlInfo /W=$windowName $cname
		
		switch( abs( V_Flag ) )
			case 1:
				Button $cname, disable=( !enable )
				break
			case 2:
				//CheckBox $cname, disable=( !enable )
				break
			case 3:
				//PopupMenu $cname, disable=( !enable )
				break
			case 4:
				ValDisplay $cname, disable=( !enable )
				break
			case 5:
				SetVariable $cname, disable=( !enable )
				break
			case 6:
				Chart $cname, disable=( !enable )
				break
			case 7:
				Slider $cname, disable=( !enable )
				break
			case 8:
				TabControl $cname, disable=( !enable )
				break
			case 9:
				GroupBox $cname, disable=( !enable )
				break
			case 10:
				TitleBox $cname, disable=( !enable )
				break
			case 11:
				ListBox $cname, disable=( !enable )
				break
		endswitch
		
	endfor
	
	return 0
	
End // EnableTabList

Function /S TabPrefix( tabNum, tabList ) // extract tab prefix name of controls and globals from the tab list
	Variable tabNum // tab number
	String tabList // list of tab names
	
	String name
	
	name = StringFromList( tabNum, tabList, ";" )
	name = StringFromList( 1, name, "," )
	
	return name

End // TabPrefix

Function /S NMFolderMenu()

	String txt = "---;" + NMPopupFolderList
	
	String folderList = NMDataFolderListLong()
	
	String logList = NMLogFolderListLong()
	
	if (strlen( folderList) > 0)
		
		folderList = "---;" + folderList
	
	endif
	
	if (strlen(logList) > 0)
		
		logList = "---;" + logList
	
	endif

	return "Folder Select;" + folderList + logList + txt

End // NMFolderMenu

Function /S NMGroupsMenu()

	Variable numWaves, numStimWaves, numGrps

	String menuList
	
	Variable on = NMVarGet( "GroupsOn" )
	
	String prefixFolder = CurrentNMPrefixFolder()
	String subStimFolder = SubStimDF()

	if ( strlen( prefixFolder ) == 0 )
	
		menuList = "Groups;"
	
	else
	
		numGrps = NMGroupsNumCount()
		
		menuList = "Groups;---;Define;Convert;"
		
		if ( numGrps > 0 )
			menuList += "Clear;"
		endif
		
		menuList += "Edit Panel;"
	
	endif
		
	if ( on == 1 )
		menuList = AddListItem("Off", menuList, ";", inf)
	else
		menuList = AddListItem("On", menuList, ";", inf)
	endif
	
	if (strlen(subStimFolder) > 0)
	
		numWaves = NumVarOrDefault(prefixFolder+"NumWaves", 0)
	
		numStimWaves = NumVarOrDefault(subStimFolder+"NumStimWaves", numWaves)
		
		menuList += ";---;Groups=" + num2istr(numStimWaves) + ";Blocks="+num2istr(numStimWaves)
		
	endif
	
	return menuList

End // NMGroupsMenu

Function /S NMChanSelectStr( [ prefixFolder ] )
	String prefixFolder
	
	Variable numChannels, currentChan
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	if ( ( numChannels > 1 ) && NMChanSelectedAll( prefixFolder = prefixFolder ) )
		return "All"
	endif
	
	currentChan = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
	
	return ChanNum2Char( currentChan )

End // NMChanSelectStr

Function /S NMChanSelectMenu()

	String allStr = "All;"
	
	Variable numChannels = NMNumChannels()
	
	String prefixFolder = CurrentNMPrefixFolder()
	
	if ( ( strlen( prefixFolder ) == 0 ) || ( numChannels == 0 ) )
		return " "
	endif
	
	strswitch( CurrentNMTabName() )
		case "Event":
		//case "Fit":
		case "EPSC":
			allStr = "" // "All" is not allowed on these tabs
			break
	
	endswitch
	
	if ( numChannels == 1 )
		return "A;"
	elseif ( numChannels < 3 )
		return "Channel Select;---;" + allStr + NMChanList( "CHAR" )
	endif
	
	return "Channel Select;---;" + allStr + NMChanList( "CHAR" ) + "---;Edit List;"

End // NMChanSelectMenu

Function /S NMWaveSelectMenu()

	Variable numSets, numGrps, numAdded
	String grpList = "", otherList = "", outList
	
	String prefixFolder = CurrentNMPrefixFolder()
	
	if ( ( strlen( prefixFolder ) == 0 ) || ( NMNumWaves() < 1 ) )
		return " "
	endif
	
	Variable grpsOn = NMVarGet( "GroupsOn" )
	
	String waveSelect = NMWaveSelectGet()
	String setList = NMSetsList()
	String addedList = NMStrGet( "WaveSelectAdded" )
	
	numSets = ItemsInList( setList )
	numAdded = ItemsInList( addedList )
	
	if ( numSets > 1 )
		otherList = AddListItem( "All Sets", otherList, ";", inf )
		otherList = NMAddToList( "Set x Set;", otherList, ";" )
	endif
	
	if ( grpsOn == 1 )
		grpList = NMGroupsList( 1 )
		numGrps = ItemsInList( grpList )
	endif
	
	if ( numGrps > 0 )
	
		otherList = AddListItem("---", otherList, ";", 0 )
		
		if ( numGrps > 1 )
			otherList = NMAddToList( "All Groups;", otherList, ";" )
		endif
		
		if ( numSets > 0 )
			otherList = NMAddToList( "Set x Group;", otherList, ";" )
		endif
		
		grpList = AddListItem("---", grpList, ";", 0 )
		
	endif
	
	if ( numAdded > 0 )
		addedList = AddListItem("---", addedList, ";", 0 )
		addedList = AddListItem( "Clear List", addedList, ";", inf )
	endif
	
	otherList = AddListItem( "This Wave", otherList, ";", inf )
	
	outList = "Wave Select;---;All;" + setList + otherList + addedList + grpList
	
	//outList = AddWaveListCheckMark( waveSelect, outList, ";", 1 )
	
	return outList

End // NMWaveSelectMenu

Function NMWinCascade( windowName ) // set cascade graph size and placement
	String windowName
	
	Variable wx1, wy1, width, height
	
	Variable xPixels = NMComputerPixelsX()
	Variable yPixels = NMComputerPixelsY()
	
	Variable cascade = NMVarGet( "Cascade" )
	
	String computer = NMComputerType()
	
	if ( WinType( windowName ) == 0 )
		return -1
	endif
	
	strswitch( computer )
		case "pc":
			wx1 = 75 +15*cascade
			wy1 = 75 +15*cascade
			width = 425
			height = 275
			break
		default:
			wx1 = 50 + 28*cascade
			wy1 = 50 + 28*cascade
			width = 525
			height = 340
	endswitch
	
	//Print wx1, wy1, ( wx1+width ), ( wy1+height )
	
	MoveWindow /W=$windowName wx1, wy1, ( wx1+width ), ( wy1+height )
	
	if ( ( wx1 > xPixels * 0.4 ) || ( wy1 > yPixels * 0.4 ) )
		cascade = 0 // reset Cascade counter
	else
		cascade += 1 // increment Cascade counter
	endif
	
	SetNMvar( NMDF+"Cascade", floor( cascade ) )

End // NMWinCascade

Function /S TMQuotes( istring )
	String istring

	return "\"" + istring + "\""

End // TMQuotes

Function KillWindows( matchStr )
	String matchStr // window name to match ( ie. "ST_*", or "*" for all )
	
	Variable wcnt, killwin
	String wName, wList
	
	wList = WinList( matchStr, ";","WIN:3" )
	
	if ( ItemsInList( wList ) == 0 )
		return 0
	endif
	
	for ( wcnt = 0; wcnt < ItemsInList( wList ); wcnt += 1 )
		wName = StringFromList( wcnt, wList )
		DoWindow /K $wName // close graphs and tables
	endfor

End // KillWindows

Function ExecuteUserTabKill( tabName, select )
	String tabName
	String select
	
	String fxnParams = "( " + TMQuotes( select ) + " )"
	String fxn = tabName + "TabKill"
	
	if ( exists( fxn ) != 6 )
		fxn = "Kill" + tabName
	endif
	
	Execute /Z fxn + fxnParams
	
	if ( V_Flag == 0 )
		return 0
	else
		return -1 // no function execution
	endif
	
End // ExecuteUserTabKill

Function CheckNMConfigDF( fname )
	String fname // config folder name
	
	String df = ConfigDF( "" ) // main config folder
	String sub = df + fname + ":" // subfolder to check
	
	Variable makeDF
	
	CheckNMPackageDF( "Configurations" )
	makeDF = CheckNMPackageDF( "Configurations:"+fname )
	
	SetNMstr( df+"FileType", "NMConfig" )
	SetNMstr( sub+"FileType", "NMConfig" )
	
	return makeDF // ( 0 ) already made ( 1 ) yes, made
	
End // CheckNMConfigDF

Function NMConfigListReset( fname )
	String fname // config folder name

	String df = ConfigDF( fname )
	
	SetNMstr( df + "C_VarList", "" )
	SetNMstr( df + "C_WaveList", "" )

End // NMConfigListReset

Function NMConfigCleanUp( fname )
	String fname // config folder name
	
	Variable icnt, changeDF
	String vList, vName
	
	String cdf = ConfigDF( fname )
	String pdf = NMPackageDF( fname )
	String saveDF = GetDataFolder( 1 )
	
	if ( DataFolderExists( cdf ) == 0 )
		return -1
	endif
	
	String varList = StrVarOrDefault( cdf + "C_VarList", "" )
	String wList = StrVarOrDefault( cdf + "C_WaveList", "" )
	
	SetDataFolder $cdf
	
	vList = VariableList( "*", ";", 4 )
	vList = RemoveFromList( varList, vList )
	
	for ( icnt = 0 ; icnt < ItemsInList( vList ) ; icnt += 1 )
	
		vName = StringFromList( icnt, vList )
		
		KillVariables /Z $cdf + vName
		
		KillVariables /Z $cdf + "D_" + vName
		KillVariables /Z $cdf + "T_" + vName
		
		if ( DataFolderExists( pdf ) == 1 )
			KillVariables /Z $pdf + vName
		endif
		
		//Print "Killed variable " + cdf + vName
		
	endfor
	
	vList = StringList( "*", ";" )
	vList = RemoveFromList( varList, vList )
	vList = RemoveFromList( "FileType", vList )
	
	for ( icnt = 0 ; icnt < ItemsInList( vList ) ; icnt += 1 )
	
		vName = StringFromList( icnt, vList )
		
		if ( StringMatch( vName[ 0, 1 ], "C_" ) == 1 )
			continue
		endif
		
		if ( StringMatch( vName[ 0, 1 ], "D_" ) == 1 )
			continue
		endif
		
		if ( StringMatch( vName[ 0, 1 ], "T_" ) == 1 )
			continue
		endif
		
		KillStrings /Z $cdf + vName
		
		KillVariables /Z $cdf + "D_" + vName
		KillVariables /Z $cdf + "T_" + vName
		
		if ( DataFolderExists( pdf ) == 1 )
			KillStrings /Z $pdf + vName
		endif
		
		//Print "Killed string " + cdf + vName
		
	endfor
	
	vList = WaveList( "*", ";", "" )
	vList = RemoveFromList( wList, vList )
	
	for ( icnt = 0 ; icnt < ItemsInList( vList ) ; icnt += 1 )
	
		vName = StringFromList( icnt, vList )
		
		KillWaves /Z $cdf + vName
		
		if ( DataFolderExists( pdf ) == 1 )
			KillWaves /Z $pdf + vName
		endif
		
		//Print "Killed wave " + cdf + vName
		
	endfor

	SetDataFolder $saveDf

	return 0
	
End // NMConfigCleanUp

Function /S NMConfigList()

	String flist = FolderObjectList( ConfigDF( "" ), 4 )
	
	if ( FindListItem( "NeuroMatic", flist ) >= 0 )
		flist = RemoveFromList( "NeuroMatic", flist )
		flist = "NeuroMatic;" + flist
	endif
	
	return flist
	
End // NMConfigList

Function /S FolderObjectList( df, objType )
	String df // data folder path ( "" ) for current
	Variable objType // ( 1 ) waves ( 2 ) variables ( 3 ) strings ( 4 ) data folders ( 5 ) numeric wave ( 6 ) text wave
	
	Variable ocnt, otype, add
	String objName, olist = ""
	
	switch( objType )
		case 1:
		case 2:
		case 3:
		case 4:
			otype = objType
			break
		case 5:
		case 6:
			otype = 1
			break
		default:
			return ""
	endswitch
	
	do
	
		add = 0
		objName = GetIndexedObjName( df, oType, ocnt )
		
		if ( strlen( objName ) == 0 )
			break
		endif
		
		switch( objType )
			case 1:
			case 2:
			case 3:
			case 4:
				add = 1
				break
			case 5:
				if ( WaveType( $( df+objName ) ) > 0 )
					add = 1
				endif
				break
			case 6:
				if ( WaveType( $( df+objName ) ) == 0 )
					add = 1
				endif
				break
		endswitch
		
		if ( add == 1 )
			olist = AddListItem( objName, olist, ";", inf )
		endif
		
		ocnt += 1
		
	while( 1 )
	
	return olist

End // FolderObjectList

Function /S NMFileBinOpen( dialogue, extStr, parentFolder, path, fileList, changeFolder, [ nmPrefix ] )
	Variable dialogue // ( 0 ) no ( 1 ) yes
	String extStr // file extension; ( "" ) for FileBinExt ( ? ) for any
	String parentFolder // data folder path where to create data folders; ( "" ) for "root:"
	String path // symbolic path name
	String fileList // string list of external file paths
	Variable changeFolder // change to this folder after opening file ( 0 ) no ( 1 ) yes
	Variable nmPrefix // ( 0 ) no ( 1 ) yes, force "nm" prefix when creating NM data folder

	Variable fcnt, numFiles, bintype
	String file, folder, folderPath, folderName, folderList = "", vList = "", df
	
	dialogue = BinaryCheck( dialogue )
	
	if ( dialogue )
		fileList = NMFileOpenDialogue( path, extStr )
	endif
	
	numFiles = ItemsInList( fileList )

	if ( numFiles == 0 )
		return "" // nothing to open
	endif
	
	if ( strlen( parentFolder ) == 0 )
		parentFolder = "root:"
	endif
	
	if ( strlen( parentFolder ) > 0 )
		parentFolder = LastPathColon( parentFolder, 1 )
	endif
	
	for ( fcnt = 0; fcnt < numFiles; fcnt += 1 )
	
		if ( NMProgress( fcnt, numFiles, "Opening " + num2str( numFiles ) + " Data Files..." ) == 1 )
			break
		endif
		
		file = StringFromList( fcnt, fileList )
		
		if ( !dialogue && !FileExistsAndNonZero( file ) )
			continue
		endif
		
		folderName = NMFolderNameCreate( file, nmPrefix = nmPrefix )
		folderPath = parentFolder + folderName
	
		if ( DataFolderExists( folderPath ) )
		
			DoAlert 2, "FileBinOpen Alert: folder " + NMQuotes( folderName ) + " already exists. Do you want to replace it?"
			
			if ( V_Flag == 1 )
				NMFolderClose( folderPath )
			elseif ( V_Flag == 3 )
				return ""
			endif
			
		endif
		
		if ( strsearch( file, ".pxp", 0 ) > 0 )
		
			if ( strlen( S_NMB_FileType( file ) ) > 0 )
				bintype = 0
			else
				bintype = 1
			endif
		
		elseif ( ReadPclampFormat( file ) > 0 )
		
			bintype = 2
			
		elseif ( ReadAxographFormat( file ) > 0 )
		
			bintype = 3
			
		else
		
			NMDoAlert( "FileBinOpen Error: file format not recognized for " + file )
			
			continue
			
		endif
		
		vList = ""
		folder = ""
		
		switch( bintype )
			
			case 0: // old NM binary format
			
				vList = NMCmdStr( folderPath, vList )
				vList = NMCmdStr( file, vList )
				vList = NMCmdStr( "1111", vList )
				vList = NMCmdNum( changeFolder, vList )
				NMCmdHistory( "NMBinOpen", vList )
			
				folder = NMBinOpen( folderPath, file, "1111", changeFolder, nmPrefix = nmPrefix )
			
				break
				
			case 1: // Igor binary
				
				vList = NMCmdStr( folderPath, vList )
				vList = NMCmdStr( file, vList )
				vList = NMCmdNum( changeFolder, vList )
				NMCmdHistory( "IgorBinOpen", vList )
			
				folder = IgorBinOpen( folderPath, file, changeFolder, nmPrefix = nmPrefix )
				
				break
				
			case 2: // Pclamp
			
				vList = NMCmdStr( folderPath, vList )
				vList = NMCmdStr( file, vList )
				NMCmdHistory( "NMImportFile", vList )
				
				NMImportFile( folderPath, file, nmPrefix = nmPrefix )
				
				break
			
			case 3: // Axograph
			
				vList = NMCmdStr( folderPath, vList )
				vList = NMCmdStr( file, vList )
				NMCmdHistory( "NMImportFile", vList )
				
				NMImportFile( folderPath, file, nmPrefix = nmPrefix )
				
				break
		
		endswitch
		
		folderList = AddListItem( folder, folderList, ";", inf )
		
	endfor
	
	if ( ItemsInList( folderList ) == 1 )
		return StringFromList( 0, folderList )
	else
		return folderList
	endif
	
End // NMFileBinOpen

Function /S SubStimName( df ) // sub folder stim name
	String df // data folder or ( "" ) for current

	return StringFromList( 0, NMFolderList( df, "NMStim" ) )

End // SubStimName

Function /S NMNoteStrByKey( wname, key )
	String wname // wave name with note
	String key // "thresh", "xbgn", "xend", etc...

	if ( WaveExists( $wname ) == 0 )
		return ""
	endif
	
	return StringByKey( key, NMNoteString( wname ) )

End // NMNoteStrByKey

Function /S NMNoteCheck( noteStr )
	String noteStr
	
	noteStr = ReplaceString( ":", noteStr, "," )
	
	return noteStr
	
End // NMNoteCheck

Function NMNoteType( wName, wType, xLabel, yLabel, wNote )
	String wName, wType, xLabel, yLabel, wNote
	
	if ( WaveExists( $wName ) == 0 )
		return -1
	endif
	
	Note /K $wName
	Note $wName, "Source:" + GetPathName( wName, 0 )
	
	if ( strlen( wType ) > 0 )
		Note $wName, "Type:" + wType
	endif
	
	if ( strlen( yLabel ) > 0 )
		Note $wName, "YLabel:" + yLabel
	endif
	
	if ( strlen( xLabel ) > 0 )
		Note $wName, "XLabel:" + xLabel
	endif
	
	if ( strlen( wNote ) > 0 )
		Note $wName, wNote
	endif
	
	return 0

End // NMNoteType

Function NMPrefixFolderRename( prefixFolder )
	String prefixFolder
	
	String fname, parent, newName
	
	prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	if ( ( exists( prefixFolder+"CurrentChan" ) != 2 ) || ( exists( prefixFolder+"CurrentWave" ) != 2 ) )
		return -1 // wrong type of subfolder
	endif
	
	fname = GetPathName( prefixFolder, 0 )
	parent = GetPathName( prefixFolder, 1 )
	
	if ( ( strlen( NMPrefixSubfolderPrefix ) > 0 ) && ( strsearch( fname, NMPrefixSubfolderPrefix, 0, 2 ) < 0 ) )
				
		newName = NMPrefixSubfolderPrefix + fname
		
		if ( !DataFolderExists( parent + newName ) )
			RenameDataFolder $RemoveEnding( prefixFolder, ":" ), $newName
		endif
				
	endif

End // NMPrefixFolderRename

Function NMPrefixFolderLock( prefixFolder, lock )
	String prefixFolder
	Variable lock // ( 0 ) no ( 1 ) yes
	
	String wName
	
	Variable lockFolders = 0 // NOT USED ANYMORE
	
	if ( lock && !lockFolders )
		return -1
	endif
	
	prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	wName = prefixFolder + "Lock"
				
	if ( lock )
	
		if ( !WaveExists( $wName ) )
			Make /O/N=1 $wName
			Note $wName, "this NM wave is locked to prevent accidental deletion of NM data folders. Control click in the Data Browser to unlock this wave."
			SetWaveLock 1, $wName
		endif
		
	elseif ( WaveExists( $wName ) )

		SetWaveLock 0, $wName
		
	endif

End // NMPrefixFolderLock

Function /S NMSetsWavesList( folder, fullPath )
	String folder
	Variable fullPath // ( 0 ) no, just wave name ( 1 ) yes, directory + wave name
	
	Variable scnt
	String setName, type, outList = ""
	
	if ( strlen( folder ) == 0 )
		return ""
	endif
	
	Variable numWaves = NumVarOrDefault( folder+"NumWaves", 0 )
	
	String optionsStr = NMWaveListOptions( numWaves, 0 )
	
	String setList = NMFolderWaveList( folder, "*", ";", optionsStr, 0 )
	
	String remList = WaveList( "*TShift*", ";", "" )
	
	remList += "WavSelect;ChanSelect;Group;FileScaleFactors;MyScaleFactors;"
	
	setList = SortList( setList, ";", 16 )
	
	if ( WhichListItem( "SetX", setList ) >= 0 )
		setList = RemoveFromList( "SetX", setList, ";" )
		setList = AddListItem( "SetX", setList, ";", inf )
	endif
	
	setList = RemoveFromList( remList, setList, ";" )

	if ( ItemsInList( setList ) < 1 )
		return ""
	endif
	
	for ( scnt = 0; scnt < ItemsInList( setList); scnt += 1 )
	
		setName = StringFromList( scnt, setList )
		
		type = NMNoteStrByKey( folder+setName, "Type" )
		
		if ( StringMatch( type, "NMSet" ) || StringMatch( setName[0,2], "Set" ) )
		
			if ( fullPath )
				outList = AddListItem( folder + setName, outList, ";", inf )
			else
				outList = AddListItem( setName, outList, ";", inf )
			endif
			
		endif
		
	endfor
	
	return outList
	
End // NMSetsWavesList

Function NMComputerPixelsY()

	Variable v1, v2, yPixels = 800

	String s0 = IgorInfo( 0 )
	
	s0 = StringByKey( "SCREEN1", s0, ":" )
	
	sscanf s0, "%*[ DEPTH= ]%d%*[ ,RECT= ]%d%*[ , ]%d%*[ , ]%d%*[ , ]%d", v1, v1, v1, v1, v2
	
	if ( ( numtype( v2 ) == 0 ) && ( v2 > yPixels ) )
		yPixels = v2
	endif
	
	return yPixels

End // NMComputerPixelsY

Function KillControls( wName, matchStr )
	String wName // window name
	String matchStr // control name to match ( ie. "ST_*", or "*" for all )
	
	Variable icnt
	
	DoWindow /F $wName
	
	String cList = ControlList( wName, matchStr, ";" )
	
	if ( ItemsInList( cList ) == 0 )
		return 0
	endif
	
	for ( icnt = 0; icnt < ItemsInList( cList ); icnt += 1 )
		KillControl $StringFromList( icnt, cList )
	endfor

End // KillControls

Function CheckNMPackage( package, forceVariableCheck ) // check folder / globals
	String package // package folder name
	Variable forceVariableCheck // ( 0 ) no ( 1 ) yes
	
	String fxn, df = NMPackageDF( package )
	
	Variable made = CheckNMPackageDF( package ) // check folder
	
	if ( ( made == 0 ) && ( forceVariableCheck == 0 ) )
		return 0
	endif
	
	fxn = "NM" + package + "Check" // i.e. "NMStatsCheck()"
	
	if ( exists( fxn ) != 6 )
		fxn = "Check" + package // i.e. "CheckStats()"
	endif
	
	if ( exists( fxn ) == 6 )
		Execute /Z fxn + "()"
	endif
	
	if ( made == 1 )
		NMConfig( package, -1 ) // copy configs to new folder
	else
		NMConfig( package, 1 ) // copy folder vars to configs
	endif
	
	return made
	
End // CheckNMPackage

Function /S NMPrefixFindFirst()

	Variable icnt, jcnt, numChar, varNum, numWaves, foundCommon
	String wName, wList, wavePrefix
	
	Variable numWavesLimit = 10
	Variable numCharLimit = 5

	wList = WaveList( "*", ";", "Text:0" )
	
	numWaves = ItemsInList( wList )
		
	if ( numWaves == 0 )
		return ""
	endif
	
	numWaves = min( numWaves, numWavesLimit )
	
	for ( icnt = 0 ; icnt < numWaves ; icnt += 1 )
	
		wName = StringFromList( icnt, wList )
	
		numChar = strlen( wName )
		
		for ( jcnt = numChar - 1 ; jcnt >= 1 ; jcnt -= 1 )
		
			wavePrefix = wName[ 0, jcnt ]
			
			wList = WaveList( wavePrefix + "*", ";", "Text:0" )
			
			if ( ItemsInList( wList ) > 1 )
				foundCommon = 1
				break
			endif
			
		endfor
		
	endfor
	
	if ( foundCommon == 1 )
	
		icnt = strsearch( wavePrefix, "_", 0 )
		
		if ( icnt > 0 )
			return wavePrefix[ 0, icnt ] // if there is underscore, use string to left as prefix
		else
			return wavePrefix[ 0, numCharLimit - 1 ]
		endif
		
	endif
	
	// found no common prefix, so use prefix of first wave
	
	wavePrefix = StringFromList( 0, wList )
	
	icnt = strsearch( wavePrefix, "_", 0 )
		
	if ( icnt > 0 )
		return wavePrefix[ 0, icnt ]
	else
		return wavePrefix[ 0, numCharLimit - 1 ]
	endif

End // NMPrefixFindFirst

Function /S ChanDisplayWaveName( directory, channel, wavNum )
	Variable directory // ( 0 ) no directory ( 1 ) include directory
	Variable channel // ( -1 ) for current channel
	Variable wavNum
	
	String df = ""
	
	if ( directory )
		df = NMDF
	endif
	
	if ( channel == -1 )
		channel = CurrentNMChannel()
	endif
	
	return df + GetWaveName( "Display", channel , wavNum )
	
End // ChanDisplayWaveName

Function /S NMXwave( [ prefixFolder ] )
	String prefixFolder

	String wName, wList
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	String xName = StrVarOrDefault( prefixFolder + "Xwave", "" )
	
	if ( WaveExists( $xName ) )
		return xName
	endif

	return ""

End // NMXwave

Function RemoveWaveUnits( wName )
	String wName
	
	Variable xstart, dx
	
	if ( WaveExists( $wName ) == 0 )
		return -1
	endif
	
	dx = deltax( $wName )
	xstart = leftx( $wName )
	
	SetScale /P x, xstart, dx, "", $wName
	SetScale y, 0, 0, "", $wName

End // RemoveWaveUnits

Function /S NMChanTransformDF( channel [ prefixFolder ] )
	Variable channel // ( -1 ) for current channel
	String prefixFolder
	
	String cdf
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	if ( channel == -1 )
		channel = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
	endif
	
	cdf = ChanDF( channel, prefixFolder = prefixFolder )
	
	return StrVarOrDefault( NMDF + "ChanTransformDF" + num2istr( channel ), cdf )

End // NMChanTransformDF

Function ChanFilterNumGet( channel, [ prefixFolder ] )
	Variable channel // ( -1 ) for current channel
	String prefixFolder
	
	String cdf
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return 0
	endif
	
	if ( channel == -1 )
		channel = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
	endif
	
	cdf = ChanFilterDF( channel )
	
	if ( strlen( cdf ) == 0 )
		return 0
	endif
	
	return NumVarOrDefault( cdf + "SmoothN", 0 ) // filter number saved as old smooth number
	
End // ChanFilterNumGet

Function /S ChanFilterAlgGet( channel [ prefixFolder ] ) // get channel smooth/filter alrgorithm
	Variable channel // ( -1 ) for current channel
	String prefixFolder
	
	String alg, cdf
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	if ( channel == -1 )
		channel = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
	endif
	
	cdf = ChanFilterDF( channel, prefixFolder = prefixFolder )
	
	if ( strlen( cdf ) == 0 )
		return ""
	endif

	alg = StrVarOrDefault( cdf + "SmoothA", "" )
	
	strswitch( alg )
	
		case "binomial": // smooth
		case "boxcar": // smooth
			break
			
		case "low-pass": // Filter IIR
		case "high-pass": // Filter IIR
			break
			
		default:
			alg = ""
			
	endswitch
	
	return alg

End // ChanFilterAlgGet

Static Function /S z_RunningAvgWaveList( channel, waveNum, numAvgWaves, wrapAround [ prefixFolder ] )
	Variable channel // ( -1 ) for current channel
	Variable waveNum
	Variable numAvgWaves
	Variable wrapAround
	String prefixFolder
	
	Variable wcnt, wcnt2, wbgn, wend, numWaves
	String cdf, wName, avgList = ""
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	if ( channel == -1 )
		channel = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
	endif
	
	numWaves = NumVarOrDefault( prefixFolder + "NumWaves", 0 )
	
	cdf = NMChanTransformDF( channel, prefixFolder = prefixFolder )
	
	if ( strlen( cdf ) == 0 )
		return ""
	endif
	
	if ( numAvgWaves < 0 )
		numAvgWaves = NumVarOrDefault( cdf + "RunAvg_NumWaves", 1 )
	endif
	
	if ( wrapAround < 0 )
		wrapAround = NumVarOrDefault( cdf + "RunAvg_Wrap", 1 )
	endif
	
	if ( numAvgWaves < 2 )
		return ""
	endif
	
	if ( waveNum < 0 )
		waveNum = NumVarOrDefault( prefixFolder + "CurrentWave", 0 )
	endif
	
	if ( waveNum >= numWaves )
		return ""
	endif
	
	wbgn = waveNum - floor( ( numAvgWaves - 1 ) / 2 )
	wend = wbgn + numAvgWaves - 1
	
	for ( wcnt = wbgn ; wcnt <= wend ; wcnt += 1 )
	
		if ( wcnt < 0 )
		
			if ( wrapAround )
				wcnt2 = numWaves + wcnt
			else
				continue
			endif
			
		elseif ( wcnt >= numWaves )
		
			if ( wrapAround )
				wcnt2 = wcnt - numWaves
			else
				continue
			endif
			
		else
		
			wcnt2 = wcnt
		
		endif
		
		wName = NMChanWaveName( channel, wcnt2 )
		
		if ( WaveExists( $wName ) )
			avgList = NMAddToList( wName, avgList, ";" )
		endif
		
	endfor
	
	return avgList
	
End // z_RunningAvgWaveList

Function /S SmoothWaves( smthAlg, AvgN, wList )
	String smthAlg // smoothing algorithm
	Variable AvgN // smooth number ( see 'Smooth' help )
	String wList // wave list ( seperator ";" )
	
	Variable wcnt, numWaves
	String wName, outList = "", badList = wList
	String thisfxn = GetRTStackInfo( 1 )
	
	if ( ( numtype( avgN ) > 0 ) || ( avgN < 1 ) )
		return NM2ErrorStr( 10, "avgN", num2istr( avgN ) )
	endif
	
	if ( ( StringMatch( smthAlg, "polynomial" ) == 1 ) && ( ( avgN < 5 ) || ( avgN > 25 ) ) )
		return NM2ErrorStr( 90, "number of points must be greater than 5 and less than 25 for polynomial smoothing.", "" )
	endif
	
	numWaves = ItemsInList( wList )
	
	if ( numWaves == 0 )
		return ""
	endif
	
	for ( wcnt = 0; wcnt < numWaves; wcnt += 1 )
	
		if ( NMProgressTimer( wcnt, numWaves, "Smoothing Waves..." ) == 1 )
			break // cancel wave loop
		endif
	
		wName = StringFromList( wcnt, wList )
		
		if ( NMUtilityWaveTest( wName ) < 0 )
			continue
		endif
		
		Note $wName, "Func:" + thisfxn
		
		strswitch( smthAlg )
			case "binomial":
				Smooth AvgN, $wName
				Note $wName, "Smth Alg:binomial;Smth Num:" + num2istr( AvgN ) + ";"
				break
			case "boxcar":
				Smooth /B AvgN, $wName
				Note $wName, "Smth Alg:boxcar;Smth Num:" + num2istr( AvgN ) + ";"
				break
			case "polynomial":
				Smooth /S=2 AvgN, $wName
				Note $wName, "Smth Alg:polynomial;Smth Num:" + num2istr( AvgN ) + ";"
				break
			default:
				NMProgressKill()
				return NM2ErrorStr( 20, "smthAlg", smthAlg )
		endswitch
		
		outList = AddListItem( wName, outList, ";", inf )
		badList = RemoveFromList( wName, badList )
	
	endfor
	
	NMUtilityAlert( thisfxn, badList )
	
	return outList

End // SmoothWaves

Function /S FilterIIRwaves( alg, freqFraction, notchQ, wList )
	String alg // "low-pass","high-pass" or "notch"
	Variable freqFraction, notchQ // see Igor FilterIIR function ( freqFraction = fHigh or fLow or fNotch )
	String wList // wave list ( seperator ";" )
	
	Variable wcnt, numWaves
	String wName, outList = "", badList = wList
	String thisfxn = "FilterIIRwaves"
	
	if ( ( numtype( freqFraction ) > 0 ) || ( freqFraction <= 0 ) || ( freqFraction > 0.5) )
		return NM2ErrorStr( 10, "freqFraction", num2str( freqFraction ) )
	endif
	
	strswitch( alg )
	
		case "low-pass":
		case "high-pass":
			break
	
		case "notch":
			
			if ( ( numtype( notchQ ) > 0 ) || ( notchQ <= 1 ) )
				return NM2ErrorStr( 10, "notchQ", num2str( notchQ ) )
			endif
			
			break
			
		default:
			return NM2ErrorStr( 20, "alg", alg )
			
	endswitch
	
	numWaves = ItemsInList( wList )
	
	if ( numWaves == 0 )
		return ""
	endif
	
	for ( wcnt = 0; wcnt < numWaves; wcnt += 1 )
	
		if ( NMProgressTimer( wcnt, numWaves, "IIR Filtering Waves..." ) == 1 )
			break // cancel wave loop
		endif
	
		wName = StringFromList( wcnt, wList )
		
		if ( NMUtilityWaveTest( wName ) < 0 )
			continue
		endif
		
		Note $wName, "Func:" + thisfxn
		
		strswitch( alg )
			case "low-pass":
				FilterIIR /LO=( freqFraction ) $wName
				Note $wName, "FilterIIR Alg:" + alg + ";freq:" + num2str( freqFraction ) + ";"
				break
			case "high-pass":
				FilterIIR /HI=( freqFraction ) $wName
				Note $wName, "FilterIIR Alg:" + alg + ";freq:" + num2str( freqFraction ) + ";"
				break
			case "notch":
				FilterIIR /N={freqFraction,notchQ} $wName
				Note $wName, "FilterIIR Alg:" + alg + ";fNotch:" + num2str( freqFraction ) + ";notchQ:" + num2str( notchQ ) + ";"
				break
			default:
				NMProgressKill()
				return ""
		endswitch
		
		outList = AddListItem( wName, outList, ";", inf )
		badList = RemoveFromList( wName, badList )
	
	endfor
	
	NMUtilityAlert( thisfxn, badList )
	
	return outList

End // FilterIIRwaves

Function /S NormalizeWaves( fxn1, xbgn1, xend1, fxn2, xbgn2, xend2, wList )
	String fxn1 // function to compute min value, "Avg" or "Min" or "minavg"
	Variable xbgn1, xend1 // window to compute fxn1, use ( -inf, inf ) for all
	String fxn2 // function to compute max value, "Avg" or "Max" or "maxavg"
	Variable xbgn2, xend2 // window to compute fxn2, use ( -inf, inf ) for all
	String wList // wave list ( seperator ";" )
	
	Variable wcnt, numWaves, amp1, amp2, scaleNum, t1, t2
	String wName, saveNote, outList = "", badList = wList
	String thisfxn = GetRTStackInfo( 1 )
	
	Variable win1 = GetNumFromStr( fxn1, "MinAvg" )
	Variable win2 = GetNumFromStr( fxn2, "MaxAvg" )
	
	if ( numtype( win1 ) == 0 )
		fxn1 = "MinAvg"
	endif
	
	strswitch( fxn1 )
		case "Avg":
		case "Min":
		case "MinAvg":
			break
		default:
			if ( numtype( win1 ) > 0 )
				return NM2ErrorStr( 20, "fxn1", fxn1 )
			endif
	endswitch
	
	if ( numtype( xbgn1 ) == 2 )
		return NM2ErrorStr( 10, "xbgn1", num2str( xbgn1 ) )
	endif
	
	if ( numtype( xend1 ) == 2 )
		return NM2ErrorStr( 10, "xend1", num2str( xend1 ) )
	endif
	
	if ( numtype( win2 ) == 0 )
		fxn2 = "MaxAvg"
	endif
	
	strswitch( fxn2 )
		case "Avg":
		case "Max":
		case "MaxAvg":
			break
		default:
			if ( numtype( win2 ) > 0 )
				return NM2ErrorStr( 20, "fxn2", fxn2 )
			endif
	endswitch
	
	if ( numtype( xbgn2 ) == 2 )
		return NM2ErrorStr( 10, "xbgn2", num2str( xbgn2 ) )
	endif
	
	if ( numtype( xend2 ) == 2 )
		return NM2ErrorStr( 10, "xend2", num2str( xend2 ) )
	endif
	
	numWaves = ItemsInList( wList )
	
	if ( numWaves == 0 )
		return ""
	endif
	
	for ( wcnt = 0; wcnt < numWaves; wcnt += 1 )
	
		if ( NMProgressTimer( wcnt, numWaves, "Normalizing Waves..." ) == 1 )
			break // cancel wave loop
		endif
	
		wName = StringFromList( wcnt, wList )
		
		if ( NMUtilityWaveTest( wName ) < 0 )
			continue
		endif
		
		Wave wtemp = $wName
		
		//lftx = leftx( wtemp )
		//dx = deltax( wtemp )
		//saveNote = note( wtemp )
		
		amp1 = NaN
		amp2 = NaN
		
		strswitch( fxn1 )
		
			case "Avg":
				amp1 = mean( wtemp, xbgn1, xend1 )
				break
				
			case "Min":
				amp1 = WaveMin( wtemp, xbgn1, xend1 )
				break
				
			case "MinAvg":
			
				WaveStats /Q/R=(xbgn1, xend1) wtemp
				
				if ( numtype( V_minloc ) == 0 )
				
					t1 = V_minloc - win1 / 2
					t2 = V_minloc + win1 / 2
					
					WaveStats /Q/R=( t1, t2 ) wtemp
					
					amp1 = V_avg
					
				endif
				
				break
				
		endswitch
		
		if ( numtype( amp1 ) > 0 )
			NMHistory( thisfxn + " encountered bad amp1 value, skipped wave: " + wName )
			continue
		endif
		
		strswitch( fxn2 )
		
			case "Avg":
				amp2 = mean( wtemp, xbgn2, xend2 )
				break
				
			case "Max":
				amp2 = WaveMax( wtemp, xbgn2, xend2 )
				break
				
			case "MaxAvg":
			
				WaveStats /Q/R=(xbgn2, xend2) wtemp
				
				if ( numtype( V_maxloc ) == 0 )
				
					t1 = V_maxloc - win2 / 2
					t2 = V_maxloc + win2 / 2
					
					WaveStats /Q/R=( t1, t2 ) wtemp
					
					amp2 = V_avg
					
				endif
				
				break
				
		endswitch
		
		if ( numtype( amp2 ) > 0 )
			NMHistory( thisfxn + " encountered bad amp2 value, skipped wave: " + wName )
			continue
		endif
		
		scaleNum = 1 / ( amp2 - amp1 )
		
		if ( ( scaleNum == 0 ) || ( numtype( scaleNum ) > 0 ) )
			NMHistory( thisfxn + " encountered bad scaleNum value, skipped wave: " + wName )
			continue
		else
			MatrixOp /O wtemp = scaleNum * ( wtemp - amp1 )
			//Setscale /P x lftx, dx, wtemp
		endif
		
		outList = AddListItem( wName, outList, ";", inf )
		badList = RemoveFromList( wName, badList )
		
		//Note wtemp, saveNote
		Note wtemp, "Func:" + thisfxn
		Note wtemp, "Norm Fxn1:" + fxn1 + ";Norm Xbgn1:" + num2str( xbgn1 ) + ";Norm Xend1:" + num2str( xend1 )
		Note wtemp, "Norm Fxn2:" + fxn2 + ";Norm Xbgn2:" + num2str( xbgn2 ) + ";Norm Xend2:" + num2str( xend2 )
	
	endfor
	
	NMUtilityAlert( thisfxn, badList )
	
	return outList

End // NormalizeWaves

Function /S DFOFWaves( bbgn, bend, wList )
	Variable bbgn, bend // baseline window begin / end, use ( -inf, inf ) for all
	String wList // wave list ( seperator ";" )
	
	Variable wcnt, numWaves, value, amp, base, scale = 1
	String wName, saveNote, outList = "", badList = wList
	String thisfxn = GetRTStackInfo( 1 )
	
	if ( numtype( bbgn ) == 2 )
		return NM2ErrorStr( 10, "bbgn", num2str( bbgn ) )
	endif
	
	if ( numtype( bend ) == 2 )
		return NM2ErrorStr( 10, "bend", num2str( bend ) )
	endif
	
	numWaves = ItemsInList( wList )
	
	if ( numWaves == 0 )
		return ""
	endif
	
	for ( wcnt = 0; wcnt < numWaves; wcnt += 1 )
	
		if ( NMProgressTimer( wcnt, numWaves, "Scaling Waves to dF/Fo..." ) == 1 )
			break // cancel wave loop
		endif
	
		wName = StringFromList( wcnt, wList )
		
		if ( NMUtilityWaveTest( wName ) < 0 )
			continue
		endif
		
		Wave wtemp = $wName
		
		base = mean( wtemp, bbgn, bend )
		
		//lftx = leftx( wtemp )
		//dx = deltax( wtemp )
		//saveNote = note( wtemp )
		
		if ( ( numtype( base ) > 0 ) || ( base == 0 ) )
			NMHistory( "dF/Fo bad baseline value ( " + num2str( base ) + " ), skipped wave:" + wName )
			continue
		else
			MatrixOp /O wtemp = ( wtemp - base ) / base
			//Setscale /P x lftx, dx, wtemp
		endif
		
		outList = AddListItem( wName, outList, ";", inf )
		badList = RemoveFromList( wName, badList )
		
		//Note wtemp, saveNote
		Note wtemp, "Func:" + thisfxn
		Note wtemp, "dFoF Bsln Value:" + num2str( base ) + ";dFoF BaseBgn:" + num2str( bbgn ) + ";dFoF BaseEnd:" + num2str( bend ) + ";"
	
	endfor
	
	NMUtilityAlert( thisfxn, badList )
	
	return outList

End // DFOFWaves

Function /S BaselineWaves( method, xbgn, xend, wList )
	Variable method // ( 1 ) subtract wave's individual mean, ( 2 ) subtract mean of all waves
	Variable xbgn, xend // x-axis window begin and end, use ( -inf, inf ) for all
	String wList // wave list ( seperator ";" )
	
	Variable wcnt, numWaves, mn, sd, cnt
	String wName, saveNote, mnsd, outList = "", badList = wList
	String thisfxn = GetRTStackInfo( 1 )
	
	//String wPrefix = "MN_Bsln_" + NMWaveSelectStr()
	//String outName = NextWaveName( wPrefix, CurrentNMChan(), 1 )
	
	if ( numtype( xbgn ) > 0 )
		xbgn = -inf
	endif
	
	if ( numtype( xend ) > 0 )
		xend = inf
	endif
	
	switch( method )
	
		case 1:
			break
			
		case 2: // subtract mean of all waves
	
			mnsd = MeanStdv( xbgn, xend, wList ) // compute mean and stdv of waves
			
			mn = str2num( StringByKey( "mean", mnsd, "=" ) )
			sd = str2num( StringByKey( "stdv", mnsd, "=" ) )
			cnt = str2num( StringByKey( "count", mnsd, "=" ) )
		 
			DoAlert 1, "Baseline mean = " + num2str( mn ) + " ± " + num2str( sd ) + ". Subtract mean from selected waves?"
		
			if ( V_Flag != 1 )
				return "" // cancel
			endif
			
			break
		
		default:
			return NM2ErrorStr( 10, "method", num2istr( method ) )
	
	endswitch
	
	numWaves = ItemsInList( wList )
	
	if ( numWaves == 0 )
		return ""
	endif
	
	for ( wcnt = 0; wcnt < numWaves; wcnt += 1 )
	
		if ( NMProgressTimer( wcnt, numWaves, "Subtracting Baseline from Waves..." ) == 1 )
			break // cancel wave loop
		endif
	
		wName = StringFromList( wcnt, wList )
	
		if ( NMUtilityWaveTest( wName ) < 0 )
			continue
		endif
	
		Wave wtemp = $wName
		
		//startx = leftx( wtemp )
		//dx = deltax( wtemp )
		//saveNote = note( wtemp )
		
		if ( method == 1 )
			mn = mean( wtemp, xbgn, xend )
		endif
		
		MatrixOp /O wtemp = wtemp - mn
		//Setscale /P x startx, dx, wtemp
		
		//Note wtemp, saveNote
		Note wtemp, "Func:" + thisfxn
		Note wtemp, "Bsln Value:" + num2str( mn ) + ";Bsln Xbgn:" + num2str( xbgn ) + ";Bsln Xend:" + num2str( xend ) + ";"
		
		outList = AddListItem( wName, outList, ";", inf )
		badList = RemoveFromList( wName, badList )
	
	endfor
	
	NMUtilityAlert( thisfxn, badList )
	
	return outList

End // BaselineWaves

Function /S NMWavesStatistics( wList, useChannelTransforms, ignoreNANs, truncateToCommonXScale, interpToSameXScale, saveMatrix )
	String wList // wave list ( seperator ";" )
	Variable useChannelTransforms // pass channel number to use its Transform and smoothing/filtering settings, or (-1) for none 
	Variable ignoreNANs // ignore NANs in computation ( 0 ) no ( 1 ) yes
	Variable truncateToCommonXScale // ( 0 ) no, if necessary, waves are expanded to fit all x-axis min and max ( 1 ) yes, waves are truncated to a common x-axis
	Variable interpToSameXScale // interpolate waves to the same x-scale (0) no (1) yes ( generally one should use interp ONLY if waves have different sample intervals )
	Variable saveMatrix // save list of waves as a 2D matrix called U_2Dmatrix ( 0 ) no ( 1 ) yes
	
	Variable minNumOfDataPoints = NumVarOrDefault("U_minNumOfDataPoints", 2) // min number of data points to include in average

	Variable wcnt, icnt, p1, p2, ipnts, imax, val, error, numWaves = ItemsInList( wList )
	Variable precision = 4
	String xl, yl, txt, wName, tName, oList, infoStr, thisfxn = GetRTStackInfo( 1 )
	
	String waveprefix = CurrentNMWavePrefix()
	
	Variable nchan = NMNumChannels()
	
	Variable npnts = NMNumPntsGet( "numpnts", wList )
	Variable dx = NMDeltaXGet( "deltax", wList )
	Variable mindx = NMDeltaXGet( "minDeltax", wList )
	
	Variable lftx = NMLeftXGet( "leftx", wList )
	Variable minLeftx = NMLeftXGet( "minLeftx", wList )
	Variable maxLeftx = NMLeftXGet( "maxLeftx", wList )
	
	Variable rghtx = NMRightXGet( "rightx", wList )
	Variable minRightx = NMRightXGet( "minRightx", wList )
	Variable maxRightx = NMRightXGet( "maxRightx", wList )
	
	if ( numWaves < 2 )
		return NM2ErrorStr( 90, "number of input waves is less than 2", "" )
	endif
	
	if ( WavesExist( wList ) == 0 )
		return NM2ErrorStr( 90, "one or more input waves do not exist", "" )
	endif
	
	if ( ( numtype( dx ) != 0 ) && ( interpToSameXScale != 1 ) )
		return NM2ErrorStr( 90, "waves do not have the same sample interval. Use interpToSameXScale=1 instead.", "" )
	endif
	
	if ( ( truncateToCommonXScale == 1 ) && ( maxLeftx >= minRightx) )
		return NM2ErrorStr( 90, "waves have no common x-axis for AND computation.", "" )
	endif
	
	if ( ( truncateToCommonXScale == 0 ) && ( minLeftx >= maxRightx) )
		return NM2ErrorStr( 90, "waves have no common x-axis for OR computation", "" )
	endif
	
	Make /O/N=1 U_WaveTemp1, U_WaveTemp2, U_WaveTemp3
	
	if ( ( numtype( lftx ) == 0 ) && ( numtype( npnts ) == 0 ) && ( numtype( dx ) == 0 ) )
	
		Make /D/O/N=( npnts ) U_Sum = 0
		Make /D/O/N=( npnts ) U_SumSqr = 0
		Make /D/O/N=( npnts ) U_Pnts = 0
	
		for ( wcnt = 0 ; wcnt < numWaves; wcnt += 1 )
		
			if ( NMProgressTimer( wcnt, numWaves, "Computing Wave Statistics..." ) == 1 )
				break // cancel wave loop
			endif
		
			wName = StringFromList( wcnt, wList )
			
			infoStr = WaveInfo( $wName, 0 )
			
			if ( NumberByKey( "NUMTYPE", infoStr ) == 2 )
				precision = 2
			endif
			
			if ( wcnt == 0 )
				tName = "U_WaveTemp1"
			else
				tName = "U_WaveTemp2"
			endif
			
			if ( ( useChannelTransforms >= 0 ) && ( useChannelTransforms < nchan ) )
				ChanWaveMake( useChannelTransforms, wName, tName ) 
			else
				Duplicate /O $wName $tName
			endif
			
			Wave wtemp = $tName
			
			MatrixOp /O U_PntsTemp = replace( wtemp, 0, 1 ) // to avoid 0/0 division
			MatrixOp /O U_PntsTemp = U_PntsTemp / U_PntsTemp
			
			if ( ignoreNANs == 1 )
				MatrixOp /O U_Sum = U_Sum + replaceNaNs(wtemp, 0)
				MatrixOp /O U_SumSqr = U_SumSqr + replaceNaNs(powR(wtemp, 2), 0)
				MatrixOp /O U_Pnts = U_Pnts + replaceNaNs(U_PntsTemp, 0)
			else
				MatrixOp /O U_Sum = U_Sum + wtemp
				MatrixOp /O U_SumSqr = U_SumSqr + powR( wtemp, 2 )
				MatrixOp /O U_Pnts = U_Pnts + U_PntsTemp
			endif
			
			if ( ( saveMatrix == 1 ) && ( wcnt > 0 ) )
			
				if ( DimSize( U_WaveTemp1, 0 ) != numpnts( U_WaveTemp2 ) )
					error = 1
					break // something went wrong creating matrix
				endif
			
				Concatenate /O { U_WaveTemp1, U_WaveTemp2 }, U_2Dmatrix
			
				Duplicate /O U_2Dmatrix U_WaveTemp1
			
			endif
			
		endfor
		
	elseif ( interpToSameXScale == 1 )
	
		if ( truncateToCommonXScale == 1 ) // contract
		
			npnts = floor( ( minRightx - maxLeftx ) / mindx )
			
			Make /O/N=( npnts ) U_wScaleX = NaN // create new x-axis for interpolation
			Setscale /P x maxLeftx, mindx, U_wScaleX
			
		else // expand
		
			npnts = floor( ( maxRightx - minLeftx ) / mindx )
			
			Make /O/N=( npnts ) U_wScaleX = NaN // create new x-axis for interpolation
			Setscale /P x minLeftx, mindx, U_wScaleX
			
		endif
		
		lftx = leftx(U_wScaleX)
		dx = mindx
		
		Make /D/O/N=( npnts ) U_Sum = 0
		Make /D/O/N=( npnts ) U_SumSqr = 0
		Make /D/O/N=( npnts ) U_Pnts = 0
		
		for ( wcnt = 0 ; wcnt < numWaves; wcnt += 1 )
		
			if ( NMProgressTimer( wcnt, numWaves, "Computing Wave Statistics..." ) == 1 )
				break // cancel wave loop
			endif
		
			wName = StringFromList( wcnt, wList )
			
			infoStr = WaveInfo( $wName, 0 )
			
			if ( NumberByKey( "NUMTYPE", infoStr ) == 2 )
				precision = 2
			endif
			
			if ( wcnt == 0 )
				tName = "U_WaveTemp1"
			else
				tName = "U_WaveTemp2"
			endif
			
			if ( ( useChannelTransforms >= 0 ) && ( useChannelTransforms < nchan ) )
				ChanWaveMake( useChannelTransforms, wName, tName ) 
			else
				Duplicate /O $wName $tName
			endif
		
			InterpolateWaves( 2, 2, "U_wScaleX", tName )
			
			Wave wtemp = $tName
			
			MatrixOp /O U_PntsTemp = replace(wtemp, 0, 1) // to avoid 0/0 division
			MatrixOp /O U_PntsTemp = U_PntsTemp/U_PntsTemp
			
			if ( ignoreNANs == 1 )
				MatrixOp /O U_Sum = U_Sum + replaceNaNs(wtemp, 0)
				MatrixOp /O U_SumSqr = U_SumSqr + replaceNaNs(powR(wtemp, 2), 0)
				MatrixOp /O U_Pnts = U_Pnts + replaceNaNs(U_PntsTemp, 0)
			else
				MatrixOp /O U_Sum = U_Sum + wtemp
				MatrixOp /O U_SumSqr = U_SumSqr + powR(wtemp, 2)
				MatrixOp /O U_Pnts = U_Pnts + U_PntsTemp
			endif
			
			if ( ( saveMatrix == 1 ) && ( wcnt > 0 ) )
			
				if ( DimSize( U_WaveTemp1, 0 ) != numpnts( U_WaveTemp2 ) )
					error = 1
					break // something went wrong creating matrix
				endif
			
				Concatenate /O { U_WaveTemp1, U_WaveTemp2 }, U_2Dmatrix
			
				Duplicate /O U_2Dmatrix U_WaveTemp1
			
			endif
	
		endfor
		
	elseif ( truncateToCommonXScale == 1 ) // AND waves (trim loose ends)
		
		npnts = floor( ( minRightx - maxLeftx ) / dx )
		
		lftx = maxLeftx
		
		Make /D/O/N=( npnts ) U_Sum = 0
		Make /D/O/N=( npnts ) U_SumSqr = 0
		Make /D/O/N=( npnts ) U_Pnts = 0
	
		for ( wcnt = 0 ; wcnt < numWaves; wcnt += 1 )
		
			if ( NMProgressTimer( wcnt, numWaves, "Computing Wave Statistics..." ) == 1 )
				break // cancel wave loop
			endif
		
			wName = StringFromList( wcnt, wList )
			
			infoStr = WaveInfo( $wName, 0 )
			
			if ( NumberByKey( "NUMTYPE", infoStr ) == 2 )
				precision = 2
			endif
		
			if ( wcnt == 0 )
				tName = "U_WaveTemp1"
			else
				tName = "U_WaveTemp2"
			endif
			
			p1 = x2pnt( $wName, maxLeftx )
			p2 = p1 + npnts - 1
			
			if ( ( useChannelTransforms >= 0 ) && ( useChannelTransforms < nchan ) )
				ChanWaveMake( useChannelTransforms, wName, "U_WaveTemp3" )
				Duplicate /O/R=[p1, p2] U_WaveTemp3 $tName
			else
				Duplicate /O/R=[p1, p2] $wName $tName
			endif
			
			Wave wtemp = $tName
			
			MatrixOp /O U_PntsTemp = replace(wtemp, 0, 1) // to avoid 0/0 division
			MatrixOp /O U_PntsTemp = U_PntsTemp/U_PntsTemp
			
			if ( ignoreNANs == 1 )
				MatrixOp /O U_Sum = U_Sum + replaceNaNs(wtemp, 0)
				MatrixOp /O U_SumSqr = U_SumSqr + replaceNaNs(powR(wtemp, 2), 0)
				MatrixOp /O U_Pnts = U_Pnts + replaceNaNs(U_PntsTemp, 0)
			else
				MatrixOp /O U_Sum = U_Sum + wtemp
				MatrixOp /O U_SumSqr = U_SumSqr + powR(wtemp, 2)
				MatrixOp /O U_Pnts = U_Pnts + U_PntsTemp
			endif
			
			if ( ( saveMatrix == 1 ) && ( wcnt > 0 ) )
			
				if ( DimSize( U_WaveTemp1, 0 ) != numpnts( U_WaveTemp2 ) )
					error = 1
					break // something went wrong creating matrix
				endif
				
				Concatenate /O { U_WaveTemp1, U_WaveTemp2 }, U_2Dmatrix
			
				Duplicate /O U_2Dmatrix U_WaveTemp1
			
			endif
		
		endfor
		
	else // OR waves (pad loose ends)
	
		npnts = 1 + floor( ( maxRightx - minLeftx ) / dx )
		
		lftx = minLeftx
		
		for ( wcnt = 0 ; wcnt < numWaves; wcnt += 1 )
		
			wName = StringFromList( wcnt, wList )
			
			val = x2pnt( $wName, maxLeftx )
			
			if ( val > imax )
				imax = val
			endif
		
		endfor
		
		Make /D/O/N=( npnts ) U_Sum = 0
		Make /D/O/N=( npnts ) U_SumSqr = 0
		Make /D/O/N=( npnts ) U_Pnts = 0
		
		for ( wcnt = 0 ; wcnt < numWaves; wcnt += 1 )
		
			if ( NMProgressTimer( wcnt, numWaves, "Computing Wave Statistics..." ) == 1 )
				break // cancel wave loop
			endif
		
			wName = StringFromList( wcnt, wList )
			
			infoStr = WaveInfo( $wName, 0 )
			
			if ( NumberByKey( "NUMTYPE", infoStr ) == 2 )
				precision = 2
			endif
			
			val = x2pnt( $wName, maxLeftx )
			
			ipnts = round( ( leftx($wName) - minLeftx ) / dx )
			
			ipnts = imax - val
			
			if ( wcnt == 0 )
				tName = "U_WaveTemp1"
			else
				tName = "U_WaveTemp2"
			endif
			
			if ( ( useChannelTransforms >= 0 ) && ( useChannelTransforms < nchan ) )
				ChanWaveMake( useChannelTransforms, wName, tName ) 
			else
				Duplicate /O $wName $tName
			endif
			
			Duplicate /O $wName, U_wIdentity
		
			U_wIdentity = 1
			
			Wave wtemp = $tName
			
			Redimension /N=( npnts ) wtemp, U_wIdentity // this inserts 0's at end of wave
			
			MatrixOp /O wtemp=wtemp/U_wIdentity // convert new 0's to NAN's
			
			if ( ipnts > 0)
				WaveTransform /O/P={ipnts, NaN} shift wtemp // shift points to align
			endif
			
			MatrixOp /O U_PntsTemp = replace(wtemp, 0, 1) // to avoid 0/0 division
			MatrixOp /O U_PntsTemp = U_PntsTemp/U_PntsTemp
			
			if ( ignoreNANs == 1 )
				MatrixOp /O U_Sum = U_Sum + replaceNaNs(wtemp, 0)
				MatrixOp /O U_SumSqr = U_SumSqr + replaceNaNs(powR(wtemp, 2), 0)
				MatrixOp /O U_Pnts = U_Pnts + replaceNaNs(U_PntsTemp, 0)
			else
				MatrixOp /O U_Sum = U_Sum + wtemp
				MatrixOp /O U_SumSqr = U_SumSqr + powR(wtemp, 2)
				MatrixOp /O U_Pnts = U_Pnts + U_PntsTemp
			endif
			
			if ( ( saveMatrix == 1 ) && ( wcnt > 0 ) )
			
				if ( DimSize( U_WaveTemp1, 0 ) != numpnts( U_WaveTemp2 ) )
					error = 1
					break // something went wrong creating matrix
				endif
			
				Concatenate /O { U_WaveTemp1, U_WaveTemp2 }, U_2Dmatrix
			
				Duplicate /O U_2Dmatrix U_WaveTemp1
			
			endif
			
		endfor
		
	endif
	
	MatrixOp /O U_Pnts2 = U_Pnts * greater( U_Pnts, minNumOfDataPoints - 1 ) // reject rows with not enough data points
	MatrixOp /O U_Pnts2 = U_Pnts2 * ( U_Pnts2 / U_Pnts2 ) // converts 0's to NAN's
	
	MatrixOp /O U_Avg = U_Sum / U_Pnts2
	MatrixOp /O U_Sdv = sqrt( ( U_SumSqr - ( ( powR( U_Sum, 2 ) ) / U_Pnts2 ) ) / ( U_Pnts2 - 1 ) )
	
	if ( error == 1 )
		KillWaves /Z U_Avg, U_Sdv, U_Sum, U_SumSqr, U_Pnts, U_2Dmatrix
	endif
	
	if ( ( error == 1 ) || ( ( saveMatrix == 1 ) && ( DimSize( U_2Dmatrix, 1 ) != numWaves ) ) )
	
		KillWaves /Z U_2Dmatrix
		
		return NM2ErrorStr( 90, "error in creating 2D matrix : wrong dimensions", "" )
		
	endif
	
	if ( precision == 2 )
	
		Make /N=( numpnts( U_Avg ) ) U_Avg_NMWS
		
		U_Avg_NMWS = U_Avg
		
		Duplicate /O U_Avg_NMWS, U_Avg
		
		Make /N=( numpnts( U_Sdv ) ) U_Sdv_NMWS
		
		U_Sdv_NMWS = U_Sdv
		
		Duplicate /O U_Sdv_NMWS, U_Sdv
		
		Make /N=( numpnts( U_Sum ) ) U_Sum_NMWS
		
		U_Sum_NMWS = U_Sum
		
		Duplicate /O U_Sum_NMWS, U_Sum
		
		Make /N=( numpnts( U_SumSqr ) ) U_SumSqr_NMWS
		
		U_SumSqr_NMWS = U_SumSqr
		
		Duplicate /O U_SumSqr_NMWS, U_SumSqr
		
		Make /N=( numpnts( U_Pnts ) ) U_Pnts_NMWS
		
		U_Pnts_NMWS = U_Pnts
		
		Duplicate /O U_Pnts_NMWS, U_Pnts
		
		KillWaves /Z U_Avg_NMWS, U_Sdv_NMWS, U_Sum_NMWS, U_SumSqr_NMWS, U_Pnts_NMWS
	
	endif
	
	if ( WaveExists( U_2Dmatrix ) == 1 )
		Setscale /P x lftx, dx, U_2Dmatrix
	endif
	
	Setscale /P x lftx, dx, U_Avg, U_Sdv, U_Sum, U_SumSqr, U_Pnts
	
	wName = StringFromList( 0, wList )
	
	xl = NMNoteLabel( "x", wName, "" )
	yl = NMNoteLabel( "y", wName, "" )
	
	NMNoteType( "U_Avg", "NMAvg", xl, yl, "Func:" + thisfxn )
	NMNoteType( "U_Sdv", "NMSdv", xl, yl, "Func:" + thisfxn )
	NMNoteType( "U_Sum", "NMSum", xl, yl, "Func:" + thisfxn )
	NMNoteType( "U_SumSqr", "NMSumSqr", xl, yl, "Func:" + thisfxn )
	NMNoteType( "U_Pnts", "NMPnts", xl, yl, "Func:" + thisfxn )
	
	Note U_Avg, "Input Waves:" + num2istr( numWaves )
	Note U_Sdv, "Input Waves:" + num2istr( numWaves )
	Note U_Sum, "Input Waves:" + num2istr( numWaves )
	Note U_SumSqr, "Input Waves:" + num2istr( numWaves )
	Note U_Pnts, "Input Waves:" + num2istr( numWaves )
	
	oList = NMUtilityWaveListShort( wList )
	
	Note U_Avg, "WaveList:" + oList
	Note U_Sdv, "WaveList:" + oList
	Note U_Sum, "WaveList:" + oList
	Note U_SumSqr, "WaveList:" + oList
	Note U_Pnts, "WaveList:" + oList
	
	KillWaves /Z U_WaveTemp1, U_WaveTemp2, U_WaveTemp3, U_wIdentity, U_wScaleX, U_Pnts2, U_PntsTemp
	
	if ( saveMatrix == 1 )
	
		NMNoteType( "U_2Dmatrix", "NM2Dwave", xl, yl, "Func:" + thisfxn )
		Note U_2Dmatrix, "WaveList:" + oList
		
		return "U_Avg;U_Sdv;U_Sum;U_SumSqr;U_Pnts;U_2Dmatrix;"
		
	else
	
		return "U_Avg;U_Sdv;U_Sum;U_SumSqr;U_Pnts;"
		
	endif
	
End // NMWavesStatistics
Function /S NMEventsClip( positiveEvents, eventFindLevel, xwinBeforeEvent, xwinAfterEvent, wList, [  waveOfEventTimes, clipValue ] )
	Variable positiveEvents // ( 0 ) negative events ( 1 ) positive events
	Variable eventFindLevel // see parameter "level" for Igor function FindLevels 
	Variable xwinBeforeEvent // x-axis window to clip before detected event
	Variable xwinAfterEvent // x-axis window to clip after detected event
	String wList // list of wave names
	String waveOfEventTimes // name of wave containing event times, will bypass event detection using FindLevels
	Variable clipValue // clip events with this value, rather than linear interpolation method
	
	Variable numWaves, wcnt, icnt, pcnt, events, eventTime, edge = 1
	Variable tbgn, tend, lx, rx, npnts, pbgn, pend, clip_pnts, m, b
	
	String wName, nstr, outList = "", badList = wList
	String thisfxn = GetRTStackInfo( 1 )
	
	Variable clipMethod = 0 // ( 0 ) linear interpolation ( 1 ) clip with clipValue
	Variable findEvents = 1 // ( 0 ) no, use waveOfEventTimes ( 1 ) yes, use FindLevels
	
	if ( ( ParamIsDefault( waveOfEventTimes ) == 0 ) && ( WaveExists( $waveOfEventTimes ) == 1 ) )
		findEvents = 0
	endif
	
	if ( ParamIsDefault( clipValue ) == 0 )
		clipMethod = 1
	endif
	
	if ( positiveEvents == 0 )
		edge = 2 // negative events
	else
		edge = 1 // positive events
	endif
	
	if ( ( findEvents == 1 ) && ( numtype( eventFindLevel ) > 0 ) )
		return NM2ErrorStr( 10, "eventFindLevel", num2str( eventFindLevel ) )
	endif
	
	if ( numtype( xwinBeforeEvent ) > 0 )
		return NM2ErrorStr( 10, "xwinBeforeEvent", num2str( xwinBeforeEvent ) )
	endif
	
	if ( numtype( xwinAfterEvent ) > 0 )
		return NM2ErrorStr( 10, "xwinAfterEvent", num2str( xwinAfterEvent ) )
	endif
	
	numWaves = ItemsInList( wList )
	
	if ( numWaves == 0 )
		return ""
	endif
	
	xwinBeforeEvent = abs( xwinBeforeEvent )
	xwinAfterEvent = abs( xwinAfterEvent )
	
	for ( wcnt = 0 ; wcnt < numWaves ; wcnt += 1 )
	
		if ( NMProgressTimer( wcnt, numWaves, "Clipping Events... " + num2istr( wcnt ) ) == 1 )
			break // cancel wave loop
		endif
	
		wName = StringFromList( wcnt, wList )
		
		if ( NMUtilityWaveTest( wName ) < 0 )
			continue
		endif
		
		Wave wtemp = $wName
		
		if ( findEvents == 1 )
	
			FindLevels /EDGE=( edge ) /Q wtemp, eventFindLevel
			
			if ( WaveExists( W_FindLevels ) == 0 )
				continue
			endif
			
			Wave etemp = W_FindLevels
			
		else
		
			Wave etemp = $waveOfEventTimes
			
		endif
		
		events = numpnts( etemp )
		
		lx = leftx( wtemp )
		rx = rightx( wtemp )
		npnts = numpnts( wtemp )
		
		for ( icnt = 0 ; icnt < events ; icnt += 1 )
		
			eventTime = etemp[ icnt ]
			
			if ( ( numtype( eventTime ) > 0 ) || ( eventTime < lx ) || ( eventTime > rx ) )
				continue
			endif
			
			tbgn = eventTime - xwinBeforeEvent
			tend = eventTime + xwinAfterEvent
			
			pbgn = x2pnt( wtemp, tbgn )
			pend = x2pnt( wtemp, tend )
			
			if ( clipMethod == 1 )
			
				pbgn = max( pbgn, 0 )
				pend = min( pend, npnts - 1 )
			
				wtemp[ pbgn, pend ] = clipValue
				
				continue
				
			endif
			
			pbgn -= 1 // compute linear interpolation 1 point before and after pbgn and pend
			pend += 1
			
			if ( ( pbgn < 0 ) || ( pend >= numpnts( wtemp ) ) )
				continue // out of range
			endif
			
			m = ( wtemp[ pend ] - wtemp[ pbgn ] ) / ( pend - pbgn )
			b = wtemp[ pbgn ] - m * pbgn
			
			wtemp[ pbgn + 1, pend - 1 ] = m * p + b
		
		endfor
		
		outList = AddListItem( wName, outList, ";", inf )
		badList = RemoveFromList( wName, badList )
		
		Note wtemp, "Func:" + thisfxn
		
		if ( findEvents == 1 )
			nstr = "Clip Events FindLevel:" + num2str( eventFindLevel )
		else
			nstr = "Clipped Event Times:" + waveOfEventTimes
		endif
		
		nstr += ";Clip Before:" + num2str( xwinBeforeEvent ) + ";Clip After:" + num2str( xwinAfterEvent )
		
		if ( clipMethod == 1 )
			nstr += ";Clip Value:" + num2str( clipValue ) + ";"
		else
			 nstr += ";Clip Value:linear interpolation;"
		endif
		
		Note wtemp, nstr
		
	endfor
	
	KillWaves /Z W_FindLevels
	
	NMUtilityAlert( thisfxn, badList )
	
	return outList
	
End // NMEventsClip

Function /S NMNoteLabel( xy, wList, defaultStr ) // quick search for first label in wave list
	String xy // "x" or "y"
	String wList
	String defaultStr
	
	Variable wcnt
	String wName, xyLabel = ""
	
	if ( ItemsInList( wList ) == 0 )
		return defaultStr
	endif
	
	for ( wcnt = 0; wcnt < ItemsInList( wList ); wcnt += 1 )
	
		wName = StringFromList( wcnt, wList )
		xyLabel = NMNoteStrByKey( wName, xy+"Label" )
		
		if ( strlen( xyLabel ) == 0 )
			xyLabel = NMNoteStrByKey( wName, xy+"dim" )
		endif
		
		if ( strlen( xyLabel ) > 0 )
			return xyLabel // returns first finding of label
		endif
	
	endfor
	
	return defaultStr

End // NMNoteLabel

Function /S NMWaveUnits( xy, wName )
	String xy // "x" or "y"
	String wName // wave name
	
	String str, units
		
	if ( WaveExists( $wName ) == 0 )
		return ""
	endif
	
	str = WaveInfo( $wName, 0 )

	if ( StringMatch( xy, "x" ) == 1 )
		units = StringByKey( "XUNITS", str ) // Igor wave x-units
	elseif ( StringMatch( xy, "y" ) == 1 )
		units = StringByKey( "DUNITS", str ) // Igor wave y-units
	else
		units = ""
	endif
	
	if ( strlen( units ) > 0 )
		return units
	endif
	
	if ( StringMatch( xy, "x" ) == 1 )
		
		units = NMNoteStrByKey( wName, "ADCunitsX" ) // NM acquisition units
		
		if ( ( strlen( units ) > 0 ) && ( StringMatch( units[ 0, 3 ] , "msec" ) == 1 ) )
			return units[ 0, 3 ]
		endif
		
		if ( ( strlen( units ) > 0 ) && ( StringMatch( units[ 0, 1] , "ms" ) == 1 ) )
			return units[ 0, 1 ]
		endif
		
		if ( strlen( units ) > 0 )
			return units
		endif
		
		units = NMNoteStrByKey( wName, "XUnits" ) // general NM units
		
		if ( strlen( units ) > 0 )
			return units
		endif
	
	elseif ( StringMatch( xy, "y" ) == 1 )
	
		units = NMNoteStrByKey( wName, "ADCunits" ) // NM acquisition units
		
		if ( strlen( units ) > 0 )
			return units
		endif
		
		units = NMNoteStrByKey( wName, "YUnits" ) // general NM units
		
		if ( strlen( units ) > 0 )
			return units
		endif
	
	endif
	
	// still did not find...
	
	str = NMNoteLabel( xy, wName, "" ) // try general NM xy-label
	
	if ( strlen( str ) > 0 )
	
		units = UnitsFromStr( str )
		
		if ( strlen( units ) > 0 )
			return units
		else
			return str
		endif
		
	endif
	
	return "" // found nothing
	
End // NMWaveUnits

Function /S UnitsFromStr( str )
	String str // string to search
	
	Variable icnt, jcnt
	
	str = UnPadString( str, 0x20 ) // remove trailing spaces if they exist
	
	for ( icnt = strlen( str )-1; icnt >= 0; icnt -= 1 )
	
		if ( StringMatch( str[icnt], ")" ) == 1 )
		
			for ( jcnt = icnt-1; jcnt >= 0; jcnt -= 1 )
				if ( StringMatch( str[jcnt, jcnt], "(" ) == 1 )
					return str[jcnt+1, icnt-1]
				endif
			endfor
			
		endif
		
	endfor
	
	for ( icnt = strlen( str )-1; icnt >= 0; icnt -= 1 )
		
		strswitch( str[icnt, icnt] )
			case " ":
			case ":":
				return str[icnt+1, inf]
		endswitch
		
	endfor
	
	return str
	
End // UnitsFromStr

Function /S ChanFilterProc( channel )
	Variable channel // ( -1 ) for current channel
	
	if ( channel == -1 )
		channel = CurrentNMChannel()
	endif
	
	return StrVarOrDefault( NMDF + "ChanFilterProc" + num2istr( channel ), "NMChanSetVariable" )

End // ChanFilterProc

Function /S NMChanTransformProc( channel )
	Variable channel // ( -1 ) for current channel
	
	if ( channel == -1 )
		channel = CurrentNMChannel()
	endif
	
	return StrVarOrDefault( NMDF + "ChanTransformProc" + num2istr( channel ), "NMChan//CheckBox" )

End // NMChanTransformProc

Function NMProgressCall( fraction, progressStr )
	Variable fraction // fraction of progress ( 0 ) create ( 1 ) kill prog window ( -1 ) create candy ( -2 ) spin
	String progressStr
	
	SetNMstr( NMDF+"ProgressStr", progressStr )
	
	// returns 1 for cancel
	
	if ( numtype( fraction ) > 0 )
		return -1
	endif
	
	switch( NMProgressFlag() )
	
		case 1:
			return NMProgWinXOP( fraction )
			
		case 2:
			return NMProgWin61( fraction, progressStr )
			
	endswitch
	
	return 0

End // NMProgressCall

Function /S NMSetsNameGet( strVarName )
	String strVarName // e.g. "TTX_SetWaveListA"
	
	Variable icnt = strsearch( strVarName, NMSetsListSuffix, 0, 2 )
		
	if ( icnt <= 0 )
		return ""
	endif
		
	return strVarName[ 0, icnt - 1 ] // e.g. "TTX"
	
End // NMSetsNameGet

Function CheckNMwave( wList, nPoints, defaultValue )
	String wList // wave list
	Variable nPoints // ( -1 ) dont care
	Variable defaultValue
	
	return CheckNMwaveOfType( wList, nPoints, defaultValue, "R" )
	
End // CheckNMwave

Function NMGroupsTag( groupList, [ prefixFolder ] )
	String groupList
	String prefixFolder
	
	Variable icnt
	String wName, wnote, prefix
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	prefix = GetPathName( prefixFolder, 0 )
	prefix = ReplaceString( NMPrefixSubfolderPrefix, prefix, "" )
	
	for ( icnt = 0; icnt < ItemsInList( groupList ); icnt += 1 )
	
		wName = StringFromList( icnt, groupList )
		
		if ( WaveExists( $wName ) == 0 )
			continue
		endif
		
		if ( StringMatch( NMNoteStrByKey( wName, "Type" ), "NMGroup" ) == 1 )
			continue
		endif
		
		wnote = "WPrefix:" + prefix
		NMNoteType( wName, "NMGroup", "Wave#", "Group", wnote )
		
		Note $wName, "DEPRECATED: Group waves are no longer utilized by NeuroMatic. Please use Group list string variables instead."
		
	endfor
	
	return 0

End // NMGroupsTag

Function LogNotebook(ldf) // create a log notebook from a log data folder
	String ldf // log data folder
	String name, tabs
	
	ldf = LastPathColon(ldf,1)
	
	Variable ocnt
	String objName, olist, ftype = StrVarOrDefault(LastPathColon(ldf,1)+"FileType", "")
	
	String nbName = LogNotebookName(ldf)
	
	if ((DataFolderExists(ldf) == 0) || (StringMatch(ftype, "NMLog") == 0))
		return 0
	endif
	
	DoWindow /K $nbName
	NewNotebook /K=1/F=0/N=$nbName/W=(0,0,0,0) as "Clamp Notebook : " + GetPathName(ldf,0)
	
	NMWinCascade(nbName)
	
	Notebook $nbName text=("NeuroMatic Clamp Notebook")
	Notebook $nbName text=(NMCR + "FILE:\t\t\t\t\t" + StrVarOrDefault(ldf+"FileName", GetPathName(ldf,0)))
	//Notebook $nbName text=(NMCR + "Created:\t\t\t\t" + StrVarOrDefault(ldf+"FileDate", ""))
	//Notebook $nbName text=(NMCR + "Time:\t\t\t\t" + StrVarOrDefault(ldf+"FileTime", ""))
	//Notebook $nbName text=(NMCR)
	
	olist = LogVarList(ldf, "H_", "string")
	
	for (ocnt = 0; ocnt < ItemsInList(olist); ocnt += 1)
		objName = StringFromList(ocnt, olist)
		name = UpperStr(ReplaceString("H_", objName, "") + ":")
		tabs = LogNotebookTabs(name)
		Notebook $nbName text=(NMCR + name + tabs + StrVarOrDefault(ldf+objName, ""))
	endfor
	
	olist = LogVarList(ldf, "H_", "numeric")
	
	for (ocnt = 0; ocnt < ItemsInList(olist); ocnt += 1)
		objName = StringFromList(ocnt, olist)
		name = UpperStr(ReplaceString("H_", objName, "") + ":")
		tabs = LogNotebookTabs(name)
		Notebook $nbName text=(NMCR + name + tabs + num2str(NumVarOrDefault(ldf+objName, Nan)))
	endfor
	
	olist = LogSubfolderList(ldf)
	
	for (ocnt = 0; ocnt < ItemsInList(olist); ocnt += 1) // loop thru Note subfolders
		objName = StringFromList(ocnt, olist)
		LogNotebookFileVars(LastPathColon(ldf,1) + objName + ":", nbName)
	endfor
	
End // LogNotebook

Function LogTable(ldf) // create a log table from a log data folder
	String ldf // log data folder
	
	ldf = LastPathColon(ldf,1)
	
	Variable ocnt
	String objName, wlist, nlist
	String tName = LogTableName(ldf)
	String ftype = StrVarOrDefault(ldf+"FileType", "")
	
	if (DataFolderExists(ldf) == 0)
		NMDoAlert("Error: data folder " + NMQuotes( ldf ) + " does not appear to exist.")
		return -1
	endif
	
	if (StringMatch(ftype, "NMLog") == 0)
		NMDoAlert("Error: data folder " + NMQuotes( ldf ) + " does not appear to be a NeuroMatic Log folder.")
		return -1
	endif
	
	LogUpdateWaves(ldf)
	
	if (WinType(tName) == 0) // make table
		Edit /K=1/N=$tName/W=(0,0,0,0) as "Clamp Log : " + GetPathName(ldf,0)
		NMWinCascade(tName)
		Execute "ModifyTable title(Point)= " + NMQuotes( "Entry" )
	endif
	
	DoWindow /F $tName
	
	wlist = LogWaveList(ldf, "F")
	
	nlist = ListMatch(wlist, "*note*", ";")
	nlist = SortList(nlist, ";", 16)
	
	wlist = RemoveFromList(nlist, wlist, ";") + nlist // place Note waves after others
	wlist += LogWaveList(ldf, "H") // place Header waves last
	
	for (ocnt = 0; ocnt < ItemsInList(wlist); ocnt += 1)
	
		objName = StringFromList(ocnt, wlist)
		
		RemoveFromTable $(ldf+objName) // remove wave first before appending
		AppendToTable $(ldf+objName)
		
		if (StringMatch(objName[0,3], "Note") == 1)
			Execute "ModifyTable alignment(" + ldf + objName + ")=0"
			Execute "ModifyTable width(" + ldf + objName + ")=150"
		endif
		
	endfor

End // LogTable

Function ChanGraphRemoveWaves( channel )
	Variable channel // ( -1 ) for current channel
	
	Variable wcnt
	String wname, wList, gName
	
	if ( channel == -1 )
		channel = CurrentNMChannel()
	endif
	
	gName = ChanGraphName( channel )
	
	if ( WinType( gName ) != 1 )
		return -1
	endif
	
	wList = TraceNameList( gName, ";", 1 )
	
	for ( wcnt = 0; wcnt < ItemsInlist( wList ); wcnt += 1 )
		wname = StringFromList( wcnt, wList )
		RemoveFromGraph /W=$gName $wname
	endfor
	
	return 0

End // ChanGraphRemoveWaves

Function ChanGraphAppendDisplayWave( channel )
	Variable channel // ( -1 ) for current channel
	
	if ( channel == -1 )
		channel = CurrentNMChannel()
	endif
	
	String cdf = ChanDF( channel )
	String gName = ChanGraphName( channel )
	String wname = ChanDisplayWave( channel )
	String xWave = NMXWave()
	String tcolor = StrVarOrDefault( cdf + "TraceColor", "0,0,0" )
	
	if ( ( strlen( cdf ) == 0 ) || ( WinType( gName ) != 1 ) || !WaveExists( $wname ) )
		return -1
	endif
	
	if ( WaveExists( $xWave ) )
		AppendToGraph /W=$gName $wname vs $xWave
	else
		AppendToGraph /W=$gName $wname
	endif
	
	wname = ParseFilePath( 0, wname, ":", 1, 0 )
	
	Execute /Z "ModifyGraph /W=" + gName + " rgb( " + wname + " )=(" + tcolor + ")"
	
	ModifyGraph /W=$gName marker( $wname )=Marker
	
	ModifyGraph /W=$gName mode( $wName )=NMChanMarkersMode( channel )

End // ChanGraphAppendDisplayWave

Function NMDeprecationNotebook( alert )
	String alert
	
	String nbName = "NM_DeprecationAlerts"

	if ( WinType( nbName ) != 5 )
	
		DoWindow /K $nbName
		NewNotebook /F=0/K=1/N=$nbName/W=( 0,0,0,0 ) as "NM Deprecation Alerts"
		NMWinCascade( nbName )
		
		NoteBook $nbName text = "To find a function, place cursor inside function name, right click and select " + NMQuotes( "Go to..." ) + NMCR
		NoteBook $nbName text = "Turn these deprecation alerts off via the DeprecationAlert flag in NeuroMatic Configurations." + NMCR + NMCR
	
	endif
	
	Notebook $nbName selection = { endOfFile, endOfFile }
	NoteBook $nbName text = alert + NMCR
	
	DoWindow /F $nbName
	
End // NMDeprecationNotebook

Function OldNMSetsWavesToLists( setList, [ prefixFolder ] )
	String setList
	String prefixFolder
	
	Variable scnt, xtype
	String setName
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif

	for ( scnt = 0 ; scnt < ItemsInList( setList ) ; scnt += 1 )
		
		setName = StringFromList( scnt, setList )
		
		if ( !AreNMSets( setName, prefixFolder = prefixFolder ) )
			
			if ( StringMatch( setName, "SetX" ) )
			
				xtype = NMNoteVarByKey( prefixFolder+"SetX", "Excluding" )
			
				if ( xtype == 0 )
					SetNMvar( prefixFolder+"SetXclude", 0 )
				endif
				
			endif
			
			NMSetsWavesToLists( setName, prefixFolder = prefixFolder )
			
		endif
		
		if ( AreNMSets( setName, prefixFolder = prefixFolder ) )
			KillWaves /Z $prefixFolder+setName
		endif
		
	endfor
		
End // OldNMSetsWavesToLists

Function CheckNMSetsExist( setList, [ prefixFolder ] )
	String setList
	String prefixFolder

	Variable scnt
	String setName
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return 0
	endif
	
	for ( scnt = 0 ; scnt < ItemsInList( setList ) ; scnt += 1 )
	
		setName = StringFromList( scnt, setList )
		
		if ( !AreNMSets( setName, prefixFolder = prefixFolder ) )
			NMSetsNew( setName, prefixFolder = prefixFolder, updateNM = 0 )
		endif
		
	endfor
	
	return 0

End // CheckNMSetsExist

Function NMNoteStrReplace( wname, key, replace )
	String wname // wave name with note
	String key // "thresh", "xbgn", "xend", etc...
	String replace // replace string
	
	Variable icnt, jcnt, found, sl = strlen( key )
	String txt
	
	if ( WaveExists( $wname ) == 0 )
		return -1
	endif
	
	txt = note( $wname )
	
	for ( icnt = 0; icnt < strlen( txt ); icnt += 1 )
		if ( StringMatch( txt[ icnt,icnt+sl-1 ], key ) == 1 )
			found = 1
			break
		endif
	endfor
	
	if ( found == 0 )
		Note $wname, key + ":" + replace
		return -1
	endif
	
	found = 0
	
	for ( icnt = icnt+sl; icnt < strlen( txt ); icnt += 1 )
	
		if ( StringMatch( txt[ icnt,icnt ], ":" ) == 1 )
			found = icnt
			break
		endif
		
		if ( StringMatch( txt[ icnt,icnt ], "=" ) == 1 )
			found = icnt
			break
		endif
		
	endfor
	
	if ( found == 0 )
		return -1
	endif
	
	for ( jcnt = icnt+1; jcnt < strlen( txt ); jcnt += 1 )
	
		if ( StringMatch( txt[ jcnt,jcnt ], ";" ) == 1 )
			found = jcnt
			break
		endif
		
		if ( char2num( txt[ jcnt ] ) == 13 )
			found = jcnt
			break
		endif
		
	endfor
	
	txt = txt[ 0, icnt ] + replace + txt[ jcnt, inf ]
	
	Note /K $wname
	Note $wname, txt

End // NMNoteStrReplace

Function NMSetsEqLockTableClear( setList, [ prefixFolder ] )
	String setList // set name list
	String prefixFolder
	
	Variable scnt
	String setName
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	for ( scnt = 0; scnt < ItemsInList( setList ); scnt += 1 )
	
		setName = StringFromList( scnt, setList )
		
		NMSetsEqLockTableAdd( setName, "", "", "", prefixFolder = prefixFolder )
	
	endfor
	
	return 0

End // NMSetsEqLockTableClear

Function NMSetsEqLockTableUpdate( [ prefixFolder ] )
	String prefixFolder
	
	Variable icnt, ipnts, foundOperation
	String eq, txt, wName
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif

	wName = NMSetsEqLockWaveName( prefixFolder = prefixFolder )
	
	if ( !WaveExists( $wName ) )
		return -1
	endif
	
	Wave /T wtemp = $wName
	
	ipnts = DimSize( wtemp, 0 )
	
	for ( icnt = 0 ; icnt < ipnts ; icnt += 1 )
	
		if ( strlen( wtemp[ icnt ][ 0 ] ) == 0 )
			continue
		endif
		
		eq = wtemp[ icnt ][ 0 ] + " = " + wtemp[ icnt ][ 1 ] + " " + wtemp[ icnt ][ 2 ] + " " + wtemp[ icnt ][ 3 ]
		
		if ( !AreNMSets( wtemp[ icnt ][ 0 ], prefixFolder = prefixFolder ) )
		
			NMHistory( "NM Locked Sets : killed the following invalid equation : " + eq )
		
			wtemp[ icnt ][ 0 ] = ""
			wtemp[ icnt ][ 1 ] = ""
			wtemp[ icnt ][ 2 ] = ""
			wtemp[ icnt ][ 3 ] = ""
			
			continue
			
		endif
		
		if ( !AreNMSets( wtemp[ icnt ][ 1 ], prefixFolder = prefixFolder ) )
		
			txt = wtemp[ icnt ][ 1 ]
		
			if ( !StringMatch( txt[ 0, 4 ], "Group" ) )
		
				NMHistory( "NM Locked Sets : killed the following invalid equation : " + eq )
			
				wtemp[ icnt ][ 0 ] = ""
				wtemp[ icnt ][ 1 ] = ""
				wtemp[ icnt ][ 2 ] = ""
				wtemp[ icnt ][ 3 ] = ""
			
				continue
			
			endif
			
		endif
		
		strswitch( wtemp[ icnt ][ 2 ] )
		
			case "AND":
			case "OR":
				foundOperation = 1
				break
			case "":
				foundOperation = 0
				break
		
			default:
				foundOperation = NaN
				
		endswitch
		
		if ( numtype( foundOperation ) > 0 )
		
			NMHistory( "NM Locked Sets : killed the following invalid equation : " + eq )
		
			wtemp[ icnt ][ 0 ] = ""
			wtemp[ icnt ][ 1 ] = ""
			wtemp[ icnt ][ 2 ] = ""
			wtemp[ icnt ][ 3 ] = ""
			
			continue
			
		endif
		
		if ( foundOperation && !AreNMSets( wtemp[ icnt ][ 3 ], prefixFolder = prefixFolder ) )
		
			txt = wtemp[ icnt ][ 3 ]
		
			if ( !StringMatch( txt[ 0, 4 ], "Group" ) )
		
				NMHistory( "NM Locked Sets : killed the following invalid equation : " + eq )
			
				wtemp[ icnt ][ 0 ] = ""
				wtemp[ icnt ][ 1 ] = ""
				wtemp[ icnt ][ 2 ] = ""
				wtemp[ icnt ][ 3 ] = ""
			
				continue
			
			endif
			
		endif
		
		NMSetsEquation( wtemp[ icnt ][ 0 ], wtemp[ icnt ][ 1 ], wtemp[ icnt ][ 2 ], wtemp[ icnt ][ 3 ], prefixFolder = prefixFolder, updateNM = 0 )
		
	endfor

End // NMSetsEqLockTableUpdate

Function NMPrefixFolderWaveToLists( inputWaveName, outputStrVarPrefix, [ prefixFolder ] )
	String inputWaveName
	String outputStrVarPrefix
	String prefixFolder
	
	Variable icnt, ccnt, wcnt, numChannels, alertUser = 0
	String wList, strVarName, strVarList, chanList, wName
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	if ( !WaveExists( $inputWaveName ) )
		return -1
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	if ( ( numtype( numChannels ) > 0 ) || ( numChannels <= 0 ) )
		return -1
	endif
	
	strVarList = NMFolderStringList( prefixFolder, outputStrVarPrefix + "*", ";", 1 )
	
	if ( ItemsInList( strVarList ) > 0 )
	
		if ( alertUser )
	
			DoAlert 1, "NMPrefixFolderWaveToLists Alert: wave lists with prefix " + NMQuotes( outputStrVarPrefix ) + " already exist. Do you want to overwrite them?"
			
			if ( V_flag != 1 )
				return -1 // cancel
			endif
		
		endif
		
		for ( icnt = 0 ; icnt < ItemsInList( strVarList ) ; icnt += 1 )
			KillStrings /Z $StringFromList( icnt, strVarList )
		endfor
	
	endif
	
	Wave input = $inputWaveName
	
	for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
	
		strVarName = prefixFolder + outputStrVarPrefix + ChanNum2Char( ccnt )
		
		wList = ""
		chanList = NMChanWaveList( ccnt, prefixFolder = prefixFolder )
	
		for ( wcnt = 0 ; wcnt < numpnts( input ) ; wcnt += 1 )
			
			if ( input[ wcnt ] == 1 )
			
				wName = StringFromList( wcnt, chanList )
				
				if ( strlen( wName ) > 0 )
					wList = AddListItem( wName, wList, ";", inf )
				endif
				
			endif
		
		endfor
		
		SetNMstr( strVarName, wList )
	
	endfor
	
	return 0
	
End // NMPrefixFolderWaveToLists

Function NMGroupsClear( [ prefixFolder, updateNM, history ] )
	String prefixFolder
	Variable updateNM
	Variable history // print function command to history ( 0 ) no ( 1 ) yes
	
	String groupList, vlist = ""
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		vlist = NMCmdStrOptional( "prefixFolder", prefixFolder, vlist )
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( paramIsDefault( updateNM ) )
		updateNM = 1
	else
		vlist = NMCmdNumOptional( "updateNM", updateNM, vlist )
	endif
	
	if ( !ParamIsDefault( history ) && history )
		NMCmdHistory( "", vlist )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	groupList = NMGroupsList( 1, prefixFolder = prefixFolder )
	
	NMSetsKill( groupList, prefixFolder = prefixFolder, updateNM = 0 )
	NMGroupsWaveNoteClear( prefixFolder = prefixFolder )
	
	if ( updateNM )
		UpdateNMGroups( prefixFolder = prefixFolder )
	endif
	
	return 0
			
End // NMGroupsClear

Function /S NMSetsWaveListRemove( waveListToRemove, setName, chanNum, [ prefixFolder ] )
	String waveListToRemove
	String setName
	Variable chanNum
	String prefixFolder
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	String strVarName = NMSetsStrVarName( setName, chanNum, prefixFolder = prefixFolder )
	
	return NMPrefixFolderStrVarListRemove( waveListToRemove, strVarName, chanNum )
	
End // NMSetsWaveListRemove

Function /S NMSetsWaveListAdd( waveListToAdd, setName, chanNum, [ prefixFolder ] )
	String waveListToAdd
	String setName
	Variable chanNum
	String prefixFolder
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	String strVarName = NMSetsStrVarName( setName, chanNum, prefixFolder = prefixFolder )
	
	return NMPrefixFolderStrVarListAdd( waveListToAdd, strVarName, chanNum )
	
End // NMSetsWaveListAdd

Static Function z_GroupSetWaveNote( wName, group )
	String wName
	Variable group
	
	String txt
	
	String groupName = NMGroupsName( group )
	
	if ( NMNoteExists( wName, "Group" ) == 1 )
	
		NMNoteVarReplace( wName, "Group", group )
		
		return 0
	
	endif
	
	if ( WaveExists( $wName ) == 1 )
	
		txt = note( $wName )
		
		Note /K $wName
		
		Note $wName, "Group:" + num2str( group )
		Note $wName, txt
	
	endif
	
End // z_GroupSetWaveNote

Function NMDragClear( wPrefix )
	String wPrefix

	String xNamePath = NMDF+wPrefix + "X"
	String yNamePath = NMDF+wPrefix + "Y"
	
	if ( WaveExists( $xNamePath ) == 0 )
		return -1
	endif
	
	Wave dragX = $xNamePath
	Wave dragY = $yNamePath
	
	dragX = Nan
	dragY = Nan

End // NMDragClear

Function NMDragUpdate( wPrefix ) // Note, this must be called AFTER graphs have been auto scaled
	String wPrefix
	
	String xNamePath = NMDF+wPrefix + "X"
	String yNamePath = NMDF+wPrefix + "Y"
	
	if ( WaveExists( $xNamePath ) == 0 )
		return -1
	endif
	
	String gName = NMNoteStrByKey( yNamePath, "Graph" )
	
	if ( WinType( gName ) != 1 )
		return -1
	endif
	
	return NMDragUpdate2( xNamePath, yNamePath )
	
End // NMDragUpdate

Function /S NMWindowWaveList( windowNameStr, type, fullPath )
	String windowNameStr // ( "" ) for top graph or table
	Variable type // see Igor WaveRefIndexed type
	Variable fullPath // ( 0 ) no, just wave name ( 1 ) yes, directory + wave name
	
	Variable icnt
	String wName, wList = ""
	
	for ( icnt = 0 ; icnt < 9999 ; icnt += 1 )
	
		if ( WaveExists( WaveRefIndexed( windowNameStr, icnt, type ) ) == 0 )
			break
		endif
		
		wName = ""
	
		if ( fullPath == 0 )
			wName = NameOfWave( WaveRefIndexed( windowNameStr, icnt, type ) )
		elseif ( fullPath == 1 )
			wName = GetWavesDataFolder( WaveRefIndexed( windowNameStr, icnt, type ), 2 )
		endif
		
		wList = AddListItem( wName, wList, ";", inf )
	
	endfor
	
	return wList
	
End // NMWindowWaveList

Function /S NMChanWaveListName( channel, [ prefixFolder ] )
	Variable channel
	String prefixFolder
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif

	return prefixFolder + "ChanWaveNames" + ChanNum2Char( channel )

End // NMChanWaveListName

Function NMGroupsNumCount( [ prefixFolder ] )
	String prefixFolder
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return 0
	endif

	return ItemsInList( NMGroupsList( 0, prefixFolder = prefixFolder ) )

End // NMGroupsNumCount

Function NMGroupsFirst( groupSeq, [ prefixFolder ] ) // first group number
	String groupSeq // e.g. "0;1;2;" or ( "" ) for current groupSeq
	String prefixFolder

	Variable gcnt, group, firstGroup = inf
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return NaN
	endif
	
	if ( ItemsInList( groupSeq ) == 0 )
		groupSeq = NMGroupsList( 0, prefixFolder = prefixFolder )
	endif
	
	for ( gcnt = 0 ; gcnt < ItemsInList( groupSeq ) ; gcnt += 1 )
	
		group = str2num( StringFromList( gcnt, groupSeq ) )
		
		if ( ( numtype( group ) == 0 ) && ( group < firstGroup ) )
			firstGroup = group
		endif
		
	endfor
	
	return firstGroup // e.g. "0"

End // NMGroupsFirst

Function NMGroupsNumDefault( [ prefixFolder ] )
	String prefixFolder

	Variable numGroups
	String groupList, subStimFolder = SubStimDF()
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	groupList = NMGroupsList( 0, prefixFolder = prefixFolder )

	numGroups = ItemsInList( groupList )
	
	if ( ( numGroups == 0 ) && ( strlen( prefixFolder ) > 0 ) )
		numGroups = NumVarOrDefault( prefixFolder+"NumGrps", 0 )
	endif
	
	if ( ( numGroups == 0 ) && ( strlen( subStimFolder ) > 0 ) )
		numGroups = NumVarOrDefault( subStimFolder+"NumStimWaves", 0 )
	endif
	
	if ( numGroups == 0 )
		numGroups = 3
	endif
	
	return numGroups

End // NMGroupsNumDefault

Function GetNumFromStr( str, findStr )
	String str // string to search
	String findStr // string to find ( e.g. "marker( x )=" or "Group:" )
	
	Variable icnt, ibgn
	
	str = ReplaceString( " ", str, "" ) // remove spaces
	
	ibgn = strsearch( str, findStr, 0 )
	
	if ( ibgn < 0 )
		return NaN
	endif
	
	ibgn += strlen( findStr )
	
	for ( icnt = ibgn+1; icnt < strlen( str ); icnt += 1 )
		if ( numtype( str2num( str[icnt] ) ) > 0 )
			break
		endif
	endfor
	
	return str2num( str[ibgn,icnt-1] )

End // GetNumFromStr

Function /S NMDataFolderListLong() // includes Folder list name ( i.e. "F0" )
	Variable icnt
	
	String fname, fList2 = "", fList = NMDataFolderList()
	
	for ( icnt = 0; icnt < ItemsInList( fList ); icnt += 1 )
		fname = StringFromList( icnt, fList )
		fname = NMFolderListName( fname ) + " : " + fname
		fList2 = AddListItem( fname, fList2, ";", inf )
	endfor

	return fList2
	
End // NMDataFolderListLong

Function /S NMLogFolderListLong()
	Variable icnt
	
	String fname, fList2 = "", fList = NMFolderList( "root:","NMLog" )
	
	for ( icnt = 0; icnt < ItemsInList( fList ); icnt += 1 )
		fname = StringFromList( icnt, fList )
		fname = "L" + num2istr( icnt ) + " : " + fname
		fList2 = AddListItem( fname, fList2, ";", inf )
	endfor

	return fList2
	
End // NMLogFolderListLong

Function /S SubStimDF()

	String sName = SubStimName("")

	if ( strlen(sName) > 0 )
		return GetDataFolder(1) + sName + ":"
	else
		return ""
	endif

End // SubStimDF

Function NMChanSelectedAll( [ prefixFolder ] )
	String prefixFolder

	Variable ccnt, numChannels
	String chanList

	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return 0
	endif
	
	chanList = StrVarOrDefault( prefixFolder + NMChanSelectVarName, "" )
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
	
		if ( WhichListItem( num2istr( ccnt ) , chanList ) < 0 )
			return 0
		endif
		
	endfor
	
	return 1

End // NMChanSelectedAll

Function /S NMFileOpenDialogue( path, ext )
	String path // symbolic path name
	String ext // file extension; ( "" ) for FileBinExt ( ? ) for any

	Variable refnum, useDefaultPath = 0
	String fList = "", pathStr = "", type = "????"
	
	if ( strlen( ext ) == 0 )
		ext = ".pxp"
	endif
	
	strswitch( ext )
		case ".pxp":
			type = "IGsU????"
			break
		case ".txt":
			type = "TEXT"
			break
	endswitch
	
	if ( strlen( path ) > 0 )
	
		PathInfo /S $path
		
		if ( V_Flag == 1 )
			useDefaultPath = 0
		endif
	
	endif
	
	if ( useDefaultPath )
	
		pathStr = SpecialDirPath( "Documents", 0, 0, 0 )
	
		NewPath NMDefaultPath, pathStr
		
		PathInfo /S NMDefaultPath
	
	endif
	
	Open /R/D/M="Select one or more files to open"/MULT=1/T=type refnum // allows multiple selections
	
	fList = ReplaceString( "\r", S_fileName, ";" ) // replace carriage returns with semi-colon
	
	KillPath /Z NMDefaultPath
	
	if ( ItemsInList( fList ) == 1 )
		return StringFromList( 0, fList )
	else
		return fList // return file name list
	endif
	
End // NMFileOpenDialogue

Function /S NMFolderNameCreate( fileName, [ nmPrefix ] )  // create a folder name based on a given file name
	String fileName
	Variable nmPrefix // ( 0 ) no ( 1 ) yes, force "nm" prefix
	
	Variable num0, num1
	String folderName = fileName
	
	folderName = ParseFilePath( 0, folderName, ":", 1, 0 ) // remove file path if it exists
	folderName = FileExtCheck( folderName, ".*", 0 ) // remove extension if it exists
	
	num0 = str2num( folderName[ 0, 0 ] )
	num1 = str2num( folderName[ 1, 1 ] )
	
	if ( numtype( num0 ) == 0 )
		folderName = "nm" + folderName
	elseif ( nmPrefix && StringMatch( folderName[ 0, 0 ], "f" ) && ( numtype( num1 ) == 0 ) )
		folderName = "nm" + folderName[ 1, inf ]
	endif
	
	if ( nmPrefix && !StringMatch( folderName[ 0, 1 ], "nm" ) )
		folderName = "nm" + folderName
	endif
	
	folderName = NMCheckStringName( folderName )
	
	return folderName

End // NMFolderNameCreate

Function NMFolderClose( folderNameList, [ update, history ] ) // close/kill a data folder
	String folderNameList // folder path ( "" ) for current folder ( "All" ) to close all NM data folders
	Variable update
	Variable history // print function command to history ( 0 ) no ( 1 ) yes
	
	Variable inum, fcnt
	String wname, folderName, folderNameShort, changeToFolder = ""
	
	String vlist = NMCmdStr( folderNameList, "" )
	
	if ( ParamIsDefault( update ) )
		update = 1
	else
		vlist = NMCmdNumOptional( "update", update, vlist )
	endif
	
	if ( !ParamIsDefault( history ) && history )
		NMCmdHistory( "", vlist )
	endif
	
	String currentFolder = CurrentNMFolder( 1 )
	String fList = NMDataFolderList()
	
	if ( strlen( folderNameList ) == 0 )
		folderNameList = currentFolder
	elseif ( StringMatch( folderNameList, "All" ) )
		folderNameList = fList
		changeToFolder = " "
	endif
	
	for ( fcnt = 0 ; fcnt < ItemsInList( folderNameList ) ; fcnt += 1 )
	
		folderName = StringFromList( fcnt, folderNameList )
	
		folderName = CheckNMFolderPath( folderName )
		
		if ( DataFolderExists( folderName ) == 0 )
			continue
		endif
		
		folderNameShort = GetPathName( folderName, 0 )
		
		inum = WhichListItem( folderNameShort, fList )
		
		if ( inum < 0 )
			continue
		endif
		
		if ( strlen( changeToFolder ) == 0 )
		
			if ( inum == 0 )
				changeToFolder  = " "
			else
				changeToFolder = StringFromList( inum - 1, fList )
				changeToFolder = GetPathName( changeToFolder, 0 )
			endif
		
		endif
		
		NMKillWindows( folderName ) // old kill method
		NMFolderWinKill( folderName ) // new FolderList function
		
		if ( StringMatch( currentFolder, folderName ) == 1 )
			ChanGraphClose( -2, 0 )
		endif
		
		NMPrefixFolderUtility( folderName, "unlock" )
	
		KillDataFolder /Z $folderName
	
		if ( DataFolderExists( folderName ) == 1 )
			NMFolderCloseAlert( folderName )
		else
			NMFolderListRemove( folderName )
		endif
	
	endfor
	
	changeToFolder = ReplaceString( " ", changeToFolder, "" )
	
	SetNMstr( NMDF+"CurrentFolder", "" )
			
	if ( strlen( changeToFolder ) > 0 )
		NMFolderChange( changeToFolder, update = update )
	else
		NMFolderChangeToFirst( update = update )
	endif
	
	return 0

End // NMFolderClose

Static Function /S S_NMB_FileType( file )
	String file // file name
	
	String ftype = ""
	
	Variable icnt, nobjchar, opnts, otype, refnum
	String objName
	
	Variable /G dumvar
	
	Open /R/T="IGBW" refnum as file
	
	FBinRead /B=2/F=1 refnum, dumvar
	
	otype = dumvar

	if ( otype == 3 )
	
		objName = S_NMB_ReadString( refnum )
		
		if ( StringMatch( objName, "FileType" ) )
			ftype = S_NMB_ReadString( refnum )
		endif
	
	endif
	
	KillVariables /Z dumvar
	
	Close refnum
	
	return ftype
		
End // S_NMB_FileType

Function /S NMBinOpen( folder, file, makeflag, changeFolder, [ nmPrefix ] )
	String folder // folder name where file objects are loaded, ( "" ) or ( "root:" ) to auto create folder in root 
	String file // external file name
	String makeflag // text waves | numeric waves | numeric variables | string variables
	Variable changeFolder // change to this folder after opening file ( 0 ) no ( 1 ) yes
	Variable nmPrefix // ( 0 ) no ( 1 ) yes, force "nm" prefix when creating NM data folder
	
	changeFolder = BinaryCheck( changeFolder )
	
	if ( ( strlen( folder ) == 0 ) || StringMatch( folder, "root:" ) )
		folder = "root:" + NMFolderNameCreate( file, nmPrefix = nmPrefix )
	endif
	
	folder = CheckFolderName( folder ) // get unused folder name
	
	if ( DataFolderExists( folder ) )
		return "" // folder must not exist
	endif
	
	if ( strlen( file ) == 0 )
		return "" // not allowed
	endif
	
	if ( !FileExistsAndNonZero( file ) || ( strlen( S_NMB_FileType( file ) ) == 0 ) )
		NMDoAlert( "Error: file " + NMQuotes( file ) + " is not a NeuroMatic binary file." )
		return "" // not a NM binary file
	endif

	String saveDF = GetDataFolder( 1 ) // save current directory
	
	NewDataFolder /O/S $RemoveEnding( folder, ":" ) // open new folder
	
	S_NMB_ReadObject( file, makeflag ) // read data
	
	SetDataFolder $folder
	
	SetNMstr( "DataFileType", "NMBin" )
	SetNMstr( "CurrentFile", file )
	
	NMHistory( "Opened NeuroMatic binary file " + NMQuotes( file ) + " to folder " + NMQuotes( folder ) )
	
	String df = LastPathColon( folder, 1 ) + "Data"
	String ftype = StrVarOrDefault( "FileType", "" )
	
	strswitch( ftype )
	
		case "NMLog":
			LogDisplayCall( folder )
			changeFolder = 0
			break
			
		case "NMData":
			
			if ( DataFolderExists( df ) )
			
				// folder was created by Clamp tab
				// waves stored in folder "Data"
				
				CopyWavesTo( df, folder, "", -inf, inf, "", 0 )
				
				if ( CountObjects( df,1 ) == 0 )
					KillDataFolder df
				endif
				
			endif
			
			CheckNMDataFolder( folder )
			NMFolderListAdd( folder )
			PrintNMFolderDetails( folder )
			
			break
			
	endswitch
	
	if ( !changeFolder )
	
		SetDataFolder $saveDF // back to original data folder
		
	else
	
		NMFolderChange( folder )
		
	endif
	
	return folder
	
End // NMBinOpen

Function /S IgorBinOpen( folder, file, changeFolder, [ nmPrefix ] ) // open Igor packed binary file
	String folder // data folder path where to open folder, ( "" ) or ( "root:" ) to auto create in root
	String file // external file name
	Variable changeFolder // change to this folder after opening file ( 0 ) no ( 1 ) yes
	Variable nmPrefix // ( 0 ) no ( 1 ) yes, force "nm" prefix when creating NM data folder
	
	changeFolder = BinaryCheck( changeFolder )
	
	if ( ( strlen( folder ) == 0 ) || StringMatch( folder, "root:" ) )
		folder = "root:" + NMFolderNameCreate( file, nmPrefix = nmPrefix )
	endif
	
	folder = CheckFolderName( folder ) // get unused folder name

	if ( ( strlen( file ) == 0 ) || DataFolderExists( folder ) )
		return "" // not allowed
	endif

	String saveDF = GetDataFolder( 1 )
	
	NewDataFolder /O/S $RemoveEnding( folder, ":" )
	LoadData /O/Q/R file
	
	KillVariables /Z V_Progress // LoadData seems to create this variable - but this creates bug for progress window
	
	SetNMstr( "DataFileType", "IgorBin" )
	SetNMstr( "CurrentFile", file )
	
	String ftype = StrVarOrDefault( "FileType", "" )
	
	NMHistory( "Opened Igor binary file " + NMQuotes( file ) + " to folder " + NMQuotes( folder ) )
	
	if ( StringMatch( ftype, "NMLog" ) )
		LogDisplayCall( folder )
		changeFolder = 0
	endif
	
	if ( StringMatch( ftype, "NMData" ) )
		CheckNMDataFolder( folder )
		NMFolderListAdd( folder )
		PrintNMFolderDetails( folder )
	endif
	
	SetDataFolder $saveDF // back to original data folder
	
	if ( changeFolder )
		NMFolderChange( folder )
	endif
	
	return folder
	
End // IgorBinOpen

Function /S NMImportFile( folder, fileList, [ nmPrefix ] ) // import a data file
	String folder // folder name, or "new" for new folder, or "one" to import into a single folder
	String fileList // list of external file names
	Variable nmPrefix // ( 0 ) no ( 1 ) yes, force "nm" prefix when creating NM data folders
	
	Variable fcnt, newFolder, success, emptyfolder
	String file, folder2, saveDF, df
	
	for ( fcnt = 0 ; fcnt < ItemsInList( fileList ) ; fcnt += 1 )
	
		file = StringFromList( fcnt, fileList )
	
		if ( ( strlen( file ) == 0 ) || ( FileExistsAndNonZero( file ) == 0 ) )
			continue
		endif
		
		if ( StringMatch( folder, "one" ) == 1 )
		
			if ( fcnt == 0 )
				folder2 = NMFolderNameCreate( file, nmPrefix = nmPrefix )
			endif
		
		elseif ( ( strlen( folder ) == 0 ) || ( StringMatch( folder, "new" ) == 1 ) )
		
			folder2 = NMFolderNameCreate( file, nmPrefix = nmPrefix )
			
		else
		
			folder2 = folder
			
		endif
		
		saveDF = GetDataFolder( 0 )
			
		if ( DataFolderExists( folder2 ) == 1 )
		
			NMFolderChange( folder2 )
		
		//elseif ( ( NMNumChannels() == 0 ) && ( ItemsInList( WaveList( "*", ";", "" ) ) == 0 ) )
		
		//	NMFolderRename( "" , folder2 ) // removed this option due to conflict with NMImportWaves 13 July 2012
			
		else
		
			folder2 = NMFolderNew( folder2 )
			
			newFolder = 1
		
			if ( strlen( folder2 ) == 0 )
				continue
			endif
			
		endif
		
		df = GetDataFolder( 1 )
		
		SetNMstr( df+"CurrentFile", file )
		SetNMstr( df+"FileName", GetPathName( file, 0 ) )
		
		success = NMImport( file, newFolder )
		
		if ( ( success < 0 ) && ( newfolder == 1 ) )
			NMFolderClose( folder2 )
			NMFolderChange( saveDF )
			folder2 = ""
		endif
	
	endfor
	
	UpdateNM( 0 )
	
	KillVariables /Z V_Flag, WaveBgn, WaveEnd
	KillStrings /Z S_filename, S_wavenames
	KillWaves /Z DumWave0, DumWave1
	
	return folder

End // NMImportFile

Function /S NMNoteString( wname )
	String wname // wave name with note
	
	Variable icnt
	String txt, txt2 = ""

	if ( WaveExists( $wname ) == 0 )
		return ""
	endif
	
	txt = note( $wname )
	
	for ( icnt = 0; icnt < strlen( txt ); icnt += 1 )
		if ( char2num( txt[ icnt ] ) == 13 ) // remove carriage return
			txt2 += ";"
		elseif ( char2num( txt[ icnt ] ) == 10 ) // remove new line
			// do nothing
		else
			txt2 += txt[ icnt ]
		endif
	endfor
	
	return txt2
	
End // NMNoteString

Function /S NMWaveListOptions( numRows, wType )
	Variable numRows // number of rows in 1-dimensional wave
	Variable wType // waveType ( 0 ) not text ( 1 ) text
	
	return "DIMS:1,MAXROWS:" + num2istr( numRows ) + ",MINROWS:" + num2istr( numRows ) + ",TEXT:" + num2istr( BinaryCheck( wType ) )
	
End // NMWaveListOptions

Function /S ChanFilterDF( channel, [ prefixFolder ] )
	Variable channel // ( -1 ) for current channel
	String prefixFolder
	
	String cdf
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	if ( channel == -1 )
		channel = NumVarOrDefault( prefixFolder + "CurrentChan", 0 )
	endif
	
	cdf = ChanDF( channel, prefixFolder = prefixFolder )
	
	return StrVarOrDefault( NMDF + "ChanFilterDF" + num2istr( channel ), cdf )

End // ChanFilterDF

Function NMUtilityWaveTest( wList )
	String wList // wave list ( seperator ";" )
	
	Variable wcnt
	String wName
	
	for ( wcnt = 0 ; wcnt < ItemsInList( wList ) ; wcnt += 1 )
	
		wName = StringFromList( wcnt, wList )
	
		if ( ( WaveExists( $wName ) == 0 ) || ( WaveType( $wName ) == 0 ) )
			return -1
		endif
		
	endfor
	
	return 0
	
End // NMUtilityWaveTest

Function NMProgressKill()

	return NMProgressCall( 1, "" )

End // NMProgressKill

Function NMUtilityAlert( fxn, badList )
	String fxn
	String badList

	if ( ItemsInList( badList ) <= 0 )
		return 0
	endif
	
	badList = NMUtilityWaveListShort( badList )
	
	String alert = fxn + " Alert : the following waves failed to pass sucessfully through function execution : " + badList
	
	NMHistory( alert )
	
End // NMUtilityAlert

Function /S MeanStdv( xbgn, xend, wList )
	Variable xbgn, xend // x-axis window begin and end, use ( -inf, inf ) for all
	String wList // wave list ( seperator ";" )
	
	Variable wcnt, cnt, num, avg, stdv
	String wName, badList = wList, thisfxn = GetRTStackInfo( 1 )
	
	if ( numtype( xbgn ) > 0 )
		xbgn = -inf
	endif
	
	if ( numtype( xend ) > 0 )
		xend = inf
	endif
	
	if ( ItemsInList( wList ) == 0 )
		return ""
	endif
	
	for ( wcnt = 0; wcnt < ItemsInList( wList ); wcnt += 1 )
	
		wName = StringFromList( wcnt, wList )
		
		if ( NMUtilityWaveTest( wName ) < 0 )
			continue
		endif
		
		Wave wv = $wName
		
		num = mean( wv, xbgn, xend )
		
		avg += num
		stdv += num*num
		cnt += 1
		
		badList = RemoveFromList( wName, badList )
		
	endfor
	
	if ( cnt >= 2 )
	
		stdv = sqrt( ( stdv - ( ( avg^2 ) / cnt ) ) / ( cnt-1 ) )
		avg = avg / cnt
	
	else
	
		stdv = NaN
		avg = NaN
	
	endif
	
	NMUtilityAlert( thisfxn, badList )
	
	return "mean=" + num2str( avg ) + ";stdv=" + num2str( stdv ) + ";count=" + num2istr( cnt )+";"

End // MeanStdv

Function NMNumPntsGet( select, wList )
	String select // "numPnts", "minNumPnts", "maxNumPnts"
	String wList // wave list ( seperator ";" )
	
	// if waves have different numpnts this function returns NaN if for select "numPnts"
	
	Variable wcnt, dumvar
	Variable pnts = -1, minNumPnts = inf, maxNumPnts = -inf
	
	String wName, badList = "", thisfxn = GetRTStackInfo( 1 )
	
	if ( ItemsInList( wList ) == 0 )
		return NaN
	endif
	
	for ( wcnt = 0; wcnt < ItemsInList( wList ); wcnt += 1 )
	
		wName = StringFromList( wcnt, wList )
		wName = StringFromList( 0, wName, "," ) // in case of sub-wavelist
		
		if ( NMUtilityWaveTest( wName ) < 0 )
			badList = AddListItem( wName, badList, ";", inf )
			continue
		endif
		
		dumvar = numpnts( $wName )
		
		if ( pnts < 0 )
			pnts = dumvar // first wave
		elseif ( ( StringMatch( select, "numpnts" ) == 1 ) && ( dumvar != pnts ) )
			return NaN // waves have different numpnts
		endif
		
		if ( dumvar < minNumPnts )
			minNumPnts = dumvar
		endif
		
		if ( dumvar > maxNumPnts )
			maxNumPnts = dumvar
		endif
		
	endfor
	
	NMUtilityAlert( thisfxn, badList )
	
	strswitch( select )
	
		case "numpnts":
			return pnts
		case "minNumPnts":
			return minNumPnts
		case "maxNumPnts":
			return maxNumPnts
		
		default:
			NM2Error( 20, "select", select )
			return NaN
			
	endswitch
	
End // NMNumPntsGet

Function NMDeltaXGet( select, wList )
	String select // "deltax", "minDeltax", "maxDeltax"
	String wList // wave list ( seperator ";" )
	
	// if waves have different deltax this function returns NaN for select "deltax"
	
	Variable wcnt, dumvar
	Variable dx = -1, minDeltax = inf, maxDeltax = -inf
	
	String wName, badList = "", thisfxn = GetRTStackInfo( 1 )
	
	if ( ItemsInList( wList ) == 0 )
		return NaN
	endif
	
	for ( wcnt = 0; wcnt < ItemsInList( wList ); wcnt += 1 )
	
		wName = StringFromList( wcnt, wList )
		wName = StringFromList( 0, wName, "," ) // in case of sub-wavelist
		
		if ( NMUtilityWaveTest( wName ) < 0 )
			badList = AddListItem( wName, badList, ";", inf )
			continue
		endif
		
		 dumvar = deltax( $wName )
		 
		if ( dx < 0 )
			dx = dumvar // first wave
		elseif ( ( StringMatch( select, "deltax" ) == 1 ) && ( numtype( dx ) == 0 ) && ( abs( dumvar - dx ) > 0.001 ) )
			return NaN // waves have different deltax
		endif
		
		if ( dumvar < minDeltax )
			minDeltax = dumvar
		endif
		
		if ( dumvar > maxDeltax )
			maxDeltax = dumvar
		endif
		
	endfor
	
	NMUtilityAlert( thisfxn, badList )
	
	strswitch( select )
			
		case "deltax":
			return dx
		case "minDeltax":
			return minDeltax
		case "maxDeltax":
			return maxDeltax
		
		default:
			NM2Error( 20, "select", select )
			return NaN
			
	endswitch
	
End // NMDeltaXGet

Function NMLeftXGet( select, wList )
	String select // "leftx", "minLeftx", "maxLeftx"
	String wList // wave list ( seperator ";" )
	
	// if waves have different leftx this function returns NaN for select "leftx"
	
	Variable wcnt, dumvar
	Variable lftx = -inf, minLeftx = inf, maxLeftx = -inf
	
	String wName, badList = "", thisfxn = GetRTStackInfo( 1 )
	
	if ( ItemsInList( wList ) == 0 )
		return NaN
	endif
	
	for ( wcnt = 0; wcnt < ItemsInList( wList ); wcnt += 1 )
	
		wName = StringFromList( wcnt, wList )
		wName = StringFromList( 0, wName, "," ) // in case of sub-wavelist
		
		if ( NMUtilityWaveTest( wName ) < 0 )
			badList = AddListItem( wName, badList, ";", inf )
			continue
		endif
		
		dumvar = leftx( $wName )
		
		if ( numtype( lftx ) == 1 )
			lftx = dumvar // first value
		elseif ( ( StringMatch( select, "leftx" ) == 1 ) && ( numtype( lftx ) == 0 ) && ( dumvar != lftx ) )
			return NaN // doesnt match first value
		endif
		
		if ( dumvar < minLeftx )
			minLeftx = dumvar
		endif
		
		if ( dumvar > maxLeftx )
			maxLeftx = dumvar
		endif
		
	endfor
	
	NMUtilityAlert( thisfxn, badList )
	
	strswitch( select )
			
		case "leftx":
			return lftx
		case "minLeftx":
			return minLeftx
		case "maxLeftx":
			return maxLeftx
			
		default:
			NM2Error( 20, "select", select )
			return NaN
			
	endswitch
	
End // NMLeftXGet

Function NMRightXGet( select, wList )
	String select // select which value to pass back ( see below )
	String wList // wave list ( seperator ";" )
	
	// select options:	"numPnts", "minNumPnts", "maxNumPnts"
	//					"deltax", "minDeltax", "maxDeltax"
	//					"leftx", "minLeftx", "maxLeftx"
	//					"rightx", "minRightx", "maxRightx",
	// note, if waves have different deltax or numpnts or leftx or rightx, this function returns NaN
	
	Variable wcnt, dumvar
	Variable rghtx = inf, minRightx = inf, maxRightx = -inf
	
	String wName, badList = "", thisfxn = GetRTStackInfo( 1 )
	
	if ( ItemsInList( wList ) == 0 )
		return NaN
	endif
	
	for ( wcnt = 0; wcnt < ItemsInList( wList ); wcnt += 1 )
	
		wName = StringFromList( wcnt, wList )
		wName = StringFromList( 0, wName, "," ) // in case of sub-wavelist
		
		if ( NMUtilityWaveTest( wName ) < 0 )
			badList = AddListItem( wName, badList, ";", inf )
			continue
		endif
		
		dumvar = rightx( $wName )
		
		if ( numtype( rghtx ) == 1 )
			rghtx = dumvar // first value
		elseif ( ( StringMatch( select, "rightx" ) == 1 ) && ( numtype( rghtx ) == 0 ) && ( dumvar != rghtx ) )
			return NaN // does not match first value
		endif
		
		if ( dumvar > maxRightx )
			maxRightx = dumvar
		endif
		
		if ( dumvar < minRightx )
			minRightx = dumvar
		endif
		
	endfor
	
	NMUtilityAlert( thisfxn, badList )
	
	strswitch( select )
			
		case "rightx":
			return rghtx
		case "minRightx":
			return minRightx
		case "maxRightx":
			return maxRightx
		
		default:
			NM2Error( 20, "select", select )
			return NaN
			
	endswitch
	
End // NMRightXGet

Function WavesExist( wList )
	String wList // wave list ( seperator ";" )
	
	Variable wcnt
	
	if ( ItemsInList( wList ) == 0 )
		return 0
	endif
	
	for ( wcnt = 0; wcnt < ItemsInList( wList ); wcnt += 1 )
		if ( WaveExists( $StringFromList( wcnt, wList ) ) == 0 )
			return 0
		endif
	endfor
	
	return 1 // yes, all exist

End // WavesExist

Function /S InterpolateWaves( alg, xmode, xwave, wList )
	Variable alg // ( 1 ) linear ( 2 ) cubic spline
	Variable xmode	// ( 1 ) compute a common x-axis for input waves
					// ( 2 ) use x-axis scale of xwave
					// ( 3 ) use values of xwave as x-scale
	String xwave // wave to derive x-values from
	String wList // wave list ( seperator ";" )

	Variable wcnt, numWaves, npnts, dx, lftx, lx, rghtx, rx, p1, p2
	String wName, oldnote, outList = "", badList = wList
	String thisfxn = GetRTStackInfo( 1 )
	
	switch( alg )
		case 1:
		case 2:
			break
		default:
			return NM2ErrorStr( 10, "alg", num2istr( alg ) )
	endswitch
	
	switch( xmode )
	
		case 1:
		
			dx = NMDeltaXGet( "deltax", wList )
			lftx = NMLeftXGet( "minLeftx", wList )
			rghtx = NMRightXGet( "maxRightx", wList )
			npnts = ( rghtx-lftx )/dx
			
			if ( ( numtype( npnts ) > 0 ) || ( npnts <= 0 ) )
				return NM2ErrorStr( 10, "npnts", num2istr( npnts ) )
			endif
			
			Make /O/N=( npnts ) U_InterpX
			
			U_InterpX = lftx + x*dx
			
			break
			
		case 2:
		
			if ( NMUtilityWaveTest( xwave ) < 0 )
				NM2Error( 1, "xwave", xwave )
			endif
			
			dx = deltax( $xwave )
			lftx = leftx( $xwave )
			rghtx = rightx( $xwave )
			npnts = numpnts( $xwave )
			
			Duplicate /O $xwave U_InterpX
			
			U_InterpX = x
			
			break
			
		case 3:
		
			if ( NMUtilityWaveTest( xwave ) < 0 )
				NM2Error( 1, "xwave", xwave )
			endif
			
			Duplicate /O $xwave U_InterpX
			
			npnts = numpnts( U_InterpX )
			lftx = U_InterpX[0]
			rghtx = U_InterpX[npnts-1]
			dx = U_InterpX[1] - U_InterpX[0] // ( assuming equal intervals )
			
			break
			
		default:
			return NM2ErrorStr( 10, "xmode", num2istr( xmode ) )
			
	endswitch
	
	if ( ( numtype( npnts ) > 0 ) || ( npnts <= 0 ) )
		return NM2ErrorStr( 10, "npnts", num2istr( npnts ) )
	endif
	
	if ( ( numtype( dx ) > 0 ) || ( dx <= 0 ) )
		return NM2ErrorStr( 10, "dx", num2str( dx ) )
	endif
	
	if ( numtype( lftx ) > 0 )
		return NM2ErrorStr( 10, "lftx", num2str( lftx ) )
	endif
	
	if ( numtype( rghtx ) > 0 )
		return NM2ErrorStr( 10, "rghtx", num2str( rghtx ) )
	endif
	
	numWaves = ItemsInList( wList )
	
	if ( numWaves == 0 )
		return ""
	endif
	
	for ( wcnt = 0; wcnt < numWaves; wcnt += 1 )
	
		if ( NMProgressTimer( wcnt, numWaves, "Interpolating Waves..." ) == 1 )
			break // cancel wave loop
		endif
	
		wName = StringFromList( wcnt, wList )
		
		if ( NMUtilityWaveTest( wName ) < 0 )
			continue
		endif
		
		lx = leftx( $wName )
		rx = rightx( $wName )

		Interpolate2 /T=( alg )/I=3/Y=U_InterpY /X=U_interpX $wName
		
		outList = AddListItem( wName, outList, ";", inf )
		badList = RemoveFromList( wName, badList )
		
		oldnote = note( $wName )
		Duplicate /O U_InterpY, $wName
		
		Wave wtemp = $wName
		
		Setscale /P x lftx, dx, wtemp
		
		p1 = x2pnt( wtemp, lftx )
		p2 = x2pnt( wtemp, lx )
		
		if ( ( numtype( p1 * p2 ) == 0 ) && ( p2 > p1 ) )
			wtemp[p1, p2] = NaN
		endif
		
		p1 = x2pnt( wtemp, rx )
		p2 = x2pnt( wtemp, rghtx )
		
		if ( ( numtype( p1 * p2 ) == 0 ) && ( p2 > p1 ) )
			wtemp[p1, p2] = NaN
		endif
		
		Note /K $wName
		Note $wName, oldnote
		
		Note $wName, "Func:" + thisfxn
		
		switch( xmode )
			case 1:
				Note $wName, "Interp Leftx:" + num2str( lftx ) + ";Interp Rightx:" + num2str( rghtx ) + ";Interp dx:" + num2str( dx ) + ";"
				break
			case 2:
				Note $wName, "Interp xScale:" + xwave
				break
			case 3:
				Note $wName, "Interp xValues:" + xwave
				break
		endswitch
		
	endfor
	
	KillWaves /Z U_InterpX, U_InterpY
	
	NMUtilityAlert( thisfxn, badList )
	
	return outList

End // InterpolateWaves

Function /S NMUtilityWaveListShort( wList )
	String wList
	
	Variable wcnt
	String prefix, wName, tempList = "", foundList = "", oList = ""
	
	prefix = FindCommonPrefix( wList )
	
	if ( strlen( prefix ) == 0 )
		return wList
	endif
	
	for ( wcnt = 0 ; wcnt < ItemsInList( wList ) ; wcnt += 1 )
	
		wName = StringFromList( wcnt, wList )
		
		if ( strsearch( wName, prefix, 0, 2 ) == 0 )
			foundList = AddListItem( wName, foundList, ";", inf )
			tempList = AddListItem( ReplaceString( prefix, wName, "" ), tempList, ";", inf )
		endif
	
	endfor
	
	if ( ItemsInList( tempList ) > 1 )
	
		tempList = SequenceToRangeStr( tempList, "-" )
		
		oList = AddListItem( prefix + "," + ReplaceString( ";", tempList, "," ), oList, ";", inf )
	
	endif
	
	return ReplaceString( ",;", oList, ";" ) + RemoveFromList( foundList, wList )
	
End // NMUtilityWaveListShort

Function NMProgressFlag()

	Variable progflag = NMVarGet( "ProgFlag" )
	
	if ( progflag > 0 )
	
		if ( IgorVersion() >= 6.1 )
			return 2 // new Igor Progress Window
			//return 1 // use ProgWin XOP
		endif
		
		return 1 // use ProgWin XOP
	
	endif
	
	return 0

End // NMProgressFlag

Function NMProgWinXOP( fraction )
	Variable fraction // fraction of progress ( 0 ) create ( 1 ) kill prog window ( -1 ) create candy ( -2 ) spin
	
	Variable xProgress = NMProgressX()
	Variable yProgress = NMProgressY()
	
	String ProgressStr = NMStrGet( "ProgressStr" )
	
	String win = "win=( " + num2str( xProgress ) + "," + num2str( yProgress ) + " )"
	String txt = "text=" + NMQuotes( ProgressStr )
	
	if ( numtype( fraction ) > 0 )
		return -1
	endif

	if ( fraction == -1 )
		Execute /Z "ProgressWindow open=candy, button=\"cancel\", buttonProc=NMProgWinXOPCancel," + win + "," + txt
		KillVariables /Z V_Progress
	elseif ( fraction == -2 )
		Execute /Z "ProgressWindow spin"
	elseif ( fraction == 0 )
		Execute /Z "ProgressWindow open, button=\"cancel\", buttonProc=NMProgWinXOPCancel," + win + "," + txt
		KillVariables /Z V_Progress
	endif
	
	if ( fraction >= 0 )
		Execute /Z "ProgressWindow frac=" + num2str( fraction )
	endif
	
	if ( fraction >= 1 )
		Execute /Z "ProgressWindow kill"
		KillVariables /Z V_Progress
		KillVariables /Z $NMDF+"ProgressLoopTimer"
		SetNMstr( NMDF+"ProgressStr", "" )
	endif
	
	Variable pflag = NumVarOrDefault( "V_Progress", 0 ) // progress flag, set to 1 if user hits "cancel" on ProgWin
	
	if ( pflag == 1 )
		Execute /Z "ProgressWindow kill"
	endif
	
	return pflag // returns the value of V_Progress ( WinProg XOP ), or 0 if it does not exist

End // NMProgWinXOP

Function NMProgWin61( fraction, progressStr ) // Igor Progress Window
	Variable fraction
	String progressStr
	
	// fraction of progress between 0 and 1, where ( 0 ) creates and ( 1 ) kills progress window
	// candy ( -1 ) create candy ( -2 ) spin candy ( 1 ) kill candy
	
	Variable xProgress, yProgress, x0
	
	if ( numtype( fraction ) > 0 )
		return -1
	endif
	
	if ( IgorVersion() < 6.1 )
		return -1 // not available
	endif
		
	if ( ( fraction > 0 ) && ( WinType( "NMProgressPanel" ) == 0 ) ) // progress display is missing
	
		return 0
		
	elseif ( fraction >= 1 ) // kill progress display
	
		NMProgWin61Kill()
		
		return 0
	
	elseif ( ( fraction == 0 ) || ( fraction == -1 ) ) // create progress display
	
		if ( WinType( "NMProgressPanel" ) != 0 )
			KillWindow NMProgressPanel
		endif
		
		xProgress = NMProgressX()
		yProgress = NMProgressY()
		
		x0 = NMProgWinWidth - 10
	
		NewPanel /FLT/K=1/N=NMProgressPanel /W=(xProgress,yProgress,xProgress+NMProgWinWidth,yProgress+NMProgWinHeight) as "NM Progress"
		
		TitleBox /Z NM_ProgWinTitle, pos={5,10}, size={x0,18}, fsize=9, fixedSize=1, win=NMProgressPanel
		TitleBox /Z NM_ProgWinTitle, frame=0, title=progressStr, anchor=MC, win=NMProgressPanel
	
		ValDisplay NM_ProgWinValDisplay, pos={5,40}, size={x0,18}, limits={0,1,0}, barmisc={0,0}, win=NMProgressPanel
		ValDisplay NM_ProgWinValDisplay, highColor=(1,34817,52428), win=NMProgressPanel // green
		
		if ( fraction == -1 )
			ValDisplay NM_ProgWinValDisplay, mode=4, value= _NUM:0, win=NMProgressPanel // candy stripe
		else
			ValDisplay NM_ProgWinValDisplay, mode=3, value= _NUM:0, win=NMProgressPanel // bar with no fractional part
		endif
		
		x0 = NMProgWinWidth / 2 - 40
	
		Button NM_ProgWinButtonStop, pos={NMProgButtonX0,NMProgButtonY0}, size={NMProgButtonXwidth,NMProgButtonYwidth}, title="Cancel", win=NMProgressPanel, proc=NMProgWin61Button
	
		SetActiveSubwindow _endfloat_
		
		DoUpdate /W=NMProgressPanel /E=1 // mark this as our progress window
		
		SetWindow NMProgressPanel, hook(nmprogwin61)=NMProgWin61Hook
		
		SetNMvar( NMDF+"NMProgressCancel", 0 )
		
		return 0
		
	elseif ( NumVarOrDefault( NMDF + "NMProgressCancel", 0 ) == 1 )
	
		NMProgWin61Kill()
	
		return 1 // cancel
	
	elseif ( WinType( "NMProgressPanel" ) == 7 )
	
		DoWindow /F NMProgressPanel
		DoUpdate /W=NMProgressPanel /E=1
		
		TitleBox /Z NM_ProgWinTitle, title=progressStr, win=NMProgressPanel
		DoUpdate /W=NMProgressPanel 
		
		if ( fraction > 0 )
			ValDisplay NM_ProgWinValDisplay,mode=3,value= _NUM:fraction,win=NMProgressPanel // update bar fraction
		elseif ( fraction < 0 )
			ValDisplay NM_ProgWinValDisplay,mode=4,value= _NUM:1,win=NMProgressPanel // update candy
		endif
	
	endif
	
	return 0

End // NMProgWin61

Function /S LogNotebookName(ldf)
	String ldf // log data folder
	
	return NMFolderNameCreate( ldf, nmPrefix = 1 ) + "_notebook"
	
End // LogNotebookName

Function /S LogVarList(ndf, prefix, varType)
	String ndf // notes data folder
	String prefix // prefix string ("H_" for header, "F_" for file)
	String varType // "numeric" or "string"

	Variable ocnt, vtype = 2
	String objName, olist = ""
	
	if (DataFolderExists(ndf) == 0)
		return ""
	endif
	
	if (StringMatch(varType, "string") == 1)
		vtype = 3
	endif
	
	olist = FolderObjectList(ndf, vtype)
	olist = RemoveFromList("FileType", olist)
	
	return olist

End // LogVarList

Function /T LogNotebookTabs(name)
	String name
	
	if (strlen(name) < 4)
		return "\t\t\t\t\t"
	elseif (strlen(name) < 7)
		return "\t\t\t\t"
	elseif (strlen(name) < 10)
		return "\t\t\t"
	elseif (strlen(name) < 13)
		return "\t\t"
	else
		return "\t"
	endif

End // LogNotebookTabs

Function /S LogSubfolderList(ldf)
	String ldf // log data folder
	
	return FolderObjectList(ldf, 4)
	
End // LogSubfolderList

Function LogNotebookFileVars(ndf, nbName)
	String ndf // notes data folder
	String nbName
	String name, tabs

	if ((WinType(nbName) == 0) || (DataFolderExists(ndf) == 0))
		return 0
	endif
	
	Variable icnt, value
	String objName, strvalue
	
	String nlist = LogVarList(ndf, "F_", "numeric")
	String slist = LogVarList(ndf, "F_", "string")
	String notelist = ListMatch(slist, "*note*", ";") // note variables
	
	notelist = SortList(notelist, ";", 16)
	
	slist = RemoveFromList(notelist, slist, ";")
	
	Notebook $nbName selection={endOfFile, endOfFile}
	Notebook $nbName text=(NMCR)
	Notebook $nbName text=(NMCR + "************************************************************")
	
	for (icnt = 0; icnt < ItemsInList(slist); icnt += 1) // string vars
		objName = StringFromList(icnt,slist)
		name = ReplaceString("H_", objName, "") + ":"
		name = UpperStr(ReplaceString("F_", name, ""))
		tabs = LogNotebookTabs(name)
		Notebook $nbName text=(NMCR + name + tabs + StrVarOrDefault(ndf+objName, ""))
	endfor
	
	Notebook $nbName text=(NMCR)
	
	for (icnt = 0; icnt < ItemsInList(nlist); icnt += 1) // numeric vars
	
		objName = StringFromList(icnt,nlist)
		name = UpperStr(ReplaceString("F_", objName, "") + ":")
		tabs = LogNotebookTabs(name)
		value = NumVarOrDefault(ndf+objName, Nan)
		strvalue = ""
		
		if (numtype(value) == 0)
			strvalue = num2str(value)
		endif
		
		Notebook $nbName text=(NMCR + name + tabs + strvalue)
		
	endfor
	
	Notebook $nbName text=(NMCR)
	
	for (icnt = 0; icnt < ItemsInList(notelist); icnt += 1) // note vars
	
		objName = StringFromList(icnt,notelist)
		name = UpperStr(ReplaceString("F_", objName, "") + ":")
		tabs = LogNotebookTabs(name)
		strvalue = StrVarOrDefault(ndf+objName, "")
		
		if (strlen(strvalue) > 0)
			Notebook $nbName text=(NMCR + name + tabs + strvalue)
		endif
		
	endfor
	
End // LogNotebookFileVars

Function /S LogTableName(ldf)
	String ldf // log data folder
	
	return NMFolderNameCreate( ldf, nmPrefix = 1 ) + "_table"
	
End // LogTableName

Function LogUpdateWaves(ldf) // create log waves from notes subfolders
	String ldf // log data folder
	Variable ocnt, icnt
	String objName, wname, flist, slist, nlist, tdf = ""
	
	ldf = LastPathColon(ldf,1)
	
	flist = LogSubfolderList(ldf)
	
	for (ocnt = 0; ocnt < ItemsInList(flist); ocnt += 1)
	
		objName = StringFromList(ocnt, flist)
		
		tdf = ldf + objName + ":"
		
		slist = LogVarList(tdf, "F_", "string")
		nlist = LogVarList(tdf, "F_", "numeric")
		
		for (icnt = 0; icnt < ItemsInList(slist); icnt += 1) // string vars
			objName = StringFromList(icnt,slist)
			wname = ldf+objName[2,inf]
			CheckNMtwave(wname, ocnt+1, "")
			SetNMtwave(wname, ocnt, StrVarOrDefault(tdf+objName, ""))
			Note /K $wname
			Note $wname, "File Notes"
		endfor
		
		for (icnt = 0; icnt < ItemsInList(nlist); icnt += 1) // numeric vars
			objName = StringFromList(icnt,nlist)
			wname = ldf+objName[2,inf]
			CheckNMwave(wname, ocnt+1, Nan)
			SetNMwave(wname, ocnt, NumVarOrDefault(tdf+objName, Nan))
			Note /K $wname
			Note $wname, "File Notes"
		endfor
		
		slist = LogVarList(tdf, "H_", "string")
		nlist = LogVarList(tdf, "H_", "numeric")
		
		for (icnt = 0; icnt < ItemsInList(slist); icnt += 1) // string vars
			objName = StringFromList(icnt,slist)
			wname = ldf+objName[2,inf]
			CheckNMtwave(wname, ocnt+1, "")
			SetNMtwave(wname, ocnt, StrVarOrDefault(tdf+objName, ""))
			Note /K $wname
			Note $wname, "Header Notes"
		endfor
		
		for (icnt = 0; icnt < ItemsInList(nlist); icnt += 1) // numeric vars
			objName = StringFromList(icnt,nlist)
			wname = ldf+objName[2,inf]
			CheckNMwave(wname, ocnt+1, Nan)
			SetNMwave(wname, ocnt, NumVarOrDefault(tdf+objName, Nan))
			Note /K $wname
			Note $wname, "Header Notes"
		endfor
		
	endfor

End // LogUpdateWaves

Function /S LogWaveList(ldf, type)
	String ldf // log data folder
	String type // ("H") Header ("F") File
	
	ldf = LastPathColon(ldf,1)
	
	Variable ocnt, add
	String objName, wnote = "", olist = ""
	
	do
	
		objName = GetIndexedObjName(ldf, 1, ocnt)
		
		if (strlen(objName) == 0)
			break // finished
		endif
		
		wnote = note($(ldf+objName))
		
		add = 1
		
		strswitch(type)
		
			case "H":
				if (StringMatch(wnote, "Header Notes") == 0)
					add = 0
				endif
				break
				
			case "F":
				if (StringMatch(wnote, "File Notes") == 0)
					add = 0
				endif
				break
				
		endswitch
		
		if (add == 1)
			olist = AddListItem(objName, olist, ";", inf)
		endif
		
		ocnt += 1
		
	while(1)
	
	return olist
	
End // LogWaveList

Function NMNoteVarByKey( wname, key )
	String wname // wave name with note
	String key // "thresh", "xbgn", "xend", etc...

	if ( WaveExists( $wname ) == 0 )
		return Nan
	endif
	
	return str2num( StringByKey( key, NMNoteString( wname ) ) )

End // NMNoteVarByKey

Function /S NMSetsNew( setList, [ prefixFolder, updateNM, history ] )
	String setList
	String prefixFolder
	Variable updateNM
	Variable history // print function command to history ( 0 ) no ( 1 ) yes
	
	Variable scnt, ccnt, numChannels
	String setName, strVarName, strVarList, setList2 = ""
	
	String vlist = NMCmdStr( setList, "" )
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		vlist = NMCmdStrOptional( "prefixFolder", prefixFolder, vlist )
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( ParamIsDefault( updateNM ) )
		updateNM = 1
	else
		vlist = NMCmdNumOptional( "updateNM", updateNM, vlist )
	endif
	
	if ( !ParamIsDefault( history ) && history )
		NMCmdHistory( "", vlist )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	for ( scnt = 0; scnt < ItemsInList( setList ); scnt += 1 )
	
		setName = StringFromList( scnt, setList )
		
		setName = NMCheckStringName( setName )
		
		if ( AreNMSets( setName, prefixFolder = prefixFolder ) )
			continue // already exists
		endif
		
		for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
		
			strVarName = NMSetsStrVarName( setName, ccnt, prefixFolder = prefixFolder )
			
			SetNMstr( strVarName, "" )
		
		endfor
		
		setList2 = AddListItem( setName, setList2, ";", inf )
		
	endfor
	
	if ( updateNM )
		UpdateNMWaveSelectLists( prefixFolder = prefixFolder )
		UpdateNMPanelSets( 1 )
	endif
	
	return setList2
	
End // NMSetsNew

Function NMSetsEqLockTableAdd( setName, arg1, operation, arg2, [ prefixFolder ] )
	String setName // e.g. "Set1"
	String arg1 // argument #1 ( e.g. "Set1" or "Group2" )
	String operation // operator ( "AND", "OR", "" )
	String arg2 // argument #1 ( e.g. "Set2" or "Group2" or "" )
	String prefixFolder
	
	// to kill a locked equation enter emptry strings, e.g. NMSetsEquationLock( "Set1", "", "", "" )
	
	Variable rvalue, icnt, ipnts, foundExisting, foundEmpty, kill
	String eq, wName
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	wName = NMSetsEqLockWaveName( prefixFolder = prefixFolder )
	
	if ( strlen( wName ) == 0 )
		return -1
	endif
	
	if ( ( strlen( arg1 ) == 0 ) && ( strlen( operation ) == 0 ) && ( strlen( arg2 ) == 0 ) )
		kill = 1
	endif
	
	if ( !WaveExists( $wName ) )
		Make /T/N=( 5, 4 ) $wName = ""
	endif
	
	Wave /T wtemp = $wName
	
	ipnts = DimSize( wtemp, 0 )
	
	eq = setName + " = " + arg1 + " " + operation + " " + arg2
	
	for ( icnt = 0 ; icnt < ipnts ; icnt += 1 )
	
		if ( StringMatch( setName, wtemp[ icnt ][ 0 ] ) )
		
			foundExisting = 1
			
			if ( kill )
			
				eq = wtemp[ icnt ][ 0 ] + " = " + wtemp[ icnt ][ 1 ] + " " + wtemp[ icnt ][ 2 ] + " " + wtemp[ icnt ][ 3 ]
			
				wtemp[ icnt ][ 0 ] = ""
				wtemp[ icnt ][ 1 ] = ""
				wtemp[ icnt ][ 2 ] = ""
				wtemp[ icnt ][ 3 ] = ""
				
				NMHistory( "NM Locked Sets : killed the following equation : " + eq )
			
			else // replace existing equation
			
				wtemp[ icnt ][ 1 ] = arg1
				wtemp[ icnt ][ 2 ] = operation
				wtemp[ icnt ][ 3 ] = arg2
			
			endif
			
		endif
	
	endfor
	
	if ( kill )
	
		return 0
		
	elseif ( foundExisting )
	
		NMHistory( "NM Locked Sets : added the following equation : " + eq )
		
		return 0
		
	endif
	
	// found no existing equation, so make new entry
	
	for ( icnt = 0 ; icnt < ipnts ; icnt += 1 )
		
		if ( strlen( wtemp[ icnt ][ 0 ] ) == 0 )
			foundEmpty = 1
			break
		endif
	
	endfor
	
	if ( !foundEmpty )
	
		Redimension /N=( ipnts+5, 4 ) wtemp
		
		for ( icnt = 0 ; icnt < ipnts ; icnt += 1 )
		
			if ( strlen( wtemp[ icnt ][ 0 ] ) == 0 )
				foundEmpty = 1
				break
			endif
		
		endfor
		
		if ( !foundEmpty )
			return -1 // shouldnt happen
		endif
		
	endif
	
	wtemp[ icnt ][ 0 ] = setName
	wtemp[ icnt ][ 1 ] = arg1
	wtemp[ icnt ][ 2 ] = operation
	wtemp[ icnt ][ 3 ] = arg2
	
	NMHistory( "NM Locked Sets : added the following equation : " + eq )
	
	return 0
	
End // NMSetsEqLockTableAdd

Function NMSetsEquation( setName, arg1, operation, arg2, [ prefixFolder, updateNM ] ) // Set = arg1 AND arg2
	String setName // e.g. "Set1"
	String arg1 // argument #1 ( e.g. "Set1" or "Group2" )
	String operation // operator ( "AND", "OR", "" )
	String arg2 // argument #1 ( e.g. "Set2" or "Group2" or "" )
	String prefixFolder
	Variable updateNM
	
	Variable numChannels, ccnt, grp1 = Nan, grp2 = Nan
	String wList1, wList2, thisfxn = GetRTStackInfo( 1 )
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	if ( ParamIsDefault( updateNM ) )
		updateNM = 1
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	if ( numChannels <= 0 )
		NMDoAlert( thisfxn + " Abort: no channels: " + num2istr( numChannels ) )
		return -1
	endif
	
	if ( strlen( setName ) == 0 )
		NMDoAlert( thisfxn + " Abort: parameter setName is undefined." )
		return -1
	endif
	
	if ( strlen( arg1 ) == 0 )
		NMDoAlert( thisfxn + " Abort: parameter arg1 is undefined." )
		return -1
	endif
	
	strswitch( operation )
	
		case "AND":
		case "&":
		case "&&":
			operation = "AND"
			break
			
		case "OR":
		case "|":
		case "||":
			operation = "OR"
			break
			
		default:
			operation = ""
			arg2 = ""
	
	endswitch
	
	if ( StringMatch( arg1[0,4], "Group" ) )
		grp1 = str2num( arg1[5,inf] )
	elseif ( !AreNMSets( arg1, prefixFolder = prefixFolder ) )
		NMDoAlert( thisfxn + " Abort: " + arg1 + " does not exist." )
		return -1
	endif
	
	if ( StringMatch( arg2[0,4], "Group" ) )
		grp2 = str2num( arg2[5,inf] )
	elseif ( ( strlen( arg2 ) > 0 ) && !AreNMSets( arg2, prefixFolder = prefixFolder ) )
		NMDoAlert( thisfxn + " Abort: " + arg2 + " does not exist." )
		return -1
	endif
	
	if ( AreNMSets( setName, prefixFolder = prefixFolder ) )
		NMSetsClear( setName, prefixFolder = prefixFolder, updateNM = 0, clearEqLock = 0 )
	endif
	
	for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
	
		wList1 = ""
		wList2 = ""
	
		if ( numtype( grp1 ) == 0 )
			wList1 = NMGroupsWaveList( grp1, ccnt, prefixFolder = prefixFolder )
		else
			wList1 = NMSetsWaveList( arg1, ccnt, prefixFolder = prefixFolder )
		endif
		
		if ( strlen( arg2 ) > 0 )
		
			if ( numtype( grp2 ) == 0 )
				wList2 = NMGroupsWaveList( grp2, ccnt, prefixFolder = prefixFolder )
			else
				wList2 = NMSetsWaveList( arg2, ccnt, prefixFolder = prefixFolder )
			endif
			
			strswitch( operation )
				
				case "AND":
					wList1 = NMAndLists( wList2, wList1, ";" )
					break
		
				case "OR":
					wList1 = NMAddToList( wList2, wList1, ";" )
					break
			
				default:
					return -1
	
			endswitch
		
		endif
		
		NMSetsWaveListAdd( wList1, setName, ccnt, prefixFolder = prefixFolder )
		
	endfor
	
	if ( updateNM )
		NMSetsEqLockTableUpdate( prefixFolder = prefixFolder )
		UpdateNMWaveSelectLists( prefixFolder = prefixFolder )
		UpdateNMPanelSets( 1 )
	endif
	
	return 0

End // NMSetsEquation

Function NMGroupsWaveNoteClear( [ prefixFolder ] )
	String prefixFolder

	Variable ccnt, wcnt, numChannels
	String wList, wName
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	numChannels = NumVarOrDefault( prefixFolder + "NumChannels", 0 )
	
	for ( ccnt = 0 ; ccnt < numChannels ; ccnt += 1 )
	
		wList = NMChanWaveList( ccnt, prefixFolder = prefixFolder )
		
		for ( wcnt = 0 ; wcnt < ItemsInList( wList ) ; wcnt += 1 )
		
			wName = StringFromList( wcnt, wList )
			z_GroupSetWaveNote( wName, NaN )
			
		endfor
		
	endfor
	
	return 0

End // NMGroupsWaveNoteClear

Function UpdateNMGroups( [ prefixFolder ] )
	String prefixFolder

	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif

	if ( ( strlen( prefixFolder ) > 0 ) && DataFolderExists( prefixFolder ) )
		UpdateNMWaveSelectLists( prefixFolder = prefixFolder )
	endif
	
	UpdateNMPanel( 0 )
	NMCurrentWaveSet( Nan, prefixFolder = prefixFolder, updateNM = 0 )
	NMSetsEqLockTableUpdate( prefixFolder = prefixFolder )
	UpdateNMPanelSets( 1 )
		
End // UpdateNMGroups

Function /S NMPrefixFolderStrVarListRemove( waveListToRemove, strVarName, channel )
	String waveListToRemove
	String strVarName
	Variable channel
	
	String wList
	
	if ( exists( strVarName ) != 2 )
		return ""
	endif

	wList = StrVarOrDefault( strVarName, "" )
	wList = RemoveFromList( waveListToRemove, wList, ";" )
	
	SetNMstr( strVarName, wList )
	
	return wList
	
End // NMPrefixFolderStrVarListRemove

Function /S NMPrefixFolderStrVarListAdd( waveListToAdd, strVarName, channel )
	String waveListToAdd
	String strVarName
	Variable channel
	
	String wList = StrVarOrDefault( strVarName, "" )
	
	wList = NMAddToList( waveListToAdd, wList, ";" )
	wList = OrderToNMChanWaveList( wList, channel )
	
	SetNMstr( strVarName, wList )
	
	return wList
	
End // NMPrefixFolderStrVarListAdd

Function NMNoteExists( wname, key )
	String wname // wave name with note
	String key // "thresh", "xbgn", "xend", etc...

	if ( WaveExists( $wname ) == 0 )
		return 0
	endif
	
	if ( numtype( NMNoteVarByKey( wname, key ) ) == 0 )
		return 1
	endif
	
	if ( strlen( NMNoteStrByKey( wname, key ) ) > 0 )
		return 1
	endif
	
	return 0
	
End // NMNoteExists

Function NMNoteVarReplace( wname, key, replace )
	String wname // wave name with note
	String key // "thresh", "xbgn", "xend", etc...
	Variable replace // replace string
	
	NMNoteStrReplace( wname, key, num2str( replace ) )
	
End // NMNoteVarReplace

Function NMDragUpdate2( xNamePath, yNamePath ) // Note, this must be called AFTER graphs have been auto scaled
	String xNamePath, yNamePath 
	
	Variable value, pnt
	
	if ( WaveExists( $xNamePath ) == 0 )
		return -1
	endif
	
	String gName = NMNoteStrByKey( yNamePath, "Graph" )
	String graphMinMax = NMNoteStrByKey( yNamePath, "Graph Axis MinMax" )
	String waveVarName = NMNoteStrByKey( yNamePath, "Wave Variable Name" )
	String varName = NMNoteStrByKey( yNamePath, "Variable Name" )
	
	if ( WinType( gName ) != 1 )
		return -1
	endif

	Wave dragX = $xNamePath
	Wave dragY = $yNamePath
	
	if ( NMVarGet( "DragOn" ) == 1 )
	
		if ( NMVarGet( "AutoDoUpdate" ) == 1 )
			DoUpdate /W=$gName
		endif
		
		if ( StringMatch( graphMinMax, "min" ) == 1 )
			value = -inf
		else
			value = inf
		endif
		
		value = NMDragVariableGet( yNamePath, value )
		
		if ( numtype( value ) == 0 )
		
			dragX = value
			
		elseif ( numtype( value ) == 1 ) // inf
		
			GetAxis /W=$gName/Q bottom
			
			if ( StringMatch( graphMinMax, "min" ) == 1 )
				dragX = V_min
			else
				dragX = V_max
			endif
		
		endif
		
		GetAxis /W=$gName/Q left
		
		dragY[ 0 ] = V_min
		dragY[ 1 ] = V_max
	
	else
	
		dragX = Nan
		dragY = Nan
		
	endif

End // NMDragUpdate

Function /S FileExtCheck( istring, ext, yes )
	String istring // string value, such as file name "myfile.txt"
	String ext // file extension such as ".txt"; ( ".*" ) for any ext
	Variable yes // ( 0 ) has no extension ( 1 ) has extension
	
	Variable icnt, ipnt = -1, sl = strlen( ext )
	
	yes = BinaryCheck( yes )
	
	for ( icnt = strlen( istring ) - 1; icnt >= 0; icnt -= 1 )
		if ( StringMatch( istring[ icnt, icnt ], "." ) )
			ipnt = icnt
		endif
		if ( StringMatch( istring[ icnt, icnt ], ":" ) )
			break
		endif
	endfor
	
	switch( yes )
	
		case 0:
			if ( StringMatch( ext, ".*" ) && ( ipnt >= 0 ) ) // any extension
				istring = istring[ 0, ipnt - 1 ] // remove extension
			elseif ( StringMatch( istring[ strlen( istring ) - sl, inf ], ext ) )
				istring = istring[ 0, strlen( istring ) - sl - 1 ] // remove extension
			endif
			break
			
		case 1:
			if ( ipnt >= 0 )
				istring = istring[ 0, ipnt-1 ] + ext // replace extension
			else
				istring += ext // add extension
			endif
			break
			
		default:
			return ""
			
	endswitch

	return istring

End // FileExtCheck

Function NMKillWindows( folderName )
	String folderName
	
	Variable wcnt
	String wName
	
	if ( ( strlen( folderName ) == 0 ) || ( IsNMDataFolder( folderName ) == 0 ) )
		return -1
	endif
	
	folderName = GetPathName( folderName, 0 )
	
	String wlist = WinList( "*" + folderName + "*", ";", "" )
	
	for ( wcnt = 0; wcnt < ItemsInList( wlist ); wcnt += 1 )
	
		wName = StringFromList( wcnt,wlist )
		
		if ( ( strlen( wName ) > 0 ) && ( winType( wName ) > 0 ) )
			DoWindow /K $wName
		endif
		
	endfor
	
	return 0
	
End // NMKillWindows

Function NMFolderWinKill( folderName )
	String folderName
	
	String wname
	Variable wcnt
	
	if ( IsNMDataFolder( folderName ) == 0 )
		return -1
	endif
	
	String wlist = WinList( "*" + NMFolderListName( folderName ) + "_" + "*", ";", "" )
	
	for ( wcnt = 0; wcnt < ItemsInList( wlist ); wcnt += 1 )
		
		wname = StringFromList( wcnt,wlist )
		
		if ( WinType( wname ) == 0 )
			continue
		endif
		
		DoWindow /K $wname
		
	endfor
	
	return 0
	
End // NMFolderWinKill

Function NMFolderCloseAlert( folderName )
	String folderName

	String txt = "Failed to close data folder " + NMQuotes( GetPathName( folderName, 0 ) )
	txt += ". Waves that reside in this folder may be currently displayed in a graph or table"
	txt += ", or may be locked."
	
	NMDoAlert( txt )

End // NMFolderCloseAlert

Function /S NMFolderChangeToFirst( [ update ] )
	Variable update
	
	if ( ParamIsDefault( update ) )
		update = 1
	endif

	String fList = NMDataFolderList()
		
	if ( ItemsInList( fList ) > 0 )
		return NMFolderChange( StringFromList( 0, fList ), update = update ) // change to first data folder
	else
		NMFolderNew( "", update = update )
	endif
		
End // NMFolderChangeToFirst

Static Function /S S_NMB_ReadString( refnum )
	Variable refnum
	
	String str2read = ""
	
	Variable /G dumvar
	
	FBinRead /B=2/F=2 refnum, dumvar
	
	Variable icnt, nobjchar = dumvar

	for ( icnt = 0; icnt < nobjchar; icnt += 1 )
		FBinRead /B=2/F=1 refnum, dumvar
		str2read += num2char( dumvar )
	endfor
	
	return str2read

End // S_NMB_ReadString

Static Function S_NMB_ReadObject( file, makeflag )
	String file // file name
	String makeflag // string variables | numeric variables | text waves | numeric waves
	// "1111" to make all variables and waves
	// "0001" to make only numeric waves
	
	Variable icnt, jcnt, nobjchar, opnts, otype, slength, refnum, lx, dx
	String objName, dumstr, wnote
	
	Variable /G dumvar
	
	String saveDF = GetDataFolder( 1 ) // save current directory 
	
	Open /R/T="IGBW" refnum as file
		
	do
		
		FBinRead /B=2/F=1 refnum, dumvar
		otype = dumvar

		if ( otype == -1 )
			break // NM Object EOF
		endif
		
		if ( ( otype < 0 ) || ( otype > 4 ) )
			break // something wrong
		endif
		
		objName = S_NMB_ReadString( refnum )
		
		if ( strlen( objName ) == 0 )
			break // something wrong
		endif
		
		switch( otype )
		
			case 0: // text wave ( 1D )
				wnote = S_NMB_ReadString( refnum ) // read wave note
				
				FBinRead /B=2/F=3 refnum, dumvar
				opnts = dumvar
				
				if ( StringMatch( makeflag[ 2, 2 ], "1" ) ) // make wave
					Make /T/O/N=( opnts ) $objName
					Wave /T tWave = $objName
					Note tWave, wnote
				endif
				
				for ( icnt = 0; icnt < opnts; icnt += 1 ) // read wave points
					dumstr = S_NMB_ReadString( refnum )
					if ( StringMatch( makeflag[ 2, 2 ], "1" ) )
						tWave[ icnt ] = dumstr
					endif
				endfor
				
				break
				
			case 1: // numeric wave ( 1D )
				
				wnote = S_NMB_ReadString( refnum ) // read wave note
				
				FBinRead /B=2/F=4 refnum, dumvar // read leftx scaling
				lx = dumvar
				
				FBinRead /B=2/F=4 refnum, dumvar // read deltax scaling
				dx = dumvar
				
				FBinRead /B=2/F=3 refnum, dumvar // read numpnts
				opnts = dumvar
				
				if ( StringMatch( makeflag[ 3, 3 ], "1" ) ) // make wave
					Make /O/N=( opnts ) $objName
					Wave nWave = $objName
					Setscale /P x lx, dx, nWave
					Note nWave, wnote
				endif
				
				for ( icnt = 0; icnt < opnts; icnt += 1 ) // read wave points
					FBinRead /B=2/F=4 refnum, dumvar
					if ( StringMatch( makeflag[ 3, 3 ], "1" ) )
						nWave[ icnt ] = dumvar
					endif
				endfor
				
				break
				
			case 2: // numeric variable
				FBinRead /B=2/F=4 refnum, dumvar
				if ( StringMatch( makeflag[ 1, 1 ], "1" ) )
					SetNMvar( objName, dumvar )
				endif
				break
				
			case 3: // string variable
				dumstr = S_NMB_ReadString( refnum )
				if ( StringMatch( makeflag[ 0, 0 ], "1" ) )
					SetNMstr( objName, dumstr )
				endif
				break
				
			case 4: // folder type
				NewDataFolder /O/S $( saveDF+objName )
				break
			
		endswitch
		
	while ( 1 )
	
	KillVariables /Z dumvar
	
	Close refnum

End // S_NMB_ReadObject

Function /S CopyWavesTo( fromFolder, toFolder, newPrefix, xbgn, xend, wList, alert )
	String fromFolder // copy waves from
	String toFolder // copy waves to
	String newPrefix // new wave prefix, ( "" ) for same as source waves
	Variable xbgn, xend // x-axis window begin and end, use ( -inf, inf ) for all
	String wList // wave list, or ( "_All_" ) for all waves
	Variable alert // ( 0 ) no alert ( 1 ) alert if overwriting
	
	Variable wcnt, numWaves, overwrite, first = 1
	String wName, dname, fName, outList = "", badList = wList
	
	if ( DataFolderExists( fromFolder ) == 0 )
		return NM2ErrorStr( 30, "fromFolder", fromFolder )
	endif
	
	if ( DataFolderExists( toFolder ) == 0 )
		return NM2ErrorStr( 30, "toFolder", toFolder )
	endif
	
	if ( numtype( xbgn ) > 0 )
		xbgn = -inf
	endif
	
	if ( numtype( xend ) > 0 )
		xend = inf
	endif
	
	if ( StringMatch( wList, "_All_" ) == 1 )
		wList = NMFolderWaveList( fromFolder, "*", ";", "", 0 )
	endif
	
	numWaves = ItemsInList( wList )
	
	if ( numWaves == 0 )
		return ""
	endif
	
	fromFolder = ParseFilePath( 2, fromFolder, ":", 0, 0 )
	toFolder = ParseFilePath( 2, toFolder, ":", 0, 0 )
	
	for ( wcnt = 0; wcnt < numWaves; wcnt += 1 )
	
		if ( NMProgressTimer( wcnt, numWaves, "Copying Waves..." ) == 1 )
			break // cancel wave loop
		endif
	
		wName = StringFromList( wcnt, wList )
	
		dname = toFolder + newPrefix + wName
		
		if ( ( WaveExists( $dname ) == 1 ) && ( alert == 1 ) && ( first == 1 ) )
		
			fName = GetPathName( toFolder, 0 )
		
			DoAlert 1, "CopyWavesTo Alert: wave(s) with the same name already exist in folder " + fName + ". Do you want to over-write them?"
			
			first = 0
			
			if ( V_flag == 1 )
				overwrite = 1
			endif
			
		endif
		
		if ( ( WaveExists( $dname ) == 1 ) && ( alert == 1 ) && ( overwrite == 0 ) )
			continue
		endif
		
		if ( WaveExists( $( fromFolder+wName ) ) == 0 )
			continue
		endif
		
		Wave wtemp = $( fromFolder+wName )
		
		Duplicate /O/R=( xbgn, xend ) wtemp $dname
		
		outList = AddListItem( dname, outList, ";", inf )
		
		badList = RemoveFromList( wName, badList )
		
	endfor
	
	//NMUtilityAlert( thisfxn, badList )
	
	return outList

End // CopyWavesTo

Function PrintNMFolderDetails( folder )
	String folder
	
	Variable tempval
	String tempstr
	
	folder = CheckNMFolderPath( folder )

	if ( DataFolderExists( folder ) == 0 )
		return -1
	endif
	
	NMHistory( "Data File: " + StrVarOrDefault( folder+"CurrentFile", "Unknown Data File" ) )
	NMHistory( "File Type: " + StrVarOrDefault( folder+"DataFileType", "Unknown" ) )
	
	tempstr = StrVarOrDefault( folder+"AcqMode", "" )
	
	if ( strlen( tempstr ) > 0 )
		NMHistory( "Acquisition Mode: " + tempstr )
	endif
	
	tempstr = StrVarOrDefault( folder+"WavePrefix", "" )
	
	if ( strlen( tempstr ) > 0 )
		NMHistory( "Data Prefix Name: " + tempstr )
	endif
	
	tempval = NumVarOrDefault( folder+"NumChannels", Nan )
	
	if ( numtype( tempval ) == 0 )
		NMHistory( "Channels: " + num2istr( tempval ) )
	endif

	tempval = NumVarOrDefault( folder+"NumWaves", Nan )
	
	if ( numtype( tempval ) == 0 )
		NMHistory( "Waves per Channel: " + num2istr( tempval ) )
	endif
	
	tempval = NumVarOrDefault( folder+"SamplesPerWave", Nan )
	
	if ( numtype( tempval ) == 0 )
		NMHistory( "Samples per Wave: " + num2istr( tempval ) )
	endif
	
	tempval = NumVarOrDefault( folder+"SampleInterval", Nan )
	
	if ( numtype( tempval ) == 0 )
		NMHistory( "Sample Interval ( ms ): " + num2str( tempval ) )
	endif
	
	NMHistory( " " )

End // PrintNMFolderDetails

Function NMImport( file, xnewFolder ) // main import data function
	String file
	Variable xnewFolder // NOT USED ANYMORE
	
	Variable success, amode, saveprompt, totalNumWaves, numChannels
	String acqMode, wPrefix, wList, prefixFolder
	String df = ImportDF()
	String folder = GetDataFolder( 1 ) // import into current data folder
	
	if ( CheckCurrentFolder() == 0 )
		return 0
	endif
	
	Variable importPrompt = NMVarGet( "ImportPrompt" )
	String saveWavePrefix = StrVarOrDefault( "WavePrefix", NMStrGet( "WavePrefix" ) )
	
	if ( FileExistsAndNonZero( file ) == 0 )
		NMDoAlert( "Error: external data file has not been selected." )
		return -1
	endif
	
	success = CallNMImportFileManager( file, df, "", "header" )
	
	if ( success <= 0 )
		return -1
	endif
	
	totalNumWaves = NumVarOrDefault( df+"TotalNumWaves", 0 )
	numChannels = NumVarOrDefault( df+"NumChannels", 1 )
	
	SetNMvar( df+"WaveBgn", 0 )
	SetNMvar( df+"WaveEnd", ceil( totalNumWaves / numChannels ) - 1 )
	CheckNMstr( df+"WavePrefix", NMStrGet( "WavePrefix" ) )
	
	if ( importPrompt == 1 )
		NMImportPanel() // open panel to display header info and request user input
	endif
	
	if ( NumVarOrDefault( df+"WaveBgn", -1 ) < 0 ) // user aborted
		return -1
	endif
	
	wPrefix = StrVarOrDefault( df+"WavePrefix", NMStrGet( "WavePrefix" ) )
	
	SetNMvar( "WaveBgn", NumVarOrDefault( df+"WaveBgn", 0 ) )
	SetNMvar( "WaveEnd", NumVarOrDefault( df+"WaveEnd", -1 ) )
	
	SetNMstr( "WavePrefix", wPrefix )
	SetNMstr( "CurrentFile", file )
	
	success = CallNMImportFileManager( file, folder, StrVarOrDefault( df+"DataFileType", "" ), "Data" ) // now read the data
	
	if ( success < 0 ) // user aborted
		return -1
	endif
	
	PrintNMFolderDetails( GetDataFolder( 1 ) )
	NMSet( wavePrefixNoPrompt = wPrefix )
	
	prefixFolder = CurrentNMPrefixFolder()
	
	acqMode = StrVarOrDefault( df+"AcqMode", "" )
	
	amode = str2num( acqMode[0] )
	
	if ( ( numtype( amode ) == 0 ) && ( amode == 3 ) ) // gap free
	
		if ( NumVarOrDefault( df+"ConcatWaves", 0 ) == 1 )
		
			NMChanSelect( "All" )
		
			wList = NMConcatWaves( "C_Record" )
			
			if ( ItemsInList( wList ) == NMNumWaves() * NMNumChannels() )
				NMDeleteWaves( noAlerts = 1 )
			else
				NMDoAlert( "Alert: waves may have not been properly concatenated." )
			endif
			
			NMSet( wavePrefixNoPrompt = "C_Record" )
			
		else
			NMTimeScaleMode( 1 ) // make continuous
		endif
		
	endif
	
	return 1

End // NMImport

Function /S FindCommonPrefix( wList )
	String wList
	
	Variable icnt, jcnt, thesame
	String wname, wname2, prefix = ""
	
	wname = StringFromList( 0, wList )
	
	for ( icnt = 0 ; icnt < strlen( wname ) ; icnt += 1 )
	
		thesame = 1
		
		for ( jcnt = 1 ; jcnt < ItemsInList( wList ) ; jcnt += 1 )
		
			wname2 = StringFromList( jcnt, wList )
			
			if ( StringMatch( wname[icnt, icnt], wname2[icnt,icnt] ) == 0 )
				return prefix
			endif
		
		endfor
		
		prefix += wname[icnt, icnt]
	
	endfor
	
	return prefix
	
End // FindCommonPrefix

Function /S SequenceToRangeStr( seqList, seperator )
	String seqList // e.g. "0;1;2;3;5;6;7;"
	String seperator // "-" or ","
	
	Variable icnt, items, seqNum, first = NaN, last, next, foundRange
	String range, rangeList = ""
	
	items = ItemsInList( seqList )
	
	for ( icnt = 0 ; icnt < items ; icnt += 1 )
		
		seqNum = str2num( StringFromList( icnt, seqList ) )
		
		if ( numtype( seqNum ) > 0 )
			return seqList // error
		endif
		
		if ( numtype( first ) > 0 )
		
			first = seqNum
			next = first + 1
			foundRange = 0
			
		else
			
			if ( seqNum == next )
			
				next += 1
				foundRange = 1
				last = seqNum
				
				if ( icnt < items - 1 )
					continue
				endif
				
			endif
			
			if ( ( foundRange == 1 ) && ( last > first + 1 ) )
				
				range = num2str( first ) + seperator + num2str( last )
				rangeList += range + ";"
				
			else
			
				rangeList += num2str( first ) + ";"
				
				if ( last != first )
					rangeList += num2str( last ) + ";"
				endif
				
			endif
			
			if ( ( seqNum != last ) && ( icnt == items - 1 ) )
				rangeList += num2str( seqNum ) + ";"
			endif
			
			first = seqNum
			next = first + 1
			foundRange = 0
			
		endif
		
		last = seqNum
	
	endfor
		
	return rangeList // e.g. "0-3;5-7;"
	
End // SequenceToRangeStr

Function NMProgressX()

	Variable xProgress = NMVarGet( "xProgress" )
	Variable xLimit = NMComputerPixelsX() - NMProgWinWidth
	
	if ( numtype( xProgress ) > 0 )
		xProgress = ( NMComputerPixelsX() - 2 * NMProgWinWidth ) / 2
	else
		xProgress = max( xProgress, 0 )
		xProgress = min( xProgress, xLimit )
	endif
	
	return xProgress
	
End // NMProgressX

Function NMProgressY()
	
	Variable yProgress = NMVarGet( "yProgress" )
	Variable yLimit = NMComputerPixelsY() - NMProgWinHeight
	
	if ( numtype( yProgress ) > 0 )
		yProgress = 0.5 * NMComputerPixelsY()
	else
		yProgress = max( yProgress, 0 )
		yProgress = min( yProgress, yLimit )
	endif
	
	return yProgress

End // NMProgressY

Function NMProgWin61Kill()

	if ( WinType( "NMProgressPanel" ) == 0 )
		return 0
	endif
	
	GetWindow NMProgressPanel, wsize
	
	Variable scale = ScreenResolution / 72
	
	SetNMvar( NMDF+"xProgress", V_left * scale )
	SetNMvar( NMDF+"yProgress", V_top * scale ) // save progress window position
	
	KillWindow NMProgressPanel

	return 0
	
End // NMProgWin61Kill

Function SetNMtwave( wname, pointNum, strValue )
	String wname
	Variable pointNum // point to set, or ( -1 ) all points
	String strValue
	
	String path = GetPathName( wname, 1 )
	String swname = GetPathName( wname, 0 )
	
	if ( strlen( wname ) == 0 )
		NM2Error( 21, "wname", wname )
		return -1
	endif
	
	if ( strlen( swname ) > 31 )
		NM2Error( 3, "wname", swname )
		return -1
	endif
	
	if ( numtype( pointNum ) > 0 )
		NM2Error( 10, "pointNum", num2istr( pointNum ) )
		return -1
	endif
	
	if ( ( strlen( path ) > 0 ) && ( DataFolderExists( path ) == 0 ) )
		NM2Error( 30, "wname", wname )
		return -1
	endif
	
	if ( WaveExists( $wname ) == 0 )
		CheckNMtwave( wname, pointNum+1, strValue )
	endif
	
	Wave /T tempWave = $wname
	
	if ( pointNum < 0 )
		tempWave = strValue
	elseif ( pointNum < numpnts( tempWave ) )
		tempWave[ pointNum ] = strValue
	endif
	
	return 0

End // SetNMtwave

Function SetNMwave( wname, pointNum, value )
	String wname
	Variable pointNum // point to set, or ( -1 ) all points
	Variable value
	
	String path = GetPathName( wname, 1 )
	String swname = GetPathName( wname, 0 )
	
	if ( strlen( wname ) == 0 )
		NM2Error( 21, "wname", wname )
		return -1
	endif
	
	if ( strlen( swname ) > 31 )
		NM2Error( 3, "wname", swname )
		return -1
	endif
	
	if ( numtype( pointNum ) > 0 )
		NM2Error( 10, "pointNum", num2istr( pointNum ) )
		return -1
	endif
	
	if ( ( strlen( path ) > 0 ) && ( DataFolderExists( path ) == 0 ) )
		NM2Error( 30, "wname", wname )
		return -1
	endif
	
	if ( WaveExists( $wname ) == 0 )
		CheckNMwave( wname, pointNum+1, Nan )
	endif
	
	Wave tempWave = $wname
	
	if ( pointNum < 0 )
		tempWave = value
	elseif ( pointNum < numpnts( tempWave ) )
		tempWave[ pointNum ] = value
	endif
	
	return 0

End // SetNMwave

Function NMSetsClear( setList, [ prefixFolder, updateNM, clearEqLock, history ] )
	String setList // set name list, or "All"
	String prefixFolder
	Variable updateNM
	Variable clearEqLock
	Variable history // print function command to history ( 0 ) no ( 1 ) yes
	
	Variable scnt, icnt
	String setName, strVarList, eList
	
	String vlist = NMCmdStr( setList, "" )
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		vlist = NMCmdStrOptional( "prefixFolder", prefixFolder, vlist )
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( ParamIsDefault( updateNM ) )
		updateNM = 1
	else
		vlist = NMCmdNumOptional( "updateNM", updateNM, vlist )
	endif
	
	if ( ParamIsDefault( clearEqLock ) )
		clearEqLock = 1
	else
		vlist = NMCmdNumOptional( "clearEqLock", clearEqLock, vlist )
	endif
	
	if ( !ParamIsDefault( history ) && history )
		NMCmdHistory( "", vlist )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return -1
	endif
	
	if ( StringMatch( setList, "All" ) )
		setList = NMSetsList()
	endif
	
	if ( clearEqLock )
		NMSetsEqLockTableClear( setList, prefixFolder = prefixFolder )
	endif
	
	eList = NMSetsListCheck( "NMSetsClear", setList, 1, prefixFolder = prefixFolder )
	
	if ( ItemsInList( eList ) > 0 )
		return -1
	endif
	
	for ( scnt = 0; scnt < ItemsInList( setList ); scnt += 1 )
	
		setName = StringFromList( scnt, setList )
		strVarList = NMSetsStrVarSearch( setName, 1, prefixFolder = prefixFolder )
		
		for ( icnt = 0 ; icnt < ItemsInList( strVarList ) ; icnt += 1 ) 
			SetNMstr( StringFromList( icnt, strVarList ) , "" )
		endfor
	
	endfor
		
	if ( updateNM )
		NMSetsEqLockTableUpdate( prefixFolder = prefixFolder )
		UpdateNMWaveSelectLists( prefixFolder = prefixFolder )
		UpdateNMPanelSets( 1 )
	endif
	
	return 0
	
End // NMSetsClear

Function NMDragVariableGet( wName, defaultValue )
	String wName
	Variable defaultValue
	
	Variable pnt
	
	if ( WaveExists( $wName ) == 0 )
		return defaultValue
	endif
	
	String waveVarName = NMNoteStrByKey( wName, "Wave Variable Name" )
	String varName = NMNoteStrByKey( wName, "Variable Name" )
	
	if ( exists( varName ) != 2 )
		return defaultValue
	endif
	
	if ( WaveExists( $waveVarName ) == 1 )
	
		Wave wtemp = $waveVarName 
		
		pnt = NumVarOrDefault( varName, Nan )
		
		if ( ( pnt >= 0 ) && ( pnt < numpnts( wtemp ) ) )
			return wtemp[ pnt ]
		endif
	
	endif
	
	return NumVarOrDefault( varName, defaultValue )
	
End // NMDragVariableGet

Function /S NMSetsListCheck( fxnName, setList, alert, [ prefixFolder ] )
	String fxnName // calling function name for alert
	String setList // list to check
	Variable alert // ( 0 ) no ( 1 ) yes
	String prefixFolder
	
	Variable scnt
	String setName, badList = ""
	
	if ( ParamIsDefault( prefixFolder ) )
		prefixFolder = CurrentNMPrefixFolder()
	else
		prefixFolder = CheckNMPrefixFolderPath( prefixFolder )
	endif
	
	if ( strlen( prefixFolder ) == 0 )
		return ""
	endif
	
	for ( scnt = 0 ; scnt < ItemsInList( setList ) ; scnt += 1 )
	
		setName = StringFromList( scnt, setList )
		
		if ( ItemsInList( NMSetsStrVarSearch( setName, 0, prefixFolder = prefixFolder ) ) == 0 )
			badList += setName + ";" 
		endif
		
	endfor
	
	if ( alert && ( ItemsInList( badList ) > 0 ) )
		NMDoAlert( fxnName + " Error: the following set(s) do not exist: " + badList )
	endif
	
	return badList

End // NMSetsListCheck

Function ReadPClampHeader( file, df )
	String file // external ABF data file
	String df // NM data folder where everything is imported
	
	Variable format = ReadPclampFormat( file )
	
	df = ParseFilePath( 2, df, ":", 0, 0 )
	
	switch( format )
		case 1:
		case 2:
			break
		default:
			Print "Import File Aborted: file not of Pclamp format"
			return -1
	endswitch
	
	if ( ReadPclampXOPExists() )
		return ReadPClampHeaderXOP( file, df )
	endif
	
	ReadPclampXOPAlert()
	
	switch( format )
		case 1:
			return ReadPClampHeader1( file, df )
		case 2:
			return ReadPClampHeader2( file, df )
	endswitch
	
	return -1
	
End // ReadPClampHeader

Function ReadPclampXOPExists()

	if ( ABF_XOP_ON && ( exists( "ReadPclamp" ) == 4 ) )
		return 1
	endif

	return 0
	
End // ReadPclampXOPExists

Static Function ReadPClampHeaderXOP( file, df )
	String file // external ABF data file
	String df // NM data folder where everything is imported
	
	Variable OK
	
	String saveDF = GetDataFolder( 1 )
	
	df = ParseFilePath( 2, df, ":", 0, 0 )
	
	String hdf = df + ABF_SUBFOLDERNAME + ":"
	
	NewDataFolder /O/S $RemoveEnding( hdf, ":" )
	
	Execute /Z "ReadPclamp /H " + NMQuotes( ReadPClampFileC( file ) ) // import header
	
	if ( WaveExists( ABF_nADCSamplingSeq ) )
		OK = 1
	endif
	
	SetDataFolder $saveDF // back to original folder
	
	if ( !OK )
		return -1
	endif
	
	ReadPclampHeaderUpdateNM( df, hdf )
	
	return 1

End // ReadPClampHeaderXOP

Static Function ReadPclampXOPAlert()

	String alertStr0, alertStr1, alertStr2, alertStr3

	if ( ReadPclampXOPExists() || StringMatch( NMComputerType(), "mac" ) )
		return 0
	endif
	
	if ( NumVarOrDefault( NMDF + "ReadPclampXOPAlertOff", 0 ) == 1 )
		return 0
	endif
	
	if ( ABF_XOP_ON == 0 )
		return 0
	endif
	
	alertStr0 = "PC / Windows users:  use the Read Pclamp XOP to import your data faster. "
	alertStr1 = "Download from http://neuromatic.thinkrandom.com/stuff/. "
	alertStr2 = "Instructions are inside the zip file. "
	alertStr3 = "This message has been printed to Igor's history window."
	
	Print alertStr0
	Print alertStr1
	Print alertStr2
	Print " "

	NMDoAlert( alertStr0 + alertStr1 + alertStr2 + alertStr3 )
	
	SetNMvar( NMDF + "ReadPclampXOPAlertOff", 1 ) // alert only once

End // ReadPclampXOPAlert

Static Function ReadPClampHeader1( file, df )
	String file // external ABF data file
	String df // NM data folder where everything is imported

	Variable ccnt, icnt
	Variable numChannels, headerSize
	
	Variable readAll = NumVarOrDefault( NMDF+"ABF_HeaderReadAll", 0 )
	
	if ( ReadPclampFormat( file ) != 1 )
		return -1
	endif
	
	df = ParseFilePath( 2, df, ":", 0, 0 )
	
	String hdf = df + ABF_SUBFOLDERNAME + ":"
	
	if ( readAll )
		NMProgressCall( -1, "Reading ABF Header ..." )
	endif
	
	NewDataFolder /O $RemoveEnding( hdf, ":" ) // create subfolder in current directory
	
	// File ID and Size information
	
	Variable /G $hdf +"lFileSignature" = ReadPclampVar( file, "long", 0 )
	Variable /G $hdf +"fFileVersionNumber" = ReadPclampVar( file, "float", 4 )
	Variable /G $hdf +"nOperationMode" = ReadPclampVar( file, "short", 8 ) // NEED THIS
	Variable /G $hdf +"lActualAcqLength" = ReadPclampVar( file, "long", 10 ) // NEED THIS
	Variable /G $hdf +"nNumPointsIgnored" = ReadPclampVar( file, "short", 14 )
	Variable /G $hdf +"lActualEpisodes" = ReadPclampVar( file, "long", 16 )
	Variable /G $hdf +"lFileStartDate" = ReadPclampVar( file, "long", 20 ) // NEED THIS
	Variable /G $hdf +"lFileStartTime" = ReadPclampVar( file, "long", 24 ) // NEED THIS
	Variable /G $hdf +"lStopwatchTime" = ReadPclampVar( file, "long", 28 ) // NEED THIS
	Variable /G $hdf +"fHeaderVersionNumber" = ReadPclampVar( file, "float", 32 )
	Variable /G $hdf +"nFileType" = ReadPclampVar( file, "short", 36 ) // FileFormat
	Variable /G $hdf +"nMSBinFormat" = ReadPclampVar( file, "short", 38 )
	
	//
	// File Structure info
	//
	
	Variable /G $hdf +"lDataSectionPtr" = ReadPclampVar( file, "long", 40 ) // DataPointer, NEED THIS
	
	SetNMvar( df+"DataPointer", NumVarOrDefault( hdf +"lDataSectionPtr", -1 ) )
	
	if ( readAll )
		Variable /G $hdf +"lTagSectionPtr" = ReadPclampVar( file, "long", 44 )
		Variable /G $hdf +"lNumTagEntries" = ReadPclampVar( file, "long", 48 )
		Variable /G $hdf +"lScopeConfigPtr" = ReadPclampVar( file, "long", 52 )
		Variable /G $hdf +"lNumScopes" = ReadPclampVar( file, "long", 56 )
		Variable /G $hdf +"lDACFilePtr" = ReadPclampVar( file, "long", 60 )
		Variable /G $hdf +"lDACFileNumEpisodes" = ReadPclampVar( file, "long", 64 )
		Variable /G $hdf +"lDeltaArrayPtr" = ReadPclampVar( file, "long", 72 )
		Variable /G $hdf +"lNumDeltas" = ReadPclampVar( file, "long", 76 )
		Variable /G $hdf +"lVoiceTagPtr" = ReadPclampVar( file, "long", 80 )
		Variable /G $hdf +"lVoiceTagEntries" = ReadPclampVar( file, "long", 84 )
		Variable /G $hdf +"lSynchArrayPtr" = ReadPclampVar( file, "long", 92 )
		Variable /G $hdf +"lSynchArraySize" = ReadPclampVar( file, "long", 96 )
	endif
	
	Variable /G $hdf +"nDataFormat" = ReadPclampVar( file, "short", 100 ) // DataFormat, NEED THIS
	Variable /G $hdf +"nSimultaneousScan" = ReadPclampVar( file, "short", 102 )
	
	if ( readAll && ( NMProgressCall( -2, "Reading ABF Header ..." ) == 1 ) )
		return -1 // cancel
	endif
		
	//
	// Trial Hierarchy Information
	//
	
	Variable /G $hdf +"nADCNumChannels" = ReadPclampVar( file, "short", 120 ) // NumChannels, NEED THIS
	Variable /G $hdf +"fADCSampleInterval" = ReadPclampVar( file, "float", 122 ) // SampleInterval, NEED THIS
	Variable /G $hdf +"fADCSecondSampleInterval" = ReadPclampVar( file, "float", 126 ) // SplitClock // NEED THIS
	Variable /G $hdf +"fSynchTimeUnit" = ReadPclampVar( file, "float", 130 )
	Variable /G $hdf +"fSecondsPerRun" = ReadPclampVar( file, "float", 134 )
	Variable /G $hdf +"lNumSamplesPerEpisode" = ReadPclampVar( file, "long", 138 ) // SamplesPerWave
	Variable /G $hdf +"lPreTriggerSamples" = ReadPclampVar( file, "long", 142 )
	Variable /G $hdf +"lEpisodesPerRun" = ReadPclampVar( file, "long", 146 )
	Variable /G $hdf +"lRunsPerTrial" = ReadPclampVar( file, "long", 150 )
	Variable /G $hdf +"lNumberOfTrials" = ReadPclampVar( file, "long", 154 )
	Variable /G $hdf +"nAveragingMode" = ReadPclampVar( file, "short", 158 )
	Variable /G $hdf +"nUndoRunCount" = ReadPclampVar( file, "short", 160 )
	Variable /G $hdf +"nFirstEpisodeInRun" = ReadPclampVar( file, "short", 162 )
	Variable /G $hdf +"fTriggerThreshold" = ReadPclampVar( file, "float", 164 )
	Variable /G $hdf +"nTriggerSource" = ReadPclampVar( file, "short", 168 ) // NEED THIS FOR GB
	Variable /G $hdf +"nTriggerAction" = ReadPclampVar( file, "short", 170 )
	Variable /G $hdf +"nTriggerPolarity" = ReadPclampVar( file, "short", 172 )
	Variable /G $hdf +"fScopeOutputInterval" = ReadPclampVar( file, "float", 174 )
	Variable /G $hdf +"fEpisodeStartToStart" = ReadPclampVar( file, "float", 178 ) // NEED THIS FOR GB
	Variable /G $hdf +"fRunStartToStart" = ReadPclampVar( file, "float", 182 )
	Variable /G $hdf +"fTrialStartToStart" = ReadPclampVar( file, "float", 186 )
	Variable /G $hdf +"lAverageCount" = ReadPclampVar( file, "long", 190 )
	Variable /G $hdf +"lClockChange" = ReadPclampVar( file, "long", 194 )
	Variable /G $hdf +"nAutoTriggerStrategy" = ReadPclampVar( file, "short", 198 )
	
	numChannels = NumVarOrDefault( hdf +"nADCNumChannels", 0 )
	
	//
	// Hardware Information
	//
	
	Variable /G $hdf +"fADCRange" = ReadPclampVar( file, "float", 244 ) // ADCRange, NEED THIS
	Variable /G $hdf +"fDACRange" = ReadPclampVar( file, "float", 248 )
	Variable /G $hdf +"lADCResolution" = ReadPclampVar( file, "long", 252 ) // ADCResolution, NEED THIS
	Variable /G $hdf +"lDACResolution" = ReadPclampVar( file, "long", 256 )
	
	//
	// Environmental information
	//
	
	if ( readAll )
		Variable /G $hdf +"nExperimentType" = ReadPclampVar( file, "short", 260 )
		Variable /G $hdf +"nAutosampleEnable" = ReadPclampVar( file, "short", 262 )
		Variable /G $hdf +"nAutosampleADCNum" = ReadPclampVar( file, "short", 264 )
		Variable /G $hdf +"nAutosampleInstrument" = ReadPclampVar( file, "short", 266 )
		Variable /G $hdf +"fAutosampleAdditGain" = ReadPclampVar( file, "float", 268 )
		Variable /G $hdf +"fAutosampleFilter" = ReadPclampVar( file, "float", 272 )
		Variable /G $hdf +"fAutosampleMembraneCap" = ReadPclampVar( file, "float", 276 )
		Variable /G $hdf +"nManualInfoStrategy" = ReadPclampVar( file, "short", 280 )
		Variable /G $hdf +"fCellID1" = ReadPclampVar( file, "float", 282 )
		Variable /G $hdf +"fCellID2" = ReadPclampVar( file, "float", 286 )
		Variable /G $hdf +"fCellID3" = ReadPclampVar( file, "float", 290 )
	endif
	
	String /G $hdf +"sCreatorInfo" = ReadPclampString( file, 294, 16 )
	String /G $hdf +"sFileComment" = ReadPclampString( file, 310, 56 )
	Variable /G $hdf +"nFileStartMillisecs" = ReadPclampVar( file, "short", 366 )
	
	//
	// Multi-channel information
	//
	
	if ( readAll && ( NMProgressCall( -2, "Reading ABF Header ..." ) == 1 ) )
		return -1 // cancel
	endif
	
	Make /I/O/N=( numChannels ) $hdf+"nADCPtoLChannelMap" = 0
	Make /I/O/N=( numChannels ) $hdf+"nADCSamplingSeq" = 0
	Make /T/O/N=( numChannels ) $hdf+"sADCChannelName" = "" // yAxisLabels, NEED THIS
	Make /T/O/N=( numChannels ) $hdf+"sADCUnits" = "" // yAxisLabels, NEED THIS
	Make /O/N=( numChannels ) $hdf+"fADCProgrammableGain" = NaN
	Make /O/N=( numChannels ) $hdf+"fADCDisplayAmplification" = NaN
	Make /O/N=( numChannels ) $hdf+"fADCDisplayOffset" = NaN
	Make /O/N=( numChannels ) $hdf+"fInstrumentScaleFactor" = NaN // scaleFactors, NEED THIS
	Make /O/N=( numChannels ) $hdf+"fInstrumentOffset" = NaN
	
	Wave nADCPtoLChannelMap = $hdf+"nADCPtoLChannelMap"
	Wave nADCSamplingSeq = $hdf+"nADCSamplingSeq"
	Wave /T sADCChannelName = $hdf+"sADCChannelName" // yAxisLabels, NEED THIS
	Wave /T sADCUnits = $hdf+"sADCUnits" // yAxisLabels, NEED THIS
	Wave fADCProgrammableGain = $hdf+"fADCProgrammableGain"
	Wave fADCDisplayAmplification = $hdf+"fADCDisplayAmplification"
	Wave fADCDisplayOffset = $hdf+"fADCDisplayOffset"
	Wave fInstrumentScaleFactor = $hdf+"fInstrumentScaleFactor" // scaleFactors, NEED THIS
	Wave fInstrumentOffset = $hdf+"fInstrumentOffset"
	
	if ( readAll )
	
		Make /O/N=( numChannels ) $hdf+"fSignalGain" = NaN
		Make /O/N=( numChannels ) $hdf+"fSignalOffset" = NaN
		Make /O/N=( numChannels ) $hdf+"fSignalLowpassFilter" = NaN
		Make /O/N=( numChannels ) $hdf+"fSignalHighpassFilter" = NaN
		Make /T/O/N=( numChannels ) $hdf+"sDACChannelName" = ""
		Make /T/O/N=( numChannels ) $hdf+"sDACChannelUnits" = ""
		Make /O/N=( numChannels ) $hdf+"fDACScaleFactor" = NaN
		Make /O/N=( numChannels ) $hdf+"fDACHoldingLevel" = NaN
		Make /I/O/N=( numChannels ) $hdf+"nSignalType" = 0
		
		Wave fSignalGain = $hdf+"fSignalGain"
		Wave fSignalOffset = $hdf+"fSignalOffset"
		Wave fSignalLowpassFilter = $hdf+"fSignalLowpassFilter"
		Wave fSignalHighpassFilter = $hdf+"fSignalHighpassFilter"
		Wave /T sDACChannelName = $hdf+"sDACChannelName"
		Wave /T sDACChannelUnits = $hdf+"sDACChannelUnits"
		Wave fDACScaleFactor = $hdf+"fDACScaleFactor"
		Wave fDACHoldingLevel = $hdf+"fDACHoldingLevel"
		Wave nSignalType = $hdf+"nSignalType"
	
	endif
	
	for ( ccnt = 0; ccnt < numChannels; ccnt += 1 )
	
		nADCPtoLChannelMap[ ccnt ] = ReadPclampVar( file, "short", 378 + ccnt * 2 )
		nADCSamplingSeq[ ccnt ] = ReadPclampVar( file, "short", 410 + ccnt * 2 )
		sADCChannelName[ ccnt ] = ReadPclampString( file, 442 + ccnt * 10, 10 ) // yAxisLabels, NEED THIS
		sADCUnits[ ccnt ] = ReadPclampString( file, 602 + ccnt * 8, 8 ) // yAxisLabels, NEED THIS
		fADCProgrammableGain[ ccnt ] = ReadPclampVar( file, "float", 730 + ccnt * 4 )
		fADCDisplayAmplification[ ccnt ] = ReadPclampVar( file, "float", 794 + ccnt * 4 )
		fADCDisplayOffset[ ccnt ] = ReadPclampVar( file, "float", 858 + ccnt * 4 )
		fInstrumentScaleFactor[ ccnt ] = ReadPclampVar( file, "float", 922 + ccnt * 4 ) // scaleFactors, NEED THIS
		fInstrumentOffset[ ccnt ] = ReadPclampVar( file, "float", 986 + ccnt * 4 )
		
		if ( readAll )
			fSignalGain[ ccnt ] = ReadPclampVar( file, "float", 1050 + ccnt * 4 )
			fSignalOffset[ ccnt ] = ReadPclampVar( file, "float", 1114 + ccnt * 4 )
			fSignalLowpassFilter[ ccnt ] = ReadPclampVar( file, "float", 1178 + ccnt * 4 )
			fSignalHighpassFilter[ ccnt ] = ReadPclampVar( file, "float", 1242 + ccnt * 4 )
			sDACChannelName[ ccnt ] = ReadPclampString( file, 1306 + ccnt * 10, 10 )
			sDACChannelUnits[ ccnt ] = ReadPclampString( file, 1346 + ccnt * 8, 8 )
			fDACScaleFactor[ ccnt ] = ReadPclampVar( file, "float", 1378 + ccnt * 4 )
			fDACHoldingLevel[ ccnt ] = ReadPclampVar( file, "float", 1394 + ccnt * 4 )
			nSignalType[ ccnt ] = ReadPclampVar( file, "short", 1410 + ccnt * 2 )
		endif
		
	endfor
	
	//
	// Synchronous timer outputs
	//
	
	if ( readAll )
		Variable /G $hdf +"nOUTEnable" = ReadPclampVar( file, "short", 1422 )
		Variable /G $hdf +"nSampleNumberOUT1" = ReadPclampVar( file, "short", 1424 )
		Variable /G $hdf +"nSampleNumberOUT2" = ReadPclampVar( file, "short", 1426 )
		Variable /G $hdf +"nFirstEpisodeOUT" = ReadPclampVar( file, "short", 1428 )
		Variable /G $hdf +"nLastEpisodeOUT" = ReadPclampVar( file, "short", 1430 )
		Variable /G $hdf +"nPulseSamplesOUT1" = ReadPclampVar( file, "short", 1432 )
		Variable /G $hdf +"nPulseSamplesOUT2" = ReadPclampVar( file, "short", 1434 )
	endif
	
	//
	// Epoch Waveform and Pulses
	//
	
	if ( readAll )
	
		Variable /G $hdf +"nDigitalEnable" = ReadPclampVar( file, "short", 1436 )
		Variable /G $hdf +"nWaveformSource" = ReadPclampVar( file, "short", 1438 )
		Variable /G $hdf +"nActiveDACChannel" = ReadPclampVar( file, "short", 1440 )
		Variable /G $hdf +"nInterEpisodeLevel" = ReadPclampVar( file, "short", 1442 )
		
		Make /I/O/N=( ABF_EPOCHCOUNT ) $hdf+"nEpochType" = 0
		Make /O/N=( ABF_EPOCHCOUNT ) $hdf+"fEpochInitLevel" = NaN
		Make /O/N=( ABF_EPOCHCOUNT ) $hdf+"fEpochLevelInc" = NaN
		Make /I/O/N=( ABF_EPOCHCOUNT ) $hdf+"nEpochInitDuration" = 0
		Make /I/O/N=( ABF_EPOCHCOUNT ) $hdf+"nEpochDurationInc" = 0
		
		Wave nEpochType = $hdf+"nEpochType"
		Wave fEpochInitLevel = $hdf+"fEpochInitLevel"
		Wave fEpochLevelInc = $hdf+"fEpochLevelInc"
		Wave nEpochInitDuration = $hdf+"nEpochInitDuration"
		Wave nEpochDurationInc = $hdf+"nEpochDurationInc"
		
		for ( icnt = 0 ; icnt < ABF_EPOCHCOUNT ; icnt += 1 )
			nEpochType[ icnt ] = ReadPclampVar( file, "short", 1444 + icnt * 2 )
			fEpochInitLevel[ icnt ] = ReadPclampVar( file, "float", 1464 + icnt * 4 )
			fEpochLevelInc[ icnt ] = ReadPclampVar( file, "float", 1504 + icnt * 4 )
			nEpochInitDuration[ icnt ] = ReadPclampVar( file, "short", 1544 + icnt * 2 )
			nEpochDurationInc[ icnt ] = ReadPclampVar( file, "short", 1564 + icnt * 2 )
		endfor
		
		Variable /G $hdf +"nDigitalHolding" = ReadPclampVar( file, "short", 1584 )
		Variable /G $hdf +"nDigitalInterEpisode" = ReadPclampVar( file, "short", 1586 )
		
		Make /I/O/N=( ABF_EPOCHCOUNT ) $hdf+"nDigitalValue" = 0
		
		Wave nDigitalValue = $hdf+"nDigitalValue"
		
		for ( icnt = 0 ; icnt < ABF_EPOCHCOUNT ; icnt += 1 )
			nDigitalValue[ icnt ] = ReadPclampVar( file, "short", 1588 + icnt * 2 )
		endfor
		
	endif
	
	//
	// DAC Output File
	//
	
	if ( readAll )
		Variable /G $hdf +"fDACFileScale" = ReadPclampVar( file, "float", 1620 )
		Variable /G $hdf +"fDACFileOffset" = ReadPclampVar( file, "float", 1624 )
		Variable /G $hdf +"nDACFileEpisodeNum" = ReadPclampVar( file, "short", 1630 )
		Variable /G $hdf +"nDACFileADCNum" = ReadPclampVar( file, "short", 1632 )
		String /G $hdf +"sDACFileName" = ReadPclampString( file, 1634, 12 )
		String /G $hdf +"sDACFilePath" = ReadPclampString( file, 1646, 60 )
	endif
	
	//
	// Conditioning pulse train
	//
	
	if ( readAll )
		Variable /G $hdf +"nConditEnable" = ReadPclampVar( file, "short", 1718 )
		Variable /G $hdf +"nConditChannel" = ReadPclampVar( file, "short", 1720 )
		Variable /G $hdf +"lConditNumPulses" = ReadPclampVar( file, "long", 1722 )
		Variable /G $hdf +"fBaselineDuration" = ReadPclampVar( file, "float", 1726 )
		Variable /G $hdf +"fBaselineLevel" = ReadPclampVar( file, "float", 1730 )
		Variable /G $hdf +"fStepDuration" = ReadPclampVar( file, "float", 1734 )
		Variable /G $hdf +"fStepLevel" = ReadPclampVar( file, "float", 1738 )
		Variable /G $hdf +"fPostTrainPeriod" = ReadPclampVar( file, "float", 1742 )
		Variable /G $hdf +"fPostTrainLevel" = ReadPclampVar( file, "float", 1746 )
	endif
	
	//
	// Variable Parameter User List
	//
	
	if ( readAll )
		Variable /G $hdf +"nParamToVary" = ReadPclampVar( file, "short", 1762 )
		String /G $hdf +"sParamValueList" = ReadPclampString( file, 1764, 80 )
	endif
	
	//
	// On-line Subtraction
	//
	
	if ( readAll )
		Variable /G $hdf +"nPNEnable" = ReadPclampVar( file, "short", 1932 )
		Variable /G $hdf +"nPNPosition" = ReadPclampVar( file, "short", 1934 )
		Variable /G $hdf +"nPNPolarity" = ReadPclampVar( file, "short", 1936 )
		Variable /G $hdf +"nPNNumPulses" = ReadPclampVar( file, "short", 1938 )
		Variable /G $hdf +"nPNADCNum" = ReadPclampVar( file, "short", 1940 )
		Variable /G $hdf +"fPNHoldingLevel" = ReadPclampVar( file, "float", 1942 )
		Variable /G $hdf +"fPNSettlingTime" = ReadPclampVar( file, "float", 1946 )
		Variable /G $hdf +"fPNInterpulse" = ReadPclampVar( file, "float", 1950 )
	endif
	
	//
	// Unused space at end of header block
	//
	
	if ( readAll )
	
		Variable /G $hdf +"nListEnable" = ReadPclampVar( file, "short", 1966 )
		Variable /G $hdf +"nLevelHysteresis" = ReadPclampVar( file, "short", 1980 )
		Variable /G $hdf +"lTimeHysteresis" = ReadPclampVar( file, "long", 1982 )
		Variable /G $hdf +"nAllowExternalTags" = ReadPclampVar( file, "short", 1986 )
		
		Make /I/O/N=( numChannels ) $hdf+"nLowpassFilterType" = 0
		Make /I/O/N=( numChannels ) $hdf+"nHighpassFilterType" = 0
		
		Wave nLowpassFilterType = $hdf+"nLowpassFilterType"
		Wave nHighpassFilterType = $hdf+"nHighpassFilterType"
		
		for ( ccnt = 0; ccnt < numChannels; ccnt += 1 )
			nLowpassFilterType[ ccnt ] = ReadPclampVar( file, "short", 1988 + ccnt * 2 )
			nHighpassFilterType[ ccnt ] = ReadPclampVar( file, "short", 2004 + ccnt * 2 )
		endfor
		
		Variable /G $hdf +"nAverageAlgorithm" = ReadPclampVar( file, "short", 2020 )
		Variable /G $hdf +"fAverageWeighting" = ReadPclampVar( file, "float", 2022 )
		Variable /G $hdf +"nUndoPromptStrategy" = ReadPclampVar( file, "short", 2026 )
		Variable /G $hdf +"nTrialTriggerSource" = ReadPclampVar( file, "short", 2028 )
		Variable /G $hdf +"nStatisticsDisplayStrategy" = ReadPclampVar( file, "short", 2030 )
		Variable /G $hdf +"nExternalTagType" = ReadPclampVar( file, "short", 2032 )
		
	endif
	
	Variable /G $hdf +"lHeaderSize" = ReadPclampVar( file, "short", 2034 )
	
	headerSize = NumVarOrDefault( hdf +"lHeaderSize", -1 )
	
	//
	// Extended Environmental Information
	//
	
	if ( headerSize >= 6144 )
	
		Make /I/O/N=( numChannels ) $hdf+"nTelegraphEnable" = 0
		Make /I/O/N=( numChannels ) $hdf+"nTelegraphInstrument" = 0
		Make /O/N=( numChannels ) $hdf+"fTelegraphAdditGain" = NaN
		Make /O/N=( numChannels ) $hdf+"fTelegraphFilter" = NaN
		Make /O/N=( numChannels ) $hdf+"fTelegraphMembraneCap" = NaN
		Make /I/O/N=( numChannels ) $hdf+"nTelegraphMode" = 0
		
		Wave nTelegraphEnable = $hdf+"nTelegraphEnable"
		Wave nTelegraphInstrument = $hdf+"nTelegraphInstrument"
		Wave fTelegraphAdditGain = $hdf+"fTelegraphAdditGain"
		Wave fTelegraphFilter = $hdf+"fTelegraphFilter"
		Wave fTelegraphMembraneCap = $hdf+"fTelegraphMembraneCap"
		Wave nTelegraphMode = $hdf+"nTelegraphMode"
		
		for ( ccnt = 0; ccnt < numChannels; ccnt += 1 )
			nTelegraphEnable[ ccnt ] = ReadPclampVar( file, "short", 4512 + ccnt * 2 )
			nTelegraphInstrument[ ccnt ] = ReadPclampVar( file, "short", 4544 + ccnt * 2 )
			fTelegraphAdditGain[ ccnt ] = ReadPclampVar( file, "float", 4576 + ccnt * 4 ) // 4572 in specs, but this must be a typo
			fTelegraphFilter[ ccnt ] = ReadPclampVar( file, "float", 4640 + ccnt * 4 )
			fTelegraphMembraneCap[ ccnt ] = ReadPclampVar( file, "float", 4704 + ccnt * 4  )
			nTelegraphMode[ ccnt ] = ReadPclampVar( file, "short", 4768 + ccnt * 2 )
		endfor
		
		Variable /G $hdf +"nTelegraphDACScaleFactor" = ReadPclampVar( file, "short", 4800 )
		String /G $hdf +"sProtocolPath" = ReadPclampString( file, 4898 , 256 )
		String /G $hdf +"sFileComment" = ReadPclampString( file, 5154 , 128 )
	
	endif
	
	ReadPclampHeaderUpdateNM( df, hdf )
	
	SetNMstr( df+"ImportFileType", "Pclamp 1" )
	
	KillWaves /Z $df+"NM_ReadPclampWave0"
	KillWaves /Z $df+"NM_ReadPclampWave1"
	
	NMProgressKill()
	
	return 1

End // ReadPClampHeader1

Static Function ReadPClampHeader2( file, df )
	String file // external ABF data file
	String df // NM data folder where everything is imported
	
	Variable icnt, jcnt, kcnt, lcnt
	Variable varTemp, uNumStrings, uMaxSize, lTotalBytes
	String strTemp
	
	df = ParseFilePath( 2, df, ":", 0, 0 )
	
	String hdf = df + ABF_SUBFOLDERNAME + ":"
	
	if ( ReadPclampFormat( file ) != 2 )
		return -1
	endif
	
	Variable readAll = NumVarOrDefault( NMDF+"ABF_HeaderReadAll", 0 )
	
	if ( readAll )
		NMProgressCall( -1, "Reading ABF Header ..." )
	endif
	
	Variable /G ABF_Read_Pointer = 0
	
	NewDataFolder /O $RemoveEnding( hdf, ":" ) // create subfolder in current directory
	
	Variable /G $hdf +"uFileSignature" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"uFileVersionNumber" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"uFileInfoSize" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"uActualEpisodes" = ReadPclampVarPointer( file, "uint" ) // NEED THIS
	Variable /G $hdf +"uFileStartDate" = ReadPclampVarPointer( file, "uint" ) // NEED THIS
	Variable /G $hdf +"uFileStartTimeMS" = ReadPclampVarPointer( file, "uint" ) // NEED THIS
	Variable /G $hdf +"uStopwatchTime" = ReadPclampVarPointer( file, "uint" ) // NEED THIS
	Variable /G $hdf +"nFileType" = ReadPclampVarPointer( file, "short" )
	Variable /G $hdf +"nDataFormat" = ReadPclampVarPointer( file, "short" ) // NEED THIS
	Variable /G $hdf +"nSimultaneousScan" = ReadPclampVarPointer( file, "short" )
	Variable /G $hdf +"nCRCEnable" = ReadPclampVarPointer( file, "short" )
	Variable /G $hdf +"uFileCRC" = ReadPclampVarPointer( file, "uint" )
	
	// GUID
	ReadPclampVarPointer( file, "long" )
	ReadPclampVarPointer( file, "short" )
	ReadPclampVarPointer( file, "short" )
	ReadPclampVarPointer( file, "char" )
	ReadPclampVarPointer( file, "char" )
	ReadPclampVarPointer( file, "char" )
	ReadPclampVarPointer( file, "char" )
	ReadPclampVarPointer( file, "char" )
	ReadPclampVarPointer( file, "char" )
	ReadPclampVarPointer( file, "char" )
	ReadPclampVarPointer( file, "char" )
	
	Variable /G $hdf +"uCreatorVersion" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"uCreatorNameIndex" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"uModifierVersion" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"uModifierNameIndex" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"uProtocolPathIndex" = ReadPclampVarPointer( file, "uint" )
	
	Variable /G $hdf +"SectionProtocol_BlockIndex" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionProtocol_Bytes" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionProtocol_NumEntries1" = ReadPclampVarPointer( file, "long" )
	Variable /G $hdf +"SectionProtocol_NumEntries2" = ReadPclampVarPointer( file, "long" )
	
	NVAR SectionProtocol_BlockIndex = $hdf +"SectionProtocol_BlockIndex"
	
	Variable /G $hdf +"SectionADC_BlockIndex" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionADC_Bytes" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionADC_NumEntries1" = ReadPclampVarPointer( file, "long" ) // NEED THIS
	Variable /G $hdf +"SectionADC_NumEntries2" = ReadPclampVarPointer( file, "long" )
	
	NVAR SectionADC_BlockIndex = $hdf +"SectionADC_BlockIndex"
	NVAR SectionADC_Bytes = $hdf +"SectionADC_Bytes"
	NVAR SectionADC_NumEntries1 = $hdf +"SectionADC_NumEntries1" // NEED THIS
	
	Variable /G $hdf +"SectionDAC_BlockIndex" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionDAC_Bytes" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionDAC_NumEntries1" = ReadPclampVarPointer( file, "long" )
	Variable /G $hdf +"SectionDAC_NumEntries2" = ReadPclampVarPointer( file, "long" )
	
	NVAR SectionDAC_BlockIndex = $hdf +"SectionDAC_BlockIndex"
	NVAR SectionDAC_Bytes = $hdf +"SectionDAC_Bytes"
	NVAR SectionDAC_NumEntries1 = $hdf +"SectionDAC_NumEntries1"
	
	Variable /G $hdf +"SectionEpoch_BlockIndex" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionEpoch_Bytes" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionEpoch_NumEntries1" = ReadPclampVarPointer( file, "long" )
	Variable /G $hdf +"SectionEpoch_NumEntries2" = ReadPclampVarPointer( file, "long" )
	
	NVAR SectionEpoch_BlockIndex = $hdf +"SectionEpoch_BlockIndex"
	NVAR SectionEpoch_Bytes = $hdf +"SectionEpoch_Bytes"
	NVAR SectionEpoch_NumEntries1 = $hdf +"SectionEpoch_NumEntries1"
	
	Variable /G $hdf +"SectionADCPerDAC_BlockIndex" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionADCPerDAC_Bytes" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionADCPerDAC_NumEntries1" = ReadPclampVarPointer( file, "long" )
	Variable /G $hdf +"SectionADCPerDAC_NumEntries2" = ReadPclampVarPointer( file, "long" )
	
	Variable /G $hdf +"SectionEpochPerDAC_BlockIndex" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionEpochPerDAC_Bytes" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionEpochPerDAC_NumEntries1" = ReadPclampVarPointer( file, "long" )
	Variable /G $hdf +"SectionEpochPerDAC_NumEntries2" = ReadPclampVarPointer( file, "long" )
	
	NVAR SectionEpochPerDAC_BlockIndex = $hdf +"SectionEpochPerDAC_BlockIndex"
	NVAR SectionEpochPerDAC_Bytes = $hdf +"SectionEpochPerDAC_Bytes"
	NVAR SectionEpochPerDAC_NumEntries1 = $hdf +"SectionEpochPerDAC_NumEntries1"
	
	Variable /G $hdf +"SectionUserList_BlockIndex" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionUserList_Bytes" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionUserList_NumEntries1" = ReadPclampVarPointer( file, "long" )
	Variable /G $hdf +"SectionUserList_NumEntries2" = ReadPclampVarPointer( file, "long" )
	
	Variable /G $hdf +"SectionStatsRegion_BlockIndex" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionStatsRegion_Bytes" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionStatsRegion_NumEntries1" = ReadPclampVarPointer( file, "long" )
	Variable /G $hdf +"SectionStatsRegion_NumEntries2" = ReadPclampVarPointer( file, "long" )
	
	Variable /G $hdf +"SectionMath_BlockIndex" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionMath_Bytes" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionMath_NumEntries1" = ReadPclampVarPointer( file, "long" )
	Variable /G $hdf +"SectionMath_NumEntries2" = ReadPclampVarPointer( file, "long" )
	
	Variable /G $hdf +"SectionStrings_BlockIndex" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionStrings_Bytes" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionStrings_NumEntries1" = ReadPclampVarPointer( file, "long" )
	Variable /G $hdf +"SectionStrings_NumEntries2" = ReadPclampVarPointer( file, "long" )
	
	NVAR SectionStrings_BlockIndex = $hdf +"SectionStrings_BlockIndex"
	NVAR SectionStrings_Bytes = $hdf +"SectionStrings_Bytes"
	NVAR SectionStrings_NumEntries1 = $hdf +"SectionStrings_NumEntries1"
	
	Variable /G $hdf +"SectionData_BlockIndex" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionData_Bytes" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"SectionData_NumEntries1" = ReadPclampVarPointer( file, "long" ) // NEED THIS
	Variable /G $hdf +"SectionData_NumEntries2" = ReadPclampVarPointer( file, "long" )
	
	NVAR SectionData_BlockIndex = $hdf +"SectionData_BlockIndex"
	NVAR SectionData_Bytes = $hdf +"SectionData_Bytes"
	NVAR SectionData_NumEntries1 = $hdf +"SectionData_NumEntries1"
	NVAR SectionData_NumEntries2 = $hdf +"SectionData_NumEntries2"
	
	SetNMvar( df+"DataPointer", SectionData_BlockIndex )
	
	if ( readAll && ( NMProgressCall( -2, "Reading ABF Header ..." ) == 1 ) )
		return -1 // cancel
	endif
	
	if ( readAll )
	
		Variable /G $hdf +"SectionTag_BlockIndex" = ReadPclampVarPointer( file, "uint" )
		Variable /G $hdf +"SectionTag_Bytes" = ReadPclampVarPointer( file, "uint" )
		Variable /G $hdf +"SectionTag_NumEntries1" = ReadPclampVarPointer( file, "long" )
		Variable /G $hdf +"SectionTag_NumEntries2" = ReadPclampVarPointer( file, "long" )
		
		Variable /G $hdf +"SectionScope_BlockIndex" = ReadPclampVarPointer( file, "uint" )
		Variable /G $hdf +"SectionScope_Bytes" = ReadPclampVarPointer( file, "uint" )
		Variable /G $hdf +"SectionScope_NumEntries1" = ReadPclampVarPointer( file, "long" )
		Variable /G $hdf +"SectionScope_NumEntries2" = ReadPclampVarPointer( file, "long" )
		
		Variable /G $hdf +"SectionDelta_BlockIndex" = ReadPclampVarPointer( file, "uint" )
		Variable /G $hdf +"SectionDelta_Bytes" = ReadPclampVarPointer( file, "uint" )
		Variable /G $hdf +"SectionDelta_NumEntries1" = ReadPclampVarPointer( file, "long" )
		Variable /G $hdf +"SectionDelta_NumEntries2" = ReadPclampVarPointer( file, "long" )
		
		Variable /G $hdf +"SectionVoiceTag_BlockIndex" = ReadPclampVarPointer( file, "uint" )
		Variable /G $hdf +"SectionVoiceTag_Bytes" = ReadPclampVarPointer( file, "uint" )
		Variable /G $hdf +"SectionVoiceTag_NumEntries1" = ReadPclampVarPointer( file, "long" )
		Variable /G $hdf +"SectionVoiceTag_NumEntries2" = ReadPclampVarPointer( file, "long" )
		
		Variable /G $hdf +"SectionSynchArray_BlockIndex" = ReadPclampVarPointer( file, "uint" )
		Variable /G $hdf +"SectionSynchArray_Bytes" = ReadPclampVarPointer( file, "uint" )
		Variable /G $hdf +"SectionSynchArray_NumEntries1" = ReadPclampVarPointer( file, "long" )
		Variable /G $hdf +"SectionSynchArray_NumEntries2" = ReadPclampVarPointer( file, "long" )
		
		Variable /G $hdf +"SectionAnnotation_BlockIndex" = ReadPclampVarPointer( file, "uint" )
		Variable /G $hdf +"SectionAnnotatio_Bytes" = ReadPclampVarPointer( file, "uint" )
		Variable /G $hdf +"SectionAnnotatio_NumEntries1" = ReadPclampVarPointer( file, "long" )
		Variable /G $hdf +"SectionAnnotatio_NumEntries2" = ReadPclampVarPointer( file, "long" )
		
		Variable /G $hdf +"SectionStats_BlockIndex" = ReadPclampVarPointer( file, "uint" )
		Variable /G $hdf +"SectionStats_Bytes" = ReadPclampVarPointer( file, "uint" )
		Variable /G $hdf +"SectionStats_NumEntries1" = ReadPclampVarPointer( file, "long" )
		Variable /G $hdf +"SectionStats_NumEntries2" = ReadPclampVarPointer( file, "long" )
	
	endif
	
	// Protocol Information Section
	
	if ( readAll && ( NMProgressCall( -2, "Reading ABF Header ..." ) == 1 ) )
		return -1 // cancel
	endif
	
	ABF_Read_Pointer = SectionProtocol_BlockIndex * ABF_BLOCK
	
	Variable /G $hdf +"nOperationMode" = ReadPclampVarPointer( file, "short" ) // NEED THIS
	Variable /G $hdf +"fADCSequenceInterval" = ReadPclampVarPointer( file, "float" ) // NEED THIS
	Variable /G $hdf +"bEnableFileCompression" = ReadPclampVarPointer( file, "char" )
	
	ReadPclampVarPointer( file, "char" ) // unused
	ReadPclampVarPointer( file, "char" ) // unused
	ReadPclampVarPointer( file, "char" ) // unused
	
	Variable /G $hdf +"uFileCompressionRatio" = ReadPclampVarPointer( file, "uint" )
	Variable /G $hdf +"fSynchTimeUnit" = ReadPclampVarPointer( file, "float" )
	Variable /G $hdf +"fSecondsPerRun" = ReadPclampVarPointer( file, "float" )
	Variable /G $hdf +"lNumSamplesPerEpisode" = ReadPclampVarPointer( file, "long" ) // NEED THIS
	Variable /G $hdf +"lPreTriggerSamples" = ReadPclampVarPointer( file, "long" )
	Variable /G $hdf +"lEpisodesPerRun" = ReadPclampVarPointer( file, "long" ) // NEED THIS
	Variable /G $hdf +"lRunsPerTrial" = ReadPclampVarPointer( file, "long" ) // NEED THIS
	Variable /G $hdf +"lNumberOfTrials" = ReadPclampVarPointer( file, "long" )
	Variable /G $hdf +"nAveragingMode" = ReadPclampVarPointer( file, "short" )
	Variable /G $hdf +"nUndoRunCount" = ReadPclampVarPointer( file, "short" )
	Variable /G $hdf +"nFirstEpisodeInRun" = ReadPclampVarPointer( file, "short" )
	Variable /G $hdf +"fTriggerThreshold" = ReadPclampVarPointer( file, "float" )
	Variable /G $hdf +"nTriggerSource" = ReadPclampVarPointer( file, "short" )
	Variable /G $hdf +"nTriggerAction" = ReadPclampVarPointer( file, "short" )
	Variable /G $hdf +"nTriggerPolarity" = ReadPclampVarPointer( file, "short" )
	Variable /G $hdf +"fScopeOutputInterval" = ReadPclampVarPointer( file, "float" )
	Variable /G $hdf +"fEpisodeStartToStart" = ReadPclampVarPointer( file, "float" ) // NEED THIS
	Variable /G $hdf +"fRunStartToStart" = ReadPclampVarPointer( file, "float" )
	Variable /G $hdf +"lAverageCount" = ReadPclampVarPointer( file, "long" )
	Variable /G $hdf +"fTrialStartToStart" = ReadPclampVarPointer( file, "float" )
	Variable /G $hdf +"nAutoTriggerStrategy" = ReadPclampVarPointer( file, "short" )
	Variable /G $hdf +"fFirstRunDelays" = ReadPclampVarPointer( file, "float" )
	Variable /G $hdf +"nChannelStatsStrategy" = ReadPclampVarPointer( file, "short" )
	Variable /G $hdf +"lSamplesPerTrace" = ReadPclampVarPointer( file, "long" )
	Variable /G $hdf +"lStartDisplayNum" = ReadPclampVarPointer( file, "long" )
	Variable /G $hdf +"lFinishDisplayNum" = ReadPclampVarPointer( file, "long" )
	Variable /G $hdf +"nShowPNRawData" = ReadPclampVarPointer( file, "short" )
	Variable /G $hdf +"fStatisticsPeriod" = ReadPclampVarPointer( file, "float" )
	Variable /G $hdf +"lStatisticsMeasurements" = ReadPclampVarPointer( file, "long" )
	Variable /G $hdf +"nStatisticsSaveStrategy" = ReadPclampVarPointer( file, "short" )
	Variable /G $hdf +"fADCRange" = ReadPclampVarPointer( file, "float" ) // NEED THIS
	Variable /G $hdf +"fDACRange" = ReadPclampVarPointer( file, "float" )
	Variable /G $hdf +"lADCResolution" = ReadPclampVarPointer( file, "long" ) // NEED THIS
	
	if ( readAll )
		Variable /G $hdf +"lDACResolution" = ReadPclampVarPointer( file, "long" )
		Variable /G $hdf +"nExperimentType" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nManualInfoStrategy" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nCommentsEnable" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"lFileCommentIndex" = ReadPclampVarPointer( file, "long" )
		Variable /G $hdf +"nAutoAnalyseEnable" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nSignalType" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nDigitalEnable" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nActiveDACChannel" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nDigitalHolding" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nDigitalInterEpisode" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nDigitalDACChannel" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nDigitalTrainActiveLogic" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nStatsEnable" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nStatisticsClearStrategy" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nLevelHysteresis" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"lTimeHysteresis" = ReadPclampVarPointer( file, "long" )
		Variable /G $hdf +"nAllowExternalTags" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nAverageAlgorithm" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"fAverageWeighting" = ReadPclampVarPointer( file, "float" )
		Variable /G $hdf +"nUndoPromptStrategy" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nTrialTriggerSource" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nStatisticsDisplayStrategy" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nExternalTagType" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nScopeTriggerOut" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nLTPType" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nAlternateDACOutputState" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nAlternateDigitalOutputState" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"fCellID0" = ReadPclampVarPointer( file, "float" )
		Variable /G $hdf +"fCellID1" = ReadPclampVarPointer( file, "float" )
		Variable /G $hdf +"fCellID2" = ReadPclampVarPointer( file, "float" )
		Variable /G $hdf +"nDigitizerADCs" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nDigitizerDACs" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nDigitizerTotalDigitalOuts" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nDigitizerSynchDigitalOuts" = ReadPclampVarPointer( file, "short" )
		Variable /G $hdf +"nDigitizerType" = ReadPclampVarPointer( file, "short" )
	endif
	
	// ADC Information Section
	
	if ( readAll && ( NMProgressCall( -2, "Reading ABF Header ..." ) == 1 ) )
		return -1 // cancel
	endif
	
	ABF_Read_Pointer = SectionADC_BlockIndex * ABF_BLOCK
	
	Make /I/O/N=( ABF_ADCCOUNT ) $hdf+"nTelegraphEnable" = 0
	Make /I/O/N=( ABF_ADCCOUNT ) $hdf+"nTelegraphInstrument" = 0
	Make /O/N=( ABF_ADCCOUNT ) $hdf+"fTelegraphAdditGain" = NaN
	Make /O/N=( ABF_ADCCOUNT ) $hdf+"fTelegraphFilter" = NaN
	Make /O/N=( ABF_ADCCOUNT ) $hdf+"fTelegraphMembraneCap" = NaN
	Make /I/O/N=( ABF_ADCCOUNT ) $hdf+"nTelegraphMode" = 0
	Make /O/N=( ABF_ADCCOUNT ) $hdf+"fTelegraphAccessResistance" = NaN
	
	Make /I/O/N=( ABF_ADCCOUNT ) $hdf+"nADCtoLChannelMap" = 0
	Make /I/O/N=( ABF_ADCCOUNT ) $hdf+"nADCSamplingSeq" = 0
	
	Make /O/N=( ABF_ADCCOUNT ) $hdf+"fADCProgrammableGain" = NaN
	Make /O/N=( ABF_ADCCOUNT ) $hdf+"fADCDisplayAmplification" = NaN
	Make /O/N=( ABF_ADCCOUNT ) $hdf+"fADCDisplayOffset" = NaN
	Make /O/N=( ABF_ADCCOUNT ) $hdf+"fInstrumentScaleFactor" = NaN
	Make /O/N=( ABF_ADCCOUNT ) $hdf+"fInstrumentOffset" = NaN
	Make /O/N=( ABF_ADCCOUNT ) $hdf+"fSignalGain" = NaN
	Make /O/N=( ABF_ADCCOUNT ) $hdf+"fSignalOffset" = NaN
	Make /O/N=( ABF_ADCCOUNT ) $hdf+"fSignalLowpassFilter" = NaN
	Make /O/N=( ABF_ADCCOUNT ) $hdf+"fSignalHighpassFilter" = NaN
	
	Make /T/O/N=( ABF_ADCCOUNT ) $hdf+"sLowpassFilterType" = ""
	Make /T/O/N=( ABF_ADCCOUNT ) $hdf+"sHighpassFilterType" = ""
	
	Make /O/N=( ABF_ADCCOUNT ) $hdf+"fPostProcessLowpassFilter" = NaN
	Make /T/O/N=( ABF_ADCCOUNT ) $hdf+"sPostProcessLowpassFilterType" = ""
	Make /I/O/N=( ABF_ADCCOUNT ) $hdf+"bEnabledDuringPN" = 0
	
	Make /I/O/N=( ABF_ADCCOUNT ) $hdf+"nStatsChannelPolarity" = 0
	
	Make /I/O/N=( ABF_ADCCOUNT ) $hdf+"lADCChannelNameIndex" = 0
	Make /I/O/N=( ABF_ADCCOUNT ) $hdf+"lADCUnitsIndex" = 0
	
	Make /T/O/N=( ABF_ADCCOUNT ) $hdf+"sADCChannelName" = ""
	Make /T/O/N=( ABF_ADCCOUNT ) $hdf+"sADCUnits" = ""
	
	Wave nTelegraphEnable = $hdf+"nTelegraphEnable"
	Wave nTelegraphInstrumen = $hdf+"nTelegraphInstrument"
	Wave fTelegraphAdditGain = $hdf+"fTelegraphAdditGain"
	Wave fTelegraphFilter = $hdf+"fTelegraphFilter"
	Wave fTelegraphMembraneCap = $hdf+"fTelegraphMembraneCap"
	Wave nTelegraphMode = $hdf+"nTelegraphMode"
	Wave fTelegraphResistance = $hdf+"fTelegraphAccessResistance"
	
	Wave nADCtoLChannelMap = $hdf+"nADCtoLChannelMap"
	Wave nADCSamplingSeq = $hdf+"nADCSamplingSeq"
	
	Wave fADCProgrammableGain = $hdf+"fADCProgrammableGain"
	Wave fADCDisplayAmplification = $hdf+"fADCDisplayAmplification"
	Wave fADCDisplayOffset = $hdf+"fADCDisplayOffset"
	Wave fInstrumentScaleFactor = $hdf+"fInstrumentScaleFactor"
	Wave fInstrumentOffset = $hdf+"fInstrumentOffset"
	Wave fSignalGain = $hdf+"fSignalGain"
	Wave fSignalOffset = $hdf+"fSignalOffset"
	Wave fSignalLowpassFilter = $hdf+"fSignalLowpassFilter"
	Wave fSignalHighpassFilter = $hdf+"fSignalHighpassFilter"
	
	Wave /T sLowpassFilterType = $hdf+"sLowpassFilterType"
	Wave /T sHighpassFilterType = $hdf+"sHighpassFilterType"
	
	Wave fPostProcessLowpassFilter = $hdf+"fPostProcessLowpassFilter"
	Wave /T sPostProcessLowpassFilterType = $hdf+"sPostProcessLowpassFilterType"
	Wave bEnabledDuringPN = $hdf+"bEnabledDuringPN"
	
	Wave nStatsChannelPolarity = $hdf+"nStatsChannelPolarity"
	
	Wave lADCChannelNameIndex = $hdf+"lADCChannelNameIndex"
	Wave lADCUnitsIndex = $hdf+"lADCUnitsIndex"
	
	Variable /G $hdf+"nADCNumChannels" = SectionADC_NumEntries1
	
	for ( icnt = 0 ; icnt < SectionADC_NumEntries1 ; icnt += 1 )
		
		jcnt = ReadPclampVarPointer( file, "short" )
		
		nADCSamplingSeq[ icnt ] = jcnt // NEED THIS
		
		if ( ( jcnt < 0 ) || ( jcnt >= ABF_ADCCOUNT ) )
			Print "ABF_ADCCOUNT error", jcnt
			return -1
		endif
	
		nTelegraphEnable[ jcnt ] = ReadPclampVarPointer( file, "short" )
		nTelegraphInstrumen[ jcnt ] = ReadPclampVarPointer( file, "short" )
		fTelegraphAdditGain[ jcnt ] = ReadPclampVarPointer( file, "float" ) // NEED THIS
		fTelegraphFilter[ jcnt ] = ReadPclampVarPointer( file, "float" )
		fTelegraphMembraneCap[ jcnt ] = ReadPclampVarPointer( file, "float" )
		nTelegraphMode[ jcnt ] = ReadPclampVarPointer( file, "short" )
		fTelegraphResistance[ jcnt ] = ReadPclampVarPointer( file, "float" )
		
		nADCtoLChannelMap[ jcnt ] = ReadPclampVarPointer( file, "short" )
		//nADCSamplingSeq[ jcnt ] = ReadPclampVarPointer( file, "short" )
		ReadPclampVarPointer( file, "short" )
		
		fADCProgrammableGain[ jcnt ] = ReadPclampVarPointer( file, "float" )
		fADCDisplayAmplification[ jcnt ] = ReadPclampVarPointer( file, "float" )
		fADCDisplayOffset[ jcnt ] = ReadPclampVarPointer( file, "float" )
		fInstrumentScaleFactor[ jcnt ] = ReadPclampVarPointer( file, "float" ) // NEED THIS
		fInstrumentOffset[ jcnt ] = ReadPclampVarPointer( file, "float" )
		fSignalGain[ jcnt ] = ReadPclampVarPointer( file, "float" )
		fSignalOffset[ jcnt ] = ReadPclampVarPointer( file, "float" )
		fSignalLowpassFilter[ jcnt ] = ReadPclampVarPointer( file, "float" )
		fSignalHighpassFilter[ jcnt ] = ReadPclampVarPointer( file, "float" )
		
		sLowpassFilterType[ jcnt ] = num2char( ReadPclampVarPointer( file, "char" ) )
		sHighpassFilterType[ jcnt ] = num2char( ReadPclampVarPointer( file, "char" ) )
		
		fPostProcessLowpassFilter[ jcnt ] = ReadPclampVarPointer( file, "float" )
		sPostProcessLowpassFilterType[ jcnt ] = num2char( ReadPclampVarPointer( file, "char" ) )
		bEnabledDuringPN[ jcnt ] = ReadPclampVarPointer( file, "char" )
		
		nStatsChannelPolarity[ jcnt ] = ReadPclampVarPointer( file, "short" )
		
		lADCChannelNameIndex[ jcnt ] = ReadPclampVarPointer( file, "long" )
		lADCUnitsIndex[ jcnt ] = ReadPclampVarPointer( file, "long" )
		
		for ( kcnt = 0 ; kcnt < 46 ; kcnt += 1 )
			ReadPclampVarPointer( file, "char" ) // unused
		endfor
	
	endfor
	
	// DAC Information Section
	
	if ( readAll )
	
		if ( readAll && ( NMProgressCall( -2, "Reading ABF Header ..." ) == 1 ) )
			return -1 // cancel
		endif
	
		ABF_Read_Pointer = SectionDAC_BlockIndex * ABF_BLOCK
		
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"nTelegraphDACScaleFactorEnable" = 0
		Make /O/N=( ABF_DACCOUNT ) $hdf+"fInstrumentHoldingLevel" = NaN
		Make /O/N=( ABF_DACCOUNT ) $hdf+"fDACScaleFactor" = NaN
		Make /O/N=( ABF_DACCOUNT ) $hdf+"fDACHoldingLevel" = NaN
		Make /O/N=( ABF_DACCOUNT ) $hdf+"fDACCalibrationFactor" = NaN
		Make /O/N=( ABF_DACCOUNT ) $hdf+"fDACCalibrationOffset" = NaN
		
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"lDACChannelNameIndex" = 0
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"lDACChannelUnitsIndex" = 0
		
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"lDACFilePtr" = 0
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"lDACFileNumEpisodes" = 0
		
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"nWaveformEnable" = 0
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"nWaveformSource" = 0
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"nInterEpisodeLevel" = 0
		
		Make /O/N=( ABF_DACCOUNT ) $hdf+"fDACFileScale" = NaN
		Make /O/N=( ABF_DACCOUNT ) $hdf+"fDACFileOffset" = NaN
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"lDACFileEpisodeNum" = 0
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"nDACFileADCNum" = 0
		
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"nConditEnable" = 0
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"lConditNumPulses" = 0
		Make /O/N=( ABF_DACCOUNT ) $hdf+"fBaselineDuration" = NaN
		Make /O/N=( ABF_DACCOUNT ) $hdf+"fBaselineLevel" = NaN
		Make /O/N=( ABF_DACCOUNT ) $hdf+"fStepDuration" = NaN
		Make /O/N=( ABF_DACCOUNT ) $hdf+"fStepLevel" = NaN
		Make /O/N=( ABF_DACCOUNT ) $hdf+"fPostTrainPeriod" = NaN
		Make /O/N=( ABF_DACCOUNT ) $hdf+"fPostTrainLevel" = NaN
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"nMembTestEnable" = 0
		
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"nLeakSubtractType" = 0
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"nPNPolarity" = 0
		
		Make /O/N=( ABF_DACCOUNT ) $hdf+"fPNHoldingLevel" = NaN
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"nPNNumADCChannels" = 0
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"nPNPosition" = 0
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"nPNNumPulses" = 0
		Make /O/N=( ABF_DACCOUNT ) $hdf+"fPNSettlingTime" = NaN
		Make /O/N=( ABF_DACCOUNT ) $hdf+"fPNInterpulse" = NaN
		
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"nLTPUsageOfDAC" = 0
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"nLTPPresynapticPulses" = 0
		
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"lDACFilePathIndex" = 0
		
		Make /O/N=( ABF_DACCOUNT ) $hdf+"fMembTestPreSettlingTimeMS" = NaN
		Make /O/N=( ABF_DACCOUNT ) $hdf+"fMembTestPostSettlingTimeMS" = NaN
		
		Make /I/O/N=( ABF_DACCOUNT ) $hdf+"nLeakSubtractADCIndex" = 0
		
		Make /T/O/N=( ABF_DACCOUNT ) $hdf+"sDACChannelName" = ""
		Make /T/O/N=( ABF_DACCOUNT ) $hdf+"sDACUnits" = ""
		
		Wave nTelegraphDACScaleFactorEnable = $hdf+"nTelegraphDACScaleFactorEnable"
		Wave fInstrumentHoldingLevel = $hdf+"fInstrumentHoldingLevel"
		Wave fDACScaleFactor = $hdf+"fDACScaleFactor"
		Wave fDACHoldingLevel = $hdf+"fDACHoldingLevel"
		Wave fDACCalibrationFactor = $hdf+"fDACCalibrationFactor"
		Wave fDACCalibrationOffset = $hdf+"fDACCalibrationOffset"
		
		Wave lDACChannelNameIndex = $hdf+"lDACChannelNameIndex"
		Wave lDACChannelUnitsIndex = $hdf+"lDACChannelUnitsIndex"
		
		Wave lDACFilePtr = $hdf+"lDACFilePtr"
		Wave lDACFileNumEpisodes = $hdf+"lDACFileNumEpisodes"
		
		Wave nWaveformEnabl = $hdf+"nWaveformEnable"
		Wave nWaveformSource = $hdf+"nWaveformSource"
		Wave nInterEpisodeLevel = $hdf+"nInterEpisodeLevel"
		
		Wave fDACFileScale = $hdf+"fDACFileScale"
		Wave fDACFileOffset = $hdf+"fDACFileOffset"
		Wave lDACFileEpisodeNum = $hdf+"lDACFileEpisodeNum"
		Wave nDACFileADCNum = $hdf+"nDACFileADCNum"
		
		Wave nConditEnable = $hdf+"nConditEnable"
		Wave lConditNumPulses = $hdf+"lConditNumPulses"
		Wave fBaselineDuration = $hdf+"fBaselineDuration"
		Wave fBaselineLevel = $hdf+"fBaselineLevel"
		Wave fStepDuration = $hdf+"fStepDuration"
		Wave fStepLevel = $hdf+"fStepLevel"
		Wave fPostTrainPeriod = $hdf+"fPostTrainPeriod"
		Wave fPostTrainLevel = $hdf+"fPostTrainLevel"
		Wave nMembTestEnable = $hdf+"nMembTestEnable"
		
		Wave nLeakSubtractType = $hdf+"nLeakSubtractType"
		Wave nPNPolarit = $hdf+"nPNPolarity"
		
		Wave fPNHoldingLevel = $hdf+"fPNHoldingLevel"
		Wave nPNNumADCChannels = $hdf+"nPNNumADCChannels"
		Wave nPNPosition = $hdf+"nPNPosition"
		Wave nPNNumPulses = $hdf+"nPNNumPulses"
		Wave fPNSettlingTime = $hdf+"fPNSettlingTime"
		Wave fPNInterpulse = $hdf+"fPNInterpulse"
		
		Wave nLTPUsageOfDAC = $hdf+"nLTPUsageOfDAC"
		Wave nLTPPresynapticPulses = $hdf+"nLTPPresynapticPulses"
		
		Wave lDACFilePathIndex = $hdf+"lDACFilePathIndex"
		
		Wave fMembTestPreSettlingTimeMS = $hdf+"fMembTestPreSettlingTimeMS"
		Wave fMembTestPostSettlingTimeMS = $hdf+"fMembTestPostSettlingTimeMS"
		
		Wave nLeakSubtractADCIndex = $hdf+"nLeakSubtractADCIndex"
		
		for ( icnt = 0 ; icnt < SectionDAC_NumEntries1 ; icnt += 1 )
			
			jcnt = ReadPclampVarPointer( file, "short" )
			
			if ( ( jcnt < 0 ) || ( jcnt >= ABF_DACCOUNT ) )
				Print "ABF_DACCOUNT error", jcnt
				return -1
			endif
			
			nTelegraphDACScaleFactorEnable[ jcnt ] = ReadPclampVarPointer( file, "short" )
			fInstrumentHoldingLevel[ jcnt ] = ReadPclampVarPointer( file, "float" )
			fDACScaleFactor[ jcnt ] = ReadPclampVarPointer( file, "float" )
			
			fDACCalibrationFactor[ jcnt ] = ReadPclampVarPointer( file, "float" )
			fDACCalibrationOffset[ jcnt ] = ReadPclampVarPointer( file, "float" )
			fDACHoldingLevel[ jcnt ] = ReadPclampVarPointer( file, "float" )
			lDACChannelNameIndex[ jcnt ] = ReadPclampVarPointer( file, "long" )
			lDACChannelUnitsIndex[ jcnt ] = ReadPclampVarPointer( file, "long" )
			
			lDACFilePtr[ jcnt ] = ReadPclampVarPointer( file, "long" )
			lDACFileNumEpisodes[ jcnt ] = ReadPclampVarPointer( file, "long" )
			
			nWaveformEnabl[ jcnt ] = ReadPclampVarPointer( file, "short" )
			nWaveformSource[ jcnt ] = ReadPclampVarPointer( file, "short" )
			nInterEpisodeLevel[ jcnt ] = ReadPclampVarPointer( file, "short" )
			
			fDACFileScale[ jcnt ] = ReadPclampVarPointer( file, "float" )
			fDACFileOffset[ jcnt ] = ReadPclampVarPointer( file, "float" )
			lDACFileEpisodeNum[ jcnt ] = ReadPclampVarPointer( file, "long" )
			nDACFileADCNum[ jcnt ] = ReadPclampVarPointer( file, "short" )
			
			nConditEnable[ jcnt ] = ReadPclampVarPointer( file, "short" )
			lConditNumPulses[ jcnt ] = ReadPclampVarPointer( file, "long" )
			fBaselineDuration[ jcnt ] = ReadPclampVarPointer( file, "float" )
			fBaselineLevel[ jcnt ] = ReadPclampVarPointer( file, "float" )
			fStepDuration[ jcnt ] = ReadPclampVarPointer( file, "float" )
			fStepLevel[ jcnt ] = ReadPclampVarPointer( file, "float" )
			fPostTrainPeriod[ jcnt ] = ReadPclampVarPointer( file, "float" )
			fPostTrainLevel[ jcnt ] = ReadPclampVarPointer( file, "float" )
			nMembTestEnable[ jcnt ] = ReadPclampVarPointer( file, "short" )
			
			nLeakSubtractType[ jcnt ] = ReadPclampVarPointer( file, "short" )
			nPNPolarit[ jcnt ] = ReadPclampVarPointer( file, "short" )
			
			fPNHoldingLevel[ jcnt ] = ReadPclampVarPointer( file, "float" )
			nPNNumADCChannels[ jcnt ] = ReadPclampVarPointer( file, "short" )
			nPNPosition[ jcnt ] = ReadPclampVarPointer( file, "short" )
			nPNNumPulses[ jcnt ] = ReadPclampVarPointer( file, "short" )
			fPNSettlingTime[ jcnt ] = ReadPclampVarPointer( file, "float" )
			fPNInterpulse[ jcnt ] = ReadPclampVarPointer( file, "float" )
			
			nLTPUsageOfDAC[ jcnt ] = ReadPclampVarPointer( file, "short" )
			nLTPPresynapticPulses[ jcnt ] = ReadPclampVarPointer( file, "short" )
			
			lDACFilePathIndex[ jcnt ] = ReadPclampVarPointer( file, "long" )
			
			fMembTestPreSettlingTimeMS[ jcnt ] = ReadPclampVarPointer( file, "float" )
			fMembTestPostSettlingTimeMS[ jcnt ] = ReadPclampVarPointer( file, "float" )
		
			nLeakSubtractADCIndex[ jcnt ] = ReadPclampVarPointer( file, "short" )
			
			for ( kcnt = 0 ; kcnt < 124 ; kcnt += 1 )
				ReadPclampVarPointer( file, "char" ) // unused
			endfor
			
		endfor
	
	endif
	
	// Epoch Per DAC Section
	
	if ( readAll )
	
		if ( readAll && ( NMProgressCall( -2, "Reading ABF Header ..." ) == 1 ) )
			return -1 // cancel
		endif
	
		ABF_Read_Pointer = SectionEpochPerDAC_BlockIndex * ABF_BLOCK
		
		Make /I/O/N=( ABF_DACCOUNT, ABF_EPOCHCOUNT ) $hdf+"nEpochType" = 0
		Make /O/N=( ABF_DACCOUNT, ABF_EPOCHCOUNT ) $hdf+"fEpochInitLevel" = NaN
		Make /O/N=( ABF_DACCOUNT, ABF_EPOCHCOUNT ) $hdf+"fEpochLevelInc" = NaN
		Make /I/O/N=( ABF_DACCOUNT, ABF_EPOCHCOUNT ) $hdf+"lEpochInitDuration" = 0
		Make /I/O/N=( ABF_DACCOUNT, ABF_EPOCHCOUNT ) $hdf+"lEpochDurationInc" = 0
		Make /I/O/N=( ABF_DACCOUNT, ABF_EPOCHCOUNT ) $hdf+"lEpochPulsePeriod" = 0
		Make /I/O/N=( ABF_DACCOUNT, ABF_EPOCHCOUNT ) $hdf+"lEpochPulseWidth" = 0
		
		Wave nEpochType = $hdf+"nEpochType"
		Wave fEpochInitLevel = $hdf+"fEpochInitLevel"
		Wave fEpochLevelInc = $hdf+"fEpochLevelInc"
		Wave lEpochInitDuration = $hdf+"lEpochInitDuration"
		Wave lEpochDurationInc = $hdf+"lEpochDurationInc"
		Wave lEpochPulsePeriod = $hdf+"lEpochPulsePeriod"
		Wave lEpochPulseWidth = $hdf+"lEpochPulseWidth"
		
		for ( icnt = 0 ; icnt < SectionEpochPerDAC_NumEntries1 ; icnt += 1 )
		
			kcnt = ReadPclampVarPointer( file, "short" )
			jcnt = ReadPclampVarPointer( file, "short" )
			
			if ( ( jcnt < 0 ) || ( jcnt >= ABF_DACCOUNT ) )
				Print "ABF_DACCOUNT error", jcnt
				return -1
			endif
			
			if ( ( kcnt < 0 ) || ( kcnt >= ABF_EPOCHCOUNT ) )
				Print "ABF_EPOCHCOUNT error", kcnt
				return -1
			endif
			
			nEpochType[ jcnt ][ kcnt ] = ReadPclampVarPointer( file, "short" )
			fEpochInitLevel[ jcnt ][ kcnt ] = ReadPclampVarPointer( file, "float" )
			fEpochLevelInc[ jcnt ][ kcnt ] = ReadPclampVarPointer( file, "float" )
			lEpochInitDuration[ jcnt ][ kcnt ] = ReadPclampVarPointer( file, "long" )
			lEpochDurationInc[ jcnt ][ kcnt ] = ReadPclampVarPointer( file, "long" )
			lEpochPulsePeriod[ jcnt ][ kcnt ] = ReadPclampVarPointer( file, "long" )
			lEpochPulseWidth[ jcnt ][ kcnt ] = ReadPclampVarPointer( file, "long" )
			
			for ( lcnt = 0 ; lcnt < 18 ; lcnt += 1 )
				ReadPclampVarPointer( file, "char" ) // unused
			endfor
			
		endfor
	
	endif
	
	// Epoch Information Section
	
	if ( readAll )
	
		if ( readAll && ( NMProgressCall( -2, "Reading ABF Header ..." ) == 1 ) )
			return -1 // cancel
		endif
	
		ABF_Read_Pointer = SectionEpoch_BlockIndex * ABF_BLOCK
		
		Make /I/O/N=( ABF_EPOCHCOUNT ) $hdf+"nDigitalValue" = 0
		Make /I/O/N=( ABF_EPOCHCOUNT ) $hdf+"nDigitalTrainValue" = 0
		Make /I/O/N=( ABF_EPOCHCOUNT ) $hdf+"nAlternateDigitalValue" = 0
		Make /I/O/N=( ABF_EPOCHCOUNT ) $hdf+"nAlternateDigitalTrainValue" = 0
		Make /I/O/N=( ABF_EPOCHCOUNT ) $hdf+"bEpochCompression" = 0
		
		Wave nDigitalValue = $hdf+"nDigitalValue"
		Wave nDigitalTrainValue = $hdf+"nDigitalTrainValue"
		Wave nAlternateDigitalValue = $hdf+"nAlternateDigitalValue"
		Wave nAlternateDigitalTrainValue = $hdf+"nAlternateDigitalTrainValue"
		Wave bEpochCompression = $hdf+"bEpochCompression"
		
		for ( icnt = 0 ; icnt < SectionEpoch_NumEntries1 ; icnt += 1 )
		
			jcnt = ReadPclampVarPointer( file, "short" )
			
			if ( ( jcnt < 0 ) || ( jcnt >= ABF_EPOCHCOUNT ) )
				Print "ABF_EPOCHCOUNT error", jcnt
				return -1
			endif
			
			nDigitalValue[ jcnt ] = ReadPclampVarPointer( file, "short" )
			nDigitalTrainValue[ jcnt ] = ReadPclampVarPointer( file, "short" )
			nAlternateDigitalValue[ jcnt ] = ReadPclampVarPointer( file, "short" )
			nAlternateDigitalTrainValue[ jcnt ] = ReadPclampVarPointer( file, "short" )
			bEpochCompression[ jcnt ] = ReadPclampVarPointer( file, "char" )
			
			for ( kcnt = 0 ; kcnt < 21 ; kcnt += 1 )
				ReadPclampVarPointer( file, "char" ) // unused
			endfor
		
		endfor
	
	endif
	
	// Strings Section
	
	if ( readAll && ( NMProgressCall( -2, "Reading ABF Header ..." ) == 1 ) )
		return -1 // cancel
	endif
	
	ABF_Read_Pointer = SectionStrings_BlockIndex * ABF_BLOCK
	
	strTemp = num2char( ReadPclampVarPointer( file, "char" ) ) // S
	strTemp += num2char( ReadPclampVarPointer( file, "char" ) ) // S
	strTemp += num2char( ReadPclampVarPointer( file, "char" ) ) // C
	strTemp += num2char( ReadPclampVarPointer( file, "char" ) ) // H
		
	if ( StringMatch( strTemp, "SSCH" ) )
	
		ReadPclampVarPointer( file, "char" ) // 1
		ReadPclampVarPointer( file, "char" ) // 0
		ReadPclampVarPointer( file, "char" ) // 0
		ReadPclampVarPointer( file, "char" ) // 0
	
		uNumStrings = ReadPclampVarPointer( file, "uint" )
		uMaxSize = ReadPclampVarPointer( file, "uint" )
		lTotalBytes = ReadPclampVarPointer( file, "long" )
	
		for ( icnt = 0 ; icnt < 6 ; icnt += 1 )
			ReadPclampVarPointer( file, "uint" ) // unused
		endfor
		
		Make /T/O/N=( uNumStrings ) $hdf+"sNames" = ""
	
		Wave /T sNames = $hdf+"sNames"
		
		jcnt = 0
		strTemp = ""
	
		for ( icnt = 0 ; icnt < lTotalBytes ; icnt += 1 )
		
			varTemp = ReadPclampVarPointer( file, "char" )
			
			if ( varTemp == 0 )
				sNames[ jcnt ] = strTemp
				strTemp = ""
				jcnt += 1
				continue
			elseif ( varTemp > 0 )
				strTemp += num2char( varTemp )
			endif
			
		endfor
		
		Wave /T sADCChannelName = $hdf + "sADCChannelName"
		Wave /T sADCUnits = $hdf + "sADCUnits"
		
		Wave lADCChannelNameIndex = $hdf+"lADCChannelNameIndex"
		Wave lADCUnitsIndex = $hdf+"lADCUnitsIndex"
		
		for ( icnt = 0 ; icnt < ABF_ADCCOUNT ; icnt += 1 )
		
			varTemp = lADCChannelNameIndex[ icnt ] - 1
		
			if ( ( varTemp >= 0 ) && ( varTemp < uNumStrings ) )
				sADCChannelName[ icnt ] = sNames[ varTemp ] // NEED THIS
			endif
			
			varTemp = lADCUnitsIndex[ icnt ] - 1
			
			if ( ( varTemp >= 0 ) && ( varTemp < uNumStrings ) )
				sADCUnits[ icnt ] = sNames[ varTemp ] // NEED THIS
			endif

		endfor
		
		if ( readAll )
		
			Wave /T sDACChannelName = $hdf + "sDACChannelName"
			Wave /T sDACUnits = $hdf + "sDACUnits"
			
			Wave lDACChannelNameIndex = $hdf+"lDACChannelNameIndex"
			Wave lDACChannelUnitsIndex = $hdf+"lDACChannelUnitsIndex"
			
			for ( icnt = 0 ; icnt < ABF_DACCOUNT ; icnt += 1 )
			
				varTemp = lDACChannelNameIndex[ icnt ] - 1
			
				if ( ( varTemp >= 0 ) && ( varTemp < uNumStrings ) )
					sDACChannelName[ icnt ] = sNames[ varTemp ]
				endif
				
				varTemp = lDACChannelUnitsIndex[ icnt ] - 1
				
				if ( ( varTemp >= 0 ) && ( varTemp < uNumStrings ) )
					sDACUnits[ icnt ] = sNames[ varTemp ]
				endif
	
			endfor
		
		endif
	
	endif
	
	ReadPclampHeaderUpdateNM( df, hdf )
	
	SetNMstr( df+"ImportFileType", "Pclamp 2" )
	
	KillVariables /Z ABF_Read_Pointer
	
	KillWaves /Z $df+"NM_ReadPclampWave0"
	KillWaves /Z $df+"NM_ReadPclampWave1"
	
	NMProgressKill()
	
	return 1
	
End // ReadPClampHeader2

Static Function /S ReadPClampFileC( file ) // convert Igor file string to C/C++ file string
	String file // external ABF data file
	String fileC

	fileC = ReplaceString( ":", file, "/" )
	fileC = file[ 0, 0 ] + ":/" + fileC[ 2, inf ]
	
	return fileC
	
End // ReadPClampFileC

Static Function ReadPclampHeaderUpdateNM( df, hdf )
	String df // where to update NM variables and waves
	String hdf // ABF header data folder
	
	Variable ccnt, chanNum, tempvar
	Variable amode, dataFormat, acqLength, numChannels, samplesPerWave, episodes
	Variable sampleInterval, splitClock, ADCRange
	String acqMode, yl, yu, wName
	String thisfxn = GetRTStackInfo( 1 )
	
	df = ParseFilePath( 2, df, ":", 0, 0 )

	CheckNMwave( df+"FileScaleFactors", ABF_ADCCOUNT, 1 )
	CheckNMtwave( df+"yLabel", ABF_ADCCOUNT, "" )
	
	Wave scaleFactors = $df+"FileScaleFactors"
	Wave /T yAxisLabels = $df+"yLabel"
	
	scaleFactors = 1
	yAxisLabels = ""
	
	amode = NM_ABFHeaderVar( "*OperationMode", folder = df )
	
	switch( amode )
		case 1:
			acqMode = "1 ( Event-Driven )"
			break
		case 2:
			acqMode = "2 ( Oscilloscope, loss free )"
			break
		case 3:
			acqMode = "3 ( Gap-Free )"
			break
		case 4:
			acqMode = "4 ( Oscilloscope, high-speed )"
			break
		case 5:
			acqMode = "5 ( Episodic )"
			break
		default:
			Print thisfxn + " Error: unknown acquisition mode :", acqMode
			return -1
	endswitch
	
	SetNMstr( df+"AcqMode", acqMode )
	
	dataFormat = NM_ABFHeaderVar( "*DataFormat", folder = df, alert = 1 )
	
	if ( numtype( dataFormat ) > 0 )
		Print thisfxn + " Error: unknown data format"
		return -1
	endif
	
	SetNMvar( df+"DataFormat", dataFormat )
	
	acqLength = NM_ABFHeaderVar( "*ActualAcqLength", folder = df ) // ReadPclampHeader1 or XOP
	
	if ( numtype( acqLength ) > 0 )
		acqLength = NM_ABFHeaderVar( "*SectionData_NumEntries1", folder = df ) // ReadPclampHeader2
	endif
	
	if ( acqLength < 0 )
		Print thisfxn + " Error: unknown acquisition length :", acqLength
		return -1
	endif
	
	SetNMvar( df+"AcqLength", acqLength )
	
	numChannels = NM_ABFHeaderVar( "*ADCNumChannels", folder = df )

	if ( ( numtype( numChannels ) > 0 ) || ( numChannels <= 0 ) )
		Print thisfxn + " Error: unknown number of channels :", numChannels
		return -1
	endif
	
	SetNMvar( df+"NumChannels", numChannels )
	
	samplesPerWave = NM_ABFHeaderVar( "*NumSamplesPerEpisode", folder = df )
	
	if ( ( numtype( samplesPerWave ) > 0 ) || ( samplesPerWave < 0 ) )
		Print thisfxn + " Error: unknown number of samples :", samplesPerWave
		return -1
	endif
	
	if ( numChannels > 1 )
		samplesPerWave /= numChannels
	endif
	
	SetNMvar( df+"SamplesPerWave", samplesPerWave )
	
	episodes = NM_ABFHeaderVar( "*ActualEpisodes", folder = df )
	
	if ( numtype( episodes ) > 0 )
		Print thisfxn + " Error: unknown number of episodes"
		return -1
	endif
	
	if ( episodes == 0 ) // must be gap free
		episodes = acqLength / ( SamplesPerWave * NumChannels )
	endif
	
	if ( episodes <= 0 )
		Print thisfxn + " Error: unknown number of episodes :", episodes
		return -1
	endif
	
	SetNMvar( df+"NumWaves", episodes )
	SetNMvar( df+"TotalNumWaves", episodes * NumChannels )
	
	sampleInterval = NM_ABFHeaderVar( "*ADCSampleInterval", folder = df )
	
	if ( numtype( sampleInterval ) > 0 )
		sampleInterval = NM_ABFHeaderVar( "*ADCSequenceInterval", folder = df )
		sampleInterval = sampleInterval / 1000
	elseif ( sampleInterval > 0 )
		sampleInterval = ( sampleInterval * NumChannels ) / 1000
	endif
	
	if ( ( numtype( sampleInterval ) > 0 ) || ( sampleInterval <= 0 ) )
		Print thisfxn + " Error: unknown sample interval :", sampleInterval
		return -1
	endif
	
	SetNMvar( df+"SampleInterval", sampleInterval )
	
	splitClock = NM_ABFHeaderVar( "*ADCSecondSampleInterval", folder = df )
	SetNMvar( df+"SplitClock", splitClock )
	
	if ( ( numtype( splitClock ) == 0 ) && ( splitClock > 0 ) )
		NMDoAlert( "Warning: data contains split-clock recording, which is not supported by this version of NeuroMatic." )
	endif
	
	//
	// Hardware Info
	//
	
	ADCRange = NM_ABFHeaderVar( "*ADCRange", folder = df ) // ADC positive full-scale input ( volts )
	SetNMvar( df+"ADCRange", ADCRange )
	
	Variable ADCResolution = NM_ABFHeaderVar( "*ADCResolution", folder = df ) // number of ADC counts in ADC range
	SetNMvar( df+"ADCResolution", ADCResolution )
	
	//
	// Multi-channel Info
	//
	
	wName = NM_ABFHeaderWaveName( "*ADCSamplingSeq", folder = df )
	
	if ( !WaveExists( $wName ) )
		Print thisfxn + " Error: cannot locate ADCSamplingSeq wave"
		return -1
	endif
	
	Wave nADCSamplingSeq = $wName
	
	wName = NM_ABFHeaderWaveName( "*InstrumentScaleFactor", folder = df )
	
	if ( !WaveExists( $wName ) )
		Print thisfxn + " Error: cannot locate InstrumentScaleFactor wave"
		return -1
	endif
	
	Wave fInstrumentScaleFactor = $wName
	
	wName = NM_ABFHeaderWaveName( "*ADCChannelName", folder = df )
	
	if ( !WaveExists( $wName ) )
		Print thisfxn + " Error: cannot locate ADCChannelName wave"
		return -1
	endif
	
	Wave /T sADCChannelName = $wName
	
	wName = NM_ABFHeaderWaveName( "*ADCUnits", folder = df )
	
	if ( !WaveExists( $wName ) )
		Print thisfxn + " Error: cannot locate ADCUnits wave"
		return -1
	endif
	
	Wave /T sADCUnits = $wName

	for ( ccnt = 0; ccnt < NumChannels; ccnt += 1 )
		
		chanNum = nADCSamplingSeq[ ccnt ]
		
		if ( ( chanNum >= 0 ) && ( chanNum < numpnts( sADCChannelName ) ) )
		
			yl = RemoveEndSpaces( sADCChannelName[ chanNum ] )
			yu = RemoveEndSpaces( sADCUnits[ chanNum ] )
			
			if ( ( strlen( yl ) > 0 ) || ( strlen( yu ) > 0 ) )
				yAxisLabels[ ccnt ] = yl + " ( " + yu + " )"
			endif
			
		endif
		
	endfor
	
	for ( ccnt = 0; ccnt < NumChannels; ccnt += 1 )
	
		chanNum = nADCSamplingSeq[ ccnt ]
		
		if ( ( chanNum >= 0 ) && ( chanNum < numpnts( fInstrumentScaleFactor ) ) )
			tempvar = fInstrumentScaleFactor[ chanNum ]
		else
			tempvar = Nan
		endif
		
		if ( ( numtype( tempvar ) == 0 ) && ( tempvar > 0 ) )
			scaleFactors[ ccnt ] = ADCRange / ( ADCResolution * tempvar )
		else
			scaleFactors[ ccnt ] = ADCRange / ADCResolution
		endif
		
	endfor
	
	//
	// Extended Environmental Info
	//
	
	wName = NM_ABFHeaderWaveName( "*TelegraphAdditGain", folder = df )
	
	if ( WaveExists( $wName ) )
	
		Wave fTelegraphAdditGain = $wName
	
		for ( ccnt = 0; ccnt < NumChannels; ccnt += 1 )
		
			chanNum = nADCSamplingSeq[ ccnt ]
		
			if ( ( chanNum >= 0 ) && ( chanNum < numpnts( fTelegraphAdditGain ) ) )
				tempvar = fTelegraphAdditGain[ chanNum ]
			else
				tempvar = NAN
			endif
			
			if ( ( numtype( tempvar ) == 0 ) && ( tempvar > 0 ) )
				scaleFactors[ ccnt ] /= tempvar
				//print "chan" + num2istr( ccnt ) + " telegraph gain:", NM_ReadPclampWave0[ ccnt ]
			endif
			
		endfor
	
	endif
	
	CheckNMwave( df+"FileScaleFactors", numChannels, 1 )
	CheckNMtwave( df+"yLabel", numChannels, "" )
	
	return 0
	
End // ReadPclampHeaderUpdateNM

Function ReadPclampVar( file, varType, pointer )
	String file // external ABF data file
	String varType // variable type
	Variable pointer // read file pointer in bytes
	
	if ( !FileExistsAndNonZero( file ) )
		return NaN
	endif
	
	pointer = ReadPclampFile( file, varType, pointer, 1 )
	
	if ( numtype( pointer ) > 0 )
		NM2Error( 10, "pointer", num2str( pointer ) )
		return Nan
	endif
	
	if ( !WaveExists( NM_ReadPclampWave0 ) )
		NM2Error( 1, "NM_ReadPclampWave0", "" )
		return Nan
	endif
	
	Wave NM_ReadPclampWave0
	
	return NM_ReadPclampWave0[ 0 ]

End // ReadPclampVar

Function ReadPclampVarPointer( file, varType )
	String file // external ABF data file
	String varType // variable type
	
	if ( exists( "ABF_Read_Pointer" ) != 2 )
		NM2Error( 13, "ABF_Read_Pointer", "" )
		return NaN // this global variable is required
	endif
	
	NVAR ABF_Read_Pointer
	
	ABF_Read_Pointer = ReadPclampFile( file, varType, ABF_Read_Pointer, 1 )
	
	if ( numtype( ABF_Read_Pointer ) > 0 )
		NM2Error( 10, "ABF_Read_Pointer", num2str( ABF_Read_Pointer ) )
		return Nan
	endif
	
	if ( !WaveExists( NM_ReadPclampWave0 ) )
		NM2Error( 1, "NM_ReadPclampWave0", "" )
		return Nan
	endif
	
	Wave NM_ReadPclampWave0
	
	return NM_ReadPclampWave0[ 0 ]

End // ReadPclampVarPointer

Function NM_ABFHeaderVar( varNameOrMatchStr, [ folder, alert ] )
	String varNameOrMatchStr
	String folder
	Variable alert
	
	String varList, varName = ""
	
	if ( ParamIsDefault( folder ) )
		folder = GetDataFolder( 1 ) + ABF_SUBFOLDERNAME + ":"
	else
		folder = ParseFilePath( 2, folder, ":", 0, 0 ) + ABF_SUBFOLDERNAME + ":"
	endif
	
	if ( strsearch( varNameOrMatchStr, "*", 0 ) >= 0 ) // found match string
	
		varList = NMFolderVariableList( folder, varNameOrMatchStr, ";", 4, 0 )
	
		if ( ItemsInList( varList ) > 0 )
			varName = StringFromList( 0, varList )
		endif
		
	else
	
		varName = varNameOrMatchStr
	
	endif
	
	if ( ( strlen( varName ) > 0 ) && ( exists( folder + varName ) == 2 ) )
		return NumVarOrDefault( folder + varName, NaN )
	endif
	
	if ( alert )
		NM2Error( 13, "varNameOrMatchStr", varNameOrMatchStr )
	endif
		
	return NaN
	
End // NM_ABFHeaderVar

Function /S NM_ABFHeaderWaveName( matchStr, [ folder ] )
	String matchStr
	String folder
	
	String wList, wName
	
	if ( ParamIsDefault( folder ) )
		folder = GetDataFolder( 1 ) + ABF_SUBFOLDERNAME + ":"
	else
		folder = ParseFilePath( 2, folder, ":", 0, 0 ) + ABF_SUBFOLDERNAME + ":"
	endif
	
	wList = NMFolderWaveList( folder, matchStr, ";", "", 1 )

	if ( ItemsInList( wList ) > 0 )
		return StringFromList( 0, wList )
	endif
	
	return ""
	
End // NM_ABFHeaderWaveName

Static Function /T RemoveEndSpaces( str )
	String str
	Variable icnt
	
	for ( icnt = strlen( str ) - 1; icnt >= 0; icnt -= 1 )
		if ( !stringmatch( str[ icnt, icnt ], " " ) )
			return str[ 0, icnt ]
		endif
	endfor
	
	return str
	
End // RemoveEndSpaces

Function /S NMFolderVariableList( folder, matchStr, separatorStr, variableTypeCode, fullPath )
	String folder // ( "" ) for current folder
	String matchStr, separatorStr // see Igor VariableList
	Variable variableTypeCode // see Igor VariableList
	Variable fullPath // ( 0 ) no, just variable name ( 1 ) yes, directory + variable name
	
	Variable icnt
	String sList, sName, oList = ""
	String saveDF = GetDataFolder( 1 ) // save current directory
	
	if ( strlen( folder ) == 0 )
		folder = GetDataFolder( 1 )
	endif
	
	if ( DataFolderExists( folder ) == 0 )
		return NM2ErrorStr( 30, "folder", folder )
	endif
	
	SetDataFolder $folder
	
	sList = VariableList( matchStr, separatorStr, variableTypeCode )
	
	SetDataFolder $saveDF // back to original data folder
	
	if ( fullPath == 1 )
	
		for ( icnt = 0 ; icnt < ItemsInList( sList ) ; icnt += 1 )
			sName = StringFromList( icnt, sList )
			oList = AddListItem( folder+sName, oList, separatorStr, inf ) // full-path names
		endfor
		
		sList = oList
	
	endif
	
	return sList

End // NMFolderVariableList

Function ReadPClampData( file, df )
	String file // external ABF data file
	String df // NM data folder where everything is imported
	
	Variable format = ReadPclampFormat( file )
	
	df = ParseFilePath( 2, df, ":", 0, 0 )
		
	switch( format )
		case 1:
		case 2:
			break
		default:
			Print "Import File Aborted: file not of Pclamp format"
			return -1
	endswitch
	
	if ( ReadPclampXOPExists() )
		return ReadPClampDataXOP( file, df )
	endif
	
	ReadPclampXOPAlert()
	
	switch( format )
		case 1:
		case 2: // can use old version for reading data
			return ReadPClampData1( file, df ) 
	endswitch
	
	return -1
	
End // ReadPClampData

Static Function ReadPClampDataXOP( file, df )
	String file // external ABF data file
	String df // NM data folder where everything is imported
	
	Variable wcnt, ccnt, scnt, scale, startNum, amode, samples
	String wName, cName, wNote, wList
	
	Variable concat = NumVarOrDefault( NMDF+"ABF_GapFreeConcat", 1 )
	
	df = ParseFilePath( 2, df, ":", 0, 0 )
	
	String acqMode = StrVarOrDefault( df+"AcqMode", "" )
	
	if ( strlen( acqMode ) == 0 )
	
		if ( ReadPClampHeaderXOP( file, df ) < 0 ) // read header first
			return -1
		endif
		
		acqMode = StrVarOrDefault( df+"AcqMode", "" )
	
	endif
	
	amode = str2num( acqMode[ 0 ] )
	
	String hdf = df + ABF_SUBFOLDERNAME + ":"
	
	Variable NumWaves = NumVarOrDefault( df+"NumWaves", 0 )
	Variable NumChannels = NumVarOrDefault( df+"NumChannels", 0 )
	Variable WaveBgn = NumVarOrDefault( df+"WaveBgn", 0 )
	Variable WaveEnd = NumVarOrDefault( df+"WaveEnd", -1 )
	Variable format = ReadPclampFormat( file )
	
	String wavePrefix = StrVarOrDefault( df+"WavePrefix", NMStrGet( "WavePrefix" ) )
	String xLabel = StrVarOrDefault( df+"xLabel", "msec" )
	
	Wave scaleFactors = $df+"FileScaleFactors"
	Wave /T yAxisLabels = $df+"yLabel"
	
	String saveDF = GetDataFolder( 1 )
	
	SetDataFolder $df
	
	startNum = NextWaveNum( "", wavePrefix, 0, 0 )
	
	if ( ( WaveBgn > WaveEnd ) || ( startNum < 0 ) || ( numtype( WaveBgn*WaveEnd*startNum ) != 0 ) )
		return 0 // options not allowed
	endif
	
	NMProgressCall( -1, "Reading Pclamp File..." ) // bring up progress window
	
	Execute /Z "ReadPclamp /D /N=( " + num2istr( WaveBgn + 1 ) + "," + num2istr( WaveEnd + 1 ) + " ) /P=" + NMQuotes( wavePrefix ) + " /S=" + num2istr( startNum ) + " " + NMQuotes( ReadPClampFileC( file ) )
	
	SetDataFolder $saveDF // back to original folder
	
	NMProgressKill()
	
	WaveBgn += startNum
	WaveEnd += startNum
	
	for ( ccnt = 0 ; ccnt < NumChannels ; ccnt += 1 )
	
		scnt = 0
		
		if ( ccnt < numpnts( scaleFactors ) )
			scale = scaleFactors[ ccnt ]
		else
			scale = 1
		endif
		
		for ( wcnt = WaveBgn ; wcnt <= WaveEnd ; wcnt += 1 )
		
			wName = GetWaveName( wavePrefix, ccnt, wcnt )
			
			wNote = "Folder:" + GetDataFolder( 0 )
			wNote += NMCR + "File:" + NMNoteCheck( file )
			wNote += NMCR + "Chan:" + ChanNum2Char( ccnt )
			wNote += NMCR + "Wave:" + num2istr( wcnt )
			wNote += NMCR + "Scale:" + num2str( scale )

			NMNoteType( wName, "Pclamp " + num2str( format ), xLabel, yAxisLabels[ ccnt ], wNote )
			PclampTimeStamps( file, format, amode, df, wName, scnt )
			
			scnt += 1
			
		endfor
	endfor
	
	if ( ( amode == 3 ) && concat )
	
		for ( ccnt = 0 ; ccnt < NumChannels ; ccnt += 1 )
		
			wList = ""
		
			for ( wcnt = WaveBgn ; wcnt <= WaveEnd ; wcnt += 1 )
				wName = GetWaveName( wavePrefix, ccnt, wcnt )
				wList = AddListItem( wName, wList, ";", inf )
			endfor
			
			cName = GetWaveName( "C_ABF_" + wavePrefix, ccnt, WaveBgn )
			
			Concatenate /O/NP wList, $cName
			
			if ( WaveExists( $cName ) )
				DeleteWaves( wList )
			else
				concat = 0 // something went wrong
				break
			endif
			
			wName = GetWaveName( wavePrefix, ccnt, WaveBgn )
			
			Duplicate /O $cName $wName
			
			samples = numpnts( $wName )
			
			wNote = "Folder:" + GetDataFolder( 0 )
			wNote += NMCR + "File:" + NMNoteCheck( file )
			wNote += NMCR + "Chan:" + ChanNum2Char( ccnt )
			wNote += NMCR + "Wave:" + num2istr( WaveBgn )
			wNote += NMCR + "Scale:" + num2str( scale )

			NMNoteType( wName, "Pclamp " + num2str( format ), xLabel, yAxisLabels[ ccnt ], wNote )
			PclampTimeStamps( file, format, amode, df, wName, 0 )
			
		endfor
		
		if ( concat )
			SetNMvar( df + "NumWaves", 1 )
			SetNMvar( df + "TotalNumWaves", 1 * NumChannels )
			SetNMvar( df + "SamplesPerWave", samples )
			WaveEnd = WaveBgn
		endif
		
		wList = WaveList( "C_ABF_*", ";", "" )
		DeleteWaves( wList )
	
	endif
	
	return ( WaveEnd - WaveBgn + 1 )
	
End // ReadPClampDataXOP

Static Function ReadPClampData1( file, df )
	String file // external ABF data file
	String df // NM data folder where everything is imported

	Variable startNum, nwaves, amode, scale, pointer, column, nsamples, bytesPerEpisode
	Variable ccnt, wcnt, scnt, npnts, lastwave, cancel
	String wName, wNote, wList
	
	Variable format = ReadPclampFormat( file )
	
	String saveDF = GetDataFolder( 1 )
	
	df = ParseFilePath( 2, df, ":", 0, 0 )
	
	if ( !FileExistsAndNonZero( file ) )
		return -1
	endif
	
	String acqMode = StrVarOrDefault( df+"AcqMode", "" )
	
	if ( strlen( acqMode ) == 0 )
	
		switch( format )
		
			case 1:
			
				if ( ReadPClampHeader1( file, df ) < 0 )
					return -1
				endif
			
				break
				
			case 2:
			
				if ( ReadPClampHeader2( file, df ) < 0 )
					return -1
				endif
			
				break
				
			default:
			
				return -1
		
		endswitch
		
		acqMode = StrVarOrDefault( df+"AcqMode", "" )
	
	endif
	
	amode = str2num( acqMode[ 0 ] )
	
	Variable NumChannels = NumVarOrDefault( df+"NumChannels", 0 )
	Variable NumWaves = NumVarOrDefault( df+"NumWaves", 0 )
	Variable SamplesPerWave = NumVarOrDefault( df+"SamplesPerWave", 0 )
	Variable SampleInterval = NumVarOrDefault( df+"SampleInterval", 1 )
	Variable AcqLength = NumVarOrDefault( df+"AcqLength", 0 )
	Variable DataPointer = NumVarOrDefault( df+"DataPointer", 0 )
	Variable WaveBgn = NumVarOrDefault( df+"WaveBgn", 0 )
	Variable WaveEnd = NumVarOrDefault( df+"WaveEnd", -1 )
	
	String xLabel = StrVarOrDefault( df+"xLabel", "msec" )
	String wavePrefix = StrVarOrDefault( df+"WavePrefix", NMStrGet( "WavePrefix" ) )
	
	Wave scaleFactors = $df+"FileScaleFactors"
	Wave /T yAxisLabels = $df+"yLabel"
	
	Variable DataFormat = NumVarOrDefault( df+"DataFormat", 0 )
	
	switch( DataFormat )
		case 0:
		case 1:
			break
		default:
			DoAlert 0, "Abort ABF Import: unrecognized DataFormat: " + num2istr( DataFormat )
			return 0 // option not allowed
	endswitch
	
	SetDataFolder $df
	
	startNum = NextWaveNum( "", wavePrefix, 0, 0 )
	
	if ( WaveEnd < 0 )
		WaveEnd = NumWaves - 1
	endif
	
	if ( ( WaveBgn > WaveEnd ) || ( startNum < 0 ) || ( numtype( WaveBgn*WaveEnd*startNum ) != 0 ) )
		return 0 // options not allowed
	endif
	
	Make /O NM_ReadPclampWave0, NM_ReadPclampWave1 // where GBLoadWave puts data
	
	lastwave = ceil( AcqLength / ( NumChannels * SamplesPerWave ) )
	
	WaveEnd = min( WaveEnd, lastwave )
	
	if ( amode == 3 ) // gap-free
		WaveBgn = 0
		WaveEnd = NumWaves - 1 // force importing all waves
	endif
	
	nwaves = ceil( WaveEnd ) - floor( WaveBgn ) + 1
	
	NMProgressCall( -1, "Importing ABF waves ..." )
	
	column = WaveBgn
	
	if ( DataFormat == 0 ) // 2-byte integer
	
		bytesPerEpisode = SamplesPerWave * NumChannels * 2
		pointer = ABF_BLOCK * DataPointer + bytesPerEpisode * column
		nsamples = nwaves * bytesPerEpisode
		nsamples = min( nsamples, AcqLength )
		
		GBLoadWave/O/Q/B/N=NM_ReadPClampWave/T={16,2}/S=(pointer)/W=1/U=(nsamples) file
		
	elseif ( DataFormat == 1 ) // 4-byte float
	
		bytesPerEpisode = SamplesPerWave * NumChannels * 4
		pointer = ABF_BLOCK * DataPointer + bytesPerEpisode * column
		nsamples = nwaves * bytesPerEpisode
		nsamples = min( nsamples, AcqLength )
		
		GBLoadWave/O/Q/B/N=NM_ReadPClampWave/T={2,2}/S=(pointer)/W=1/U=(nsamples) file
		
	endif
	
	if ( NMProgressCall( -2, "Importing ABF waves ..." ) == 1 )
		return 0 // cancel
	endif
	
	npnts = nsamples / NumChannels
	
	if ( amode == 3 )
		WaveBgn = 0
		WaveEnd = 0
		nwaves = 1
		SamplesPerWave = npnts
		SetNMvar( df + "NumWaves", 1 )
		SetNMvar( df + "TotalNumWaves", 1 * NumChannels )
		SetNMvar( df + "SamplesPerWave", npnts )
	endif 
	
	for ( ccnt = 0; ccnt < NumChannels; ccnt += 1 ) // unpack channel waves
	
		if ( NumChannels == 1 )
		
			Wave ctemp = NM_ReadPclampWave0
		
		else
		
			wName = "NM_ReadPClampWave_" + num2istr( ccnt )
		
			Make /O/N=( npnts ) $wName
			
			Wave ctemp = $wName
			
			ctemp = NM_ReadPclampWave0[ x * NumChannels + ccnt ]
		
		endif
		
		scale = scaleFactors[ ccnt ]
			
		if ( ABF_SCALEWAVES )
			if ( ( numtype( scale ) == 0 ) && ( scale > 0 ) )
				ctemp *= scale
			endif
		endif
		
		scnt = 0
	
		for ( wcnt = WaveBgn; wcnt <= WaveEnd; wcnt += 1 )
		
			if ( NMProgressCall( -2, "Importing ABF waves ..." ) == 1 )
				cancel = 1
				break
			endif
		
			wName = GetWaveName( wavePrefix, ccnt, ( scnt + startNum ) )
			
			Make /O/N=( SamplesPerWave ) $wName
			
			Wave wtemp = $wName
			
			wtemp = ctemp[ x + scnt * SamplesPerWave ]
			
			Setscale /P x 0, SampleInterval, $wName
			
			wNote = "Folder:" + GetDataFolder( 0 )
			wNote += NMCR + "File:" + NMNoteCheck( file )
			wNote += NMCR + "Chan:" + ChanNum2Char( ccnt )
			wNote += NMCR + "Wave:" + num2istr( wcnt )
			wNote += NMCR + "Scale:" + num2str( scale )

			NMNoteType( wName, "Pclamp " + num2str( format ), xLabel, yAxisLabels[ ccnt ], wNote )
			
			PclampTimeStamps( file, format, amode, df, wName, scnt )
			
			scnt += 1
		
		endfor
		
		if ( cancel )
			break
		endif
	
	endfor
	
	NMProgressKill()
	
	KillVariables /Z $df+"DataPointer"
	
	wList = WaveList( "NM_ReadPclampWave*", ";", "" )
	
	DeleteWaves( wList )
	
	SetDataFolder $saveDF // back to original folder
	
	return nwaves

End // ReadPClampData1

Static Function PclampTimeStamps( file, format, amode, df, wName, episodeNum ) // modified from code from Gerard Borst, Erasmus MC, Dept of Neuroscience
	String file
	Variable format // pclamp format
	Variable amode // acquisition mode
	String df // NM data folder where everything is imported
	String wName // wave name
	Variable episodeNum // corresponding episode number for this wave
	
	Variable fileStartTime, fileStartMillisecs, stopwatchTime
	Variable runsPerTrial, episodesPerRun, triggerSource, episodeStartToStart, recordStart
	String tstr, wNote
	String thisfxn = GetRTStackInfo( 1 )
	
	df = ParseFilePath( 2, df, ":", 0, 0 )
	
	String wavePrefix = StrVarOrDefault( df + "WavePrefix", NMStrGet( "WavePrefix" ) )
	String wNameT1 = df + ABF_WAVENAMETIME1
	String wNameT2 = df + ABF_WAVENAMETIME2
	
	Variable sampleInterval = NumVarOrDefault( df + "SampleInterval", NaN )
	Variable samplesPerWave = NumVarOrDefault( df + "SamplesPerWave", NaN )
	Variable numChannels = NumVarOrDefault( df + "NumChannels", NaN )
	
	if ( ( numtype( sampleInterval ) > 0 ) || ( numtype( samplesPerWave ) > 0 ) )
		Print thisfxn + " Error: cannot locate SampleInterval or SamplesPerWave"
		return -1
	endif
	
	if ( ( numtype( numChannels ) > 0 ) || ( numChannels <= 0 ) )
		Print thisfxn + " Error: cannot locate NumChannels"
		return -1
	endif
	
	fileStartTime = NM_ABFHeaderVar( "*FileStartTimeMS", folder = df )
	
	if ( numtype( fileStartTime ) == 0 )
		fileStartTime /= 1000 // convert to seconds
	else
		fileStartTime = NM_ABFHeaderVar( "*FileStartTime", folder = df )
		// time of day in seconds past midnight when data portion of this file was first written to
	endif
	
	if ( numtype( fileStartTime ) > 0 )
		Print thisfxn + " Error: cannot locate FileStartTime"
		return -1
	endif
	
	fileStartMillisecs = NM_ABFHeaderVar( "*FileStartMillisecs", folder = df ) // msec portion of lFileStartTime
	
	if ( numtype( fileStartMillisecs ) ==  0 )
		fileStartTime += fileStartMillisecs / 1000
	endif
	
	//Print "FileStartTime", NMSecondsToStopwatch( fileStartTime )
	tstr = NMSecondsToStopwatch( fileStartTime )
	tstr = ReplaceString( ":", tstr, "," )
	NMNoteStrReplace( wName, "ABF_FileStartTime", tstr )
	sprintf tstr, "%.3f", fileStartTime
	NMNoteStrReplace( wName, "ABF_FileStartTimeSeconds", tstr )
	
	stopwatchTime = NM_ABFHeaderVar( "*StopwatchTime", folder = df )
	
	if ( numtype( stopwatchTime ) > 0 )
		Print thisfxn + " Error: cannot locate StopwatchTime"
		return -1
	endif
	
	//Print "StopwatchTime", NMSecondsToStopwatch( stopwatchTime )
	tstr = NMSecondsToStopwatch( stopwatchTime )
	tstr = ReplaceString( ":", tstr, "," )
	NMNoteStrReplace( wName, "ABF_StopwatchTime", tstr )
	sprintf tstr, "%.3f", stopwatchTime
	NMNoteStrReplace( wName, "ABF_StopwatchTimeSeconds", tstr )
	
	runsPerTrial = NM_ABFHeaderVar( "*RunsPerTrial", folder = df )
	// requested number of runs/trial.  0=Run until terminated by user. Runs are averaged.  If nOperationMode = 3 (gap free), the value of this parameter is 1.  See lAverageCount.
	
	if ( numtype( runsPerTrial ) > 0 )
		Print thisfxn + " Error: cannot locate RunsPerTrial"
		return -1
	endif
	
	if ( runsPerTrial > 1 )
		return 0 // finished, the remaining code currently only works for files with one run per trial
	endif
	
	episodesPerRun = NM_ABFHeaderVar( "*EpisodesPerRun", folder = df )
	// requested number of episodes/run.  0=Run until terminated by user. If nOperationMode = 3 (gap free), this parameter is 1 and the requested acquisition length is set in fSecondsPerRun.
	
	if ( numtype( episodesPerRun ) > 0 )
		Print thisfxn + " Error: cannot locate EpisodesPerRun"
		return -1
	endif
	
	triggerSource = NM_ABFHeaderVar( "*TriggerSource", folder = df )
	// trigger source:  N (>=0) = Physical channel number selected for threshold detection;  -1 = external trigger;  -2 = keyboard;  -3 = use start-to-start interval. If nOperationMode=3 (gap-free)  0 = start immediately.
	
	if ( numtype( triggerSource ) > 0 )
		Print thisfxn + " Error: cannot locate TriggerSource"
		return -1
	endif
	
	episodeStartToStart = NM_ABFHeaderVar( "*EpisodeStartToStart", folder = df )
	// time between start of sweeps (seconds).  Use when nTriggerSource = "start-to-start".
	
	if ( numtype( episodeStartToStart ) > 0 )
		Print thisfxn + " Error: cannot locate EpisodeStartToStart"
		return -1
	endif
	
	if ( ( episodesPerRun > 1 ) && ( triggerSource != -3 ) && ( episodeNum > 0 ) )
		//Print "Start of episode cannot be reliably determined from ABF header"
		return 0
	endif
	
	if ( ( episodesPerRun == 1 ) && ( episodeNum > 0 ) )
		//Print thisfxn + " Error: wrong episode number : ", episodeNum
		//return -1
		// could be gap-free with XOP import
	endif
	
	recordStart = fileStartTime + episodeNum * episodeStartToStart // assumes no missing traces, ascending order, etc.  !!!!!!!!!!!!!!!!!
	
	tstr = NMSecondsToStopwatch( recordStart )
	tstr = ReplaceString( ":", tstr, "," )
	
	NMNoteStrReplace( wName, "ABF_EpisodeTime", tstr )
	
	sprintf tstr, "%.3f", recordStart

	NMNoteStrReplace( wName, "ABF_EpisodeTimeSeconds", tstr )
	
	if ( ( amode == 3 ) || ( episodesPerRun <= 1 ) )
		return 0
	endif
	
	if ( WaveExists( $wNameT1 ) == 0 )
	
		Make /O/N=( episodesPerRun ) $wNameT1 = NaN
		
		wNote = "Folder:" + GetDataFolder( 0 )
		wNote += NMCR + "File:" + NMNoteCheck( file )
		NMNoteType( wNameT1, "Pclamp " + num2str( format ), "episode #", "seconds past midnight", wNote )
		
	endif
	
	if ( WaveExists( $wNameT2 ) == 0 )
	
		Make /O/N=( episodesPerRun ) $wNameT2 = NaN
		
		wNote = "Folder:" + GetDataFolder( 0 )
		wNote += NMCR + "File:" + NMNoteCheck( file )
		NMNoteType( wNameT2, "Pclamp " + num2str( format ), "episode #", "msec", wNote )
	
	endif
	
	Wave wt1 = $wNameT1
	
	if ( ( episodeNum >= 0 ) && ( episodeNum < numpnts( wt1 ) ) && ( numtype( wt1[ episodeNum ] ) > 0 ) )
		wt1[ episodeNum ] = recordStart
	endif
	
	Wave wt2 = $wNameT2
	
	if ( ( episodeNum >= 0 ) && ( episodeNum < numpnts( wt2 ) ) && ( numtype( wt2[ episodeNum ] ) > 0 ) )
		wt2[ episodeNum ] = episodeNum * episodeStartToStart * 1000 // ms
	endif
	
	return 0

End // PclampTimeStamps

Function /S NMSecondsToStopwatch( timeInSeconds ) // from Gerard Borst, Erasmus MC, Dept of Neuroscience
	Variable timeInSeconds

	if ( numtype( timeInSeconds ) > 0 )
		return ""
	endif

	Variable hours, minutes, seconds
	String daytime

	hours = floor( timeInSeconds / 3600 )
	timeInSeconds -= hours * 3600
	
	minutes = floor( timeInSeconds / 60 )
	timeInSeconds -= minutes * 60
	
	seconds = timeInSeconds

	daytime = SelectString( ( hours < 10 ), num2str( hours ), num2str( 0 ) + num2str( hours ) ) + ":"
	daytime += SelectString( ( minutes < 10 ), num2str( minutes ), num2str( 0 ) + num2str( minutes ) ) + ":"
	daytime += SelectString( ( seconds < 10 ), num2str( seconds ), num2str( 0 ) + num2str( seconds ) )

	return daytime

End // NMSecondsToStopwatch
