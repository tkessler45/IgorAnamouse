#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version = 1.201.04.14

//MODIFIED FROM THE JTG_EXPERIMENTPREVIEW PROJECT

//*****************************************************************************************************************//
//*****								JTG_ExperimentPreview							*****//
//*****************************************************************************************************************//
//	2013/04/12																			//
//	--Menu items appear under the Experiment Preview item added to the main File Menu.		//
//	--"Save Preview"  will copy open graph windows to a notebook; notebook will be named after 	//
//	  the experiment and saved in the same directory as the experiment.						//
//	--"View Preview" presents the user with a panel where notebooks residing on disk can be 		//
//	  quickly viewed.																		//
//*****************************************************************************************************************//

//*****************************************************************************************************************//
//*****									To Do										*****//
//*****************************************************************************************************************//
//	-- Button to open experiment file associated (by name) with the currently viewed notebook.	//
//	--Add set variable to enter match string to limit list of notebooks shown in listbox.				//
//*****************************************************************************************************************//
//*****									Other Ideas									*****//
//*****************************************************************************************************************//
//	-- Save a default Symbolic Path for the location of preview notebooks in the user's Igor 		//
//	  preferences folder.  The default could be the last used directory for viewing previews.			//
//*****************************************************************************************************************//
//*****									Completed									*****//
//*****************************************************************************************************************//
//	<Date Complete>																		//
//	--<Move To Do Items here when completed, add other comments as needed>				//
//*****************************************************************************************************************//

//*****************************************************************************************************************//
//*****					 Menus, Constants and Structures								*****//
//*****************************************************************************************************************//
Menu "File", dynamic
	"-"
	FileMenuItem(1),/Q, FileMenuFunc(1)
	FileMenuItem(2),/Q, FileMenuFunc(2)
End
	
Function/S FileMenuItem(num)
	variable num
	switch(num)
		case 1:
			if(getkeystate(0) & 2)
				return "Generate Preview"
			else
				return "Browse Previews /0"
			endif
		case 2:
			if(getkeystate(0) & 2)
				return "Check Previews"
			else
				return ""
			endif
	endswitch
end
	
Function FileMenuFunc(num)
	variable num
	GetLastUserMenuInfo
	
	switch(num)
		case 1:
			if(stringmatch(S_Value,"Generate Preview"))
				NBP_Save()
			else
				NBP_Panel_Create()
			endif
		case 2:
			if(stringmatch(S_Value,"Check Previews"))
				CheckPreviews()
			else
				//nothing
			endif
	endswitch
end
	
//Igor datafolder path used for package directory.  Directory will be specific to each GUI panel.  
//Multiple panels can be in use at the same time without interfering with one another.
Static StrConstant ksDFPath = "root:Packages:JTG:ExperimentPreview:"

//version pragma is not easily accessed; 
//this constant helps with that but must be kept synchronized with it
Static StrConstant ksVersion = "1.201.04.14"

//Path to default disk folder that provides list of files.  It is suggested that the path expression use the 
//Macintosh file system convention of employing a colon to separate elements in a file path. For example:
//The default path shown here points to the root directory on drive C.
//Future work could involve saving the last used directory to the user's Igor preferences folder
//Static StrConstant ksDefaultDataPath = "Macintosh HD:Users:Shared:Igor Previews"
Static Function/S DefaultDataPath()
	return ParseFilePath(0,SpecialDirPath("Temporary",2,0,0),":",0,0)+":Users:Shared:Igor Previews"
end

//Variable to control types of files appearing in file list box.  Set to "????" for any file type or limit with
//extension including the preceeding "." as in ".dat" for files with a "dat" extension.  Here we want to
//fine Igor formatted or unformatted notebook files.
Static StrConstant ksFileTypeOrExtension = "IGsU" //".pxp" //WMTO

Static StrConstant ksSymbolicPathNameStart = "NBP_Path_"

//*****************************************************************************************************************//
//*****						 End of Constants and Structures							*****//
//*****************************************************************************************************************//

