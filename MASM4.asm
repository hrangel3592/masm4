;**************************************************************************
; Name:   		Hernan Rangel & Peter Tang
; Program:		MASM4.asm
; Class:        CS 3B
; Project:		MASM4
; Date:         May 8, 2017
; Purpose:
;		This program is a console interface that allows a user to add,
;		delete, and edit 10 strings up to 128 bytes long including the null
;		terminator.  The program also allows the user to search for
;		a subsequence within all relevant strings.  Finally, the program
;		uses dynamic memory and displays the total amount of bytes taken
;		up by all the strings.
;**************************************************************************

	.486				; enables assembly nonprivileged instructions for 80486 processor
	INCLUDE MASM4.inc	; include file contains all declarations

HEAP_START = 1200		; initial heap size
HEAP_MAX   = 2000000	; max heap size
CHAR_MAX   = 127		; max number of characters to be entered

	.data				; directive for declaring data
strHeader	byte  13, 10, 9, 9, "MASM4 STRING MANAGER", 13, 10, ; title of program
				  13, 10, 9, "Name:        Hernan Rangel & ",	; name of author
				  "Peter Tang", 13, 10, 						; name of author
			      9, "Program:     MASM4.asm", 13, 10, 			; name of lab
			      9, "Class:       CS3B", 13, 10, 			    ; name of class
			      9, "Date:        May 10, 2017", 13, 10, 0 	; date of lab
strMenu1  	byte  13, 10, 13, 10, 9, 9,							; spacing before menu
				  "MASM4 STRING MANAGER MENU", 13, 10, 13, 10,	; title of program
				  9, "<1> View All Strings", 13, 10, 			; option view all strings
				  9, "<2> Add String", 13, 10, 0				; option add string
strMenu2	byte  9, "<3> Delete String", 13, 10,				; option delete string
				  9, "<4> Edit String", 13, 10,					; option to edit string
				  9, "<5> String Search", 13, 10,				; option for string search
				  9, "<6> String Array Memory Consumption", 	; option to get memory
				  13, 10, 9, "<7> Quit", 0						; option to quit
strInsert	byte  "Please enter a selection: ", 0				; prompt to enter selection
strCont 	byte  "Press any key to continue...", 0				; press any key to continue
dStrList	dword 10 DUP(0)										; array of str pointers
strInput    byte  2 DUP(0)										; single char input str
dStrCnt		 dword 0											; count of strings in list
strBuffer	byte  132 DUP (0)									; input buffer
hThisHeap   HANDLE ?											; heap handle
dMemConsum dword 0												; total memory used

	.code			; directive marking the program's entry point
main PROC			; label for entry point of code segment
		INVOKE HeapCreate, 0, HEAP_START, HEAP_MAX				; create private heap
		.IF eax == NULL											; check if return is null
			CALL WriteWindowsMsg								; show errors
			jmp exitL											; exit program
		.ELSE 													; else condition
			mov hThisHeap, eax									; save heap handle
		.ENDIF													; end if
		setWindow 170, 25										; force window size
		INVOKE clearScreen, 25									; clear screen 25 spaces
		mWriteString strHeader									; show header
		INVOKE clearScreen, 9									; show 9 spaces
		mWriteString strCont									; show continue message
		INVOKE getch											; phantom char input
		INVOKE clearScreen, 25									; clear screen 25 spaces
		mWriteString strMenu1									; show menu 1st part
		mWriteString strMenu2									; show menu 2nd part
		INVOKE clearScreen, 8									; show 8 spaces
		mWriteString strInsert									; prompt for input
		INVOKE getString, ADDR strInput, 1						; method to get input
		INVOKE ascint32, ADDR strInput							; convert input to number
		.WHILE (EAX != 7)										; exit on 7
			.IF(EAX < 1 || EAX > 7)								; error check
				INVOKE clearScreen, 25							; clear screen 25 spaces
				mWriteString strMenu1							; show menu 1st part
				mWriteString strMenu2							; show menu 2nd part
				INVOKE clearScreen,5							; clear screen 5 spaces
				mWrite <9, 'Invalid input.  "'>					; invalid message prompt
				mWriteString strInput							; invalid message prompt
				mWrite <'" was entered.  '>						; invalid message prompt
				mWrite <"Please enter a number from 1 to 7.">	; invalid message prompt
				INVOKE clearScreen, 3							; clear screen 3 spaces
				jmp getInputL									; loop to get input
			.ENDIF												; end input
			.IF(EAX == 1)										; option 1 all strings
				INVOKE viewStrings, ADDR dStrList				; call view strings method
			.ELSEIF (EAX == 2)									; optoin 2 add string
				INVOKE addString, hThisHeap, ADDR dStrList, 	; call addstring
					ADDR dStrCnt								; pass str count
			.ELSEIF (EAX == 3)									; option 3 delete string
				INVOKE delString, hThisHeap, ADDR dStrList,		; call delete string
					ADDR dStrCnt								; pass str count
			.ELSEIF (EAX == 4)									; option 4 edit string
				INVOKE editString, hThisHeap, ADDR dStrList,	; call edit string
					ADDR dStrCnt								; pass str count
			.ELSEIF (EAX == 5)									; option 5 search string
				INVOKE searchString, hThisHeap, ADDR dStrList,	; call search string
					ADDR dStrCnt								; pass str count
			.ELSEIF (EAX == 6)									; option 6
				INVOKE memConsumption, ADDR dStrList			; call total mem
			.ENDIF												; end if directive
			INVOKE clearScreen, 25								; clear screen 25 spaces
			mWriteString strMenu1								; show menu 1st part
			mWriteString strMenu2								; show menu 2nd part
			INVOKE clearScreen, 8								; show 8 spaces
