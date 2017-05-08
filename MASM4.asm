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
	showList PROTO Near32 STDCALL, lpStrList:dword
	addString PROTO Near32 STDCALL, hHeap:HANDLE, lpStrList:dword, lpStrCount:dword	
	getEmptyIndex PROTO Near32 STDCALL lpStrList:dword, lpNum:dword
	delString PROTO Near32 STDCALL, hHeap:HANDLE, lpStrList:dword, lpStrCount:dword
	editString

	
	getch		PROTO Near32 stdcall	;Returns charater in the AL register
	putch		PROTO Near32 stdcall, bchar:byte

HEAP_START = 1300
HEAP_MAX   = 2000000
CHAR_MAX   = 127

	.data
hThisHeap   HANDLE ?
strHeader	byte  13, 10, 9, 9, "MASM4 STRING MANAGER", 13, 10, 
				  13, 10, 9, "Name:        Hernan Rangel & ",	; name of author
				  "Peter Tang", 13, 10, 						; name of author
			      9, "Program:     MASM4.asm", 13, 10, 			; name of lab
			      9, "Class:       CS3B", 13, 10, 			    ; name of class
			      9, "Date:        May 10, 2017", 13, 10, 0 	; date of lab
strMenu  	byte  13, 10, 13, 10, 9, 9,
				  "MASM4 STRING MANAGER MENU", 13, 10, 13, 10,
				  9, "<1> View All Strings", 13, 10, ;menu for available options
				  9, "<2> Add String", 13, 10,
				  9, "<3> Delete String", 13, 10,
				  9, "<4> Edit String", 13, 10,
				  9, "<5> String Search", 13, 10,
				  9, "<6> String Array Memory Consumption", 13, 10,
				  9, "<7> Quit", 0
			byte  8 DUP(13, 10)
strInsert	byte  "Please enter a selection: ", 0
strCont 	byte  "Press any key to continue...", 0	
	
dStrList	dword 10 DUP(0)
strInput    byte  2 DUP(0)
;strNum		byte  2 DUP(0)
dStrCnt		dword 0
;dTemp		dword 0
strBuffer	byte  128 DUP (0)

strTest		byte  "testing", 0



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
		
		INVOKE HeapCreate, 0, HEAP_START, HEAP_MAX
		.IF eax == NULL
			CALL WriteWindowsMsg
			jmp exitL
		.ELSE 
			mov hThisHeap, eax
		.ENDIF
		
		setWindow 170, 300
				
		INVOKE clearScreen, 25
		mWriteString strHeader
		INVOKE clearScreen, 9
		mWriteString strCont
		INVOKE ReadChar

		INVOKE clearScreen, 25
		mWriteString strMenu
		INVOKE clearScreen, 8			
		mWriteString strInsert
		INVOKE getString, ADDR strInput, 1
		INVOKE ascint32, ADDR strInput
	
		.WHILE (EAX != 7)
		
			.IF(EAX < 1 || EAX > 7)
				INVOKE clearScreen, 25
				mWriteString strMenu
				INVOKE clearScreen,5
				mWrite 'Invalid input.  "'
				mWriteString strInput
				mWrite <'" was entered.  '>
				mWrite <"Please enter a number from 1 to 7.">
				INVOKE clearScreen, 3
				jmp getInputL
			.ENDIF
			
			
			.IF(EAX == 1)
				INVOKE showList, ADDR dStrList
			.ELSEIF (EAX == 2)
				INVOKE addString, hThisHeap, ADDR dStrList, ADDR dStrCnt
			.ELSEIF (EAX == 3)
				INVOKE delString, hThisHeap, ADDR dStrList, ADDR dStrCnt
			.ELSEIF (EAX == 4)
				INVOKE editString, hThisHeap, ADDR dStrList
			.ENDIF

			INVOKE clearScreen, 25
			mWriteString strMenu
			INVOKE clearScreen, 8
getInputL:
			mov EAX, NULL
			mWriteString strInsert
			INVOKE getString, ADDR strInput, 1
			INVOKE ascint32, ADDR strInput
		.ENDW


