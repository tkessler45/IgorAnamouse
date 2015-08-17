#pragma rtGlobals=1		// Use modern global access method.
#pragma version=6.20		// shipped with Igor 6.20A
#pragma IgorVersion=6.1
#pragma moduleName=ResizeControls

//	The ResizeControlsPanel procedure implements the resize behavior of individual controls in panel.
//	When the panel is resized, each edge of each control is (optionally) moved or resized
//	according to the selected mode.
//
//	Controls can be moved relative to the panel's or subwindows' edges,
//	or relative to user guides.
//
//	A table-like editor of these behaviors is implemented by
//		#include <Resize Controls Panel>
//
//	After including Resize Controls Panel.ipf,
//	call the ShowResizeControlsPanel() function to display the editor
//	or choose "Edit Controls Resized Positions" from Igor's Panel menu.
//
// NOTE: 
//		Control resizing information is stored in each control's userData(ResizeControlsInfo),
//		and the window resizing information is stored in the panel's userData(ResizeControlsInfo)
//
//	Revision History:
//		JP090429, version 6.1B07 (initial version)
//		JP090612, version 6.1 (initial release) - Fixed FitControlsToPanel bug: didn't grow controls vertically.
//		JP091022, version 6.12 -  ListOfChildWindows now returns only windows that can contain controls,
//				ResizeControlsHook no longer prevents other resize hooks from being called.
//		JP091201, version 6.13 -  Uses different technique for enforcing minimum size to avoid multiple Execute/P commands
//		JP100922, version 6.20 -  Revised comments.
//

// ++++++++ Public Constants

StrConstant ksResizeUserDataName= "ResizeControlsInfo"

StrConstant ksFixedFromLeft = "Left"	// aka "Panel Left"
StrConstant ksFixedFromMiddle= "Middle"
StrConstant ksFixedFromRight= "Right"

StrConstant ksFixedFromTop = "Top"
StrConstant ksFixedFromCenter= "Center"
StrConstant ksFixedFromBottom= "Bottom"

// ++++++++ Public Structures

Constant kCurrentResizeInfoVersion= 1

Structure WMResizeInfo
	int16	version			// usually kCurrentResizeInfoVersion

	// saved control or panel position
	float	originalLeft
	float	originalTop
	float	originalWidth
	float	originalHeight
	
	int16	fixedWidth	// for panel resize hook
	int16	fixedHeight	// for panel resize hook
	
	// how to adjust each control edge after panel resize
	char	leftMode[64]		// default is ksFixedFromLeft WITHOUT any appended ksPopArrowText
	char	rightMode[64]		// default is ksFixedFromLeft
	char	topMode[64]		// default is ksFixedFromTop
	char	bottomMode[64]	// default is ksFixedFromTop
EndStructure

// ++++++++ Static (Private) Constants



// window edge-relative adjustment constants



static Function GetControlResizeInfo(panelName, controlName, resizeInfo)
 	String panelName, controlName
	STRUCT WMResizeInfo &resizeInfo
	
	Variable hadInfo= 0
	String userdata = GetUserData(panelName, controlName, ksResizeUserDataName)
	if( strlen(userData)  )
		hadInfo= 1
		StructGet/S resizeInfo, userdata
		// if( ResizeInfo.version < kCurrentResizeInfoVersion )
		// here upgrade the structure to the current version
		// endif
	endif
	// Defaults are (Top/Left)
	if( strlen(resizeInfo.leftMode) == 0 )
		resizeInfo.leftMode= ksFixedFromLeft
	endif
	if( strlen(resizeInfo.rightMode) == 0 )
		resizeInfo.rightMode= ksFixedFromLeft
	endif
	if( strlen(resizeInfo.topMode) == 0 )
		resizeInfo.topMode= ksFixedFromTop
	endif
	if( strlen(resizeInfo.bottomMode) == 0 )
		resizeInfo.bottomMode= ksFixedFromTop
	endif
	return hadInfo
End

static Function GetGuideDelta(panelName,moveMode)
	String panelName
	String moveMode	// something like "Guide UGV1"

	Variable guideDelta= 0	// how much the guide has moved from its recorded position
	
	String guideName= StringFromList(1,moveMode, " ")

	String info= GuideInfo(panelName,guideName)
	Variable currentPosition= NumberByKey("POSITION",info)
	String userdataGuideInfo = GetUserData(panelName, "", ksResizeUserDataName+guideName)	// GuideInfo recorded in userData, see SaveControlPositions
	if( strlen(userdataGuideInfo) )
		Variable originalPosition=NumberByKey("POSITION",userdataGuideInfo)
		guideDelta= currentPosition-originalPosition
	endif
	return guideDelta
End