//*****************************************************************************************************************//
//*****									NBP_Save									*****//
//*****************************************************************************************************************//
//	2013/04/12																			//
//	--Get list of all open graphs (doesn't get hidden graphs) and inserts them in a new notebook as	//
//	  pictures.  Saves the notebook to disk using the same name and disk location as the current	//
//	  experiment.  If the experiment has not yet been saved, the notebook is not created, instead	//
//	  a warning is printed to the history window requesting that the experiment be saved before	//
//	  creating the preview.	 Gets disk location of experiment from the special "home" Igor 			//
//	  Symbolic Path.																		//
//*****************************************************************************************************************//
//	--Called by:	"Save Preview" item in "Experiment Preview" menu (File Menu)					//
//	--Calls:		none																	//
//*****************************************************************************************************************//
Function  NBP_Save()

	SVAR UUID=root:S_UUID
	
	String sGraphList = ""
	String sGraphName = ""
	String sExperimentName = ""
	String sExperimentPath = ""
	String sNotebookName = ""
	String sMsg = ""
	String sNBtext = ""
	Variable vIndex
	
	sGraphList = WinList("*", ";", "WIN:1")
//check for empty string
	if( strlen( sGraphList ) == 0 )
		print "Preview not generated -- No graphs found."
		return 1	//failed
	endif
	
//name of current experiment
//if it is "Untitled", the experiment has not yet been saved; quit & request user first save experiment
	sExperimentName = IgorInfo(1)
	if( stringmatch( sExperimentName, "Untitled" ) == 1 )
		sMsg = "This experiment has not been saved.\r"  
		sMsg += "The preview notebook must be named after the experiment, "
		sMsg += "please save the experiment and then create the preview notebook."
		print sMsg
		return 1	//failed
	endif
//	print sExperimentName
	
//path to current experiment
//if the experiment is not named "Untitled", this should be valid, right?

	Newpath/C/O/Q previewPath, DefaultDataPath()

	PathInfo home	
	sExperimentPath = S_path
//	if( V_flag == 0 )	//path doesn't exist; this shouldn't happen given the previous check
//		sMsg = "This experiment has not been saved.\r"  
//		sMsg += "The preview notebook must be named after the experiment, "
//		sMsg += "please save the experiment and then create the preview notebook."
//		print sMsg
//	endif

//	print sExperimentPath
//get legal & unique name for preview notebook
	sNotebookName = CleanupName( sExperimentName, 0 )
	sNotebookName = UniqueName( sNotebookName, 10, 0 )
	
//create notebook
	NewNotebook /F=1 /K=0 /v=0 /N=$sNotebookName as sNotebookName

//Add some potentially helpful header text	
//Other items could be added here as well
	sNBtext = "Experiment Name: " + sExperimentName + "\r"
	sNBtext += "Experiment Path: " + sExperimentPath + "\r"
	sNBtext +=  "Save Date: " + Secs2Date(DateTime,0) + ", " + Secs2Time(DateTime,0) + "\r"
	Notebook $sNotebookName, fsize=24, text=sNBtext
	
//process graph list and add graphs to notebook
	vIndex = 0
	Do
		sGraphName = StringFromList( vIndex, sGraphList, ";" )
		if( strlen( sGraphName ) == 0 )
			break	//done
		endif
		Notebook $sNotebookName, picture={$sGraphName, -5, 1}
//		print sGraphName
		vIndex += 1
	While ( 1 )
	
//save the notebook
	SaveNotebook /O/P=previewPath /S=7  $sNotebookName as UUID + ".ifn"
	killwindow $sNotebookName
End
//*****************************************************************************************************************//
//*****							End of Function NBP_Save							*****//
//*****************************************************************************************************************//

//*****************************************************************************************************************//
//*****									NBP_View									*****//
//*****************************************************************************************************************//
//	2013/04/12																			//
//	--Open notebook selected from listbox and copy its content to the notebook subwindow in the	//
//	  panel.  Close selected notebook after copying the contents.								//
//*****************************************************************************************************************//
//	--Called by:	NBP_View																//
//	--Calls:		nonw																	//
//*****************************************************************************************************************//
Function  NBP_View(sPanelName, sFileName, sPath) 
	String sPanelName	//name of panel
	String sFileName		//name of notebook file to open
	String sPath	//name of Igor symbolic path to folder with notebook file sFileName
	
	String sNBwin = ""
	sNBwin = sPanelName + "#NB0"	//notebook subwindow in panel

//delete current contents of notebook subwindow in panel	
	String S_value = ""
	Notebook $sNBwin selection={startOfFile, endOfFile}
	Notebook $sNBwin setData=S_value
	Notebook $sNBwin magnification=3