getInputL:														; get input label
			mov EAX, NULL										; clear eax
			mWriteString strInsert								; prompt for input
			INVOKE getString, ADDR strInput, 1					; get uuser input
			INVOKE ascint32, ADDR strInput						; convert char to int
		.ENDW													; end of loop
		INVOKE clearScreen, 25									; clear screen 25 spaces
		INVOKE clearScreen, 15									; show new line
		mWrite <9, "Thanks for using our program.">				; end message
		INVOKE clearScreen, 12									; show new line
exitL:															; exit label
	INVOKE HeapDestroy, hThisHeap								; destroy private heap
	INVOKE ExitProcess, 0										; call exit
main ENDP														; end of main proc

;-----------------------------------------------------
clearScreen PROC Near32 STDCALL USES ECX,
	dCount:dword		; count of new lines
;
; receives count of space desired
; displays the entered count of spaces
;-----------------------------------------------------
	mov ecx, dCount												; set ecx to count
clsLoop:														; loop label
	call crlf													; call display new line
	loop clsLoop												; loop to label
	ret															; return
clearScreen ENDP												; end process

;-----------------------------------------------------
viewStrings PROC Near32 STDCALL USES EAX,
	lpStrList:dword		; pointer to array of str ptrs
;
; receives a pointer to array of pointers
; shows all strings in the list
;-----------------------------------------------------
	INVOKE clearScreen, 25										; clear screen 25 spaces
	mWrite <9, "<1> View All Strings">							; header of section
	INVOKE clearScreen, 2										; show 2 spaces
	showStrings 10, lpStrList									; shows all strings
	INVOKE clearScreen, 6										; shows 6 spaces
	mWriteString strCont										; continue message
	INVOKE getch												; phantom input
	ret															; return
viewStrings ENDP												; end proc

;-----------------------------------------------------
addString PROC Near32 STDCALL USES EDI ECX EBX EAX ESI,
	hHeap:HANDLE,				; handle to heap
	lpStrList:dword,			; pointer to array list
	lpStrCount:dword			; pointer to str count
	LOCAL dTemp:dword,			; temp var
		  stdInHandle:HANDLE,	; input console handle
		  lpTemp:dword			; temp pointer
