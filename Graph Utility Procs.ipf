#pragma rtGlobals=1
#pragma IgorVersion=6.1	// for Function/Wave
#pragma version=6.2		// shipped with Igor 6.2
#pragma moduleName= GraphUtilityProcs

// Graph Utility Procs
//
// Version 1.1 Created to be liberal name aware. Also added option to  CopyTraceSettings.
// Version 1.2, Added ApplyStyleMacro.
// Version 1.3, Removed use of Strings as Lists.
// Version 5.03, Removed use of String Substitution
//					Added WMGetGraphPlotBkgColor(), WMGetGraphWindowBkgColor()
// Version 5.031 - Added WMGetLayoutWindowBkgColor() here, even though it's not for graphs.
//					Removed WMLockGraphSize() because it's redundant with #include <Freeze Graph Size>
// Version 6.1 - (JP) Added WMGetColorsFromTopGraph() which requires Igor 6.1, and AskUserWhichColors().
//					Added WMGetRECREATIONFromInfo(info) and WMGetRECREATIONInfoByKey(key, info).
//					ApplyStyleMacro now just passes the entire macro to Execute (Igor 6 feature).
//					Added #pragma moduleName= GraphUtilityProcs so static functions are accessible from outside.
//				 (JW) Added CopyAxisSettingsForGraph() which is just like CopyAxisSettings() but includes the 
//					name of a graph in the input parameters.
//					Added CopyContourSettings()
//					Added CopyImageSettings()
// Version 6.2 - (JP) Fixed WMGetColorsFromGraph() to get the colors of all traces.
//					Added WMSetGraphSizePoints and WMSetGraphSizePixels.


// WMGetGraphPlotBkgColor - get the graph's plot area background color.
//
// Calling procedure:
//		Variable red, green, blue
//		Variable valid= WMGetGraphPlotBkgColor(graphName, red, green, blue)
//
// Returns truth that the colors returned in red, green, blue are valid (that the graph exists, mostly).
Function WMGetGraphPlotBkgColor(graphName, red, green, blue)
	String graphName					// input
	Variable &red, &green, &blue	// outputs: 0-65535
	
	return ParseStyleMacroColor(graphName, "gbRGB", red, green, blue)
End

// WMGetGraphWindowBkgColor - get the graph's window background color.
Function WMGetGraphWindowBkgColor(graphName, red, green, blue)
	String graphName					// input
	Variable &red, &green, &blue	// outputs: 0-65535
	
	return ParseStyleMacroColor(graphName, "wbRGB", red, green, blue)
End

// WMGetLayoutWindowBkgColor - get the layout's window background color.
Function WMGetLayoutWindowBkgColor(layoutName, red, green, blue)
	String layoutName				// input
	Variable &red, &green, &blue	// outputs: 0-65535
	
	return ParseStyleMacroColor(layoutName, "bgRGB", red, green, blue)
End

// Returns truth that the colors returned in red, green, blue are valid (that the graph exists, mostly).
Static Function ParseStyleMacroColor(win, keyword, red, green, blue)
	String win	// input
	String keyword	// "gbRGB" or "wbRGB", "bgRGB", etc. case sensitive
	Variable &red, &green, &blue	// outputs: 0-65535
	
	Variable valid= 0
	DoWindow $win
	if( V_Flag 	)	// the graph exists
		red= 65535	// default is white
		green= 65535
		blue= 65535
		String commands= WinRecreation(win,1+4) // style macro is all that's needed to get the color
		// 	ModifyGraph/Z wbRGB=(65535,54611,49151),gbRGB=(65535,65534,49151)
		String key= keyword+"=("
		Variable start= strsearch(commands, key, 0)
		if( start > 0 )
			Variable last= strsearch(commands, ")", start)
			if( last > start )
				String rgb= commands[start+strlen(key),last]	// "65535,65534,49151"
				sscanf rgb, "%d,%d,%d", red, green, blue
				valid= V_Flag == 3
			endif
		else
			valid= 1	// no command means the default white is the valid color.
		endif
	endif
	return valid
End

Function/S WMGetRECREATIONFromInfo(info)
	String info	// from ImageInfo, ContourInfo, TraceInfo, or AxisInfo

	String key=";RECREATION:"
	Variable sstop= strsearch(info, key, 0)
	info= info[sstop+strlen(key),inf]		// want just recreation stuff
	return info
end

Function/S WMGetRECREATIONInfoByKey(key, info)
	String key	// "zmrkNum(x)" for TraceInfo, or "ctab" for ImageInfo
	String info	// from ImageInfo, AxisInfo, or TraceInfo
	
	return StringByKey(key,WMGetRECREATIONFromInfo(info), "=")
end

// This routine reads the settings of the srcaxis of the top graph and copies them
// to the destaxis
Function CopyAxisSettings(srcaxis,destaxis)
	String srcaxis,destaxis

	String graphName = WinName(0,1)
	CopyAxisSettingsForGraph(graphName, srcaxis, destaxis)
End

