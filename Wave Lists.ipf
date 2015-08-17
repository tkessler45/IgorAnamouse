#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion=5		// built-in StringFromList, etc.		
#pragma version=6.2		// shipped with Igor 6.2

//AUGMENTS NEUROMATIC CODE

//****************************************
//  Functions to augment the basic built-in wave listing functions in Igor
//****************************************

//WaveListQualified(WinName, type, NRows, NCols, NDims, nPnts, wType, PrefixStr, SuffixStr, ExcludeList, ReturnFullPath)
//
//	returns a semicolon-separated list of waves that meet selected criteria. The function is based on the
//	built-in function WaveRefIndexed, so it has that function's advantages, but lacks the match string
// 	available with the WaveList function. This lack is partially remedied by providing strings to match
//	the beginning or ending of wave names.
//
//	Parameters:
//		WinName			Just like the WinName parameter to the builtin function WaveRefIndexed.
//		type				Just like the type parameter to the builtin function WaveRefIndexed.
//		NRows				List only waves having NRows rows. If NRows is zero, this parameter is ignored.
//		NCols				List only waves having NCols columns. If NCols is zero, this parameter is ignored.
//		NDims				List only waves having NDims dimensions. If NDims is zero, this parameter is ignored.
//		nPnts				List only waves having nPnts points, regardless of number of dimensions. 
//								If nPnts is zero, this parameter is ignored.
//		wType				List only waves with number type matching a bit in wType (see WaveType for details).
//									Type			Bit #		Decimal Value
//									complex			0			1
//									32 bit float		1			2
//									64 bit float		2			4
//									8 bit integer		3			8
//									16 bit integer		4			16
//									32 bit integer		5			32
//									unsigned			6			64
//								For instance, if wType is 6, match waves that are either 32-bit or 64-bit float 
//								EXCEPT: if wtype is zero, match only text waves.
//								ALSO: if wtype is -1, ignore this parameter.			
//		PrefixStr			Match waves with names beginning with PrefixStr. If PrefixStr is null (""), this parameter is ignored.
//		SuffixStr			Match waves with names ending with SuffixStr. If SuffixStr is null (""), this parameter is ignored.
//		ExcludeList		Semicolon-separated list of waves to exclude from the list. Must have full datafolder
//								paths, or they must be in the current datafolder.
//		ReturnFullPath	Set to 1 to get a list of waves with full datafolder paths. Set to 0 to get just the wave names in the list.
//								TIP: You can set ReturnFullPath to zero to get a list suitable for a menu, and then set
//									ReturnFullPath to one, and use the menu selection to pick out the correct item from
//									the full path list.

Function/S WaveListQualified(WinName, type, NRows, NCols, NDims, nPnts, wType, PrefixStr, SuffixStr, ExcludeList, ReturnFullPath)
	String WinName
	Variable type
	Variable NRows
	Variable NCols
	Variable NDims
	Variable nPnts
	Variable wType
	String PrefixStr
	String SuffixStr
	String ExcludeList
	Variable ReturnFullPath
	
	String result="",resultwithpaths=""
	String oneWave=""
	String ExList
	Variable DoExclude=0
	Variable theType
	
	Variable PrefixLen=strlen(PrefixStr)
	Variable SuffixLen=strlen(SuffixStr)
	
	// Make the exclude list match the requirements of WaveNameIndexedExcluding()
	if (strlen(ExcludeList) > 0)
		ExcludeList = RebuildExcludeList(ExcludeList)
		DoExclude=1
	endif
	
	Variable i=0
	do
		if (DoExclude)
			// This makes sure that we list a wave only once even if it appears in a graph or table more than once
			ExList=ExcludeList+";"+resultwithpaths
			oneWave = WaveNameIndexedExcluding(WinName, i, type, ExList, ReturnFullPath)
			if (strlen(oneWave) == 0)	// null string- no more waves
				break
			endif
			WAVE/Z w=$oneWave
		else		// This is faster- use it if there isn't any exclude list
			WAVE/Z w = WaveRefIndexed(WinName, i, type)
			if (!WaveExists(w))			// null wave- no more waves
				break
			endif
		endif
		// w will be null for the string "***EXCLUDE***", which fails the WaveExists test
		if (WaveExists(w))
			do		// a "loop" to break out of
				if ((NRows != 0) && (NRows != DimSize(w, 0)) )
					break
				endif
				if (NCols != 0)
					if ((NCols == 1) && (WaveDims(w) != 1))
						break
					endif
					if ((NCols != 1) && (NCols != DimSize(w, 1)) )
						break
					endif
				endif
				if ((NDims != 0) && (NDims != WaveDims(w)) )
					break
				endif
				if ((nPnts != 0) && (nPnts != numpnts(w)) )
					break
				endif
				theType = WaveType(w)
				if ((wType > 0) && ((wType&theType) != theType) )
					break
				endif
				if ((wType == 0) && (theType != 0))
					break
				endif
				if ( (PrefixLen > 0) && (CmpStr(PrefixStr, (NameOfWave(w))[0,PrefixLen-1]) != 0) )
					break
				endif
				if (SuffixLen > 0)
					String TheName=NameOfWave(w)
					Variable WaveNameLen=strlen(TheName)
					if (CmpStr(SuffixStr, (NameOfWave(w))[WaveNameLen-SuffixLen,WaveNameLen-1]) != 0)
						break
					endif
				endif
				// w passed all the tests- include it in the list
				result += NameOfWave(w)+";"
				resultwithpaths += GetWavesDataFolder(w,2)+";"
			while (0)
		endif
		i += 1
	while (1)
	
	if (ReturnFullPath)
		return resultwithpaths
	else
		return result
	endif
