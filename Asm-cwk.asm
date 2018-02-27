; Coursework
; 1768713 - Philip Rogers
; CMT102 Computational Systems - Dr M Morgan
; 8086 Assembly Language Programming
.386
.model flat,stdcall
.stack 4096
GetStdHandle proto :dword
ReadConsoleA  proto :dword, :dword, :dword, :dword, :dword
WriteConsoleA proto :dword, :dword, :dword, :dword, :dword
ExitProcess proto,dwExitCode:dword

STD_INPUT_HANDLE equ -10
STD_OUTPUT_HANDLE equ -11
 
.data
	;setting up the necessary variables for strings
	bufSize = 80
	inputHandle DWORD ?
	buffer db bufSize dup(?) ; first input
	buffer1 db bufSize dup(?) ; first input with non alpha stripped
	buffed db bufSize dup(?) ; second input
	buffed1 db bufSize dup(?) ; second input with non alpha stripped
	bytes_read  DWORD  ? ; length of buffer
	bytes_read2 DWORD ? ; length of buffer2
	outputHandle DWORD ?
	bytes_written dd ?
	
	;following are strings to display on console
	enter_string db "enter string: ",0
	sum_string db "just read string: ",0
	sum_string2 db "converted to lower case: ",0
	sum_string3 db "removed no-alphabetic characters: ",0
	sum_string4 db "character counts: ",0
	sum_string5 db "strings ARE anagrams",0
	sum_string6 db "strings are NOT anagrams",0

	;setting up default strings for charcter counts
	count1 db "00000000000000000000000000",0
	count2 db "00000000000000000000000000",0

	;setting up a new line command
	newline DWORD ?

.code
main proc

	;completing new line command 0Ah is carrige return and 0Dh is new line
	mov ebx, 0
	mov byte ptr newline+[ebx], 0Dh
	inc ebx
	mov byte ptr newline+[ebx], 0Ah

;part 1 - writing in two strings
	;write in input 1
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outputHandle, eax
	mov eax, LENGTHOF enter_string
	invoke WriteConsoleA, outputHandle, addr enter_string, eax, addr bytes_written, 0
	invoke GetStdHandle, STD_INPUT_HANDLE
	mov inputHandle, eax
	invoke ReadConsoleA, inputHandle, addr buffer, bufSize, addr bytes_read,0

	;output string 1
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outputHandle, eax
	mov eax, LENGTHOF sum_string
	invoke WriteConsoleA, outputHandle, addr sum_string, eax, addr bytes_written, 0
	invoke WriteConsoleA, outputHandle, addr buffer, bytes_read, addr bytes_written, 0

	;write in input 1
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outputHandle, eax
	mov eax, LENGTHOF enter_string
	invoke WriteConsoleA, outputHandle, addr enter_string, eax, addr bytes_written, 0
	invoke GetStdHandle, STD_INPUT_HANDLE
	mov inputHandle, eax
	invoke ReadConsoleA, inputHandle, addr buffed, bufSize, addr bytes_read2,0

	;output string 2
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outputHandle, eax
	mov eax, LENGTHOF sum_string
	invoke WriteConsoleA, outputHandle, addr sum_string, eax, addr bytes_written, 0
	invoke WriteConsoleA, outputHandle, addr buffed, bytes_read2, addr bytes_written, 0

	mov eax,0
	mov eax,bytes_written
	mov ebx,0

;part 2 - converting upper to lower case
;function to take a charcter at a time and if it is a capital letter (ASCII code between 41h and 5Ah) and convert to lower
conChar1:
	mov al, byte ptr buffer+[ebx]
	cmp al, 41h
	jb getNext1
	cmp al, 5Ah
	ja getNext1
	add al, 20h ;ASCII codes for lower case letters are 20h above their capital
	mov byte ptr buffer+[ebx], al
	jmp getNext1

;increase the index to get next charcter
getNext1:
	inc ebx
	cmp ebx, bytes_read
	jz cont1
	jmp conChar1

;print out the new lower case string
cont1:
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outputHandle, eax
	mov eax, LENGTHOF sum_string2
	invoke WriteConsoleA, outputHandle, addr sum_string2, eax, addr bytes_written, 0
	invoke WriteConsoleA, outputHandle, addr buffer, bytes_read, addr bytes_written, 0
	mov ebx, 0


;now converting upper to lower on the second string
;function to take a charcter at a time and if it is a capital letter (ASCII code between 41h and 5Ah) and convert to lower
conChar2:
	mov al, byte ptr buffed+[ebx]
	cmp al, 41h
	jb getNext2
	cmp al, 5Ah
	ja getNext2
	add al, 20h
	mov byte ptr buffed+[ebx], al
	jmp getNext2

;increase index to get next charcter
getNext2:
	inc ebx
	cmp ebx, bytes_read2
	jz cont2
	jmp conChar2

;print out second new lower case string
cont2:
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outputHandle, eax
	mov eax, LENGTHOF sum_string2
	invoke WriteConsoleA, outputHandle, addr sum_string2, eax, addr bytes_written, 0
	invoke WriteConsoleA, outputHandle, addr buffed, bytes_read2, addr bytes_written, 0
	mov ebx,0
	mov ecx,0

;part 3 - removing non-alphabetic characters
;function that takes each charcter and checks whether it is inbetween 61h (a) and 7Ah (z), and if it is, puts it in a new string
nonalpha1:
	mov al, byte ptr buffer+[ebx]
	cmp al, 61h
	jb getNext3
	cmp al, 7Ah
	ja getNext3
	mov byte ptr buffer1+[ecx], al
	inc ecx
	jmp getNext3

;increase index to get next character
getNext3:
	inc ebx
	cmp ebx, bytes_read
	jz cont3
	jmp nonalpha1

