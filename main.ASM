;***********************************************************
; 版权所有 (C)2018, WangMeow
;
; 文件名称： main.asm
; 内容摘要：该代码为主程序，用于调用其他功能子程序
; 当前版本： V1.0
; 作   者： WangMeow
; 完成日期： 20180701
;**********************************************************
extrn s1:far,clean:far  ;主程序可调用的外部子程序有显示时间子程序和清屏子程序
assume cs:code,ss:stack,ds:data

stack segment stack
	db 100h dup(0)
stack ends

data segment
	 menu db 10,13,10,13,'      ----------WangMeow.Clock_System----------'
	      db 10,13
	      db 10,13,'          --------------Menu---------------          '
	      db 10,13,'                    1.Show time.'
	      db 10,13,'                    2.Set alarm clock.'
	      db 10,13,'                    0.exit.'
	      db 10,13,'          ---------------------------------          '
	      db 10,13,'          Please choose one of 0~2:','$'
	table dw pro1,pro2

	 tip1 db 10,13,'          Input error!','$'
	 tip2 db 10,13,'          Please set the hour:','$'
	 tip3 db 10,13,'          Please set the minute:','$'
	 
	 hour dw 64h
	 minute dw 64h

data ends


code segment
main proc

aton macro     ;宏定义:将ASCII转换成数字
	sub al,30h
endm

ntoad macro    ;宏定义:将数字转换成各子程序的偏移地址
	shl al,1
	mov bl,al
	mov bh,0
	sub bx,2
endm

outscr macro x		   ;宏定义:输出字符串到屏幕
	lea dx,x           ;ds:dx = 输出字符串的首地址
	mov ah,9           ;调用21h中断的9号功能,输出字符串
	int 21h
endm

inputb macro
mov ah,0ch    ;调用21h中断的c号功能，从键盘读入字符，al保存读入字符的ASCII码
 mov al,01h
int 21h
endm

start:   
    run:
		 mov ax,data   ;设置数据段
		 mov ds,ax

		 outscr menu   ;宏调用     
      	 
		 inputb        ;宏调用

      	 aton          ;宏调用 
      	 cmp al,1      ;输入输入的不在[1,2]这个区间，那么去处理
      	 jb deal
      	 cmp al,2
      	 ja deal

      	 ntoad         ;宏调用

      	 call far ptr clean        ;调用清屏子程序
      	 mov si,00h                ;这里si的作用相当于flag
      	 call word ptr table[bx]   ;使用代码的直接定址表调用子程序

		 jmp run                   ;主程序持续运行


    deal:;用来处理非正常输入
    	 cmp al,0      ;如果是输入是0,程序正常退出
    	 je exit

    	 outscr tip1    ;如果是非正常输入,输出错误提示
    	 
    	 jmp run
    	 
    exit:;程序正常退出
    	 mov ax,4c00h
    	 int 21h

main endp
;*****************************************************************
; 子程序：pro1
; 功能：负责远间调用S1子程序，负责显示时间和时间对比
; 入口参数：无
; 出口参数：无
;*****************************************************************
pro1 proc near         ;PRO1子程序，显示时钟
	 call far ptr s1   ;调用S1子程序
	 ret
pro1 endp

;*****************************************************************
; 子程序：pro2
; 功能：负责设置闹钟，实现小时和分钟的输入
; 入口参数：无
; 出口参数：0：[0200]存放小时的低位，0：[0201]存放小时的高位
; 0：[0202]存放分钟的低位，0：[0203]存放分钟的高位
;调用注意事项：近调用，ret返回
;*****************************************************************
pro2 proc near         ;调用PRO2子程序，用来输入要设置的时间
	  mov ax,0h        ;将输入的时间保存到0:0200h这个物理地址里面
      mov es,ax
      mov bx,0200h
	  
	  outscr tip2      ;宏调用
	  mov cx,2         ;循环两次输入字符
	  mov si,1

  l1: inputb                   ;宏调用,输入小时
      mov es:[bx+si],al        ;将输入的小时的高位存到0201h里面，低位存到0200h里面
      dec si
      loop l1
      
      add bx,2                 ;偏移地址+2
      outscr tip3              ;宏调用
      mov cx,2		           ;循环两次输入字符
      mov si,1

  l2: inputb                   ;宏调用,输入分钟
      mov es:[bx+si],al        ;将输入的分钟的高位保存到0203h里面，低位保存到0202h里面
      dec si 
      loop l2
      ret

pro2 endp

code ends
end start