Function CopyAxisSettingsForGraph(graphName, srcaxis, destaxis)
	String graphName, srcaxis, destaxis

	String info=  AxisInfo(graphName,srcaxis)
	Variable sstop= strsearch(info, "RECREATION:", 0)
	info= info[sstop+strlen("RECREATION:"),1e6]		// want just recreation stuff
	Variable i=0
	String dstr= "("+destaxis+")"	// i.e., (left)
	String sitem,xstr
	do
		sitem= StringFromList(i,info)
		if( strlen(sitem) == 0 )
			break;
		endif
		xstr= "ModifyGraph/W="+graphName+" "+ReplaceString("(x)",sitem,dstr,1)	// replace "(x)" in sitem with, for example, "(left)"
		Execute/Q/Z xstr
		i+=1
	while(1)
End


// This routine reads the settings of the given trace on the top graph and copies them
// to the destination trace
// Modifyed 951107,LH: Can now accept either a wave name and instance or a
// trace name. To use the later, specify -1 for the instance.
//
Function CopyTraceSettings(srcwave,srcinstance,destwave,destinstance [, graphName])
	String srcwave,destwave
	Variable srcinstance,destinstance
	String graphName
	
	if (paramIsDefault(graphName))
		graphName = WinName(0,1)
	endif
	
	if( srcinstance == -1 )
		srcinstance= 0			// only used by TraceInfo which knows how to handle trace name
	endif

	String info=  TraceInfo("",srcwave,srcinstance)
	CopyXSettings(info, "ModifyGraph", graphName, destwave, destinstance)
End

static Function CopyXSettings(infoString, command, graphname, destwave, destinstance)
	String infoString, command, graphname
	String destwave
	Variable destinstance
	
	Variable sstop= strsearch(infoString, "RECREATION:", 0)
	infoString= infoString[sstop+strlen("RECREATION:"),1e6]		// want just recreation stuff
	Variable i=0
	String dstr
	if( destinstance == -1 )
		dstr= "("+destwave+")"			// i.e., (jack#1)
	else
		dstr= "("+PossiblyQuoteName(destwave)+"#"+num2istr(destinstance)+")"
	endif
	String sitem,xstr
	do
		sitem= StringFromList(i,infoString)
		if( strlen(sitem) == 0 )
			break;
		endif
		xstr= command+"/W="+graphname+" "+ReplaceString("(x)",sitem,dstr,1)	// replace "(x)" in sitem with, for example, "(left)"
		Execute/Q/Z xstr
		i+=1
	while(1)
end

Function CopyImageSettings(srcwave, srcinstance, destwave, destinstance [, graphName])
	String srcwave,destwave
	Variable srcinstance, destinstance
	String graphName
	
	if (paramIsDefault(graphName))
		graphName = WinName(0,1)
	endif
		
	if( srcinstance == -1 )
		srcinstance= 0			// only used by TraceInfo which knows how to handle trace name
	endif

	String info=  ImageInfo("",srcwave,srcinstance)
	CopyNoXSettings(info, "ModifyImage", graphName, destwave, destinstance)
end

Function CopyContourSettings(srcwave, srcinstance, destwave, destinstance [, graphName])
	String srcwave,destwave
	Variable srcinstance, destinstance
	String graphName
	
	if (paramIsDefault(graphName))
		graphName = WinName(0,1)
	endif
		
	if( srcinstance == -1 )
		srcinstance= 0			// only used by TraceInfo which knows how to handle trace name
	endif

	String info=  ContourInfo("",srcwave,srcinstance)
	CopyNoXSettings(info, "ModifyContour", graphName, destwave, destinstance)
end

static Function CopyNoXSettings(infoString, command, graphname, destwave, destinstance)
	String infoString, command, graphname
	String destwave
	Variable destinstance
	
	Variable sstop= strsearch(infoString, "RECREATION:", 0)
	infoString= infoString[sstop+strlen("RECREATION:"),1e6]		// want just recreation stuff
	Variable i=0
	String dstr
	if( destinstance == -1 )
		dstr= destwave			// i.e., jack#1
	else
		dstr= PossiblyQuoteName(destwave)+"#"+num2istr(destinstance)
	endif
	command = command+"/W="+graphName+" "+dstr+" "
	String sitem,xstr
	do
		sitem= StringFromList(i,infoString)
		if( strlen(sitem) == 0 )
			break;
		endif
		xstr= command+sitem
		Execute/Q/Z xstr
		i+=1
	while(1)
end

// This routine applies the style macro contained in styleMacroStr to the top window
// The usual method of acquiring the style macro is
// String styleMacroStr= WinRecreation("",1)	// "" means top window
Function ApplyStyleMacro(styleMacroStr)
	String styleMacroStr

	// Igor 6 allows direct execution of the entire style and window recreation macros
	Execute/Q/Z styleMacroStr
End

Function WMSetGraphSizePixels(graphName, widthPixels, heightPixels [,fixedSize])
	String graphName
	Variable widthPixels, heightPixels	// wsize, not psize
	Variable fixedSize	// optional, default is -1 to not set the graph's width and height mode, 0 to set the graph width mode to auto, 1 to fixed.
	
	if( ParamIsDefault(fixedSize) )
		fixedSize= -1	// don't change width and height modes
	endif

	Variable widthPoints= widthPixels * (72/ScreenResolution)	// Convert pixels to points
	Variable heightPoints= heightPixels * (72/ScreenResolution)

	return WMSetGraphSizePoints(graphName, widthPoints, heightPoints,fixedSize=fixedSize)
End

