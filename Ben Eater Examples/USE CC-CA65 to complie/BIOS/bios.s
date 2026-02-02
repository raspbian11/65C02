.setcpu "65C02"
.debuginfo
.segment "BIOS"

ACIA_DATA   = $5000
ACIA_STATUS = $5001
ACIA_CMD    = $5002
ACIA_CTRL   = $5003

CHRIN:
                lda ACIA_STATUS    ; Check status
                and #$08           ; Key ready?
                beq @no_keypresses
                lda ACIA_DATA      ; Load character
                jsr CHROUT
                sec
                rts
@no_keypresses:
                clc
                rts

CHROUT:
                pha
                sta ACIA_DATA
                lda #$FF
@txdelay:        dec
                bne @txdelay
                pla
                rts

.include "wozmon.s"

.segment "RESETVEC"
                .word   $0F00          ; NMI vector
                .word   RESET          ; RESET vector
                .word   $0000          ; IRQ vector
