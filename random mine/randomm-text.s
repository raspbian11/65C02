PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E  = %10000000
RW = %01000000
RS = %00100000

  .org $8000

reset:

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
  
  ldx #0
print:
  lda message,x
  beq loop
  jsr print_char
  inx
  jmp print
  
loop:
  
  
  jmp loop

message: .asciiz "    ______ =                             Edgar Allen Poe"

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
