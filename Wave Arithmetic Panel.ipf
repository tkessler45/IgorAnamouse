#pragma rtGlobals=2		// Use modern global access method.
#pragma version=2.02
#pragma IgorVersion=6.20

// Wave Arithmetic Panel
// See the accompanying help file for details on the use of this procedure file.
//
// The Wave Arithmetic Panel was originally developed by John Weeks for 
// Dept. of Physics, Div. 5, Uppsala University, 1996. 

// for version 1.01, changed to #pragma rtGlobals=2
// for version 1.03, JP: changed fixed use of obsolete Strings as Lists procedure file.

// Release 2.00
//		100528 modernization
// Release 2.01 JW 101109
//		Fixed bugs in Constant Arithmetic and Wave Arithmetic: results wave couldn't handle a liberal name
// Release 2.02 JW 101118
//		Fixed bugs in Wave Arithmetic:
//			When using Cursor A or Cursor B as the destination, code ran that tried to add a trace to the graph, but the wave name was empty.
//			When initializing, Cursor B destination was selected, but X Values from area was not disabled. Now New Wave is initially selected as the destination.
//			Undo info for subtract, multiply and divide lacked a space so the undo messages looked like "  UNDO Subtractroot:junk - root:junk2"

#include <SaveRestoreWindowCoords>, version >=6.1

#include <Axis Utilities>
#include <Wave Lists>
#include <CsrTraceName>
#include <Graph Utility Procs>

Menu "Analysis"
	"Wave Arithmetic Panel", InitWaveArith(WinName(0,1))
end

Function InitWaveArith(gname)
	String gname
	
	if (strlen(gname) == 0)
		DoAlert 0, "The Wave Arithmetic package requires a graph window."
		return -1
	endif

	String SaveDF=GetDataFolder(2)
	SetDataFolder root:
	NewDataFolder/S/O Packages
	NewDataFolder/S/O WM_WaveArithPanel
	NewDataFolder/S/O $gname
	
	String/G IgorPlatform=IgorInfo(2)
	Variable/G IgorOnMac = CmpStr(IgorPlatform, "Macintosh")==0
	if (IgorOnMac)
		String/G BullitChar=num2char(-91)
		String/G DeltaStr=num2char(-58)
	else
		String/G BullitChar=num2char(-107)
		String/G DeltaStr="delta"
	endif
	
	String tempStr
	Variable tempVar

	tempVar = NumVarOrDefault("root:Packages:WM_WaveArithPanel:"+gname+":GArithConst", 1)
	Variable/G GArithConst = tempVar

	tempVar = NumVarOrDefault("root:Packages:WM_WaveArithPanel:"+gname+":WAr_XValuesFromRadioSelection", 3)
	Variable/G WAr_XValuesFromRadioSelection = tempVar
	tempStr = StrVarOrDefault("root:Packages:WM_WaveArithPanel:"+gname+":GSWA_ResultName", "NewWave")
	String/G GSWA_ResultName = tempStr
	tempStr = StrVarOrDefault("root:Packages:WM_WaveArithPanel:"+gname+":GSWA_NewTraceName", "")
	String/G GSWA_NewTraceName = tempStr

	tempVar = NumVarOrDefault("root:Packages:WM_WaveArithPanel:"+gname+":GXS_ShiftConst", 0)
	Variable/G GXS_ShiftConst = tempVar

	tempStr = StrVarOrDefault("root:Packages:WM_WaveArithPanel:"+gname+":GGC_AWave", "")
	String/G GGC_AWave = tempStr
	tempStr = StrVarOrDefault("root:Packages:WM_WaveArithPanel:"+gname+":GGC_BWave", "")
	String/G GGC_BWave = tempStr
	tempVar = NumVarOrDefault("root:Packages:WM_WaveArithPanel:"+gname+":GGC_BPoint", 0)
	Variable/G GGC_BPoint = tempVar
	tempVar = NumVarOrDefault("root:Packages:WM_WaveArithPanel:"+gname+":GGC_APoint", 0)
	Variable/G GGC_APoint = tempVar
	tempStr = StrVarOrDefault("root:Packages:WM_WaveArithPanel:"+gname+":GNewWaveConst", "NewWave")
	String/G GNewWaveConst = tempStr
	
	tempVar = NumVarOrDefault("root:Packages:WM_WaveArithPanel:"+gname+":gUndoIndex", 0)
	Variable/G gUndoIndex = tempVar
	
	fWaveArithmeticPanel(gname)
	
	SetDataFolder $SaveDF
end

Proc MakeGraphControls(ctrlName) : ButtonControl
	String ctrlName
	
	if (wintype("GraphControls") == 0)
		GraphControls()
	else
		DoWindow/F GraphControls
	endif
end

Function/S GetGraphName(controlPanelName)
	String controlPanelName
	
	String GraphName, subpanelName
	String regexp = "([[:print:]]+)#WaveArithmeticPanel(#([[:print:]]+))?"
	SplitString/E=regexp controlPanelName, GraphName, subpanelName

	return GraphName
end

// returns trace name if yWave is displayed as a Wave Arithemetic Panel trace
Function/S CheckWArWaveDisplayed(gname, yWave)
	String gname
	Wave yWave
	
	String tracelist = TraceNameList(gname, ";", 1)
	Variable ntraces = ItemsInList(tracelist)
	Variable i
	String returnValue = ""
	
	for (i = 0; i < ntraces; i += 1)
		String oneTrace = StringFromList(i, tracelist)
		if (StringMatch(oneTrace, "WAr_*"))
			if (strlen(GetUserData(gname, oneTrace, "WArTrace")) > 0)
				Wave w = TraceNameToWaveRef(gname, oneTrace)
				if (WaveRefsEqual(w, yWave))
					returnValue = oneTrace
				endif
			endif
		endif
	endfor
	
	return returnValue
end

Function/S NextWArTraceName(gname)
	String gname
	
	String tracelist = TraceNameList(gname, ";", 1)
	Variable ntraces = ItemsInList(tracelist)
	Variable i
	Variable maxInstance = 0
	
	for (i = 0; i < ntraces; i += 1)
		String oneTrace = StringFromList(i, tracelist)
		if (StringMatch(oneTrace, "WAr_*"))
			if (strlen(GetUserData(gname, oneTrace, "WArTrace")) > 0)
				Variable traceNumber
				sscanf oneTrace, "WAr_%d", traceNumber
				maxInstance = max(maxInstance, traceNumber)
			endif
		endif
	endfor
	
	return "WAr_"+num2istr(maxInstance+1)
end

Function WAr_KillUndoFolders(gname, [firstIndexToKill])
	String gname
	Variable firstIndexToKill
	
	DFREF WArDF = root:Packages:WM_WaveArithPanel:$(gname)

	Variable undoIndex = firstIndexToKill
	
	do
		DFREF possibleDF = WArDF:$("UNDO"+num2str(undoIndex))
		if (DataFolderRefStatus(possibleDF) == 0)
			break;
		endif
		KillDataFolder possibleDF
		undoIndex += 1
	while(1)
end

Function/DF WAr_MakeNextUndoFolder(gname, [undoMessage])
	String gname
	String undoMessage
	
	DFREF WArDF = root:Packages:WM_WaveArithPanel:$(gname)
	
	NVAR gUndoIndex = WArDF:gUndoIndex
	DFREF possibleNextDF = WArDF:$("UNDO"+num2str(gUndoIndex))
	if (DataFolderRefStatus(possibleNextDF) > 0)
		WAr_KillUndoFolders(gname, firstIndexToKill = gUndoIndex)
	endif
	
	NewDataFolder WArDF:$("UNDO"+num2str(gUndoIndex))
	DFREF newDFR = WArDF:$("UNDO"+num2str(gUndoIndex))
	gUndoIndex += 1
	
	if (!ParamIsDefault(undoMessage))
		String/G newDFR:Message = undoMessage
	endif
	
	return newDFR
end

Function/DF WAr_getCurrentUndoFolder(gname)
	String gname
	
	DFREF WArDF = root:Packages:WM_WaveArithPanel:$(gname)
	
	NVAR gUndoIndex = WArDF:gUndoIndex
	DFREF UndoFolder = WArDF:$("UNDO"+num2str(gUndoIndex-1))
	
	return UndoFolder
end

Function/DF WAr_getUndoFolderAndDecrement(gname)
	String gname

	DFREF WArDF = root:Packages:WM_WaveArithPanel:$(gname)
	
	NVAR gUndoIndex = WArDF:gUndoIndex
	if (gUndoIndex == 0)
		return $""
	endif
	
	DFREF UndoFolder = WArDF:$("UNDO"+num2str(gUndoIndex-1))
	if (DataFolderRefStatus(UndoFolder) > 0)
		gUndoIndex -= 1
	endif
	
	return UndoFolder
end

Function/DF WAr_getUndoFolderAndIncrement(gname)
	String gname

	DFREF WArDF = root:Packages:WM_WaveArithPanel:$(gname)
	
	NVAR gUndoIndex = WArDF:gUndoIndex
	DFREF UndoFolder = WArDF:$("UNDO"+num2str(gUndoIndex))
	if (DataFolderRefStatus(UndoFolder) > 0)
		gUndoIndex += 1
	endif
	
	return UndoFolder
end

// must be called before modWave1 or modWave2 is actually modified- it duplicates the waves to save them.
Function WAr_MakeUndoInfo(gname, undoDF, [undoMessage, NewWave1, NewWave2, modWave1, modWave2, newTrace, modTrace, modTraceAction])
	String gname
	DFREF undoDF
	String undoMessage
	String NewWave1, NewWave2
	Wave/Z modWave1, modWave2
	String newTrace
	String modTrace, modTraceAction
	
	if (!ParamIsDefault(undoMessage))
		String/G undoDF:message = undoMessage
	endif
	if (!ParamIsDefault(NewWave1))
		String/G undoDF:NewWavePath1 = NewWave1
	endif
	if (!ParamIsDefault(NewWave2))
		String/G undoDF:NewWavePath2 = NewWave2
	endif
	if (!ParamIsDefault(modWave1))
		Duplicate/O modWave1, UndoDF:savedWave1
		String/G undoDF:modWave1Path = GetWavesDataFolder(modWave1, 2)
	endif
	if (!ParamIsDefault(modWave2))
		Duplicate/O modWave2, UndoDF:savedWave2
		String/G undoDF:modWave2Path = GetWavesDataFolder(modWave2, 2)
	endif
	if (!ParamIsDefault(newTrace))
		String/G undoDF:NewGraphTrace = newTrace
	endif
	if (!ParamIsDefault(modTrace))
		String/G undoDF:modifiedTrace = modTrace
		String/G undoDF:modifiedTraceAction = modTraceAction
	endif
