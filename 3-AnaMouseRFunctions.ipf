#pragma rtGlobals=1		// Use modern global access method.

// Misc Functions
Function AlmostEqual2(val1, val2, tolerance) //"AlmostEqual" already exists...
	variable val1; variable val2; variable tolerance
	variable flag
	flag = 0
	if ((val1 >= (val2 - tolerance)) %& (val1 <= (val2 + tolerance))) 
		flag = 1
	endif
	return(flag)
End

//****************************************************************
//****************************************************************
//****************************************************************

// Curvefit Functions
// set of functions used to generate user-defined curve fits.
// includes:

// Michaelis curve A / (1 + B/x)
Function michaelis(w,x)
	wave w; variable x
	Return( w[2] *  (1 / (1 + (w[1]/x)^w[0])) )
End

//****************************************************************
//****************************************************************
//****************************************************************

// Weber-Fechner curve A / (1 + x / B)
Function wf(w,x)
	wave w; variable x
	Return( w[1] * (1 / (1 + x/w[0])) )
End

//****************************************************************
//****************************************************************
//****************************************************************

// Saturing exponential A - exp(-B * x)
Function satexp(w,x)
	wave w; Variable x
	Return (w[0]-exp(-w[1]*x))
End

//****************************************************************
//****************************************************************
//****************************************************************

//Activation equation of Lamb and Pugh, 1993
Function activation(w,x)
	wave w; variable x
	Return(1-exp(-w[0]*((x-1.032)/0.22)^2))
End

//****************************************************************
//****************************************************************
//****************************************************************

// Sum of 3 Lorentzians, each of form A / (1 + (2 * Pi * x / B)^2)
Function lorentz_sum3(w, x)
	wave w; variable x
	Return( w[0]  / ((1 + (2 * 3.14159 * x / w[1])^2)) + w[2] / ((1 + (2 * 3.14159 * x / w[3])^2)))
End

//****************************************************************
//****************************************************************
//****************************************************************

// Bessel low-pass filter A / (1 + (x / B)^n)
Function bessel(w,x)
	wave w; variable x
	Return( (w[2] / (1 + (x / w[0])^w[1])) )
End

//****************************************************************
//****************************************************************
//****************************************************************

// Sum of two bessels low pass filters of form  A / (1 + (x / B)^n)
Function bessel_sum(w,x)
	wave w; variable x
	Return( (w[0] * ( 1/ (1 + (x / w[1])^w[3])) * 1 / (1 + (x / w[2])^w[4]) ) )
End

//****************************************************************
//****************************************************************
//****************************************************************

// Damped sinusoid
Function damp_sine(w,x) // returns a sin(x / d) exp(-x/b) (x / b)^(c-1)
	wave w; variable x
	Return( w[0] * sin(x / w[3]) * exp( - x / w[1]) ) * (x / w[1])^(w[2] - 1)
End

//****************************************************************
//****************************************************************
//****************************************************************

// Poisson filter for fitting flash response
Function poisson_filter(w,x) //returns a(x/b)^(c-1)exp(-x/b)
	wave w; variable x
	Return ( w[0] * ( (x/w[1])^(w[2]-1) * exp( -x/w[1] ) ) )
End

//****************************************************************
//****************************************************************
//****************************************************************

// Product of two Lorentzians with equal half-power frequencies
Function lorentz2(w, x) // returns A * [1 + (2 * pi * x / alpha)^2]^(-2)
	wave w; variable x
	Return( w[0]  / ((1 + (2 * 3.14159 * x / w[1])^2)^2))
End

//****************************************************************
//****************************************************************
//****************************************************************

// Product of 4 Lorentzians with equal half-power frequecies
Function lorentz4(w, x) // returns A * [1 + (2 * pi * x / alpha)^2]^(-2)
	wave w; variable x
	Return( w[0]  / ((1 + (2 * 3.14159 * x / w[1])^2)^4))
End

//****************************************************************
//****************************************************************
//****************************************************************

// Straight line for curve fits
Function straightlinefit(w,x) //returns a+bx
	Wave w
	Variable x
	return(w(0) + w(1)*x)
End

//****************************************************************
//****************************************************************
//****************************************************************

