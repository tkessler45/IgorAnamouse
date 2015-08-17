#pragma rtGlobals=1		// Use modern global access method.

Menu "Panels"
	//Submenu "   || AnaMouse ||"
		PanelMenuItem(1), /Q, DoWindow/F Summary
		PanelMenuItem(2), /Q, DoWindow/F ExperimentNotes
	//end
end

Function/S PanelMenuItem(num)
	variable num
	if(num==1)
		DoWindow Summary
		if(V_Flag)
			return "Summary"
		else
			return "(Summary"
		endif
	endif
	
	if(num==2)
		DoWindow ExperimentNotes
		if(V_Flag)
			return "Experiment Notes"
		else
			return "(Experiment Notes"
		endif
	endif
end

Menu "TracePopup", dynamic //"AllTracesPopup"
	"-"
//	TraceMenuItem(1), /Q , RenameGraphWave(1) //"Rename Wave", RenameGraphWave(1)
	"("+TraceMenuItem(3)//"Append trace to..."
		"   Rename...", /Q, RenameGraphWave(1) //"Rename Wave", RenameGraphWave(1)
		"   Display as-is...", /Q , DisplayTracename()
		Submenu "   Append to..."
			TraceMenuItem(2), /Q , AppendTracename(3)
		end
		Submenu "   Move to..."
			TraceMenuItem(2), /Q , AppendTracename(1)
		end
		Submenu "   Copy to..."
			TraceMenuItem(2), /Q , AppendTracename(2)
		end
	//end
	"-"
	TraceMenuItem(1), GetThreshValues()
End

Menu "New", dynamic
	"-"
end

Menu "Analysis"
	"-"
	"Spanned Average", SpannedAverage()
End

Function/S TraceMenuItem(num)
	variable num
	getlastusermenuinfo
	string namestr=TraceNameList("",";",3) //3 = omit hidden traces
	if(num==1)
		if(!grepstring(namestr,"zero"))
			return "Setup Threshold"
		else
			return "Get Threshold Crossings"
		endif
	endif
	if(num==2)
		return "(Choose graph...;"+removefromlist(stringfromlist(0,WinList("*", ";", "WIN: 1" )),WinList("*", ";", "WIN: 1" ))+";<INew Graph;-;(Choose table...;"+WinList("*", ";", "WIN: 2" )+";<INew Table"
	endif
	if(num==3)
		return "Manage "+S_traceName
	endif
end


//**********************
// Igor Hooks, starters, and setup functions

Function/S ExecuteUnixShellCommand(uCommand, printCommandInHistory, printResultInHistory)
	String uCommand				// Unix command to execute
	Variable printCommandInHistory
	Variable printResultInHistory

	if (printCommandInHistory)
		printf "Unix command: %s\r", uCommand
	endif

	String cmd
	sprintf cmd, "do shell script \"%s\"", uCommand
	ExecuteScriptText/B/Z cmd

	if (printResultInHistory)
		Print S_value
	endif

	return S_value
End

Function IgorStartOrNewHook(igorApplicationNameStr)
	String igorApplicationNameStr
	BrowserSetup()
	CommandSetup()
	//SVAR/Z UUID=root:S_UUID
	//if(!SVAR_exists(UUID))
//		DFR saveDFR = getdatafolderdfr()
//		setdatafolder root:
		//string/g root:S_UUID=doshell("uuidgen")
//		setdatafolder saveDFR
	//endif
//	ExecuteUnixShellCommand("caffeinate", 1, 1)
	if(findlistitem("ExperimentNotes",winlist("*", ";", "WIN:16"),";")<0)
		NewNotebook /F=0/N=ExperimentNotes as "Experiment Notes"
	endif
end

Function AfterFileOpenHook(refNum, fileNameStr,pathNameStr,fileTypeStr,fileCreatorStr,fileKind)
	Variable refNum, fileKind
	String fileNameStr, pathNameStr, fileTypeStr, fileCreatorStr
	BrowserSetup()
	SVAR/Z UUID=root:S_UUID
	if(!SVAR_exists(UUID))
//		DFR saveDFR = getdatafolderdfr()
//		setdatafolder root:
		string/g root:S_UUID=doshell("uuidgen")
//		setdatafolder saveDFR
	endif
	if(findlistitem("ExperimentNotes",winlist("*", ";", "WIN:16"),";")<0)
		NewNotebook /F=0/N=ExperimentNotes as "Experiment Notes"
	endif
end

Function BeforeExperimentSaveHook(refNum,fileNameStr,pathNameStr,fileTypeStr,fileCreatorStr,fileKind)
	Variable refNum, fileKind
	String fileNameStr, pathNameStr, fileTypeStr, fileCreatorStr
	SVAR/Z UUID=root:S_UUID
	if(!SVAR_exists(UUID))
//		DFR saveDFR = getdatafolderdfr()
//		setdatafolder root:
		string/g root:S_UUID=doshell("uuidgen")
//		setdatafolder saveDFR
	endif
	NBP_Save()
	SummaryPDF()
//	string sPanelName = "NBP_Panel"
//	killwindow $sPanelName
end

Function AfterWindowCreatedHook(winNameStr, type)
	string winNameStr
	variable type
//	print type
	if(type==1) //graph
		SetWindow $winNameStr hook=GraphContextual, hookevents=1
	endif
	if(type==2) //table
		SetWindow $winNameStr hook=TableContextual, hookevents=1
	endif
end

Function BrowserSetup()
	execute "CreateBrowser"
	execute "ModifyBrowser appendUserButton={'Move...',\"MoveSelected()\"}"
	execute "ModifyBrowser appendUserButton={'Batch Rename...',\"RenameSelected()\"}"
	execute "ModifyBrowser appendUserButton={'Display...',\"DisplaySelected()\"}"
	execute "ModifyBrowser appendUserButton={'Average...',\"AverageSelected()\"}"
	execute "ModifyBrowser echoCommands=0"
end

Function CommandSetup()
	MoveWindow/C 2,900,700,1170
End

//SetWindow kwTopWin hook=GraphContextual, hookevents=1	// mouse down events
Function TableContextual(infoStr)
	String infoStr
//	strswitch(StringByKey("EVENT",infoStr))
//		case "mousedown":
//			if(!(numberbykey("MODIFIERS",infoStr) & 0x16))
//				PopupContextualMenu/C=(NumberByKey("MOUSEX",infoStr), NumberByKey("MOUSEY",infoStr)) "Disable Menu For This Graph;----------;Average All Graph Traves;Trace Values at Cursor \"A\";Min Trace Values Between Cursors;Adjust Baselines to Zero;DC Correct Traces;Splay Traces;Concatenate Waves;"
//				strswitch(S_selection)
//					case "Average All Graph Traves":
//						AverageGraphTraces(1)
//						break;
//					case "Concatenate Waves":
//						ConcatWaves()
//						break;
//					case "Splay Traces":
//						SplayTraces()
//						break;
//					case "Adjust Baselines to Zero":
//						ZeroBaseline(1)
//						break;
//					case "DC Correct Traces":
//						DCCorrectTraces()
//						break;
//					case "Trace Values at Cursor \"A\"":
//						ValuesAtX()
//						break;
//					case "Min Trace Values Between Cursors":
//						MinValuesBetwCurs()
//						break;
//					case "Disable Menu For This Graph":
//						SetWindow kwTopWin hook=$""
//						// do something because "maybe" was chosen
//						break;
//				endswitch
//			endif
//	endswitch
	return 0
End

Menu "GraphContextualMenu", contextualmenu, dynamic
	"Disable Menu For This Graph/1", SetWindow kwTopWin hook=$""
	"-"
//	Submenu "Create"
	"Create ("
	"   Average All Graph Traces", AverageGraphTraces(1)
	"   Concatenate Waves;",ConcatWaves()
	"   Display Trace Range", DisplayRange()
//	end
	"-"
//	Submenu "Measure"
	"Measure ("
	"   Trace Values at Cursor \"A\"", ValuesAtX()
	"   Min Trace Values Between Cursors", MinValuesBetwCurs()
//	end
	"-"
//	Submenu "Adjust"
	"Adjust ("
	"   Subtract Base Wave", SubtractBaseWave()
	"   Adjust Baselines to Zero", ZeroBaseline(1)
	"   DC Correct Traces", DCCorrectTraces()
	Submenu "   Manage Offsets"
	"Fix Offsets only", FixAllOffsets()
	"Fix Offsets and Pad Traces", FixAndPad()
	"-"
	"Undo Offsets", UndoAllOffsets()
	end
	"   Scale Waves", TraceScaling()
	"   Change Wave Unit Labels", ChangeGraphUnitLabels()
	"   Switch point to NAN", NanPointSwitch()
//	end
	"-"
//	Submenu "Visual"
	"Visual ("
	"   Splay Traces", SplayTraces()
	"   Highlight Traces", TraceHighlight()
//	end
End

//SetWindow kwTopWin hook=GraphContextual, hookevents=1	// mouse down events
Function GraphContextual(infoStr)
	String infoStr
	strswitch(StringByKey("EVENT",infoStr))
		case "mousedown":
			if(!(numberbykey("MODIFIERS",infoStr) & 0x16))
				PopupContextualMenu/C=(NumberByKey("MOUSEX",infoStr), NumberByKey("MOUSEY",infoStr))/N "GraphContextualMenu"
			endif
	endswitch
	return 0
End
	
//**********************
// Window management functions

Function killchildwindow(winNameStr)
	string winNameStr
	variable i, j
	string winhostlist=winlist("*",";","WIN:1")
	string childwinlist
	for(i=0;i<itemsinlist(winhostlist);i+=1)
		childwinlist=ChildWindowList(stringfromlist(i,winhostlist))
		for(j=0;j<itemsinlist(childwinlist);j+=1)
			if(stringmatch(stringfromlist(j,childwinlist),winNameStr))
				killwindow $(stringfromlist(i,winhostlist))#$(stringfromlist(j,childwinlist))
			endif
		endfor
	endfor