end

Function WAr_DoUndo(gname)
	String gname
	
	DFREF undoFolder = WAr_getUndoFolderAndDecrement(gname)
	if (DataFolderRefStatus(undoFolder) == 0)
		return -1
	endif
	
	SVAR/Z message = undoFolder:message
	if (SVAR_Exists(message))
		print "UNDO "+message
	endif
	
	SVAR/Z modifiedTrace = undoFolder:modifiedTrace
	if (SVAR_Exists(modifiedTrace))
		SVAR modifiedTraceAction = undoFolder:modifiedTraceAction
		if (CmpStr("ADDXWAVE", modifiedTraceAction) == 0)
			Wave xw = XWaveRefFromTrace(gname, modifiedTrace)
			String/G RedoRemovedXWave = GetWavesDataFolder(xw, 2)
			ReplaceWave/W=$gname/X trace = $modifiedTrace, $""
		elseif (CmpStr("REPLACEXWAVE", modifiedTraceAction[0,11]) == 0)
			Wave xw = XWaveRefFromTrace(gname, modifiedTrace)
			String/G RedoReplacedXWave = GetWavesDataFolder(xw, 2)
			Wave oldXWave = $(modifiedTraceAction[13, strlen(modifiedTraceAction)-1])
			ReplaceWave/W=$gname/X trace = $modifiedTrace, oldXWave
		elseif (CmpStr("REMOVEXWAVE", modifiedTraceAction[0,10]) == 0)
			Wave oldXWave = $(modifiedTraceAction[12, strlen(modifiedTraceAction)-1])
			ReplaceWave/W=$gname/X trace = $modifiedTrace, oldXWave
		endif
	endif
	
	SVAR/Z NewGraphTrace = undoFolder:NewGraphTrace
	if (SVAR_Exists(NewGraphTrace))
		Wave yw = TraceNameToWaveRef(gname, NewGraphTrace)
		Wave/Z xw = XWaveRefFromTrace(gname, NewGraphTrace)
		String/G undoFolder:RedoNewTraceYWave = GetWavesDataFolder(yw, 2)
		if (WaveExists(xw))
			String/G undoFolder:RedoNewTraceXWave = GetWavesDataFolder(xw, 2)
		else
			String/G undoFolder:RedoNewTraceXWave = ""
		endif
		RemoveFromGraph/W=$gname $NewGraphTrace
	endif
	
	SVAR/Z modWave1Path = undoFolder:modWave1Path
	if (SVAR_Exists(modWave1Path))
		Wave savedWave = undoFolder:savedWave1
		Duplicate/O $modWave1Path, undoFolder:redoWave1
		Duplicate/O savedWave, $modWave1Path
	endif
	
	SVAR/Z modWave2Path = undoFolder:modWave2Path
	if (SVAR_Exists(modWave2Path))
		Wave savedWave = undoFolder:savedWave2
		Duplicate/O $modWave2Path, undoFolder:redoWave2
		Duplicate/O savedWave, $modWave2Path
	endif
	
	SVAR/Z NewWavePath1 = undoFolder:NewWave1
	if (SVAR_Exists(NewWavePath1))
		Duplicate/O $NewWavePath1, undoFolder:RedoNewWave1
		KillWaves $NewWavePath1
	endif
	
	SVAR/Z NewWavePath2 = undoFolder:NewWave2
	if (SVAR_Exists(NewWavePath2))
		Duplicate/O $NewWavePath2, undoFolder:RedoNewWave2
		KillWaves $NewWavePath2
	endif
	
	return 0
end

Function WAr_DoRedo(gname)
	String gname
	
	DFREF undoFolder = WAr_getUndoFolderAndIncrement(gname)
	if (DataFolderRefStatus(undoFolder) == 0)
		return -1
	endif
	
	SVAR/Z message = undoFolder:message
	if (SVAR_Exists(message))
		print "REDO "+message
	endif
	
	SVAR/Z modWave1Path = undoFolder:modWave1Path
	if (SVAR_Exists(modWave1Path))
		Wave savedWave = undoFolder:savedWave1
		Duplicate/O $modWave1Path, savedWave
		Duplicate/O undoFolder:redoWave1, $modWave1Path
	endif
	
	SVAR/Z modWave2Path = undoFolder:modWave2Path
	if (SVAR_Exists(modWave2Path))
		Wave savedWave = undoFolder:savedWave2
		Duplicate/O $modWave2Path, savedWave
		Duplicate/O undoFolder:redoWave2, $modWave2Path
	endif
	
	SVAR/Z NewWavePath1 = undoFolder:NewWave1
	if (SVAR_Exists(NewWavePath1))
		Duplicate/O undoFolder:RedoNewWave1, $NewWavePath1
	endif
	
	SVAR/Z NewWavePath2 = undoFolder:NewWave2
	if (SVAR_Exists(NewWavePath2))
		Duplicate/O undoFolder:RedoNewWave2, $NewWavePath2
	endif
	
	SVAR/Z modifiedTrace = undoFolder:modifiedTrace
	if (SVAR_Exists(modifiedTrace))
		SVAR modifiedTraceAction = undoFolder:modifiedTraceAction
		if (CmpStr("ADDXWAVE", modifiedTraceAction) == 0)
			SVAR RedoRemovedXWave = undoFolder:RedoRemovedXWave
			ReplaceWave/W=$gname/X trace = $modifiedTrace, $RedoRemovedXWave
		elseif (CmpStr("REPLACEXWAVE", modifiedTraceAction[0,11]) == 0)
			SVAR RedoReplacedXWave = undoFolder:RedoReplacedXWave
			ReplaceWave/W=$gname/X trace = $modifiedTrace, $RedoReplacedXWave
		elseif (CmpStr("REMOVEXWAVE", modifiedTraceAction[0,10]) == 0)
			ReplaceWave/W=$gname/X trace = $modifiedTrace, $""
		endif
	endif
	
	SVAR/Z NewGraphTrace = undoFolder:NewGraphTrace
	if (SVAR_Exists(NewGraphTrace))
		SVAR RedoNewTraceYWave = undoFolder:RedoNewTraceYWave
		SVAR RedoNewTraceXWave = undoFolder:RedoNewTraceXWave
		SVAR NewGraphTrace = undoFolder:NewGraphTrace
		Wave yw = $RedoNewTraceYWave
		Wave/Z xw = $RedoNewTraceXWave
		if (WaveExists(xw))
			AppendToGraph/W = $gname yw/TN=$NewGraphTrace vs xw
		else
			AppendToGraph/W = $gname yw/TN=$NewGraphTrace
		endif
	endif
	
	return 0
end
	
Function WaveArithConst(s) : ButtonControl
	struct WMButtonAction &s
	
	if (s.eventCode != 2)			// only act on mouse-up
		return 0
	endif
	
	String CwaveName, Curs, ResultWaveName
	String CXwaveName, ResultXWaveName

	String gname = GetGraphName(s.win)
	DFREF WArDF = root:Packages:WM_WaveArithPanel:$(gname)
	SVAR GNewWaveConst=WArDF:GNewWaveConst
	SVAR BullitChar=WArDF:BullitChar
	
	NVAR GArithConst=WArDF:GArithConst
	
	Variable NewWave=0, UseXWave
	DoWindow/F $gname
	
	String ctrlName = s.ctrlName
	
	if (cmpstr(ctrlName[0],"A") == 0)
		WAVE/Z Cwave = CsrWaveRef(A, gname)
		WAVE/Z CXwave = CsrXWaveRef(A, gname)
		Curs="A"
	else
		WAVE/Z Cwave = CsrWaveRef(B)
		WAVE/Z CXwave = CsrXWaveRef(B, gname)
		Curs="B"
	endif
	if (!WaveExists(Cwave))
		DoAlert 0, "Couldn't find the wave in the top graph for the "+Curs+" cursor."
		return -1
	endif
	CwaveName = GetWavesDataFolder(Cwave, 2)
	if (WaveExists(CXwave))
		CXwaveName = GetWavesDataFolder(CXwave, 2)
		UseXWave = 1
	else
		CXwaveName = ""
		UseXWave = 0
	endif
	
	if (StringMatch(ctrlName, "*divC"))
		if (GArithConst == 0)
			DoAlert 0, "You don't really want to divide by zero!"
			return -1
		endif
	endif
	
	ControlInfo/W=$(s.win) WAr_SelectCAResultWave
	Variable doCursorWave = CmpStr(S_value, "Cursor") == 0
	if (!doCursorWave)
		ResultWaveName = GetDataFolder(1)+PossiblyQuoteName(GNewWaveConst)
		if (CmpStr(ResultWaveName, CwaveName) == 0)
			DoAlert 1, "The New Wave Name is the same as the source wave (wave marked by the cursor). Overwrite the source wave?"
			if (V_flag == 1)		// Yes was clicked
				doCursorWave = 1
			else
				return 0
			endif
		endif
	endif
	
	DFREF undoDF = WAr_MakeNextUndoFolder(gname)
	
	if (doCursorWave)		// Use cursor wave to receive results
		ResultWaveName = CwaveName
		WAr_MakeUndoInfo(gname, undoDF, modWave1 = $ResultWaveName)
	else						// Use new wave to receive results
		Wave/Z w=$ResultWaveName
		if (WaveExists(w))
			WAr_MakeUndoInfo(gname, undoDF, modWave1=w)
		else
			WAr_MakeUndoInfo(gname, undoDF, NewWave1=ResultWaveName)
		endif
		Duplicate/O $CwaveName, $ResultWaveName/WAVE=WArResultWave
		if (UseXWave)
			if (WaveExists($(ResultWaveName+"_X")))
				Wave xw = $(ResultWaveName+"_X")
				WAr_MakeUndoInfo(gname, undoDF, modWave2=xw)
			else
				WAr_MakeUndoInfo(gname, undoDF, NewWave2=ResultWaveName+"_X")
			endif
			Duplicate/O $CXwaveName, $(ResultWaveName+"_X")/WAVE=WArResultXWave
		endif
