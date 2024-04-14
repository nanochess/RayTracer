        ;
        ; Ray tracer in a boot sector
	;
	; by Oscar Toledo G.
	; https://nanochess.org/
	;
	; Based on the original Atari 8-bit BASIC version by D. Scott Williamson.
	;
        ; Revision: Apr/11/2024. First working version.
	;

	;
	; The original code and comments are available at:
	; https://bunsen.itch.io/raytrace-movie-atari-8bit-by-d-scott-williamson
	;
	; I tuned the visuals using the VGA palette reference from:
	; https://www.fountainware.com/EXPL/vga_color_palettes.htm
	;
	; References for x87 instruction set from:
	; https://www.felixcloutier.com/x86/
	;

	bits 16
        cpu 686			; Minimum requirements: Pentium Pro.         

    %ifndef com_file            ; If not defined create a boot sector
com_file:       equ 0
    %endif

    %ifdef com_file
        org 0x0100              ; Start address for COM file
        mov al,0x13		; Video mode 320x200x256 colors
    %else
        org 0x7c00              ; Start address for boot sector
        mov ax,0x0013		; Video mode 320x200x256 colors
    %endif

        int 0x10		; Call BIOS.

        enter total,0		; Make space for internal variables,
        			; and use BP to refer them.

        push 0xa000		; Point to video RAM.
        pop es

	fninit			; Reset coprocessor.
        cld			; Clear direction flag.
	mov si, const_2
restart:
        fld dword [si+const_25-const_2]    ; Initial viewpoint (z)
        fstp dword [bp+var_a]   ; a = 25.0
e0:
        xor di,di		; Pixel pointer.
        mov word [bp+var_n],199 ; Pixel row.
e1:
        mov word [bp+var_m],319 ; Pixel column.
e2:
        fldz                    ; x = 0
        fst dword [bp+var_x]

        fld dword [bp+var_a]    ; z = a
        fst dword [bp+var_z]

        fsubp                   ; y = -a / 25
        fdiv dword [si+const_25-const_2]
        fstp dword [bp+var_y]

        fld1

        fild word [bp+var_m]	; The X-coordinate defines the current sphere.
        fsub dword [si+const_80_5-const_2]
        fldz
        fcomip
        fld1			; One sphere at 1.
        jc e3
        fldz
        fsubrp			; One sphere at -1.
e3:
        fstp dword [bp+var_i]

        fdiv dword [si+const_80_1_3-const_2]
        fst dword [bp+var_u]	; X-direction of ray.
        fmul st0

        fild word [bp+var_n]
        fsub dword [si+const_80_5-const_2]
        fdiv dword [si+const_80_1_3-const_2]
        fst dword [bp+var_v]	; Y-direction of ray.
        fmul st0

        faddp
        fld1
        faddp
        fsqrt

        fdivp			; Normalize.
        fst dword [bp+var_w]	; Z-direction of ray.

        fmul dword [bp+var_u]
        fstp dword [bp+var_u]

        fld dword [bp+var_v]
        fmul dword [bp+var_w]
        fstp dword [bp+var_v]

        ; Line 4 of BASIC.
e4:
        call sphere	; Calculate sphere position.

        fst dword [bp+var_p]

        fmul st0	; Calculate sphere intersection.
        fld dword [bp+var_e]
        fmul st0
        fsubp
        fld dword [bp+var_f]
        fmul st0
        fsubp
        fld dword [bp+var_z]
        fmul st0
        fsubp
        fld1
        faddp
        fst dword [bp+var_d]

        fldz
        fcomip          ; Remove second operand.
        fstp st0        ; Remove the first operand.
        jnc e5		; Jump if no intersection (<= 0)

        ; Line 5 of BASIC.
        fldz
        fld dword [bp+var_d]
        fsqrt
        fadd dword [bp+var_p]
        fsubp
        fst dword [bp+var_t]

        fldz
        fcomip          ; Remove second operand.
        fstp st0        ; Remove first operand.
        jnc e5

        ; Line 6 of BASIC.
        fld dword [bp+var_t]	; Move ray origin to sphere surface.
        fmul dword [bp+var_u]
        fadd dword [bp+var_x]
        fstp dword [bp+var_x]

        fld dword [bp+var_t]
        fmul dword [bp+var_v]
        fadd dword [bp+var_y]
        fstp dword [bp+var_y]

        fld dword [bp+var_t]
        fmul dword [bp+var_w]
        fsubr dword [bp+var_z]
        fstp dword [bp+var_z]

        call sphere

        fmul dword [si]
        fst dword [bp+var_p]

        fmul dword [bp+var_e]	; Update ray direction.
        fsubr dword [bp+var_u]
        fstp dword [bp+var_u]

        fld dword [bp+var_p]
        fmul dword [bp+var_f]
        fsubr dword [bp+var_v]
        fstp dword [bp+var_v]

        fld dword [bp+var_p]
        fmul dword [bp+var_g]
        fadd dword [bp+var_w]
        fstp dword [bp+var_w]

        fldz		; Switch coordinate to hit the other sphere.
        fsub dword [bp+var_i]
        fstp dword [bp+var_i]

        jmp e4		; Bounce ray.

        ; Line 8
