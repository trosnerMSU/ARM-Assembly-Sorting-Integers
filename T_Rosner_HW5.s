;**********************************
; Sorting integers
; With ARM Assembly 
; Code
;
; Author: Tanner Rosner
; Class: Prof. Lakhani Comp Org 2
;**********************************
; R0 - File handler
; R2 - Table (Integer array)
; R3 - file handle placeholder
; R4 - Size of integer array
; R5 - integer min used for loop
; R6 - integer j used for inner loop
; R7 - placeholder for array integers
; R8 - placeholder for array integers
; R9 - i value
; R10 - 
; 
; *********************************

.equ Exit, 0x11             ; Halt execution
.equ Open, 0x66             ; Open file
.equ Close, 0x68            ; Close file
.equ PrInt, 0x6b            ; Write integer to stdout
.equ RdInt, 0x6c            ; Read Integer from a file
.equ InputMode, 0           ; Open file for reading
.equ OutputMode, 1          ; Open file for writing
.equ PrStr, 0x69			; Print string to file or stdout

.data
NewLine: .asciz "\n"
InFileError: .asciz "Unable to open file for input\n"
OutFileError: .asciz "Unable to open output file\n"
Infile: .asciz "input.txt"
OutFile: .asciz "output.txt"
Table: .word 0 
min:   .word 0

;Start of Program
.text
start:

; Open file for reading
		LDR R0, =Infile
		Mov R1, #InputMode
		SWI Open
		BCS input_error             ; Branch to error handler if carry flag is set
		Mov R3, R0                  ; Save file handle in R3

; Read integers from inputfile
		LDR R2, =Table              ; Load address of the table
		Mov R4, #0                  ; Set counter to 0
Loop:   Mov R0, R3                  ; Move input file handle to R0
		SWI RdInt					
		BCS done					; Branch to done - reached end of file
		STR R0, [R2]				; Store integer into memory
		Add R2, R2, #4				; Increment memory pointer
		Add R4, R4, #1				; Increment size counter
		B Loop                      ; Go to top of the loop to read next integer

done:

; Start with sorting the integer array
; We start with doing nested loops (Outer loop and Inner loop)

; Outer loop will iterate once through the Table
		Mov R5, #0                ; min-value
		Mov R9, #0					; i- value
		Mov R6, #0					; j-value
		Mov R3, #4
		Mul R1, R4, R3             ; size * 4
		LDR R2, =Table

Oloop:  CMP R9, R1                ; i - (size*4)
		BEq OloopEnd
        Mov R5, R9                  ; Min value is equal to i
		Add R6, R9, #4
	    
Iloop:  CMP R6, R1
		BEQ ILoopEnd
	    LDR R7, [R2, R5]			;R7 = Table[min]
		LDR R8, [R2, R6]			;R8 = Table[j]
		CMP R7, R8
		BLE noSwap                 ; if table[min] <= Table[j]
        Mov R5, R6

noSwap:
		Add R6, R6, #4
		B Iloop

ILoopEnd:
		LDR R7, [R2, R9]		; Temp(R7) = table[i]
		LDR R8, [R2, R5]		; Temp(R8) = Table[min]
		STR R7, [R2, R5]		; table[min] = table[i]
		STR R8, [R2, R9]		; table[i] = table[min]
		Add R9, R9, #4			; i++
		B Oloop
		
		; Now I will open my outputfile so I can write my integers
OloopEnd:
		
	   LDR R0, =OutFile
	   Mov R1, #OutputMode
	   SWI Open
	   Mov R0, R3

	   ; Now I will write my integers to the File
WriteFile:

		LDR R2, =Table		;Sets Table[] to R2 and @ first spot in array
		Mov R6, #0			; Init counter to zero
OutFileLoop:
		
		Mov R0, R3
		LDR R1, [R2]		; Moves table[i] to R1 to write 
		SWI PrInt			;Writes int to File
		Add R2, R2, #4		; Points to next spot in array (i)
		Add R6, R6, #1		; Increments counter 
		CMP R4, R6			;Compares array length to the counter
		BEQ end
		LDR R1, =NewLine	; Writes a newline for the next int
		SWI PrStr
		B OutFileLoop		;Branches back to top of loop

		; Now we close the File
OutFileClose:

		Mov R0, R4
		SWI Close
		B end

		
		

input_error: 

		Mov R0, #OutputMode
		LDR R1, =InFileError
		SWI PrStr


end:   SWI Exit 


