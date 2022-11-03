	__config 3F10
	list P=16F628A
	#include <p16f628a.inc>
;-----------------------------------------------------------------------------------
;EJERCICIO 2 - LUCES LEDS.
;-----------------------------------------------------------------------------------
		CBLOCK 0x20

PDel0		;0X21
PDel1		;0X22

cont1		;0X23
cont2		;0X24
cont3		;0X25

		ENDC
;*********************************************************************************
 
        ORG             0x00
        BSF             STATUS,0                                ; activa la pagina 1
        MOVLW           b'11111111'                             ; comparadores desactivados,
        MOVWF           CMCON                                   ; E/S digitales.
        BCF             STATUS,0                               ; volvemos a la pagina 0
        CLRF            PORTB                                   ; ponemos a 0 portb
 
INICIO

																;PRENDER TODOS LOS LEDS
																;CON UNA DEMORA DE 1 SEGUNDO
		BSF 			PORTB, 0
		BSF 			PORTB, 1
		BSF 			PORTB, 2
		BSF 			PORTB, 3
		BSF 			PORTB, 4
		BSF 			PORTB, 5
		BSF 			PORTB, 6
		BSF 			PORTB, 7
		CALL 			RETARDO

																;APAGO TODOS LOS LEDS CON UNA
																;DEMORA DE UN SEGUNDO

		BCF 			PORTB, 0
		BCF 			PORTB, 1
		BCF 			PORTB, 2
		BCF 			PORTB, 3
		BCF 			PORTB, 4
		BCF 			PORTB, 5
		BCF 			PORTB, 6
		BCF 			PORTB, 7
		CALL 			RETARDO

																;PRENDO TODOS LOS LEDS LUEGO
																;DE LA ANTERIOR DEMORA DE UN
																;SEGUNDO

		BSF 			PORTB, 0
		BSF 			PORTB, 1
		BSF 			PORTB, 2
		BSF 			PORTB, 3
		BSF 			PORTB, 4
		BSF 			PORTB, 5
		BSF 			PORTB, 6
		BSF 			PORTB, 7
		CALL 			DEMORA									;SE USARÁ LA DEMORA DE MEDIO
																;SEGUNDO, OSEA 500 MS, PARA
																;PODER APAGARLOS.	

		BCF 			PORTB, 0
		BCF 			PORTB, 1
		BCF 			PORTB, 2
		BCF 			PORTB, 3
		BCF 			PORTB, 4
		BCF 			PORTB, 5
		BCF 			PORTB, 6
		BCF 			PORTB, 7
		CALL 			RETARDO									;LUEGO DE UN RETARDO DE 1 SEGUNDO
																;EMPIEZA EL SIGUIENTE PUNTO.

																;PRENDE TODOS CON UNA DEMORA
																;DE 500 MS ENTRE ELLOS

        BSF             PORTB,0                                 ; pone a 1 RB0
        CALL            DEMORA
		BSF				PORTB,1									; PONE 1 AL RB1
		CALL			DEMORA
		BSF				PORTB,2									; PONE 1 AL RB2
		CALL			DEMORA
		BSF				PORTB,3									; PONE 1 AL RB3
		CALL			DEMORA

																;PONE DEL RB3 AL RB0 EN 0
																;CON UNA DEMORA DE 500 MS

        BCF             PORTB,3                                 ; pone a 0 RB3
        CALL            DEMORA
        BCF             PORTB,2                                 ; pone a 0 RB2
        CALL            DEMORA   
        BCF             PORTB,1                                 ; pone a 0 RB1
        CALL            DEMORA 
        BCF             PORTB,0                                 ; pone a 0 RB0
        CALL            DEMORA     
 
        GOTO            INICIO                                  ; va a inicio

;---------------------------------------------------------------------------------------------
;DEMORAS DE UN SEGUNDO, SUBRUTINA.
;---------------------------------------------------------------------------------------------

																;ESTA SUBRUTINA HARÁ
																;UN CONTADOR DE UN 1S, QUE
																;IRÁ DECREMENTANDO PARA SU RETARDO
RETARDO
	
		MOVLW 0x23
		MOVWF cont3
RETA3
		movlw 0x64
		movwf cont2
RETA2
		movlw 0x64
		movwf cont1
RETA1
		decfsz cont1,f
		goto RETA1
		decfsz cont2,f
		goto RETA2
		decfsz cont3,f
		goto RETA3
		RETURN
	
	
	
;---------------------------------------------------------------------------------------------
;       La demora a sido generada con el programa PDEL
;       Delay 250000 ciclos
;---------------------------------------------------------------------------------------------
 
DEMORA  movlw     .197                                          ; 1 set numero de repeticion  (B)
        movwf     PDel0                                         ; 1
PLoop1  movlw     .253                                          ; 1 set numero de repeticion  (A)
        movwf     PDel1                                         ; 1
PLoop2  clrwdt                                                  ; 1 clear watchdog
        clrwdt                                                  ; 1 ciclo delay
        decfsz    PDel1,1                                       ; 1 + (1) es el tiempo 0  ? (A)
        goto      PLoop2                                        ; 2 no, loop
        decfsz    PDel0,1                                       ; 1 + (1) es el tiempo 0  ? (B)
        goto      PLoop1                                        ; 2 no, loop
PDelL1  goto PDelL2                                             ; 2 ciclos delay
PDelL2  
        return                                                  ; 2+2 Fin.
;----------------------------------------------------------------------------------------------
 
        END                                        