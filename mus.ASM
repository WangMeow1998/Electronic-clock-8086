;***********************************************************
; 版权所有 (C)2018, Wang Miao
;
; 文件名称： mus.asm
; 内容摘要：该代码为子程序，用于音乐响铃
; 当前版本： V1.0
; 作   者： 汪淼
; 完成日期： 20180701
;**********************************************************
public music  ;音乐子程序
.8086
.MODEL small
.stack 100h

.data
mus_freq dw 524,524,784,784,880,880,784   ;闹钟的音乐，这里的音乐是一闪一闪亮晶晶
         dw 698,698,659,659,587,587,524
         dw 784,784,698,698,659,659,587
         dw 784,784,698,698,659,659,587
         dw 524,524,784,784,880,880,784
         dw 698,698,659,659,587,587,524
         dw -1

mus_time dw 3 dup(25,25),25                ;音乐节奏（音长）
         dw 3 dup(25,25),25
         dw 3 dup(25,25),25
         dw 3 dup(25,25),25
         dw 3 dup(25,25),25
         dw 3 dup(25,25),25
         dw 3 dup(25,25),25
         dw 3 dup(25,25),25
         dw 3 dup(25,25),25
         dw 3 dup(25,25),25
         dw 3 dup(25,25),25
         dw 3 dup(25,25),25

.code
music proc
start:

    mov ax, @data
    mov ds, ax

    lea si, mus_freq
    lea di, mus_time

play:
    mov dx, [si]
    cmp dx, -1       ;如果是最后一个音符，那么结束演奏
    je end_play                     
    call sound       ;否则,调用演奏子程序
    add si, 2
    add di, 2
    jmp play

;*****************************************************************
; 子程序：sound
; 功能：负责演奏一个音符
; 入口参数：si - 要演奏的音符的频率的地址 di - 要演奏的音符的音长的地址
; 出口参数：无
;*****************************************************************
sound:
    push ax
    push dx
    push cx

    ;8253 芯片(定时/计数器)的设置
    mov al,0b6h       ;8253初始化
    out 43h,al        ;43H是8253芯片控制口的端口地址
    mov dx,12h
    mov ax,34dch
    div word ptr [si] ;计算分频值,赋给ax。[si]中存放声音的频率值。
    out 42h, al       ;先送低8位到计数器，42h是8253芯片定时器通道2的端口地址
    mov al, ah
    out 42h, al       ;后送高8位计数器

    ;设置8255芯片, 控制扬声器的开/关
    in al,61h   ;读取8255 B端口原值      PB口的最低两位：PB0：控制8253定时器，PB1：控制喇叭发声
    mov ah,al   ;保存原值
    or al,3     ;使低两位置1，以便打开开关
    out 61h,al  ;开扬声器, 发声

    mov dx, [di]       ;保持[di]时长
wait1:
    mov cx, 28560      ;1s = 1428次循环,这里设置一首音乐20s
delay:
    nop
    loop delay
    dec dx
    jnz wait1

    mov al, ah         ;取回8255的PB口原值
    out 61h, al        ;回复8255PB口，停止发声

    pop cx
    pop dx
    pop ax
    ret

end_play:
    retf

music endp

end start