end

// WaveListMatchWave(WinName, type,TemplateWave, MatchWaveType, AllowedTypes, ExcludeList, ReturnFullPaths)
//
//	Returns a list of waves that match the template wave. A match means that the number of points and number
//	of dimensions are the same. You can further require that the number type match or that the list be limited
//	to waves of only certain number types.
//
//	Parameters:
//		WinName			Just like the WinName parameter to the builtin function WaveRefIndexed.
//		type				Just like the type parameter to the builtin function WaveRefIndexed.
//		TemplateWave		The wave to match.
//		MatchWaveType	Set to one if you want the listed waves to match the template wave's number type.
//		AllowedTypes		List only waves with number type matching a bit in wType (see WaveType for details).
//									Type			Bit #		Decimal Value
//									complex			0			1
//									32 bit float		1			2
//									64 bit float		2			4
//									8 bit integer		3			8
//									16 bit integer		4			16
//									32 bit integer		5			32
//									unsigned			6			64
//								For instance, if wType is 6, match waves that are either 32-bit or 64-bit float 
//								EXCEPT: if wtype is zero, match only text waves.
//								ALSO: if wtype is -1, ignore this parameter.
//								NOTE: if MatchWaveType is 1, this parameter is ignored.
//		ExcludeList		Semicolon-separated list of waves to exclude from the list. Must have full datafolder
//								paths, or they must be in the current datafolder.
//		ReturnFullPath	Set to 1 to get a list of waves with full datafolder paths. Set to 0 to get just the wave names in the list.
//								TIP: You can set ReturnFullPath to zero to get a list suitable for a menu, and then set
//									ReturnFullPath to one, and use the menu selection to pick out the correct item from
//									the full path list.

Function/S WaveListMatchWave(WinName, type,TemplateWave, MatchWaveType, AllowedTypes, ExcludeList, ReturnFullPaths)
	String WinName
	Variable type
	Wave/Z TemplateWave
	Variable MatchWaveType
	Variable AllowedTypes
	String ExcludeList
	Variable ReturnFullPaths
	
	if (!WaveExists(TemplateWave))
		return ""
	endif
	Variable nPnts, nDims, wType
	nPnts = numpnts(TemplateWave)
	nDims = WaveDims(TemplateWave)
	if (MatchWaveType)
		wType = WaveType(TemplateWave)
	else
		wType = AllowedTypes
	endif
	return WaveListQualified(WinName, type,0,0,nDims, nPnts, wType, "", "", ExcludeList, ReturnFullPaths)
end

// WaveNameIndexedExcluding(WinName, i, type, ExcludeList, ReturnFullPath)
//
// returns a string containing the i'th wave if it is not in ExcludeList. If the i'th wave is in the list,
//   WaveNameIndexedExcluding will return the string "***EXCLUDE***". The calling program should
//   check for this return value before using the string. A nice way to do that is with WaveExists() since
//	"***EXCLUDE***" isn't (or at least shouldn't but could be) the name of any wave.
//
//	The parameters WinName, i, and type are the same as for the built-in function WaveRefIndexed.
//		ExcludeList- 	semicolon-separated list of waves that should should result in the EXCLUDE return value.
//						The wavenames must include full datafolder paths, and have case the same as
//						Igor's stored names. Use RebuildExcludeList function to make sure your list
//						meets these requirements.
//		FullPath- returned wave name includes full datafolder path to the wave.