Static Function FitControlsToPanel(win)
	String win

	// We need the original size of window to compare with original positions of controls to generate offsets
	STRUCT WMResizeInfo resizeInfo
	String userdata = GetUserData(win, "", ksResizeUserDataName)
	if( strlen(userdata) == 0 )
		return 0
	endif
			
	StructGet/S resizeInfo, userdata
	Variable originalWinWidth=resizeInfo.originalWidth	// pixels
	Variable originalWinHeight=resizeInfo.originalHeight	// pixels
	
	GetWindow $win wsizeDC	// the new window size in pixels
	Variable winWidth= V_right-V_left	
	Variable winHeight= V_bottom-V_top
	
	// adjustment amounts in pixels
	Variable deltaWidth= winWidth - originalWinWidth
	Variable deltaHeight= winHeight - originalWinHeight
	
	String controls= ControlNameList(win)
	Variable i, n= ItemsInList(controls)
	for( i=0; i<n; i+=1 )
		String ctrlName= StringFromList(i,controls)
		
		if( !GetControlResizeInfo(win, ctrlName, resizeInfo) )
			continue
		endif
		
		Variable origLeft=resizeInfo.originalLeft
		Variable origTop=resizeInfo.originalTop
		Variable origWidth=resizeInfo.originalWidth
		Variable origHeight=resizeInfo.originalHeight
		
		Variable left= origLeft, top= origTop, width=origWidth, height= origHeight

		String leftAdjust= 		resizeInfo.leftMode
		String rightAdjust=		resizeInfo.rightMode

		String topAdjust= 		resizeInfo.topMode
		String bottomAdjust=	resizeInfo.bottomMode

		strswitch(leftAdjust)
			case ksFixedFromLeft:
				break
			case ksFixedFromRight:
				left += deltaWidth
				break
			case ksFixedFromMiddle:
				left += deltaWidth/2
				break
			default:	// user guide
				left +=GetGuideDelta(win,leftAdjust)
				break
		endswitch

		Variable right= origLeft + origWidth
		strswitch(rightAdjust)
			case ksFixedFromLeft:
				break
			case ksFixedFromRight:
				right += deltaWidth
				break
			case ksFixedFromMiddle:
				right += deltaWidth/2
				break
			default:	// user guide
				right +=GetGuideDelta(win,rightAdjust)
				break
		endswitch
		width = right-left
		
		strswitch(topAdjust)
			case ksFixedFromTop:
				break
			case ksFixedFromBottom:
				top += deltaHeight
				break
			case ksFixedFromCenter:
				top += deltaHeight/2
				break
			default:	// user guide
				top +=GetGuideDelta(win,topAdjust)
				break
		endswitch
		
		Variable bottom= origTop+origHeight
		strswitch(bottomAdjust)
			case ksFixedFromTop:
				break
			case ksFixedFromBottom:
				bottom += deltaHeight
				break
			case ksFixedFromCenter:
				bottom += deltaHeight/2
				break
			default:	// user guide
				bottom +=GetGuideDelta(win,bottomAdjust)
				break
		endswitch
		height= bottom-top
		
		Variable sizeChange= CmpStr(leftAdjust,rightAdjust) != 0 || CmpStr(topAdjust,bottomAdjust) != 0
		if( sizeChange )
			ModifyControl $ctrlName, win=$win, pos={left,top},size={width,height}
		else
			ModifyControl $ctrlName, win=$win, pos={left,top}
		endif
	endfor
	
	return 1
End

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif


Static Function ComputeNewPanelSize(panelName,minWidthPixels, maxWidthPixels, minHeightPixels, maxHeightPixels, neededWidthPoints, neededHeightPoints)
	String panelName
	Variable minWidthPixels, maxWidthPixels, minHeightPixels, maxHeightPixels
	Variable &neededWidthPoints, &neededHeightPoints	// outputs

	Variable resizeNeeded= 0
	DoWindow $panelName
	if( V_Flag )
		Variable minWidthPoints= minWidthPixels * PanelResolution(panelName)/ScreenResolution
		Variable maxWidthPoints= maxWidthPixels * PanelResolution(panelName)/ScreenResolution
		Variable minHeightPoints= minHeightPixels * PanelResolution(panelName)/ScreenResolution
		Variable maxHeightPoints= maxHeightPixels * PanelResolution(panelName)/ScreenResolution
		GetWindow $panelName wsize
		Variable widthPoints= V_right-V_left
		Variable heightPoints= V_bottom-V_top
		neededWidthPoints= min(max(widthPoints,minWidthPoints),maxWidthPoints)
		neededHeightPoints= min(max(heightPoints,minHeightPoints),maxHeightPoints)
		resizeNeeded= (neededWidthPoints != widthPoints) || (neededHeightPoints != heightPoints)
	endif
	return resizeNeeded
End