// Note: WMSetGraphSizePoints() always sets the margins to fixed values, perhaps to None (-1)
// Also see #include <Freeze Graph Size>
//
Function WMSetGraphSizePoints(graphName, widthPoints, heightPoints[,fixedSize])
	String graphName
	Variable widthPoints, heightPoints	// wsize, not psize
	Variable fixedSize	// optional, default is -1 to not set the graph's width and height mode, 0 to set the graph width mode to auto, 1 to fixed.
	
	if( WinType(graphName) != 1 )
		return -1
	endif
	
	if( ParamIsDefault(fixedSize) )
		fixedSize= -1	// don't change width and height modes
	endif
	
	GetWindow/Z $graphName wsizeRM	// to get new size (in points), works even if the window is minimized
	if( fixedSize == 1 )
		Variable graphWidthPoints= V_right-V_left
		Variable graphHeightPoints= V_bottom-V_top
		
		GetWindow $graphName psize	// local coordinate points, not sure it works if the window is minimized
	
		Variable leftMarginPoints= V_left	// assumes no in-graph tool bar
		Variable topMarginPoints= V_top		// assumes no ControlBar
		Variable rightMarginPoints= graphWidthPoints - V_right
		Variable bottomMarginPoints= graphHeightPoints - V_bottom

		// Set new plot-area width and height to give new total size
		widthPoints -= (leftMarginPoints + rightMarginPoints)
		heightPoints -= (topMarginPoints + bottomMarginPoints)

		// fix the margins, too.
		// a margin of 0 actually means "Auto". Here we convert that to -1
		if( leftMarginPoints == 0 )
			leftMarginPoints= -1	// None
		endif
		if( topMarginPoints == 0 )
			topMarginPoints= -1	// None
		endif
		if( rightMarginPoints == 0 )
			rightMarginPoints= -1	// None
		endif
		if( bottomMarginPoints == 0 )
			bottomMarginPoints= -1	// None
		endif
		ModifyGraph/W=$graphName width=widthPoints, height=heightPoints, margin(left)=leftMarginPoints, margin(right)=rightMarginPoints, margin(top)=topMarginPoints, margin(bottom)=bottomMarginPoints
	else
		Variable rightPoints= V_left + widthPoints
		Variable bottomPoints= V_top + heightPoints
		if( fixedSize == 0 )
			ModifyGraph/W=$graphName width=0, height=0	// auto plot area width and height. This does not alter the margins. Use ModifyGraph/W=$graphName margin=0 to set them to auto.
		endif
		MoveWindow/W=$graphName V_left, V_top, rightPoints, bottomPoints
	endif
	return 0
End


Function/WAVE WMGetColorsFromTopGraph(rgbWaveName,whichColors)
	String rgbWaveName
	String &whichColors	// "all;" or list containing some or all of "traces;axes;drawing;backgrounds;ctab;cindex;rgbimages"
							// on return whichColors will contain a list of which of those colors were actually found.
	String graphName= WinName(0,1,1)	// top visible graph
	if( strlen(graphName) )
		return WMGetColorsFromGraph(graphName,rgbWaveName,whichColors)
	endif
 	WAVE/Z/U/W graphRGBs
	return graphRGBs	// NULL
End

Static Function/S ListOfGraphSubwindows(parentPath)
	String parentPath
	
	String childrenList = ChildWindowList(parentPath)	// direct children of parent
	String returnList = ""
	Variable i, nItems = ItemsInList(childrenList)
	for (i = 0; i < nItems; i += 1)
		String child = StringFromList(i, childrenList)
		String childPath=parentPath+"#"+child
		String allTheChildren= ListOfGraphSubwindows(childPath)
		if( strlen(allTheChildren) )
			returnList += allTheChildren
		endif
	endfor
	
	if( WinType(parentPath) == 1 )
		returnList = parentPath+";"+returnList
	endif
	return returnList
end


