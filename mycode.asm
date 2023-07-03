.model small
.stack 64
.data    
    window_w dw 140h ;width of the w
    window_h dw 0c8h ;height of the w
    window_bound dw 3h ;setting boundary for our screen in order to have better collisions
    
    sys_time DB 0 ;our system time for checking the time diff 
    
    Ball_X DW 023H ;top left horizontal coordinate of the ball
    BAll_Y DW 12H ;top left vertical coordinate of the ball
    Ball_size DW 06H ;the width and height of the ball(which is technically a square). 
    
  
    ball_v_y dw 00h ;speed of the ball in y direction
    ball_v dw 18h ;speed of ball each time the user changes its position in X direction.

    ; here are the coorinates of the poison( hashare sammi ).
    poison_x dw 25h
    poison_y dw 60h
    poison_size dw 09h
    poision_flag dw 01h
    poison_v dw 04h
    poison_bound dw 20h

    rocket_x dw 020h ;top left horizontal coordinate of the rocket
    rocket_y dw 64h ;top left vertical coordinate of the rocket
    rocket_w dw 27h ;width of the rocket
    rocket_h dw 06h ;height of the rocket

    border_H_X DW 08h ; starting X position of the horizontal border
    border_H_Y_up dw 08h ; starting Y position of the horizontal border_up
    border_H_Y_down dw 0bdh ; starting Y position of the horizontal border_down
    border_H_W dw 130h; width of the horizontal border
    border_H_H dw 03h ; height of the horizontal border

    border_v_Y DW 08h ; starting Y position of the horizontal border
    border_v_X_left dw 08h ; starting X position of the vertical border_left
    border_v_X_right dw 135h ; starting position of the vertical border_right
    border_v_W dw 03h; width of the horizontal border
    border_v_H dw 0B5h ; height of the horizontal border
    
    ; random numbers for the positon of the rocket
    ; ,each time it appears again on the screen:
    randomnumx dw 0h 
    randomnumy dw 0h

    game_over_message db "it's over rely!","$"
    first_digit db 0h
    sec_digit db 0h
    third_digit db 0h
    
    
.code
    main proc far  
         
        MOV AX, @data
        mov DS, AX
                
        call cls ; clear thee screen for the start of program
    
        call draw_borders
        
    ; main loop of the program which updates the screen if time has changed  
    check_time: 
       
        mov ah, 2ch ; get the system time 
        int 21h
        
        cmp dl, sys_time ;checking if time has changed 
        je check_time 
        
        mov sys_time, dl ;updating the system time...
     
        call randNumberGenerator ; create new random numbers for the position of the rocket
   
        call delete_ball 

        call move_ball ; moving the ball in y direction(no user involved here).
       
        call moveBall_user ; moving the ball in x direction(user involved here). 

        call makePoison
        
        call makeball ;drawing the ball in its new position
         
        call makerocket ;drawing the rocket in its new position.

        call show_score ;showing the score of the user
        
        jmp check_time
        
      RET
    main endp
; ------------------------------------------------------ Making Poison Here --------------------------------------------------------
    makePoison proc far
        mov al, sec_digit
        cmp al, 1
        jl not_make

        mov Cx, poison_x
        mov Dx, poison_y
       

        horizon_2:
        Mov Ah,0Ch
        Mov Al,04h
        Mov Bh,00h       
        int 10h  
        Inc Cx
        Mov Ax,Cx
        sub Ax,poison_x
        cmp Ax,poison_size
        Jng horizon_2 
            vertical_2:
            mov cx, poison_x
            inc dx  
             
            Mov Ax,dx
            sub Ax,poison_y
            cmp Ax,poison_size
            Jng horizon_2 
        not_make:
        ret
    makePoison endp 