;print the new stipped string
cont3:
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outputHandle, eax
	mov eax, LENGTHOF sum_string3
	mov ecx, LENGTHOF buffer1
	mov ebx, LENGTHOF newline
	inc ebx
	invoke WriteConsoleA, outputHandle, addr sum_string3, eax, addr bytes_written, 0
	invoke WriteConsoleA, outputHandle, addr buffer1, ecx, addr bytes_written, 0
	invoke WriteConsoleA, outputHandle, addr newline, ebx, addr bytes_written, 0
	mov ebx, 0
	mov ecx, 0

;stripping non-alphabetics from string 2
;function that takes each charcter and checks whether it is inbetween 61h (a) and 7Ah (z), and if it is, puts it in a new string
nonalpha2:
	mov al, byte ptr buffed+[ebx]
	cmp al, 61h
	jb getNext4
	cmp al, 7Ah
	ja getNext4
	mov byte ptr buffed1+[ecx], al
	inc ecx
	jmp getNext4

;increase index to get next character
getNext4:
	inc ebx
	cmp ebx, bytes_read2
	jz cont4
	jmp nonalpha2

;print out second new stripped string
cont4:
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outputHandle, eax
	mov eax, LENGTHOF sum_string3
	mov ecx, LENGTHOF buffed1
	mov ebx, LENGTHOF newline
	inc ebx
	invoke WriteConsoleA, outputHandle, addr sum_string3, eax, addr bytes_written, 0
	invoke WriteConsoleA, outputHandle, addr buffed1, ecx, addr bytes_written, 0
	invoke WriteConsoleA, outputHandle, addr newline, ebx, addr bytes_written, 0

;part 4 - charcter counts
;set up registers
	mov edx, 0
	mov ebx, 0
	mov ah, 61h ; 61h being a
	mov cl, byte ptr count1+[edx] ;take first character of count1 string - 0

;functions that go through string and compare with a increasing cl each time it finds it, then putting this back into count1
;then goes through each letter of the alphabet, checking through the string each time
counting1:
	mov al, byte ptr buffer1+[ebx]
	cmp al, ah
	jz incr
	jmp getNext5

;for increasing the count of the character
incr:
	inc cl
	jmp getNext5

;increase index to get next character in the string
getNext5:
	inc ebx
	cmp ebx, LENGTHOF buffer1
	jz nextalpha1
	jmp counting1

;put the final character count for a letter back in the count1 string and move onto the next letter
nextalpha1:
	mov byte ptr count1+[edx], cl
	inc ah
	inc edx
	cmp edx, LENGTHOF count1
	jz cont5
	mov ebx, 0
	mov cl, byte ptr count1+[edx]
	jmp counting1

;print out character count1
cont5:
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outputHandle, eax
	mov eax, LENGTHOF sum_string4
	;mov ecx, LENGTHOF count1
	mov ebx, LENGTHOF newline
	inc ebx
	invoke WriteConsoleA, outputHandle, addr sum_string4, eax, addr bytes_written, 0
	invoke WriteConsoleA, outputHandle, addr count1, LENGTHOF count1, addr bytes_written, 0
	invoke WriteConsoleA, outputHandle, addr newline, ebx, addr bytes_written, 0

;character count for string 2
;set up registers
	mov edx, 0
	mov ebx, 0
	mov ah, 61h ; 61h is a
	mov cl, byte ptr count2+[edx] ; take first character of count2 - 0

;functions that go through string and compare with a increasing cl each time it finds it, then putting this back into count2
;then goes through each letter of the alphabet, checking through the string each time
counting2:
	mov al, byte ptr buffed1+[ebx]
	cmp al, ah
	jz incr1
	jmp getNext6

;for increasing the count of the character
incr1:
	inc cl
	jmp getNext6

;increase index to get next character in the string
getNext6:
	inc ebx
	cmp ebx, LENGTHOF buffed1
	jz nextalpha2
	jmp counting2

;put the final character count for a letter back in the count1 string and move onto the next letter
nextalpha2:
	mov byte ptr count2+[edx], cl
	inc ah
	inc edx
	cmp edx, LENGTHOF count2
	jz cont6
	mov ebx, 0
	mov cl, byte ptr count2+[edx]
	jmp counting2

;print out character count2
cont6:
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outputHandle, eax
	mov eax, LENGTHOF sum_string4
	;mov ecx, LENGTHOF count1
	mov ebx, LENGTHOF newline
	inc ebx
	invoke WriteConsoleA, outputHandle, addr sum_string4, eax, addr bytes_written, 0
	invoke WriteConsoleA, outputHandle, addr count2, LENGTHOF count2, addr bytes_written, 0
	invoke WriteConsoleA, outputHandle, addr newline, ebx, addr bytes_written, 0
	mov ebx,0

;part 5 - anagram?
;function that goes through and compares each character of count1 and count2 at the same index
anagrams:
	mov al, byte ptr count1+[ebx]
	mov ah, byte ptr count2+[ebx]
	cmp al, ah
	jz getNext7
	jmp notsame

;increase index
getNext7:
	inc ebx
	cmp ebx, LENGTHOF count1
	jz same
	jmp anagrams

;print out statement for if the counts are the same
same:
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outputHandle, eax
	mov eax, LENGTHOF sum_string5
	invoke WriteConsoleA, outputHandle, addr sum_string5, eax, addr bytes_written, 0
	invoke ExitProcess,0

;print out statement if they are not the same
notsame:
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov outputHandle, eax
	mov eax, LENGTHOF sum_string6
	invoke WriteConsoleA, outputHandle, addr sum_string6, eax, addr bytes_written, 0
	invoke ExitProcess,0
main endp
end main