Function/S WaveNameIndexedExcluding(WinName, i, type, ExcludeList, ReturnFullPath)
	String WinName
	Variable  i, type
	String ExcludeList
	Variable ReturnFullPath
	
	String testname
	
	// Get the i'th wave
	WAVE/Z w=WaveRefIndexed(WinName, i, type)
	if (!WaveExists(w))
		return ""
	endif

	// Get the full path with wave name for the i'th wave
	testname=GetWavesDataFolder(w,2)
	// And find out if it is in the exclude list
	if (FindListItem(testname, ExcludeList) >= 0)
		return "***EXCLUDE***"
	else
		if (ReturnFullPath)
			return testname
		else
			return NameOfWave(w)	// NameOfWave doesn't include the datafolder path
		endif
	endif
end

// WaveNameIndexedExcluding uses FindItemInList, which uses strsearch. Since strsearch is case-sensitive,
// the wave names in ExcludeList must match the case you used when the waves were created.
// This function will re-build the input list to make it match the strings that WaveRefIndexed, etc., will return.
// Also makes the list have nothing but full datafolder paths, which is also required by WaveNameIndexedExcluding.

Function/S RebuildExcludeList(InputListOfWaves)
	String InputListOfWaves
	
	String aWave
	String returnList=""
	
	Variable i=0
	do
		aWave = StringFromList(i,InputListOfWaves)
		if (strlen(aWave) == 0)
			break
		endif
		WAVE/Z w=$aWave
		if (WaveExists(w))
			returnList += GetWavesDataFolder($aWave, 2)+";"
		endif
		i +=1
	while (1)
	
	return returnList
end


// The following is included for backward compatibility with previous versions of Wave Lists.

// NOTE:
//	As of Igor Pro 3.0, this function is no longer needed and should not be used in new programming.
//	It will not work if the graph contains waves from data folders other than the current data folder.
//	Igor Pro 3.0 added the built-in TraceNameList function. Use TraceNameList to get a list of
//	the traces in the graph. Then use TraceNameToWaveRef to get a wave reference for a particular
//	trace. If necessary, use XWaveRefFromTrace to get the wave supplying the x in an XY pair.

// GraphWaveList(graphNameStr, matchStr, xOnly, yOnly, separatorStr)
//	Returns a string containing a list of waves in the specified graph which fit
//	certain criteria. Use this when you want only x waves or only y waves.
//	If you want all waves, you can use the built-in WaveList function instead.
//		graphNameStr can be the name of a graph or "" for the top graph
//		matchStr is "*" to match any wave or some pattern to match only selected waves
//		pass 1 for xOnly if you want only waves furnishing the x part of an XY pair
//		pass 1 for yOnly if you want only waves furnishing the y part of an XY pair
//		separatorStr is normally ";" or ","
Function/S GraphWaveList(graphNameStr, matchStr, xOnly, yOnly, separatorStr)
	String graphNameStr
	String matchStr
	Variable xOnly, yOnly
	String separatorStr
	
	String list1, list2, w
	Variable i
	Variable waveTypeCode
	
	if (strlen(graphNameStr) == 0)
		graphNameStr = WinName(0, 1)
	endif
	if (WinType(graphNameStr) != 1)
		return ""				// bad graph name
	endif
	
	// Apply matchStr and graphNameStr criteria
	list1 = WaveList(matchStr, separatorStr, "WIN:" + graphNameStr)
	
	// Figure out which type of waves we want
	waveTypeCode = 0
	if (yOnly)
		waveTypeCode = 1
	endif
	if (xOnly)
		waveTypeCode = 2
	endif
	if (waveTypeCode == 0)
		list2 = list1
	else
		// Now apply the xOnly or yOnly criterion
		list2 = ""
		i = 0
		do
			w = WaveName(graphNameStr, i , waveTypeCode)
			if (strlen(w) == 0)
				break							// no more waves
			endif
			if (strsearch(list1, w, 0) >= 0)
				list2 += w + separatorStr
			endif
			i += 1
		while (1)
	endif
	
	return list2
End
