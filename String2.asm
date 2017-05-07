;**************************************************************************
; Name:   		Peter Tang
; Program:		String2.asm
; Class:        CS 3B
; Project:		String2 of MASM3
; Date:         April 17, 2017
; Purpose:
;		String2.asm implements procedures listed per MASM3 String2 specification.
;		These procedures include String_length, String_indexOf_1, 
;		String_indexOf_2, String_indexOf_3, String_lastIndexOf_1,
;		String_lastIndexOf_2, String_lastIndexOf_3, String_concat,
;		String_replace, String_toLowerCase, and String_toUpperCase
;**************************************************************************

	.486			; enables assembly nonprivileged instructions for 80486 processor
	.model flat 	; directive identifies memory model as flat (protected mode)

	; receives a number of requested bytes to be allocated in memory
	; returns 0 if memory is not available, otherwise
	; returns a dword address of a dynamically allocated block of memory
	; of the requested size
	memoryallocBailey PROTO Near32 stdcall, dNumBytes:DWORD
	
	.code	; directive marking the program's entry point
	
;-----------------------------------------------------
String_length PROC Near32 PRIVATE
;	lpString1:dword			; address of string
;	: dword					; returns length in eax
;
; Receives the address of a string and counts the
;  characters in the string, excluding the NULL char
; Returns the length as a dwrd in the EAX register
;-----------------------------------------------------
	push ebp				; save address in ebp
	mov ebp, esp			; set ebp as base reference for stack frame
	push edi				; save contents of edi in stack
	
	mov eax, 0				; reset eax sum contents to 0
	mov edi, [ebp + 8]		; set edi to address of string

checkChar:					; loop label for counting chars
	cmp byte ptr [edi], 0	; checks for null term
	je returnL				; null term reached, jump to ret
	inc edi					; increment to next byte
	inc eax					; increment sum
	jmp checkChar			; loop back and continue counting
	
returnL:					; ret label
	pop edi					; restore edi value from stack
	pop ebp					; restore ebp from stack
	ret 4					; stdcall, clean args
String_length ENDP			; end of proc


;-----------------------------------------------------
String_indexOf_1 PROC Near32
;	lpString:dword,		; address of string
;	cCharKey:byte		; char to search for
;	:dword				; returns index in eax
;
; Receives a string address and a character, then
;  searches the string for the character
; Returns the index of the character in the string
; Returns -1 if not found
;-----------------------------------------------------
	lpString EQU [ebp + 8]		; var for arg 1
	cCharKey EQU [ebp + 12]		; var for arg 2
	
	push ebp					; save ebp to stack
	mov ebp, esp				; set ebp as base ref for stack frame
	push edi					; save edi on stack
	push ecx					; save ecx on stack
	
	mov edi, lpString			; set edi as address of string
	push edi					; push addr as arg1 to length call
	CALL String_length			; get length of string
	mov ecx, eax				; set ecx counter as length of string
	mov al, byte ptr cCharKey	; set al as char key
	
	cld							; set direction flag 0, forward
	repne scasb					; repeat while al != char in edi
	jnz errorL					; ZF = 0, not equal, return
	dec edi						; edi is auto inc, so dec 1
	sub edi, lpString			; get numeric index
	mov eax, edi				; set eax to index
	
returnL:						; return label
	pop ecx						; restore ecx value from stack
	pop esi						; restore esi value from stack
	pop ebp						; restore ebp value form stack
	ret 6						; stdcall, clean up 2 args
errorL:							; label if char not found
	mov eax, -1					; set eax to -1
	jmp returnL					; jump to return label
String_indexOf_1 ENDP			; end of proc


