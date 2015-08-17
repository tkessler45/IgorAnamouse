#pragma rtGlobals=1		// Use modern global access method.
#include <Waves Average>

Menu "|| AnaMouse ||"
	"-"
	"Load Average Waves...", AvgBinaryLoad()
	"Save Average Waves...", AvgBinarySave()
End

//****************************************************************
//****************************************************************
//****************************************************************

Macro AvgBinarySave(cellnum)
	variable cellnum
	prompt cellnum, "Enter a unique cell number:"
	silent 1
	variable i
	string savelist=""
	string savepath=""
	string savename=""
	//savename=igorinfo(1)
	string datestr=""
	datestr=Measurements[0]//savename[0,9]
	GetFileFolderInfo/Q/D "???"
	if(V_Flag!=0)
		Abort "Select an existing folder"
	endif
	NewPath/O savepath S_Path //Defining savepath from selected folder pathname
	i=0
	do
		if(exists("avef"+num2str(i))==1)
			savelist=("avef"+num2str(i))
			savename=datestr[0,9]+" c"+num2str(cellnum)+" avef"+num2str(i)
			print "Saving... "+savename
			duplicate/o $savelist $savename
			Save/O/P=savepath $savename
			duplicate/o $savename $savelist
			killwaves $savename
		endif
		i+=3
	while(i<100)
EndMacro

Macro AvgBinaryLoad(cellnum)
	variable cellnum=100
	prompt cellnum, "Enter the total number of cells:"
	silent 1
	variable i
	variable j
	variable div
	variable wavelen
	string namestr=""
	string newname=""
	string searchstr=""
	string newdirstr=""
	string avgdirstr=""
	NewDataFolder/o/s root:temp
	LoadData/D
	j=0
	do
		i=0
		do
			searchstr="* c"+num2str(j)+" avef"+num2str(i)
			namestr=WaveList(searchstr,"","")
			if(exists(namestr)==1)
				newname="c"+num2str(j)+"f"+num2str(i) //namestr[11,strlen(namestr)]
				print namestr+" loaded as... "+newname
				duplicate/o $namestr $newname
				if(DataFolderExists("root:temp")==1)
					newdirstr=namestr[0,9]
					KillDataFolder/z root:$(namestr[0,9]) //$newdirstr
					RenameDataFolder root:temp,$(namestr[0,9]) //$newdirstr
				endif
				killwaves $namestr
				wavestats/q $newname
				wavelen=V_npnts
			endif
			i+=3
		while(i<100)
		j+=1
	while(j<=cellnum)

	j=0
	string execstr
	do
		i=0
		div=0
		SetDataFolder root:$newdirstr
		searchstr="*f"+num2str(j)
		namestr=WaveList(searchstr,"+","")
		if(strlen(namestr)>0)
			do
				if(char2num(namestr[i])==char2num("+"))
					div+=1
				endif
				i+=1
			while(i<=strlen(namestr))
			make/o/n=(wavelen) $("avef"+num2str(j))
			SetScale/P x 0,0.005, "s", $("avef"+ num2str(j))
			namestr=namestr[0,strlen(namestr)-2]
			execstr="avef"+num2str(j)+"=("+namestr+")/div"
			execute execstr
			avgdirstr=newdirstr+"_avg"
			if(DataFolderExists("root:temp")==0)
				NewDataFolder/o root:temp
			endif
			duplicate/o $("avef"+num2str(j)) root:temp:$("avef"+num2str(j))
			killwaves $("avef"+num2str(j))
		endif
		j+=3
	while(j<100)
	KillDataFolder/z root:$(newdirstr+"_avg")
	RenameDataFolder root:temp,$(newdirstr+"_avg")
EndMacro