e5:
        fld dword [bp+var_v]
        fldz
        fcomip          ; Remove second operand.
        jbe e6
        fstp st0
        fld dword [bp+var_y]
        fadd dword [si]
        fdiv dword [bp+var_v]
        fst dword [bp+var_p]	; Perspective correction.

        fmul dword [bp+var_u]	; Adjust coordinates.
        fsubr dword [bp+var_x]
        frndint
        fld dword [bp+var_w]
        fmul dword [bp+var_p]
        fsubr dword [bp+var_z]
        frndint
        faddp
        fst dword [bp+var_s]

        fdiv dword [si]	; Modulus 2.
        frndint
        fmul dword [si]
        fsubr dword [bp+var_s]

        fdiv dword [si]	; Modulate final result.
        fadd dword [si+const__3-const_2]
        fldz
        fsub dword [bp+var_v]
        fmulp
        fadd dword [si+const_1_4-const_2]  ; Color offset for floor.
e6:
        fsqrt			; Make a curved gradient (like inside of a sphere)
        fmul dword [si+const_25-const_2]	; Spread over 25 pixel values.
        fistp word [bp+pixel]	; Convert to integer.

;        mov ax,199		; Not necessary as DI contains the pixel pointer.
;        sub ax,[bp+var_n]
;        mov bx,320
;        mul bx
;        add ax,[bp+var_m]
;        xchg di,ax
        mov al,$38              ; Color palette
        sub al,[bp+pixel]       ; Subtract pixel value.
        stosb                   ; Put in the screen.

        dec word [bp+var_m]	; Decrease column number.
        jns e2			; Continue if it is still positive.

        dec word [bp+var_n]	; Decrease row number.
        jns e1			; Continue if it is still positive.

        fld dword [bp+var_a]	; Move viewing point.
        fsub dword [si+const___1-const_2]
        fst dword [bp+var_a]
        fadd dword [si]
        fldz
        fcomip			; Reached the limit?
        fstp st0
        jnc restart		; Yes, jump and restart.

        mov ah,0x01		; Keys waiting?
        int 0x16
        je e0			; No, jump.

        mov ax,0x0002		; Back to text mode.
        int 0x10
    %ifdef com_file
        int 0x20		; Exit.
    %else
        int 0x18		; Exit.
    %endif

sphere:
        fld dword [bp+var_x]	; Origin of ray.
        fsub dword [bp+var_i]	; Minus sphere position.
        fst dword [bp+var_e]
        fmul dword [bp+var_u]

        fld dword [bp+var_y]	; Origin of ray.
        fsub dword [bp+var_i]	; Minus sphere position.
        fst dword [bp+var_f]
        fmul dword [bp+var_v]

        faddp

        fld dword [bp+var_z]
        fst dword [bp+var_g]
        fmul dword [bp+var_w]

        fsubp			; Now we have the perspective point.
        ret

	;
	; Constants used by the ray tracer.
	;
const_2:        dd 2.0
const_25:       dd 25.0
const_80_5:     dd 80.5
const___1:      dd 0.01
const_80_1_3:   dd 104.0
const__3:       dd 0.3

const_1_4:      dd 1.4

    %ifdef com_file
    %else
        times 510-($-$$) db 0x4f
        db 0x55,0xaa            ; Make it a bootable sector
    %endif

	;
	; Variables are kept on the stack to make instructions shorter.
	;
var_n:  equ -$42    ; Integer
var_m:  equ -$40    ; Integer
pixel:  equ -$3e    ; Integer
var_u:  equ -$3c    ; u - Ray direction (normalized)
var_v:  equ -$38    ; v - Ray direction (normalized)
var_w:  equ -$34    ; w - Ray direction (normalized)
var_x:  equ -$30    ; x - Origin of ray
var_y:  equ -$2c    ; y - Origin of ray
var_z:  equ -$28    ; z - Origin of ray
var_e:  equ -$24    ; e - Position of sphere
var_f:  equ -$20    ; f - Position of sphere
var_g:  equ -$1c    ; g - Position of sphere
var_p:  equ -$18    ; Float
var_d:  equ -$14    ; Float
var_t:  equ -$10    ; Float
var_i:  equ -$0c    ; Float
var_a:  equ -$08    ; Float
var_s:  equ -$04    ; Float

total:  equ $44

