TITLE Project 6     (num_manipulator.asm)

; Last Modified: 3/13/22
; Description: Program asks user to input 10 signed integers. Integers must fit inside
;				a 32-bit register. The program validates each of the inputted integers
;				as follows:
;					- read user input as string, convert to numeric form
;					- if user enters non-digits (other than +/-) raise error
;					- if number is too large for 32-bit register, raise error
;					- if user enters nothing, raise error
;					- discard any number when an error is raised
;				The program displays all the numbers inputted by the user, calculates
;				the sum, displays the sum, calculates the truncated average, and finally
;				displays the truncated average. 
;
;
; 

INCLUDE Irvine32.inc

; --------------------------------------------------------------------------------- 
; Name: mGetString 
; 
; Prompts user to input integers. Stores user input and input size (EAX).  
; 
; Preconditions: called in readVal
; 
; Receives:
;		inputPrompt
;		input
;		ARRAYSIZE + 1		= 11
;		inputSize			= size of the value inputted by the user
; 
; returns: displays prompt to output, stores user input 
; --------------------------------------------------------------------------------- 
mGetString MACRO prompt, input, counter, stringLength
	; save registers
	PUSH	EDX
	PUSH	ECX
	PUSH	EAX

	; prompt user input 
	mov		EDX, prompt
	call	WriteString
	; read input
	mov		EDX, input				; input in EDX
	mov		ECX, counter			; counter to ECX
	call	ReadString
	; store length of input (EAX) in inputSize
	mov		inputSize, EAX

	_exit:
		; restore registers
		POP		EAX
		POP		ECX
		POP		EDX

ENDM

; --------------------------------------------------------------------------------- 
; Name: mDisplayString 
; 
; Takes as an input parameter a string. Displays string.
; 
; Preconditions: input parameter passed to EDX
; 
; Receives: 
;	string		+8		= string value to be displayed/printed to output
; 
; returns: display string to output
; --------------------------------------------------------------------------------- 
mDisplayString MACRO string
	PUSH	EDX

	mov	EDX, string
	call	WriteString

	POP	EDX

ENDM

; declare constants
	BLANKSPACE		= 32
	ARRAYSIZE		= 10

.data

	; intro strings
		programTitle			BYTE		"Project 6: Designing low-level I/O procedures by Kateri Boink",0
		promptIntro				BYTE		"Please provide 10 signed integers.",0
		promptNote				BYTE		"Each number must be small enough to fit in a 32-bit register.",0
		instructions			BYTE		"After you have finished inputting numbers, a list of the integers, their sum, and their average value will be displayed.",0
	
	; get data
		inputPrompt				BYTE		"Please enter a signed number: ",0
		errorMsg				BYTE		"ERROR! You did not enter a signed number or your number was too big.",0

		input					BYTE		ARRAYSIZE + 1 DUP(?)
		inputSize				DWORD		?

	; display and calculations
		printNums				BYTE		"You entered the following numbers: ",0
		printSum				BYTE		"The sum of these numbers is: ",0
		printAvg				BYTE		"The truncated average is: ",0

		sArray					SDWORD		10 DUP(?)
		sum						SDWORD		0
		average					SDWORD		0

		zero					DWORD		0
		arrayPrint				BYTE		1 DUP(?)
		avgPrint				BYTE		1 DUP(?)

	; goodbye
		goodbye					BYTE		"Goodbye!",0

.code
main PROC

; (1) INTRODUCTION
	; display program title
		PUSH	OFFSET programTitle
		PUSH	OFFSET promptIntro
		PUSH	OFFSET promptNote
		PUSH	OFFSET instructions
		call	introduction


; (2) GET INPUT
	; get user input
		PUSH	OFFSET zero
		PUSH	OFFSET inputSize
		PUSH	OFFSET input
		PUSH	OFFSET sArray
		PUSH	OFFSET errorMsg
		PUSH	OFFSET inputPrompt
		call	readVal
	; display user input
		PUSH	OFFSET printNums
		PUSH	OFFSET arrayPrint
		PUSH	OFFSET sArray
		call	printArray


; (3) SUM
	; calculate
		PUSH	OFFSET sum
		PUSH	OFFSET sArray
		call	calcSum
	; display sum
		PUSH	OFFSET printSum
		call	printTitle
		PUSH	OFFSET	arrayPrint
		PUSH	sum
		call	writeVal
		call	Crlf
		call	Crlf


; (4) AVERAGE
	; calculate
		PUSH	OFFSET average
		PUSH	sum
		call	calcAvg
	; display average
		PUSH	OFFSET printAvg
		call	printTitle
		PUSH	OFFSET	arrayPrint
		PUSH	average
		call	writeVal
		call	Crlf
		call	Crlf

		
