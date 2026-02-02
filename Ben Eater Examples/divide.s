PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

value = $0200 ; 2 bytes
mod10 = $0202 ; 2 bytes
message = $0204 ; 6 bytes

E  = %10000000
RW = %01000000
RS = %00100000

  .org $8000

reset:
  ldx #$ff
  txs

  lda #%11111111 ; Set all pins on port B to output
  sta DDRB
  lda #%11100000 ; Set top 3 pins on port A to output
  sta DDRA

  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #%00000001 ; Clear display
  jsr lcd_instruction

  lda #0
  sta message
  ; initialize value to be the number to convert
  lda number
  sta value
  lda number + 1    
  sta value + 1
divide:
  ; initialize the remainder to 0
  lda #0
  sta mod10
  sta mod10 + 1
  clc

  ldx #16

divloop:  
  ;rotating quotient and remainder
  rol value
  rol value + 1
  rol mod10
  rol mod10 + 1

  ; a,y = dividend - divisor
  sec
  lda mod10
  sbc #10
  tay ;save lo byte
  lda mod10 + 1
  sbc #0
  bcc ignore_result ; if result is negative, ignore
  sty mod10      ; could bcs to subrotiene
  sta mod10 + 1
ignore_result:
  dex
  bne divloop
  rol value ; shift in the last bit of the quotient
  rol value + 1

  lda mod10
  clc
  adc #"0"
  jsr push_char

  ;if value != 0 , then cointinue dividing
  lda value
  ora value + 1
  bne divide ; branch if not 0 to divide

  ldx #0
print:
  lda message,x
  beq loop
  jsr print_char
  inx
  jmp print
loop:
  jmp loop

number: .word 1729

; add the character in A to the begining of the null-terminated string 'message'
push_char:
  pha
  ldy #0

char_loop:
  lda message,y ; get character on string and put into x
  tax
  pla
  sta message,y ; pull char off stack and add it to the string
  iny
  txa
  pha
  bne char_loop

  pla
  sta message,y ; pull the null off stact and add to the emnd of the string
  rts
lcd_wait:
  pha
  lda #%00000000 ; sets input mode
  sta DDRB

lcd_busy:
  lda #RW
  sta PORTA
  lda #(RW | E); OR's bits together
  sta PORTA 
  lda PORTB ; puts contents of port B into accumulator
  and #%10000000 ; masks all but the busy flag bit
  bne lcd_busy ; if busy flag is 0, branch to lcd_ready
  
  lda #RW 
  sta PORTA
  lda #%11111111 ; sets as output mode
  sta DDRB
  pla
  rts


lcd_instruction:
  jsr lcd_wait
  sta PORTB
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  lda #E         ; Set E bit to send instruction
  sta PORTA
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  rts

print_char:
  jsr lcd_wait
  sta PORTB
  lda #RS         ; Set RS; Clear RW/E bits
  sta PORTA
  lda #(RS | E)   ; Set E bit to send instruction
  sta PORTA
  lda #RS         ; Clear E bits
  sta PORTA
  rts

  .org $fffc
  .word reset
  .word $0000
