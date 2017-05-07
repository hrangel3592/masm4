;*******************************************************************************
; Name:   		Hernan Rangel
; Program:		String1.asm
; Class:      	CS 3B
; Project:		String1 of MASM3
; Date:       	April 17, 2018
; Purpose:		String1.asm handles a set of procedures involving the comparing,
;				checking if a substring is present, and character location.
;				String1 implements all methods listed in MASM3 spec for String1
;*******************************************************************************
	.486			; enables instructions for 80486 cpu
	.model flat		; flat memory model


	;allocates memory for a new string
	;returns 0 if no memory else it returns the address
	memoryallocBailey  PROTO Near32 stdcall, dNumBytes:dword

	;program entry point
	.code

;-------------------------------------------------------------------------------
String_length proc Near32
; 	ebp+8: dword
;	returns: dword
;	This proc reveieves address of a string and returns the string length
; 	in the form of a dword in the eax
;-------------------------------------------------------------------------------
	push ebp		;preserve base register
	mov  ebp, esp	;set new stack frame
	push ebx		;preserve used register
	push esi		;push esi on stack
	mov ebx,[ebp+8]	;ebx-> 1st string
	mov esi, 0		;esi indexes into the strings

stLoop:							; beg of loop
	cmp byte ptr[ebx+esi], 0	; reached the end of string
	je finished					; if end jump to end
	inc esi						; go to next char
	jmp stLoop					; loop again

finished:			; clean up
	mov eax, esi 	; stores length to eax
	pop esi			; restores preserved registers
	pop ebx			; restores ebx
	pop ebp			; restores ebp
	ret 4			; returns eip and cleans up args
String_length endp	; end of proc

;-------------------------------------------------------------------------------
String_equals proc Near32
; 	ebp+8  : dword
;	ebp+12 : dword
;	returns: byte
;	This proc recieves two strings and compares each individual character to see if
;	the two strings are the same. This proc does not ignores case and returns true
; 	or false in the al register
;-------------------------------------------------------------------------------

	push ebp		;preserve the base register
	mov ebp, esp	;set new stack frame

	push ebx		;pushing all register to stack
	push edx		;push edx
	push esi		;push esi
	push edi		;push edi


	mov eax, 0			; setting all registers to 0
	mov ebx, 0			; ebx to 0
	mov edx, 0			; edx to 0
	mov  esi, [ebp+8]	; Moves 1st string into esi
	mov	 edi, [ebp+12]	; moves 2nd string into edi

checkNull:				; moves current characters into the registers
	mov bl, [esi]		; moves first char to bl
	mov dl, [edi]		; moves sec char to dl
	cmp bl, 0			; checks for end of string
	jne compare			; end of string, jump
	cmp dl, 0			; checks for end of string2
	jne compare			; end of string2, jump
	mov eax, 1			; true
	jmp finish			; cleanup

compare:				; continue comparing
	inc esi				; Increment esi and edi for next character
	inc edi				; next char
	cmp bl, dl			; compares characters
	je  checkNull		; if equal it jumps to checkNull

finish:					; cleanup
	pop edi				; restoring stack to original state
	pop esi				; restore esi
	pop edx				; restore edx
	pop ebx				; restore ebx
	pop ebp				; restore ebp
	ret 8				; ret addr and clean args
String_equals endp		; end of proc

;-------------------------------------------------------------------------------
String_equalsIgnoreCase Proc Near32
; 	ebp+8  : dword
;	ebp+12 : dword
;	returns: byte
;	This proc recieves two strings and compares each individual character to see if
;	the two strings are the same. This proc ignores case and returns true or false
;	in the al register
;-------------------------------------------------------------------------------

	push ebp		; preserve the base register
	mov ebp, esp	; set new stack frame

	push ebx		; pushing all registers to stack
	push edx		; save edx
	push esi		; save esi
	push edi		; save edi

	mov eax, 0			; clearing registers for use
	mov ebx, 0			; clear ebx
	mov edx, 0			; clear edx
	mov  esi, [ebp+8]	; Moves 1st string into esi
	mov	 edi, [ebp+12]	; moves 2nd string into edi