; (5) CLOSING
	; display closing message
		PUSH	OFFSET goodbye
		call	closing

	Invoke ExitProcess,0	; exit to operating system

main ENDP

; --------------------------------------------------------------------------------- 
; Name: introduction 
; 
; Reads string input and displays to output.   
; 
; Preconditions: none
;
; Postcondition: none
; 
; Receives: 
;		programTitle		20
;		promptIntro			16
;		promptNote			12
;		instructions		8
;
; returns: none, display to output
; --------------------------------------------------------------------------------- 

introduction		PROC
	; setup
	PUSH	EBP
	mov		EBP, ESP

	; display program title
	mDisplayString [EBP+20]
	call	Crlf
	call	Crlf

	; display prompt
	mDisplayString [EBP+16]
	call	Crlf
	mDisplayString [EBP+12]
	call	Crlf
	mDisplayString [EBP+8]
	call	Crlf
	call	Crlf

	POP		EBP

	RET		16							; title +4 * 4 = 4

introduction ENDP

; --------------------------------------------------------------------------------- 
; Name: readVal 
; 
; Reads integer input parameter. Stores as string.  
; 
; Preconditions: none
;
; Postcondition: modifies register when input is stored as string
; 
; Receives: 
;		PUSH	OFFSET zero				28
;		PUSH	OFFSET inputSize		24
;		PUSH	OFFSET input			20
;		PUSH	OFFSET sArray			16
;		PUSH	OFFSET errorMsg			12
;		PUSH	OFFSET inputPrompt		8
; 
; returns: string
; --------------------------------------------------------------------------------- 
readVal PROC
	; setup
	PUSH	EBP
	mov		EBP, ESP

	; save registers
	PUSH	ESI
	PUSH	EDI
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX

	; set ECX equal to size of sArray (10)
	mov	ECX, ARRAYSIZE

	mov	EDI, [EBP+16]			; string Address of sArray

	_getInput:
		; save ECX counter
		PUSH		ECX

		; call mGetString: inputPrompt, input, ARRAYSIZE+1 (11), inputSize
		mGetString	[EBP+8], [EBP+20], ARRAYSIZE + 1, [EBP+24]

		; save EAX
		PUSH		EAX

		; set counter ECX as value of EAX (inputSize)
		mov		EAX, [EBP+24]
		mov		ECX, [EAX]

		; restore EAX
		POP		EAX

		mov		ESI, [EBP+20]			; input
		
		; move zero into EBX then move EBX into [zero]
		mov		EBX, 0					; reset EBX
		mov		[EBP+28], EBX			; reset zero

		; now validate input
		_checkSign:
			LODSB								; load string

			CMP		AL, 45						; ASCII (-)
			je		_negative					; if equal, negative sign present

			CMP		AL, 43						; ASCII (+)
			je		_positive					; if equal, positive sign present

			jmp		_checkRange					; else, validate integer range

		; if negative sign found
		_negative:
			; save EBX
			PUSH	EBX

			mov		EBX, 1
			mov		[EBP+28], EBX				; change [zero] to = 1
			
			; restore EBX
			POP		EBX

			; decrement counter
			SUB		ECX, 1

			jmp		_next

		; if plus sign found
		_positive:
			; decrement counter, no other changes needed
			SUB		ECX, 1

	_next:
		cld

		LODSB
		
		; continue validation
		jmp		_checkRange				

		_checkRange:
			; confirm string within 32-bit register (error if len >= 4)
			CMP		ECX, 3
			ja		_error

			; confirm string is within ASCII values 
			CMP		AL, 48			; 0 = 48
			jb		_error

			CMP		AL, 57			; 9 = 57
			ja		_error

			;CMP		AX, -2147483648
			;jb		_error

			;CMP		AX, 2147483647
			;ja		_error
			
			; if within range, continue 
			jmp		_cont

	_error:
		; if error, call mDisplayString: errorMsg
		mDisplayString	[EBP+12]
		call	Crlf

		; restore ECX to outer/external count
		POP		ECX	

		; reset [EDI] using EBX to prepare for new input
		mov		EBX, 0
		mov		[EDI], EBX

		; return to start of loop: prompt user to enter again
		jmp		_getInput
		
	_cont:
		; store [EDI] in EBX
		mov		EBX, [EDI]

		; save AL and EBX
		PUSH	EBX
		PUSH	EAX

		; multiply *10
		mov		EAX, EBX
		mov		EBX, 10
		MUL		EBX
		
		; store value in [EDI]
		mov		[EDI], EAX

		; restore registers
		POP		EAX
		POP		EBX

		; subtract 48 (0)
		SUB		AL, 48
		ADD		[EDI], AL

		; decrement counter, compare to zero
		SUB		ECX, 1
		CMP		ECX, 0
		ja		_next

		; save EAX
		PUSH	EAX

		; if number was negative, zero will be 1
		mov		EAX, [EBP+28]						; move [zero] to EAX
		CMP		EAX, 1
		je		_neg

		; if no negative sign needs to be added, exit procedure
		jmp		_end

		_neg:
			; move [EDI] to A register
			mov		EAX, [EDI]

			; negate value in register
			NEG		EAX

			; return negated value to [EDI]
			mov		[EDI], EAX
		
		_end:
			POP		EAX

			; move to next number
			ADD		EDI, 4

			; restore external counter
			POP		ECX
			; decrement counter
			SUB		ECX, 1
			CMP		ECX, 0

			; if counter hasn't reached zero, continue getting input until 10 numbers inputted
			jnz		_getInput

			; if 10 numbers have been inputted, exit procedure
			JMP		_exitProc

	_exitProc:
		POP		ECX
		POP		EBX
		POP		EAX
		POP		EDI
		POP		ESI
		POP		EBX
		; POP	EBP

		RET		28