end
	
//**********************
// Graph window functions

Function DisplayRange([graph,num1, skip,num2])
	string graph
	variable num1
	variable skip
	variable num2
	//GetLastUserMenuInfo
	//DoWindow/F kwTopWin
//	if(stringmatch(graph,""))
		graph=WinName(0,1)
//	endif
	string traces=tracenamelist(graph,";",1)
	if(num1==0 && num2==0)
		num1=0
		num2=itemsinlist(traces)-1
		prompt num1, "Enter beginning trace number:"
		prompt skip, "Skip every n traces:"
		prompt num2, "Enter final trace number:"
		DoPrompt "Display the last traces of "+graph, num1,skip,num2
	endif
	
	if(!V_flag)
		if(num1>num2)
			abort "The first number must be less than or equal to the last number"
		elseif(num1>itemsinlist(traces)-1 || num2>itemsinlist(traces)-1)
			abort "The numbers must be between 0 and "+num2str(itemsinlist(traces)-1)
		elseif(num1<0 || num2<0)
			abort "The numbers must be positive"
		else
			variable i
			getwindow/Z kwTopWin wsize
			display/N=$(graph+"_range")/W=(V_left+20,V_top+20,V_right+20,V_bottom+20)
			for(i=num1;i<=num2;i+=(1+skip))
				WAVE wavenm=tracenametowaveref(graph,stringfromlist(i,traces))
				appendtograph wavenm
			endfor
		endif
	endif
end

Function/WAVE MinValuesBetwCurs([graph,ax,bx, bin])
	string graph
	variable ax
	variable bx
	variable bin
//	variable x1, x2
	string namestr
	string printnm
	variable i
	
	if(numtype(strlen(graph))==2)
		namestr=TraceNameList("",";",3) //3 = omit hidden traces
		printnm=WinName(0,1,1,0)
	else
		namestr=TraceNameList(graph,";",3) //3 = omit hidden traces
		printnm=graph
	endif
	
	make/o/n=(itemsinlist(namestr)) W_Values
	
	if(strlen(csrinfo(A)) && strlen(csrinfo(B)))
		ax = xcsr(A) > xcsr(B) ? xcsr(B) : xcsr(A)
		bx = xcsr(A) > xcsr(B) ? xcsr(A) : xcsr(B)
	else
		Print "Error: Place cursors A and B on graph"
		killwaves W_Values
		Return W_Values
	endif
	
	bin=abs(ax-bx)*.05
//	if(numtype(bin)==2)
		prompt bin, "Bin Size:"
//	endif
	
	prompt ax, "Enter first point (x values in "+waveunits(tracenametowaveref("",stringfromlist(0,namestr)),0)+"):"
	prompt bx, "Enter second point (x values in "+waveunits(tracenametowaveref("",stringfromlist(0,namestr)),0)+"):"
	doprompt "Setup", ax, bx, bin
	
	if(!V_Flag)
		namestr[strlen(namestr)-1,strlen(namestr)]=""
	
		for(i=0;i<itemsinlist(namestr, ";");i+=1)
			wave wavenm=tracenametowaveref("",stringfromlist(i,namestr)) //root:$stringfromlist(i,namestr)
			WaveStats/Q/R = (ax, bx )/Z wavenm
			W_Values[i]=mean(wavenm,ax-bin/2,bx+bin/2)
			//print nameofwave(wavenm)+" at x="+num2str(x)+" is "+num2str(mean(wavenm,x-bin,x+bin))
		endfor
	
		Print "Values for graph "+ printnm// +" at "+num2str(x-bin/2)+" to "+num2str(x+bin/2)
		Print "stored in W_Values"
		Return W_Values
	endif
end

Function/WAVE ValuesAtX([graph,x,bin])
	string graph
	variable x
	variable bin
	variable normalize=2
	variable i
	string namestr
	string printnm
	string valuesName="W_Values"
	
	if(numtype(strlen(graph))==2)
		namestr=TraceNameList("",";",3) //3 = omit hidden traces
		printnm=WinName(0,1,1,0)
	else
		namestr=TraceNameList(graph,";",3) //3 = omit hidden traces
		printnm=graph
	endif
	
//	WAVE W_Values=$W_Values
	
	if(strlen(csrinfo(A)))
		x=xcsr(A)
	else
		Abort "Error: Place cursor A on graph"
	endif
	
	if(strlen(csrinfo(B)))
		bin=abs((xcsr(B)-xcsr(A))*2)
	else
		bin=10*deltax(tracenametowaveref("",stringfromlist(0,namestr)))
	endif
	
	getaxis/q bottom
	
//	bin = bin > (xcsr(A)-V_min) ? xcsr(A) : bin
//		startx = xcsr(A) > xcsr(B) ? xcsr(B) : xcsr(A)
//		endx = xcsr(A) > xcsr(B) ? xcsr(A) : xcsr(B)
	
	prompt x, "Enter center point:"
	prompt bin, "Enter bin size (x values in "+waveunits(tracenametowaveref("",stringfromlist(0,namestr)),0)+"):"
	prompt valuesName, "Enter name of output wave:"
	prompt normalize, "Normalize at point?",popup, "Yes;No"
	doprompt "Setup",x,bin,valuesName,normalize
	
	if(!V_Flag)
		make/o/n=(itemsinlist(namestr)) $valuesName
		wave output=$valuesName
		
		namestr[strlen(namestr)-1,strlen(namestr)]=""
	
		for(i=0;i<itemsinlist(namestr, ";");i+=1)
			wave wavenm=tracenametowaveref("",stringfromlist(i,namestr)) //root:$stringfromlist(i,namestr)
			output[i]=mean(wavenm,x-bin/2,x+bin/2)
			if(normalize==1 || getkeystate(0) & 2)
				wavenm/=output[i]
				setnote(wavenm,"Scaling Factor",fullnum2Str(output[i])) //Scaling Factor used 
			endif
			//print nameofwave(wavenm)+" at x="+num2str(x)+" is "+num2str(mean(wavenm,x-bin,x+bin))
		endfor
	
		Print "Values for graph "+ printnm +" at "+num2str(x-bin/2)+" to "+num2str(x+bin/2)
		Print "stored in "+valuesName
		Return output
	endif
end

Function DCCorrectTraces([x1,x2,bin])
	variable x1
	variable x2
	variable bin
	variable finalBin
	variable binflag=0
	string namestr=TraceNameList("",";",3) //3 = omit hidden traces
	namestr[strlen(namestr)-1,strlen(namestr)]=""
	variable i
	variable pointslope
	variable revert//=2
	
	string prevslope
	
	for(i=0;i<itemsinlist(namestr, ";");i+=1)
		WAVE wavenm = tracenametowaveref("",stringfromlist(i,namestr)) //root:$stringfromlist(i,namestr)
		prevslope=getnote(wavenm,"Slope Adjustment")	
		prompt revert, "Adjustment detected for "+nameofwave(wavenm)+". Revert?",popup,"yes;no;yes for all"
		if(!stringmatch(prevslope,"") && revert!=3)
			doprompt "Adjust Slope", revert
		endif
		if(V_flag)
			return 1
		endif
		if(revert>=1)
			pointslope=str2num(getnote(wavenm,"Slope Adjustment"))*-1
			dccorrect(wavenm, pointslope,0.001)
			SetNote(wavenm,"Slope Adjustment","")
		else
			if(strlen(csrinfo(A)) && strlen(csrinfo(B)))
				x1=pnt2x(wavenm,pcsr(A))
				x2=pnt2x(wavenm,pcsr(B))
				if(binflag==0)
					prompt bin, "Enter bin percent size (0-1):"
					doprompt "Values", bin
					binflag=1
				endif
			elseif(paramisdefault(x1) && paramisdefault(x2))
				prompt x1, "Enter first x value:"
				prompt x2, "Enter second x value:"
				prompt bin, "Enter bin percent size (0-1):"
				doprompt "X-values", x1, x2, bin
				if(V_flag)
					return 1
				endif
			endif
			finalBin=(x2-x1)*bin
			pointslope=(mean(wavenm, x2-bin,x2+finalBin)-mean(wavenm, x1-bin,x1+finalBin))/(x2pnt(wavenm, x2)-x2pnt(wavenm, x1))
			//pointslope=(wavenm[x2pnt(wavenm, x2-bin)]-wavenm[x2pnt(wavenm, x1)])/(x2pnt(wavenm, x2)-x2pnt(wavenm, x1))
			dccorrect(wavenm, pointslope,0.001)
		endif
//		print nameofwave(wavenm)+" adjusted by "+num2str(pointslope)
	endfor
end

Function DisplayTracename()
	GetLastUserMenuInfo
	//get recreation string
	//traceinfo("","test",0)[0,strsearch(traceinfo("","S_traceName",0),"RECREATION",0)]
	//string tracerec=StringByKey("RECREATION",traceinfo("","test",0)[strsearch(traceinfo("","test",0),"RECREATION",0),strlen(traceinfo("","test",0))],":"," ")
	
	string traceRec=StringByKey("RECREATION", replacestring(";",traceinfo("",S_traceName,0),"?",0,9),":","?")
	string exstr=StringByKey("ERRORBARS", replacestring(";",traceinfo("",S_traceName,0),"?",0,9),":","?")
	WAVE xwave=$(StringByKey("XWAVEDF", replacestring(";",traceinfo("",S_traceName,0),"?",0,9),":","?")+StringByKey("XWAVE", replacestring(";",traceinfo("",S_traceName,0),"?",0,9),":","?"))
	
	if(waveexists(xwave))
		Display TraceNameToWaveRef("",S_traceName) vs xwave
	else
		Display TraceNameToWaveRef("",S_traceName)
	endif
	//apply recreation