//open selected notebook; if all goes well there will be no need for user to get involved;
//if there is a problem with the path or file name, Igor will present a standard OS file open dialog
	newpath/O/Q temppath, sPath
	OpenNotebook/Z /N=Preview /M="Open Notebook"/V=0 /R /T="WMT0"/P=temppath sFileName
	killpath/Z temppath
	if(!V_flag)
		Notebook $sNBwin magnification=50
		Notebook Preview getData=1	//get all content of notebook just opened
		Notebook $sNBwin setData=S_value	//save content in notebook subwindow on panel
		KillWindow Preview	//kill notebook just opened
	else
		Notebook $sNBwin setData="No Preview Available..."
	endif
End
//*****************************************************************************************************************//
//*****							End of Function NBP_View							*****//
//*****************************************************************************************************************//

//*****************************************************************************************************************//
//*****								NBP_Panel_Create								*****//
//*****************************************************************************************************************//
//	2013/04/13																			//
//	--Create panel for reviewing experiment preview notebooks.									//
//	--This will create a package data folder, variables and waves in that folder and a symbolic path	//
//	  needed by the preview functions.														//
//	--Sets hook function to close the panel and clean up.										//
//*****************************************************************************************************************//
//	--Called by:	"View Preview" item in "Experiment Preview" menu (File Menu)					//
//	--Calls:		NBP_Panel_GetFileList													//
//*****************************************************************************************************************//
Function  NBP_Panel_Create() 
	String sPanelName = "NBP_Panel"
	String sPanelTitle = ""			//title is same a s panel name
	String sPackageDataPath		//data folder for storing panel global variables
	String sWSWlistOptions
	String sMsg = ""
	
	Variable vRefHeight = 20
	
	dowindow/K $sPanelName
	
//get unique names for symbolic path and graph panel	
	//sPanelName = UniqueName(sPanelName, 9, 0 )	//panel
	sPackageDataPath = ksDFPath + sPanelName +":"
	sPanelTitle = sPanelName
	
//Create data folders to hold panel info; ksDFPath is string constant
//see top of procedure file for its value.  Folder has same name as panel name.
	CreateDFPath(ksDFPath, sPanelName)

//create global strings	
	Make /O /T /N=10 $(sPackageDataPath + "w") = ""
	Wave/T w = $(sPackageDataPath + "w")	//list wave for list box lbFiles
	String/G $(sPackageDataPath + "sPathToFiles") = ""	//string holding disk path to files displayed in listbox
	String/G  $(sPackageDataPath + "sSymbolicPathName") = ""	//string holding symbolic path name
//we need to access the following strings in this function
	SVAR sPathToFiles =  $(sPackageDataPath + "sPathToFiles")
	SVAR sSymbolicPathName =  $(sPackageDataPath + "sSymbolicPathName") 
		
	NewPanel  /K=1/N=$sPanelName/W=(60,50,1264,984)/K=1 as sPanelTitle		//K=1 kill with no dialog

//path selection
//	GroupBox gbPath frame=1, title="Path", pos={0,5}, size={504,43}
	SetVariable svPath,pos={106,24},size={454,16},proc=NBP_Panel_GetFileList,title="Path"
	SetVariable svPath,value= $(sPackageDataPath + "sPathToFiles") //PathToFiles
	Button btnSetPath,pos={8,22},size={90,20},proc=NBP_Panel_bpSetPath,title="Open Folder"
	Button btnSetPath, help={"Change disk path to search for files."}

//list box
	GroupBox groupListBox,pos={0,52},size={700,133},title="Notebooks"
	ListBox lbFiles disable=0, editStyle= 0, listWave= w, mode=1, pos={7,70}
	ListBox lbFiles size={246,750}, widths={200},proc=NBP_Panel_lbpFiles

//notebook
//	GroupBox groupNotebook,pos={0,188},size={504,446},title="Preview"
	NewNotebook/HOST=# /F=1 /N=nb0 /W=(260,70,1250,1050) // /W=(7,207,497,626)
	SetActiveSubwindow ##
	
//An Igor Symbolic Path unique to this panel will be created; if it already exists it will be overwritten
//In theory it should not preexist as the panel name will be unique and the path will be name after the
//panel.  The path will be killed when the panel is killed.
	sSymbolicPathName = ksSymbolicPathNameStart + sPanelName
//set symbolic path to default disk path (ksDefaultDataPath)
	
	PathInfo home
	if(V_flag)
		NewPath /O/Q $sSymbolicPathName, S_path
		sPathToFiles = S_path
	else
		NewPath /O/Q $sSymbolicPathName, DefaultDataPath()
		sPathToFiles = DefaultDataPath()
	endif

	NBP_Panel_GetFileList("",0,"","")