;
; receives a heap, pointer to array of strings and
;	number of strings
; prompts the user, error checks, and adds strings to
;	list
;-----------------------------------------------------
	INVOKE clearScreen, 25										; clear screen 25 spaces
	mWrite <9, "<2> Add String">								; header for add string
	INVOKE clearScreen, 2										; 2 spaces
	showStrings 10, lpStrList									; show string list
	mov ecx, lpStrCount											; set ecx to str count
	.IF (dword ptr [ecx] < 10)									; check if count < 10
		INVOKE clearScreen, 3									; clear screen 3 spaces
		mWrite <9, "Press ENTER to cancel.">					; prompt to cancel
		INVOKE clearSCreen, 3									; clear screen 3 spaces
		mWrite "Enter new string (Max 127 characters): "		; prompt for input
		INVOKE getEmptyIndex, lpStrList, ADDR dTemp				; get empty space in list
		INVOKE getString, ADDR strBuffer, 127					; get string input
		mov bl, [strBuffer]										; set bl to first char
		.IF (bl != 0)											; check if bl is 0
			lea esi, strBuffer									; set esi to addr of input
			push esi											; push esi to stack
			CALL String_length									; get length of string
			inc eax												; one for space
			add dMemConsum, eax									; adds byte size to total
			push eax											; save eax	
			INVOKE HeapAlloc, hHeap, HEAP_ZERO_MEMORY, eax		; allocate space for string
			.IF (eax == NULL)									; if heap full or error
				pop eax											; restore eax
				sub dMemConsum, eax								; restore total
				jmp errorHeapL									; go to error msg
			.ENDIF												; end if
			mov lpTemp, eax										; dynamic address to var
			push eax											; push addr to stack
			push esi											; push addr of input
			CALL String_copy									; copy str to dynamic space
			mov edi, lpStrList									; set edi to array list
			mov esi, [dTemp]									; set esi to index
			mov [edi + esi * TYPE lpStrList], eax				; add dynamic str to array
			INVOKE clearScreen, 25								; clear screen
			mWrite <9, "<2> Add String">						; show title of section
			INVOKE clearScreen, 2								; show space
			showStrings 10, lpStrList							; show list of strings
			INVOKE clearScreen, 3								; show spaces
			mWrite <9, "SUCCESSFULLY ADDED STRING: [">			; show succes prompt
			INVOKE intasc32, ADDR strBuffer, [dTemp]			; convert index to char
			INVOKE putstring, ADDR strBuffer					; show index
			mWrite <'] "'>										; show bracket
			INVOKE putstring, lpTemp							; show string
			mWrite <'"'>										; show quotes
			mov ecx, lpStrCount									; set ecx to str count
			inc dword ptr [ecx]									; inc count
		.ELSE													; else directive
			INVOKE clearScreen, 25								; clear screen
			mWrite <9, "<2> Add String">						; add string header
			INVOKE clearScreen, 2								; show space
			showStrings 10, lpStrList							; show list of strings
			INVOKE clearScreen, 3								; show space
			mWrite <9, "*** No string entered.  ">				; no string mgs
			mWrite <"Returning to main menu. ***">				; return to main msg
		.ENDIF													; endif
	.ELSE														; else directive
		INVOKE clearScreen, 3									; show space
		mWrite <9, "*** ERROR String Manager is FULL.  ">		; error full msg
		mWrite "Please delete a string before adding. ***"		; error add str msg
	.ENDIF														; endif directive
	INVOKE clearScreen, 3										; show space
	mWriteString strCont										; show continue msg
	INVOKE getch												; phantom input
returnL:														; return label
	ret															; return
errorHeapL:														; error heap lbael
	mWrite <9, "***ERROR Not enough memory.">					; memory error msg
		mWriteString strCont									; show cont msg
	INVOKE getch												; phantom input
	jmp returnL													; return label
addString ENDP													; end proc

;-----------------------------------------------------
getEmptyIndex PROC Near32 STDCALL USES ECX EAX ESI EDI,
	lpStrList:dword,			; pointer to str list
	lpNum:dword					; point to str count
	LOCAL strTemp[80]:byte,		; char array temp
	dnum:dword					; temp num car
;
; receives a pointer to array of strings and str index
; gets an empty index from list of strings
;-----------------------------------------------------
	mov eax, lpNum												; set eax to index ptr
	mov ecx, 0													; set ecx to 0
	mov esi, lpStrList											; set esi to array str
	.WHILE (ecx < 10)											; while ecx < 10
		mov edi, [esi]											; set edi to str pointer
		.IF (edi != 0)											; if not null
			inc ecx												; move to next index
			add esi, TYPE lpStrList								; go to next pointer
		.ELSE													; else directive
			mov [eax], ecx										; set pointer to index
			jmp returnL											; jump to return
		.ENDIF													; endif directive
	.ENDW														; end while
	mov dword ptr [eax], -1										; not found, index = -1
returnL:														; return label
	ret															; return
getEmptyIndex ENDP												; end proc

;-----------------------------------------------------
delString PROC Near32 STDCALL USES EDI ECX EBX EAX ESI,
	hHeap:HANDLE,				; heap handle
	lpStrList:dword,			; pointer to str list
	lpStrCount:dword			; pointer to str count
	LOCAL strTemp[2]:byte,		; char temp
		  strBuff[2]:byte		; char temp
;
; receives a heap handle, pointer to arr list and str
;	count
; allows user to delete a string from array
;-----------------------------------------------------
delMainL:														; beg label
	INVOKE clearScreen, 25										; clear screen
	mWrite <9, "<3> Delete String">								; section title
	INVOKE clearScreen, 2										; show space
	showStrings 10, lpStrList									; show list of strs
	mov ecx, lpStrCount											; set ecx to num strs
	.IF (dword ptr [ecx] > 0)									; check if list is full
		INVOKE clearScreen, 3									; show spaces
		mWrite <9, "Press ENTER to cancel.">					; cancel msg
		INVOKE clearSCreen, 3									; show paces
		mWrite "Please enter string index to delete: "			; prompt for str index
