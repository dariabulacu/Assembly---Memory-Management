#deci. eu in mom asta ma plimb printre toate liniile din matrice si ma chinui sa gasesc efectiv o linie pe care
#sa incapa descriptorul ideea e ca dimensiunea max a descriptorului este cat nrul de coloane ideea e alta ca
#daca ajunge sa termine toate liniile inseamna clar
#ca n are unde sa l puna pe descriptorul curent, dar daca termina coloana atunci exista o alta potentiala linie 
#unde ar putea sa l bage si tb sa o caut fr.

.data
    formatPrintfAdd:.asciz "%ld: ((%ld, %ld), (%ld, %ld))\n"
    formatScanf:.asciz "%ld"
    formatScanfDim:.asciz "%ld"
    formatScanfDescriptor:.asciz "%ld"
    formatPrintf1:.asciz "%ld\n" 
    formatScanfNrAdd:.asciz "%ld\n" 
    formatPrintfGet:.asciz "((%ld, %ld), (%ld, %ld))\n"
    formatPrintfDelete:.asciz "%ld: ((%ld, %ld), (%ld, %ld))\n"
    formatPrintfMatrix:.asciz "%ld"
    nr_op:.space 4
    op:.space 4
    imp:.long 1024 
    matrix:.space 4194304
    vector:.space 4194304
    descriptor:.space 4
    dimensiune:.space 4
    startX:.space 4
    endX:.space 4
    startY:.space 4
    endY:.space 4
    subsecv:.space 4
    i:.space 4 # contor pt nrul de operatii din add
    j:.space 4 # contor pentru numarul de operatii citite 
    n:.space 4 # nrul de operatii din add
    get_des:.space 4
    get_des_dummy: .space 4
    get_sX:.space 4
    get_eX:.space 4
    get_sY:.space 4
    get_eY:.space 4
    columnIndex:.space 4
    lineIndex:.space 4
    vectorIndex:.space 4
    array_sequence: .space 4
    newLine:.asciz "\n"
    inceput:.space 4
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

    #DE AICI INCEPE FUNCTIA ADD 
    func_add:
    push %ebp
    mov %esp, %ebp
    push %edi 
    mov 8(%ebp), %edi 
    movl $0, lineIndex
    lineIndex_loop:
    cmpl $1024, lineIndex
    je func_add_exit #nu am gasit nicio linie pe care sa incapa descriptorul deci afisez 0 0 0 0
    movl lineIndex, %eax
    xor %edx, %edx
    mull imp 
    movl $0, subsecv
    movl $0, columnIndex
        columnIndex_loop:
        cmpl $1024, columnIndex
        je columnIndex_continue
        cmpl $0, (%edi, %eax, 4)
        jne func_add_not_zero
        add_column_continue: #la %eax se afla un inceput de 0 care poate deveni o potentiala subsecventa 
        cmpl $0, (%edi, %eax,4)
        je func_add_zero
        inc %eax
        incl columnIndex
        jmp columnIndex_loop
    columnIndex_continue:
    incl lineIndex
    jmp lineIndex_loop

    func_add_not_zero:
    cmpl $1024, columnIndex
    je columnIndex_continue
    cmpl $0, (%edi, %eax, 4)
    je add_column_continue 
    movl $0, subsecv
    incl columnIndex
    inc %eax
    jmp func_add_not_zero

    func_add_zero:
    cmpl $1024, columnIndex
    je columnIndex_continue
    cmpl $0, (%edi, %eax, 4)
    jne func_add_not_zero
    incl subsecv
    movl subsecv, %ebx
    cmpl dimensiune, %ebx
    je add_descriptor
    incl columnIndex
    inc %eax
    jmp func_add_zero

    add_descriptor:
    mov %eax, %edx # finalul subsecventei 
    subl subsecv, %eax
    inc %eax
    add_descriptor_loop:
    cmp %eax, %edx
    jl func_add_exit1
    movl descriptor, %ebx
    mov %ebx, (%edi, %eax, 4)
    inc %eax
    incl columnIndex
    jmp add_descriptor_loop

    func_add_exit:
    movl $0, startX
    movl $0, startY
    movl $0, endX
    movl $0, endY
    pop %edi 
    pop %ebp
    ret

    func_add_exit1:
    movl %edx, %eax
    movl $0, %edx  
    divl imp    
    movl %eax, startX
    movl %eax, endX
    movl %edx, endY
    subl subsecv, %edx 
    incl %edx
    movl %edx, startY
    pop %edi 
    pop %ebp
    ret

    #DE AICI INCEPE FUNCTIA GET 
    func_get:
    push %ebp
    mov %esp, %ebp
    push %edi 
    mov 8(%ebp), %edi 
    movl $0, lineIndex
    movl get_des, %ebx
    xor %ecx, %ecx
    get_lineIndex_loop:
    cmpl $1024, lineIndex
    je func_get_exit
    movl lineIndex, %eax 
    xor %edx, %edx
    mull imp
    movl $0, columnIndex
        get_columnIndex_loop:
        cmpl $1024, columnIndex
        je get_line_continue
        cmp %ebx, (%edi, %eax, 4)
        je get_start
        incl columnIndex
        inc %eax
        jmp get_columnIndex_loop
    get_line_continue: 
    incl lineIndex
    jmp get_lineIndex_loop

    get_start:
    cmpl $1024, columnIndex
    je get_end 
    cmp %ebx, (%edi, %eax, 4)
    jne get_end 
    inc %ecx # am lungimea subsecventei in %ecx, in %eax am ultima aparitie a elem din subsecventa 
    inc %eax
    incl columnIndex
    jmp get_start

    get_end:
    dec %ecx
    dec %eax
    movl $0, %edx  
    divl imp    
    movl %eax, get_sX
    movl %eax, get_eX
    movl %edx, get_eY
    subl %ecx, %edx 
    movl %edx, get_sY
    pop %edi 
    pop %ebp
    ret

    func_get_exit:
    movl $0, get_sX
    movl $0, get_sY
    movl $0, get_eX
    movl $0, get_eY
    pop %edi 
    pop %ebp
    ret

    #DE AICI INCEPE FUNCTIA DELETE 
    func_delete:
    push %ebp
    mov %esp, %ebp
    push %edi 
    mov 8(%ebp), %edi 
    movl startX, %ecx
    func_delete_loop:
    cmp startY, %ecx
    jg func_delete_exit
    movl $0, (%edi, %ecx, 4)
    inc %ecx
    jmp func_delete_loop

    func_delete_exit:
    pop %edi 
    pop %ebp
    ret

    #DE AICI INCEPE FUNCTIA DEFRAGMENTATION...
    func_defragmentation:
    push %ebp
    mov %esp, %ebp
    push %edi
    push %esi
    mov 12(%ebp), %edi
    mov 8(%ebp), %esi
    xor %ecx, %ecx
    movl $0, lineIndex
    movl $0, vectorIndex
    lineIndex_loop_def:
    cmpl $1024, lineIndex
    je init_vector
    movl $0, columnIndex
    movl lineIndex, %eax
    xor %edx, %edx
    mull imp
        columnIndex_loop_def:
        cmpl $1024, columnIndex
        je lineIndex_continue_def
        cmpl $0, (%edi, %eax, 4)
        jne add_vector
        add_vector_continue:
        movl $0, (%edi, %eax, 4)
        inc %eax
        incl columnIndex
        jmp columnIndex_loop_def
    lineIndex_continue_def:
    incl lineIndex
    jmp lineIndex_loop_def
        
    add_vector:
    movl vectorIndex, %ecx
    movl (%edi, %eax, 4), %ebx
    movl %ebx, (%esi, %ecx, 4)
    incl vectorIndex
    jmp add_vector_continue

    init_vector:
    movl vectorIndex, %ecx
    init_vector_loop:
    cmpl $1048576, %ecx
    je make_matrix
    movl $0, (%esi, %ecx,4)
    inc %ecx
    jmp init_vector_loop

    make_matrix:
    movl $0, lineIndex
    xor %ecx, %ecx
    lineIndex_loop_matrix:
    cmpl $1024, lineIndex
    je defrag_exit
    movl lineIndex, %eax
    xor %edx, %edx 
    mull imp 
    movl $0, columnIndex
    movl $1024, subsecv
        columnIndex_loop_matrix:
        movl (%esi, %ecx, 4), %ebx # 280-284 iau primul element dintr o noua subsecventa din vector, aflu lungimea subsecventei si pastrez inceputul acesteia in cazul in care nu incape pe linie in matrice
        cmpl $0, %ebx
        je defrag_exit
        movl $0, array_sequence
        movl %ecx, inceput 
        jmp get_length
        get_length_continue: #in acest moment ecx se afla la o potentiala noua subsecventa 
        movl array_sequence, %edx 
        subl %edx, subsecv
        cmpl $0, subsecv # daca ce a mai ramas in subsecv este mai mic decat 0 inseamna ca noua sbsecventa nu incape pe linie si tb sa ma duc pe urmatoarea linie si ecx sa fie incrementat iar de la inceputul subsecventei actuale
        jl func_def_exit1
        cmpl $0,subsecv # inseamna ca subsecventa are loc pe linie si tb sa o pun acolo 
        jge add_matrix
        et_continue_def:
        jmp columnIndex_loop_matrix

    lineIndex_loop_continue_matrix:
    incl lineIndex
    jmp lineIndex_loop_matrix
   
    get_length:
    cmpl %ebx, (%esi, %ecx, 4)
    jne get_length_continue
    incl array_sequence
    inc %ecx
    jmp get_length

    add_matrix:
    cmpl $0, array_sequence
    je et_continue_def
    movl %ebx, (%edi, %eax,4)
    inc %eax
    decl array_sequence
    jmp add_matrix

    func_def_exit1:
    movl inceput, %ecx
    jmp lineIndex_loop_continue_matrix
    
    defrag_exit:
    pop %esi
    pop %edi 
    pop %ebp 
    ret 