//set window hook for this panel; hook function is MultiFileLoadHook	
	SetWindow kwTopWin, hook(NBP_Panel_CleanUp )=NBP_Panel_Hook

End
//*****************************************************************************************************************//
//*****					End of Function NBP_Panel_Create								*****//
//*****************************************************************************************************************//

//*****************************************************************************************************************//
//*****								NBP_Panel_Hook								*****//
//*****************************************************************************************************************//
//	2013/04/14																			//
//	--Window hook function for NBP_Panel; cleans up when  the panel is closed.  Deletes 		//
//	  package folder and symbolic path.													  	//
//*****************************************************************************************************************//
//	--Called by:	NBP_Panel kill window event.												//
//	--Calls:		none																	//
//*****************************************************************************************************************//
Function NBP_Panel_Hook(s)
	STRUCT WMWinHookStruct &s
	
	Variable statusCode = 0
	
	String sPanelName
	String sDFName

	sPanelName = s.winName
	sDFName = ksDFPath + sPanelName + ":"
	SVAR sSymbolicPathName =  $(sDFName + "sSymbolicPathName") 

	if(s.eventCode == 2)	//kill window: clean up
		KillPath /Z $sSymbolicPathName	//kill symbolic path unique to this panel
		KillDataFolder $sDFName

		statusCode = 0
	endif
	
	return statusCode // 0 if nothing done, else 1
End
//*****************************************************************************************************************//
//*****						End of Function NBP_Panel_Hook							*****//
//*****************************************************************************************************************//

//****************************************************************************************************************//
//*****								NBP_Panel_bpSetPath							*****//
//*****************************************************************************************************************//
//	2013/04/14																			//
//	--Based on function from multi file loader: Called by Set Path button on panel.  Opens dialog 	//
//	  to select new symbolic path to directory containing files to load.  Then calls routine to get all 	//
//	  files from that directory and load into wave w for display in the list box.						//
//	--Change to use WMButtonAction input structure.										//
//*****************************************************************************************************************//
//	--Called by:	btnSetPath on panel														//
//	--Calls:		NBP_Panel_GetFileList													//
//*****************************************************************************************************************//
Function NBP_Panel_bpSetPath(str_BA)
	Struct WMButtonAction &str_BA

	String sMsg
	String sPanelName
	String sDataLocation
	
//string and waves associated with this panel instance are located in a data folder named 
//after the panel name 
	sPanelName = str_BA.win
	sDataLocation = ksDFPath + sPanelName + ":"
	SVAR sPathToFiles = $(sDataLocation + "sPathToFiles")
	SVAR sSymbolicPathName =  $(sDataLocation + "sSymbolicPathName") 

//only respond to specific control
	if(stringmatch(str_BA.ctrlName, "btnSetPath") != 1)
		return 0
	endif
	
	switch (str_BA.eventCode)
		case 2:	//mouse up	
			sMsg = "Browse To The File Location..."
			NewPath /M=sMsg /O/Q $sSymbolicPathName
			if(V_flag != 0)		//user hit cancel
				return 0
			endif
			
			PathInfo  $sSymbolicPathName
			if(V_flag == 0)	//path doesn't exist
				return 0
			endif
		
		//update path variable; S_path is variable created by PathInfo operation
			sPathToFiles = S_path
			
		//fill listbox with files from new path
			NBP_Panel_GetFileList("",0,"","")
			break
	endswitch
	return 0
End 
//*****************************************************************************************************************//
//*****					End of Function NBP_Panel_bpSetPath							*****//
//*****************************************************************************************************************//

//*****************************************************************************************************************//
//*****								NBP_Panel_GetFileList							*****//
//*****************************************************************************************************************//
//	2013/04/14																			//
//	--Get list of files from current path sSymbolicPathName, redimension waves used to hold        	//
//	  file names and list box attributes.                                                                                    	//
//	--This will automatically put new list into listbox.                                                                 	//
//*****************************************************************************************************************//
//	--Called by:	NBP_Panel_Create														//
//				NBP_Panel_bpSetPath													//
//	--Calls:		none																	//
//*****************************************************************************************************************//
Function NBP_Panel_GetFileList(ctrlName,varNum,varStr,varName)
	String ctrlName
	Variable varNum	// value of variable as number
	String varStr		// value of variable as string
	String varName	// name of variable

	String sPanelName
	String sDataLocation
	String sFileList
	Variable vNumFiles
	