// Fits to amplitude histograms of dim flash responses.
// Assume # photons / flash follows Poisson statistics
// and that variance of failures is additive with variance
// of single photon response.  Variables are 
// mean # photons / flash, mean single photon amplitude
// single photon standard deviation, failures standard
// deviation, # flashes, histogram bin size.

Function poissonfit_single(w,x) 	// Sum of Gaussian Components w/ area weighted according to the Poisson Eqn.
	Wave w; Variable x 	// w is the coef. wave and contains parameters: w[0], mean # of events/trial w[1], single event amplitude w[2], variance of background noise w[3], response variance w[4], bin width w[5], # of trials x is the response amplitude
	Variable a = ( ((2*3.141592654)*(w[2]^2) )^0.5 ) 
	Variable b = ( ((2*3.141592654)*(w[2]^2 + w[3]^2) )^0.5 )
	Variable c = ( ((2*3.141592654)*(w[2]^2 + (2*w[3]^2)) )^0.5 )
	Variable d = ( ((2*3.141592654)*(w[2]^2 + (3*w[3]^2)) )^0.5 )
	Variable q = ( ((2*3.14)*(w[2]^2 + (4*w[3]^2)) )^0.5 )
	Variable e = (2*(w[2]^2))
	Variable f = (2*(w[2]^2 + w[3]^2))
	Variable g = (2*(w[2]^2 + (2*w[3]^2)))
	Variable h = (2*(w[2]^2 + (3*w[3]^2)))
	Variable r = (2*(w[2]^2 + (4*w[3]^2)))
	Variable i = x^2
	Variable j = (x - w[1])^2
	Variable k = (x - (2*w[1]))^2
	Variable l = (x - (3*w[1]))^2
	Variable s = (x - (4*w[1]))^2
	Variable m = exp( -w[0] )
	Variable n = m*w[0]
	Variable o = (m*w[0]^2)/2
	Variable p = (m*w[0]^3)/6
	Variable t = (m*w[0]^4)/24	
	Variable P0 = m*((w[4]*w[5])/a)*exp( -i/e )
	Variable P1 = n*((w[4]*w[5])/b)*exp( -j/f )
	Variable P2 = o*((w[4]*w[5])/c)*exp( -k/g )
	Variable P3 = p*((w[4]*w[5])/d)*exp( -l/h )
	Variable P4 = t*((w[4]*w[5])/q)*exp( -s/r )
	Variable w0LIM=0, w1LIM=0, w3LIM=0
	if (w[0] < w0LIM)
		w[0] = 2*w0LIM - w[0]
	endif
	if (w[1] < w1LIM)
		w[1] = 2*w1LIM - w[1]
	endif
	if (w[3] < w3LIM)
		w[3] = 2*w3LIM - w[3]
	endif
	Return(P0+P1+P2+P3+P4)
End

//****************************************************************
//****************************************************************
//****************************************************************

// Fit amplitude histograms at two different intensities
//w[0], mean # of events/trial
//w[1], single event amplitude
//w[2], variance of background noise
//w[3], response variance 
//w[4], bin width
//w[5], # of trials for 1st Histo.
//w[6], # of trials for 2nd Histo.
//w[7], magnification factor for light intensity difference
//x is the response amplitude

