;**************************************************************************
; Name:   		Hernan Rangel & Peter Tang
; Program:		MASM4.asm
; Class:        CS 3B
; Project:		MASM4
; Date:         May 8, 2017
; Purpose:
;		This is an include file accompanying the MASM4.asm source code
;**************************************************************************
	
	; String1.asm methods
	EXTERNDEF String_equals:Near32, String_equalsIgnoreCase:Near32, String_copy:Near32,
		   String_substring_1:Near32, String_substring_2:Near32, String_charAt:Near32,
		   String_startsWith_1:Near32, String_startsWith_2:Near32, String_endsWith:Near32,
		   String_length:Near32
	
	; String2.asm methods
	EXTERNDEF String_indexOf_1:Near32, String_indexOf_2:Near32, String_indexOf_3:Near32,
		   String_lastIndexOf_1:Near32, String_lastIndexOf_2:Near32,
		   String_lastIndexOf_3:Near32, String_concat:Near32, String_replace:Near32,
		   String_toLowerCase:Near32, String_toUpperCase:Near32
	
	; inc files from irvine library
	INCLUDE ..\Irvine\Irvine32.inc
	INCLUDE ..\Irvine\Macros.inc
	
	; lib files from irvine library
	INCLUDELIB ..\Irvine\Irvine32.lib 
	INCLUDELIB \masm32\lib\user32.lib
	INCLUDELIB \masm32\lib\kernel32.lib
	
	; gets a count of how many new lines
	; outputs new lines to console
	clearScreen PROTO Near32 STDCALL, dCount:dword
	
	; gets addr of array of strings
	; outputs strings in array to console
	viewStrings PROTO Near32 STDCALL, lpStrList:dword
	
	; gets heap handle, ptr to array of str ptrs, ptr to str count
	; adds string to array of str ptrs
	addString PROTO Near32 STDCALL, hHeap:HANDLE, lpStrList:dword, lpStrCount:dword	

	; gets heap handle, ptr to array of str ptrs, ptr to str count
	; gets index of array without str addr
	getEmptyIndex PROTO Near32 STDCALL, lpStrList:dword, lpNum:dword
	
	; gets heap handle, ptr to array of str ptrs, ptr to str count
	; deletes string from array
	delString PROTO Near32 STDCALL, hHeap:HANDLE, lpStrList:dword, lpStrCount:dword
	
	; gets heap handle, ptr to array of str ptrs, ptr to str count
	; edits a string in the array
	editString PROTO Near32 STDCALL, hHeap:HANDLE, lpStrList:dword, lpStrCount:dword
	
	; gets heap handle, ptr to array of str ptrs, ptr to str count
	; searches for subseq in list of str
	searchString PROTO Near32 STDCALL, hHeap:HANDLE, lpStrList:dword, lpStrCount:dword

	; gets ptr to array of str ptrs
	; gets total mem consumption
	memConsumption PROTO Near32 STDCALL, lpStrList:dword

	; gets a character without echo
	; returns character to AL register
	getch PROTO Near32 stdcall
	
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
	
;-----------------------------------------------------
setWindow MACRO dWidth:REQ, dHeight:REQ
	LOCAL dwSize, dWinSize, outHandle
;
; receives a width and height for buffer/console win
; sets the buffer and console window
;-----------------------------------------------------
	.data															; data directive
	dwSize  COORD <dWidth, dHeight>									; coord struct
	dWinSize SMALL_RECT <0, 0, dWidth - 1, dHeight - 1>				; window rect struct
	outHandle HANDLE ?												; stdout handle
	.code															; code dir
	push eax														; save eax on stack
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE							; get stdout handle
	mov outHandle, eax												; set outhandle
	INVOKE SetConsoleWindowInfo, outHandle, TRUE, ADDR dWinSize		; set window
	INVOKE SetConsoleScreenBufferSize, outHandle, dwSize			; set console
	INVOKE SetConsoleWindowInfo, outHandle, TRUE, ADDR dWinSize		; set window
	INVOKE SetConsoleScreenBufferSize, outHandle, dwSize			; set console
	pop eax															; restore eax
ENDM																; endmacro

;-----------------------------------------------------
showStrings MACRO dNumStrings:REQ, lpStrArr:REQ
	LOCAL strNum, dNum, dTemp, stringLoop, continueLoopL
;
; receives number of strings, pointer to array of str
; shows strings in array if str ptrs
;-----------------------------------------------------
	.data															; data dir
	strNum byte  2 DUP(0)											; char str
	dNum   dword ?													; temp number
	dTemp  dword ?													; temp var
	.code															; code dir
	push ecx														; save ecx
	push esi														; save esi
	push ebx														; save ebx
	mov dNum, 0														; init dnum
	mov ecx, dNumStrings											; set ecx num str
	mov esi, lpStrArr												; set esi arr ptr
stringLoop:															; loop to output str
	mWrite <9, "[">													; show bracket
	INVOKE intasc32, ADDR strNum, dNum								; convert int to char
	mWriteString strNum												; show char
	mWrite <"] ">													; show bracket
	mov ebx, [esi]													; set str addr to ebx
	.IF (ebx == 0)													; check if addr null
		jmp continueLoopL											; continue
	.ELSE															; else dir
		mWrite '"'													; show quote
		INVOKE putstring, ebx										; show string
		mWrite '"'													; show quote
	.ENDIF															; endif dir
continueLoopL:														; loop after output str
	inc dNum														; next index
	add esi, type dword												; next addr in arr
	CALL CRLF														; show space
	loop stringLoop													; show next line/index
	pop ebx															; restore ebx
	pop esi															; restore esi
	pop ecx															; restore ecx
ENDM