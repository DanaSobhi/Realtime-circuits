;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;       Source File:	LED1H.ASM		
;	Author:		MPB              
;	Date:		2-12-05      
;
;	Output binary count incremented
;       and reset with push buttons. 
;	Uses hardware timer to debounce input switch
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

	PROCESSOR 16F877	; Define MCU type
	__CONFIG 0x3731		; Set config fuses 0011011100110001

; Register Label Equates....................................

PORTB   EQU 06	; Port B Data Register     
TRISB	EQU	86	; Port D Direction Register
   
PORTD   EQU 08	; Port D Data Register  
TRISD	EQU	88	; Port D Direction Register

TMR0	EQU	01	; Hardware Timer Register
INTCON	EQU	0B	; Interrupt Control Register
OPTREG	EQU	81	; Option Register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ORG	000		; Start of program memory
	NOP			; For ICD mode
	GOTO	init		; Jump to main program

; Interrupt Service Routine ................................

	ORG	004
	BCF	INTCON,2	; Reset TMR0 interrupt flag
	RETFIE			; Return from interrupt

; Initialise Port D (Port B defaults to inputs).............
        
init	NOP						; BANKSEL cannot be labelled
		BANKSEL	TRISD			; Select bank 1
		MOVLW   0x0    			; Port B Direction Code
    	MOVWF	TRISD          	; Load the DDR code into F86

		BANKSEL	TRISB
       	MOVLW   b'00000110'    ; Port B Direction Code
		MOVWF	TRISB

; Initialise Timer0 ........................................

	;BANKSEL	OPTREG
	MOVLW	b'11010000'	; TMR0 initialisation code
	MOVWF	OPTREG		; Int clock, no prescale	
	
	MOVLW	b'10000000'	;	b'10100000'	; INTCON init. code
	MOVWF	INTCON		; Enable TMR0 interrupt

	BANKSEL	PORTD		; Select bank 0

; Start main loop ...........................................

reset   CLRF    PORTD  		; Clear Port B Data 

start   BTFSS  	PORTB,1   	; Test reset button
       	GOTO   	reset       ; and reset Port B if pressed
        BTFSC  	PORTB,2   	; Test step button
        GOTO  	start          	; and repeat if not pressed

		CLRF	TMR0		; Reset timer
wait	BTFSS	INTCON,2	; Check for time out
		GOTO	wait		; Wait if not
stepin	BTFSS	PORTB,2		; Check step button
		GOTO	stepin		; and wait until released
        INCF   	PORTD,f     ; Increment output at Port B 
        GOTO   	start       ; Repeat main loop always

        END                   	; Terminate source code......
