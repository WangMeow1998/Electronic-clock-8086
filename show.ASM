;***********************************************************
; 版权所有 (C)2018, Wang Miao
;
; 文件名称： show.asm
; 内容摘要：该代码为子程序，用于动态时间显示以及时间对比
; 当前版本： V1.0
; 作   者： 汪淼
; 完成日期： 20180701
;**********************************************************
public s1    ;显示时间子程序
extrn clean:far,music:far   ;显示时间子程序可调用的外部子程序有清屏子程序和音乐子程序

assume cs:code
code segment
s1 proc

show macro x,col    ;宏定义,使用70h和71h端口获取系统时间
      mov al,x
      out 70h,al
      in al,71h
      
      mov ah,al     ;13---18行代码是把系统时间的高位保存到ah，低位保存到al
      mov cl,4
      shr ah,cl
      and al,00001111b
      add ah,30h
      add al,30h
      mov bx,0b800h
      mov es,bx

      mov byte ptr es:[160*12+col*2],ah ;两个字节代表屏幕的一列,将代表时间的字符放入屏幕显示缓冲区
      mov byte ptr es:[160*12+col*2+2],al
endm

sym macro
	mov byte ptr es:[160*12+32*2],'/'   ;美化时间显示
	mov byte ptr es:[160*12+35*2],'/'
	mov byte ptr es:[160*12+38*2],' '
	mov byte ptr es:[160*12+41*2],':'
	mov byte ptr es:[160*12+44*2],':'
endm

start:
	call disptime
	mov ah,01h          ;检查是否有键盘输入
	int 16h

	jz start            ;表示位ZF = 1时，无键盘输入，继续显示时间
	mov ah,00h          ;如果有键盘输入
	int 16h

	cmp al,27           ;ESC的ASCII是27(10进制)
	jnz start           ;如果按住的键盘不是ESC,继续显示时间
	call far ptr clean  ;如果是ESC,那么返回主程序
	retf


;*****************************************************************
; 子程序：disptime
; 功能：负责动态显示时间
; 入口参数：日期在70h端口处的地址
; 出口参数：无
;*****************************************************************
disptime proc near
		 show 9,30         ;年
         show 8,33         ;月
         show 7,36         ;日
         show 4,39         ;小时
         call judge1       ;判断设置的小时与当前显示的是否一致
         show 2,42         ;分钟
         call judge2	   ;判断设置的分钟与当前显示的是否一致
         show 0,45         ;秒
         sym               ;符号

         cmp si,01h        ;如果flag = 1,说明闹钟与显示时间一直，响铃
         je alarm
         ret

  alarm: call far ptr music  
  		 ret
disptime endp

;*****************************************************************
; 子程序：judge1
; 功能：负责判断设置的小时是否与显示的小时一直
; 入口参数：0：[0200]存放的小时的低位，0：[0201]存放的小时的高位
; 出口参数：无
;*****************************************************************
judge1 proc near          ;判断小时的子程序
		mov dx,0h
	  	mov es,dx
	  	mov bp,0200h

	  	mov ch,es:[bp]
	  	cmp ch,al         ;al是小时的低位
	  	jne nset

	  	inc bp
	  	mov ch,es:[bp]
	  	cmp ch,ah         ;ah是小时的高位
	  	jne nset

	  	jmp set
judge1 endp

;*****************************************************************
; 子程序：judge2
; 功能：负责判断设置的分钟是否与显示的分钟一直
; 入口参数：0：[0202]存放的分钟的低位，0：[0203]存放的分钟的高位
; 出口参数：无
;*****************************************************************
judge2 proc near         ;判断分钟的子程序
		mov dx,0h
	  	mov es,dx
	  	mov bp,0202h

	  	mov ch,es:[bp]
	  	cmp ch,al
	  	jne nset

	  	inc bp
	  	mov ch,es:[bp]
	  	cmp ch,ah
	  	jne nset

	  	jmp set
judge2 endp

return: ret

set:  mov si,01h
      jmp return
nset:
 	  mov si,00h
 	  jmp return

s1 endp

code ends
end start