;-----------------------------------------------------
String_indexOf_2 PROC Near32
;	lpString:dword,		; address of string
;	cCharKey:byte,		; char to search for
;	dFromIndex:dword	; start of search index
;	:dword				; return index of key in eax
;
; Receives a string address, character key, and 
;  starting index position, then searches the string 
;  for the character starting at the input index position
; Returns the index of the character in the string
; Returns -1 if not found or input position is out of bounds
;-----------------------------------------------------
	lpString    EQU [ebp + 8]	; address of string
	cCharKey    EQU [ebp + 12]	; char to search for
	dFromIndex  EQU [ebp + 14]	; index to start searching
	
	push ebp					; save ebp addr to stack
	mov ebp, esp				; set ebp as base reference
	push edi					; save edi values to stack
	push ebx					; save ebx values to stack
	push ecx					; save ecx values to stack
	
	mov ebx, dFromIndex			; set ebx to beg search pos
	cmp ebx, 0					; compare index to 0
	jl errorL					; exit if index < 0
	
	mov edi, lpString			; set edi to string address
	push edi					; push string addr to stack
	CALL String_length			; get length of address
	cmp ebx, eax				; check index input and length
	jge errorL					; SF = OF, ZF = 1? index >= length
	add edi, ebx				; adds index to string address
	
	push word ptr cCharKey		; arg 1 key pushed to stack
	push edi					; arg 2 string addr pushd to stack
	CALL String_indexOf_1		; call string indexOf_1
	cmp eax, -1					; check if index == -1 (not found)
	je returnL					; ZF=1, not found, jump to return
	add eax, ebx				; get real index of string in eax
	
returnL:						; return label
	pop ecx						; restore ecx value from stack
	pop ebx						; restore ebx value from stack
	pop esi						; restore esi value from stack
	pop ebp						; restore ebp value from stack
	ret 10						; return addr, clean 12 bytes
errorL:							; error label
	mov eax, -1					; not found, move -1 to eax
	jmp returnL					; jump to return label
String_indexOf_2 ENDP			; end of proc


;-----------------------------------------------------
String_indexOf_3 PROC Near32
;	lpString:dword,		; string address
;	lpSubstring:dword	; substring address
;	:dword				; index of first occurrence
;
; Receives an address to a string and a substring,
;  then searches the string to check if it contains
;  the substring
; Returns the index of the first occurrence of the
;  substring in the string
; Returns -1 if not found
;-----------------------------------------------------
	lpString          EQU [ebp + 8]		; original string
	lpSubstring       EQU [ebp + 12]	; substring addr
	dSubstringLength  EQU [ebp - 4]		; length of substr
	dStringLength     EQU [ebp - 8]		; length of string
	dStringIndex	  EQU [ebp - 12]	; string index
	dSubStringIndex   EQU [ebp - 16]	; substring index
	
	enter 16,0						; set stack frame, 4 locals
	push esi						; save esi values on stack
	push edi						; save edi values on stack
	push ecx						; save ecx values on stack
	push ebx						; save ebx values on stack
	
	push lpString					; push string addr to stack
	CALL String_length				; get length of string
	cmp eax, 0						; checks if string is empty
	jle errorL						; jumps to error label
	mov dStringLength, eax			; set string length
	
	push lpSubstring				; push substring addr to stack
	CALL String_length				; get length of string
	cmp eax, 0						; checks if string is empty
	jle errorL						; jumps to error label
	mov dSubstringLength, eax		; set substring length
	mov esi, lpString				; set esi to string addr
	mov ecx, dStringLength			; set ecx to string length
	sub ecx, dSubstringLength		; sub string len from substring len
	mov ebx, dSubstringLength		; set ebx to substring length
	
	push ebx						; save substr len on stack
	mov ebx, 0						; reset ebx to 0
	mov dStringIndex, ebx			; set string index to 0
	pop ebx							; restore ebx to substr length
	
stringLoop:							; label for string loop
	cmp dStringIndex, ecx			; compare index to length of 
	jg errorL						; SF=OF? jump to error
	
	push ebx						; save substr len on stack
	mov ebx, 0						; reset ebx to 0
	mov dSubstringIndex, ebx		; set substring index to 0
	pop ebx							; restore substr len in ebx
	mov edi, lpSubstring			; set edi to substring addr
	
	push esi						; save string addr on stack
substringLoop:						; label for looping thru substr
	cmp dSubstringIndex, ebx		; compare substr index to substr length
	je foundL						; ZF=1? jump to found label
	cmpsb							; compare char in esi and edi
	jne incStringL					; ZF=0? jump to increment string
	inc dword ptr dSubstringIndex	; increment substring index
	jmp substringLoop				; continue checking for substring