//	string winrec=WinRecreation("",0)	
//	for(i=0;i<itemsinlist(winrec,"\r");i+=1)
//		exstr=stringfromlist(i,winrec,"\r")
//		if(strsearch(exstr,"ErrorBars",0)>=0)
//			if (strsearch(exstr, S_traceName+" ", 0) >= 0) // space prevents finding trace "wave0x" when you ask for "wave0"
//				Execute exstr
//			endif
//		endif
//	endfor
	Execute exstr
	
	variable i
	for(i=0;i<itemsinlist(tracerec);i+=1)
		exstr=replacestring("(x)",stringfromlist(i,tracerec),"("+S_traceName+")")
		//do not include offset values
		if(!grepstring(exstr,"offset"))
			Execute "ModifyGraph "+exstr
		endif
	endfor
end

Function AppendTracename(action)
	variable action//1=move, 2=copy, 3=append(default)
	GetLastUserMenuInfo
//	Print S_traceName //the current trace...
//	Print S_value //menu selected item (new graph)
//	Print S_graphName //current graph
	
	WAVE/Z wavenm=$S_traceName
	
	strswitch(S_Value)
		case "New Graph":
			display
			S_value=""
			break
		case "New Table":
			edit
			S_value=""
			break
	endswitch
	
	if(action==2)
		duplicate/o wavenm $(nameofwave(wavenm)+"_copy")
		string name=nameofwave(wavenm)
		WAVE/Z wavenm=$(name+"_copy")
	endif
	if(wintype(S_value)==1)
		AppendToGraph/W=$S_value wavenm
		if(action==1)
			RemoveFromGraph/Z/W=$S_graphName $S_traceName
		endif
	elseif(wintype(S_value)==2)
		AppendToTable/W=$S_value wavenm
		if(action==1)
			RemoveFromGraph/Z/W=$S_graphName $S_traceName
		endif
	endif
end

Function RenameGraphWave(fromMenu)
	variable fromMenu
	
	GetLastUserMenuInfo
	
	string namestr=TraceNameList("",";",3) //3 = omit hidden traces
	string renameWave=S_traceName
	string name=S_traceName+"_new"
	string prevname=getnote(tracenametowaveref("",S_traceName),"Previous Name")
	variable revert=1
	prompt renameWave,"Select graph wave:", popup,namestr
	prompt name,"New name:"
	prompt revert, "Previous name \""+prevname+"\" detected. Revert?",popup,"no;yes"
	if(stringmatch(prevname,""))
		doprompt "Rename Waves",renamewave,name
	else
		doprompt "Rename Waves",revert,renamewave,name
	endif
	
	if(!V_flag)
		WAVE wavenm=tracenametowaveref("",renameWave)
		if(revert==2)
			rename wavenm $prevname
			SetNote(wavenm, "Previous Name", "")
			Print "Renamed",renameWave,"to",prevname
		else
			SetNote(wavenm, "Previous Name", nameofwave(wavenm))
//			note wavenm, "Previous Name:"+nameofwave(wavenm)
			rename wavenm $(name)
			Print "Renamed",renameWave,"to",name
		endif
	endif
end

Function ZeroBaseline(fromMenu,[x1,x2])
	variable fromMenu
	variable x1, x2
	string namestr=TraceNameList("",";",3) //3 = omit hidden traces
	namestr[strlen(namestr)-1,strlen(namestr)]=""
	
	variable i
	variable startflag=1
	
	getaxis/q bottom
	
	//prompt for x values
	variable startx=V_min
	variable endx=0.2*(V_max-V_min)
	
	if(strlen(csrinfo(A)) && strlen(csrinfo(B)))
		startx = xcsr(A) > xcsr(B) ? xcsr(B) : xcsr(A)
		endx = xcsr(A) > xcsr(B) ? xcsr(A) : xcsr(B)
	endif
	
	if(!numtype(x1)) //x1 is a number
		startx = x1
	endif
	if(!numtype(x2))
		endx = x2
	endif
	
	if(x1+x2==0)//numtype(x1) && numtype(x2)) //is not a number
		prompt startx, "Enter beginning of baseline"
		prompt endx, "Enter end of baseline"
		DoPrompt "Enter baseline values", startx, endx
	endif
	
	if(!V_flag)
		for(i=0;i<itemsinlist(namestr, ";");i+=1)
			WAVE wavenm = tracenametowaveref("",stringfromlist(i,namestr)) //root:$stringfromlist(i,namestr)
			wavestats/q/r=(startx,endx) wavenm
			wavenm-=V_avg
		endfor
	
		if(fromMenu)
			print "Number of waves adjusted: "+num2str(i)
		else
			return i
		endif
	endif
end

Function AverageGraphTraces(fromMenu)
	variable fromMenu
	string namestr=removefromlist(winname(0,1)+"_waveAverage",removefromlist("zero",TraceNameList("",";",3))) //3 = omit hidden traces
	namestr[strlen(namestr)-1,strlen(namestr)]=""
	
	variable i
	variable startflag=1
	string avgnote
	
	string avgname=winname(0,1)+"_waveAverage"
	prompt avgname, "Name of average wave:"
	DoPrompt "Average", avgname
	
	if(V_flag==0)
		Print "Waves averaged:"
		for(i=0;i<itemsinlist(namestr, ";");i+=1)
			WAVE wavenm = tracenametowaveref("",stringfromlist(i,namestr)) //root:$stringfromlist(i,namestr)
			if(startflag)
				duplicate/o wavenm $(avgname)//root:$(avgname)
				WAVE avg=$(avgname)//root:$(avgname)
				avg=0
				startflag=0
			endif
			avg+=wavenm
			//append note
			avgnote=GetNote(avg,"Average Sources")
			SetNote(avg,"Average Sources",avgnote+nameofwave(wavenm)+";")
			Print "     "+nameofwave(wavenm)
		endfor
	
		avg/=i
		Print "Average wave: "+nameofwave(avg)
	
		if(findlistitem(winname(0,1)+"_waveAverage",TraceNameList("",";",3))<0)
			appendtograph avg
			ModifyGraph rgb($nameofwave(avg))=(0,0,0)
		endif
	
		if(fromMenu)
			print "Number of waves averaged: "+num2str(i)
		else
			return i
		endif
	endif
end

Function  RogueInfo()
	variable/g roguenum
	WAVE Imem=root:Imemchart
	
	if(!waveexists(roguelength))
		Make/n=0 roguelength, roguetime
	endif
	
	WAVE roguelength=root:roguelength
	WAVE roguetime=root:roguetime
	
	insertpoints numpnts(roguelength),1, roguelength, roguetime
	
	print "Rogue Number: "+num2str(roguenum+1)
	roguetime[numpnts(roguetime)-1]=xcsr(A)
	print "          Start Time: "+num2str(xcsr(A))
	roguelength[numpnts(roguelength)-1]=xcsr(B)-xcsr(A)
	print "          Length: "+num2str(xcsr(B)-xcsr(A))
	Tag/C/N=$("rogue"+num2istr(pcsr(A)))/F=1/I=1/TL=0/A=MB/X=2/Y=15 imemchart, xcsr(A),"R"+num2str(roguenum+1)
	roguenum+=1
end

function exchangeF(exfit,filter)
	wave exfit
	variable filter
	
	wave W_sigma
	
	variable/g v1
	make/o/n=6 exprops=0
	
	wavestats/q exfit
	make/o/n=100 exwave
	setscale/p x (1.005+(.51/filter)-v_minloc), .005, "", exwave
	exwave = -K1*exp(-x/K2)
	
	exprops[0] = K2*1000
	exprops[1] = wavemax(exwave)
	exprops[2] = area (exwave)
	sscanf nameofwave(exfit), "fit_avef%f", v1
	exprops[3] = v1
	exprops[4] = (v_maxloc - v_minloc)*1000
	exprops[5] = W_sigma[2]*1000
	
	//matrixtranspose exprops
	
	print "tau = ", exprops[0], "ms"
	print "amplitude = ", exprops[1] , "pA"
	print "charge = ", exprops[2] , "pC"
	
	//edit exprops
	
end

Function exchange()
	
	wave wavenm=csrWaveRef(A)
	print nameofwave(wavenm)
	CurveFit/M=2/W=0 exp_XOffset, wavenm[pcsr(a),pcsr(b)]/D
	wave fitwave=$("fit_"+nameofwave(wavenm))
	ModifyGraph rgb($nameofwave(fitwave))=(0,0,0)
	exchangeF(fitwave,30)
end

Function cutwave(point, preS, postS, wavenm,num)
	variable point
	variable preS
	variable postS
	variable num
	WAVE wavenm
	
	duplicate/o/r=[point-x2pnt(wavenm,preS),point+x2pnt(wavenm,postS)] wavenm $(nameofwave(wavenm)+"_cut"+num2str(num))
	SetScale/P x 0,deltax($(nameofwave(wavenm)+"_cut"+num2str(num))),"s", $(nameofwave(wavenm)+"_cut"+num2str(num))
end

Function seedGlobals()
	variable sweeplength=5, baselinelength=1, numwaves, fdur=10, pdiodeshift=0
	NVAR standardcomplete=root:globals:standardcomplete
		
	variable i
	for(i=0;i<=81;i+=3)
		WAVE listwave=root:$("f"+num2str(i))
		if(exists(nameofwave(listwave)))
			numwaves+=numpnts(listwave)
		endif
	endfor
	
	prompt sweeplength, "Sweep Length (s):"
	prompt baselinelength, "Baseline Length (s):"
	prompt fdur, "Flash Duration (msec):"
	prompt pdiodeshift, "Photodiode center, including baseline (s):"
	prompt numwaves, "Total number of flashes:"
	
	doprompt "Variables" sweeplength, baselinelength, fdur, pdiodeshift, numwaves
	
	if(!V_flag)
		variable/g root:globals:fdur=fdur
		variable/g root:globals:sweeplength=sweeplength
		variable/g root:globals:baselinelength=baselinelength
		variable/g root:globals:numwaves=numwaves
		variable/g root:globals:pdiodeshift=pdiodeshift
		
		//from "MakeDefaultWaves" function
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
			Measurements[0]=igorinfo(1) //"" //current file name....
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
		standardcomplete=1
		
		if(exists("intens") && !exists("flstrtrue"))
			duplicate intens flstrtrue
		endif
		if(exists("ndf"))
			WAVE ndf=root:ndf
			if(ndf[0]>ndf[1])
				WAVE ndflist=root:globals:ndflist
				WAVE flstrtrue=root:flstrtrue
