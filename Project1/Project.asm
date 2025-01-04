INCLUDE Irvine32.inc
INCLUDE Ascii.inc
cpp_clrscr PROTO C
updateFile PROTO C
detectKeyPress PROTO C
.data
    space BYTE " ", 0 
    pvpMsg BYTE "2: Multi Player", 0
    pvcMsg BYTE "1: Single Player", 0
    scoreMsg BYTE "3: Scoreboard", 0
    exitMsg BYTE "4: Quit game", 0
    selectMsg BYTE "Select your gamemode: ", 0
    selectTurn BYTE "Select your player: ", 0
    letX BYTE "1: Player 1", 0
    letO BYTE "2: Player 2", 0
    playerChoice DWORD 0
    board BYTE "1", "2", "3", "4", "5", "6", "7", "8", "9", 0
    separator BYTE "-|-|-", 0
    player1Msg BYTE "Player 1, enter your move: ", 0
    player2Msg BYTE "Player 2, enter your move: ", 0
    invalid1MSG BYTE "Invalid selection, choose between 1-3: ", 0
    invalid2MSG BYTE "Invalid selection, choose between 1 and 2: ", 0
    invalidMoveMsg BYTE "Invalid move, try again: ", 0
    gameOverMsg BYTE "Game over", 0
    winner1Msg BYTE "Player 1 wins! Do you want to play again?", 0
    winner2Msg BYTE "Player 2 wins! Do you want to play again?", 0
    tieMsg BYTE "It's a tie! Do you want to play again?", 0
    currentPlayer BYTE 'X'
    computer BYTE 0
    minValue DWORD 1
    maxValue DWORD 9
    returnMsg BYTE "Press any key to return to main menu", 0
    filename BYTE "PlayerScore.txt", 0
.code
main PROC C
call gameStart
mov eax, 0
gameLoop:
    call displayBoard
    cmp currentPlayer, 'X'
    je player1Turn
    jne player2Turn
player1Turn:
    mov edx, OFFSET player1Msg
    call WriteString
    push eax
    call getMove
    pop eax
    call checkWinner
    cmp eax, 0
    jg gameOver
    mov currentPlayer, 'O'
    jmp checkEnd
player2Turn:
    mov edx, OFFSET player2Msg
    call WriteString
    push eax
    call getMove
    pop eax
    call checkWinner
    cmp eax, 0
    jg gameOver
    mov currentPlayer, 'X'
checkEnd:
    call checkTie
    cmp eax, 0
    jg gameOver
    jmp gameLoop
gameOver:
    mov ebx, OFFSET gameOverMsg
    call displayBoard
    cmp eax, 2
    jl player1Won
    je player2Won
    jg tie
tie:
    movzx edx, computer
    push edx
    push eax
    call updateFile
    add esp, 8
    mov edx, OFFSET tieMsg
    call MsgBoxAsk
    cmp eax, 6
    je reinitialize
    exit
player1Won:
    movzx edx, computer
    push edx
    push eax
    call updateFile
    add esp, 8
    mov edx, OFFSET winner1Msg
    call MsgBoxAsk
    cmp eax, 6
    je reinitialize
     exit
player2Won:
    movzx edx, computer
    push edx
    push eax
    call updateFile
    add esp, 8
    mov edx, OFFSET winner2Msg
    call MsgBoxAsk
    cmp eax, 6
    je reinitialize
    exit
reinitialize:
    call cpp_clrscr
    mov byte ptr board[0], '1'
    mov byte ptr board[1], '2'
    mov byte ptr board[2], '3'
    mov byte ptr board[3], '4'
    mov byte ptr board[4], '5'
    mov byte ptr board[5], '6'
    mov byte ptr board[6], '7'
    mov byte ptr board[7], '8'
    mov byte ptr board[8], '9'
    mov byte ptr board[9], 0
    mov currentPlayer, 'X'
    jmp main
main ENDP

gameStart PROC C
call asciiArt
mov dh, 6
mov dl, 24
call gotoXY
mov edx, OFFSET pvcMsg
call WriteString
mov dh, 7
mov dl, 24
call gotoXY
mov edx, OFFSET pvpMsg
call WriteString
mov dh, 8
mov dl, 24
call gotoXY
mov edx, OFFSET scoreMsg
call WriteString
mov dh, 9
mov dl, 24
call gotoXY
mov edx, OFFSET exitMsg
call WriteString
mov dh, 10
mov dl, 0
call gotoXY
mov edx, OFFSET selectMsg
call WriteString
recall:
call ReadInt
cmp eax, 1
je setComputer
cmp eax, 2
je return
cmp eax, 3
je scores
cmp eax, 4
je exitGame
jmp invalid1
setComputer:
    call cpp_clrscr
    call asciiArt
    mov dh, 6
    mov dl, 26
    call gotoXY
    mov edx, OFFSET letX
    call WriteString
    mov dh, 7
    mov dl, 26
    call gotoXY
    mov edx, OFFSET letO
    call WriteString
    mov dh, 8
    mov dl, 0
    call gotoXY
    mov edx, OFFSET selectTurn
    call WriteString
    recall2:
    call ReadInt
    mov playerChoice, eax
    cmp eax, 1
    je comp2
    cmp eax, 2
    je comp1
    jmp invalid2
    comp1:
    mov computer, 1
    jmp return
    comp2:
    mov computer, 2