// Returns wave reference to wave created in the current data folder
// containing red, green, blue values in columns 0,1,2
// with red, green, blue dimension labels.
//
// Contains these colors from the top graph:
//	Colors from window and plot area backgrounds
//	Colors from traces, including contour traces
//	Colors from axes, ticks, axis labels and tick labels
//	Colors from f(z) and image plot color tables
//	Colors from drawing tools
//	Colors from annotations (textboxes, legends, tags)
//	f(z) and Image Color Index Waves
//	Direct RGB images
//
// This is prone to gather more colors than needed;
// if the user specifies a fill-to-zero color but doesn't change the fill from None,
// the color isn't actually used but we return it.
//
// NOT RETURNED:
//	Colors from pasted graphics
//	Black from default axis, textbox, or drawing settings
//	White from default background settings
//
// It could be argued that a better way would be to export the graph and read it as rgb.
//
// See Also: AskUserWhichColors().
//
Function/WAVE WMGetColorsFromGraph(graphName,rgbWaveName,whichColors)
	String graphName		// must exist. This window and any children are examined.
	String rgbWaveName
	String &whichColors	// "all;" or list containing some or all of "traces;axes;drawing;backgrounds;ctab;cindex;rgbimages"
							// on return whichColors will contain a list of which of those colors were actually found.
							
	String foundColors=""
	if (strlen(whichColors) == 0 )
		whichColors= "all;"
	endif
	Variable doingAll= Cmpstr(whichColors,"all") == 0 || Cmpstr(whichColors,"all;") == 0
	String allColorTables= CTabList()
	
	Make/U/W/O/N=(0,3) $rgbWaveName/WAVE=graphRGBs
	SetDimLabel 1, 0, red, graphRGBs
	SetDimLabel 1, 1, green, graphRGBs
	SetDimLabel 1, 2, blue, graphRGBs
	
	Variable red, green, blue
	String code= WinRecreation(graphName,4)			// graph and all children
	String styleCode= WinRecreation(graphName,1+4)	// style only, graph and all children

	// To iterate over the current graph and all of its graph subwindows,  we make a list now.
	String windowName, windows= ListOfGraphSubwindows(graphName)
	Variable winNum, numWindows= ItemsInList(windows)

	Variable offset,i,n,foundAColor
	String keys,keyPrefix, keyEnd, rgbStart, rgbEnd, thatColor

	thatColor= "backgrounds"
	if( doingAll || WhichListItem(thatColor, whichColors) >= 0 )
		foundAColor= 0
		// colors from windows and plot areas
		// ModifyGraph/Z wbRGB=(21845,21845,21845),gbRGB=(21845,21845,21845)
		keys= "gbRGB=;wbRGB=;"
		n=ItemsInList(keys)
		for(i=0; i<n; i+= 1)
			keyPrefix= StringFromList(i,keys)
			offset= 0
			do
				offset= GetNextRGB(styleCode, offset, keyPrefix, "", "(", ")", red, green, blue)
				if( offset < 0 )
					break
				endif
				foundAColor= 1
				foundColors = RemoveFromList(thatColor,foundColors)+thatColor+";"
				if( -1 == MatchingRGB(graphRGBs, red, green, blue) )
					AddRGBToWave(graphRGBs, red, green, blue)
				endif
			while( 1 )
		endfor
	endif
		
	thatColor= "axes"
	if( doingAll || WhichListItem(thatColor, whichColors) >= 0 )
		foundAColor= 0
		// colors from individual axes: axRGB, tlblRGB, tlblRGB
		// ModifyGraph/Z axRGB(left)=(65535,16385,16385), etc
		keys= "alblRGB(;axRGB(;tickRGB(;tlblRGB(;"
		// colors from all axes
		// ModifyGraph/Z axRGB=(65535,16385,16385), etc
		keys += "alblRGB;axRGB;tickRGB;tlblRGB;"
		n=ItemsInList(keys)
		for(i=0; i<n; i+= 1)
			keyPrefix= StringFromList(i,keys)
			if( strsearch(keyPrefix,"(",0)>=0 )
				keyEnd=")="
			else
				keyEnd= "="
			endif
			offset= 0
			do
				offset= GetNextRGB(styleCode, offset, keyPrefix, keyEnd, "(", ")", red, green, blue)
				if( offset < 0 )
					break
				endif
				foundAColor= 1
				foundColors = RemoveFromList(thatColor,foundColors)+thatColor+";"
				if( -1 == MatchingRGB(graphRGBs, red, green, blue) )
					AddRGBToWave(graphRGBs, red, green, blue)
				endif
			while( 1 )
		endfor
		// gridRGB is tricky: the default is a light blue. We may have no grid, the default grid color, or (only) a user-specified grid color.
		for( winNum=0; winNum<numWindows; winNum+=1 )
			String win= StringFromList(winNum,windows)
			String axes= AxisList(win)
			n= ItemsInList(axes)
			for(i=0; i<n; i+= 1)
				String axisName= StringFromList(i,axes)
				String info = AxisInfo(win, axisName)
				if( strlen(info) )
					Variable grid= str2num(WMGetRECREATIONInfoByKey("grid(x)", info))
					if( grid )
						String rgbtext= WMGetRECREATIONInfoByKey("gridRGB(x)", info)	//  "(r,g,b)"
						sscanf rgbtext, "(%d,%d,%d)", red, green, blue
						if( V_Flag == 3 )
							foundColors = RemoveFromList(thatColor,foundColors)+thatColor+";"
							if( -1 == MatchingRGB(graphRGBs, red, green, blue) )
								AddRGBToWave(graphRGBs, red, green, blue)
							endif	// new color
						endif	// V_Flag
					endif	// grid
				endif	// info
			endfor	// axes
		endfor	// graph windows
	endif	// thatColor
	
	thatColor= "traces"
	if( doingAll || WhichListItem(thatColor, whichColors) >= 0 )
		foundAColor= 0
		// rgb is tricky: the default is pure red. We may have no traces, the default trace color, or (only) a user-specified grid color.
		for( winNum=0; winNum<numWindows; winNum+=1 )
			win= StringFromList(winNum,windows)
			String traces= TraceNameList(win,";",7)	// 7=normal and contour traces, omit hidden traces
			Variable traceIndex,numTraces= ItemsInList(traces)
			for(traceIndex=0; traceIndex<numTraces; traceIndex+= 1)
				String traceName= StringFromList(traceIndex,traces)
				info = TraceInfo(win, traceName,0)
				if( strlen(info) )
					// This is prone to gather more colors than needed;
					// if the user specifies a fill-to-zero color but doesn't change the fill from None,
					// the color isn't actually used but we return it.
					String enableKeys="lsize(x);usePlusRGB(x);useNegRGB(x);useMrkStrokeRGB(x);useBarStrokeRGB(x);"
					String rgbKeys="rgb(x);plusRGB(x);negRGB(x);mrkStrokeRGB(x);barStrokeRGB(x);"
					n=ItemsInList(enableKeys)
					for(i=0; i<n; i+= 1)
						String enableKey= StringFromList(i,enableKeys)
						String rgbKey= StringFromList(i,rgbKeys)
						Variable enable= str2num(WMGetRECREATIONInfoByKey(enableKey, info))
						if( enable )
							rgbtext= WMGetRECREATIONInfoByKey(rgbKey, info)	//  "(r,g,b)"
							sscanf rgbtext, "(%d,%d,%d)", red, green, blue
							if( V_Flag == 3 )
								foundColors = RemoveFromList(thatColor,foundColors)+thatColor+";"
								if( -1 == MatchingRGB(graphRGBs, red, green, blue) )
									AddRGBToWave(graphRGBs, red, green, blue)
								endif	// new color
							endif	// V_Flag
						endif	// enable
					endfor	// keys
				endif	// info
			endfor	// axes
		endfor	// graph windows
	endif

	thatColor= "drawing"
	if( doingAll || WhichListItem(thatColor, whichColors) >= 0 )
		foundAColor= 0
		// color from drawing commands
		// SetDrawEnv linefgc= (0,26214,26214),fillfgc= (65535,54607,32768),fillbgc= (49151,65535,65535), etc
		code= WinRecreation(graphName,4)	// full recreation macro
		code= GrepList(code, "SetDrawEnv", 0, "\r")	// just SetDrawEnv lines.
		keys= "fillbgc= ;fillfgc= ;linebgc= ;linefgc= ;textrgb= ;"	// note the trailing spaces
		n=ItemsInList(keys)
		for(i=0; i<n; i+= 1)
			keyPrefix= StringFromList(i,keys)
			offset= 0
			do
				offset= GetNextRGB(code, offset, keyPrefix, "", "(", ")", red, green, blue)
				if( offset < 0 )
					break
				endif
				foundAColor= 1
				foundColors = RemoveFromList(thatColor,foundColors)+thatColor+";"
				if( -1 == MatchingRGB(graphRGBs, red, green, blue) )
					AddRGBToWave(graphRGBs, red, green, blue)
				endif
			while( 1 )
		endfor
	endif
	
	thatColor= "annotations"
	if( doingAll || WhichListItem(thatColor, whichColors) >= 0 )
		foundAColor= 0
		// color from drawing annotations
		// Textbox/B=(r,g,b)/G=(r,g,b) "\\K(r,g,b,)\\k(r,g,b)"
		code= WinRecreation(graphName,4)	// full recreation macro
		String  regExpr="TextBox|Tag|Legend|ColorScale|AppendText"
		code= GrepList(code,regExpr,0,"\r")	// only annotation commands
		keys= "/B=;/G=;\\K;\\k;"
		n=ItemsInList(keys)
		for(i=0; i<n; i+= 1)
			keyPrefix= StringFromList(i,keys)
			offset= 0
			do
				offset= GetNextRGB(code, offset, keyPrefix, "", "(", ")", red, green, blue)
				if( offset < 0 )
					break
				endif
				foundAColor= 1
				foundColors = RemoveFromList(thatColor,foundColors)+thatColor+";"
				if( -1 == MatchingRGB(graphRGBs, red, green, blue) )
					AddRGBToWave(graphRGBs, red, green, blue)
				endif
			while( 1 )
		endfor
	endif

	String ctabs=""		// don't include color tables multiple times by keeping a list
	String indexWaves=""	// don't index waves multiple times by keeping a list
	String rgbWaves=""	// don't index waves multiple times by keeping a list

	// now iterate over the current graph and all of its graph subwindows
	for( winNum=0; winNum<numWindows; winNum+=1 )
		win= StringFromList(winNum,windows)
	
		// note that we add alll the colors from the color table, regardless of whether they're actually used in the graph.
		thatColor= "ctab"
		if( doingAll || WhichListItem(thatColor, whichColors) >= 0 )
			foundAColor= 0
	
			// color tables from images that actually USE the color table
			String images= ImageNameList(win,";")
			n= ItemsInList(images)
			for(i=0; i<n; i+= 1)
				String imageName= StringFromList(i,images)
				info = ImageInfo(win, imageName, 0)
				if( strlen(info) )
					Variable colorMode= NumberByKey("COLORMODE",info)
					if( colorMode != 1 )	// 1 means color table
						continue
					endif
					info= WMGetRECREATIONInfoByKey("ctab", info)	//  " {*,*,Rainbow,0}" (note leading space)
					String ctab= StringFromList(2,info,",")		// "Rainbow"
					if( strlen(ctab) && WhichListItem(ctab,allColorTables) >= 0 )
						foundAColor= 1
						if( WhichListItem(ctab,ctabs) < 0 )	// unique color table in this graph
							ctabs += ctab+";"
							AddColorTableRGBsToWave(graphRGBs, ctab)
						endif
					endif
				endif
			endfor
			
			// color tables from contour plots are handled by the trace stuff above
			// (and that's better than using every color in the contour's color table).
			
			// colors from f(z) traces: "... ;RECREATION:zColor(x)={data,num1,num2,dBZ14}; ..."
			traces= TraceNameList(win,";",1+2+4)	// only visible traces, include normal and contour traces
			n= ItemsInList(traces)
			for(i=0; i<n; i+= 1)
				traceName= StringFromList(i,traces)
				info = WMGetRECREATIONFromInfo(TraceInfo(win, traceName, 0))	// "zColor(x)={data,num1,num2,dBZ14}; ..."
				if( strlen(info) )
					info= StringByKey("zColor(x)", info, "=")		// "{data,num1,num2,dBZ14}"
					ctab= StringFromList(3,info,",")				// "dBZ14}"
					ctab= RemoveEnding(ctab,"}")				// "dBZ14"
					if( strlen(ctab) && WhichListItem(ctab,allColorTables) >= 0 )
						foundAColor= 1
						if( WhichListItem(ctab,ctabs) < 0 )	// unique color table in this graph
							ctabs += ctab+";"
							AddColorTableRGBsToWave(graphRGBs, ctab)
						endif
					endif
				endif
			endfor
			
			if( 	foundAColor )
				foundColors += thatColor+";"
			endif
		endif	// end of color table sources
		
		// cindex
		thatColor= "cindex"
		if( doingAll || WhichListItem(thatColor, whichColors) >= 0 )
			foundAColor= 0

			// color index waves from images
			images= ImageNameList(win,";")
			n= ItemsInList(images)
			for(i=0; i<n; i+= 1)
				imageName= StringFromList(i,images)
				info = ImageInfo(win, imageName, 0)
				if( strlen(info) )
					colorMode= NumberByKey("COLORMODE",info)
					if( colorMode != 2 && colorMode != 3 )	// scaled and point-scaled index waves
						continue
					endif
					String relPathToCIndex= WMGetRECREATIONInfoByKey("cindex", info)	//  " {*,*,Rainbow,0}" (note leading space)
					WAVE/Z cindex= $relPathToCIndex
					if( WaveExists(cindex) )
						foundAColor= 1
						String fullPath= GetWavesDataFolder(cindex,2)
						if( WhichListItem(fullPath,indexWaves) < 0 )	// unique color index wave in this graph
							indexWaves += fullPath+";"
							AddCIndexRGBsToWave(graphRGBs, cindex)
						endif
					endif
				endif
			endfor

			// color index waves from contour plots are handled by the trace stuff above
			// (and that's better than using every color in the contour's color index wave).
			
			// indexed colors from f(z) traces: "... ;RECREATION:zColor(x)={::cmykIn[0][*][0],*,*,cindexRGB,0,::M_colors}; ..."
			// or  "zColor(x)={directCiWave,*,*,directRGB}; ..." (3-column trace color waves)
			traces= TraceNameList(win,";",1+2+4)	// only visible traces, include normal and contour traces
			n= ItemsInList(traces)
			for(i=0; i<n; i+= 1)
				traceName= StringFromList(i,traces)
				info = WMGetRECREATIONFromInfo(TraceInfo(win, traceName, 0))	// "zColor(x)={zWave,*,*,cindexRGB,0,ciWave}; 
				if( strlen(info) )
					info= StringByKey("zColor(x)", info, "=")					// "{zWave,*,*,cindexRGB,0,ciWave}" or "{directCiWave,*,*,directRGB}"
					ctab= RemoveEnding(StringFromList(3,info,","),"}")		// "cindexRGB", or possibly "directRGB"
					strswitch(ctab)
						case "cindexRGB":
							relPathToCIndex= RemoveEnding(StringFromList(5,info,","),"}")
							break
						default:
							continue	// next trace
					endswitch
					WAVE/Z cindex= $relPathToCIndex
					if( WaveExists(cindex) )
						foundAColor= 1
						fullPath= GetWavesDataFolder(cindex,2)
						if( WhichListItem(fullPath,indexWaves) < 0 )	// unique color index wave in this graph
							indexWaves += fullPath+";"
							AddCIndexRGBsToWave(graphRGBs, cindex)
						endif
					endif
				endif
			endfor
	
			if( 	foundAColor )
				foundColors += thatColor+";"
			endif
		endif		// end of cindex sources

		// rgbImages & explicit
		thatColor= "directRGB"
		if( doingAll || WhichListItem(thatColor, whichColors) >= 0 )
			foundAColor= 0

			// direct color waves from images
			images= ImageNameList(win,";")
			n= ItemsInList(images)
			for(i=0; i<n; i+= 1)
				imageName= StringFromList(i,images)
				info = ImageInfo(win, imageName, 0)
				if( strlen(info) )
					colorMode= NumberByKey("COLORMODE",info)
					if( colorMode != 4 )	// direct color (from the 3-layer z wave)
						continue
					endif
					String pathToZ= StringByKey("ZWAVEDF",info)+StringByKey("ZWAVE",info)
					WAVE/Z zrgb= $pathToZ
					if( WaveExists(zrgb) && DimSize(zrgb,2) >= 3)	// 3 layers
						foundAColor= 1
						fullPath= GetWavesDataFolder(zrgb,2)
						if( WhichListItem(fullPath,rgbWaves) < 0 )	// unique color index wave in this graph
							rgbWaves += fullPath+";"
							AddDirectColorRGBsToWave(graphRGBs, zrgb)
						endif
					endif
				endif
			endfor

			// indexed colors from f(z) traces: "... ;RECREATION:zColor(x)={::cmykIn[0][*][0],*,*,cindexRGB,0,::M_colors}; ..."
			// or  "zColor(x)={directCiWave,*,*,directRGB}; ..." (3-column trace color waves)
			traces= TraceNameList(win,";",1+2+4)	// only visible traces, include normal and contour traces
			n= ItemsInList(traces)
			for(i=0; i<n; i+= 1)
				traceName= StringFromList(i,traces)
				info = WMGetRECREATIONFromInfo(TraceInfo(win, traceName, 0))	// "zColor(x)={zWave,*,*,cindexRGB,0,ciWave}; 
				if( strlen(info) )
					info= StringByKey("zColor(x)", info, "=")					// "{zWave,*,*,cindexRGB,0,ciWave}" or "{directCiWave,*,*,directRGB}"
					ctab= RemoveEnding(StringFromList(3,info,","),"}")		// "cindexRGB", or possibly "directRGB"
					strswitch(ctab)
						case "directRGB":
							relPathToCIndex= StringFromList(0,info,",")[1,inf]	// directCiWave
							break
						default:
							continue	// next trace
					endswitch
					WAVE/Z cindex= $relPathToCIndex
					if( WaveExists(cindex) )
						foundAColor= 1
						fullPath= GetWavesDataFolder(cindex,2)
						if( WhichListItem(fullPath,indexWaves) < 0 )	// unique color index wave in this graph
							indexWaves += fullPath+";"
							AddCIndexRGBsToWave(graphRGBs, cindex)
						endif
					endif
				endif
			endfor
		
			if( 	foundAColor )
				foundColors += thatColor+";"
			endif
		endif	// end of rgbImages & explicit
			
	endfor	// end of this (sub-) window

	whichColors= foundColors
	return graphRGBs
