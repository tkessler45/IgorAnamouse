#pragma rtGlobals=1		// Use modern global access method.
#pragma version=6.2		// Shipped with Igor 6.2

//	CsrTraceName(GraphNameStr, CsrName)
//
// 	Returns string containing the name of the trace that has the named cursor on it.
// 		graphNameStr		String containing the name of a graph window. May be "" to use the top graph window
//		csrNameStr			String containing the name of a cursor, such as "A" or "B"
//	If the named graph doesn't have the named cursor active, the function returns "".
//	If csrNameStr doesn't contain a valid cursor name, function returns "".
//	The returned string is suitable for use with $ in a ModifyGraph command:
//		ModifyGraph mode($CsrTraceName("", "A"))=2	// set cursor trace to dots mode
//
// LH040611, v1.01: had been broken for a long time due to use of Cursor/P rather than just Cursor.
// JP100625 ,v6.2: Rewritten to use CsrInfo()

Function/S CsrTraceName(graphNameStr, csrNameStr)
	String graphNameStr, csrNameStr
	
	if (strlen(graphNameStr) == 0)
		graphNameStr = WinName(0, 1)
	endif
	if (strlen(graphNameStr) == 0 || WinType(graphNameStr) != 1)
		return ""	// no graphs or no graph by that name
	endif

	String info= CsrInfo($csrNameStr, graphNameStr)
	if (strlen(info) == 0)
		return ""	// no cursor by that name on the graph
	endif

	String traceName= StringByKey("TNAME", info)	// can be "" if the cursor is attached to an image
	
	return traceName
End