checkInputL:													; check input label
		INVOKE getString, ADDR strTemp, 1						; get input index
		mov bl, byte ptr [strTemp]								; set bl to first char
		.IF(bl != 0)											; check if empty char
			.IF (bl < "0" || bl > "9")							; check if number char
				jmp invalidInputL								; jmp invalid label
			.ENDIF												; endif directive
			INVOKE ascint32, ADDR strTemp						; convert char to int
			mov ebx, eax										; set ebx to int
			mov esi, lpStrList									; set esi to array list
			lea edi, [esi + ebx * TYPE lpStrList]				; set edi to str ptr
			mov ecx, [edi]										; set ecx to str addr
			.IF (ecx != 0)										; if str addr isnt 0
getConfirmL:													; show confirm label
				INVOKE clearScreen, 25							; clear screen
				mWrite <9, "<3> Delete String">					; section name
				INVOKE clearScreen, 2							; show space
				showStrings 10, lpStrList						; show strin g list
				INVOKE clearScreen, 3							; show space
				mWrite <9, "Deleting: [">						; show index delete
				INVOKE putstring, ADDR strTemp					; show index
				mWrite <"] ">									; show bracket
				INVOKE putstring, [edi]							; show string
				INVOKE clearScreen, 3							; show space
				mWrite <"CONFIRM DELETION Y/N: ">				; confirm del msg
				INVOKE getString, ADDR strBuff, 1				; get char input
				mov bl, byte ptr [strBuff]						; set bl to char
				and bl, 11011111b								; make uppercase
				.IF (bl == 'Y')									; check if char is y
					INVOKE HeapSize, hHeap, 0, [edi]			; call heapsize
					sub dMemConsum, eax							; dec total
					push eax									; save eax
					INVOKE HeapFree, hHeap, 0, [edi]			; dealloc space on heap
					.if eax == null								; check if error
						pop eax									; restore eax
						add dMemConsum, eax						; dec total
						call crlf								; show space
						call writewindowsmsg					; show error msg
						call getch								; get phantom input
					.endif										; endif directory
					mov dword ptr [edi], 0						; set index in arr to 0
					mov ecx, lpStrCount							; set ecx to str count
					dec dword ptr [ecx]							; dec str count
					INVOKE clearScreen, 25						; clear screen
					mWrite <9, "<3> Delete String">				; show section header
					INVOKE clearScreen, 2						; show space
					showStrings 10, lpStrList					; show string list
					INVOKE clearScreen, 3						; show space
					mWrite <9, "SUCCESSFULLY DELETED ">			; succes msg
					mWrite <"STRING: [">						; show msg
					INVOKE putstring, ADDR strTemp				; show index deleted
					mWrite <"] ">								; show bracket
				.ELSEIF (bl == 'N')								; check if char is n
					jmp delMainL								; show confirm again
				.ELSE											; else directive
					jmp getConfirmL								; loop back to get confirm
				.ENDIF											; endif directive
			.ELSE												; else directive
invalidInputL:													; invalid input label
				INVOKE clearScreen, 25							; clear screen
				mWrite <9, "<3> Delete String">					; section header
				INVOKE clearScreen, 2							; show space
				showStrings 10, lpStrList						; show list of strings
				INVOKE clearScreen, 3							; show space
				mWrite <9, 'Invalid input.  "'>					; show invalid inp mesage
				INVOKE putstring, ADDR strTemp					; show string input
				mWrite <'" was entered.  '>						; show entered
				mWrite "Press ENTER to cancel."					; show cancel msg
				INVOKE clearSCreen, 3							; show space
				mWrite "Please enter string index to delete: "	; prompt for index
				jmp checkInputL									; jump to check input
			.ENDIF												; endif directive
		.ELSE													; else directive
			INVOKE clearScreen, 25								; clear screen
			mWrite <9, "<3> Delete String">						; section title
			INVOKE clearScreen, 2								; show space
			showStrings 10, lpStrList							; show string list
			INVOKE clearScreen, 3								; show space
			mWrite <9, "*** No string selected.  ">				; show error msg
			mWrite <"Returning to main menu. ***">				; show return msg
		.ENDIF													; endif directive
	.ELSE														; else directive
		INVOKE clearScreen, 3									; show space
		mWrite <9, "*** ERROR String Manager is EMPTY.  ">		; show error msg
		mWrite "Please add a string before deleting. ***"		; show error msg
	.ENDIF														; endif directive
	INVOKE clearScreen, 3										; show space
	mWriteString strCont										; show continue msg
	INVOKE getch												; phantom input
	ret															; return