checkNull:				; moves current characters into the registers
	mov bl, [esi]		; move char to bl
	mov dl, [edi]		; move char to dl
	cmp bl, 0			; checks for end of string
	jne compare			; end of str jump
	cmp dl, 0			; checks for end of string2
	jne compare			; end of str2 jump
	mov eax, 1			; true
	jmp finish			; clean up

compare:				; ignore case
	; Compares to see if characters are within 'a' and 'z' if so it
	; changes them to uppercase
	.IF (bl >= 'a') && (bl <='z')	; if char in bl a-z
		and bl, 11011111b			; make uppercase
	.ENDIF							; end if

	.IF (dl >= 'a') && (bl <='z')	; if char in dl a-z
		and dl, 11011111b			; make uppercase
	.ENDIF							; endif

	inc esi							; Increment esi and edi for next character
	inc edi							; inc edi
	cmp bl, dl						; compares characters
	je  checkNull					; if equal it jumps to checkNull

finish:								; clean up
	pop edi							; Restores registers and stack
	pop esi							; restore esi
	pop edx							; restore edx
	pop ebx							; restore ebx
	pop ebp							; restore ebp
	ret 8							; ret addr and arg cleanup
String_equalsIgnoreCase endp		; end of proc

;-------------------------------------------------------------------------------
String_copy proc Near32
; 	ebp+8  : dword
;	returns: dword
;	This proc recieves a string and then allocates memory for a 2nd string and
;	copies over the 1st string into the address of the 2nd string. It returns the
; 	address of the 2nd string via eax
;-------------------------------------------------------------------------------
	enter 0, 0			; set up ebp base
	push  esi			; pushing registers to stack
	push  edi			; save edi
	push  ecx			; save ecx
	
	mov eax, 0			; reset eax
	mov esi, [ebp+8]	; moving address to esi
	push esi			; pushing address to stack

	call String_length	; get length
	mov ecx, eax		; stores the string length
	inc ecx				; increments string length +1

	; create space in memory for new string
	invoke memoryallocBailey, ecx

	jz finished		; checks zero flag and jumps to finished if true
	mov edi, eax	; moves address from memoryallocBailey into edi

	cld				; clear direction forward
	rep movsb		; copy the string

finished:			; cleanup
	pop ecx			; restoring stack
	pop edi			; restore edi
	pop esi			; restore esi
	leave			; restore local and ebp
	ret 4			; ret address and args cleanup
String_copy endp	; end of proc

;-------------------------------------------------------------------------------
String_substring_1 proc Near32
; 	lpString   : dword
; 	dBeginIndex: dword
; 	dEndIndex  : dword
; 	dLength    : dword
;	returns		 : dword
;	This proc recieves a string, a beginning index, and an ending index. It then
; 	returns an address of a second string that is a substring of the first string
; 	which is from the beginning index to the end index given.
;-------------------------------------------------------------------------------
	lpString    	EQU [ebp+8]	 ;main string
	dBeginIndex 	EQU [ebp+12] ;start index
	dEndIndex		EQU [ebp+16] ;end index
	dLength			EQU [ebp-4]	 ;stores string length

	enter 4, 0		;set ebp
	push  esi		;pushing registers to stack
	push  edi		;save edi
	push  ebx		;save ebx
	push  ecx		;save ecx
	push  edx		;save edx
	mov   eax, 0	;reset eax

	;moving start and end index to registers ebx and edx
	mov ebx, dBeginIndex
	mov edx, dEndIndex

	;compare dBeginIndex to 0 if less jumps to error
	cmp ebx, 0
	jl	error
	;compare dEndIndex to 0 if less jumps to error
	cmp edx, 0
	jl	error
	;compares dBeginIndex to dEndIndex if start > end jumps to error
	cmp ebx, edx
	jg	error
	;compare end index to string length
	mov  esi, lpString		;moving address to esi
	push esi			    ;pushing address to stack
	call String_length		;get length
	cmp  edx, eax 			;comparing size of end index to string length
	jl	 copy				;valid end index, jump to copy
	mov  edx, eax			;else set end index to end of str
	dec  edx				;last index set