//		GSCA_ResultWave = ResultWaveName
		if (UseXWave)
			resultXWaveName = ResultWaveName+"_X"
		endif

		Variable NewTrace = 0
		String WArTraceName = CheckWArWaveDisplayed(gname, WArResultWave)
		String newTraceName = NextWArTraceName(gname)
		if (UseXWave)
			print BullitChar+"Made new waves",ResultWaveName, "and", resultXWaveName," for Constant Arithmetic:"
			print "\tDuplicate/O ",CwaveName,",", ResultWaveName
			print "\tDuplicate/O ",CXwaveName,",", ResultWaveName+"_X"
			if (strlen(WArTraceName) > 0)
				Wave/Z xw = XWaveRefFromTrace(gname, WArTraceName)
				if (!WaveExists(xw))
					WAr_MakeUndoInfo(gname, undoDF, modTrace=WArTraceName, modTraceAction="ADDXWAVE")
					ReplaceWave/X/W=$gname trace=$WArTraceName, WArResultXWave
				endif
				if (!WaveRefsEqual(xw, WArResultXWave))
					WAr_MakeUndoInfo(gname, undoDF, modTrace=WArTraceName, modTraceAction="REPLACEXWAVE="+GetWavesDataFolder(xw, 2))
					ReplaceWave/X/W=$gname trace=$WArTraceName, WArResultXWave
				endif
			else
				NewTrace =1
				WAr_MakeUndoInfo(gname, undoDF, newTrace=newTraceName)
				AppendToGraph/W=$gname   $ResultWaveName/TN=$newTraceName vs $(ResultWaveName+"_X")
				ModifyGraph/W=$gname userData($newTraceName)={WArTrace, 0, "1"}
				print "\tAppendToGraph ", ResultWaveName, " vs ", ResultWaveName+"_X"
			endif
		else
			print BullitChar+"Made new wave",ResultWaveName," for Constant Arithmetic:"
			print "\tDuplicate/O ",CwaveName,",", ResultWaveName
			if (strlen(WArTraceName) > 0)
				Wave/Z xw = XWaveRefFromTrace(gname, WArTraceName)
				if (WaveExists(xw))
					WAr_MakeUndoInfo(gname, undoDF, modTrace=WArTraceName, modTraceAction="REMOVEXWAVE="+GetWavesDataFolder(xw, 2))
					ReplaceWave/X/W=$gname trace=$WArTraceName, $""
				endif
			else
				NewTrace =1
				WAr_MakeUndoInfo(gname, undoDF, newTrace=newTraceName)
				AppendToGraph/W=$gname   $ResultWaveName/TN=$newTraceName
				ModifyGraph/W=$gname userData($newTraceName)={WArTrace, 0, "1"}
				print "\tAppendToGraph ", ResultWaveName, " vs ", ResultWaveName+"_X"
			endif
		endif
		String tname = TraceForWave(gname, ResultWaveName, 0)	// 0 to get last trace on graph
		ModifyGraph/W=$gname rgb($tname)=(0,0,65535)  
		NewWave = 1
	endif
	
	Wave CWave = $CwaveName
	Wave rwave=$ResultWaveName
	
	if (StringMatch(ctrlName, "*plusC"))
		rwave += GArithConst
		print "ADD CONSTANT:"
		WAr_MakeUndoInfo(gname, undoDF, undoMessage = "Add Constant")
		if (NewWave)
			print "\t",ResultWaveName, "= ", CWaveName,"+", GArithConst
		else
			print "\t",CWaveName,"+=",GArithConst
		endif
	endif
	if (StringMatch(ctrlName, "*minusC"))
		print "SUBTRACT CONSTANT:"
		WAr_MakeUndoInfo(gname, undoDF, undoMessage = "Subtract Constant")
		rwave -= GArithConst
		if (NewWave)
			print "\t",ResultWaveName, "= ", CWaveName,"-", GArithConst
		else
			print "\t",CWaveName,"-=",GArithConst
		endif
	endif
	if (StringMatch(ctrlName, "*timesC"))
		print "MULTIPLY BY CONSTANT:"
		WAr_MakeUndoInfo(gname, undoDF, undoMessage = "Multiply by Constant")
		rwave *= GArithConst
		if (NewWave)
			print "\t",ResultWaveName, "= ", CWaveName,"*", GArithConst
		else
			print "\t",CWaveName,"*=",GArithConst
		endif
	endif
	if (StringMatch(ctrlName, "*divC"))
		print "DIVIDE BY CONSTANT:"
		WAr_MakeUndoInfo(gname, undoDF, undoMessage = "Divide by Constant")
		rwave /= GArithConst
		if (NewWave)
			print "\t",ResultWaveName, "= ", CWaveName,"/", GArithConst
		else
			print "\t",CWaveName,"/=",GArithConst
		endif
	endif
End

Function WAr_UndoRedo(s) : ButtonControl
	Struct WMButtonAction &s
	
	if (s.eventCode != 2)		// mouse up
		return 0
	endif
	
	String ctrlName = s.ctrlName
	String gname = GetGraphName(s.win)
	
	if (CmpStr(ctrlName, "WAr_UndoButton") == 0)
		WAr_DoUndo(gname)
	else
		WAr_DoRedo(gname)
	endif
End


Function SelectCAResultWave(s) : PopupMenuControl
	Struct WMPopupAction &s
	
	if (s.eventCode == 2)			// mouse up
		ModifyControl WAr_SetCAResultWaveName, win=$(s.win), disable = (s.popNum == 2 ? 0 : 2)
	endif	
End

Function findMinP(lowX, highX, targetWave)
	Variable lowX, highX
	Wave targetWave
	
	print "findMin:", NameofWave(targetWave), lowX, highX
	Variable i=0
	if (targetWave[0] < targetWave[numpnts(targetWave)])
		if (targetWave[i] >= lowX)
			return 0
		endif
		do
			//print "minP: using lowX", i, targetWave[i]
			i += 1
		while(targetWave[i] < lowX)
	else
		if (targetWave[i] <= highX)
			return 0
		endif
		do
			//print "minP: using highX",i, targetWave[i]
			i += 1
		while(targetWave[i] > highX)
	endif
	print "Min X point", i
	return i
end

Function findMaxP(lowX, highX, targetWave)
	Variable lowX, highX
	Wave targetWave
	
	print "findMax:", NameofWave(targetWave), lowX, highX
	Variable i=numpnts(targetWave)-1
	print i
	if (targetWave[0] < targetWave[ i])
		if (targetWave[i] <= highX)
			return i
		endif
		do
			//print i, targetWave[i]
			i -= 1
		while(targetWave[i] > highX)
	else
		if (targetWave[i] >= lowX)
			return i
		endif
		do
			//print i, targetWave[i]
			i -= 1
		while(targetWave[i] < lowX)
	endif
	print "Max X point", i
	return i
end

// IsMonotonic() returns true if the wave has ∂wave(x)/∂x >= 0 for all x.
static Function IsMonotonic(wv)
	Wave wv
	
	Variable diff,i=0
	Variable nm1=numpnts(wv)-1
	Variable incr=(wv[1]-wv[0])>0
	do
		if(incr)
			diff=wv[i+1]-wv[i]
		else
			diff=wv[i]-wv[i+1]
		endif
		if( numtype(diff) == 0 )
			if (diff<0)
				return 0	// not monotonically increasing. (we allow wv[i+1] == wv[i]).
			endif
		endif
		i += 1
	while (i < nm1)
	return 1			// success
End

Function WAr_FirstAndLastPointFromWave(w, lowValue, highValue, firstPoint, lastPoint)
	Wave w
	Variable lowValue, highValue
	Variable &firstPoint, &lastPoint

	Variable lastPointInWave = numpnts(w)-1
	Variable pnLow = BinarySearch(w, lowValue)
	Variable pnHigh = BinarySearch(w, highValue)
	
	if (w[0] > w[lastPointInWave])					// w is reversed
		firstPoint = pnHigh < 0 ? 0 : (w[pnHigh] == highValue ? pnHigh : pnHigh+1)
		lastPoint = pnLow < 0 ? lastPointInWave : pnLow
	else
		firstPoint = pnLow < 0 ? 0 : (w[pnLow] == lowValue ? pnLow : pnLow+1)
		lastPoint = pnHigh < 0 ? lastPointInWave : pnHigh
	endif
end

Function WaveArithWave(s) : ButtonControl
	Struct WMButtonAction &s
	
	if (s.eventCode != 2)		// mouse up
		return 0
	endif
	
	String ctrlName = s.ctrlName
	String gname = GetGraphName(s.win)
			
	String AwaveName,AXWaveName
	String BwaveName,BXWaveName
	Variable hasAXWave, hasBXWave
	Variable firstX, finalX, firstAX, firstBX, finalAX, finalBX, firstP, finalP
	Variable lowX, highX, lowAX, highAX, lowBX, highBX
	Variable i
	String cmd, Xexpression
	
	NVAR WAr_XValuesFromRadioSelection=root:Packages:WM_WaveArithPanel:$(gname):WAr_XValuesFromRadioSelection

	SVAR GSWA_ResultName=root:Packages:WM_WaveArithPanel:$(gname):GSWA_ResultName
	SVAR BullitChar=root:Packages:WM_WaveArithPanel:$(gname):BullitChar
	