//String and waves associated with this panel instance are located in a data folder named 
//after the panel name.
	sPanelName = WinName(0, 64)	//name of top panel
	sDataLocation = ksDFPath + sPanelName + ":"
	SVAR sSymbolicPathName =  $(sDataLocation + "sSymbolicPathName") 
	
	Wave/T w = $(sDataLocation + "w")
	

//Get list of files in the folder pointed to by the symbolic path sSymbolicPathName; this list is limited by file type or
//extension stored in string constant ksFileTypeOrExtension.  If no files are found matching the specification, 
//IndexedFile returns and empty string "".  
	sFileList = IndexedFile($sSymbolicPathName, -1, ksFileTypeOrExtension)
 
//Sort list of files before storing in file name wave w
//16: case-insensitive alphanumeric sort that sorts wave0 and wave9 before wave10.
	sFileList = SortList(sFileList, ";", 16)
	vNumFiles = itemsinlist(sFileList, ";")

//Redimension waves used for file list and selection of files in list to match number of entries in FileList.
	Redimension /N=(vNumFiles) w
	w[] = StringFromList(p, sFileList, ";")		//store list of file names in w
	
End
//*****************************************************************************************************************//
//*****					End of Function NBP_Panel_GetFileList							*****//
//*****************************************************************************************************************//

//*****************************************************************************************************************//
//*****								NBP_Panel_lbpFiles								*****//
//*****************************************************************************************************************//
//	2013/04/14																			//
//	--Action procedure for lbFiles list box.  Responds to mouse click (mouse up) event.  If an item	//
//	  in the box had been clicked on (selected) NBP_View will be called to open the selected		//
//	  notebook file and load its contents into the notebook embedded in the panel.				//
//*****************************************************************************************************************//
//	--Called by:	lbFiles list box mouse up event												//
//	--Calls:		NBP_View																//
//*****************************************************************************************************************//
Function  NBP_Panel_lbpFiles(str_LBA) 
	STRUCT WMListboxAction &str_LBA
	
	Wave/T w = str_LBA.listWave
	Variable vSelectedRow
	String sPackageDataPath = ""
	String sFileWithPath = ""
	
	sPackageDataPath = ksDFPath + str_LBA.win +":"

	SVAR sPathToFiles = $(sPackageDataPath + "sPathToFiles")
	SVAR sSymbolicPathName =  $(sPackageDataPath + "sSymbolicPathName") 

	switch (str_LBA.eventcode)
		case 4:	//mouse up
			ControlInfo /W=$str_LBA.win $str_LBA.ctrlname
		//vSelectedRow = number of row in list box that was clicked; 
		//corresponds to point in list wave containing entry that was selected
			vSelectedRow = V_value
			if( vSelectedRow < 0 )	//no selection
				print "No selection for Notebook listbox."
				return 0
			endif
			//get UUID
			sFileWithPath = sPathToFiles + w[vSelectedRow]
//			GetExpUUID(sFileWithPath)
			//NBP_View(str_LBA.win,  w[vSelectedRow], sSymbolicPathName) 
			if(strlen(GetExpUUID(sFileWithPath)))
				NBP_View(str_LBA.win,  GetExpUUID(sFileWithPath)+".ifn", DefaultDataPath())
			else
				NBP_View(str_LBA.win,  "", DefaultDataPath()) //pass empty file name to clear view...
			endif
			break
		case 3:
//			print sPathToFiles+w[str_LBA.row]
//			print "open -R "+"/"+replacestring(" ",replacestring(":",removelistitem(0,sPathToFiles,":"),"/")+w[str_LBA.row],"\\ ")
//			print "open -R "+"'/"+replacestring(":",removelistitem(0,sPathToFiles,":"),"/")+w[str_LBA.row]+"'"
			string cmd
			if(getkeystate(0) & 2) //option key
				cmd="open -R "+"\\\"/"+replacestring(":",removelistitem(0,sPathToFiles+w[str_LBA.row],":"),"/")+"\\\""
			else
				cmd="open "+"\\\"/"+replacestring(":",removelistitem(0,sPathToFiles+w[str_LBA.row],":"),"/")+"\\\""
				dowindow/K $str_LBA.win
			endif
//			print cmd
			doshell(cmd)
			break
	endswitch	
	return 0
End
//*****************************************************************************************************************//
//*****					End of Function NBP_Panel_lbpFiles							*****//
//*****************************************************************************************************************//

