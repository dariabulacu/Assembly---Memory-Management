.data
    formatPrintf:.asciz "%ld : (%ld, %ld) \n"
    formatScanf:.asciz "%ld"
    formatScanfDim:.asciz "%ld"
    formatScanfDescriptor:.asciz "%ld"
    formatPrintf1:.asciz "%ld \n" 
    formatScanfNrAdd:.asciz "%ld \n" 
    formatPrintfGet:.asciz "%ld : (%ld, %ld) \n"
    formatPrintfGet1:.asciz "(%ld, %ld) \n"
    nr_op:.space 4
    op:.space 4
    v:.space 4096
    descriptor:.space 4
    dimensiune:.space 4
    start:.space 4
    end:.space 4
    subsecv:.space 4
    i:.space 4 # contor pt nrul de operatii din add
    j:.space 4
    n:.space 4 #nrul de operatii din add
    get_des:.space 4
    get_des_dummy: .space 4
    get_s:.space 4
    get_e:.space 4
    
.text
    
    parte_sup:
    push %ebp
    mov %esp,%ebp
    mov 8(%ebp), %eax
    mov $8, %ebx
    xor %edx, %edx
    divl %ebx
    cmp $0, %edx
    jne parte_sup_1
    pop %ebp
    ret
    parte_sup_1:
    inc %eax
    pop %ebp
    ret 
#FUNCTIA ADD
    func_add:
    push %ebp
    mov %esp, %ebp
    push %edi 
    mov 8(%ebp), %edi 
    xor %ecx, %ecx
    movl $0, subsecv 
    func_add_loop:
    cmpl $1024, %ecx
    je func_add_exit1
    cmpl $0, (%edi, %ecx, 4)
    jne func_add_not_zero
    add_continue: #in acest moment am la ecx un elem cu val 0
    cmpl $0, (%edi, %ecx, 4)
    je func_add_zero
    inc %ecx
    jmp func_add_loop

    func_add_not_zero:
    cmpl $1024, %ecx
    jge func_add_exit1 #aici e clar ca n are loc in vector
    cmpl $0, (%edi, %ecx,4)
    je add_continue #daca am gasit un elem din vector cu val 0 incepe o potentiala subsecventa
    movl $0, subsecv 
    inc %ecx
    jmp func_add_not_zero

    func_add_zero:
    cmpl $1024, %ecx
    jge func_add_exit1 
    cmpl $0, (%edi, %ecx, 4)
    jne func_add_not_zero
    incl subsecv
    movl subsecv, %eax
    cmp %eax, dimensiune
    je add_descriptor
    inc %ecx
    jmp func_add_zero

    add_descriptor:
    mov %ecx, %edx
    subl subsecv, %ecx
    inc %ecx
    add_descriptor_loop:
    cmp %ecx, %edx
    jl func_add_exit
    movl descriptor, %eax
    mov %eax, (%edi, %ecx, 4)
    inc %ecx
    jmp add_descriptor_loop

    func_add_exit1:
    movl $0, start
    movl $0, end
    pop %edi 
    pop %ebp
    ret 

    func_add_exit:
    movl %edx, end
    subl subsecv, %edx
    incl %edx
    movl %edx, start
    pop %edi 
    pop %ebp
    ret

#FUNCTIA GET 
    func_get:
    push %ebp
    mov %esp, %ebp
    push %edi 
    mov 8(%ebp), %edi
    xorl %ecx, %ecx
    movl get_des, %eax
    func_get_loop:
    cmp $1024, %ecx
    je func_get_exit
    cmp %eax, (%edi, %ecx,4)
    je get_start
    inc %ecx
    jmp func_get_loop

    get_start:
    movl %ecx, get_s
    get_start_loop:
    cmpl $1024, %ecx
    je get_end1
    cmp %eax, (%edi, %ecx, 4)
    jne get_end
    inc %ecx
    jmp get_start_loop

    get_end:
    dec %ecx
    movl %ecx, get_e 
    jmp func_get_exit1

    get_end1:
    dec %ecx
    movl %ecx, get_e 
    jmp func_get_exit1

    func_get_exit:
    movl $0, get_s
    movl $0, get_e
    pop %edi 
    pop %ebp
    ret

    func_get_exit1:
    pop %edi
    pop %ebp
    ret