incStringL:							; label for searching string
	pop esi							; restore address to string
	inc dword ptr dStringIndex		; increment index of string
	inc esi							; increment pointer to string
	jmp stringLoop					; jump to string loop label
	
foundL:								; label for index substring found
	pop esi							; restore string pointer
	mov eax, dStringIndex			; set eax to index in string

returnL:							; return label
	pop ebx							; restore ebx from stack
	pop ecx							; restore ecx from stack
	pop edi							; restore edi from stack
	pop esi							; restore esi from stack
	leave							; restore ebp
	ret 8							; stdcall, clean 2 args
errorL:								; error label
	mov eax, -1						; set eax to -1
	jmp returnL						; go to return label
String_indexOf_3 ENDP				; end of proc


;-----------------------------------------------------
String_lastIndexOf_1 PROC Near32
;	lpString:dword,		; string addr
;	cCharKey:byte		; key of char
;	:dword				; return index of char
;
; Receives a string address and a character, then
;  searches the string for the character from the end
;  of the string
; Returns the index of the character in the string
; Returns -1 if not found
;-----------------------------------------------------
	lpString    EQU [ebp + 8]	; string addr
	cCharKey    EQU [ebp + 12]	; char key
	
	enter 0,0					; set stack frame
	push edi					; save edi values on stack
	push ecx					; save ecx values on stack
	
	mov edi, lpString			; set edi to string addr
	push edi					; arg1 push edi to stack
	CALL String_length			; get length of string
	
	mov ecx, eax				; move length to ecx
	dec eax						; decrement eax
	add edi, eax				; go to last index of string
	mov al, byte ptr cCharKey	; set al to key
	
	std							; set direction flag
	repne scasb					; compare al to char in edi
	jnz errorL					; ZF=0? not found
	inc edi						; increment edi, 1 past
	sub edi, lpString			; go to beg of substr in str
	mov eax, edi				; set eax to index
	
returnL:						; return label
	cld							; clear direction flag
	pop ecx						; restore ecx from stack
	pop esi						; restore esi from stack
	leave						; restore ebp from stack
	ret 6						; stdcall, clean 2 args
errorL:							; error label
	mov eax, -1					; set eax to -1
	jmp returnL					; jump to return label
String_lastIndexOf_1 ENDP		; end of proc


;-----------------------------------------------------
String_lastIndexOf_2 PROC Near32
;	lpString:dword,		; string to search
;	cCharKey:byte,		; char key to search for
;	dFromIndex:dword	; starting search index
;	:dword				; return last index of char
;
; Receives a string address, character key, and 
;  starting index position, then searches the string 
;  for the character starting at the input index position
;  in reverse order from the back of the string to the front
; Returns the index of the character in the string
; Returns -1 if not found or input position is out of bounds
;-----------------------------------------------------
	lpString    EQU [ebp + 8]	; string to search
	cCharKey    EQU [ebp + 12]	; char to search for
	dFromIndex  EQU [ebp + 14]	; index to begin search
	
	enter 0,0				  ; set stack frame
	push edi				  ; save edi values on stack
	push ecx				  ; save ecx values on stack
	
	mov ecx, dFromIndex		  ; set ecx to starting index
	cmp ecx, 0				  ; compare ecx, 0
	jl errorL				  ; SF != OF? error
	
	mov edi, lpString		  ; set edi to string addr
	push edi				  ; push edi as arg to stack
	CALL String_length		  ; get length of string
	cmp ecx, eax			  ; starting index >= length of str?
	jge errorL				  ; ZF=1, SF = OF? error
	
	add edi, dFromIndex		  ; set edi to starting index in string
	push word ptr cCharKey	  ; character to search for
	push edi				  ; push string from input starting point
	CALL String_lastIndexOf_1 ; call older proc with new starting point
	cmp eax, -1				  ; if not found, return
	je returnL				  ; ZF=1, return
	add eax, dFromIndex		  ; else, ZF=0, return real index
	
