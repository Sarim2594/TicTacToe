.data
    art BYTE "           _____ _     _____         _____          ", 0          
        BYTE "          |_   _(_) __|_   _|_ _  __|_   _|__   ___ ", 0 
        BYTE "            | | | |/ __|| |/ _` |/ __|| |/ _ \ / _ \", 0
        BYTE "            | | | | (__ | | (_| | (__ | | (_) |  __/", 0
        BYTE "            |_| |_|\___||_|\__,_|\___||_|\___/ \___|", 0
.code
asciiArt PROC
mov ecx, 5
mov esi, OFFSET art
mov edx, esi
call WriteString
l1:
inc esi
cmp byte ptr [esi], 0
jne l1
inc esi
call crlf 
mov edx, esi
call WriteString
loop l1
ret
asciiArt ENDP