DB(0, "WaveArithWave")
	
	WAVE/Z AWave = CsrWaveRef(A, gname)
	if (!WaveExists(AWave))
		abort "The A cursor is not on a trace in the top graph"
	endif
	WAVE/Z BWave = CsrWaveRef(B, gname)
	if (!WaveExists(BWave))
		abort "The B cursor is not on a trace in the top graph"
	endif

	AwaveName = GetWavesDataFolder(AWave, 2)
	
	WAVE/Z AXWave = CsrXWaveRef(A, gname)
	if (WaveExists(AXWave))
		hasAXWave = 1
		AXWaveName = GetWavesDataFolder(AXWave,2)
		if (!IsMonotonic(AXWave))
			DoAlert 0, "The X values for trace A are not monotonic. Wave Arithmetic requires monotonic X values."
			return 0
		endif
	else
		hasAXWave = 0
		AXWaveName = ""
	endif
	
	BwaveName = GetWavesDataFolder(BWave, 2)
	
	WAVE/Z BXWave = CsrXWaveRef(B, gname)
	if (WaveExists(BXWave))
		hasBXWave = 1
		BXWaveName = GetWavesDataFolder(BXWave,2)
		if (!IsMonotonic(BXWave))
			DoAlert 0, "The X values for trace B are not monotonic. Wave Arithmetic requires monotonic X values."
			return 0
		endif
	else
		hasBXWave = 0
		BXWaveName = ""
	endif
	
DB(1, "WaveArithWave")
	
	Variable AReversed, BReversed
	if (hasAXWave)
		firstAX = AXWave[0]
		finalAX = AXWave[numpnts(AXWave)-1]
	else
		firstAX = leftx(AWave)
		finalAX = pnt2x(AWave,numpnts(AWave)-1)
	endif
	if (hasBXWave)
		firstBX = BXWave[0]
		finalBX = BXWave[numpnts(BXWave)-1]
	else
		firstBX = leftx(BWave)
		finalBX = pnt2x(BWave,numpnts(BWave)-1)
	endif
	lowAX = min(firstAX, finalAX)
	highAX = max(firstAX, finalAX)
	AReversed = firstAX > finalAX
	lowBX = min(firstBX, finalBX)
	highBX = max(firstBX, finalBX)
	BReversed = firstBX > finalBX
	
	lowX = max(lowAX, lowBX)
	highX = min(highAX, highBX)
DB(2, "WaveArithWave")
	if (lowX > highX)
		DoAlert 0, "The chosen waves do not overlap."
		return 0
	endif
	
	// if X Values From A Wave or from B Wave is selected, then use of an X wave depends on whether or not the A or B wave is a waveform or an XY pair.
	// if X Values from A and B Wave is selected, then we will *always* generate an XY pair.
	// The choice of X value source is only available when putting results into a new wave.
	// If results are overwriting A or B, then the X values always come from A or B, respectively.
	
	DFREF undoFolder = WAr_MakeNextUndoFolder(gname)
	
	Variable numResultPoints, Apoints, Bpoints
	Variable firstAPoint, lastAPoint, firstBPoint, lastBPoint
	if (hasAXWave)
		WAr_FirstAndLastPointFromWave(AXWave, lowX, highX, firstAPoint, lastAPoint)
	else
		if (AReversed)
			firstAPoint = ceil((highX - leftx(AWave))/deltax(AWave))
			lastAPoint = floor((lowX - leftx(AWave))/deltax(AWave))
		else
			firstAPoint = ceil((lowX - leftx(AWave))/deltax(AWave))
			lastAPoint = floor((highX - leftx(AWave))/deltax(AWave))
		endif
	endif
	if (hasBXWave)
		WAr_FirstAndLastPointFromWave(BXWave, lowX, highX, firstBPoint, lastBPoint)
	else
		if (BReversed)
			firstBPoint = ceil((highX - leftx(BWave))/deltax(BWave))
			lastBPoint = floor((lowX - leftx(BWave))/deltax(BWave))
		else
			firstBPoint = ceil((lowX - leftx(BWave))/deltax(BWave))
			lastBPoint = floor((highX - leftx(BWave))/deltax(BWave))
		endif
	endif
	APoints = lastAPoint - firstAPoint + 1
	BPoints = lastBPoint - firstBPoint + 1
	switch (WAr_XValuesFromRadioSelection)
		case 1:
			numResultPoints = APoints
			break;
		case 2:
			numResultPoints = BPoints
			break;
		case 3:
			numResultPoints = APoints+Bpoints
			break;
	endswitch
	
	Make/D/FREE/N=(numResultPoints) resultWave, resultXWave
	switch (WAr_XValuesFromRadioSelection)
		case 1:
			if (hasAXWave)
				resultXWave = AXWave[p+firstAPoint]
			else
				resultXWave = pnt2x(AWave, p+firstAPoint)
			endif
			break;
		case 2:
			if (hasBXWave)
				resultXWave = BXWave[p+firstBPoint]
			else
				resultXWave = pnt2x(BWave, p+firstBPoint)
			endif
			break;
		case 3:
			if (hasAXWave)
				resultXWave[0,APoints-1] = AXWave[p+firstAPoint]
			else
				resultXWave[0,APoints-1] = pnt2x(AWave, p+firstAPoint)
			endif
			if (hasBXWave)
				resultXWave[APoints, ] = BXWave[p - APoints + firstBPoint]
			else
				resultXWave[APoints, ] = pnt2x(BWave, p - APoints + firstBPoint)
			endif
			break;
	endswitch
	Sort resultXWave, resultXWave
	
	if (hasAXWave)
		ResultWave = interp(ResultXWave[p], AXWave, AWave )
	else
		ResultWave = AWave(ResultXWave)
	endif
	
	strswitch(ctrlName)
		case "AplusB":
			print BullitChar+"Add "+AWaveName+" + "+BWaveName
			WAr_MakeUndoInfo(gname, undoFolder, undoMessage = "Add "+AWaveName+" + "+BWaveName)
			if (hasBXWave)
				ResultWave += interp(ResultXWave[p], BXWave, BWave )
			else
				ResultWave += BWave(ResultXWave)
			endif
			break;
		case "AminusB":
			print BullitChar+"Subtract "+AWaveName+" - "+BWaveName
			WAr_MakeUndoInfo(gname, undoFolder, undoMessage = "Subtract "+AWaveName+" - "+BWaveName)
			if (hasBXWave)
				ResultWave -= interp(ResultXWave[p], BXWave, BWave )
			else
				ResultWave -= BWave(ResultXWave)
			endif
			break;
		case "AtimesB":
			print BullitChar+"Multiply "+AWaveName+" * "+BWaveName
			WAr_MakeUndoInfo(gname, undoFolder, undoMessage = "Multiply "+AWaveName+" * "+BWaveName)
			if (hasBXWave)
				ResultWave *= interp(ResultXWave[p], BXWave, BWave )
			else
				ResultWave *= BWave(ResultXWave)
			endif
			break;
		case "AdivB":
			print BullitChar+"Divide "+AWaveName+" / "+BWaveName
			WAr_MakeUndoInfo(gname, undoFolder, undoMessage = "Divide "+AWaveName+" / "+BWaveName)
			if (hasBXWave)
				ResultWave /= interp(ResultXWave[p], BXWave, BWave )
			else
				ResultWave /= BWave(ResultXWave)
			endif
			break;
	endswitch
	
	Variable needXWave = 0
	String targetWaveName=""
	ControlInfo/W=$(s.win) WAr_SelectWAResultWave
	if (V_value == 1)		//Cursor A wave is the target
		WAr_MakeUndoInfo(gname, undoFolder, modWave1=$AwaveName)
		Duplicate/O ResultWave, $AwaveName/WAVE=targetWave
		targetWaveName = GetWavesDataFolder(targetWave, 2)
		if (hasAXWave)
			WAr_MakeUndoInfo(gname, undoFolder, modWave2=$AXwaveName)
			Duplicate/O ResultXWave, $AXWaveName
			needXWave = 1
		else
			SetScale/I x ResultXWave[0], ResultXWave[numpnts(ResultXWave)-1], $AWaveName
		endif
	endif
	if (V_value == 2)		//Cursor B wave is the target
		WAr_MakeUndoInfo(gname, undoFolder, modWave1=$BwaveName)
		Duplicate/O ResultWave, $BwaveName/WAVE=targetWave
		targetWaveName = GetWavesDataFolder(targetWave, 2)
		if (hasBXWave)
			WAr_MakeUndoInfo(gname, undoFolder, modWave2=$BXWaveName)
			Duplicate/O ResultXWave, $BXWaveName
			needXWave = 1
		else
			SetScale/I x ResultXWave[0], ResultXWave[numpnts(ResultXWave)-1], $BWaveName
		endif
	endif
	String ResultName="", ResultXName=""
	if (V_value == 3)		//New wave is the target
		if (strlen(GSWA_ResultName) == 0)
			ResultName="GSWA_NewWave"
		else
			ResultName=GSWA_ResultName
		endif
		targetWaveName = GetDataFolder(1)+PossiblyQuoteName(ResultName)
		Wave/Z targetWave = $targetWaveName
		if (WaveExists(targetWave))
			WAr_MakeUndoInfo(gname, undoFolder, modWave1=targetWave)
		else
			WAr_MakeUndoInfo(gname, undoFolder, NewWave1=targetWaveName)
		endif
		Duplicate/O ResultWave, $targetWaveName
		if (WAr_XValuesFromRadioSelection == 1 && hasAXWave)
			needXWave = 1
		elseif (WAr_XValuesFromRadioSelection == 2 && hasBXWave)
			needXWave = 1
		elseif (WAr_XValuesFromRadioSelection == 3 && (hasAXWave || hasBXWave))
			needXWave = 1
		endif
		if (needXWave)
			ResultXName = targetWaveName+"_X"
			Wave/Z targetXWave = $(ResultXName)
			if (WaveExists(targetXWave))
				WAr_MakeUndoInfo(gname, undoFolder, modWave2=targetXWave)
			else
				WAr_MakeUndoInfo(gname, undoFolder, NewWave2=ResultXName)
			endif
			Duplicate/O ResultXWave, $(ResultXName)
		else
			Variable first = ResultXWave[0]
			Variable last = ResultXWave[numpnts(ResultXWave)-1]
			SetScale/I x first, last, $(targetWaveName)
		endif
	endif
	
	CheckDisplayed/W=$gname $targetWaveName
	Variable NewTrace=0
	String NewTraceName = NextWArTraceName(gname)
	if (V_flag == 0)
		NewTrace=1
		WAr_MakeUndoInfo(gname, undoFolder, newTrace = NewTraceName)
		if ((cmpstr(targetWaveName, AwaveName) != 0) && (cmpstr(targetWaveName, BwaveName) != 0))
			if (!needXWave)
				AppendToGraph $ResultName/TN=$NewTraceName
				print BullitChar+"Wave Arithmetic:"
				print "\tAppendToGraph ",ResultName
			else
				AppendToGraph $ResultName/TN=$NewTraceName vs $ResultXName
				print BullitChar+"Wave Arithmetic:"
				print "\tAppendToGraph ",ResultName, "vs", ResultXName
			endif
		endif
	else
		String tname = TraceForWave(gname, targetWaveName, 0)
		Wave/Z tXWAve = XWaveRefFromTrace(gname, tname)
		if (needXWave)
			if (WaveExists(tXWave))
				if (!WaveRefsEqual($(ResultXName), tXWave))
					WAr_MakeUndoInfo(gname, undoFolder, modTrace = tname, modTraceAction = "REPLACEXWAVE="+GetWavesDataFolder(tXWave, 2))
					ReplaceWave/W=$gname/X trace=$tname, $(ResultXName)
				endif
			else
				WAr_MakeUndoInfo(gname, undoFolder, modTrace = tname, modTraceAction = "ADDXWAVE")
				ReplaceWave/W=$gname/X trace=$tname, $(ResultXName)
			endif
		else
			if (WaveExists(tXWave))
				WAr_MakeUndoInfo(gname, undoFolder, modTrace = tname, modTraceAction = "REMOVEXWAVE="+GetWavesDataFolder(tXWAve, 2))
				ReplaceWave/W=$gname/X trace=$tname, $""
			endif
		endif
	endif
	
	// Turn the new trace blue
	if (NewTrace)
		ModifyGraph rgb($NewTraceName)=(0,0,65535)
		print "\tModifyGraph rgb(",NewTraceName,")=(0,0,65535)"
	endif

