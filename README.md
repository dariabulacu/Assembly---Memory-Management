# Arhitectura Sistemelor de Calcul – Tema Laborator 2024

Acest repository conține metode de gestiune a memoriei folosind tehnici din cadrul cursului de  **Arhitectura Sistemelor de Calcul (ASC)**.

1. **Cazul unidimensional** (`1D_memory.s`) – gestionarea memoriei de stocare ca un spațiu liniar .
2. **Cazul bidimensional** (`2D_memory.s`) – extinderea gestionării memoriei pe două dimensiuni .

---

## Cuprins

- [Prezentare generală](#prezentare-generală)  
- [Structura proiectului](#structura-proiectului)  
- [Cerințe și formate de input/output](#cerințe-și-formate-de-inputoutput)  
  - [Cazul unidimensional (0x00)](#cazul-unidimensional-0x00)  
  - [Cazul bidimensional (0x01)](#cazul-bidimensional-0x01)  
- [Compilare și rulare](#compilare-și-rulare)  
- [Exemple de utilizare](#exemple-de-utilizare)  
- [Note administrative](#note-administrative)  
- [Resurse și referințe](#resurse-și-referințe)  

---

## Prezentare generală

Acest proiect implementează un modul de gestionare a dispozitivului de stocare (hard-disk sau SSD) pentru un sistem de operare minimal. Sunt două variante:

1. **Memorie unidimensională**:  
   - Capacitate totală fixă de 8 MB, împărțită în blocuri de câte 8 kB (în implementarea demonstrativă, un bloc de 8 kB este modelat ca 8 B).  
   - Fiecare fișier trebuie stocat contigu și ocupă un număr întreg de blocuri (rotunjire în sus).  
   - Operații suportate:  
     - **ADD** (alocare fișier)  
     - **GET** (interogare interval de blocuri pentru un descriptor)  
     - **DELETE** (ștergere fișier)  
     - **DEFRAGMENTATION** (reordonarea blocurilor pentru a compacta spațiul liber)

2. **Memorie bidimensională**:  
   - Dispozitiv de stocare privit ca o matrice de 8 MB × 8 MB, împărțită în blocuri de 8 kB fiecare (în demonstrație, 8 B).  
   - Fiecare fișier trebuie stocat pe linii succesive, tot contigu.  
   - Operații similare cu cazul unidimensional plus o operație suplimentară:  
     - **CONCRETE** (scanare a unui director local, determinare descriptor și dimensiune pentru fiecare fișier, apoi tratare ca un ADD)

Ambele cazuri trebuie implementate în limbaj de asamblare x86 (fișiere `.s`), astfel încât evaluarea să fie automată și să respecte formatul cerut.

---

## Structura proiectului
├── README.md
└── memory_management
├── 1D_memory.s
├── 2D_memory.s
└── input.txt

- **1D_memory.s**  
  Conține codul pentru partea unidimensională (ADD, GET, DELETE, DEFRAGMENTATION).  
- **2D_memory.s**  
  Conține codul pentru partea bidimensională (ADD, GET, DELETE, DEFRAGMENTATION și CONCRETE).  
- **input.txt**  
  Exemple de fișiere cu seturi de operații care pot fi folosite pentru a testa codul.

---

## Cerințe și formate de input/output

### Cazul unidimensional (0x00)

1. **Structura memoriei**  
   - Capacitate totală: 8 MB  
   - Blocuri de 8 kB → în implementarea demonstrativă, un bloc are 8 B.  
   - Fiecare bloc stochează descriptorul (un număr între 1 și 255) sau `0` dacă este liber.  
   - Maximum 255 fișiere active (descriptor ∈ [1..255]).  

2. **Codificarea operațiilor**  
   - `1` → **ADD**  
   - `2` → **GET**  
   - `3` → **DELETE**  
   - `4` → **DEFRAGMENTATION**

3. **Formatul inputului**  
   - Prima linie: `O` = numărul de operații.  
   - Pentru fiecare dintre cele `O` operații:  
     1. Citiți un cod de operație (1..4).  
     2. Dacă e `ADD` (cod `1`):  
        - Citiți `N` = numărul de fișiere care urmează să fie adăugate.  
        - Pentru fiecare dintre cele `N` fișiere, două linii consecutive:  
          1. Descriptor (întreg, între 1 și 255).  
          2. Dimensiune în kB (întreg).  
        - Pentru fiecare fișier, se returnează un interval de blocuri:  
          ```
          %d: (%d, %d)\n
          ```  
          unde primul `%d` este descriptorul, următoarele două `%d` sunt blocul de start și blocul de final (interval închis).  
        - Dacă nu se poate aloca fișierul (spațiu contiguu insuficient), tipăriți:  
          ```
          fd: (0, 0)\n
          ```  
          unde `fd` este descriptorul fișierului respectiv.  
     3. Dacă e `GET` (cod `2`):  
        - Citiți descriptorul fișierului.  
        - Tipăriți:
          ```
          (%d, %d)\n
          ```  
          unde `%d, %d` este intervalul (start, end) în care se găsește fișierul, sau `(0, 0)` dacă nu există.  
     4. Dacă e `DELETE` (cod `3`):  
        - Citiți descriptorul fișierului.  
        - Ștergeți fișierul (todos blocurile devin 0).  
        - Tipăriți întreaga stare curentă a memoriei, sub forma unei liste de descriptor per bloc, separată prin virgule și spațiu:
          ```
          d0, d1, d2, …, dM\n
          ```
          unde `M` = numărul total de blocuri – 1.  
     5. Dacă e `DEFRAGMENTATION` (cod `4`):  
        - Reordonați blocurile astfel încât toate blocurile ocupate să fie lipite de la stânga la dreapta, păstrând ordinea fișierelor.  
        - Tipăriți starea curentă a memoriei (același format ca la DELETE).

4. **Intervalele de blocuri și conversia dimensiunii**  
   - Un fișier de `S` kB necesită `ceil(S kB ÷ 8 kB) = ceil(S ÷ 8)` blocuri în simulare (deoarece fiecare bloc stochează 8 kB).  
   - În exemplu, s-a redus 8 kB → 8 B pentru a putea demonstra ușor.

---

### Cazul bidimensional (0x01)

1. **Structura memoriei**  
   - Dispozitivul este privit ca o matrice de dimensiune 8 MB × 8 MB → număr total de blocuri (`(8 MB / 8 kB) × (8 MB / 8 kB) = 1024 × 1024` blocuri).  
   - În demonstrație, 8 MB × 8 MB și bloc de 8 kB s-au redus la 8 B.  
   - Fiecare fișier este alocat pe linii succesive. O zonă contiguă de blocuri este definită pe aceeași linie/linii adiacente – practic, se caută primul “spațiu dreptunghiular” (o secvență de blocuri pe linii consecutive) suficient de mare.  
   - Dacă fișierul nu încape (contiguu pe linii), intervalul returnat este `((0, 0), (0, 0))`.

2. **Codificarea operațiilor**  
   - `1` → **ADD**  
   - `2` → **GET**  
   - `3` → **DELETE**  
   - `4` → **DEFRAGMENTATION**  

3. **Formatul inputului**  
   - Prima linie: `O` = numărul de operații.  
   - Pentru fiecare dintre cele `O` operații:  
     1. Citiți codul de operație (1..5).  
     2. Dacă e `ADD` (cod `1`):  
        - Citiți `N` = numărul de fișiere care urmează să fie adăugate.  
        - Pentru fiecare dintre cele `N` fișiere, două linii:  
          1. Descriptor (întreg ∈ [1..255]).  
          2. Dimensiune în kB (întreg).  
        - Pentru fiecare fișier se tipărește:
          ```
          %d: ((%d, %d), (%%d, %d))\n
          ```
          unde primul `%d` = descriptor, apoi coordonatele colțului stânga-sus `(startX, startY)` și colțului dreapta-jos `(endX, endY)` (interval închis).  
        - Dacă nu încape, tipăriți:
          ```
          fd: ((0, 0), (0, 0))\n
          ```  
     3. Dacă e `GET` (cod `2`):  
        - Citiți descriptor.  
        - Tipăriți:
          ```
          ((%d, %d), (%d, %d))\n
          ```
          cu coordonatele unde este stocat fișierul, sau `((0, 0), (0, 0))` dacă nu există.  
     4. Dacă e `DELETE` (cod `3`):  
        - Citiți descriptor.  
        - Ștergeți fișierul (toate blocurile cu acel descriptor → 0).  
        - Tipăriți întreaga stare a memoriei, sub forma unei matrice de `R` linii × `C` coloane (unde `R = C = 1024` în versiunea reală; în demonstrație, o dimensiune mai mică). Fiecare linie este afișată ca:
          ```
          d0, d1, …, dC−1\n
          ```
          unde fiecare `di` este descriptorul sau `0`.  
     5. Dacă e `DEFRAGMENTATION` (cod `4`):  
        - Reordonați fișierele astfel încât toate blocurile ocupate să fie lipite “în sus și la stânga” (golurile mutându-se în dreapta-jos). Păstrați ordinea de alocare a fișierelor.  
        - Tipăriți memoria reordonată (tolată similar cu DELETE).  
     

---

## Compilare și rulare

Codul este scris în limbaj de asamblare x86 (fișierele `.s`). Vă recomandăm să folosiți **NASM** (Netwide Assembler) și **ld** (linker-ul GNU) pentru a genera un executabil pe Linux (sau WSL) pe arhitectură `elf32`. Urmați pașii:

1. **Compilare task**  
   ```bash
   gcc -m32 file_name.s -o file_name -no-pie -z noexecstack
   ./file_name < input.txt > output.txt
   Rulare cu fișier de input

În loc să introduceți manual operațiile, creați un fișier input.txt și scrieți acolo toate liniile de input conform formatului cerut, asemenea exemplului din directory. Rezultatul poate fi redirectionat catre un al fisier de output.txt