//				sort/R ndflist,ndflist
				sort/R flstrtrue, flstrtrue
			endif
		endif
		
		variable tablefsize
		if(stringmatch(IgorInfo(2),"Windows")) //Microsoft Windows
			tablefsize=10 //appropriate table font size for respective OS...
		endif
		if(stringmatch(IgorInfo(2),"Macintosh")) //Apple Macintosh
			tablefsize=9 //was 9pt for "Geneva" font...changed to Arial to keep things consistent with Windows.
		endif
		Edit/n=summarytable Measurements,Values
		ModifyTable/W=summarytable alignment(Point)=1,width(Point)=29,width(Measurements)=160,width(Values)=120,size=tablefsize,showParts=6		
	endif
end

Function MyWindowHook(s)
	STRUCT WMWinHookStruct &s
	variable rval
	switch(s.eventCode)
		case 8:
			GetThreshValues()
			rval=1
			break
		default:
			rval=0
	endswitch
	
	return rval
end

Function GetThreshValues()
	string offsetlist=" "
	string offsetstr
	
	string tracelist=tracenamelist("",";",1)
	
	if(GrepString(tracelist, "zero"))
		if(itemsinlist(removefromlist("zero",tracelist))>1)
			string tracenm
			Prompt tracenm, "Select target trace:", popup, removefromlist("zero",tracelist)
			Doprompt "Select Wave", tracenm
		else
			tracenm=stringfromlist(1,removefromlist("zero",tracelist))
		endif
		
		if(!V_flag)
			offsetstr=stringbykey("offset(x)",traceinfo("","zero",0),"=")
			variable i
			for(i=1;i<strlen(offsetstr)-1;i+=1)
				offsetlist+=offsetstr[i]
			endfor
			variable offset=str2num(stringfromlist(1,offsetlist,","))
//			print "Offset: "+num2str(offset)
	
			FindLevels/Q/D=ThresholdCrossings/EDGE=0, tracenametowaveref("",tracenm), offset
			print "Levels Found: "+num2str(V_LevelsFound)
		endif
	else
		make/o/n=2 zero=0
		getaxis/q bottom
		SetScale/P x V_min,V_max,"", zero
		appendtograph zero
		newdatafolder/O root:WinGlobals
		newdatafolder/O root:WinGlobals:$(winname(0,1))
		string/g root:WinGlobals:$(winname(0,1)):S_TraceOffsetInfo
		ModifyGraph live(zero)=1
		ModifyGraph quickdrag(zero)=2
		getaxis/q left
		ModifyGraph lstyle(zero)=3,rgb(zero)=(0,0,0)
		ModifyGraph offset(zero)={0,(V_max+V_min)/2}
		
//		SetWindow kwTopWin, hook(threshhook)=MyWindowHook
	endif
end

Function SplayTraces()
	string tracelist=tracenamelist("",";",1)
	variable offset
	prompt offset, "Space:"
	DoPrompt "Values",offset
	
	variable i
	for(i=0;i<itemsinlist(tracelist);i+=1)
		ModifyGraph offset($stringfromlist(itemsinlist(tracelist)-i-1,tracelist))={0,offset*i}
	endfor
end


//**********************
// Misc Analysis functions

Function SpannedAverage(wavenm, index, startcycle, cyclespan, avoidlast,[thresh])
	Wave wavenm
	Wave index
	variable startcycle //number of cycles to skip at beginning (0 for full trace)
	variable cyclespan //number of periods to include in the cycle window
	variable avoidlast //number of cycles at end to omit (use 1 for sinusoidal stimuli/index waves)
	variable thresh //manual threshold

	variable currentcycle=startcycle

//	wavestats/q index
	STRUCT w_stats ix
	wstats(index, ix)
	
	if(!thresh)
		thresh=ix.avg+3*ix.sdev //0.1 make dynamic
	endif
	variable numcycles
	variable i
	//find threshold crossings and generate waves
	FindLevels/D=StimTimes/EDGE=1 index, thresh
	numcycles=floor((numpnts(StimTimes)-startcycle)/cyclespan)

	//first cut
	duplicate/O/R=(floor(stimtimes[currentcycle]),floor(stimtimes[currentcycle+cyclespan])) wavenm spanned
	duplicate/O/R=(floor(stimtimes[currentcycle]),floor(stimtimes[currentcycle+cyclespan])) index spannedindex
//	duplicate/O/R=(floor(stimtimes[currentcycle]),floor(stimtimes[currentcycle+cyclespan])) index spannedindex_0
	wave spanned=root:spanned
	currentcycle+=cyclespan

	//remaining cuts
	for(i=1;i<numcycles-avoidlast;i+=1)
		duplicate/O/R=(floor(stimtimes[currentcycle]),floor(stimtimes[currentcycle+cyclespan])) wavenm tmp
		duplicate/O/R=(floor(stimtimes[currentcycle]),floor(stimtimes[currentcycle+cyclespan])) index tmpindex
//		duplicate/O/R=(floor(stimtimes[currentcycle]),floor(stimtimes[currentcycle+cyclespan])) index $("spannedindex_"+num2str(i))
		wave tmp=root:tmp
		wave tmpindex=root:tmpindex
		spanned+=tmp
		spannedindex+=tmpindex
		currentcycle+=cyclespan
	endfor

	spanned/=numcycles
//	wavestats/q spanned
	STRUCT w_stats sd
	wstats(spanned, sd)
	spanned-=sd.avg
	spannedindex/=(numcycles/100)
	killwaves tmp, tmpindex
	Print "Number of cycles: "+num2str(numcycles)
end

Function sectionAvg([wavenm,start,range])
	WAVE wavenm
	variable start
	variable range
	
	if(range>0)
		variable pnts = numpnts(wavenm)-start
		variable i
		make/o/n=(trunc(pnts/range)) sectionWave, sectionSEM
		WAVE output = sectionWave
		WAVE sem = sectionSEM
	
		SetScale/P x range/2,range,"", output
	
		variable j=0
		for(i=start;i<pnts;i+=range)
			wavestats/q/r=[i,i+range] wavenm
			output[j]=V_avg
			sem[j]=V_sem ? V_sem : nan
			j+=1
		endfor
	dowindow/k sectionGraph
	display/n=sectionGraph wavenm output
	ModifyGraph zero(left)=2
	ModifyGraph rgb($nameofwave(output))=(0,0,0)
	if(range>1)
		//ErrorBars $nameofwave(output) XY,const=((range/2)/sqrt(range)),wave=(sectionSEM,sectionSEM)
		ErrorBars $nameofwave(output) Y,wave=($nameofwave(sem),$nameofwave(sem))
	endif
	DoWindow/H
	endif
end

Function exportSPR()
	WAVE/T Measurements=root:Measurements
	NVAR scale=root:globals:scalingf
	NVAR NDF=root:globals:maxndfused
	duplicate/o $("avef"+num2str(NDF)) $(replacestring(" ", Measurements[0], "")+"_SPR")
	WAVE SPR=root:$(replacestring(" ", Measurements[0], "")+"_SPR")
	SPR*=scale
	Save/C SPR as nameofwave(SPR)
end

Function GetStimHz(stimwave,thresh)
	WAVE stimwave
	variable thresh
	
	FindLevels/Q/D=ThresholdCrossings/EDGE=1, stimwave, thresh	
	return round(numpnts(ThresholdCrossings)/(ThresholdCrossings[numpnts(ThresholdCrossings)]-ThresholdCrossings[0]))
end

//truncate a given length (seconds) to give a unitary cycle count for frequency
Function TruncByCycle(length, freq)
	variable length
	variable freq
	Print "Using length of: "+num2str(trunc(length*freq)/freq)
	return trunc(length*freq)/freq
end

Function SubtractBaseWave([graph,basename])
	string graph
	string basename
	
	if(numtype(strlen(graph))==2)//empty
		graph=winname(0,1)
	endif
	
	if(numtype(strlen(basename))==2)
		//prompt...
		prompt basename, "Enter Base Wave Name for "+graph+":"
		doprompt "Wave Name", basename
	endif
	
	string traces=tracenamelist(graph,";",1)
	variable i

	if(!V_flag)
		WAVE basewave=$basename
		if(exists(basename))
			for(i=0;i<itemsinlist(traces);i+=1)
				WAVE wavenm=tracenametowaveref(graph,stringfromlist(i,traces,";"))
				wavenm-=basewave
			endfor
		else
			abort "ERROR: No wave of that name"
		endif
	endif
end

Function ScalingFunc(rWave, mWave, x1, x2)
	//computes the statistically relevant scaling factor using least-squares, to match a range of two waves as closely as possible.
	WAVE rWave //raw wave
	WAVE mWave //mean wave
	variable x1 //starting point
	variable x2 //ending point
	
	Duplicate/o mWave wSquared wMeanProd
	WAVE wSquared=wSquared
	WAVE wMeanProd=wMeanProd
	
	wSquared=rWave^2
	wMeanProd=rWave*mWave
	
	wavestats/q/r=(x1,x2) wSquared
	variable wSquared_Sum = V_sum
	wavestats/q/r=(x1,x2) wMeanProd
	variable wMeanProd_Sum = V_sum
	
	killwaves/z wSquared wMeanProd
	
	return wMeanProd_Sum/wSquared_Sum
End


//**********************
// Data Browser functions

Function SelectionSize() //all items, regardless of what they are...
	variable i
	do
		i+=1
	while(!stringmatch(GetBrowserSelection(i),""))
	return i