DB(1000, "WaveArithWave")
End

Function/S TraceForWave(graphNameStr, WaveFullPath, UseFirstTrace)
	String graphNameStr
	String WaveFullPath
	Variable UseFirstTrace
	
	Variable i
	String TList=TraceNameList(graphNameStr, ";", 1)
	String aTrace
	String theResult

	// Find the trace corresponding to the new result wave
	theResult = ""
	i = 0
	do
		aTrace = StringFromList(i, TList)
		if (strlen(aTrace) == 0)
			break
		endif
		Wave w=TraceNameToWaveRef(graphNameStr, aTrace)
		if (CmpStr(GetWavesDataFolder(w,2), WaveFullPath) == 0)
			theResult = aTrace
			if (UseFirstTrace)
				break
			endif
		endif
		i += 1
	while (1)
	return theResult
end

Function SetupForWAResultWaveSelection(windowName, itemNumber)
	String windowName
	Variable itemNumber
	
	String gname = GetGraphName(windowName)
	NVAR WAr_XValuesFromRadioSelection=root:Packages:WM_WaveArithPanel:$(gname):WAr_XValuesFromRadioSelection
	switch (itemNumber)
		case 1:				// "Cursor A":
			CheckBox WAr_XValuesFromAWave, win=$(windowName), value = 1, disable=2
			CheckBox WAr_XValuesFromBWave, win=$(windowName), value = 0, disable=2
			CheckBox WAr_XValuesFromABWave, win=$(windowName), value = 0, disable=2
			GroupBox WAr_WAVEArithmeticXValuesGroup, win=$(windowName), disable=2
			WAr_XValuesFromRadioSelection = 1
			break;
		case 2:				// "Cursor B":
			CheckBox WAr_XValuesFromAWave, win=$(windowName), value = 0, disable=2
			CheckBox WAr_XValuesFromBWave, win=$(windowName), value = 1, disable=2
			CheckBox WAr_XValuesFromABWave, win=$(windowName), value = 0, disable=2
			GroupBox WAr_WAVEArithmeticXValuesGroup, win=$(windowName), disable=2
			WAr_XValuesFromRadioSelection = 2
			break;
		case 3:				// "New Wave":
			CheckBox WAr_XValuesFromAWave, win=$(windowName), value = 0, disable=0
			CheckBox WAr_XValuesFromBWave, win=$(windowName), value = 0, disable=0
			CheckBox WAr_XValuesFromABWave, win=$(windowName), value = 1, disable=0
			GroupBox WAr_WAVEArithmeticXValuesGroup, win=$(windowName), disable=0
			WAr_XValuesFromRadioSelection = 3
			break;
	endswitch
	
	ModifyControl WAr_SetWAResultWaveName, win=$(windowName), disable = (itemNumber == 3 ? 0 : 2)
end
	
Function SelectWAResultWave(s) : PopupMenuControl
	Struct WMPopupAction &s
	
	if (s.eventCode == 2)			// mouse up
		SetupForWAResultWaveSelection(s.win, s.popNum)
	endif
End

Function Normalize(s) : ButtonControl
	Struct WMButtonAction &s
	
	if (s.eventCode != 2)			// mouse up
		return 0
	endif
	
	String ctrlName = s.ctrlName
	String gname = GetGraphName(s.win)
		
	String CWaveName
	Variable WPos, NormConst
	
	SVAR BullitChar=root:Packages:WM_WaveArithPanel:$(gname):BullitChar
	
	DFREF undoDF = WAr_MakeNextUndoFolder(gname)
	String undomsg=""
	if (cmpstr(ctrlName[4], "A") == 0)
		Wave Cwave = CsrWaveRef(A)
		NormConst = vcsr(A)
	else
		Wave Cwave = CsrWaveRef(B)
		NormConst = vcsr(B)
	endif
	CwaveName = GetWavesDataFolder(Cwave,2)
	sprintf undomsg, "Normalize %s by %g", CwaveName, NormConst
	WAr_MakeUndoInfo(gname, undoDF, undoMessage=undoMsg, modWave1=Cwave)

	CWave /= NormConst
	print BullitChar+"Normalized Wave:"
	print "\t",CWaveName,"/=",NormConst
End

Function RemoveBackProc(s) : ButtonControl
	Struct WMButtonAction &s
	
	if (s.eventCode != 2)			// mouse up
		return 0
	endif
	
	String ctrlName = s.ctrlName
	String gname = GetGraphName(s.win)
	
	String CWaveName
	Variable WPos, CVal, pnumber, xvalue

	SVAR BullitChar=root:Packages:WM_WaveArithPanel:$(gname):BullitChar

	DFREF undoDF = WAr_MakeNextUndoFolder(gname)
	if (cmpstr(ctrlName[10], "A") == 0)
		Wave Cwave = CsrWaveRef(A)
		CVal=vcsr(A)
		pnumber=pcsr(A)
		xvalue=hcsr(A)
	else
		Wave Cwave = CsrWaveRef(B)
		CVal=vcsr(B)
		pnumber=pcsr(B)
		xvalue=hcsr(B)
	endif
	CwaveName = GetWavesDataFolder(Cwave, 2)
	String undomsg
	sprintf undomsg, "Remove Background: Subtract %g from %s", CVal, CwaveName
	WAr_MakeUndoInfo(gname, undoDF, undoMessage=undomsg, modWave1=Cwave)
	
	CWave -= CVal
	print BullitChar+"Subtract background value at point number ",pnumber, "; X value ",xvalue,":"
	print "\t",CWaveName,"-=", CVal
End

Function XShiftButProc(s) : ButtonControl
	Struct WMButtonAction &s
	
	if (s.eventCode != 2)		// mouse up
		return 0
	endif
	
	String ctrlName = s.ctrlName
	
	Variable AXpos, BXpos
	Variable deltX, OffX
	Variable i
	Variable XP
	
	String cmd
	String gname = GetGraphName(s.win)
	
	NVAR GXS_ShiftConst=root:Packages:WM_WaveArithPanel:$(gname):GXS_ShiftConst

	SVAR BullitChar=root:Packages:WM_WaveArithPanel:$(gname):BullitChar
	SVAR DeltaStr=root:Packages:WM_WaveArithPanel:$(gname):DeltaStr
	
DB(0, "XShiftButProc")
	
	WAVE/Z XWaveA = CsrXWaveRef(A)
	WAVE/Z WaveA = CsrWaveRef(A)
	WAVE/Z XWaveB = CsrXWaveRef(B)
	WAVE/Z WaveB = CsrWaveRef(B)
	
	if (WaveExists(WaveA))
		AXpos = hcsr(A)
	endif
	if (WaveExists(WaveB))
		BXpos = hcsr(B)
	endif