delString ENDP													; end proc

;-----------------------------------------------------
editString PROC Near32 STDCALL USES EDI ECX EBX EAX ESI,
	hHeap:HANDLE,				; heap handle
	lpStrList:dword,			; ptr to str list
	lpStrCount:dword			; ptr to str count
	LOCAL strTemp[2]:byte,		; char input
		  strBuff[2]:byte,		; char temp
		  lpTemp:dword,			; pointer to str
		  dTemp:dword			; pointer to num
;
; receives heap handle, ptr to str array and ptr to
;	str count
; allows user to edit a string in the str list
;-----------------------------------------------------
editMainL:														; main loop label
	INVOKE clearScreen, 25										; clear screen
	mWrite <9, "<4> Edit String">								; section header
	INVOKE clearScreen, 2										; show space
	showStrings 10, lpStrList									; show string list
	mov ecx, lpStrCount											; set ecx to str count
	.IF (dword ptr [ecx] > 0)									; check if count > 0
		INVOKE clearScreen, 3									; show space
		mWrite <9, "Press ENTER to cancel.">					; cancel msg
		INVOKE clearSCreen, 3									; show space
		mWrite "Please enter string index to edit: "			; prompt for index
checkInputL:													; check input label
		INVOKE getString, ADDR strTemp, 1						; get index input
		mov bl, byte ptr [strTemp]								; set bl to char input
		.IF(bl != 0)											; check if bl is null
			.IF (bl < "0" || bl > "9")							; check if char is num
				jmp invalidInputL								; jmp to invalid section
			.ENDIF												; endif directive
			INVOKE ascint32, ADDR strTemp						; convert char to int
			mov ebx, eax										; set ebx to int
			mov esi, lpStrList									; set esi to ptr str list
			lea edi, [esi + ebx * TYPE lpStrList]				; set edi to ptr to arr
			mov ecx, [edi]										; set ecx to str addr
			.IF (ecx != 0)										; check if str addr == 0