end

Function/S SelectedWaveList() //all selected waves...
	string SelectedWaves=""
	variable i
	do
		if(waveexists($(GetBrowserSelection(i))))
			SelectedWaves+=GetBrowserSelection(i)+";"
		endif
		i+=1
	while(strlen(GetBrowserSelection(i))>0)
	return SelectedWaves
end

Function DisplaySelected([vsWave])
	wave vsWave
	string selected=SelectedWaveList()
	variable cancelled
	
	if(getkeystate(0) & 2)
		string vsWaveStr
		prompt vsWaveStr, "Enter \"vs\" wave name:"
		DoPrompt "Display selected vs", vsWaveStr
		wave vsWave=$(vsWaveStr)
		cancelled=V_flag
	endif
	
	if(strlen(selected)>0 && !cancelled)
		if(waveexists(vsWave))
			display $(stringfromlist(0,selected)) vs vsWave
		else
			display $(stringfromlist(0,selected))
		endif
//		SetWindow kwTopWin hook=GraphContextual, hookevents=1
		variable i
		pauseupdate
		for(i=1;i<itemsinlist(selected);i+=1)
			if(waveexists(vsWave))
				appendtograph $(stringfromlist(i,selected)) vs vsWave
			else
				appendtograph $(stringfromlist(i,selected))
			endif
		endfor
		resumeupdate
	endif
end

Function/WAVE Selected(printname)
	variable printname
	if(SelectionSize()>1)
		Abort "Select only one item"
	else
		string selected=GetBrowserSelection(0)
		WAVE wavenm=$(stringfromlist(0,selected))
//		if(itemsinlist(selected)>1)
//			print "Multiple items selected. Using wave "+nameofwave(wavenm)
//		endif
		if(printname)
			print "Selected Wave: "+nameofwave(wavenm)
		endif
	endif
	return wavenm
End

Function RenameSelected()
	string selected=SelectedWaveList()
	string newName
	variable revert
	prompt newName,"Enter new base name for selection:"
	prompt revert, "Revert Name(s)?", popup, "No;Yes"
	DoPrompt "Batch Rename", revert, newName
//	print revert
	
	if(!V_Flag && numtype(strlen(newName))==0 && strlen(selected)>0)
		variable i
		for(i=0;i<itemsinlist(selected);i+=1)
			WAVE wavenm=$(stringfromlist(i,selected))
			if(revert==2) //if reverting...
				if(!stringmatch(GetNote(wavenm,"Previous Name"),""))
					rename wavenm $(GetNote(wavenm,"Previous Name"))
					SetNote(wavenm, "Previous Name", "")
				endif
			else
				if(!stringmatch(newName,""))
					//duplicate/o $getwavesdatafolder(wavenm,2) $(getwavesdatafolder(wavenm,1)+newName+"_"+num2str(i))
					SetNote(wavenm, "Previous Name",nameofwave(wavenm))
					rename wavenm $(newName+"_"+num2str(i))
					//WAVE newWave=$(getwavesdatafolder(wavenm,1)+newName+"_"+num2str(i))
					//killwaves wavenm
				endif
			endif
		endfor
	endif
end

Function AverageSelected()
	//add option to truncate Nans...
		//for each selected items
			//if yes (truncate)
				//find point of nans --> to index wave
					//add point to index wave
					//append value
			//create average wave (done)
			//average waves
			//sort index wave
			//if yes (truncate)
				//for each point in index wave
					//aveerage to avgwave on per-point basis
	//add option to generate std err wave...
		//done after avg wave...
		//replace errwave points that are in index wave with point-specific error values.
	string selected=SelectedWaveList()
	if(itemsinlist(selected)>1)
		variable option=3
		variable truncate=2
		variable generr=1
		string newFolder
		string keystr=getdatafolder(1)[0,strlen(getdatafolder(1))-1]
		string name=getbasename(stringbykey(keystr,stringfromlist(0,selected)),stringbykey(keystr,stringfromlist(1,selected)))+"waveAverage"
		prompt option, "Manage source waves:", popup, "Do nothing;Delete waves;Move waves to \"Averaged\" folder;Move waves to custom folder..."
		prompt newFolder, "Custom Folder:"
		prompt name, "Base name for average wave"
		prompt truncate, "Include NAN points?",popup,"yes;no"
		prompt generr, "Generate error wave?",popup,"yes;no"
		DoPrompt "Average Waves", name, option,newFolder,truncate,generr
	
		if(!V_Flag && itemsinlist(selected)>1)
			string avgName=UniqueName(name,1,0)
			make/n=(numpnts($stringfromlist(0,selected))) $avgName=0
			make/o/n=0 indexnans
			WAVE indexnans=$nameofwave(indexnans)
	
			WAVE avg=$avgName
			SetScale/P x 0,deltax($stringfromlist(0,selected)), stringbykey("XUNITS",waveinfo($stringfromlist(0,selected),0)), avg
	
			variable i,j
			string avgnote
			Print "Waves averaged:"
			for(i=0;i<itemsinlist(selected);i+=1)
				WAVE wavenm=$stringfromlist(i,selected)
				if(truncate==1)
					for(j=0;j<numpnts(wavenm);j+=1)
						FindValue/V=(j) indexnans
						if(numtype(wavenm[j])==2 && V_value==-1)
							insertpoints 0,1,indexnans
							indexnans[0]=j
						endif
					endfor
				endif
				avg+=wavenm
				print "     "+nameofwave(wavenm)
				//append note
				avgnote=GetNote(avg,"Average Sources")
				SetNote(avg,"Average Sources",avgnote+nameofwave(wavenm)+";")
				//manage options
				if(option==2)
					killwaves/z wavenm
				endif
				if(option==3)
					newdatafolder/o Averaged
					//execute "ModifyBrowser expand="+num2str(GetBrowserLine(":Averaged:"))
					MoveWave wavenm, :Averaged:
				endif
				if(option==4)
					Print "Not Yet Implemented"
					//newdatafolder/o $newFolder
					//execute "ModifyBrowser expand=("+num2str(GetBrowserLine("newFolder"))+")"
					//MoveWave wavenm, :$(newFolder):
				endif
			endfor
			
			avg/=itemsinlist(selected)
			
			//generate std err wave here
			if(generr==1)
				make/o/n=(numpnts($stringfromlist(0,selected))) $(avgName+"_err")=0
				wave err=$(avgName+"_err")
				//perform error for full wave
				for(i=0;i<itemsinlist(selected);i+=1)
					WAVE wavenm=$stringfromlist(i,selected)
					err+=(wavenm-avg)^2
				endfor
				err=sqrt(err/(itemsinlist(selected)))/sqrt(itemsinlist(selected))
			endif
			
			if(truncate==1)
				variable numnans
				for(i=0;i<numpnts(indexnans);i+=1)
					numnans=0
					avg[indexnans[i]]=0
					for(j=0;j<itemsinlist(selected);j+=1)
						WAVE wavenm=$stringfromlist(j,selected)
						if(numtype(wavenm[indexnans[i]])==0)
							numnans+=1
							avg[indexnans[i]]+=wavenm[indexnans[i]]
						endif
					endfor
					avg[indexnans[i]]/=numnans
					//perform per-point error for index wave
					
					if(generr==1)
						//zero error point
						err[indexnans[i]]=0
						for(j=0;j<itemsinlist(selected);j+=1)
							WAVE wavenm=$stringfromlist(j,selected)
							if(numtype(wavenm[indexnans[i]])==0)
								numnans+=1
								err[indexnans[i]]+=(wavenm[indexnans[i]]-avg[indexnans[i]])^2
							endif
						endfor
						err[indexnans[i]]=sqrt(err[indexnans[i]]/numnans)/sqrt(numnans-1)
					endif
					
				endfor
			endif
			
			killwaves indexnans
			Print "Average wave: "+nameofwave(avg)
		endif
	else
		Abort "Select more than one wave to average."
	endif
end

Function MoveSelected([folder])
	string folder
	string selected=SelectedWaveList()
	
	if(numtype(str2num(folder)))
		variable selection
		variable action = 1
		string folderlist="New Folder;root;"+getdatafolder(1)+replacestring(",",stringbykey("FOLDERS",datafolderdir(1)),";"+getdatafolder(1))+";"
		prompt folder, "Folder Name:"
		prompt action, "What to do", popup, "Move;Copy"
		prompt selection, "Select folder",popup, folderlist
		DoPrompt "Copy or Move",action,selection,folder
		if(V_flag)
			return 1
		endif
	endif
	
	variable i
	if(!stringmatch(folder,""))
		newdatafolder/o $folder
		
		Print "Waves moved:"
		For(i=0;i<itemsinlist(selected);i+=1)
			WAVE wavenm=$stringfromlist(i,selected)
			Print "     "+nameofwave(wavenm)
			switch(action)	// numeric switch
				case 1:		// execute if case matches expression
					Movewave wavenm :$(folder):
				case 2:		// execute if case matches expression
					Duplicate/o wavenm,  :$(folder):$(nameofwave(wavenm))
			endswitch
		endfor
		Print "To Folder: "+folder
	elseif(selection>1)
		switch(action)	// numeric switch
			case 1:		// execute if case matches expression
				Print "Waves moved:"
			case 2:		// execute if case matches expression
				Print "Waves copied:"
		endswitch
		For(i=0;i<itemsinlist(selected);i+=1)
			WAVE wavenm=$stringfromlist(i,selected)
			Print "     "+nameofwave(wavenm)
			MoveWave wavenm, $(stringfromlist(selection-1,folderlist)+":")
		endfor
		Print "To Folder: "+stringfromlist(selection-1,folderlist)
	endif
end


//**********************
// Wave Note Handling

Function SetNote(wavenm, notekey, newValueStr)
	WAVE wavenm
	string notekey
	string newValueStr
	
	if(stringmatch(newValueStr,""))
		note/k wavenm, removebykey(notekey,Note(wavenm),":","\r")
	else
		note/k wavenm, replacestringbykey(notekey,Note(wavenm)," "+newValueStr,":","\r")
	endif