End


Static Function AddRGBToWave(w, red, green, blue)
	Wave/Z w
	Variable red, green, blue

	Variable rows= -1
	if( WaveExists(w) )
		rows= DimSize(w,0)
		InsertPoints/M=0 rows, 1, w
		w[rows][%red]= red
		w[rows][%green]= green
		w[rows][%blue]= blue
	endif
	return rows
End

Static Function MatchingRGB(w, red, green, blue)
	Wave/Z w
	Variable red, green, blue

	if( WaveExists(w) )
		Variable nrows= DimSize(w,0)
		Variable row
		for(row= 0; row < nrows; row += 1 )
			if( w[row][%red] == red &&w[row][%green] == green &&w[row][%blue] == blue )
				return row
			endif	
		endfor
	endif
	return -1
End

Static Function AddColorTableRGBsToWave(w, ctab)
	Wave/Z w
	String ctab

	if( WaveExists(w) )
		ColorTab2Wave $ctab
		WAVE/Z M_colors
		if( WaveExists(M_Colors) )
			Variable row, nrows= DimSize(M_colors,0)
			for( row=0; row<nrows; row+=1)
				Variable red= M_colors[row][0]
				Variable green= M_colors[row][1]
				Variable blue= M_colors[row][2]
				if(  -1 == MatchingRGB(w, red, green, blue) )
					AddRGBToWave(w, red, green, blue)
				endif
			endfor
			KillWaves/Z M_colors
		endif
	endif