DB(10, "XShiftButProc")	

	DFREF undoDF = WAr_MakeNextUndoFolder(gname)
	
	String undoMessage
	StrSwitch(ctrlName)
		case "XShiftA2B":
			if (!WaveExists(WaveA))
				DoAlert 0, "Can't shift A to B: Cursor A is not on the graph"
				return -1
			endif
			if (!WaveExists(WaveB))
				DoAlert 0, "Can't shift A to B: Cursor B is not on the graph"
				return -1
			endif
			sprintf undoMessage, "Shift trace A to trace B: %s", StringByKey("TNAME", CsrInfo(A, gname), ":", ";")
			break;
		case "ShiftA":
			if (!WaveExists(WaveA))
				DoAlert 0, "Can't shift A: Cursor A is not on the graph"
				return -1
			endif
			sprintf undoMessage, "Shift trace A: %s", StringByKey("TNAME", CsrInfo(A, gname), ":", ";")
			break;
		case "XShiftB2A":
			if (!WaveExists(WaveA))
				DoAlert 0, "Can't shift B to A: Cursor A is not on the graph"
				return -1
			endif
			if (!WaveExists(WaveB))
				DoAlert 0, "Can't shift B to A: Cursor B is not on the graph"
				return -1
			endif
			sprintf undoMessage, "Shift trace B to trace A: %s", StringByKey("TNAME", CsrInfo(B, gname), ":", ";")
			break;
		case "ShiftB":
			if (!WaveExists(WaveB))
				DoAlert 0, "Can't shift B: Cursor B is not on the graph"
				return -1
			endif
			sprintf undoMessage, "Shift trace B: %s", StringByKey("TNAME", CsrInfo(B, gname), ":", ";")
			break;
		case "XShiftMid":
			if (!WaveExists(WaveA))
				DoAlert 0, "Can't shift to midpoint: Cursor A is not on the graph"
				return -1
			endif
			if (!WaveExists(WaveB))
				DoAlert 0, "Can't shift to midpoint: Cursor B is not on the graph"
				return -1
			endif
			sprintf undoMessage, "Shift trace A and trace B to midpoint: %s, %s", StringByKey("TNAME", CsrInfo(A, gname), ":", ";"), StringByKey("TNAME", CsrInfo(B, gname), ":", ";")
			break;
	endswitch
	WAr_MakeUndoInfo(gname, undoDF, undoMessage=undoMessage)
	
	if (WaveExists(XWaveA) && WaveExists(XWaveB) && WaveRefsEqual(XWaveA, XWaveB))
	// Both waves plotted versus same X wave, here we make a new x wave for cursor B so that they can be
	//    shifted independently.
		i = 0
		String newName
		do
			newName = NameOfWave(XWaveA) + num2str(i)
			if (!exists(newName))
				WAr_MakeUndoInfo(gname, undoDF, NewWave2=newName)
				cmd = "Duplicate "+GetWavesDataFolder(XWaveA, 2)+", "+newName
				print BullitChar+"X Shift: both waves plotted versus same X wave:"
				print "\t",cmd
				Execute cmd
				
				// now replace the B cursor trace X wave with the new wave
				String tname = StringByKey("TNAME", CsrInfo(B, gname), ":", ";")
				WAr_MakeUndoInfo(gname, undoDF, modTrace=tname, modTraceAction="REPLACEXWAVE")
				ReplaceWave/W=$gname/X trace=$tname, $newName
				print "\tReplaceWave/W="+gname+"/X trace="+tname+","+newName
				break
			endif
			i += 1
		while(1)
	endif
	
DB(20, "XShiftButProc")
	
	if (cmpstr(ctrlName,"XShiftA2B") == 0)
		print BullitChar+"Shift A to B"
		if (!WaveExists(XWaveA))
//			print "No X Wave"
			deltX = deltax(WaveA)
			OffX = leftx(WaveA)
			WAr_MakeUndoInfo(gname, undoDF, modWave1=WaveA)
			SetScale/P x OffX+BXpos-AXpos,deltX,WaveA
			print "\t",CsrWave(A),DeltaStr+"X =",BXpos-AXpos
			print "\tSetScale/P x",OffX+BXpos-AXpos,",",deltX,",",CsrWave(A)
		else
//			print "Has X Wave"
			WAr_MakeUndoInfo(gname, undoDF, modWave1=XWaveA)
			XWaveA += BXpos - AXpos
			print "\t",GetWavesDataFolder(XWaveA, 2),DeltaStr+"X =",BXpos - AXpos
			print "\t",GetWavesDataFolder(XWaveA, 2),"+=", BXpos - AXpos
		endif
		return 0
	endif
DB(30, "XShiftButProc")
	if (cmpstr(ctrlName,"XShiftB2A") == 0)
		print BullitChar+"Shift B to A"
		if (!WaveExists(XWaveB))
			//print "No X Wave"
			deltX = deltax(WaveB)
			OffX = leftx(WaveB)
			WAr_MakeUndoInfo(gname, undoDF, modWave1=WaveB)
			SetScale/P x OffX+AXpos-BXpos,deltX,WaveB
			print "\t", CsrWave(B), DeltaStr+"X =", AXpos-BXpos
			print "\tSetScale/P x",OffX+AXpos-BXpos,",",deltX,",",CsrWave(B)
		else
//			print "Has X Wave"
			WAr_MakeUndoInfo(gname, undoDF, modWave1=XWaveB)
			XWaveB += AXpos - BXpos
			print "\t",GetWavesDataFolder(XWaveB, 2),DeltaStr+"X =", AXpos-BXpos
			print "\t",GetWavesDataFolder(XWaveB, 2),"+=", AXpos-BXpos
		endif
		return 0
	endif
DB(40, "XShiftButProc")
	if (cmpstr(ctrlName,"XShiftMid") == 0)
		print BullitChar+"Shift A and B to Midpoint"
		if (!WaveExists(XWaveA))
//			print "No X Wave"
			deltX = deltax(WaveA)
			OffX = leftx(WaveA)
			WAr_MakeUndoInfo(gname, undoDF, modWave1=WaveA)
			SetScale/P x OffX+(BXpos-AXpos)/2,deltX,WaveA
			print "\t",CsrWave(A),DeltaStr+"X =", (BXpos-AXpos)/2
			print "\tSetScale/P x",OffX+(BXpos-AXpos)/2,",",deltX,",",CsrWave(A)
		else
//			print "Has X Wave"
			WAr_MakeUndoInfo(gname, undoDF, modWave1=XWaveA)
			XWaveA += (BXpos - AXpos)/2
			print "\t",GetWavesDataFolder(XWaveA, 2),DeltaStr+"X =",(BXpos - AXpos)/2
			print "\t",GetWavesDataFolder(XWaveA, 2),"+=",(BXpos - AXpos)/2
		endif
		if (!WaveExists(XWaveB))
//			print "No X Wave"
			deltX = deltax(WaveB)
			OffX = leftx(WaveB)
			WAr_MakeUndoInfo(gname, undoDF, modWave2=WaveB)
			SetScale/P x OffX+(AXpos-BXpos)/2,deltX,WaveB
			print "\t",CsrWave(B),DeltaStr+"X =", (AXpos-BXpos)/2
			print "\tSetScale/P x",OffX+(AXpos-BXpos)/2,",",deltX,",",CsrWave(B)
		else
//			print "Has X Wave"
			WAr_MakeUndoInfo(gname, undoDF, modWave2=XWaveB)
			XWaveB += (AXpos - BXpos)/2
			print "\t",GetWavesDataFolder(XWaveB, 2), DeltaStr+"X =", (AXpos-BXpos)/2
			print "\t",GetWavesDataFolder(XWaveB, 2),"+=",(AXpos - BXpos)/2
		endif
		return 0
	endif
	if (cmpstr(ctrlName,"ShiftA") == 0)
		print BullitChar+"Shift A"
		if (!WaveExists(XWaveA))
//			print "No X Wave"
			deltX = deltax(WaveA)
			OffX = leftx(WaveA)
			WAr_MakeUndoInfo(gname, undoDF, modWave1=WaveA)
			SetScale/P x OffX+GXS_ShiftConst,deltX,WaveA
			print "\t",CsrWave(A),DeltaStr+"X =", GXS_ShiftConst
			print "\tSetScale/P x",OffX+GXS_ShiftConst,",",deltX,",",CsrWave(A)
		else
//			print "Has X Wave"
			WAr_MakeUndoInfo(gname, undoDF, modWave1=XWaveA)
			XWaveA += GXS_ShiftConst
			print "\t",GetWavesDataFolder(XWaveA, 2),DeltaStr+"X =", GXS_ShiftConst
			print "\t",GetWavesDataFolder(XWaveA, 2),"+=",GXS_ShiftConst
		endif
		return 0
	endif
DB(50, "XShiftButProc")
	if (cmpstr(ctrlName,"ShiftB") == 0)
		print BullitChar+"Shift B"
		if (!WaveExists(XWaveB))
//			print "No X Wave"
			deltX = deltax(WaveB)
			OffX = leftx(WaveB)
			WAr_MakeUndoInfo(gname, undoDF, modWave1=WaveB)
			SetScale/P x OffX+GXS_ShiftConst,deltX,WaveB
			print "\t",CsrWave(B),DeltaStr+"X =", GXS_ShiftConst
			print "\tSetScale/P x",OffX+GXS_ShiftConst,",",deltX,",",CsrWave(B)
		else
//			print "Has X Wave"
			WAr_MakeUndoInfo(gname, undoDF, modWave1=XWaveB)
			XWaveB += GXS_ShiftConst
			print "\t",GetWavesDataFolder(XWaveB, 2),DeltaStr+"X =", GXS_ShiftConst
			print "\t",GetWavesDataFolder(XWaveB, 2),"+=",GXS_ShiftConst
		endif
		return 0
	endif
DB(1000, "XShiftButProc")
End

Function GoToGraphControl(ctrlName) : ButtonControl
	String ctrlName

End