;	dec eax					  ; dec length to match indx
;	mov ecx, eax			  ; set ecx to max index
;	sub ecx, dFromIndex		  ; subtract max index from start index
;	add edi, eax			  ; set edi to addr of starting index
;	mov al, cCharKey		  ; set al to key
	
;	std						  ; set direction flag(reverse)
;	repne scasb				  ; compare al to char in edi while !=
;	jnz errorL				  ; ZF=0, error
;	inc edi					  ; increment edi, point to end index
;	sub edi, lpString		  ; get starting index
;	mov eax, edi			  ; set eax to index of string
	
returnL:					  ; return label
;	cld						  ; clear direction flag
	pop ecx					  ; restore ecx from stack
	pop edi					  ; restore esi form stack
	leave					  ; restore ebp from stack
	ret 10					  ; stdcall, clean 3 args
errorL:						  ; error label
	mov eax, -1				  ; set eax to -1
	jmp returnL				  ; jump to return label
String_lastIndexOf_2 ENDP	  ; end of process


;-----------------------------------------------------
String_lastIndexOf_3 PROC Near32
;	lpString:dword,		; string addr
;	lpSubstring:dword	; substring addr
;	:dword				; return index found
;
; Receives an address to a string and a substring,
;  then searches the string to check if it contains
;  the substring from the end of the string
; Returns the index of the first occurrence of the
;  substring in the string
; Returns -1 if not found
;-----------------------------------------------------
	lpString          EQU [ebp + 8]		; string addr
	lpSubstring       EQU [ebp + 12]	; substring addr
	dSubstringLength  EQU [ebp - 4]		; length of substring
	dStringLength     EQU [ebp - 8]		; length of string
	dStringIndex	  EQU [ebp - 12]	; index of string
	dSubstringIndex   EQU [ebp - 16]	; index of substring
	
	enter 16,0						; set stack frame, 4 locals
	push esi						; save esi values on stack
	push edi						; save edi values on stack
	push ecx						; save ecx values on stack
	
	push lpString					; push string addr to stack
	CALL String_length				; get string length
	dec eax							; get last index of string
	mov dStringLength, eax			; set last index
	mov dStringIndex, eax			; set to last index
		
	push lpSubstring				; push substr addr to stack
	CALL String_length				; get length of substring
	dec eax							; get last index
	mov dSubstringLength, eax		; set to last index of substr
	mov dSubstringIndex, eax		; set to last index of substr
	
	mov esi, lpString				; set esi to string addr
	add esi, dStringLength			; go to addr of last index
	
stringLoop:							; loop for string
	mov ecx, dSubstringLength		; set ecx to last index of substr
	cmp dStringIndex, ecx			; check last str index < last substr index
	jl errorL						; SF!=OF?, error
	
	mov edi, lpSubstring			; set edi to substring addr
	add edi, dSubstringLength		; set edi to last substr length
	
	push esi						; save esi contents on stack
substringLoop:						; label looping thru substring
	mov ecx, dSubstringIndex		; set ecx to last index
	cmp ecx, -1						; ecx == -1
	je foundL						; ZF = 1? found
	std								; set direction flag (reverse)
	cmpsb							; compare esi to edi char
	jne decStringL					; ZF=0, continue searching string
	dec dword ptr dSubstringIndex	; decrement substring index
	jmp subStringLoop				; keep searching substring/string
	
decStringL:							; label to ocntinue searching str
	pop esi							; restore string addr in esi
	dec dword ptr dStringIndex		; dec string index
	dec esi							; dec esi addr for string
	jmp stringLoop					; jump string loop

foundL:								; label found
	pop esi							; restore esi from stack
	mov eax, dStringIndex			; set eax to end of substr in str index
	sub eax, dSubstringLength		; set eax to beg of substr in str

returnL:							; return label
	cld								; set direction flag
	pop ecx							; restore ecx from stack
	pop edi							; restore edi from stack
	pop esi							; restore esi from stack
	leave							; restore stack frame
	ret 8							; stdcall, clean 2 args
errorL:								; error label
	mov eax, -1						; set eax to -1
	jmp returnL						; jump to return label
