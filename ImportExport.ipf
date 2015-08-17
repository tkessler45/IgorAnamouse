#pragma rtGlobals=1		// Use modern global access method.

//Imports all Igor Binary waves from the selected folder to the named project folder
Function ImportWaves(name)
	string name
	LoadData/D/I/L=1/T=$name
end

//****************************************************************
//****************************************************************
//****************************************************************

Macro ExportList(wlist,type)
	Variable wlist
	Variable type
	prompt wlist, "Wave List:",popup "Imem Waves Only;Pdiode Waves Only;FBNDF Waves Only;BBNDF Waves Only;NQ Waves Only;Average and Variance Waves Only;All Waves"
	prompt type, "File Format:",popup "Delimited Text;General Text;Igor Text;Igor Binary"
	String savelist=""
	String savename=""
	String S_Path
	variable len
	variable i
	variable j
	variable num
	//Add popup menu for 
	GetFileFolderInfo/Q/D "???"
	if(V_Flag!=0)
		Abort "Select an existing folder"
	endif
	Silent 1
	NewPath/O savepath S_Path //Defining savepath from selected folder pathname
	i=0
	j=0
	if(wlist==1)
		Print "--Exporting Imem Waves..."
	endif
	if(wlist==2)
		Print "--Exporting Pdiode Waves..."
	endif
	if(wlist==3)
		Print "--Exporting FBndf Waves..."
	endif
	if(wlist==4)
		Print "--Exporting BBndf Waves..."
	endif
	if(wlist==5)
		Print "--Exporting NQ Waves..."
	endif
	if(wlist==6)
		Print "--Exporting Average and Variance Waves..."
	endif
	if(wlist==7)
		Print "--Exporting All Waves..."
	endif
	do //Duplicate wavelists to savelists, iterating and increasing "i" in increments of 3 to get through allpossible NDF values under 100.
		if(wlist==1 || wlist==7)
			if(exists("f"+num2str(i))==1) //if wave f"#" exists...continue...
				len=numpnts($("f"+num2str(i))) //define length of the wave for "do" iterations...
				j=0
				savename=("f"+num2str(i)+"imemwaves.txt")
				savelist=""
				do
					num=$("f"+num2str(i))[j] 
					savelist+=("imem"+num2str(num)+";")
					j+=1
				while(j<len)
				if(type==1)
					Save/J/W/O/B/P=savepath savelist as savename
				endif
				if(type==2)
					Save/G/W/O/B/P=savepath savelist as savename
				endif
				if(type==3)
					Save/T/O/B/P=savepath savelist as savename
				endif
				if(type==4)
					Save/O/B/P=savepath savelist as savename
				endif
			endif
		endif
		if(wlist==2 || wlist==7)
			if(exists("f"+num2str(i))==1) //if wave f"#" exists...continue...
				len=numpnts($("f"+num2str(i))) //define length of the wave for "do" iterations...
				j=0
				savename=("f"+num2str(i)+"pdiodewaves.txt")
				savelist=""
				do
					num=$("f"+num2str(i))[j] 
					savelist+=("pdiode"+num2str(num)+";")
					j+=1
				while(j<len)
				if(type==1)
					Save/J/W/O/B/P=savepath savelist as savename
				endif
				if(type==2)
					Save/G/W/O/B/P=savepath savelist as savename
				endif
				if(type==3)
					Save/T/O/B/P=savepath savelist as savename
				endif
				if(type==4)
					Save/O/B/P=savepath savelist as savename
				endif
			endif
		endif
		if(wlist==3 || wlist==7)
			if(exists("f"+num2str(i))==1) //if wave f"#" exists...continue...
				len=numpnts($("f"+num2str(i))) //define length of the wave for "do" iterations...
				j=0
				savename=("f"+num2str(i)+"fbndfwaves.txt")
				savelist=""
				do
					num=$("f"+num2str(i))[j] 
					savelist+=("fbndf"+num2str(num)+";")
					j+=1
				while(j<len)
				if(type==1)
					Save/J/W/O/B/P=savepath savelist as savename
				endif
				if(type==2)
					Save/G/W/O/B/P=savepath savelist as savename
				endif
				if(type==3)
					Save/T/O/B/P=savepath savelist as savename
				endif
				if(type==4)
					Save/O/B/P=savepath savelist as savename
				endif
			endif
		endif
		if(wlist==4 || wlist==7)
			if(exists("f"+num2str(i))==1) //if wave f"#" exists...continue...
				len=numpnts($("f"+num2str(i))) //define length of the wave for "do" iterations...
				j=0
				savename=("f"+num2str(i)+"bbndfwaves.txt")
				savelist=""
				do
					num=$("f"+num2str(i))[j] 
					savelist+=("bbndf"+num2str(num)+";")
					j+=1
				while(j<len)
				if(type==1)
					Save/J/W/O/B/P=savepath savelist as savename
				endif
				if(type==2)
					Save/G/W/O/B/P=savepath savelist as savename
				endif
				if(type==3)
					Save/T/O/B/P=savepath savelist as savename
				endif
				if(type==4)
					Save/O/B/P=savepath savelist as savename
				endif
			endif
		endif
		i+=3 //NDF values increase by 3...
	while(i<100)
	if(wlist==5 || wlist==7)
		if(exists("NQ_FBNDF")==1) //if wave exists...continue...
			if(type==1)
				Save/J/W/O/B/P=savepath "NQ_FBNDF" as "NQ_FBNDFwave.txt"
			endif
			if(type==2)
				Save/G/W/O/B/P=savepath "NQ_FBNDF" as "NQ_FBNDFwave.txt"
			endif
			if(type==3)
				Save/T/O/B/P=savepath "NQ_FBNDF" as "NQ_FBNDFwave.txt"
			endif
			if(type==4)
				Save/O/B/P=savepath "NQ_FBNDF" as "NQ_FBNDFwave.txt"
			endif
		endif
		if(exists("NQ_Imem")==1) //if wave exists...continue...
			if(type==1)
				Save/J/W/O/B/P=savepath "NQ_Imem" as "NQ_Imemwave.txt"
			endif
			if(type==2)
				Save/G/W/O/B/P=savepath "NQ_Imem" as "NQ_Imemwave.txt"
			endif
			if(type==3)
				Save/T/O/B/P=savepath "NQ_Imem" as "NQ_Imemwave.txt"
			endif
			if(type==4)
				Save/O/B/P=savepath "NQ_Imem" as "NQ_Imemwave.txt"
			endif
		endif
		if(exists("NQ_PDIODE")==1) //if wave exists...continue...
			if(type==1)
				Save/J/W/O/B/P=savepath "NQ_PDIODE" as "NQ_PDIODEwave.txt"
			endif
			if(type==2)
				Save/G/W/O/B/P=savepath "NQ_PDIODE" as "NQ_PDIODEwave.txt"
			endif
			if(type==3)
				Save/T/O/B/P=savepath "NQ_PDIODE" as "NQ_PDIODEwave.txt"
			endif
			if(type==4)
				Save/O/B/P=savepath "NQ_PDIODE" as "NQ_PDIODEwave.txt"
			endif
		endif
		if(exists("NQ_BBNDF")==1) //if wave exists...continue...
			if(type==1)
				Save/J/W/O/B/P=savepath "NQ_BBNDF" as "NQ_BBNDFwave.txt"
			endif
			if(type==2)
				Save/G/W/O/B/P=savepath "NQ_BBNDF" as "NQ_BBNDFwave.txt"
			endif
			if(type==3)
				Save/T/O/B/P=savepath "NQ_BBNDF" as "NQ_BBNDFwave.txt"
			endif
			if(type==4)
				Save/O/B/P=savepath "NQ_BBNDF" as "NQ_BBNDFwave.txt"
			endif
		endif
	endif
	if(wlist==6 || wlist==7)
		savename="aveandvarwaves.txt"
		savelist=""
		i=0
		do
			if(exists("avef"+num2str(i))==1)
				savelist+=("avef"+num2str(i)+";")
			endif
			if(exists("varf"+num2str(i))==1)
				savelist+=("varf"+num2str(i)+";")
			endif
			i+=3
		while(i<100)
		if(type==1)
			Save/J/W/O/B/P=savepath savelist as savename
		endif
		if(type==2)
			Save/G/W/O/B/P=savepath savelist as savename
		endif
		if(type==3)
			Save/T/O/B/P=savepath savelist as savename
		endif
		if(type==4)
			Save/O/B/P=savepath savelist as savename
		endif
	endif
EndMacro
