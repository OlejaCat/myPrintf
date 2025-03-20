# myPrintf

## Description
My printf implementation in x86-64 NASM Assembly for educational purposes. Supports basic format strings with specifiers.

## Features

- Supported format specifiers:
  - `%b` - Binary
  - `%c` - Character
  - `%d` - Signed decimal
  - `%o` - Octal
  - `%s` - String
  - `%x` - Hexadecimal (lowercase)
- Return value is number of formated arguments
- In case of error will return -1

## Installation (Linux x86-64)

### Dependencies
- NASM (Netwide Assembler)
- GCC (GNU Compiler Collection)
- GNU Linker (ld)

### Build Instructions
```bash
# Install dependencies
sudo apt-get install nasm gcc

# Clone repository
git clone https://github.com/yourusername/myprintf.git
cd myprintf
./run
./exec
```


## Usage
You can watch exaple program in 'main.c'