return:
    call cpp_clrscr
    ret
exitGame:
    exit
scores:
    call cpp_clrscr
    call displayScoreBoard
    call crlf
    call crlf
    mov edx, OFFSET returnMsg
    call writestring
    call detectKeyPress
    call cpp_clrscr
    jmp gameStart
invalid1:
    mov edx, OFFSET invalid1Msg
    call WriteString
    jmp recall
invalid2:
    mov edx, OFFSET invalid2Msg
    call WriteString
    jmp recall2
gameStart ENDP

displayScoreBoard PROC
    LOCAL bytesRead: DWORD
    sub esp, 1024
    mov edx, OFFSET filename
    call OpenInputFile
    mov ebx, eax
    mov ecx, 1024
    mov edx, esp
    call ReadFromFile
    mov bytesRead, eax
    cmp eax, 0
    je close_file
    mov edx, esp
    call WriteString
close_file:
    mov eax, ebx
    call CloseFile
    add esp, 1024
    ret
displayScoreBoard ENDP

displayBoard PROC C USES eax
    call cpp_clrscr
    call asciiArt
    mov ecx, 9
    mov esi, OFFSET board
    call Crlf
printBoard:
    mov al, [esi]
    cmp al, 'X'
    je colorRed
    cmp al, 'O'
    je colorBlue
back:
    call WriteChar
    mov eax, white+(black*16)
    call SetTextColor
    inc esi
	cmp ecx, 7
	je separate
	cmp ecx, 4
	je separate
    cmp ecx, 1
    je return
    mov al, '|'
    call WriteChar
loop printBoard
return:
    call Crlf
    ret
separate:
    call Crlf
	mov edx, OFFSET separator
    call WriteString
    dec ecx
    call Crlf
	jmp printBoard
colorRed:
    mov eax, red+(black*16)
    call SetTextColor
    jmp back
colorBlue:
    mov eax, blue+(black*16)
    call SetTextColor
    jmp back
displayBoard ENDP

getMove PROC
    cmp computer, 0
    jg compMove
playerMove:
    call ReadInt
    cmp eax, 1
    jl invalidMove
    cmp eax, 9
    jg invalidMove
    mov esi, OFFSET board
    dec eax
    add esi, eax
    cmp BYTE PTR [esi], "X"
    je invalidMove
    cmp BYTE PTR [esi], "O"
    je invalidMove
    mov al, currentPlayer
    mov BYTE PTR [esi], al
    ret
invalidMove:
    mov edx, OFFSET invalidMoveMsg
    call WriteString
    jmp getMove
compMove:
    cmp playerChoice, 1
    je checkX
    jne checkO
    checkX:
    cmp currentPlayer, "X"
    je playerMove
    jmp rng
    checkO:
    cmp currentPlayer, "O"
    je playerMove
    rng:
        call Randomize
        mov eax, maxValue
        sub eax, minValue
        inc eax
        call RandomRange
        mov esi, OFFSET board
        add esi, eax
        cmp BYTE PTR [esi], "X"
        je rng
        cmp BYTE PTR [esi], "O"
        je rng
        mov al, currentPlayer
        mov BYTE PTR [esi], al
    return:
    ret
getMove ENDP

checkWinner PROC
push eax
mov ecx, 3
mov esi, OFFSET board
rowCheck:
    mov al, [esi]
    cmp al, [esi+1]
    jne nextRow
    cmp al, [esi+2]
    je setWinner
nextRow:
    add esi, 3
loop rowCheck
mov ecx, 3
mov esi, OFFSET board
colCheck:
    mov al, [esi]
    cmp al, [esi+3]
    jne nextCol
    cmp al, [esi+6]
    je setWinner
nextCol:
    inc esi
loop colCheck
diagonal1:
    mov esi, OFFSET board
    mov al, [esi]
    cmp al, [esi+4]
    jne diagonal2
    cmp al, [esi+8]
    je setWinner
    jne diagonal2
diagonal2:
    mov esi, OFFSET board
    mov al, [esi+2]
    cmp al, [esi+4]
    jne return
    cmp al, [esi+6]
    je setWinner
    jne return
return:
    pop eax
    ret
setWinner:
    pop eax
    cmp currentPlayer, 'X'
    je player1
    jne player2
player1:
    mov eax, 1
    ret
player2:
    mov eax, 2
    ret
checkWinner ENDP

checkTie PROC
    mov esi, OFFSET board
    mov ecx, 9
checkLoop:
    cmp BYTE PTR [esi], 'X'
    je nextCheck
    cmp BYTE PTR [esi], 'O'
    je nextCheck
    ret
nextCheck:
    inc esi
    loop checkLoop
mov eax, 3
ret
checkTie ENDP
END