getConfirmL:													; get confirmation label
				mov dTemp, ebx									; set dTemp to index
				INVOKE clearScreen, 25							; clear screen
				mWrite <9, "<4> Edit String">					; show section header
				INVOKE clearScreen, 2							; show space
				showStrings 10, lpStrList						; show string list
				INVOKE clearScreen, 3							; show space
				mWrite <9, "Editing: [">						; show prompt for index
				INVOKE putstring, ADDR strTemp					; show index
				mWrite <"] ">									; show bracket
				INVOKE putstring, [edi]							; show string
				INVOKE clearScreen, 3							; show space
				mWrite <"CONFIRM EDIT Y/N: ">					; show confirm prompt
				INVOKE getString, ADDR strBuff, 1				; get confirm input
				mov bl, byte ptr [strBuff]						; set bl to char input
				and bl, 11011111b								; make uppercase
				.IF (bl == 'Y')									; check if char Y
					INVOKE clearScreen, 25						; clear screen
					mWrite <9, "<4> Edit String">				; section header
					INVOKE clearScreen, 2						; show space
					showStrings 10, lpStrList					; show strings
					INVOKE clearScreen, 3						; show space
					mWrite <9, "Editing: [">					; show edit index prompt
					INVOKE putstring, ADDR strTemp				; show index
					mWrite <"] ">								; show bracket
					INVOKE putstring, [edi]						; show string
					INVOKE clearScreen, 3						; show space
					mWrite "Please enter the replacement "		; prompt for string
					mWrite "string: "							; prompt for string cont
					INVOKE getString, ADDR strBuffer, 127		; get string input
					mov bl, byte ptr [strBuffer]				; set bl to input char
					.IF(bl != 0)								; check if char null
						INVOKE HeapSize, hHeap, 0, [edi]		; returns size of block into eax
						sub dMemConsum, eax						; subtracts block size from total
						push eax								; pushing to preserve eax
						INVOKE HeapFree, hHeap, 0, [edi]		; dealloc str on heap
						.IF eax == null							; check if heap error
							pop eax								; restoring eax
							add dMemConsum, eax					; retoring total
							call crlf							; show space
							call writewindowsmsg				; show error msg
							call getch							; phantom input
						.ENDIF									; endif directive
						lea esi, strBuffer						; set esi to str buffer
						push esi								; push esi to stack
						CALL String_length						; get string inp len
						inc eax									; inc len by one
						add dMemConsum, eax						; adding size to total
						push eax								; preserving eax
						INVOKE HeapAlloc, hHeap, 				; call heap alloc
							HEAP_ZERO_MEMORY, eax 				; heap alloc parameters
						.IF (eax == NULL)						; check if heap error
							pop eax								; restoring eax
							sub dMemConsum, eax					; restoring total
							jmp errorHeapL						; jump to error section
						.ENDIF									; endif directive
						mov lpTemp, eax							; set var to heap addr
						push eax								; push heap addr to stack
						push esi								; push str input to stack
						CALL String_copy						; call str cpy
						mov edi, lpStrList						; set edi to ptr to list
						mov esi, dTemp							; set esi to index
						mov [edi + esi * TYPE lpStrList], eax	; move heap alloc to list
						INVOKE clearScreen, 25					; clear screen
						mWrite <9, "<4> Edit String">			; section header
						INVOKE clearScreen, 2					; show space
						showStrings 10, lpStrList				; show string list
						INVOKE clearScreen, 3					; show space
						mWrite <9, "SUCCESSFULLY EDITED ">		; show success msg
						mWrite <"STRING: [">					; show sucess msg cont
						INVOKE putstring, ADDR strTemp			; show index
						mWrite <'] "'>							; show bracket
						INVOKE putstring, lpTemp				; show string
						mWrite <'"'>							; show quote
					.ELSE										; else directive
						INVOKE clearScreen, 25					; clear screen
						mWrite <9, "<4> Edit String">			; show section header
						INVOKE clearScreen, 2					; clear screen
						showStrings 10, lpStrList				; show string list
						INVOKE clearScreen, 3					; show space
						mWrite <9, "*** No replacement ">		; show error msg part 1
						mWrite <"string entered.  Returning ">	; show error msg part 2
						mWrite <"to previous menu. ***">		; show error msg part 3
						INVOKE clearScreen, 3					; show space
						mWriteString strCont					; show cont msg
						INVOKE getch							; phantom input
						jmp editMainL							; jump to main edit label
					.ENDIF										; endif directive
					INVOKE clearScreen, 25						; clear screen
					mWrite <9, "<4> Edit String">				; show section header
					INVOKE clearScreen, 2						; show space
					showStrings 10, lpStrList					; show string list
					INVOKE clearScreen, 3						; show space
					mWrite <9, "SUCCESSFULLY EDITED STRING: [">	; show success msg
					INVOKE putstring, ADDR strTemp				; show index
					mWrite <"] ">								; show bracket
				.ELSEIF (bl == 'N')								; check char to n
					jmp editMainL								; jmp to top
				.ELSE											; else directive
					jmp getConfirmL								; jmp to input check
				.ENDIF 											; endif directive
			.ELSE												; else directive
invalidInputL:													; invalid label
				INVOKE clearScreen, 25							; clear screen
				mWrite <9, "<4> Edit String">					; show section header
				INVOKE clearScreen, 2							; show space
				showStrings 10, lpStrList						; show str list
				INVOKE clearScreen, 3							; show space
				mWrite <9, 'Invalid input.  "'>					; show error message
				INVOKE putstring, ADDR strTemp					; show input
				mWrite <'" was entered.  '>						; show input 2
				mWrite "Press ENTER to cancel."					; show cancel msg
				INVOKE clearSCreen, 3							; show spce
				mWrite "Please enter string index to edit: "	; show prompt for index
				jmp checkInputL									; jump to check label
			.ENDIF												; endif directive
		.ELSE													; else directive
			INVOKE clearScreen, 25								; clear screen
			mWrite <9, "<4> Edit String">						; show section header
			INVOKE clearScreen, 2								; show space
			showStrings 10, lpStrList							; show string list
			INVOKE clearScreen, 3								; show space
			mWrite <9, "*** No string selected.  ">				; show erro msg 1
			mWrite <"Returning to main menu. ***">				; show error msg 2
		.ENDIF													; endif directive
	.ELSE														; else directive
		INVOKE clearScreen, 3									; show spce
		mWrite <9, "*** ERROR String Manager is EMPTY.  ">		; show error message
		mWrite "Please add a string before editing. ***"		; show error msg 2
	.ENDIF														; endif directive
	INVOKE clearScreen, 3										; show space
	mWriteString strCont										; show cont message
	INVOKE getch												; phantom input
returnL:														; return label
	ret															; return
errorHeapL:														; error heap label
	mWrite <9, "*** ERROR Not enough memory.">					; show error msg
		mWriteString strCont									; show cont msg
	INVOKE getch												; phantom input
	jmp returnL													; jmp return msg