copy:   					; make new substring
	mov dLength, eax 		; dLength = eax

	;Copying of string begins
	add esi, ebx			;moving esi to start index (esi+ebx)
	mov ecx, edx			;ecx = edx
	sub ecx, ebx			;eax = ecx - ebx

	;add 2 to ecx to allocate space
	add ecx, 2				;null term and first index
	invoke memoryallocBailey, ecx
	jz error				;no space
	;moving address the new allocated string into edi
	mov edi, eax			;edi with new space in mem
	cld						;set direction flag
	rep movsb				;move char in esi to edi

	sub dLength, edx		;subtracting end index from string length
	mov edx, dLength		;edx = dLength
	cmp edx, 1				;comparing edx to 1 if it is = it finishes otherwise
	je finish				;it adds a null terminator to the string
	dec edi					;last index
	mov byte ptr [edi], 0	;set to null

finish:						;cleanup
	pop edx					;restoring stack
	pop ecx					;restore ecx
	pop ebx					;restore ebx
	pop edi					;restore edi
	pop esi					;restore esi
	leave					;restore ebp
	ret 12					;ret address, args
	
error:							;error
	invoke memoryallocBailey, 1	;empty substring
	jz finish					;no space
	mov byte ptr [eax], 0		;if there is an error it returns a null string
	jmp finish					;finish	
String_substring_1 endp			;end of proc

;-------------------------------------------------------------------------------
String_substring_2 proc Near32
; 	lpString   : dword
; 	dBeginIndex: dword
; 	dLength    : dword
;	returns		 : dword
;	This proc recieves a string and a beginning index. It then
; 	returns an address of a second string that is a substring of the first string
; 	which is from the beginning index to the end of the first string.
;-------------------------------------------------------------------------------
	lpString    EQU [ebp+8]  	;Main string passed in
	dBeginIndex EQU [ebp+12] 	;Starting index
	dLength		EQU [ebp-4]		;dlength used to store string length

	enter 4, 0					;setup ebp
	push  esi 					;pushing registers to stack
	push  edi					;save edi
	push  ebx					;save ebx
	push  ecx					;save ecx
	mov  eax, 0					;reset eax

	;moving start and end index to registers ebx and edx
	mov ebx, dBeginIndex		;set ebx to index

	;compare dBeginIndex to 0 if less jumps to error
	cmp ebx, 0					;check if 0
	jl	error					;error out
	;compare begin index to string length
	mov esi, lpString			;moving address to esi
	push esi			    	;pushing address to stack
	call	String_length		;string length
	cmp  ebx, eax				;check index
	jge	 error					;error out
	mov dLength, eax			;local variable for length

	;Copying of string begins
	add esi, ebx  				;moving exi to the starting index
	mov ecx, eax				;ecx = eax
	sub ecx, ebx				;eax = ecx - ebx
	add ecx, 1					;add 1 to ecx to allocate space
	
	;create space in memory
	invoke memoryallocBailey, ecx
	jz error					;error out
	
	mov edi, eax				;moving address the new allocated string into edi
	cld							;direction flag forward
	rep movsb					;copy to esi
	
finish:							;finish
	pop ecx						;restoring stack
	pop ebx						;restore ebx
	pop edi						;restore edi
	pop esi						;restore esi
	leave						;restore ebp
	ret 8						;ret addr
error:							;error out
	invoke memoryallocBailey, 1 ;make empty string
	jz finish					;no space
	mov byte ptr [eax], 0 		;returns null string if an error occurs
	jmp finish					;finish
String_substring_2 endp			;end of proc

;-------------------------------------------------------------------------------
String_charAt proc Near32
; 	lpString : dword
; 	dIndex   : dword
;	returns  : byte
;	This proc recieves a string and an index. It then returns the character
;	located at the given index location.
;-------------------------------------------------------------------------------
	lpString EQU [ebp+8] 	;Main string
	dIndex   EQU [ebp+12]	;String index

	enter 0,0				;setup ebp
	push esi 				;pushing registers to stack
	push ebx				;save ebx
	mov eax, 0				;reset eax

	;moving esi to string and moving index to ebx
	mov esi, lpString		;move string to esi
	mov ebx, dIndex			;move index to ebx

	;comparing to see if index < 0
	cmp ebx, 0				;compare index to 0
	jl  error				;error out

	;pushing string to stack and getting the length
	push esi				;arg esi
	call String_length		;string length

	;comparing index to string length if it is greater it jumps to error
	cmp ebx, eax			;index >= legnth
	jge error				;error out

	add esi, ebx 			;adding ebx to esi to get given index
	mov eax, [esi]			;moving character at given index to eax