end

Function/S GetNote(wavenm,notekey)
	WAVE wavenm
	string notekey
	return stringbykey(notekey,note(wavenm),":","\r")[1,inf]
end


//**********************
// Trace Offset Handling

Function FixAllOffsets([graph])
	string graph
	if(numtype(strlen(graph))==2)
		graph=""
	endif
	string traces=tracenamelist(graph,";",1)
	string name
	variable xVal
	variable yVal
	variable i
	
	for(i=0;i<itemsinlist(traces);i+=1)
		WAVE wavenm=tracenametowaveref(graph,stringfromlist(i,traces,";"))
		FixTraceOffset(wavenm,graph=graph)
	endfor
end

Function FixTraceOffset(wavenm,[graph])
	WAVE wavenm
	string graph
	if(numtype(strlen(graph))==2)
		graph=""
	endif
	
	variable xVal
	variable yVal
	
	xVal=GetTraceOffset(graph,nameofwave(wavenm),"x")
	print "xval=",xval
	yVal=GetTraceOffset(graph,nameofwave(wavenm),"y")
	print "yval=",yval
	
//	variable doffset
//	if(numtype(str2num(getnote(wavenm,"xoffset")))==2)
//		doffset=0
//	else
//		doffset=str2num(getnote(wavenm,"xoffset"))
//	endif
		
	if(xVal != 0)
		SetScale/P x round((xVal+dimoffset(wavenm,0))/deltax(wavenm))*deltax(wavenm),deltax(wavenm),waveunits(wavenm,0), wavenm
		if(numtype(str2num(getnote(wavenm,"xoffset")))==2)
			setnote(wavenm,"xoffset",num2str(round((xVal+dimoffset(wavenm,0))/deltax(wavenm))*deltax(wavenm)-dimoffset(wavenm,0)))
		else
			setnote(wavenm,"xoffset",num2str(round((xVal+dimoffset(wavenm,0))/deltax(wavenm))*deltax(wavenm)-dimoffset(wavenm,0)+str2num(getnote(wavenm,"xoffset"))))
		endif
		ModifyGraph offset($(nameofwave(wavenm)))={0,*}
	endif
	if(yVal != 0)
		wavenm+=yVal
		variable lastoffset=str2num(getnote(wavenm,"yoffset"))
		if(numtype(lastoffset)==2)
			setnote(wavenm,"yoffset",num2str(yVal))
		else
			setnote(wavenm,"yoffset",num2str(yVal+lastoffset))
		endif
		ModifyGraph offset($(nameofwave(wavenm)))={*,0}
	endif
End

Function PadWave(wavenm,[graph])
	WAVE wavenm
	string graph
	if(numtype(strlen(graph))==2)
		graph=""
	endif
	//if detect Rotated
		//restore it...?
	
	variable xVal
	
	if(strlen(getnote(wavenm,"xoffset")))
		xVal=str2num(getnote(wavenm,"xoffset")) //GetTraceOffset(graph,nameofwave(wavenm),"x")
		print "Rotate xVal =",xVal
		print "point value =",x2pnt(wavenm, xVal)
		rotate x2pnt(wavenm, xVal)-x2pnt(wavenm,0), wavenm
		if(numtype(str2num(getnote(wavenm,"Rotated")))==2)
			setnote(wavenm,"Rotated",num2str(x2pnt(wavenm, xVal)))
		else
			setnote(wavenm,"Rotated",num2str(x2pnt(wavenm, xVal)-str2num(getnote(wavenm,"Rotated"))))
		endif
		if(str2num(getnote(wavenm,"Rotated"))==0)
			setnote(wavenm,"Rotated","")
		endif
//		setnote(wavenm,"xoffset","")
	endif
End

Function PadAllWaves([graph])
	string graph
	if(numtype(strlen(graph))==2)
		graph=""
	endif
	string traces=tracenamelist(graph,";",1)
	variable i
	
	for(i=0;i<itemsinlist(traces);i+=1)
		WAVE wavenm=tracenametowaveref(graph,stringfromlist(i,traces,";"))
		PadWave(wavenm,graph=graph)
	endfor
end

Function FixAndPad([graph])
	string graph
	if(numtype(strlen(graph))==2)
		graph=""
	endif
	FixAllOffsets(graph=graph)
	PadAllWaves(graph=graph)
end

Function UndoOffsets(wavenm)
	wave wavenm
	variable xoffset=str2num(getnote(wavenm,"xoffset"))
	variable yoffset=str2num(getnote(wavenm,"yoffset"))
	variable rotated=str2num(getnote(wavenm,"Rotated"))
	
	if(numtype(xoffset)==2)
		//do nothing if nan
	else	
		SetScale/P x round((-xoffset+dimoffset(wavenm,0))/deltax(wavenm))*deltax(wavenm),deltax(wavenm),waveunits(wavenm,0), wavenm
		setnote(wavenm,"xoffset","")
	endif
	
	if(numtype(yoffset)==2)
		//do nothing if nan
	else
		wavenm-=yoffset
		setnote(wavenm,"yoffset","")
	endif
	
	ModifyGraph offset={0,0}
	
	if(numtype(rotated)==2)
		//do nothing if nan
	else
		//rotate x2pnt(wavenm, -rotated), wavenm
		rotate -rotated, wavenm
		setnote(wavenm,"Rotated","")
	endif
end

Function UndoAllOffsets([graph])
	string graph
	if(numtype(strlen(graph))==2)
		graph=""
	endif
	string traces=tracenamelist(graph,";",1)
	variable i
	
	for(i=0;i<itemsinlist(traces);i+=1)
		WAVE wavenm=tracenametowaveref(graph,stringfromlist(i,traces,";"))
		UndoOffsets(wavenm)
	endfor
end


//**********************
// Trace Highlighting

Function TraceHighlight([graph])
	string graph

	string list
	if(numtype(strlen(graph))==2)
		getwindow/z kwTopWin, wsize
		list=tracenamelist("",";",3)
	else
		getwindow/z $graph, wsize
		list=tracenamelist(graph,";",3)
	endif
	
	make/o/T/n=(itemsinlist(list)) graphTracesWave
	make/o/B/n=(itemsinlist(list)) graphTracesSelection=0
	WAVE/T listW=graphTracesWave
	WAVE selectW=graphTracesSelection
	variable i
	for(i=0;i<itemsinlist(list);i+=1)
		listW[i]=stringfromlist(i,list,";")
	endfor
	
	if(winType(winName(0,87))==7)
		V_right=0
		v_top=0
	endif
	
	//append "original z" position note to all waves...
	
	killchildwindow("TraceScalePanel")
	killchildwindow("TraceHighlightePanel")
	NewPanel/N=TraceHighlightPanel/HOST=#/EXT=0/W=(0,0,360,495) //FLT=2// /W=(V_right,V_top,V_right+253,V_top+380)/FLT=2
		Button DoneButton,pos={30,15},size={70,30},title="Done",proc=TraceHighlightButtons,disable=0
		Button RevertButton,pos={130,15},size={70,30},title="Revert",proc=TraceHighlightButtons,disable=0
//		Slider ScaleSlider,pos={31,59},size={41,293},limits={0.0000001,5,0},value= 1,ticks= 5,proc=TraceScalingSlider,disable=2
		ListBox TraceList listWave=listW,pos={30,60},size={300,408},mode=4,selWave=selectW,proc=TraceHighlightList
end

Function TraceHighlightList(ctrlName,row,col,event) : ListboxControl
	String ctrlName
	variable row
	variable col
	variable event
	
	//string from selection wave
	variable i
	string selection
	WAVE indexW=graphTracesSelection
	WAVE/T traceList=graphTracesWave
	FindLevels/DEST=SelectionIndex/P/Q indexW, 1
	ModifyGraph rgb=(65535,0,0)
	for(i=0;i<numpnts(SelectionIndex);i+=1)
		WAVE wavenm=$traceList[SelectionIndex[i]]
		removefromgraph $nameofwave(wavenm)
		appendtograph $nameofwave(wavenm)
		ModifyGraph rgb($(traceList[SelectionIndex[i]]))=(0,0,0)
		selection+=traceList[SelectionIndex[i]]+","
	endfor
	
	return 0
end

Function TraceHighlightButtons(ctrlName) : ButtonControl
	string ctrlName
	variable oldValue
	SetActiveSubwindow $winlist("*","","WIN:")#TraceHighlightPanel
//	print ctrlName
	strswitch(ctrlName)	// string switch
		case "DoneButton":		// execute if case matches expression
			controlinfo/W=# TraceList
			string trace=S_Value
			controlinfo/W=# ScaleValue
//			Print trace+" scaled by "+num2str(V_Value)
			killwindow #
			break					// exit from switch
		case "RevertButton":
			variable i
			WAVE/T traceList=graphTracesWave
			for(i=0;i<numpnts(traceList);i+=1)
				WAVE wavenm=$traceList[i]
				removefromgraph $nameofwave(wavenm)
				appendtograph $nameofwave(wavenm)
			endfor
			break
		default:							// optional default expression executed
									// when no case matches
	endswitch
end


//**********************
// Trace Scaling