readVal ENDP

; --------------------------------------------------------------------------------- 
; Name: writeVal 
; 
; Takes an integer value, converts it to its ASCII equivalent, and displays a string.   
; 
; Preconditions: none
; 
; Postconditions: changes register for string
; 
; Receives: 
;		PUSH	OFFSET	arrayPrint				12
;		PUSH	sum								8
; 
; returns: ASCII converted integer, displays string
; --------------------------------------------------------------------------------- 

writeVal PROC
	; setup
	PUSH	EBP
	mov		EBP, ESP

	; save registers
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDI
	PUSH	EDX

	; store address in EDI
	mov	EDI, [EBP+12]

	; store number in EAX
	mov	EAX, [EBP+8]

	; check first character of string
	CMP		EAX, 0
	jl		_addMinus

	PUSH	0
	JMP		_convert

	cld

	; add back (-)
	_addMinus:
		PUSH		EAX
		
		; move ascii character representation into AL
		mov			AL, 45						; 45 = (-) ascii character representation

		stosb	

		; call DisplayString: arrayPrint
		mDisplayString	[EBP+12]

		; return
		SUB		EDI, 1
		
		; restore EAX
		POP		EAX
		neg		EAX								; necessary to avoid double neg

	_convert:
		; prepare division
		mov		EDX, 0
		mov		EBX, 10
		; divide integer by 10
		div		EBX
		
		; convert remainder to decimal ascii representation
		mov		ECX, EDX
		ADD		ECX, 48

		; push ascii representation
		PUSH	ECX

		; compare until quotient is 0
		CMP		EAX, 0

		; once quotient equals zero, pop all
		je		_pop

		; if quotient not 0, continue until equal to 0
		jmp		_convert

	_pop:
		; pop quotient
		POP		EAX

		stosb

		; call mDisplayString: arrayPrint
		mDisplayString	[EBP+12]									; arrayPrint
		SUB		EDI, 1				; Move back to display again

		; if EAX is 0, exit procedure
		CMP		EAX, 0
		je		_exitProc

		; otherwise, continue to POP
		jmp		_pop

	_exitProc:
		; move space character into AL
		mov		AL, BLANKSPACE

		stosb

		; call mDisplayString for arrayPrint
		mDisplayString	[EBP+12]

		; print blank lines

		; reset EDI
		SUB		EDI, 1
	
		POP		EDX
		POP		EDI
		POP		ECX
		POP		EBX
		POP		EAX
		POP		EBP

		RET	8											; sum +4 , arrayPrint + 4 = 8

writeVal ENDP


; --------------------------------------------------------------------------------- 
; Name: printArray 
; 
; Takes user input (as array) and displays to output. 
; 
; Preconditions: none
; 
; Postconditions: ECX, ESI, EDI
; 
; Receives: 
;		sArray		+8		array to be displayed
;		arrayPrint	+12
;		printNums	+16		string: title to be displayed
; 
; returns: none ; displays array to output
; --------------------------------------------------------------------------------- 