#FUNCTIA DELETE
    func_delete:
    push %ebp
    mov %esp, %ebp
    push %edi 
    mov 8(%ebp), %edi
    movl get_s, %ebx
    func_delete_loop:
    cmp get_e, %ebx
    jg func_delete_exit
    movl $0, (%edi, %ebx, 4)
    inc %ebx
    jmp func_delete_loop

    func_delete_exit:
    pop %edi 
    pop %ebp
    ret 
#FUNCTIA DEFRAGMENTATION 
    func_defragmentation:
    push %ebp
    mov %esp, %ebp
    push %edi 
    mov 8(%ebp), %edi
    xor %ecx, %ecx
    xor %edx, %edx
    func_defragmentation_loop:
    cmp $1024, %ecx
    je defragmentation_exit
    cmpl $0, (%edi, %ecx, 4)
    jne defragmentation_start
    defragmentation_continue:
    inc %ecx
    jmp func_defragmentation_loop

    defragmentation_start:
    mov (%edi, %ecx, 4), %eax
    mov %eax, (%edi, %edx, 4)
    inc %edx
    jmp defragmentation_continue
    
    defragmentation_exit:
    cmp $1024, %edx
    je def_final
    movl $0, (%edi, %edx,4)
    inc %edx
    jmp defragmentation_exit

    def_final:
    pop %edi 
    pop %ebp
    ret

.global main
    main:
    push $nr_op
    push $formatScanf
    call scanf
    add $8, %esp
    et_nr_op:
    xor %ecx, %ecx 
    movl $0, j
    nr_op_loop:
    movl j, %ecx
    cmp nr_op, %ecx 
    je et_exit
    push $op
    push $formatScanf 
    call scanf 
    add $8, %esp
    movl op, %eax
    cmp $1,  %eax
    je et_add
    cmp $2,  %eax
    je et_get
    cmp $3,  %eax
    je et_delete
    cmp $4, %eax
    je et_defragmentation
    et_continue:
    incl j
    jmp nr_op_loop

    #DE AICI INCEPE ADD 
    et_add:
    push $n
    push $formatScanfNrAdd
    call scanf 
    add $8, %esp
    movl $0, i
    nradd_loop:
    movl i, %eax
    cmp %eax, n
    je et_continue
    push $descriptor
    push $formatScanfDescriptor
    call scanf
    add $8, %esp
    push $dimensiune
    push $formatScanfDim
    call scanf 
    add $8, %esp
    push dimensiune
    call parte_sup
    add $4, %esp
    movl %eax, dimensiune 
    push $v
    call func_add
    pop %ebx
    push end
    push start
    push descriptor
    push $formatPrintf
    call printf
    add $12, %esp
    incl i
    jmp nradd_loop

    #DE AICI INCEPE GET 
    et_get:
    push $get_des
    push $formatScanfDescriptor
    call scanf 
    add $8, %esp
    push $v 
    call func_get
    add $4, %esp
    push get_e
    push get_s
    push $formatPrintfGet1
    call printf
    add $12, %esp
    jmp et_continue 

    #DE AICI INCEPE DELETE
    et_delete:
    push $get_des
    push $formatScanfDescriptor
    call scanf 
    add $8, %esp
    push $v
    call func_get
    add $4, %esp
    cmpl $0, get_e
    je delete_exit
    push $v
    call func_delete
    add $4, %esp
    jmp delete_exit
        
    delete_exit:
    lea v, %edi 
    xor %ebx, %ebx
    delete_exit_loop:
    cmp $1024, %ebx
    jge et_continue
    cmpl $0, (%edi, %ebx, 4)
    jne printf_des
    des_printf_continue:
    inc %ebx
    jmp delete_exit_loop
    
    printf_des:
    mov (%edi, %ebx, 4), %eax
    movl %eax, get_des
    push $v 
    call func_get
    add $4, %esp
    push get_e
    push get_s
    push get_des
    push $formatPrintfGet
    call printf
    add $12, %esp
    movl get_s, %eax
    subl %eax, get_e
    add get_e, %ebx
    jmp des_printf_continue


    #DE AICI INCEPE DEFRAGMENTATION
    et_defragmentation:
    push $v
    call func_defragmentation
    add $4, %esp
    jmp delete_exit

    et_exit:
    pushl $0
    call fflush
    popl %eax

    mov $1, %eax
    xor %ebx, %ebx
    int $0x80
