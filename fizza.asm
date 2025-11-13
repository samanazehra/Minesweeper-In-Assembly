INCLUDE Irvine32.inc

.data
Title BYTE "-*-*- Minesweeper Game -*-*-",0
Rules1 BYTE "Rules:",0
Rules2 BYTE "~ Click squares to reveal safe spots, avoid mines or the game ends.",0
Rules3 BYTE "~ Numbers show how many mines are nearby, flag suspected mines to help.",0
PromptStart BYTE "Enter 0 to start: ",0
PromptN BYTE "Enter grid size N (1-10): ",0
MsgInvalid BYTE "Invalid input. Enter 1 to 10.",0
MsgMines BYTE "Number of mines: ",0
Rows DWORD ?
Cols DWORD ?
numMines DWORD ?
MAX_ROWS = 10
MAX_COLS = 10
MINE = 9
HiddenBoard BYTE MAX_ROWS*MAX_COLS DUP(0)
PlayerView BYTE MAX_ROWS*MAX_COLS DUP('#')
newline BYTE 13,10,0

.code
main PROC
call StartScreens
call ReadGridSize
call InitBoard
call PlaceMines
call ComputeAdjacency
call Screen3Show
exit
main ENDP

StartScreens PROC
call ClrScr
mov edx,OFFSET Title
call WriteString
mov edx,OFFSET newline
call WriteString
mov edx,OFFSET Rules1
call WriteString
mov edx,OFFSET newline
call WriteString
mov edx,OFFSET Rules2
call WriteString
mov edx,OFFSET newline
call WriteString
mov edx,OFFSET Rules3
call WriteString
mov edx,OFFSET newline
call WriteString
mov eax,3000
call Delay
mov edx,OFFSET PromptStart
call WriteString
call ReadDec
cmp eax,0
jne StartScreens
call ClrScr
ret
StartScreens ENDP

ReadGridSize PROC
call ClrScr
mov edx,OFFSET PromptN
call WriteString
call ReadDec
cmp eax,1
jl ReadGridSizeInvalid
cmp eax,MAX_ROWS
jg ReadGridSizeInvalid
mov Rows,eax
mov Cols,eax
ret
ReadGridSizeInvalid:
mov edx,OFFSET MsgInvalid
call WriteString
call ReadDec
jmp ReadGridSize
ReadGridSize ENDP

InitBoard PROC
mov ecx,MAX_ROWS*MAX_COLS
mov edi,OFFSET HiddenBoard
mov al,0
rep stosb
mov ecx,MAX_ROWS*MAX_COLS
mov edi,OFFSET PlayerView
mov al,'#'
rep stosb
ret
InitBoard ENDP

PlaceMines PROC
call Randomize
mov eax,Rows
imul eax,eax
mov ebx,eax
mov ecx,6
cdq
idiv ecx
mov numMines,eax
cmp eax,1
jne SkipEnsureOne
mov numMines,1
SkipEnsureOne:
mov esi,0
mov edi,numMines
PlaceLoop:
cmp esi,edi
jge DonePlace
mov eax,Rows
call RandomRange
mov ebx,eax
mov eax,Cols
call RandomRange
mov ecx,eax
mov eax,ebx
imul eax,Cols
add eax,ecx
mov ebx,eax
mov edx,OFFSET HiddenBoard
add edx,ebx
cmp BYTE PTR [edx],MINE
je PlaceLoop
mov BYTE PTR [edx],MINE
inc esi
jmp PlaceLoop
DonePlace:
ret
PlaceMines ENDP

ComputeAdjacency PROC
mov eax,0
OuterRow:
cmp eax,Rows
jge EndCompute
push eax
mov ebx,0
InnerCol:
cmp ebx,Cols
jge EndInner
push ebx
mov ecx,eax
imul ecx,Cols
add ecx,ebx
mov esi,OFFSET HiddenBoard
add esi,ecx
cmp BYTE PTR [esi],MINE
je SkipCell
push ecx
push eax
push ebx
call CountAdjacentMines
pop ebx
pop eax
pop ecx
mov edx,OFFSET HiddenBoard
add edx,ecx
mov BYTE PTR [edx],al
SkipCell:
pop ebx
inc ebx
jmp InnerCol
EndInner:
pop eax
inc eax
jmp OuterRow
EndCompute:
ret
ComputeAdjacency ENDP

CountAdjacentMines PROC
push ebp
mov ebp,esp
mov al,0
mov ecx,-1
AdjRowLoop:
cmp ecx,1
jg AdjDone
mov ebx,-1
AdjColLoop:
cmp ebx,1
jg NextAdjRow
mov edx,[ebp+8]
mov esi,edx
add esi,ecx
cmp esi,0
jl SkipAdj
cmp esi,Rows
jge SkipAdj
mov edx,[ebp+12]
mov edi,edx
add edi,ebx
cmp edi,0
jl SkipAdj2
cmp edi,Cols
jge SkipAdj2
mov eax,edx
mov edx,esi
imul eax,Cols
add eax,edi
mov ebx,OFFSET HiddenBoard
add ebx,eax
cmp BYTE PTR [ebx],MINE
jne SkipAdj2
inc al
SkipAdj2:
SkipAdj:
inc ebx
jmp AdjColLoop
NextAdjRow:
inc ecx
jmp AdjRowLoop
AdjDone:
mov esp,ebp
pop ebp
ret
CountAdjacentMines ENDP

Screen3Show PROC
call ClrScr
mov edx,OFFSET MsgMines
call WriteString
mov eax,numMines
call WriteDec
mov edx,OFFSET newline
call WriteString
mov eax,2000
call Delay
call ClrScr
call PrintPlayerView
ret
Screen3Show ENDP

PrintPlayerView PROC
mov eax,0
RowLoop2:
cmp eax,Rows
jge DonePrint
push eax
mov ebx,0
ColLoop2:
cmp ebx,Cols
jge EndCol2
push ebx
mov ecx,eax
imul ecx,Cols
add ecx,ebx
mov edx,OFFSET PlayerView
add edx,ecx
mov al,[edx]
call WriteChar
mov al,' '
call WriteChar
pop ebx
inc ebx
jmp ColLoop2
EndCol2:
pop eax
mov edx,OFFSET newline
call WriteString
inc eax
jmp RowLoop2
DonePrint:
ret
PrintPlayerView ENDP

END main