Function poissonfit_double(w,x) 	// Sum of Gaussian Components w/ area weighted according to the Poisson Eqn.
	Wave w; Variable x 	// w is the coef. wave and contains parameters:
	Variable a = ( ((2*3.141592654)*(w[2]^2) )^0.5 ) 
	Variable b = ( ((2*3.141592654)*(w[2]^2 + w[3]^2) )^0.5 )
	Variable c = ( ((2*3.141592654)*(w[2]^2 + (2*w[3]^2)) )^0.5 )
	Variable d = ( ((2*3.141592654)*(w[2]^2 + (3*w[3]^2)) )^0.5 )
	Variable e = ( ((2*3.14)*(w[2]^2 + (4*w[3]^2)) )^0.5 )
	Variable f = (2*(w[2]^2))
	Variable g = (2*(w[2]^2 + w[3]^2))
	Variable h = (2*(w[2]^2 + (2*w[3]^2)))
	Variable i = (2*(w[2]^2 + (3*w[3]^2)))
	Variable j = (2*(w[2]^2 + (4*w[3]^2)))
	Variable k1 = x^2
	Variable l1 = (x - w[1])^2
	Variable m1 = (x - (2*w[1]))^2
	Variable n1 = (x - (3*w[1]))^2
	Variable o1 = (x - (4*w[1]))^2
	Variable k2 = (x-5e-12)^2
	Variable l2 = ((x-5e-12) - w[1])^2
	Variable m2 = ((x-5e-12) - (2*w[1]))^2
	Variable n2 = ((x-5e-12) - (3*w[1]))^2
	Variable o2 = ((x-5e-12) - (4*w[1]))^2
	Variable p1 = exp( -w[0] ),        p2 = exp( -w[0]*w[7] )
	Variable q1 = p1*w[0],                q2 = p2*w[0]*w[7]
	Variable r1 = (p1*w[0]^2)/2,   r2 = (p2*(w[0]*w[7])^2)/2
	Variable s1 = (p1*w[0]^3)/6,    s2 = (p2*(w[0]*w[7])^3)/6
	Variable t1 = (p1*w[0]^4)/24,  t2 = (p2*(w[0]*w[7])^4)/24	
	Variable P0a = p1*((w[4]*w[5])/a)*exp( -k1/f ),P0b = p2*((w[4]*w[6])/a)*exp( -k2/f )
	Variable P1a = q1*((w[4]*w[5])/b)*exp( -l1/g ),P1b = q2*((w[4]*w[6])/b)*exp( -l2/g )
	Variable P2a = r1*((w[4]*w[5])/c)*exp( -m1/h ),P2b = r2*((w[4]*w[6])/c)*exp( -m2/h )
	Variable P3a = s1*((w[4]*w[5])/d)*exp( -n1/i ),P3b = s2*((w[4]*w[6])/d)*exp( -n2/i )
	Variable P4a = t1*((w[4]*w[5])/e)*exp( -o1/j ),P4b = t2*((w[4]*w[6])/e)*exp( -o2/j )
	Variable w0LIM=0, w1LIM=0, w3LIM=0
	if (w[0] < w0LIM)
		w[0] = 2*w0LIM - w[0]
	endif
	if (w[1] < w1LIM)
		w[1] = 2*w1LIM - w[1]
	endif
	if (w[3] < w3LIM)
		w[3] = 2*w3LIM - w[3]
	endif
	Return(P0a+P1a+P2a+P3a+P4a+P0b+P1b+P2b+P3b+P4b)
End

//Gauss0= (exp( -pcoef[0] )*pcoef[4]*pcoef[5])/(Sqrt(2*3.14)*pcoef[2])*exp(-((ResAmp/(sqrt(2)*pcoef[2]))^2))
//Gauss1 = exp( -pcoef[0] )*pcoef[0]*(pcoef[4]*pcoef[5]/( ((2*3.14)*(pcoef[2]^2 + pcoef[3]^2) )^0.5 ))*exp( -(ResAmp - pcoef[1])^2/(2*(pcoef[2]^2 + pcoef[3]^2)))
//Gauss2 = (( exp( -pcoef[0] )*pcoef[0]^2)/2)*(pcoef[4]*pcoef[5]/( ((2*3.14)*(pcoef[2]^2 + (2*pcoef[3]^2)) )^0.5 ))*exp( -((ResAmp - (2*pcoef[1]))^2)/(2*(pcoef[2]^2 + (2*pcoef[3]^2))) )
//Gauss3 = ((exp( -pcoef[0] )*pcoef[0]^3)/6)*(pcoef[4]*pcoef[5]/( ((2*3.14)*(pcoef[2]^2 + (3*pcoef[3]^2)) )^0.5 ))*exp( -((ResAmp - (3*pcoef[1]))^2)/(2*(pcoef[2]^2 + (3*pcoef[3]^2))) )	
//Gauss4 = ((exp( -pcoef[0] )*pcoef[0]^4)/24)*(pcoef[4]*pcoef[5]/( ((2*3.14)*(pcoef[2]^2 + (4*pcoef[3]^2)) )^0.5 ))*exp( -((ResAmp - (4*pcoef[1]))^2)/(2*(pcoef[2]^2 + (4*pcoef[3]^2))) )