End

Static Function AddCIndexRGBsToWave(w, cindex)
	Wave/Z w, cindex

	if( WaveExists(w) && WaveExists(cindex) && DimSize(cindex,1) >= 3 )
		Variable row, nrows= DimSize(cindex,0)
		for( row=0; row<nrows; row+=1)
			Variable red= cindex[row][0]
			Variable green= cindex[row][1]
			Variable blue= cindex[row][2]
			if(  -1 == MatchingRGB(w, red, green, blue) )
				AddRGBToWave(w, red, green, blue)
			endif
		endfor
	endif
End

Static Function AddDirectColorRGBsToWave(w, zrgb)
	Wave/Z w, zrgb

	if( WaveExists(w) && WaveExists(zrgb) && DimSize(zrgb,2) >= 3 )
		Variable row, nrows= DimSize(zrgb,0)
		for( row=0; row<nrows; row+=1)
			Variable col, ncols= DimSize(zrgb,1)
			for( col=0; col<ncols; col+=1)
				Variable red= zrgb[row][col][0]
				Variable green= zrgb[row][col][1]
				Variable blue= zrgb[row][col][2]
				if(  -1 == MatchingRGB(w, red, green, blue) )
					AddRGBToWave(w, red, green, blue)
				endif
			endfor
		endfor
	endif