Function TraceScaling([graph])
	string graph

	if(numtype(strlen(graph))==2)
		getwindow/z kwTopWin, wsize
	else
		getwindow/z $graph, wsize
	endif
	
	if(winType(winName(0,87))==7)
		V_right=0
		v_top=0
	endif
	
	killchildwindow("TraceScalePanel")
	killchildwindow("TraceHighlightePanel")
	NewPanel/N=TraceScalePanel/HOST=#/EXT=0/W=(0,0,200,380) //FLT=2// /W=(V_right,V_top,V_right+253,V_top+380)/FLT=2
		PopupMenu ScaleToTrace,pos={101,89},size={49,20},mode=1,popvalue="Autoscale To",value="Autoscale To;"+tracenamelist("",";",1),proc=TraceScalingMenu,disable=2
		Button DoneButton,pos={101,138},size={70,30},title="Done",proc=TraceScalingButtons,disable=0
		Button UndoButton,pos={101,187},size={70,30},title="Undo",proc=TraceScalingButtons,disable=2
		Button UndoAllButton,pos={101,236},size={70,30},title="Undo All",proc=TraceScalingButtons,disable=2
		Slider ScaleSlider,pos={31,59},size={41,293},limits={0.0000001,5,0},value= 1,ticks= 5,proc=TraceScalingSlider,disable=2
		SetVariable ScaleValue,pos={101,59},size={70,20},limits={0.0000001,0,0},fSize=14,value=_NUM:1,proc=TraceScalingValue,disable=2 //#"0"
		Checkbox BoldSelect,pos={150,40},size={50,20},title="Bold",value=0,proc=TraceScalingCheckbox,disable=2
		Button IncreaseRange,pos={113,283},size={30,30},title="\\W617",proc=TraceScalingButtons,disable=2
		Button DecreaseRange,pos={113,321},size={30,30},title="\\W623",proc=TraceScalingButtons,disable=2
		PopupMenu TraceList,pos={14,16},size={49,20},mode=1,popvalue="Select Trace",value= "Select Trace;"+tracenamelist("",";",1),proc=TraceScalingMenu
end

Function TraceScalingCheckbox(ctrlName,checked): CheckBoxControl
	String ctrlName
	Variable checked
	SetActiveSubwindow $winlist("*","","WIN:")#TraceScalePanel
	
	controlinfo/W=# TraceList
	if(checked)
		ModifyGraph lsize($S_Value)=4
	else
		ModifyGraph lsize($S_Value)=1
	endif
End

Function TraceScalingButtons(ctrlName) : ButtonControl
	string ctrlName
	variable oldValue
	SetActiveSubwindow $winlist("*","","WIN:")#TraceScalePanel
//	print ctrlName
	strswitch(ctrlName)	// string switch
		case "DoneButton":		// execute if case matches expression
			controlinfo/W=# TraceList
			string trace=S_Value
			controlinfo/W=# ScaleValue
//			Print trace+" scaled by "+num2str(V_Value)
			killwindow #
			ModifyGraph lsize=1
			break					// exit from switch
		case "UndoButton":		// execute if case matches expression
			controlinfo/W=# TraceList
			WAVE wavenm=tracenametowaveref("",S_Value) //$S_Value
			oldValue=str2num(getnote(wavenm,"Scaling Factor"))
			if(numtype(oldvalue)==2)
				oldValue=1
			endif
			wavenm/=oldValue
			Slider ScaleSlider win=#,value=1
			SetVariable ScaleValue win=#,value=_NUM:1
//			ValDisplay ScaleValue win=#,value=#num2str(1)
			setnote(wavenm,"Scaling Factor","")
			break
		case "UndoAllButton":
			string traces=tracenamelist("",";",1)
			variable i
			for(i=0;i<itemsinlist(traces);i+=1)
				WAVE wavenm=tracenametowaveref("",stringfromlist(i,traces))//$stringfromlist(i,traces)
				oldvalue=str2num(getnote(wavenm,"Scaling Factor"))
				if(numtype(oldValue)==2)
					oldValue=1
				endif
				wavenm/=oldValue
				setnote(wavenm,"Scaling Factor","")
			endfor
			Slider ScaleSlider win=#,value=1,limits={0.0000001,5,0},ticks= 5
			SetVariable ScaleValue win=#,value=_NUM:1
//			ValDisplay ScaleValue win=#,value=#num2str(1)
			ModifyGraph lsize=1
			PopupMenu TraceList win=#,popmatch="Select Trace"//,value="Select Trace;"+tracenamelist("",";",1)
			Checkbox BoldSelect win=#, disable=2,value=0
			break
		case "IncreaseRange":
			controlinfo/W=# ScaleSlider
			Slider ScaleSlider win=#,limits={0.0000001,str2num(stringbykey("limits={1e-07",S_Recreation,",",","))*1.1,0},ticks= 5
			break
		case "DecreaseRange":
			controlinfo/W=# ScaleSlider
			Slider ScaleSlider win=#,limits={0.0000001,str2num(stringbykey("limits={1e-07",S_Recreation,",",","))/1.1,0},ticks= 5
			break
		default:							// optional default expression executed
									// when no case matches
	endswitch
end

Function TraceScalingValue(ctrlname,varNum,varStr,varName) : SetVariableControl
	string ctrlname
	variable varNum
	string varStr
	string varName
	variable newValue=str2num(varStr)
	if(newValue<0.0000001)
		newValue=0.0000001
	endif
	SetActiveSubwindow $winlist("*","","WIN:")#TraceScalePanel
	
//	newValue=round(newValue*10000)/10000

	pauseupdate
	controlinfo/W=# TraceList
	WAVE wavenm=tracenametowaveref("",S_Value) //$S_Value
	if(waveexists(wavenm))
		variable oldvalue=str2num(getnote(wavenm,"Scaling Factor"))
		if(numtype(oldvalue)==2)
			oldvalue=1
		endif
		wavenm/=oldvalue
		wavenm*=newValue
		setnote(wavenm,"Scaling Factor",fullNum2Str(newValue)) //num2str(newValue))
		Slider ScaleSlider win=#,value=newValue
		controlinfo/w=# ScaleSlider
		if(str2num(stringbykey("limits={1e-07",S_Recreation,",",","))<newValue)
			Slider ScaleSlider win=#,limits={0.0000001,newValue,0},ticks= 5
		endif
		SetVariable ScaleValue win=#,value=_NUM:newValue
	endif
	doupdate
end

Function TraceScalingSlider(ctrlName,value,event) : SliderControl
	string ctrlName
	variable value
	variable event
	SetActiveSubwindow $winlist("*","","WIN:")#TraceScalePanel
//	value=round(value*10000)/10000
	
	pauseupdate
	controlinfo/W=# TraceList
//	print S_Value
	WAVE wavenm=tracenametowaveref("",S_Value) //$S_Value
	if(waveexists(wavenm))
		variable oldvalue=str2num(getnote(wavenm,"Scaling Factor"))
		if(numtype(oldvalue)==2)
			oldvalue=1
		endif
		wavenm/=oldvalue
		wavenm*=value
		setnote(wavenm,"Scaling Factor", fullNum2Str(value))//num2str(value))
		SetVariable ScaleValue win=#,value=_NUM:value
//		ValDisplay ScaleValue win=#,value=#num2str(value)
		controlinfo/W=# ScaleSlider
		if(value > .9*str2num(stringbykey("limits={1e-07",S_Recreation,",",",")))
			Slider ScaleSlider win=#,limits={0.0000001,str2num(stringbykey("limits={1e-07",S_Recreation,",",","))*(1+V_Value/str2num(stringbykey("limits={1e-07",S_Recreation,",",","))-.9),0},ticks= 5
		endif
		if(value < .1*str2num(stringbykey("limits={1e-07",S_Recreation,",",",")))
			Slider ScaleSlider win=#,limits={0.0000001,str2num(stringbykey("limits={1e-07",S_Recreation,",",","))/(1+(0.1-V_Value/str2num(stringbykey("limits={1e-07",S_Recreation,",",",")))),0},ticks= 5
		endif
	endif
//	print ctrlName
	doupdate
end

Function TraceScalingMenu(ctrlName,popNum,popStr) : PopupMenuControl
	string ctrlName
	variable popNum
	string popStr
	SetActiveSubwindow $winlist("*","","WIN:")#TraceScalePanel
//	print ctrlName
	//set slider to current scaling factor value
	variable oldvalue
	strswitch(ctrlName)
		case "TraceList":
			if(popnum>1)
				WAVE wavenm=tracenametowaveref("",popStr)
				oldvalue=str2num(getnote(wavenm,"Scaling Factor"))
				if(numtype(oldvalue)==2)
					oldvalue=1
				endif
	
				Slider ScaleSlider win=#,value=oldvalue
				SetVariable ScaleValue win=#,value=_NUM:oldvalue
//	ValDisplay ScaleValue win=#,value=#num2str(oldvalue)
				ModifyGraph lsize=1
				ModifyGraph lsize($popStr)=4
		
//		Button DoneButton win=#,disable=0
				Button UndoButton win=#,disable=0
				Button UndoAllButton win=#,disable=0
				Slider ScaleSlider win=#,disable=0
				SetVariable ScaleValue win=#,disable=0
				Button IncreaseRange win=#,disable=0
				Button DecreaseRange win=#,disable=0
				Checkbox BoldSelect win=#, disable=0,value=1
				
				if(strlen(csrinfo(A)) && strlen(csrinfo(B)))
					PopupMenu ScaleToTrace win=#, disable=0
				endif
	
				doupdate
				controlinfo/w=# $ctrlName
				if(strlen(S_Recreation)>0)
					variable newWidth=28+str2num(stringbykey("size",S_Recreation,"=",",")[1,strlen(stringbykey("size",S_Recreation,"=",","))])
					if(newWidth>200)
						movesubwindow/w=# fnum=(0,0,newWidth,380)
					endif
				endif
			else
				Slider ScaleSlider win=#,value=oldvalue
				SetVariable ScaleValue win=#,value=_NUM:oldvalue
//	ValDisplay ScaleValue win=#,value=#num2str(oldvalue)
				ModifyGraph lsize=1
		