; --------------------------------------------------------- Drawing borders ------------------------------------------------------
    draw_borders proc far
        call draw_horizontal_up

        call draw_horizontal_down

        call draw_vertical_right

        call draw_vertical_left

        ret
    draw_borders endp

    draw_horizontal_up proc far
        Mov Cx,border_H_X
        Mov Dx,border_H_Y_up 
        
        horizon:
        Mov Ah,0Ch
        Mov Al,07h
        Mov Bh,00h       
        int 10h  
        Inc Cx
        Mov Ax,Cx
        sub Ax,border_H_X
        cmp Ax,border_H_W
        Jng horizon 
            vertical:
            mov cx, border_H_X
            inc dx  
             
            Mov Ax,dx
            sub Ax,border_H_Y_up
            cmp Ax,border_H_H
            Jng horizon 
        ret
    draw_horizontal_up endp

    draw_horizontal_down proc far
        Mov Cx,border_H_X
        Mov Dx,border_H_Y_down 
        
        horizon:
        Mov Ah,0Ch
        Mov Al,07h
        Mov Bh,00h       
        int 10h  
        Inc Cx
        Mov Ax,Cx
        sub Ax,border_H_X
        cmp Ax,border_H_W
        Jng horizon 
            vertical:
            mov cx, border_H_X
            inc dx  
             
            Mov Ax,dx
            sub Ax,border_H_Y_down
            cmp Ax,border_H_H
            Jng horizon 
        ret
    draw_horizontal_down endp

    draw_vertical_right proc far
        Mov Cx,border_v_X_right
        Mov Dx,border_v_Y 
        
        horizon:
        Mov Ah,0Ch
        Mov Al,07h
        Mov Bh,00h       
        int 10h  
        Inc Cx
        Mov Ax,Cx
        sub Ax,border_v_X_right
        cmp Ax,border_v_W
        Jng horizon 
            vertical:
            mov cx, border_v_X_right
            inc dx  
             
            Mov Ax,dx
            sub Ax,border_v_Y
            cmp Ax,border_v_H
            Jng horizon 
        ret
    draw_vertical_right endp

   draw_vertical_left proc far
        Mov Cx,border_v_X_left
        Mov Dx,border_v_Y 
        
        horizon:
        Mov Ah,0Ch
        Mov Al,07h
        Mov Bh,00h       
        int 10h  
        Inc Cx
        Mov Ax,Cx
        sub Ax,border_v_X_left
        cmp Ax,border_v_W
        Jng horizon 
            vertical:
            mov cx, border_v_X_left
            inc dx  
             
            Mov Ax,dx
            sub Ax,border_v_Y
            cmp Ax,border_v_H
            Jng horizon 
        ret
    draw_vertical_left endp

; ---------------------------------------------- showing the score of the user ---------------------------------------------------
    show_score proc far
        mov ah, 02h
        mov dl, 18
        mov dh, 3
        mov bh, 0
        int 10h

        mov ah, 02h
        mov al, third_digit
        add al, 48
        mov dl, al
        int 21h

        mov ah, 02h
        mov dl, 19
        mov dh, 3
        mov bh, 0
        int 10h

        mov ah, 02h
        mov al, sec_digit
        add al, 48
        mov dl, al
        int 21h

        mov ah, 02h
        mov dl, 20
        mov dh, 3
        mov bh, 0
        int 10h

        mov ah, 02h
        mov al, first_digit
        add al, 48
        mov dl, al
        int 21h
        ret
    show_score endp  
; ---------------------------------------------------- creating random number ---------------------------------------------------------------    
     randNumberGenerator proc far
        mov ah, 0h
        int 1ah
        
        mov ax, dx
        mov dx, 0
        mov bx, 7
        div bx
        
        inc dl
        mov al,dl 
        mov cl, 39
        mul cl
         

        other_conditions:
        cmp ax, 79
        jl adder_x 

        cmp ax, 272
        jg subber_x
        
        jmp create_random_x
        
        adder_x:
        add ax, 40
        jmp create_random_x

        subber_x:
        sub ax, 40
        
        
        create_random_x:
         cmp ax, rocket_X
         je not_change


        mov randomnumx, ax
        
        
        mov ah, 0h
        int 1ah
        
        mov ax, dx
        mov dx, 0
        mov bx, 4
        div bx

        inc dl 
        mov al,dl 
        mov cl,50
        mul cl 
        
        cmp ax, 100
        jl adder_y

        cmp ax, 101
        jl adder_y_2
        
        cmp ax, 170
        jg subtractor_y
        jmp create_random_y
        
        adder_y:
        add ax, 90
        jmp create_random_y

        adder_y_2:
        add ax, 50
        jmp create_random_y
        
        subtractor_y:
        sub ax, 35
        
        create_random_y:
        mov randomnumy, ax
        not_change:
        ret
     randNumberGenerator endp