End


// returns offset PAST then found rgb stuff (where to start the NEXT search.
Static Function GetNextRGB(code, offset, keyPrefix, keyEnd, rgbStart, rgbEnd, red, green, blue)
	String code
	Variable offset	// start looking here
	String keyPrefix		// "rgb[" or "rgb("
	String keyEnd		// "]=(" or")="
	String rgbStart		// "(" or whatever
	String rgbEnd		// ")"
	Variable &red, &green, &blue		// outputs
	
	do
		// keyPrefix is not optional
		offset= strsearch(code, keyPrefix, offset)
		if( offset < 0 )
			return -1
		endif
		offset += strlen(keyPrefix)
		// skip to keyEnd, we've now skipped over something like rgb[0]=(
		if( strlen(keyEnd) )
			offset= strsearch(code, keyEnd, offset)
			if( offset < 0 )
				continue
			endif
			offset += strlen(keyEnd)
		endif
		if( strlen(rgbStart) )
			offset= strsearch(code, rgbStart, offset)
			if( offset < 0 )
				continue
			endif
			offset += strlen(rgbStart)
		endif
		// rgbEnd is not optional
		Variable rgbEndPos= strsearch(code, rgbEnd, offset)
		if( rgbEndPos < 0 )
			continue
		endif
		// found an rgb
		String rgbtext=code[offset,rgbEndPos-1]
		sscanf rgbtext, "%d,%d,%d", red, green, blue
		if( V_Flag == 3 )
			offset= rgbEndPos + strlen(rgbEnd)
			return offset
		endif
		// didn't scan, keep looking, discarding the (apparently unreliable) rgbEndPos
		
	while( 1 )	// return from inside loop
	// WE NEVER GET HERE