editString ENDP													; end proc

;-----------------------------------------------------
searchString PROC Near32 STDCALL USES EDI ECX EBX EAX ESI EDX,
	hHeap:HANDLE,					; heap handle
	lpStrList:dword,				; ptr to list arr
	lpStrCount:dword				; ptr to str count
	LOCAL strFoundList[10]:dword,	; copy of array list
		  strIndex:dword,			; str index
		  dTemp:dword,				; num temp
		  dSubLen:dword,			; subseq len
		  dFoundCount:dword,		; found str count
		  dListIndex:dword,			; str list index
		  strtemp[2]:byte			; char temp
;
; receives a heap handle, ptr to str list and str count
; allows the user to search for a subseq from the array of
;	strings by making a copy and capitalizing found
;-----------------------------------------------------
	INVOKE clearScreen, 25										; clear screen
	mWrite <9, "<5> Search String">								; show sectoin header
	INVOKE clearScreen, 2										; show space
	showStrings 10, lpStrList									; show string list
	mov ecx, lpStrCount											; set ecx to str count
	.IF (dword ptr [ecx] > 0)									; check if str exists
		INVOKE clearScreen, 3									; show space
		mWrite <9, "Press ENTER to cancel.">					; show cancel msg
		INVOKE clearSCreen, 3									; show spaces
		mWrite "Please enter the target string: "				; prompt for string
checkInputL:  													; check input label
		INVOKE getString, ADDR strBuffer, CHAR_MAX				; get input for string
		mov bl, byte ptr [strBuffer]							; set bl to first char
		.IF(bl != 0)											; check if char null
			mov ecx, LENGTHOF strFoundList						; set ecx to len of arr
			lea edi, strFoundList								; set edi as ptr to arr
initLoopL:														; init loop to 0 label
			; sets the array of str pointers to 0
			mov dword ptr [edi + ecx * TYPE strFoundList - TYPE strFoundList], 0
			loop initLoopL										; for loop 10 times
			mov ecx, 0											; set ecx to 0
			mov dFoundcount, 0									; init foundcount to 0
			.WHILE(ECX < 10)									; check ecx < 0
				mov dListIndex, ecx								; save count in list index
				mov edi, lpStrList								; set edi ptr to list
				lea esi, dword ptr [edi + ecx * TYPE lpStrList]	; set esi ptr to str addr
				mov ebx, [esi]									; set ebx to str addr
				.IF(ebx != 0)									; check ebx isnt 0
					mov ebx, 0									; init ebx to 0
					mov dTemp, esi								; save ptr in dtemp
					push 0										; push index 0
					push offset strBuffer						; push addr of str input
					push [esi]									; push str addr
					CALL String_indexOf_3						; get subseq in string
					.IF (EAX != -1)								; check if not found -1
						mov strIndex, eax						; save index in strIndex
						lea ebx, strFoundList					; set ebx to ptr str arr
						;set edi as ptr to string address from list
						lea edi, dword ptr [ebx + ecx * TYPE strFoundList]
						mov esi, dTemp							; set esi to ptr to str
						push dword ptr [esi]					; push str address
						CALL String_length						; get length of string
						inc eax									; inc len for null term
						;allocate mem for string on heap
						INVOKE HeapAlloc, hHeap, HEAP_ZERO_MEMORY, eax
						.IF (eax == NULL)						; check if heap error
							jmp errorHeapL						; jump to error section
							mwrite "heap error"					; show error msg
							call getch							; phantom inp
						.ENDIF									; endif directive
						mov dword ptr [edi], eax				; save addrr in list
						push eax								; push dyn addr to stack
						push [esi]								; push str addr to stack
						CALL String_copy						; copy to new dyn str
						push offset strBuffer					; push input to stack
						CALL String_length						; get length
						mov dSubLen, eax						; save substring len
						mov strIndex, 0							; init index to 0
						mov ebx, dFoundCount					; set ebx to found subseq
						push 0									; push 0 beg index
						push offset strBuffer					; push input addr to stack
						push dword ptr [edi]					; push dyn str addr
						CALL String_indexOf_3					; check if subseq in str
						.WHILE (EAX != -1)						; check if found
							add strIndex, eax					; save index in strindex
							inc ebx								; inc count of str found
							mov edx, 0							; init edx 0
							mov esi, [edi]						; set esi to string
							add esi, strIndex					; advance esi ptr in str
							.WHILE(edx < dSubLen)				; loop while index < len
								mov al, byte ptr [esi + edx]	; set al to char in str
								.IF (al >= "a" && al <= "z")	; check if al is lower
									; uppercases the letter in string if so
									and byte ptr [esi + edx], 11011111b
								.ENDIF							; endif directive
								inc edx							; next index
							.ENDW								; end while loop
							mov dFoundCount, ebx				; update foundcount
							mov edx, dSubLen					; set edx to sub len
							add strIndex, edx					; advance index in str
							push strIndex						; push str to stack
							push offset strBuffer				; push offset of substr
							push dword ptr [edi]				; push string addr
							CALL String_indexOf_3				; get index of sub in str
						.ENDW									; end while
					.ENDIF										; end if dir
				.ENDIF											; endif directive
				mov ecx, dListIndex								; set ecx to arr list index
				inc ecx											; inc ecx to next index
			.ENDW												; end while
		.ELSE													; else directive
			INVOKE clearScreen, 25								; clear screen
			mWrite <9, "<5> Search String">						; show section header
			INVOKE clearScreen, 2								; show space
			showStrings 10, lpStrList							; show array list
			INVOKE clearScreen, 3								; show space
			mWrite <9, "*** No string selected.  ">				; show error msg
			mWrite <"Returning to main menu. ***">				; show error msg pt2
			jmp returnL											; return label
		.ENDIF 													; endif dir
		INVOKE clearScreen, 25									; clear screen
		mWrite <9, "<5> Search String">							; show section header
		INVOKE clearScreen, 2									; show space
		lea esi, strFoundList									; set edi ptr to list arr
		showstrings 10, esi										; show list of strings
		INVOKE clearScreen, 3									; show space
		mWrite <9, '"'>											; show squote
		INVOKE putstring, addr strBuffer						; show substring input
		mWrite '" was successfully found '						; show success msg
		invoke intasc32, addr strBuffer, dFoundCount			; convert int to ascii
		invoke putstring, addr strBuffer						; show char
		mov ebx, dFoundCount									; set ebx to str count
		.IF (ebx == 1)											; checks if count is 1
			mWrite " time."										; shows singular
		.ELSE													; else directive
			mWrite " times."									; shows plural
		.ENDIF													; endif direc
		mov ecx, 0												; init ecx to 0
		.WHILE (ecx < 10)										; while ecx < 10 loop
		lea esi, strFoundList									; set esi ptr arr list
		lea edi, [esi + ecx * TYPE strFoundList]				; set edi ptr str addr
		mov ebx, [edi]											; set ebx str addr
		.IF (ebx != 0)											; check if addr null
			INVOKE HeapFree, hHeap, 0, [edi]					; free memory of string
		.ENDIF													; endif dir
			inc ecx												; next index
		.ENDW 													; end while
	.ELSE														; else dir
		INVOKE clearScreen, 3									; show space
		mWrite <9, "*** ERROR String Manager is EMPTY.  ">		; show error msg
		mWrite "Please add a string before searching. ***"		; show error msg 2
	.ENDIF														; endif dir