finish:						;finish
	pop ebx 				;restoring stack
	pop esi					;restore esi
	leave					;restore ebp
	ret 8					;ret addr
error:						;error out
	mov eax, 0 				;returns eax = 0 if an error occurs
	jmp finish				;finish
String_charAt endp			;end of proc

;-------------------------------------------------------------------------------
String_startsWith_1 proc Near32
; 	lpString : dword
; 	lpPrefix : dword
;	dIndex   : dword
;	returns  : byte
;	This proc recieves two strings a main string and a prefix. It then checks if
;	the prefix is a substring of the main string starting at the given index
;-------------------------------------------------------------------------------
	lpString EQU [ebp+8]	;main string
	lpPrefix EQU [ebp+12] 	;prefix string
	dIndex   EQU [ebp+16] 	;index to check mainstring for prefix
	dLength1 EQU [ebp-4]  	;stores length of string

	enter 4, 0				;setup ebp
	push esi  				;pushes registers to stack
	push edi				;save edi
	push ebx				;save ebx
	push ecx				;save ecx
	mov eax, 0				;reste eax

	mov esi, lpString 		;moving esi to main string
	mov edi, lpPrefix 		;moving edi to prefix string
	mov ebx, dIndex	  		;ebx = index

	cmp ebx, 0 				;if ebx < 0 jumps to error
	jl	error				;error out

	push esi				;pushing string to get string length
	call String_length		;string length

	cmp ebx, eax 			;if ebx >= eax jumps to error
	jge error				;error out
	mov dLength1, eax		;else dLength1 = eax

	add esi, ebx 			;esi = esi + ebx

	push edi				;pushing string to get string length
	call String_length		;string length

	cmp eax, dLength1 		;if eax > dLength1 jump to error
	jg  error				;error out

	mov ecx, eax 			;ecx = eax

	cld						;starts comparing the two strings
	repe cmpsb				;compare chars 
	jne error				;error flag, error out
	mov eax, 1				;else true

finish:						;clean up
	pop ecx					;restores stack
	pop ebx					;save ebx
	pop edi					;save edi
	pop esi					;save esi
	leave					;restore ebp
	ret 12					;ret address

error:						;error
	mov eax, 0				;returns 0 if error occurs
	jmp finish				;finish
String_startsWith_1 endp	;end of proc

;-------------------------------------------------------------------------------
String_startsWith_2 proc Near32
; 	lpString : dword
; 	lpPrefix : dword
;	returns  : byte
;	This proc recieves two strings a main string and a prefix. It then checks if
;	the prefix is a substring of the main string
;-------------------------------------------------------------------------------
	lpString EQU [ebp+8]	;main string
	lpPrefix EQU [ebp+12] 	;prefix string

	enter 0, 0				;setup ebp

	push 0  				;pushes an index of 0
	push lpPrefix 			;pushes both strings
	push lpString			;push substring
	call String_startsWith_1;check for same string

	leave					;restore ebp
	ret 8					;ret address, args
String_startsWith_2 endp	;end of proc

;-------------------------------------------------------------------------------
String_endsWith proc Near32
; 	lpString : dword
; 	lpSuffix : dword
;	returns  : byte
;	This proc recieves two strings a main string and a suffix string. It then
; 	checks if the suffix string is an actual suffix of the main string.
;-------------------------------------------------------------------------------
	lpString EQU [ebp+8] 	;main string
	lpSuffix EQU [ebp+12]	;suffix string
	dLength1 EQU [ebp-4] 	;used to store string length

	;enter at 4 since allocating memory for dLength1
	enter 4, 0				;setup ebp
	push lpSuffix			;pushing lpSuffix to stack
	call String_length		;eax = lpSuffix string length

	mov dLength, eax		;dLength = String length

	push lpString			;pushing lpString to stack
	call String_length		;eax = lpString string length

	sub eax, dLength		;subtracting lpSuffix length from lpString length
							;this gives us the index of where  the suffix index starts
	push eax				;pushes eax as an index
	push lpSuffix			;pushing both strings to stack
	push lpString			;push substring
	call String_startsWith_1;call startswith

	leave					;restore ebp
	ret 8					;ret to address
String_endsWith endp		;end of proc

END ;end of program
