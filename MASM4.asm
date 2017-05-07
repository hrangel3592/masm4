;**************************************************************************
; Name:   		Hernan Rangel & Peter Tang
; Program:		MASM4.asm
; Class:        CS 3B
; Project:		MASM4
; Date:         May 3, 2017
; Purpose:
;
;**************************************************************************

	.486					; enables assembly nonprivileged instructions for 80486 processor
	
	INCLUDE MASM4.inc
	
	clearScreen PROTO Near32 STDCALL, dCount:dword
ExitProcess	PROTO Near32 stdcall, dwExitCode:dword
getch		PROTO Near32 stdcall	;Returns charater in the AL register
putch		PROTO Near32 stdcall, bchar:byte

	.data
strHeader	byte  13, 10, 9, 9, "MASM4 STRING MANAGER", 13, 10, 
				  13, 10, 9, "Name:        Hernan Rangel & ",	; name of author
				  "Peter Tang", 13, 10, 						; name of author
			      9, "Program:     MASM4.asm", 13, 10, 			; name of lab
			      9, "Class:       CS3B", 13, 10, 			    ; name of class
			      9, "Date:        May 10, 2017", 13, 10, 0 	; date of lab
strMenu  	byte  13, 10, 13, 10, 9, 
				  "MASM4 STRING MANAGER MENU", 13, 10, 13, 10,
				  "<1> View all strings", 13, 10, ;menu for available options
				  "<2> Add string", 13, 10,
				  "<3> Delete string", 13, 10,
				  "<4> Edit string", 13, 10,
				  "<5> String search", 13, 10,
				  "<6> String Array Memory Consumption", 13, 10,
				  "<7> Quit"
			byte  9 DUP(13, 10)
			byte  "Please insert selection: ", 0
strCont 	byte  13, 10, "Press any key to continue...", 0		




		
	strInput byte  ?
;these strings are for testing the menu
strError   byte   "Error", 13, 0
strView    byte   "strView test", 13, 0
strAdd	   byte   "strAdd test", 13, 0
strDelete	 byte   "strDelete test", 13, 0
strEdit	   byte   "strEdit test", 13, 0
strSearch  byte   "strSearch test", 13, 0
strMem	   byte   "strMem test", 13, 0
	.code							; directive marking the program's entry point
main PROC							; label for entry point of code segment
		setWindow 175, 25
				
		INVOKE clearScreen, 50
		mWriteString strHeader
		INVOKE clearScreen, 9
		mWriteString strCont
		INVOKE ReadChar
		
		INVOKE clearScreen, 50
		mWriteString strMenu
		mov esi, 0; moves 0 into esi to be used as an index
		jmp getNum

menu: ; label that prints menu and prompts user for input.
;		call ClrScr; clears screen
		mWrite 13
		mWriteString strMenu; prints out menu for user
		mov esi, 0
		jmp getNum; jumps to the get number label
getNum:
		INVOKE getch ; calls the getch prototype
		cmp al, 8
		je	backspace ; if(al = 8) then it jumps to backspace
		cmp al, 13
		je 	return
		cmp esi, 1; if 1 character has been entered no more inputs will be allowed
							; but it will allow user to delete input and enter a new one
		je	getNum; loops back to continually allow user to change input
		mov strInput, al; moves contents of al into the strInput
		invoke putch, byte ptr al; prints character stored in al
		inc esi				 ; keeps tracck of characters input
		jmp getNum; keeps looping while enter is not entered

backspace:
		cmp esi,0	;checks to see if this is the first spot in array
		je getNum; if(esi = 0) then it jumps to getNum
		invoke putch, 8; else it prints out a backspace then a blank then goes back one
		invoke putch, 32; prints out blank
		invoke putch, 8; goes back one
		dec esi; decrements 1 from esi to go back one spot
		mov strInput, 0
		jmp getNum

return:
		cmp esi, 0; if esi is just enter it jumps to the exit label
		je finish

		.IF     strInput == '1'; if 1 is input prints out string aray
			jmp viewStrings
		.ELSEIF strInput == '2'; if 2 is input it adds a string to array
			jmp addString
		.ELSEIF strInput == '3'; if 3 it deletes a string from array, chosen by the
													 ; 	user
			jmp deleteString
		.ELSEIF strInput == '4'; if 4 it allows user to edit the strings
			jmp editString
		.ELSEIF strInput == '5'; if 5 allows user to search for string in array
			jmp stringSearch
		.ELSEIF strInput == '6'; if 6 prints out memory consumption of string array
			jmp arrayMem
		.ELSEIF strInput == '7'; if 7 it quits
			jmp finish
		.ELSE									 ; if anything else is entered it jumps to error
			jmp error
		.ENDIF

viewStrings:
		mWriteString strView
		jmp menu
addString:
		mWriteString strAdd
		jmp menu
deleteString:
		mWriteString strDelete
		jmp menu
editString:
		mWriteString strEdit
		jmp menu
stringSearch:
		mWriteString strSearch
		jmp menu
arrayMem:
		mWriteString strMem
		jmp menu



error:
		mWriteString strError
finish:
		exit
main ENDP



	



clearScreen PROC USES ECX, 
	dCount:dword
	mov ecx, dCount
clsLoop:
	call crlf
	loop clsLoop
	ret
clearScreen ENDP




END main