returnL:														; return label
	INVOKE clearScreen, 3										; show space
	mWriteString strCont										; show cont message
	INVOKE getch												; phantom input
	ret															; return
errorHeapL:														; error heap label
	mWrite <9, "*** ERROR Not enough memory.">					; show error msg
		mWriteString strCont									; show cont msg
	INVOKE getch												; phantom input
	jmp returnL													; return label
searchString ENDP												; end proc



;-----------------------------------------------------
memConsumption PROC Near32 STDCALL,
	lpStrList:dword				; ptr to list arr
	LOCAL lpStrTemp[10]:byte	; used to hold sring of memConsum
;
; receives a variable that contains the current memory consumption
;	used by the string array.
; shows memory consumption in bytes
;-----------------------------------------------------
	INVOKE clearScreen, 25										; clear screen 25 spaces
	mWrite <9, "<6> String Array Memory Consumption">			; header for add string
	INVOKE clearScreen, 2										; 2 spaces
	showStrings 10, lpStrList									; show string list
	INVOKE clearScreen, 3										; clear screen 3 spaces
	.IF (dMemConsum == 0)										; checks if no memory
		mWrite <9, "*** LIST IS CURRENTLY EMPTY ***">			; error msg
	.ELSE														; else directive
		mWrite <9, "Current memory consumption is: ">			; prompt for total
		INVOKE intasc32, ADDR lpStrTemp, dMemConsum				; convert int to char
		INVOKE putstring, ADDR lpStrTemp						; show string
	.ENDIF														; endif directive
		INVOKE clearSCreen, 3									; clear screen 3 spaces
	mWriteString strCont										; continue message
	INVOKE getch												; phantom input
	ret															; return
memConsumption ENDP												; end proc
END main														; end of main