//*****************************************************************************************************************//
//*****							Static Function CreateDFPath							*****//
//*****************************************************************************************************************//
//	2013/04/14																			//
//	--Standard function used to created a new data folder and the path to it if it does not exist.		//
//	  Function is declared as static in case it exists in other open procedure files.				//
//*****************************************************************************************************************//
//	--Called by:	NBP_Panel_Create														//
//	--Calls:		none																	//
//*****************************************************************************************************************//
Static Function CreateDFPath(sFullDFPath, sNewDF)
	String sFullDFPath
	String sNewDF
	
	String sEntireDFPath	//path plus new folder
	Variable incr
	String sPathElement = ""
	String sPartialPath = ""
	String sPathChar = ""
	sEntireDFPath = sFullDFPath + sNewDF
//check that path and folder strings aren't empty
	if((strlen(sFullDFPath) == 0) || (strlen(sNewDF) == 0 ) == 1)
		DoAlert 0, "Missing Data Folder Path... check string constant at start of procedure."
		return 0
	endif
	
//Does path already exist?
//then check for its existence, if it alrealdy exists, alert user and return success
	If(DataFolderExists(sEntireDFPath))
		//print "Path already exists: ", sEntireDFPath
		return 1
	EndIf

//Are there any ":" at front?
	Do
		sPathChar = sEntireDFPath[0]
		if(stringmatch(sPathChar, ":") == 0)
			break
		endif
		sPartialPath += ":"
		sEntireDFPath = sEntireDFPath[1, inf]
	While(1)
	
	incr = 0	
//if the first part of the path is "root:", this is a special case.  It always exists and we don't
//need to create it, so skip over it.
//break path at folders and work with each part of the path
	sPathElement = StringFromList(incr, sEntireDFPath, ":")
	If(stringmatch(sPathElement, "root"))
		sPartialPath = "root:"
		incr += 1
	EndIf
			
	
	Do
//break path at folders and work with each part of the path
		sPathElement = StringFromList(incr, sEntireDFPath, ":")
//exit loop when we encounter a null string, this usually means that all elements of loop 
//have been processed
		If(!strlen(sPathElement))
			break
		EndIf
		sPartialPath += sPathElement
//		print "creating: ", sPartialPath
		NewDataFolder/O $sPartialPath
		
//need ":" to separate path elements, but NewDataFolder doesn't like this on the end of a path
//string, so we append it here.
		sPartialPath +=  ":"

		incr += 1
	While(1)
	return 1
	
End
//*****************************************************************************************************************//
//*****								End of  CreateDFPath								*****//
//*****************************************************************************************************************//

Function CheckPreviews()
	NewPath/O/Q/Z tempPath, "Macintosh HD:Users:Shared:Igor Previews"
//	get list of previews in /Users/Shared/Igor Previews
	string fileList=IndexedFile(tempPath,-1,"WMTO")//.ifn")
	string nothere=""
//	Iterate through list
	variable i
	print "Checking unlinked Previews..."
	print "     Preview folder: /Users/Shared/Igor Previews"
	for(i=0;i<itemsinlist(fileList);i+=1)
		openNotebook /k=1 /n=tempNotebook /R /V=0 /Z /P=tempPath stringfromlist(i,fileList)
		Notebook tempNotebook, selection={startOfFile,endOfNextParagraph}
		GetSelection notebook, tempNotebook, 2
		killwindow tempNotebook
		string path=stringbykey("Experiment Path", ReplaceString("\r", S_selection, ";"),": ",";")
		string file=stringbykey("Experiment Name", ReplaceString("\r", S_selection, ";"),": ",";")
		path=path[1,strlen(path)]
		file=file[1,strlen(file)]+".pxp"
		if(PXPMissing(path,file))
			print "     --> "+path+file
			print "            Preview file: "+stringfromlist(i,fileList)
			nothere+=stringfromlist(i,fileList)+";"
		endif
	endfor
	if(itemsinlist(nothere)==0)
		print "      ...No unlinked previews found."
	else
		print "     "+num2str(itemsinlist(nothere))+" unlinked previews found."
		print "     NOTE: These files or their paths may have simply been moved or renamed. If so, then open and re-save them to re-link the preview."
	endif
	killpath tempPath
	return 0
End

Function PXPMissing(path,file)
	string path
	string file
	newpath/O/Q/Z tempFindPath, path
	PathInfo tempFindPath
	if(V_Flag)
		string fileList=IndexedFile(tempFindPath,-1,"IGsU")//.pxp")
	else
		Print "     *****Path-based problem with this next file*****"
		return 1
	endif
	killpath tempFindPath
	if(findlistitem(file,fileList,";")>=0)
		return 0
	else
		return 1
	endif
end