String_lastIndexOf_3 ENDP			; end of procedure


;-----------------------------------------------------
String_concat PROC Near32
;	lpString1:dword		; string 1 address
;	lpString2:dword		; string 2 address
;	:dword				; return combined str addr
;
; Receives the address of two strings, then concatenates
;  the second string to the first string.
; Returns the address of that newly created string
;  if there is not enough space to allocate for a new
;  string, 0 is returned in eax
;-----------------------------------------------------
	lpString1      EQU [ebp + 8]	; string 1 addr
	lpString2      EQU [ebp + 12]	; string 2 addr
	dString1Length EQU [ebp - 4]	; length of str1
	dString2Length EQU [ebp - 8]	; length of str2
	
	enter 8,0						; set stack frame
	push esi						; save esi values on stack
	push edi						; save edi values on stack
	push ecx						; save ecx values on stack
	
	mov esi, lpString2				; set esi to string 2 addr
	push esi						; arg 1 esi
	CALL String_length				; get string 2 length
	mov dString2Length, eax			; set pointer to str2 length
	
	mov esi, lpString1				; set esi to string 1 addr
	push esi						; arg1 esi
	CALL String_length				; get string 1 length
	mov dString1Length, eax			; set pointer to str1 length
	
	mov ecx, dString2Length			; set ecx to string 2 len
	add ecx, dString1Length			; add str1 len to str2 len
	inc ecx							; room for null term
	
	INVOKE memoryallocBailey, ecx	; get dynamic memory addr
	jz returnL						; exit no memory
	
	mov ecx, dString1Length			; set ecx to str1 len
	mov edi, eax					; set edi to new str addr
	cld								; clear direction flag
	rep movsb						; copy all contents str1
	
	mov ecx, dString2Length			; set ecx to str2 len
	inc ecx							; inc ecx for null term
	mov esi, lpString2				; set esi to str2 addr
	rep movsb						; copy all str2 inc null term

returnL:							; return label
	pop ecx							; restore ecx values from stack
	pop edi							; restore edi values from stack
	pop esi							; restore esi values from stack
	leave							; restore ebp addr
	ret 8							; stdcall, clean 2 args
String_concat ENDP					; end of procedure


;-----------------------------------------------------
String_replace PROC Near32
;	lpString:dword		; string addr
;	cOldChar:byte		; char to replace
;	cNewChar:byte		; new char
;	:dword				; return new str w/ replacements
;
; Receives the address of a string, character to 
;  replace, and a character to replace with
; Returns the address of that newly created string with
;  all old characters replaced with new characters
;  if there is not enough space to allocate for a new
;  string, 0 is returned in eax
;-----------------------------------------------------
	lpString EQU [ebp + 8]		; string addr
	cOldChar EQU [ebp + 12]		; old char to replace
	cNewChar EQU [ebp + 14]		; new char
	
	enter 0,0						; set stack frame
	push esi						; save esi to stack
	push edi						; save edi to stack
	push ecx						; save ecx to stack
	push ebx						; save ebx to stack
	
	mov esi, lpString				; set esi to string addr
	push esi						; arg 1 esi to stack
	CALL String_length				; get string length
	mov ecx, eax					; set ecx to string length
	inc ecx							; inc ecx for null term
	INVOKE memoryallocBailey, ecx	; get new string alloc
	jz returnL						; ZF=1? return
	mov edi, eax					; set edi to new string addr
	
	mov ebx, 0						; reset ebx
	mov bl, cOldChar				; set bl to old char
	mov bh, cNewChar				; set bh to new char
checkReplaceL:						; label to check char
	cmp byte ptr [esi], bl			; str[esi] == bl?
	jne copyCharL					; ZF=0? copy char
	mov byte ptr [edi], bh			; else set char to bh
	jmp incPtrL						; jump to next char
copyCharL:							; copy old char label
	push ebx						; save ebx chars
	mov bl, byte ptr [esi]			; set bl to str char
	mov byte ptr [edi], bl			; set new str char to bl
	pop ebx							; restore key/new char in ebx
incPtrL:							; inc ot next char label
	inc esi							; point esi to next char
	inc edi							; point edi to next char
	loop checkReplaceL				; loop thru string