printArray PROC
	; setup
	PUSH	EBP
	mov		EBP, ESP

	; save registers
	PUSH	ESI
	PUSH	EDI
	PUSH	ECX

	; input array
	mov	ESI, [EBP+8]

	; arrayPrint
	mov	EDI, [EBP+12]

	; setup counter for size of array (10)
	mov	ECX, ARRAYSIZE
	
	; print title for array
	_title:
		call	Crlf
		mDisplayString [EBP+16]

	; display array
	_display:
		; save arrayPrint external
		PUSH	EDI
		; save sArray external
		PUSH	[ESI]
		call	writeVal
		JMP		_increment

	_increment:
		; increment to next number in array
		ADD		ESI, 4
		loop	_display
		JMP		_newLine

	_newLine:
		; print new lines before exiting
		call	Crlf
		call	Crlf
		JMP		_exitProc

	_exitProc:
		POP		ECX
		POP		EDI
		POP		ESI
		POP		EBP
		
		RET		16									; sArray +4, arrayPrint +4, printNums +4 = 16

printArray ENDP

; --------------------------------------------------------------------------------- 
; Name: printTitle 
; 
; Reads string input and displays to output.   
; 
; Preconditions: none
;
; Postcondition: none
; 
; Receives: 
;		title		EBP+8		string to print to output
;
; returns: none, display to output
; --------------------------------------------------------------------------------- 

printTitle		PROC
	; setup
	PUSH	EBP
	mov		EBP, ESP

	; display title
	mDisplayString [EBP+8]

	POP		EBP

	RET		4							; title +4 = 4

printTitle ENDP


; --------------------------------------------------------------------------------- 
; Name: calcSum 
; 
; Calculates the sum of all numbers in an array.    
; 
; Preconditions: array is type SDWORD
; 
; Postconditions: changes EAX, EBX, ECX
; 
; Receives: 
;		sum			+12
;		sArray		+8		SDWORD
; 
; returns: displays prompt to output, stores user input 
; --------------------------------------------------------------------------------- 
calcSum PROC
	; setup
	PUSH	EBP
	mov		EBP, ESP

	; save registers
	PUSH	ESI
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX

	; store input sArray
	mov	ESI, [EBP+8]

	; set counter to size of array
	mov	ECX, ARRAYSIZE

	; clear EAX
	mov	EAX, 0

	_calculate:
		; add current value to EAX
		ADD		EAX, [ESI]
		
		; increment to next number in sArray
		ADD		ESI, 4

		loop	_calculate

		JMP		_store

	; sum currently stored in EAX
	_store:
		; move sum var to EBX
		mov		EBX, [EBP+12]

		; mov sum from EAX into value of sum var
		mov		[EBX], EAX

		JMP		_exitProc

	_exitProc:
		POP		ECX
		POP		EBX
		POP		EAX
		POP		ESI
		POP		EBP
	
		RET		8												; sArray +4 , sum +4 = 8

calcSum ENDP


; --------------------------------------------------------------------------------- 
; Name: calcAvg 
; 
; Calculates the average of the integers in an array. Uses SUM.    
; 
; Preconditions: array is type SDWORD. 
; 
; Postconditions: ECX, EAX, EBX
; 
; Receives: 
;		average				12
;		sum					8
; 
; returns: displays prompt to output, stores user input 
; --------------------------------------------------------------------------------- 
calcAvg PROC
	; setup
	PUSH	EBP
	mov		EBP, ESP

	; save registers
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX

	; set counter according to size of input
	mov	ECX, ARRAYSIZE

	; move sum into EAX
	mov	EAX, [EBP+8]					
	
	_calculate:
		; divide by size of array (10)
		mov		EBX, ARRAYSIZE
		mov		EDX, 0						; clear remainder

		cdq

		IDIV	EBX							; quotient stored in EAX

		; move average var into EBX
		mov	EBX, [EBP+12]
	
		; replace value of EBX with EAX (sum / ARRAYSIZE)
		mov	[EBX], EAX

		JMP		_exitProc

	_exitProc:
		; restore registers
		POP	ECX
		POP	EBX
		POP	EAX
		POP	EBP

		RET	12									; sum +4 , average +4 = 8

calcAvg ENDP


; --------------------------------------------------------------------------------- 
; Name: closing 
; 
; Takes an integer value, converts it to its ASCII equivalent, and displays a string.   
; 
; Preconditions: none
; 
; Postconditions: calls mDisplayString, EDX
; 
; Receives: 
;		goodbye		+8	= string: message to be displayed 
; 
; returns: displays closing message to output
; --------------------------------------------------------------------------------- 

closing		PROC

	; setup
	PUSH	EBP
	mov		EBP, ESP

	; display closing message
	mDisplayString [EBP+8]
	call	Crlf

	POP		EBP

	RET		4							; closing +4 = 4

	; exit

closing ENDP

END main