Function fWaveArithmeticPanel(graphName)
	String graphName
	
	if (WinType(graphName) != 1)
		return -1
	endif
	
	DoWindow/F $graphName
	
	String panelName = graphName+"#WaveArithmeticPanel"
	
	if (WinType(panelName) != 0)
		return 0
	endif
	
	NewPanel/HOST=$graphName/EXT=0/W=(0,375,218,375) as "Wave Arithmetic"
	RenameWindow $(graphName+"#"+S_name), WaveArithmeticPanel
	SetWindow $panelName UserData(graphName)=graphName
	
	Button WAr_UndoButton,pos={15,330},size={65,20},proc=WAr_UndoRedo,title="Undo"
	Button WAr_RedoButton,pos={135,330},size={65,20},proc=WAr_UndoRedo,title="Redo"
	Button WAr_HelpButton,pos={75,351},size={65,20},proc=WaveArithHelpButtonProc,title="Help"


	PopupMenu WAr_OperationMenu,pos={23,7},size={170,20},bodyWidth=170,proc=WAr_OperationMenuProc
	PopupMenu WAr_OperationMenu,fSize=12,mode=1,value= #"\"Normalize/Background;Wave Arithmetic;Constant Arithmetic;X Shift;Cursors;\""
	GroupBox WAr_ControlGroupBox,pos={6,30},size={207,297}
	
	NewPanel/W=(9,33,209,325)/HOST=# /HIDE=1 
	ModifyPanel frameStyle=0
	GroupBox WAr_NormalizeGroup,pos={16,27},size={172,57},title="Normalize",fSize=12
	Button NormA,pos={41,56},size={40,20},proc=Normalize,title="A"
	Button NormB,pos={121,56},size={40,20},proc=Normalize,title="B"
	Button removeBackA,pos={39,121},size={40,20},proc=RemoveBackProc,title="A"
	Button removeBackB,pos={123,121},size={40,20},proc=RemoveBackProc,title="B"
	GroupBox WAr_BackgroundGroup,pos={15,91},size={172,57},title="Subtract Background"
	GroupBox WAr_BackgroundGroup,fSize=12
	RenameWindow #,WAr_BackgroundNormalizeGroup
	SetActiveSubwindow ##
	
	NewPanel/W=(9,33,209,325)/HOST=# /HIDE=1 
	ModifyPanel frameStyle=0
	GroupBox WAr_WAVEArithmeticGroup,pos={14,24},size={173,93},title="Wave Arithmetic"
	GroupBox WAr_WAVEArithmeticGroup,fSize=12
	Button AplusB,pos={27,52},size={65,20},proc=WaveArithWave,title="A + B"
	Button AminusB,pos={27,85},size={65,20},proc=WaveArithWave,title="A - B"
	Button AdivB,pos={107,85},size={65,20},proc=WaveArithWave,title="A / B"
	Button AtimesB,pos={107,52},size={65,20},proc=WaveArithWave,title="A * B"

	NVAR WAr_XValuesFromRadioSelection=root:Packages:WM_WaveArithPanel:$(graphName):WAr_XValuesFromRadioSelection
	GroupBox WAr_WAVEArithmeticXValuesGroup,pos={14,132},size={173,93},title="X Values From"
	GroupBox WAr_WAVEArithmeticXValuesGroup,fSize=12
	CheckBox WAr_XValuesFromAWave,pos={36,159},size={96,16},proc=WAr_XValuesFromAWaveRadioProc,title="From A Wave"
	CheckBox WAr_XValuesFromAWave,fSize=12,value=WAr_XValuesFromRadioSelection==1,mode=1
	CheckBox WAr_XValuesFromBWave,pos={36,179},size={95,16},proc=WAr_XValuesFromAWaveRadioProc,title="From B Wave"
	CheckBox WAr_XValuesFromBWave,fSize=12,value=WAr_XValuesFromRadioSelection==2,mode=1
	CheckBox WAr_XValuesFromABWave,pos={36,199},size={132,16},proc=WAr_XValuesFromAWaveRadioProc,title="From A and B Wave"
	CheckBox WAr_XValuesFromABWave,fSize=12,value=WAr_XValuesFromRadioSelection==3,mode=1

	TitleBox WAr_WAResultsWaveTitle,pos={11,240},size={81,16},title="Results Wave:"
	TitleBox WAr_WAResultsWaveTitle,fSize=12,frame=0
	PopupMenu WAr_SelectWAResultWave,pos={100,240},size={91,20},proc=SelectWAResultWave
	PopupMenu WAr_SelectWAResultWave,mode=3,value= #"\"Cursor A;Cursor B;New Wave;\""
	SetVariable WAr_SetWAResultWaveName,pos={12,264},size={179,16},title=" ",fSize=10
	SVAR GSWA_ResultName = root:Packages:WM_WaveArithPanel:$(graphName):GSWA_ResultName
	SetVariable WAr_SetWAResultWaveName,value= GSWA_ResultName
	RenameWindow #,WAr_WaveArithmeticGroup
	SetActiveSubwindow ##
	
	NewPanel/W=(9,33,209,325)/HOST=# 
	ModifyPanel frameStyle=0
	SetVariable setvar0,pos={60,168},size={85,16},title=" ",fSize=10
	NVAR GXS_ShiftConst = root:Packages:WM_WaveArithPanel:$(graphName):GXS_ShiftConst
	SetVariable setvar0,limits={-inf,inf,0},value= GXS_ShiftConst
	Button XShiftA2B,pos={55,37},size={95,20},proc=XShiftButProc,title="Csr A -> B"
	Button XShiftB2A,pos={55,70},size={95,20},proc=XShiftButProc,title="Csr B -> A"
	Button XShiftMid,pos={55,103},size={95,20},proc=XShiftButProc,title="Midpoint"
	Button ShiftA,pos={50,193},size={40,20},proc=XShiftButProc,title="A"
	Button ShiftB,pos={117,193},size={40,20},proc=XShiftButProc,title="B"
	GroupBox WAr_ConstantShiftGroup,pos={32,138},size={140,82},title="Constant Shift"
	GroupBox WAr_ConstantShiftGroup,fSize=12
	GroupBox WAr_ShiftAtoBGroup,pos={33,13},size={138,118},title="X Shift",fSize=12
	RenameWindow #,WAr_XShiftGroup
	SetActiveSubwindow ##
	
	NewPanel/W=(9,33,209,325)/HOST=# /HIDE=1 
	ModifyPanel frameStyle=0
	SetVariable SetArithConst,pos={30,46},size={114,16},title="C = ",fSize=10
	NVAR GArithConst = root:Packages:WM_WaveArithPanel:$(graphName):GArithConst
	SetVariable SetArithConst,value= GArithConst
	Button AplusC,pos={29,80},size={65,20},proc=WaveArithConst,title="A + C"
	Button BplusC,pos={109,81},size={65,20},proc=WaveArithConst,title="B + C"
	Button BminusC,pos={109,114},size={65,20},proc=WaveArithConst,title="B - C"
	Button BtimesC,pos={109,147},size={65,20},proc=WaveArithConst,title="B * C"
	Button BdivC,pos={108,181},size={65,20},proc=WaveArithConst,title="B / C"
	Button BdivC,fSize=13
	Button AminusC,pos={28,113},size={65,20},proc=WaveArithConst,title="A - C"
	Button AtimesC,pos={28,146},size={65,20},proc=WaveArithConst,title="A * C"
	Button AdivC,pos={28,180},size={65,20},proc=WaveArithConst,title="A / C"
	GroupBox group0,pos={19,18},size={167,191},title="Constant Arithmetic",fSize=12
	TitleBox WAr_CAResultsWaveTitle,pos={11,240},size={81,16},title="Results Wave:"
	TitleBox WAr_CAResultsWaveTitle,fSize=12,frame=0
	PopupMenu WAr_SelectCAResultWave,pos={100,240},size={91,20},proc=SelectCAResultWave
	PopupMenu WAr_SelectCAResultWave,mode=2,value= #"\"Cursor;New Wave;\""
	SetVariable WAr_SetCAResultWaveName,pos={12,264},size={179,16},title=" ",fSize=10
	SVAR  GNewWaveConst = root:Packages:WM_WaveArithPanel:$(graphName):GNewWaveConst
	SetVariable WAr_SetCAResultWaveName,value= GNewWaveConst
	RenameWindow #,WAr_ConstantArithmeticGroup
	SetActiveSubwindow ##
	
	NewPanel/W=(9,33,209,325)/HOST=# /HIDE=1 
	ModifyPanel frameStyle=0
	TitleBox WAr_PlaceACursor,pos={7,12},size={181,16},title="Put A (round) Cursor On Trace:"
	TitleBox WAr_PlaceACursor,fSize=12,frame=0
	PopupMenu WAr_PlaceACursorMenu,pos={24,30},size={160,20},bodyWidth=160
	String menuValue = "TraceNameList(\""+graphName+"\", \";\",5)"
	PopupMenu WAr_PlaceACursorMenu,mode=1,value= #menuValue, proc=WAr_PlaceCursorMenuProc
	PopupMenu WAr_PlaceACursorAtMenu,pos={23,56},size={141,20},bodyWidth=120,title="At:"
	PopupMenu WAr_PlaceACursorAtMenu,fSize=12, proc=WAr_PlaceCursorAtMenuProc
	PopupMenu WAr_PlaceACursorAtMenu,mode=3,value= #"\"Start;End;Maximum Point;Minimum Point;\""
	TitleBox WAr_PlaceBCursor,pos={7,158},size={149,16},title="Put B (square) Cursor On Trace:"
	TitleBox WAr_PlaceBCursor,fSize=12,frame=0
	PopupMenu WAr_PlaceBCursorMenu,pos={24,176},size={160,20},bodyWidth=160
	PopupMenu WAr_PlaceBCursorMenu,mode=2,value= #menuValue,proc=WAr_PlaceCursorMenuProc
	PopupMenu WAr_PlaceBCursorAtMenu,pos={23,202},size={141,20},bodyWidth=120,title="At:"
	PopupMenu WAr_PlaceBCursorAtMenu,fSize=12,proc=WAr_PlaceCursorAtMenuProc
	PopupMenu WAr_PlaceBCursorAtMenu,mode=3,value= #"\"Start;End;Maximum Point;Minimum Point;\""
	SetVariable WAr_CursorAPoint,pos={42,86},size={105,15},bodyWidth=76,title="Point:",proc=WAr_CursorSetPoint,live=1
	SetVariable WAr_CursorAXValue,pos={59,104},size={72,15},bodyWidth=60,title="X:"
	SetVariable WAr_CursorAXValue,limits={-inf,inf,0},value= _NUM:0,noedit= 1
	SetVariable WAr_CursorAYValue,pos={59,122},size={72,15},bodyWidth=60,title="Y:"
	SetVariable WAr_CursorAYValue,limits={-inf,inf,0},value= _NUM:0,noedit= 1
	SetVariable WAr_CursorBPoint,pos={42,232},size={105,15},bodyWidth=76,title="Point:",proc=WAr_CursorSetPoint,live=1
	SetVariable WAr_CursorBXValue,pos={59,250},size={72,15},bodyWidth=60,title="X:"
	SetVariable WAr_CursorBXValue,limits={-inf,inf,0},value= _NUM:0,noedit= 1
	SetVariable WAr_CursorBYValue,pos={59,268},size={72,15},bodyWidth=60,title="Y:"
	SetVariable WAr_CursorBYValue,limits={-inf,inf,0},value= _NUM:0,noedit= 1
	RenameWindow #,WAr_CursorsGroup
	SetActiveSubwindow ##	
	
	SetActiveSubwindow ##
	
	SetWindow $graphname, hook(WaveArithmeticPanelHook)=WAr_graphWinHook
	SetWindow $panelName, hook(WaveArithmeticPanelHook)=WAr_panelWinHook
	
	String pName
	pName = graphname+"#WaveArithmeticPanel#WAr_WaveArithmeticGroup"
	SetupForWAResultWaveSelection(pName, 3)

	pName = graphname+"#WaveArithmeticPanel#WAr_CursorsGroup"
	String AtraceName = StringByKey("TNAME", CsrInfo(A, graphname), ":", ";")
	String BtraceName = StringByKey("TNAME", CsrInfo(B, graphname), ":", ";")
	if ( (strlen(AtraceName) == 0) && (strlen(BtraceName) == 0) )
		DoAlert 0, "You need to place the graph cursors on the graph before using the Wave Arithmetic panel."
		PopupMenu WAr_OperationMenu,win=$panelName,mode=5
		WAr_SelectPanel(panelName, "Cursors")
	elseif (strlen(AtraceName) == 0)
		DoAlert 0, "You need to place the A (round) graph cursor on the graph before using the Wave Arithmetic panel."
		PopupMenu WAr_OperationMenu,win=$panelName,mode=5
		WAr_SelectPanel(panelName, "Cursors")
	elseif (strlen(BtraceName) == 0)
		DoAlert 0, "You need to place the B (square) graph cursor on the graph before using the Wave Arithmetic panel."
		PopupMenu WAr_OperationMenu,win=$panelName,mode=5
		WAr_SelectPanel(panelName, "Cursors")
	else
		WAr_PlaceCursor(graphname, pName, AtraceName, "A", "Dont Move")
		WAr_PlaceCursor(graphname, pName, BtraceName, "B", "Dont Move")
		PopupMenu WAr_OperationMenu,win=$panelName,mode=1
		WAr_SelectPanel(panelName, "Normalize/Background")
	endif