Static Function LimitPanelSize(panelName, minWidthPixels, maxWidthPixels, minHeightPixels, maxHeightPixels)
	String panelName
	Variable minWidthPixels, maxWidthPixels, minHeightPixels, maxHeightPixels

	Variable neededWidthPoints,neededHeightPoints
	Variable resizePending= ComputeNewPanelSize(panelName,minWidthPixels, maxWidthPixels, minHeightPixels, maxHeightPixels, neededWidthPoints, neededHeightPoints)
	if( resizePending )
		// Eventually: MoveWindow/W=$win V_left, V_top, V_left+neededWidthPoints, V_top+neededHeightPoints
		// To prevent SetPanelSize commands from piling up, we set a flag that the minimizer has been scheduled to run.
		// To avoid global variables, we use userdata on the window being resized.
		String setPanelSizeScheduledStr= GetUserData(panelName,"","setPanelSizeScheduled")	// "" if never set (means "no")
		if( strlen(setPanelSizeScheduledStr) == 0 )
			SetWindow $panelName, userdata(setPanelSizeScheduled)= "yes"
			String cmd
			String module= GetIndependentModuleName()+"#ResizeControls#"
			sprintf cmd, "%sSetPanelSize(\"%s\",%g,%g,%g,%g)", module, panelName, minWidthPixels, maxWidthPixels, minHeightPixels, maxHeightPixels
			Execute/P/Q cmd	// after the functions stop executing, the SetPanelSize's call to MoveWindow will provoke another resize event.
		endif
	endif
	return resizePending	
End

Static Function SetPanelSize(panelName,minWidthPixels, maxWidthPixels, minHeightPixels, maxHeightPixels)
	String panelName
	Variable minWidthPixels, maxWidthPixels, minHeightPixels, maxHeightPixels

	Variable resizeNeeded= 0
	DoWindow $panelName
	if( V_Flag )
		Variable neededWidthPoints,neededHeightPoints
		resizeNeeded= ComputeNewPanelSize(panelName,minWidthPixels, maxWidthPixels, minHeightPixels, maxHeightPixels, neededWidthPoints, neededHeightPoints)
		if( resizeNeeded )
			GetWindow $panelName wsize
			MoveWindow/W=$panelName V_left, V_top, V_left+neededWidthPoints, V_top+neededHeightPoints
		endif
		SetWindow $panelName, userdata(setPanelSizeScheduled)= ""	// allow another call to SetPanelSize().
	endif
	return resizeNeeded	
End

// This is the hook function for resizing controls in client panels.
// We also use it for the editing panel itself
Static Function ResizeControlsHook(hs)
	STRUCT WMWinHookStruct &hs

	Variable statusCode= 0
	String panelName= hs.winName
	
	strswitch(hs.eventName)
		case "activate":
		case "deactivate":
			SetWindow $panelName, userdata(setPanelSizeScheduled)= ""	// avoid locking out calls to SetPanelSize().
			break
		case "resize":
			// opposite of SetWindow $panelName userdata($ksResizeUserDataName)=userData
			STRUCT WMResizeInfo resizeInfo
			String userdata = GetUserData(panelName, "", ksResizeUserDataName)
			Variable resizePending= 0
			if( strlen(userdata) )
				StructGet/S resizeInfo, userdata
				Variable minWidth=resizeInfo.originalWidth	// pixels
				Variable minHeight=resizeInfo.originalHeight	// pixels
				Variable maxWidth= inf, maxHeight=inf
				
				if( resizeInfo.fixedWidth )
					maxWidth= minWidth
				endif
				if( resizeInfo.fixedHeight )
					maxHeight= minHeight
				endif
				resizePending= LimitPanelSize(panelName,minWidth, maxWidth, minHeight, maxHeight)
			endif
			if( !resizePending )	// don't bother adjusting controls if another resize event is pending
				String windows= ListOfChildWindows(panelName)
				Variable i, n= ItemsInList(windows)
				for(i=0; i<n; i+=1 )
					String win= StringFromList(i,windows)
					FitControlsToPanel(win)
				endfor
			endif
			// statusCode=1	// don't shortcircuit other hooks.
			break
	endswitch
	return statusCode
End

// only child windows that can contain controls.
Static Function/S ListOfChildWindows(hostWindow)
	String hostWindow

	String list= hostWindow+";"

	Variable type= WinType(hostWindow)
	if( (type == 1) || (type == 7) )	// list only panels and graphs
		String subwindows= ChildWindowList(hostWindow)
		Variable i, n= ItemsInList(subwindows)
		for(i=0; i<n; i+=1 )
			String subwindow= hostWindow+"#"+StringFromList(i,subwindows)
			type= WinType(subwindow)
			if( (type == 1) || (type == 7) )	// list only panels and graphs
				list += ListOfChildWindows(subwindow)
			endif
		endfor
	endif

	return list
End