//		Button DoneButton win=#,disable=2
				Button UndoButton win=#,disable=2
				Button UndoAllButton win=#,disable=2
				Slider ScaleSlider win=#,disable=2
				SetVariable ScaleValue win=#,disable=2
				Button IncreaseRange win=#,disable=2
				Button DecreaseRange win=#,disable=2
				Checkbox BoldSelect win=#, disable=2,value=1
				PopupMenu ScaleToTrace win=#, disable=2
			endif
			break
		case "ScaleToTrace":
			if(popnum>1)
				WAVE toWave=tracenametowaveref("",popStr)
				//controlinfo on T
				ControlInfo/W=# TraceList
				WAVE wavenm=tracenametowaveref("",S_Value)
				variable value=ScalingFunc(wavenm,toWave,xcsr(A),xcsr(B))
				oldvalue=str2num(getnote(wavenm,"Scaling Factor"))
				if(numtype(oldvalue)==2)
					oldvalue=1
				endif
				wavenm/=oldvalue
				wavenm*=value
				setnote(wavenm,"Scaling Factor", fullNum2Str(value))//num2str(value))
				SetVariable ScaleValue win=#,value=_NUM:value
				Slider ScaleSlider win=#,value=value
				//ModifyGraph lsize($popStr)=4
			else
				//ModifyGraph lsize=1
			endif
			break
		default:
	endswitch
end

//**********************
//Number and String management

Function/S fullNum2Str(num)
	variable num
	string numStr
	sprintf numStr "%.16g" num
	return numStr
end

Function/S doshell(cmd)
	string cmd
//	print "do shell script \""+cmd+"\""
	ExecuteScriptText/Z "do shell script \""+cmd+"\""
	return S_value[1,strlen(S_value)-2]
end

Function GetUUID()
	
	WAVE/T UUIDs=root:UUIDs
	if(!waveexists(UUIDs))
		make/T/N=0 UUIDs
	endif
	InsertPoints numpnts(UUIDs),1, UUIDs
	LoadData/I/J="S_UUID"/L=4/Q/T=tmp
	SVAR S_UUID=root:tmp:S_UUID
	UUIDs[numpnts(UUIDs)-1]=S_UUID
	KillDataFolder/Z root:tmp
end

Function/S GetExpUUID(filePathStr)
	string filePathStr
	string rval
	DFREF saveDFR = GetDataFolderDFR()
	setdatafolder root:
	Newpath/O/Q filePath, ParseFilePath(1, filePathStr, ":", 1, 0)
	LoadData/P=filePath/J="S_UUID"/L=4/Q/T=tmp ParseFilePath(0, filePathStr, ":", 1, 0)
	SVAR UUID=root:tmp:S_UUID
	setdatafolder saveDFR
	if(SVAR_exists(UUID))
		rval=UUID
	else
		rval=""
	endif
	killDataFolder/Z root:tmp
	return rval
end

//**********************
//Curve Fitting Functions

Function Geometric(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = A*e^((x-1)*ln(p))+y
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = p
	//CurveFitDialog/ w[1] = A
	//CurveFitDialog/ w[2] = y

	return w[1]*e^((x-1)*ln(w[0]))+w[2]
End

Function DoubleGeometric(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = A1*e^(x*ln(p1))+A2*e^(x*ln(p2))+y
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = p1
	//CurveFitDialog/ w[1] = A1
	//CurveFitDialog/ w[2] = p2
	//CurveFitDialog/ w[3] = A2
	//CurveFitDialog/ w[4] = y

	return w[1]*e^(x*ln(w[0]))+w[3]*e^(x*ln(w[2]))+w[4]
End

Function ERPmodel(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = A*(((1/tauf)/((1/tauf)-(1/taum))*(10^(-(1/taum)*x)-10^(-(1/tauf)*x))+((B*(1/tauf)*(1/tauM2))/(((1/tauf)-(1/taum))*((1/taum)-(1/tauM2))*((1/tauM2)-(1/tauf))))*(((1/taum)-(1/tauM2))*10^(-(1/tauf)*x)+((1/tauM2)-(1/tauf))*10^(-(1/taum)*x)+((1/tauf)-(1/taum))*10^(-(1/tauM2)*x))))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = tauf
	//CurveFitDialog/ w[1] = taum
	//CurveFitDialog/ w[2] = tauM2
	//CurveFitDialog/ w[3] = B
	//CurveFitDialog/ w[4] = A

	return w[4]*(((1/w[0])/((1/w[0])-(1/w[1]))*(e^(-(1/w[1])*x)-e^(-(1/w[0])*x))+((w[3]*(1/w[0])*(1/w[2]))/(((1/w[0])-(1/w[1]))*((1/w[1])-(1/w[2]))*((1/w[2])-(1/w[0]))))*(((1/w[1])-(1/w[2]))*e^(-(1/w[0])*x)+((1/w[2])-(1/w[0]))*e^(-(1/w[1])*x)+((1/w[0])-(1/w[1]))*e^(-(1/w[2])*x))))
End

Function TripleGeometric(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = A1*e^(x*ln(p1))+A2*e^(x*ln(p2))+A3*e^(x*ln(p3))+y
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 7
	//CurveFitDialog/ w[0] = A1
	//CurveFitDialog/ w[1] = p1
	//CurveFitDialog/ w[2] = A2
	//CurveFitDialog/ w[3] = p2
	//CurveFitDialog/ w[4] = A3
	//CurveFitDialog/ w[5] = p3
	//CurveFitDialog/ w[6] = y

	return w[0]*e^(x*ln(w[1]))+w[2]*e^(x*ln(w[3]))+w[4]*e^(x*ln(w[5]))+w[6]
End


//**********************
//Wave Label and Axis Management

Function SetUnitLabel(wavenm,dimStr,unitStr)
	WAVE wavenm
	string dimStr
	string unitStr
	//get current scaling
	strswitch(dimStr)
		case "x":
			SetScale/P x, dimoffset(wavenm,0), deltax(wavenm), unitStr, wavenm
			break
		case "y":
			SetScale/P y, dimoffset(wavenm,0), deltax(wavenm), unitStr, wavenm
			break
	endswitch
end

Function SetGraphUnits(graphnm,dimstr,unitstr)
	string graphnm
	string dimstr
	string unitstr
	//check if graph exists
	if(itemsinlist(winlist(graphnm,";","WIN:1"))==1)
		//get wave list in graph
		string tracelist=tracenamelist(graphnm,";",1)
		//iterate through and change dimensions of waves
		variable i=0
		for(i=0;i<itemsinlist(tracelist);i+=1)
			WAVE wavenm=tracenametowaveref(graphnm,StringFromList(i,tracelist,";"))
			SetUnitLabel(wavenm,dimstr,unitstr)
		endfor
	else
		abort "No graph of that name, or multiple graphs of that name found"
	endif
end

Function ChangeGraphUnitLabels()
	string dimstr
	string unitstr
	prompt dimstr, "Select X or Y axis:", popup, "X;Y"
	prompt unitstr, "Enter New Label:"
	doprompt "Change axis labels for graph \""+winname(0,1)+"\":", unitstr,dimstr
	SetGraphUnits(winname(0,1),dimstr,unitstr)
end

Function NanPointSwitch()
	string info=csrinfo(A)
	Variable point=str2num(StringByKey("POINT", info  , ":"  , ";"))
	WAVE wavenm=tracenametowaveref("",StringByKey("TNAME", info  , ":"  , ";"))
	if(strlen(getnote(wavenm,nameofwave(wavenm)+"["+num2str(point)+"]")))
		wavenm[point]=str2num(getnote(wavenm,nameofwave(wavenm)+"["+num2str(point)+"]"))
		setnote(wavenm,nameofwave(wavenm)+"["+num2str(point)+"]","")
	else
		//Print nameofwave(wavenm)+"["+num2str(point)+"]="+num2str(wavenm[point])
		setnote(wavenm,nameofwave(wavenm)+"["+num2str(point)+"]",num2str(wavenm[point]))
		wavenm[point]=nan
	endif
end

Function SummaryPDF()
	WAVE/T Measurements = Measurements
	WAVE/T Values = Values
	NVAR ndf = root:globals:maxndfused
//	string saveName
	
	DoWindow Summary
	if(V_flag)//summary graph exists
//		saveName=igorinfo(1)
//		if(stringmatch("Untitled",igorinfo(1)))
//			if(strlen(Values[0]))
//				saveName=Measurements[0]+" Ana"+num2str(ndf)+".pdf"
//			else
//				saveName=Measurements[0]+" Ana.pdf"
//			endif
//		else
//			saveName=igorinfo(1)
//		endif
		SavePICT/O/P=home/E=-2/N=Summary as igorinfo(1)
		CopyValues()
	endif
end

Function wave2array(wavenm)
	WAVE wavenm
	string theString=""
	variable i
	for(i=0;i<numpnts(wavenm);i+=1)
		theString+=num2str(wavenm[i])+"	"
	endfor
	PutScrapText theString
end

Function XYBox(nBoxes, YSorted, XSorted, suffix)
	variable nBoxes
	WAVE XSorted
	WAVE YSorted
	string suffix
	
	variable i
	
	if(strlen(suffix))
		suffix="_"+suffix
	endif
	
	make/o/n=(nBoxes) $(nameofwave(XSorted)+suffix+"_Avg"), $(nameofwave(YSorted)+suffix+"_Avg"), $(nameofwave(XSorted)+suffix+"_Err"), $(nameofwave(YSorted)+suffix+"_Err")
	WAVE XAvg = $(nameofwave(XSorted)+suffix+"_Avg")
	WAVE YAvg = $(nameofwave(YSorted)+suffix+"_Avg")
	WAVE XErr = $(nameofwave(XSorted)+suffix+"_Err")
	WAVE YErr = $(nameofwave(YSorted)+suffix+"_Err")
	
	variable jump = numpnts(XSorted)/nBoxes
	
	for(i=1;i<(nBoxes+1);i+=1)
		wavestats/q/r=[i*jump-jump,i*jump-1] XSorted
		XAvg[i-1]=V_avg
		XErr[i-1]=V_sem
		wavestats/q/r=[i*jump-jump,i*jump-1] YSorted
		YAvg[i-1]=V_avg
		YErr[i-1]=V_sem
	endfor
end