returnL:							; return label
	pop ebx							; restore ebx from stack
	pop ecx							; restore ecx from stack
	pop edi							; restore edi from stack
	pop esi							; restore esi from stack
	leave							; restore ebp 
	ret 8							; stdcall, clean 3 args
String_replace ENDP					; end of proc


;-----------------------------------------------------
String_toLowerCase PROC Near32
;	lpString:dword		; string addr
;	:dword				; returns new string in lowercase
;
; Receives the address of a string and returns a copy
;  of the string in all lowercase
; Returns the address of that newly created string
;  if there is not enough space to allocate for a new
;  string, 0 is returned in eax
;-----------------------------------------------------
	enter 0,0						; set stack frame
	push esi						; save esi to stack
	push edi						; save edi to sack
	push ecx						; save ecx values on stack
	push ebx						; save ebx to stack
				
	mov eax, 0						; clear eax
	mov esi, [ebp + 8]				; set esi to string addr
	push esi						; arg1 esi to stack
	CALL String_length				; get string length
	mov ecx, eax					; set ecx to length
	inc ecx							; inc ecx for null term
	INVOKE memoryallocBailey, ecx	; get new string 
	jz returnL						; ZF=1? return
	mov edi, eax					; set edi to new string addr
	
stringLoop:							; loop thru string label
	mov bl, byte ptr [esi]			; set bl to char in string
	cmp bl, 'A'						; bl < 'A'?
	jl copyCharL					; SF != OF? straight copy char
	cmp bl, 'Z'						; bl > 'Z'?
	jg copyCharL					; SF != OF? straight copy char
	or bl, 00100000b				; else set char to lower case
copyCharL:							; copy char label
	mov byte ptr [edi], bl			; copy char in bl to new str
	inc esi							; point to next char in str
	inc edi							; point to next char in new str
	loop stringLoop					; loop thru string

returnL:							; return label
	pop ebx							; restore ebx from stack
	pop ecx							; restore ecx from stack
	pop edi							; restore edi from stack
	pop esi							; restore esi from stack
	leave							; restore ebp from stack
	ret 4							; stdcall, clean 1 arg
String_toLowerCase ENDP				; end of proc


;-----------------------------------------------------
String_toUpperCase PROC	Near32
;	lpString:dword			; string addr
;	:dword					; return new string in uppercase
;
; Receives the address of a string and returns a copy
;  of the string in all uppercase
; Returns the address of that newly created string
;  if there is not enough space to allocate for a new
;  string, 0 is returned in eax
;-----------------------------------------------------
	enter 0,0						; set stack frame
	push esi						; save esi on stack
	push edi						; save edi on stack
	push ecx						; save ecx on stack
	push ebx						; save ebx on stack
	
	mov eax, 0						; reset eax to 0
	mov esi, [ebp + 8]				; set esi to string addr
	push esi						; push esi to stack arg1
	CALL String_length				; get string length
	mov ecx, eax					; set ecx to length
	inc ecx							; inc ecx for null term
	INVOKE memoryallocBailey, ecx	; get new string addr
	jz returnL						; zf=1? return
	mov edi, eax					; set edi to new string addr
	
stringLoop:							; loop thru string label
	mov bl, byte ptr [esi]			; set bl to char in str
	cmp bl, 'a'						; bl < 'a'?
	jl copyCharL					; SF != OF? copy char
	cmp bl, 'z'						; bl > 'z'?
	jg copyCharL					; SF = OF, copy char
	and bl, 11011111b				; convert bl to uppercase
copyCharL:							; copy char label
	mov byte ptr [edi], bl			; set new str char from bl
	inc esi							; point string to next char
	inc edi							; point new string to next char
	loop stringLoop					; loop thru string

returnL:							; return label
	pop ebx							; restore ebx from stack
	pop ecx							; restore ecx from stack
	pop edi							; restore edi from stack
	pop esi							; restore esi from stack
	leave							; restore ebp form stack
	ret 4							; stdcall, ret 4 args
String_toUpperCase ENDP				; end of proc

end				  						; end of program