; ----------------------------------------------------------- changing the position of the ball -----------------------------------------------------------     
     moveBall_user proc far 
        mov ah, 01h
        int 16h
        jz return_main  
        
        mov ah, 00h
        int 16h 
        
        cmp al, 'j'
        je turn_left
        cmp al, 'J'
        je turn_left
        
        cmp al, 'k'
        je turn_right
        cmp al, 'K'
        je turn_right
        
        jmp return_main
        
        turn_left:
        mov ax, ball_v
        sub ball_x, ax
        
        mov ax, window_bound
        cmp ball_x, ax
        jl fix_position_left
        jmp return_main
        
        turn_right:
        mov ax, ball_v 
        add ball_x, ax
        
        mov ax, window_w
        sub ax, window_bound
        sub ax, ball_size
        cmp ball_x, ax
        jg fix_position_right
        jmp return_main                                                   
        
        fix_position_left:
        mov ball_x, ax
        jmp return_main
        
        fix_position_right:   
        mov ball_x, ax
        jmp return_main
        
        return_main:
        RET
     moveBall_user endp   

; ---------------------------------------------------------------drawing new rocket -------------------------------------------------------------------     
     makerocket proc far
        Mov Cx,rocket_X
        Mov Dx,rocket_Y 
        
        horizon:
        Mov Ah,0Ch
        Mov Al,07h
        Mov Bh,00h       
        int 10h  
        Inc Cx
        Mov Ax,Cx
        sub Ax,rocket_X
        cmp Ax,rocket_w
        Jng horizon 
            vertical:
            mov cx, rocket_x
            inc dx  
             
            Mov Ax,dx
            sub Ax,rocket_y
            cmp Ax,rocket_h
            Jng horizon 
        
       

        ret
     makerocket endp

; ---------------------------------------------------------------- moving the ball in Y direction -----------------------------------------------------    
     move_ball proc far
        mov ax, ball_v_y 
        add ball_y, ax     
        mov ax, ball_v_y
        cmp ax, 09h
        je not_add
        inc ax
        not_add:
        mov ball_v_y, ax

        mov al, sec_digit
        cmp al, 1
        jl not_make
        mov ax, poison_v
        add poison_x, ax
        
        not_make:
        mov ax, window_bound 
        add ax, ball_size
        cmp ball_y, ax
        jle neg_v_y
        
        mov ax, window_h
        sub ax, window_bound 
        sub ax, ball_size
        cmp ball_y, ax
        jge neg_v_y
        
    
        mov ax, ball_x
        add ax, ball_size
        cmp ax, rocket_x
        jl check_gameover 
        
        mov ax, ball_x
        mov cx, rocket_x
        add cx, rocket_w
        cmp ax, cx
        jg check_gameover 
          
        mov ax, ball_y 
        add ax, ball_size
        mov cx, rocket_y
        sub cx, 04h
        cmp ax, cx
        jge next_condition
        jmp check_gameover
        
        next_condition:
        add cx, 08h
        cmp ax, cx
        jle neg_v_y_rocket
          
        
        check_gameover:
            mov ax, ball_y 
            mov cx, rocket_y
            cmp ax, cx
            jg gameover
            jmp continue
        
        
       
        
        gameover:
          cmp ball_v_y, 0
          jl continue
          call cls 

          mov ah, 02h
          mov dl, 39
          mov dx, 12
          mov bh, 00h
          int 10h

          mov ah, 09h
          lea dx, game_over_message
          int 21h

          mov ah, 4ch
          int 21h
          
        neg_v_y: 
           neg ball_v_y
           jmp continue
           
        neg_v_y_rocket:
           call update_score
           cmp ball_v_y, 0
           jl false_way 
           mov ball_v_y, 0Ah
           neg ball_v_y 
           
           call clear_rocket
           ;neg poision_flag
           mov ax, randomnumx
           mov rocket_x, ax
           mov ax, 0
           mov ax, randomnumy
           mov rocket_y, ax
           jmp continue
          
        false_way:
            call cls 
            mov ah, 02h
            mov dl, 39
            mov dx, 12
            mov bh, 00h
            int 10h
            mov ah, 09h
            lea dx, game_over_message
            int 21h
            mov ah, 4ch
            int 21h 

        
        continue:
        mov al, sec_digit
        cmp al, 1
        jl endFunc

        mov ax, window_w
        sub ax, window_bound 
        sub ax, poison_size
        sub ax, poison_bound
        cmp poison_x, ax
        jge neg_poison
        

        mov ax, poison_bound 
        cmp poison_x, ax
        jle neg_poison
        

        mov ax, ball_x
        add ax, Ball_size    
        cmp ax, poison_x
        jge next_1
        jmp endFunc
        
        next_1:
        mov ax, poison_x
        add ax, poison_size
        cmp ax, ball_x
        jge next_2
        jmp endFunc

        next_2:  
        mov ax, ball_y
        add ax, ball_size 
        cmp ax, poison_y
        jge next_3
        jmp endFunc
        
        next_3:
        mov ax, poison_y
        add ax, poison_size
        cmp ax, ball_y
        jge gameover2
        jmp endFunc

         gameover2:
          call cls 
          mov ah, 02h
          mov dl, 39
          mov dx, 12
          mov bh, 00h
          int 10h
          mov ah, 09h
          lea dx, game_over_message
          int 21h
          mov ah, 4ch
          int 21h



        neg_poison:
        neg poison_v

        endFunc:
        ret
     move_ball endp 
