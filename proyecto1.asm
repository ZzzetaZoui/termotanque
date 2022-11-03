__config 3F10
LIST P=16F628A
#include <p16f628a.inc>
ERRORLEVEL -302

;---------------------------------------------------
;CODIFICACIÓN INICIAL, DETERMINAMOS SUS VARIABLES
;---------------------------------------------------

temperatura_a equ 0x21 ; indicador de temperatura actual
temperatura_mn equ 0x22 ; indicador de temp. minima
temperatura_mx equ 0x23 ; indicador de temp. maxima

canilla_abierta equ 0x24 ; registro que se irá complementando

cont1 equ 0x25 ;CONFIGURACIONES DE LOS RETARDOS
cont2 equ 0x26 ; " " " "
cont3 equ 0x27 ; " " " "
cont4 equ 0x28 ; " " " "

ENDC

ORG 0X00

call CONFUGURAR_PUERTOS
call CONFIGURAR_SENSORES
goto INICIO

;------------------------------------------------------
;SUBRUTINA PRINCIPAL
;------------------------------------------------------

INICIO
	comf canilla_abierta, f ;complementación de este registro, F.
							;LOS SIGUIENTES CALL SERÁN PARA CALENTAR
							; EL AGUA Y LUEGO ESPERAR 10 SEGUNDOS
	call calentar_agua 
	call delay_10s
							;LO MISMO QUE EL PUNTO ANTERIOR, SOLO QUE
							;ESTE HACE ENFRIAMIENTO Y ESPERA DE 10 SEGUNDOS
	call enfriar_agua
	call delay_10s

	goto INICIO ; bucle infinito

;------------------------------------------------------
CONFIGURAR_SENSORES
	
	movlw D'20' ;VALOR INICIAL EN W
	movwf temperatura_a ;LO CARGAMOS EN W SU VALOR DE TEMPERATURA ACTUAL

	movlw D'30' ;VALOR INICIAL EN W
	movwf temperatura_mn ;CARGAMOS EL VALOR DE W A TEMPERATURA MINIMA

	movlw D'70' ;VALOR INICIAL W
	movwf temperatura_mx ;CARGAMOS EL VALOR DE W A TEMPERATURA MÁXIMA

	clrf canilla_abierta ;CERRADO POR DEFECTO

	return

;--------------------------------------------------------
;SUBRUTINA DE CALENTAR EL AGUA
;--------------------------------------------------------

calentar_agua
	movfw temperatura_a ; RESTAMOS MAX - ACT
	subwf temperatura_mx, w ; VERIFICA SI TEMPERATURA_MX > TEMPERATURA_A

	btfsc status, c ; Si TEMPERATURA_A > TEMPERATURA_MX salta
	call calentar_agua_0 ; Si TEMPERATURA_A < TEMPERATURA_MX ejecuta CALENTAR_AGUA_0

	call encender led_rojo ;indica temperatura maxima

	return

calentar_agua_0

	incf temperatura_a, f ; temperatura_a += 1
	call led_amarillo ; resistencia prendida
	
	movfw temperatura_a			; Restamos TEMPERATURA_MX - TEMPERATURA_A
	subwf temperatura_mx, w			; Si es iguales, el Z del status debe ser 1
		
	BTFSS STATUS,Z			; Salta si STATUS,Z es 1
	GOTO CALENTAR_AGUA_0		; Hasta que no se llegue, sigue aumentando
		
	RETURN

;--------------------------------------------------------
;SUBRUTINA DECREMENTO DE TEMPERATURA ACTUAL
;--------------------------------------------------------

enfriar_agua
	movwf temperatura_mn ; verificamos que la temperatura actual sea mayor que
	subwf temperatura_a, w ; la minima mediante la resta W = temperatura_a - temperatura_mn 

	btfsc status, c ; salta si su temperatura es minima

	call enfriar_agua_0 ; sino solo decremente
	call led_verde ;temperatura que lllegó a su minima, encendida.

enfriar_agua_0
	decf temperatura_a ; decrementa el agua en 1
	call led_azul ;indicador de resistencia apagada
	
	btfsc canilla_abierta,0		; Si la canilla esta abierta
	call enfriado_rapido	; que decremente de a 2
		
	movwf temperatura_mn			; cargamos el regisro W con el valor de temperatura_a
	subwf temperatura_a,w			; se realliza una resta entre la temperatura minima y actual	
		
	btfss STATUS,Z			; Si la temperatura es la minima que deje de decrementar	
	goto enfriado_rapido		; por lo contrario que continue decrementando
		
	return
		
		
		
		
enfriado_rapido
	movlw D'2'			; Cargamos el valor a decrementar
	subwf temperatura_a,f	; su temperatura actual le restamos 2
	

	return

;-----------------------------------------------------------------------
; RETARDOS
;-----------------------------------------------------------------------

delay_1ms
	movlw d'250' ;carga en w el valor
	movwf cont1 ;carga de valor w al cont1

retardo1
					;DECREMENTAMOS EN 1, HASTA LLEGAR A 0
					;EN SU PRIMER CONTADOR
	nop
	decfsz cont1, f
	goto retardo1 

delay_250ms
	movlw d'250' 
	movwf cont2

retardo2
					;ES CASI EL MISMO PROCEDIMIENTO QUE EL ANTERIOR
					;SOLO QUE SE ESPERA 1 MS, Y HACE LO MISMO QUE EL ANTERIOR RETARDO1
					;SOLO QUE USANDO SU CONTADOR 2
	call delay_1ms
	decfsz cont2, f
	goto retardo2
	return

delay_1s
	movlw d'4'
	movwf cont3

retardo3
						; ESPERA DE 250MS POR DECREMENTO DEL CONT3
						; 250 X 4 = 1S, REPITIENDO LA ACCIÓN
						; HASTA QUE SEA 0
	call delay_250ms
	decfsz cont3, f
	return

delay_10s
	movlw d'10'
	movfw cont4

retardo4
						;ESPERA DE UN 1S POR DECREMENTO, DEL
						;CONT4: 1S X 10 = 10S, SE REPITE LA ACCIÓN
						;HASTA LLEGAR A 0
	call delay_1s
	decfsz cont4, f
	goto retardo4
	return

;------------------------------------------------------------------------
;CONFIGURACIONES DE PUERTO
;------------------------------------------------------------------------

PUERTOS
	bsf	STATUS,RP0
	movlw B'11110000'		; RB0 hasta RB3 se usan como salida	
	movwf TRISB				; aclaramos en donde, soea trisB
	bcf STATUS,RP0
	return

;-------------------------------------------------------------------------
;SUBRUTINAS DE ENCENDER LOS LEDS
;-------------------------------------------------------------------------

						;ir al banco 0, para administrar el portB
						; habilitación de los puertos y se prenden leds 
						;con un retardo de 250 ms, y se deshabilitan.
led_azul
		bcf STATUS,RP0	
		bsf PORTB,0		
		call DELAY_250MS
		bcf PORTB,0	
		RETURN

led_rojo
		bcf STATUS,RP0
		bsf PORTB,1	
		call DELAY_250MS
		bcf PORTB,1	
		RETURN

led_amarillo
		bcf STATUS,RP0	
		bsf PORTB,2	
		call DELAY_250MS	
		bcf PORTB,2	
		RETURN

led_verde
		bcf STATUS,RP0
		bsf PORTB,3	
		call DELAY_250MS
		bcf PORTB,3		
		RETURN

		END