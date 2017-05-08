

	
	EXTERNDEF String_equals:Near32, String_equalsIgnoreCase:Near32, String_copy:Near32,
		   String_substring_1:Near32, String_substring_2:Near32, String_charAt:Near32,
		   String_startsWith_1:Near32, String_startsWith_2:Near32, String_endsWith:Near32,
		   String_length:Near32

	EXTERNDEF String_indexOf_1:Near32, String_indexOf_2:Near32, String_indexOf_3:Near32,
		   String_lastIndexOf_1:Near32, String_lastIndexOf_2:Near32,
		   String_lastIndexOf_3:Near32, String_concat:Near32, String_replace:Near32,
		   String_toLowerCase:Near32, String_toUpperCase:Near32
		   
	INCLUDE ..\Irvine\Irvine32.inc
	INCLUDE ..\Irvine\Macros.inc
	INCLUDELIB ..\Irvine\Irvine32.lib 
	INCLUDELIB \masm32\lib\user32.lib
	INCLUDELIB \masm32\lib\kernel32.lib


		   
	; converts a string of characters to an equivalent 4-byte dword  value
	; binary value is returned into EAX register, 
	; if invalid char or too large, EAX = 0
	ascint32    PROTO Near32 stdcall, lpStringToConvert: dword
	
	; stores string from user input
	; requires the address of a string that will be large enough to hold the
	; max number of chars that can be entered plus 1 for the NULL character
	; allows a max of dlength chars to be entered
	getstring PROTO Near32 stdcall, lpStringToGet: dword, dlength: dword
	
	; converts binary dword to a printable string of ASCII chars
	; requires an address of string to hold converted value (12 bytes)
	; including the null terminator
	intasc32 PROTO Near32 stdcall, lpStringToHold: dword, dval: dword
	
	; displays the chars one at a time until NULL char (0) is reached
	; requires the address of a null-terminated characters as input
	putstring   PROTO Near32 stdcall, lpStringToPrint: dword
		   
	; converts hex value to string of ascii char codes
	; requires a value for third parameter, length of value or 0 for entire length
	hexToChar PROTO Near32 stdcall, lpDestStr: dword, lpSourceStr: dword, dLen: dword
	
setWindow MACRO dWidth:REQ, dHeight:REQ
	LOCAL dwSize, dWinSize, outHandle
	.data
	dwSize  COORD <dWidth, dHeight>
	dWinSize SMALL_RECT <0, 0, dWidth - 1, dHeight - 1>
	outHandle HANDLE ?
	
	.code	
	push eax
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov outHandle, eax	
	INVOKE SetConsoleWindowInfo, outHandle, TRUE, ADDR dWinSize
	INVOKE SetConsoleScreenBufferSize, outHandle, dwSize
	INVOKE SetConsoleWindowInfo, outHandle, TRUE, ADDR dWinSize
	INVOKE SetConsoleScreenBufferSize, outHandle, dwSize
	pop eax
ENDM

showStrings MACRO dNumStrings:REQ, lpStrArr:REQ
	LOCAL strNum, dNum, dTemp, stringLoop, continueLoopL
	.data
	strNum byte  2 DUP(0)
	dNum   dword ?
	dTemp  dword ?
	
	.code
	push ecx
	push esi
	push ebx
	
	mov dNum, 0
	mov ecx, dNumStrings
	mov esi, lpStrArr

stringLoop:
	mWrite <9, "[">
	INVOKE intasc32, ADDR strNum, dNum
	mWriteString strNum
	mWrite <"] ">
	
	mov ebx, [esi]
	.IF (ebx == 0)
		jmp continueLoopL
	.ELSE
		INVOKE putstring, ebx
	.ENDIF
	
continueLoopL:
	inc dNum
	add esi, type dword
	CALL CRLF
	loop stringLoop	
	
	pop ebx
	pop esi
	pop ecx
ENDM


comment @
showList MACRO strTitle:REQ, midClear:REQ, 
	botClear, botMsg, lastClear, lastMsg
	INVOKE clearScreen, 25
	mWrite <9, "&strTitle">
	INVOKE clearScreen, midClear
	showStrings 10, lpStrList
	IFNB <botClear>
		INVOKE clearScreen, botClear
	ENDIF
	IFNB <botMsg>
		mWrite <9, "&botMsg">
	ENDIF
	IFNB <lastClear>
		INVOKE clearScreen, lastClear
	ENDIF
	IFNB <lastMsg>
		mWrite "&lastMsg"
	ENDIF
ENDM
@	