End



// AskUserWhichColors() usage:
//
//	// Find out which colors are in the graph
//	String whichColors="all;"
//	WAVE/Z rgbs= WMGetColorsFromTopGraph("graphRGBs",whichColors)	// sets whichColors
//
// // Then ask the user which ones are desired:
//	String userApprovedColors=	AskUserWhichColors(whichColors)
//	Variable userCancelled= CmpStr(userApprovedColors,"cancel;") == 0 
//	if( userCancelled )
//		return 0
//	endif
//
//	// Get only the approved colors...
//	if( CmpStr(userApprovedColors,whichColors) != 0  && ItemsInList(userApprovedColors) > 0 )
//		WAVE/Z rgbs= WMGetColorsFromTopGraph("graphRGBs",userApprovedColors)
//	endif
//
//	// Use the approved colors...
//
// Input and output are lists of categories of colors from ksListOfGraphColorSources
//
// If the user cancels, the returned string is "cancel"
//

StrConstant ksListOfGraphColorSources= "traces;axes;drawing;annotations;backgrounds;ctab;cindex;rgbWaves;"
StrConstant ksGraphColorSourceDescriptions= "Trace Colors;Axis Colors;Drawing Objects Colors;Annotation Colors;Window and Plot Area Backgrounds;Color Tables;Color Index Waves;Direct RGB Images;"

Function/S AskUserWhichColors(whichColors)
	String whichColors
	
	String userApprovedColors=SortList(whichColors)
	
	if( ItemsInList(whichColors) > 0 )
		// Put up a bunch of checkboxes for the user to approve
		Variable checkboxOffset= 30
		Variable i, n=ItemsInList(whichColors)
		Variable titleBoxTop= 10
		Variable titleBoxHeight= 44
		Variable panelWidth= 400
		Variable buttonHeight=20
		
		Variable panelHeight= (n+2) * checkboxOffset + titleBoxTop + titleBoxHeight + buttonHeight
		
		DoWindow/K AskUserWhichColorsPanel
		Variable top=100, bottom= top+panelHeight
		Variable left= 100, right= left+panelWidth
		NewPanel/W=(left,top,right,bottom)/K=1/N=AskUserWhichColorsPanel as "Which Colors Do You Want to Use?"
		DefaultGuiFont/W=#/Mac popup={"_IgorMedium",12,0},all={"_IgorMedium",12,0}
		DefaultGuiFont/W=#/Win popup={"_IgorMedium",0,0},all={"_IgorMedium",0,0}
		
		TitleBox about,pos={0,titleBoxTop},size={panelWidth,titleBoxHeight},title="\\JCThe graph contains colors from these sources.\r\rUncheck those you don't want to use."
		TitleBox about,anchor= MT
		
		left= 80
		for(i=0; i<n; i+= 1)
			String name= StringFromList(i,whichColors)	// in same order as provided by caller.
			top=titleBoxTop  + titleBoxHeight+ (i+1)*checkboxOffset
			Variable whichOne= WhichListItem(name,ksListOfGraphColorSources)
			String title= SelectString(whichOne>=0, name,StringFromList(whichOne,ksGraphColorSourceDescriptions))
			Checkbox $name, value=1, pos={left,top}, title=title, proc=GraphUtilityProcs#WhichColorsCheckProc
		endfor
		
		top += checkboxOffset*1.5
		Button cancel,pos={left,top},size={80,buttonHeight},title="Cancel"
		Button cancel proc=GraphUtilityProcs#WhichColorsCancelButtonProc
		left += 130
		Button approve,pos={left,top},size={150,buttonHeight},title="Use These Colors"
		Button approve proc=GraphUtilityProcs#WhichColorsApproveButtonProc

		String/G root:wmWhichColors=whichColors
		SVAR wmWhichColors= root:wmWhichColors

		PauseForUser AskUserWhichColorsPanel

		userApprovedColors= wmWhichColors
		KillStrings/Z root:wmWhichColors
	else
		DoAlert 0, "No Colors Found!"
	endif
	
	return SortList(userApprovedColors)
End

Static Function WhichColorsCancelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SVAR wmWhichColors= root:wmWhichColors
	wmWhichColors="cancel"
	DoWindow/K AskUserWhichColorsPanel
End

Static Function WhichColorsApproveButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K AskUserWhichColorsPanel	// PauseForUser
End

Static Function WhichColorsCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	SVAR wmWhichColors= root:wmWhichColors
	wmWhichColors= RemoveFromList(ctrlName,wmWhichColors)
	if( checked )
		wmWhichColors += ctrlName+";"
	endif
End
