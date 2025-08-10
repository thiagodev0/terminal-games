#include <iostream>
#include <string>
#include <vector>
#include <filesystem>
#include <locale>
#include <limits>

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}

namespace fs = std::filesystem;

#ifdef _WIN32
#include <conio.h>
#else
#include <termios.h>
#include <unistd.h>
char getch() {
    char buf = 0;
    struct termios old = {};
    if (tcgetattr(STDIN_FILENO, &old) < 0) perror("tcsetattr()");
    struct termios newt = old;
    newt.c_lflag &= ~ICANON;
    newt.c_lflag &= ~ECHO;
    if (tcsetattr(STDIN_FILENO, TCSANOW, &newt) < 0) perror("tcsetattr ICANON");
    if (read(STDIN_FILENO, &buf, 1) < 0) perror("read()");
    if (tcsetattr(STDIN_FILENO, TCSANOW, &old) < 0) perror("tcsetattr ~ICANON");
    return buf;
}
#endif

class Launcher {
public:
    Launcher() {
        L = luaL_newstate();
        luaL_openlibs(L);
    }

    ~Launcher() {
        if (L)
            lua_close(L);
    }

    std::vector<std::string> listarJogos(const std::string& pasta) {
        std::vector<std::string> jogos;
        if (!fs::exists(pasta) || !fs::is_directory(pasta))
            return jogos;
        for (const auto& entrada : fs::directory_iterator(pasta)) {
            if (entrada.path().extension() == ".lua")
                jogos.push_back(entrada.path().filename().string());
        }
        return jogos;
    }

    bool executar(const std::string& arquivo, int argc, char* argv[]) {
        lua_newtable(L);
        for (int i = 0; i < argc; ++i) {
            lua_pushinteger(L, i + 1);
            lua_pushstring(L, argv[i]);
            lua_settable(L, -3);
        }
        lua_setglobal(L, "arg");

        if (luaL_loadfile(L, arquivo.c_str()) || lua_pcall(L, 0, 0, 0)) {
            std::cerr << "Erro ao executar Lua: " << lua_tostring(L, -1) << "\n";
            lua_settop(L, 0);
            return false;
        }
        return true;
    }

private:
    lua_State* L;
};

void limparTela() {
#ifdef _WIN32
    system("cls");
#else
    system("clear");
#endif
}

int menuInterativo(const std::vector<std::string>& opcoes, const std::string& titulo) {
    int selecionado = 0;
    while (true) {
        limparTela();
        std::cout << titulo << "\n\n";
        for (size_t i = 0; i < opcoes.size(); i++) {
            if ((int)i == selecionado)
                std::cout << "> " << opcoes[i] << "\n";
            else
                std::cout << "  " << opcoes[i] << "\n";
        }
        char c = 0;
#ifdef _WIN32
        c = _getch();
        if (c == 0 || c == -32) {
            c = _getch();
            if (c == 72) selecionado = (selecionado - 1 + (int)opcoes.size()) % (int)opcoes.size();
            else if (c == 80) selecionado = (selecionado + 1) % (int)opcoes.size();
        } else if (c == '\r')
            return selecionado;
#else
        c = getch();
        if (c == 27) {
            if (getch() == '[') {
                char dir = getch();
                if (dir == 'A') selecionado = (selecionado - 1 + (int)opcoes.size()) % (int)opcoes.size();
                else if (dir == 'B') selecionado = (selecionado + 1) % (int)opcoes.size();
            }
        } else if (c == '\n' || c == '\r')
            return selecionado;
#endif
    }
}

void aguardarEnter() {
    std::cout << "Pressione Enter para continuar...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    std::cin.get();
}

int main(int argc, char* argv[]) {
    setlocale(LC_ALL, "pt_BR.UTF-8");
    Launcher launcher;
    const std::string pasta_games = "./games";

    while (true) {
        auto jogos = launcher.listarJogos(pasta_games);
        if (jogos.empty()) {
            limparTela();
            std::cout << "Nenhum jogo (.lua) encontrado na pasta './games'.\n";
            aguardarEnter();
            return 0;
        }
        std::vector<std::string> opcoes = jogos;
        opcoes.push_back("Sair");
        int escolha = menuInterativo(opcoes, "=== Selecione um Jogo ===");
        if (escolha == (int)opcoes.size() - 1) {
            limparTela();
            std::cout << "Obrigado por jogar! Até a próxima.\n";
            break;
        }
        std::string jogoEscolhido = jogos[escolha];
        limparTela();
        std::cout << "Executando: " << jogoEscolhido << "\n\n";
        std::string caminho = (fs::path(pasta_games) / jogoEscolhido).string();
        bool sucesso = launcher.executar(caminho, argc, argv);
        if (!sucesso)
            std::cout << "Falha na execução do jogo.\n";
        else
            std::cout << "Jogo finalizado.\n";
        aguardarEnter();
    }

    return 0;
}