; ---------------------------------------------------------- updating the score of the user --------------------------------------------------
    update_score proc far
        mov al, first_digit
        cmp al, 9
        je zero_first_digit
        inc al 
        mov first_digit, al
        ret
        zero_first_digit:
        mov first_digit, 0
        mov Bl, sec_digit
        cmp Bl, 9
        je zero_sec_digit
        inc Bl 
        mov sec_digit, Bl
        ret
        zero_sec_digit:
        mov sec_digit, 0
        mov cl, third_digit
        inc cl

        
        ret
    update_score endp
; ----------------------------------------------------------- deleting the prev roccket --------------------------------------------------------     
     clear_rocket proc far
         Mov Cx,rocket_X
        Mov Dx,rocket_Y 
        
        horizon:
        Mov Ah,0Ch
        Mov Al,00h
        Mov Bh,00h       
        int 10h  
        Inc Cx
        Mov Ax,Cx
        sub Ax,rocket_X
        cmp Ax,rocket_w
        Jng horizon 
            vertical:
            mov cx, rocket_x
            inc dx  
             
            Mov Ax,dx
            sub Ax,rocket_y
            cmp Ax,rocket_h
            Jng horizon 


  

      

        ret
     clear_rocket endp

; ------------------------------------------------------------ drawing the new ball -------------------------------------------------------------     
     makeball proc far  
        Mov Cx,BALL_X
        Mov Dx,BALL_Y 
        horizon:
        Mov Ah,0Ch
        Mov Al,09h
        Mov Bh,00h       
        int 10h        
        Inc Cx
        Mov Ax,Cx
        sub Ax,Ball_X
        cmp Ax,BAll_size
        Jng horizon 
            vertical:
            mov cx, ball_x
            inc dx  
             
            Mov Ax,dx
            sub Ax,Ball_y
            cmp Ax,BAll_size
            Jng horizon 
            
        ret
     makeball endp 
; ------------------------------------------------------------- CLEARING THE SCREEN ---------------------------------------------------------------     
     cls proc far 
         Mov  AH,00h
        Mov Al,13h
        int 10h  
        
        Mov Ah,0Bh
        Mov Bh,00h
        Mov Bl,01h
        int 10h
        ret
     cls endp 

     delete_ball proc far
        Mov Cx,BALL_X
        Mov Dx,BALL_Y 
        horizon:
        Mov Ah,0Ch
        Mov Al,00h
        Mov Bh,00h       
        int 10h        
        Inc Cx
        Mov Ax,Cx
        sub Ax,Ball_X
        cmp Ax,BAll_size
        Jng horizon 
            vertical:
            mov cx, ball_x
            inc dx  
             
            Mov Ax,dx
            sub Ax,Ball_y
            cmp Ax,BAll_size
            Jng horizon

        mov al, sec_digit
        cmp al, 1
        jl not_make
        mov Cx, poison_x
        mov Dx, poison_y
       

        horizon_2:
        Mov Ah,0Ch
        Mov Al,00h
        Mov Bh,00h       
        int 10h  
        Inc Cx
        Mov Ax,Cx
        sub Ax,poison_x
        cmp Ax,poison_size
        Jng horizon_2 
            vertical_2:
            mov cx, poison_x
            inc dx  
             
            Mov Ax,dx
            sub Ax,poison_y
            cmp Ax,poison_size
            Jng horizon_2 
        not_make: 
        ret
     delete_ball endp
        
END  main



