# terminal-games

🎮 Launcher simples para jogos em Lua no terminal

---

## 🧩 Sobre

O **terminal-games** é um launcher interativo que permite executar jogos feitos em Lua diretamente do terminal. Ele lista automaticamente os scripts `.lua` presentes na pasta `games/`, exibe descrições dos jogos (se disponíveis) e permite a navegação através das setas do teclado.

---

## ⚙️ Funcionalidades

- ✅ Lista jogos `.lua` da pasta `./games`
- ✅ Navegação com setas e Enter
- ✅ Exibe descrições dos jogos (`.txt`)
- ✅ Executa scripts Lua via launcher C++
- ✅ Interface simples e portátil

---

## 📂 Estrutura do Projeto

```
terminal-games/
│
├── games/           # Coloque aqui seus arquivos .lua e .txt de descrição
├── saves/           # (não usado na versão atual, mas preparado para progresso)
├── src/
│   ├── main.cpp     # Código fonte do launcher
│   └── lua/         # Código fonte da biblioteca Lua
├── Makefile         # Arquivo para compilar o projeto
└── README.md        # Este arquivo
```

---

## 🛠️ Como Compilar

### Requisitos

- GCC/G++ com suporte a C++17
- Make (Windows: use `mingw32-make`)

### Comando para compilar

```bash
make
```

Ou no Windows:

```bash
mingw32-make
```

---

## 🚀 Como Usar

1. Coloque seus jogos `.lua` em `games/`.  
2. (Opcional) Crie arquivos `.txt` com descrição para cada jogo.  
3. Execute o launcher:

```bash
./terminal-games
```

No Windows:

```bash
terminal-games.exe
```

4. Navegue com as setas e Enter para jogar.

---

## 📞 Contato

Crie issues ou envie pull requests para contribuir!

---

Feito com ❤️ para jogos em terminal.
