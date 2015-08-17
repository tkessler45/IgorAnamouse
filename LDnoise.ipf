#pragma rtGlobals=1		// Use modern global access method.

Macro LDnoise()
	variable ampgain=50
	
	duplicate/R=[pcsr(A),pcsr(A)+4675]/O NQ_Imem Imem1
	
	Imem1*=-1000/ampgain
	wavestats/q Imem1
	Imem1-=V_avg
	SetScale d 0,0,"pA", Imem1
	
	duplicate/R=[pcsr(B)-4675,pcsr(B)]/O NQ_Imem Imem2
	
	Imem2*=-1000/ampgain
	wavestats/q Imem2
	Imem2-=V_avg
	SetScale d 0,0,"pA", Imem2
	make/o light, dark
	light[0]=1
	dark[0]=2
	execute "PowerSpecVar2(\"light\")"
	duplicate/o pow2 pow2light
	execute "PowerSpecVar2(\"dark\")"
	duplicate/o pow2 pow2dark
	duplicate/o pow2 pow2diff
	pow2diff=pow2dark-pow2light
	display pow2dark pow2light
	ModifyGraph mode=3, marker=19, msize=1, rgb(pow2dark)=(0,0,65280)
	ModifyGraph log=1
	display pow2diff
	ModifyGraph mode=3, marker=19, msize=1
	ModifyGraph log=1
	Duplicate/R=(0.1, 10)/O pow2diff intvar
	integrate intvar
	display intvar
	wavestats intvar
	print V_max, V_avg, V_avg/sqrt(V_npnts-1)
endmacro


Macro PowerSpecSweep(fnum)
	Variable fnum
	Prompt fnum,"Flash number?"
	
	//setup difflist wave...
	if(exists("powlist")==0)
		Make/O/N=0/D powlist
	endif
	insertpoints/M=0, 0, 1, powlist
	powlist[0]=fnum
	
	Variable tstep=0.005 //200Hz time interval...
	Silent 1; PauseUpdate
	//$("light"+num2str(fnum)) <-- this makes the string name "light34", for instance, if "34" is passed to the function as "fnum"
	fft/RP=[pcsr(A),pcsr(A)+301]/dest=$("light"+num2str(fnum)) imemchart
	$("light"+num2str(fnum))*=conj($("light"+num2str(fnum)))
	Redimension/R $("light"+num2str(fnum))

	fft/RP=[pcsr(B)-301,pcsr(B)]/dest=$("dark"+num2str(fnum)) imemchart
	$("dark"+num2str(fnum))*=conj($("light"+num2str(fnum)))
	Redimension/R $("dark"+num2str(fnum))
	
	// convert to spectral density of light
	wavestats/q $("light"+num2str(fnum))
	$("light"+num2str(fnum)) *= 2 * V_npnts * tstep / (V_npnts^2)
	
	// convert to spectral density of dark
	wavestats/q $("dark"+num2str(fnum))
	$("dark"+num2str(fnum)) *= 2 * V_npnts * tstep / (V_npnts^2)
	
	//Difference spectra
	duplicate/o $("dark"+num2str(fnum)) $("diff"+num2str(fnum))
	$("diff"+num2str(fnum))=$("dark"+num2str(fnum))-$("light"+num2str(fnum))
	
	//Integration from 1Hz to 10Hz from the difference spectra...1Hz is used because sweep is 1.5sec
//	duplicate/o/r=(1,10) $("diff"+num2str(fnum)) $("intpow"+num2str(fnum))
//	integrate $("intpow"+num2str(fnum))
//	wavestats/q $("intpow"+num2str(fnum))
//	print "Total Noise Variance from 1-10Hz for flash number",fnum,"is:",V_max
	
	//Displaying graphs
	dowindow/k $("pow"+num2str(fnum))
	display/n=$("pow"+num2str(fnum)) $("dark"+num2str(fnum)) $("light"+num2str(fnum)) $("diff"+num2str(fnum))
	ModifyGraph mode=3, marker=19, msize=3, rgb($("dark"+num2str(fnum)))=(0,0,0)
	ModifyGraph rgb($("diff"+num2str(fnum)))=(0,65280,0)
	ModifyGraph log=1
EndMacro

Macro AveDiffSpec(difflist)
	String difflist
	wavestats/q $(difflist)
	variable i=1
	
	duplicate/o $("diff"+num2str($(difflist)[0])) temp
	do
		temp+=$("diff"+num2str($(difflist)[i]))
		i+=1
	while(i<=V_npnts)
	temp/=V_npnts
	display temp
	ModifyGraph mode=3, marker=19, msize=3, log=1
	
	duplicate/o/r=(1,10) temp avintpow
	integrate avintpow
	wavestats/q avintpow
	print "Average Total Noise Variance from 1-10Hz:",V_max
EndMacro