exitL:
	INVOKE HeapDestroy, hThisHeap
	INVOKE ExitProcess, 0
main ENDP


clearScreen PROC Near32 STDCALL USES ECX, 
	dCount:dword
	mov ecx, dCount
clsLoop:
	call crlf
	loop clsLoop
	ret
clearScreen ENDP

;-----------------------------------------------------
showList PROC Near32 STDCALL USES EAX,
	lpStrList:dword

	INVOKE clearScreen, 25
	mWrite <9, "<1> View All Strings">
	INVOKE clearScreen, 2	
	showStrings 10, lpStrList	
	INVOKE clearScreen, 6
	mWriteString strCont
	INVOKE ReadChar
	ret
showList ENDP

;-----------------------------------------------------
addString PROC Near32 STDCALL USES EDI ECX EBX EAX ESI,
	hHeap:HANDLE,
	lpStrList:dword,
	lpStrCount:dword
	LOCAL strTemp[132]:byte,
		  dTemp:dword,
		  stdInHandle:HANDLE,
		  lpTemp:dword
getInputL:
	INVOKE clearScreen, 25
	mWrite <9, "<2> Add String">
	INVOKE clearScreen, 2
	showStrings 10, lpStrList
	
	
	mov ecx, lpStrCount
	.IF (dword ptr [ecx] < 10)
		INVOKE clearScreen, 3
		mWrite "Press ENTER to cancel."
		INVOKE clearSCreen, 3
		mWrite "Enter new string (Max 127 characters): "
		
	;	INVOKE getEmptyIndex, lpStrList, ADDR dTemp
	;	mov eax, dTemp
	
		INVOKE getEmptyIndex, lpStrList, ADDR dTemp		
		
		INVOKE getString, ADDR strTemp, 127
		mov bl, [strTemp]
		
		.IF (bl != 0)
			lea esi, strTemp
			push esi
			CALL String_length
					
			inc eax
			INVOKE HeapAlloc, hHeap, HEAP_ZERO_MEMORY, eax
			
			.IF (eax == NULL)
				jmp errorHeapL
			.ENDIF
			
			mov lpTemp, eax
			push eax
			push esi
			CALL String_copy
.IF (EAX != lpTemp)
	mwrite "fucking christ"
	call readchar
.ENDIF						
			mov edi, lpStrList
			mov esi, [dTemp]
			mov [edi + esi * TYPE lpStrList], eax
			
			INVOKE clearScreen, 25
			mWrite <9, "<2> Add String">
			INVOKE clearScreen, 2
			showStrings 10, lpStrList
			INVOKE clearScreen, 3
			mWrite <"SUCCESSFULLY ADDED STRING ">
						
			INVOKE intasc32, ADDR strTemp, [dTemp]
			INVOKE putstring, ADDR strTemp
			mWrite <': "'>
			INVOKE putstring, lpTemp
			mWrite <'"'>
			
			mov ecx, lpStrCount
			inc dword ptr [ecx]
			
			INVOKE clearScreen, 3
			mWriteString strCont
			INVOKE ReadChar
			jmp getInputL
		.ELSE
			INVOKE clearScreen, 25
			mWrite <9, "<2> Add String">
			INVOKE clearScreen, 2
			showStrings 10, lpStrList
			INVOKE clearScreen, 3
			mWrite "** No string entered.  Returning to main menu. **"
		.ENDIF
		
	.ELSE
		INVOKE clearScreen, 3
		mWrite "** ERROR String Manager is FULL.  "
		mWrite "Please delete a string before adding. **"
	.ENDIF

	INVOKE clearScreen, 3
	mWriteString strCont
	INVOKE ReadChar
returnL:
	ret
errorHeapL:
	mWrite "**ERROR Not enough memory."
		mWriteString strCont
	INVOKE ReadChar
	jmp returnL
addString ENDP


