;Chap4 P-BUZZ.asm
;WWW.MWFTR.COM/book.html
;Charles Kim
;push button and buzz
; This is to test a Piezo Buzzer 32S4120
;
; Frequency Range is 4KHz+/- 0.5KHz
;
;
;
;
;PBuzz is connected to RD4
;


        list P = 16F877

STATUS	EQU	0x03
PORTD	EQU	0x08
TRISD	EQU	0x88
PBUZZ	EQU	0x04

;4000HZ  ; Hihg Duration (125us) and LOW (125 us)
;
;
;RAM arEA
       
	CBLOCK	0x20
		TEMP
		TEMP2
		Kount120us   ;Delay count (number of instr cycles for delay)
		Kount100us
		Kount1ms
		Kount10ms
		Kount100ms
		Kount500ms
		Kount1s
		Kount10s
		Kount1m
	ENDC

;
;The Next 5 lines must be here
;because of bootloader arrangement
;Bootloader first execute the first 4 addresses
;then jump to the address what the execution directs 
;=========================================================
        org 	0x0000      	;line 1
	GOTO	START		;line 2 ($0000)
	NOP			;line 3 ($0001)
	NOP			;line 4 ($0002)
	NOP			;line 5 ($0003)
;======================================================
;start of the program from $0004

START	
	BANKSEL	TRISD
        movlw 	0x00		;RD0 - RD7 are all outputs
        movwf 	TRISD

        BANKSEL	PORTD
	clrf	PORTD
AGAIN
   	movlw	0x04		;4 pulses of 1 Hz
	banksel	TEMP
	movwf	TEMP
LOOPc	bsf	PORTD, PBUZZ
	call	Delay500ms
	bcf	PORTD, PBUZZ
	call	Delay500ms
	decfsz	TEMP
	goto	LOOPc
	call	Delay1s

	movlw	0x08		;8 pulses of 5Hz
	banksel	TEMP
	movwf	TEMP
LOOPb	bsf	PORTD, PBUZZ
	call	Delay100ms
	bcf	PORTD, PBUZZ
	call	Delay100ms
	decfsz	TEMP
	goto	LOOPb
	call	Delay1s

	movlw	0x30		;25 pulses of 50Hz
	banksel	TEMP
	movwf	TEMP
LOOPa	bsf	PORTD, PBUZZ
	call	Delay10ms
	bcf	PORTD, PBUZZ
	call	Delay10ms
	decfsz	TEMP
	goto	LOOPa
	call	Delay1s


	movlw	0xFF		;255 pulses of 500Hz
	banksel	TEMP
	movwf	TEMP
LOOP	bsf	PORTD, PBUZZ
	call	Delay1ms
	bcf	PORTD, PBUZZ
	call	Delay1ms
	decfsz	TEMP
	goto	LOOP

	call	Delay1s
;	call	delay1s	
				;2550 pulses of 4000Hz
	movlw	0x10
	movwf	TEMP
LOOP3	movlw	0xFF
	movwf	TEMP2
LOOP2	bsf	PORTD, PBUZZ
	call	Delay120us
	bcf	PORTD, PBUZZ
	call	Delay120us
	decfsz	TEMP2
	goto	LOOP2
	decfsz	TEMP
	goto	LOOP3

	call	Delay1s
	call	Delay1s
	goto	AGAIN


;==========================================================
;DELAY SUBROUTINES 


; 1 instruction cycle for 20MHz clock is 0.2 us
; Therefore 120 uS delay needs 600 instuction cycles
;  600 =199*3 +3 ---->Kount=199=0xC7
;  or  =198*3 +6 ---->Kount=198=0xC6
;  or  =197*3 +9 ---->Kount=197=0xC5

Delay120us
	banksel	Kount120us
	movlw	H'C5'		;D'197'
	movwf	Kount120us
R120us	decfsz	Kount120us
	goto	R120us
	return
;
;100us delay needs 500 instruction cycles
;  500 =166*3 +2 ---->Kount=166=0xA6
;  or  =165*3 +5 ---->Kount=165=0xA5
;  or  =164*3 +8 ---->Kount=164=0xA4
Delay100us
	banksel	Kount100us
	movlw	H'A4'
	movwf	Kount100us
R100us	decfsz	Kount100us
	goto	R100us
	return

;
Delay1ms 
	banksel	Kount1ms
	movlw	0x0A	;10
	movwf	Kount1ms
R1ms	call	Delay100us
	decfsz	Kount1ms
	goto	R1ms
	return
;
;10ms delay
; call 100 times of 100 us delay  (with some time discrepancy)
Delay10ms 
	banksel	Kount10ms
	movlw	H'64'	;100
	movwf	Kount10ms
R10ms	call	Delay100us
	decfsz	Kount10ms
	goto	R10ms
	return
;====
Delay100ms 
	banksel	Kount100ms
	movlw	0x0A
	movwf	Kount100ms
R100ms	call	Delay10ms
	decfsz	Kount100ms
	goto	R100ms
	return
;
Delay500ms 
	banksel	Kount500ms
	movlw	0x05
	movwf	Kount500ms
R500ms	call	Delay100ms
	decfsz	Kount500ms
	goto	R500ms
	return	
;1 sec delay
;call 100 times of 10ms delay
Delay1s
	banksel	Kount1s
	movlw	H'64'
	movwf	Kount1s
R1s	call	Delay10ms
	decfsz	Kount1s
	goto	R1s
	return
;
;
;10 s delay
;call 10 tiems of 1 s delay
Delay10s
	banksel	Kount10s
	movlw	H'0A'		;10
	movwf	Kount10s
R10s	call	Delay1s
	decfsz	Kount10s
	goto	R10s
	return
;
;1 min delay
;call	60 times of 1 sec delay
Delay1m
	banksel	Kount1m
	movlw	H'3C'	;60
	movwf	Kount1m
R1m	call	Delay1s
	decfsz	Kount1m
	goto	R1m
	return
;======================================================

;END OF CODE
        END
