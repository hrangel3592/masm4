	INCLUDE ..\Irvine\Irvine32.inc
	INCLUDE ..\Irvine\Macros.inc
	INCLUDELIB ..\Irvine\Irvine32.lib 
	INCLUDELIB \masm32\lib\user32.lib
	INCLUDELIB \masm32\lib\kernel32.lib

	
	EXTERNDEF String_equals:Near32, String_equalsIgnoreCase:Near32, String_copy:Near32,
		   String_substring_1:Near32, String_substring_2:Near32, String_charAt:Near32,
		   String_startsWith_1:Near32, String_startsWith_2:Near32, String_endsWith:Near32,
		   String_length:Near32

	EXTERNDEF String_indexOf_1:Near32, String_indexOf_2:Near32, String_indexOf_3:Near32,
		   String_lastIndexOf_1:Near32, String_lastIndexOf_2:Near32,
		   String_lastIndexOf_3:Near32, String_concat:Near32, String_replace:Near32,
		   String_toLowerCase:Near32, String_toUpperCase:Near32
		   

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