;-----------------------------------------------------
getEmptyIndex PROC Near32 STDCALL USES ECX EAX ESI EDI,
	lpStrList:dword,
	lpNum:dword
	LOCAL strTemp[80]:byte,
	dnum:dword
	
	mov eax, lpNum
	mov ecx, 0
	mov esi, lpStrList	
	.WHILE (ecx < 10)

		mov edi, [esi]

		.IF (edi != 0)
			inc ecx
			add esi, TYPE lpStrList
		.ELSE
			mov [eax], ecx
			jmp returnL
		.ENDIF
	.ENDW
	
	mov dword ptr [eax], -1
returnL:
	ret
getEmptyIndex ENDP


;-----------------------------------------------------
delString PROC Near32 STDCALL USES EDI ECX EBX EAX ESI,
	hHeap:HANDLE,
	lpStrList:dword,
	lpStrCount:dword
	LOCAL strTemp[2]:byte,
		  StrBuff[2]:byte,
		  lpTemp:dword,
		  dTemp:dword
delMainL:
	INVOKE clearScreen, 25
	mWrite <9, "<3> Delete String">
	INVOKE clearScreen, 2
	showStrings 10, lpStrList

	mov ecx, lpStrCount
	.IF (dword ptr [ecx] > 0)
		INVOKE clearScreen, 3
		mWrite "Press ENTER to cancel."
		INVOKE clearSCreen, 3
		mWrite "Please enter string index to delete: "
checkInputL:
		INVOKE getString, ADDR strTemp, 1
		mov bl, [strTemp]
		
		.IF(bl != 0)
			INVOKE ascint32, ADDR strTemp
			mov ebx, eax
			
			mov esi, lpStrList
			lea edi, [esi + ebx * TYPE lpStrList]
			mov ecx, [edi]
			.IF (ebx > 0 && ebx < 10 && ecx != 0)
getConfirmL:
				INVOKE clearScreen, 25
				mWrite <9, "<3> Delete String">
				INVOKE clearScreen, 2
				showStrings 10, lpStrList
				INVOKE clearScreen, 3
				mWrite <"Deleting: [">
				INVOKE putstring, ADDR strTemp
				mWrite <"] ">
				INVOKE putstring, [edi]
				INVOKE clearScreen, 3
				mWrite <"CONFIRM DELETION Y/N: ">
				INVOKE getString, ADDR strBuffer, 1
				mov bl, byte ptr [strBuffer]
				and bl, 11011111b			; make uppercase
				
				.IF (bl == 'Y')
					INVOKE HeapFree, hHeap, 0, [edi]
					
					.if eax == null
						call crlf
						call writewindowsmsg
						call readchar
					.endif

					mov dword ptr [edi], 0
					mov ecx, lpStrCount
					dec dword ptr [ecx]
					INVOKE clearScreen, 25
					mWrite <9, "<3> Delete String">
					INVOKE clearScreen, 2
					showStrings 10, lpStrList
					INVOKE clearScreen, 3
					mWrite <"SUCCESSFULLY DELETED STRING: [">
					INVOKE putstring, ADDR strTemp
					mWrite <"] ">
					
					INVOKE clearScreen, 3
					mWriteString strCont
					INVOKE ReadChar
					jmp delMainL					
				.ELSEIF (bl == 'N')
					jmp delMainL
				.ELSE
					jmp getConfirmL
				.ENDIF
			.ELSE
				INVOKE clearScreen, 25
				mWrite <9, "<3> Delete String">
				INVOKE clearScreen, 2
				showStrings 10, lpStrList

				INVOKE clearScreen, 3
				mWrite 'Invalid input.  "'
				INVOKE putstring, ADDR strTemp
				mWrite <'" was entered.  '>
				mWrite "Press ENTER to cancel."
				INVOKE clearSCreen, 3
				mWrite "Please enter string index to delete: "
				jmp checkInputL
			.ENDIF
			
			
		.ELSE
			INVOKE clearScreen, 25
			mWrite <9, "<3> Delete String">
			INVOKE clearScreen, 2
			showStrings 10, lpStrList
			INVOKE clearScreen, 3
			mWrite "** No string selected.  Returning to main menu. **"
		.ENDIF
	.ELSE
		INVOKE clearScreen, 3
		mWrite "** ERROR String Manager is EMPTY.  "
		mWrite "Please add a string before deleting. **"
	.ENDIF

	INVOKE clearScreen, 3
	mWriteString strCont
	INVOKE ReadChar

	ret

