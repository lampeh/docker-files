This image contains only a 120-byte x86_64 /bin/true to allow docker to run the data volume container.

Bytes copied from the internet: [http://www.muppetlabs.com/~breadbox/software/tiny/return42.html][1]

TODO: Look at [https://github.com/cpuguy83/docker-volumes][2]

    ;; tiny.asm: Copyright (C) 2011 Brian Raiter <breadbox@muppetlabs.com>
    ;; Licensed under the terms of the GNU General Public License, either
    ;; version 2 or (at your option) any later version.
    ;;
    ;; To build:
    ;;      nasm -f bin -o tiny tiny.asm && chmod +x tiny
    
    BITS 64
    
                    org     0x00BF00000000
    ehdr:                                                   ; Elf64_Ehdr
                    db      0x7F, "ELF", 2, 1, 1, 3         ;   e_ident
                    dq      0
                    dw      2                               ;   e_type
                    dw      62                              ;   e_machine
                    dd      1                               ;   e_version
                    dq      _start                          ;   e_entry
                    dq      phdr - $$                       ;   e_phoff
                    dq      0                               ;   e_shoff
                    dd      0                               ;   e_flags
                    dw      ehdrsz                          ;   e_ehsize
                    dw      phdrsz                          ;   e_phentsize
                    dw      1                               ;   e_phnum
                    dw      0                               ;   e_shentsize
                    dw      0                               ;   e_shnum
                    dw      0                               ;   e_shstrndx
    ehdrsz          equ     $ - ehdr
    
    phdr:                                                   ; Elf64_Phdr
                    dd      1                               ;   p_type
                    dd      5                               ;   p_flags
                    dq      0                               ;   p_offset
                    dd      0                               ;   p_vaddr
    _start:         mov     edi, 0  ; rdi = exit code       ;   p_paddr
                    mov     eax, 60 ; rax = syscall number
                    syscall         ; exit(rdi)
                    dq      filesz                          ;   p_filesz
                    dq      filesz                          ;   p_memsz
                    dq      0x1000                          ;   p_align
    phdrsz          equ     $ - phdr
    
    filesz          equ     $ - $$


  [1]: http://www.muppetlabs.com/~breadbox/software/tiny/return42.html
  [2]: https://github.com/cpuguy83/docker-volumes