end

Function WAr_panelWinHook(s)
	Struct WMWinHookStruct &s

	strswitch(s.eventName)
		case "kill":
		case "subwindowKill":
			String gname = GetGraphName(s.winName)
			SetWindow $gname, hook(WaveArithmeticPanelHook)=$""
			break;
	endswitch
end

Function WAr_graphWinHook(s)
	Struct WMWinHookStruct &s
	
	strswitch(s.eventName)
		case "cursormoved":
			String panelName = s.winName+"#WaveArithmeticPanel#WAr_CursorsGroup"
			ControlInfo/W=$panelName $("WAr_Place"+s.cursorName+"CursorMenu")
			if (CmpStr(S_value, s.traceName) != 0)
				string tlist = TraceNameList(s.winName, ";", 5)
				Variable menuItem = whichListItem(s.traceName, tlist)+1
				PopupMenu $("WAr_Place"+s.cursorName+"CursorMenu"),win=$panelName, mode=menuItem
			endif
			WAr_PlaceCursor(s.winName, panelName, s.traceName, s.cursorName, "Dont Move")
			break;
	endswitch
end

Function WAr_SelectPanel(windowName, menuItemStr)
	String windowName, menuItemStr
	
	SetWindow $(windowName+"#WAr_BackgroundNormalizeGroup") hide = CmpStr(menuItemStr, "Normalize/Background") != 0
	SetWindow $(windowName+"#WAr_ConstantArithmeticGroup") hide = CmpStr(menuItemStr, "Constant Arithmetic") != 0
	SetWindow $(windowName+"#WAr_WaveArithmeticGroup") hide = CmpStr(menuItemStr, "Wave Arithmetic") != 0
	SetWindow $(windowName+"#WAr_XShiftGroup") hide = CmpStr(menuItemStr, "X Shift") != 0
	SetWindow $(windowName+"#WAr_CursorsGroup") hide = CmpStr(menuItemStr, "Cursors") != 0
end

Function WAr_OperationMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	if (pa.eventCode == 2)			// mouse up
		WAr_SelectPanel(pa.win, pa.popStr)
	endif
	return 0
End

Function DB(sequenceNumber, ProcName)
	Variable sequenceNumber
	String ProcName
	
	if (GetRTError(0))
		print "Error at sequence number"+num2istr(sequenceNumber)+" in "+ProcName+":"
		print GetRTErrMessage()
	endif
end

Function WaveArithHelpButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DisplayHelpTopic("Wave Arithmetic Panel")
End


Function WAr_XValuesFromAWaveRadioProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	String gname = GetGraphName(cba.win)
	NVAR WAr_XValuesFromRadioSelection=root:Packages:WM_WaveArithPanel:$(gname):WAr_XValuesFromRadioSelection

	switch( cba.eventCode )
		case 2: // mouse up
			strswitch (cba.ctrlname)
				case "WAr_XValuesFromAWave":
					WAr_XValuesFromRadioSelection = 1
					break;
				case "WAr_XValuesFromBWave":
					WAr_XValuesFromRadioSelection = 2
					break;
				case "WAr_XValuesFromABWave":
					WAr_XValuesFromRadioSelection = 3
					break;
			endswitch
			CheckBox WAr_XValuesFromAWave,win=$(cba.win), value = WAr_XValuesFromRadioSelection==1
			CheckBox WAr_XValuesFromBWave,win=$(cba.win),value = WAr_XValuesFromRadioSelection==2
			CheckBox WAr_XValuesFromABWave,win=$(cba.win), value = WAr_XValuesFromRadioSelection==3
			break
	endswitch

	return 0
End

Function WAr_PlaceCursorMenuProc(s) : PopupMenuControl
	STRUCT WMPopupAction &s

	if (s.eventCode == 2)			// mouse up
		String gname = GetGraphName(s.win)
		String cursorName
		strswitch(s.ctrlName)
			case "WAr_PlaceACursorMenu":
				cursorName = "A"
				break;
			case "WAr_PlaceBCursorMenu":
				cursorName = "B"
				break;
		endswitch
		ControlInfo/W=$(s.win) $("WAr_Place"+cursorName+"CursorAtMenu")
		
		WAr_PlaceCursor(gname, s.win, s.popStr, cursorName, S_value)
	endif
	
	return 0
end

Function WAr_PlaceCursorAtMenuProc(s) : PopupMenuControl
	STRUCT WMPopupAction &s

	if (s.eventCode == 2)			// mouse up
		String gname = GetGraphName(s.win)
		String cursorName
		strswitch(s.ctrlName)
			case "WAr_PlaceACursorAtMenu":
				cursorName = "A"
				break;
			case "WAr_PlaceBCursorAtMenu":
				cursorName = "B"
				break;
		endswitch
		
		ControlInfo/W=$(s.win) $("WAr_Place"+cursorName+"CursorMenu")
		
		WAr_PlaceCursor(gname, s.win, S_value, cursorName, s.popStr)
	endif
	
	return 0
end

Function WAr_PlaceCursor(gname, panelName, traceName, cursorName, placementStr [, placementPoint])
	String gname, panelName, traceName, cursorName, placementStr
	Variable placementPoint
	
	if (strlen(tracename) == 0)
		return -1
	endif
	Wave/Z yw = TraceNameToWaveRef(gname, tracename)
	if (!WaveExists(yw))
		return -1
	endif
	
	Wave/Z xw = XWaveRefFromTrace(gname, tracename)
	Variable point = 0
	Variable xvalue, yvalue
	Variable moveCursor = 1
	strswitch(placementStr)
		case "Start":
			point = 0
			break;
		case "End":
			point = numpnts(yw)-1
			break;
		case "Maximum Point":
			WaveStats/Q yw
//			point = x2pnt(yw, V_maxLoc)
			point = V_maxRowLoc
			break;
		case "Minimum Point":
			WaveStats/Q yw
//			point = x2pnt(yw, V_minLoc)
			point = V_minRowLoc
			break;
		default:
			if (ParamIsDefault(placementPoint))
//				if (strlen(CsrInfo(A, gname)) == 0)
				point = pcsr($cursorName)
				moveCursor = 0
			else
				point = placementPoint
			endif
			break;
	endswitch
	
	if (WaveExists(xw))
		xvalue = xw[point]
	else
		xvalue = pnt2x(yw, point)
	endif
	yvalue = yw[point]
	
	if (moveCursor)
		Cursor/W=$gname/P/A=1 $cursorName, $(tracename), point
	endif
	SetVariable $("WAr_Cursor"+cursorName+"Point"), win=$(panelName),value=_NUM:(point),limits={0,numpnts(yw)-1, 1}
	SetVariable $("WAr_Cursor"+cursorName+"XValue"), win=$(panelName),value=_NUM:(xvalue)
	SetVariable $("WAr_Cursor"+cursorName+"YValue"), win=$(panelName),value=_NUM:(yvalue)
end


Function WAr_CursorSetPoint(s) : SetVariableControl
	STRUCT WMSetVariableAction &s

	switch( s.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			String gname = GetGraphName(s.win)
			String cursorName
			strswitch(s.ctrlName)
				case "WAr_CursorAPoint":
					cursorName = "A"
					break;
				case "WAr_CursorBPoint":
					cursorName = "B"
					break;
			endswitch
			
			ControlInfo/W=$(s.win) $("WAr_Place"+cursorName+"CursorMenu")
			
			WAr_PlaceCursor(gname, s.win, S_value, cursorName, "Dont Move", placementPoint=s.dval)
			break
	endswitch

	return 0
End