delString ENDP




;-----------------------------------------------------
editString PROC Near32 STDCALL USES EDI ECX EBX EAX ESI,
	hHeap:HANDLE,
	lpStrList:dword
	LOCAL strTemp[2]:byte,
		  StrBuff[2]:byte,
		  lpTemp:dword,
		  dTemp:dword
delMainL:
	INVOKE clearScreen, 25
	mWrite <9, "<4> Edit String">
	INVOKE clearScreen, 2
	showStrings 10, lpStrList

	mov ecx, lpStrCount
	.IF (dword ptr [ecx] > 0)
		INVOKE clearScreen, 3
		mWrite "Press ENTER to cancel."
		INVOKE clearSCreen, 3
		mWrite "Please enter string index to edit: "
checkInputL:
		INVOKE getString, ADDR strTemp, 1
		mov bl, [strTemp]
		
		.IF(bl != 0)
			INVOKE ascint32, ADDR strTemp
			mov ebx, eax
			
			mov esi, lpStrList
			lea edi, [esi + ebx * TYPE lpStrList]
			mov ecx, [edi]
			.IF (ebx > 0 && ebx < 10 && ecx != 0)
getConfirmL:
				INVOKE clearScreen, 25
				mWrite <9, "<4> Edit String">
				INVOKE clearScreen, 2
				showStrings 10, lpStrList
				INVOKE clearScreen, 3
				mWrite <"Deleting: [">
				INVOKE putstring, ADDR strTemp
				mWrite <"] ">
				INVOKE putstring, [edi]
				INVOKE clearScreen, 3
				mWrite <"CONFIRM DELETION Y/N: ">
				INVOKE getString, ADDR strBuffer, 1
				mov bl, byte ptr [strBuffer]
				and bl, 11011111b			; make uppercase
				
				.IF (bl == 'Y')
					INVOKE HeapFree, hHeap, 0, [edi]
					
					.if eax == null
						call crlf
						call writewindowsmsg
						call readchar
					.endif

					mov dword ptr [edi], 0
					mov ecx, lpStrCount
					dec dword ptr [ecx]
					INVOKE clearScreen, 25
					mWrite <9, "<4> Edit String">
					INVOKE clearScreen, 2
					showStrings 10, lpStrList
					INVOKE clearScreen, 3
					mWrite <"SUCCESSFULLY editD STRING: [">
					INVOKE putstring, ADDR strTemp
					mWrite <"] ">
					
					INVOKE clearScreen, 3
					mWriteString strCont
					INVOKE ReadChar
					jmp delMainL					
				.ELSEIF (bl == 'N')
					jmp delMainL
				.ELSE
					jmp getConfirmL
				.ENDIF
			.ELSE
				INVOKE clearScreen, 25
				mWrite <9, "<4> Edit String">
				INVOKE clearScreen, 2
				showStrings 10, lpStrList

				INVOKE clearScreen, 3
				mWrite 'Invalid input.  "'
				INVOKE putstring, ADDR strTemp
				mWrite <'" was entered.  '>
				mWrite "Press ENTER to cancel."
				INVOKE clearSCreen, 3
				mWrite "Please enter string index to edit: "
				jmp checkInputL
			.ENDIF
			
			
		.ELSE
			INVOKE clearScreen, 25
			mWrite <9, "<4> Edit String">
			INVOKE clearScreen, 2
			showStrings 10, lpStrList
			INVOKE clearScreen, 3
			mWrite "** No string selected.  Returning to main menu. **"
		.ENDIF
	.ELSE
		INVOKE clearScreen, 3
		mWrite "** ERROR String Manager is EMPTY.  "
		mWrite "Please add a string before deleting. **"
	.ENDIF

	INVOKE clearScreen, 3
	mWriteString strCont
	INVOKE ReadChar

	ret

editString ENDP














END main