#ok deci in defrag salvez toate subsecventele diferite de 0 intr un vector si apoi recosntruiesc matrice astfel
#iau o subsecventa si apoi vad daca are loc pe linia curenta daca nu are loc atunci trec la urmatoarea linie 
# doar ca tb sa reinitializez contorul pentru vector ca sa se duca ianpoi la subsecventa care nu a incaput 

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
    cmp $1, %eax
    je et_add
    cmp $2, %eax
    je et_get
    cmp $3, %eax
    je et_delete
    cmp $4, %eax
    je et_defragmentation
    et_continue:
    incl j
    jmp nr_op_loop

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
    push $matrix 
    call func_add
    pop %ebx
    push endY
    push endX
    push startY
    push startX
    push descriptor
    push $formatPrintfAdd
    call printf
    add $24, %esp
    et_continue_add:
    incl i
    jmp nradd_loop

    et_get:
    push $get_des 
    push $formatScanfDescriptor
    call scanf 
    add $8, %esp
    push $matrix 
    call func_get
    add $4, %esp
    push get_eY
    push get_eX
    push get_sY
    push get_sX
    push $formatPrintfGet
    call printf 
    add $20, %esp
    jmp et_continue

    et_delete:
    push $get_des
    push $formatScanfDescriptor
    call scanf 
    add $8, %esp
    push $matrix 
    call func_get
    add $4, %esp
    cmpl $0,get_eY
    je delete_exit 
    movl get_sX, %eax
    xorl %edx, %edx 
    mull imp
    addl get_sY, %eax
    movl %eax, startX
    subl get_sY, %eax
    addl get_eY, %eax
    movl %eax, startY
    push $matrix
    call func_delete
    add $4, %esp
    jmp delete_exit
    
    delete_exit:
    lea matrix, %edi 
    xor %ebx, %ebx 
    delete_exit_loop:
    cmpl $1048576, %ebx
    jge et_continue
    cmpl $0, (%edi, %ebx,4)
    jne printf_des
    des_printf_continue:
    inc %ebx
    jmp delete_exit_loop

    printf_des:
    movl (%edi, %ebx, 4), %eax
    movl %eax, get_des
    push $matrix
    call func_get 
    add $4, %esp
    push get_eY
    push get_eX
    push get_sY
    push get_sX
    push get_des
    push $formatPrintfDelete
    call printf 
    add $20, %esp
    movl get_sX, %eax
    xor %edx, %edx 
    mull imp
    addl get_eY, %eax
    movl %eax, %ebx
    jmp des_printf_continue

    et_defragmentation:
    push $matrix
    push $vector
    call func_defragmentation
    add $8, %esp
    jmp delete_exit


    et_exit:
    pushl $0
    call fflush
    popl %eax

    mov $1, %eax
    mov $0, %ebx
    int $0x80

