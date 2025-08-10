math.randomseed(os.time())

local Utils = {}
function Utils.clear() os.execute("clear||cls") end

local Classes = {}

Classes.data = {
  Guerreiro = {
    descricao = "Um combatente forte e destemido que adora entrar na luta corpo a corpo.",
    bonus_status = {forca=3, agilidade=2, inteligencia=0, sorte=0}
  },
  Mago = {
    descricao = "Um sábio que domina as artes arcanas, mas precisa cuidar de sua fragilidade.",
    bonus_status = {forca=0, agilidade=1, inteligencia=5, sorte=2}
  },
  Ladino = {
    descricao = "Astuto e rápido, especialista em golpes certeiros e fugas rápidas.",
    bonus_status = {forca=2, agilidade=4, inteligencia=1, sorte=3}
  }
}

local Personagem = {}

function Personagem.novo(nome, classe)
  local p = {
    nome = nome,
    classe = classe,
    lvl = 1,
    exp = 0,
    exp_to_next = 100,
    hp_max = 100,
    hp = 100,
    mp_max = 50,
    mp = 50,
    base_status = {forca=5, agilidade=5, inteligencia=5, sorte=5},
    equipamentos = {arma=nil, armadura=nil, anel=nil},
    inventario = {},
    habilidades = {},
    perks = {},
    quests = {},
    perk_points = 0,
  }
  local c = Classes.data[classe]
  if c then
    for k,v in pairs(c.bonus_status) do
      p.base_status[k] = p.base_status[k] + v
    end
  end
  Personagem.atualizar_status(p)
  return p
end

function Personagem.atualizar_status(p)
  p.atk = p.base_status.forca * 2
  p.def = p.base_status.agilidade * 1.5
  p.mag = p.base_status.inteligencia * 2
  p.crit_chance = 5 + p.base_status.sorte
  p.evasion = 5 + p.base_status.agilidade
  for perk,_ in pairs(p.perks) do
    local perkdata = Perks.data[perk]
    if perkdata and perkdata.aplicar then
      perkdata.aplicar(p)
    end
  end
end

function Personagem.ganha_exp(p, qtd)
  p.exp = p.exp + qtd
  print("\nVocê ganhou " .. qtd .. " pontos de experiência.")
  while p.exp >= p.exp_to_next do
    p.exp = p.exp - p.exp_to_next
    p.lvl = p.lvl + 1
    p.exp_to_next = math.floor(p.exp_to_next * 1.5)
    p.perk_points = p.perk_points + 1
    print("Parabéns! Você subiu para o nível " .. p.lvl .. " e ganhou 1 ponto para desbloquear perks.")
  end
end

local Itens = {}

Itens.data = {
  ["Pó Mágico"] = {tipo="material", descricao="Ingrediente brilhante, essencial para magias e poções."},
  ["Ferro"] = {tipo="material", descricao="Metal resistente, base para forjar armas e armaduras."},
  ["Espada Curta"] = {tipo="arma", ataque=10, descricao="Uma lâmina rápida, perfeita para ataques ágeis."},
  ["Anel da Sorte"] = {tipo="anel", sorte=5, descricao="Um anel que parece atrair boa sorte."},
  ["Poção de Vida"] = {tipo="consumivel", cura=50, descricao="Bebida que restaura sua saúde imediatamente."},
  ["Poção de Mana"] = {tipo="consumivel", recarrega=30, descricao="Poção que recarrega sua energia mágica."}
}

Itens.receitas = {
  ["Espada Curta"] = {materiais={["Ferro"]=2}},
  ["Anel da Sorte"] = {materiais={["Ferro"]=1, ["Pó Mágico"]=1}},
  ["Poção de Vida"] = {materiais={["Pó Mágico"]=1}},
  ["Poção de Mana"] = {materiais={["Pó Mágico"]=2}},
}

function Itens.craft(p, nome)
  local receita = Itens.receitas[nome]
  if not receita then
    print("Não conheço essa receita.")
    return false
  end
  for mat, qtd in pairs(receita.materiais) do
    if (p.inventario[mat] or 0) < qtd then
      print("Você precisa de " .. qtd .. "x " .. mat .. ".")
      return false
    end
  end
  for mat, qtd in pairs(receita.materiais) do
    p.inventario[mat] = p.inventario[mat] - qtd
    if p.inventario[mat] <= 0 then p.inventario[mat] = nil end
  end
  p.inventario[nome] = (p.inventario[nome] or 0) + 1
  print("Você criou 1x " .. nome .. ".")
  return true
end

local Perks = {}

Perks.data = {
  ["Força Aprimorada"] = {
    descricao = "Sua força aumenta consideravelmente, tornando seus golpes mais potentes.",
    custo = 1,
    aplicar = function(p) p.base_status.forca = p.base_status.forca + 3 end,
    requisitos = {}
  },
  ["Mestre das Armas"] = {
    descricao = "Você domina melhor as armas, aumentando seu poder ofensivo.",
    custo = 2,
    aplicar = function(p) p.atk = p.atk + 10 end,
    requisitos = {"Força Aprimorada"}
  },
  ["Agilidade Felina"] = {
    descricao = "Sua agilidade impressiona, fazendo com que você evite ataques com mais facilidade.",
    custo = 1,
    aplicar = function(p) p.evasion = p.evasion + 5 end,
    requisitos = {}
  },
  ["Magia Avançada"] = {
    descricao = "Seus conhecimentos mágicos crescem, aumentando seu poder com feitiços.",
    custo = 2,
    aplicar = function(p) p.base_status.inteligencia = p.base_status.inteligencia + 5 end,
    requisitos = {}
  }
}

function Perks.pode_adquirir(p, nome)
  local perk = Perks.data[nome]
  if not perk then return false, "Este perk não existe." end
  for _, req in ipairs(perk.requisitos) do
    if not p.perks[req] then
      return false, "Você precisa desbloquear '" .. req .. "' antes."
    end
  end
  if p.perk_points < perk.custo then
    return false, "Você não tem pontos suficientes para esse perk."
  end
  return true
end

function Perks.adquirir(p, nome)
  local pode, motivo = Perks.pode_adquirir(p, nome)
  if not pode then
    print("Ainda não dá: " .. motivo)
    return false
  end
  p.perks[nome] = true
  p.perk_points = p.perk_points - Perks.data[nome].custo
  print("Você desbloqueou o perk: " .. nome .. ".")
  Personagem.atualizar_status(p)
  return true
end

local NPCs = {}

NPCs.data = {
  ["Olaf"] = {
    nome = "Olaf, o Ferreiro",
    descricao = "Um homem robusto, com mãos calejadas e um sorriso amigável.",
    quest = {
      nome = "Reúna Ferro",
      descricao = "Olaf precisa de 2 unidades de Ferro para fabricar uma arma especial.",
      requisito = function(p) return (p.inventario["Ferro"] or 0) >= 2 end,
      recompensa = function(p)
        Itens.craft(p, "Espada Curta")
        print("Olaf entrega para você uma Espada Curta feita especialmente para você.")
        p.inventario["Ferro"] = p.inventario["Ferro"] - 2
        if p.inventario["Ferro"] <= 0 then p.inventario["Ferro"] = nil end
        Personagem.atualizar_status(p)
        Personagem.ganha_exp(p, 50)
      end
    }
  },
  ["Lina"] = {
    nome = "Lina, a Alquimista",
    descricao = "Uma jovem alquimista que estuda ingredientes raros na floresta.",
    quest = {
      nome = "Pó Mágico",
      descricao = "Lina quer que você colete 3 unidades de Pó Mágico da floresta.",
      requisito = function(p) return (p.inventario["Pó Mágico"] or 0) >= 3 end,
      recompensa = function(p)
        print("Lina sorri e lhe dá uma Poção de Mana como agradecimento.")
        p.inventario["Poção de Mana"] = (p.inventario["Poção de Mana"] or 0) + 1
        p.inventario["Pó Mágico"] = p.inventario["Pó Mágico"] - 3
        if p.inventario["Pó Mágico"] <= 0 then p.inventario["Pó Mágico"] = nil end
        Personagem.ganha_exp(p, 40)
      end
    }
  }
}

function NPCs.falar(npc, p)
  print("\nVocê se aproxima de " .. npc.nome .. ".")
  print(npc.descricao)
  if npc.quest then
    local q = npc.quest
    print("\nQuest: " .. q.nome)
    print(q.descricao)
    if q.requisito(p) then
      print("Você cumpriu os requisitos da quest. Deseja entregar? (sim/não)")
      local res = io.read()
      if res:lower() == "sim" then
        q.recompensa(p)
        npc.quest = nil
      else
        print("Você decide guardar a quest por enquanto.")
      end
    else
      print("Ainda não completou essa quest.")
    end
  else
    print("Nada mais para fazer aqui.")
  end
end

local Eventos = {}

Eventos.lista = {
  function(p)
    print("\nEnquanto explora, você encontra uma árvore com frutos brilhantes.")
    local chance = math.random(1, 100)
    if chance <= 70 then
      print("Você colhe 1x Pó Mágico.")
      p.inventario["Pó Mágico"] = (p.inventario["Pó Mágico"] or 0) + 1
    else
      print("Uma criatura aparece e tenta atacar!")
      local dano = math.random(10, 25)
      p.hp = p.hp - dano
      print("Você recebeu " .. dano .. " de dano. HP atual: " .. p.hp .. "/" .. p.hp_max)
      if p.hp <= 0 then
        print("Você desmaiou após o ataque...")
      end
    end
  end,
  function(p)
    print("\nVocê encontra um riacho cristalino, e bebe água para se recuperar.")
    local cura = math.random(10, 20)
    p.hp = math.min(p.hp + cura, p.hp_max)
    print("HP restaurado em " .. cura .. ". HP atual: " .. p.hp .. "/" .. p.hp_max)
  end,
  function(p)
    print("\nVocê encontra um barril abandonado, que pode conter materiais.")
    local itens_possiveis = {"Ferro", "Pó Mágico", "Poção de Vida"}
    local achado = itens_possiveis[math.random(#itens_possiveis)]
    p.inventario[achado] = (p.inventario[achado] or 0) + 1
    print("Você encontrou 1x " .. achado .. ".")
  end
}

function Eventos.aleatorio(p)
  local evento = Eventos.lista[math.random(#Eventos.lista)]
  evento(p)
end

local Menu = {}

function Menu.mostrar_status(p)
  print("\nStatus de " .. p.nome)
  print("Classe: " .. p.classe .. " | Nível: " .. p.lvl .. " | EXP: " .. p.exp .. "/" .. p.exp_to_next)
  print("HP: " .. p.hp .. "/" .. p.hp_max .. " | MP: " .. p.mp .. "/" .. p.mp_max)
  print("Força: " .. p.base_status.forca .. " | Agilidade: " .. p.base_status.agilidade .. " | Inteligência: " .. p.base_status.inteligencia .. " | Sorte: " .. p.base_status.sorte)
  print("Ataque: " .. math.floor(p.atk) .. " | Defesa: " .. math.floor(p.def) .. " | Magia: " .. math.floor(p.mag))
  print("Chance Crítica: " .. p.crit_chance .. "% | Evasão: " .. p.evasion .. "%")
  print("Pontos para perks: " .. p.perk_points)
end

function Menu.mostrar_inventario(p)
  print("\nInventário:")
  if next(p.inventario) == nil then
    print("  (vazio)")
    return
  end
  for item, qtd in pairs(p.inventario) do
    local desc = Itens.data[item] and Itens.data[item].descricao or ""
    print("  " .. item .. " x" .. qtd .. " - " .. desc)
  end
end

function Menu.mostrar_perks(p)
  print("\nPerks desbloqueados:")
  if next(p.perks) == nil then print("  Nenhum perk desbloqueado.") end
  for perk,_ in pairs(p.perks) do
    print("  " .. perk .. " - " .. Perks.data[perk].descricao)
  end
  print("\nPontos disponíveis: " .. p.perk_points)
  print("Digite o nome do perk para desbloquear ou ENTER para voltar:")
  local escolha = io.read()
  if escolha ~= "" then
    Perks.adquirir(p, escolha)
  end
end

function Menu.mostrar_crafting(p)
  print("\nItens que você pode criar:")
  local pode_fazer = false
  for nome, receita in pairs(Itens.receitas) do
    local pode = true
    for mat, qtd in pairs(receita.materiais) do
      if (p.inventario[mat] or 0) < qtd then pode = false break end
    end
    if pode then
      print("  " .. nome)
      pode_fazer = true
    end
  end
  if not pode_fazer then
    print("  Você não tem materiais suficientes para criar nada.")
    return
  end
  print("Digite o nome do item que deseja criar ou ENTER para voltar:")
  local escolha = io.read()
  if escolha ~= "" then
    Itens.craft(p, escolha)
  end
end

function Menu.mostrar_npcs(p)
  print("\nPessoas que você pode encontrar:")
  for key, npc in pairs(NPCs.data) do
    print("  " .. npc.nome)
  end
  print("Digite o nome do NPC para conversar ou ENTER para voltar:")
  local escolha = io.read()
  if escolha ~= "" then
    local npc = NPCs.data[escolha]
    if npc then
      NPCs.falar(npc, p)
    else
      print("Não há ninguém com esse nome aqui.")
    end
  end
end

function explorar(p)
  Eventos.aleatorio(p)
end

function Menu.jogo()
  Utils.clear()
  print("Bem-vindo ao RPG Lua - Uma aventura épica começa!")
  print("Digite seu nome:")
  local nome = io.read()
  print("\nEscolha sua classe:")
  for classe, dados in pairs(Classes.data) do
    print("- " .. classe .. ": " .. dados.descricao)
  end
  local classe
  while true do
    classe = io.read()
    if Classes.data[classe] then break end
    print("Classe inválida, tente novamente:")
  end

  local player = Personagem.novo(nome, classe)
  print("\nÓtima escolha, " .. nome .. " o " .. classe .. ". Boa sorte na sua jornada!")

  while true do
    print("\nO que deseja fazer agora?")
    print("1 - Ver status")
    print("2 - Ver inventário")
    print("3 - Ver perks")
    print("4 - Crafting")
    print("5 - Explorar")
    print("6 - Conversar com NPC")
    print("7 - Sair do jogo")
    local opcao = io.read()

    if opcao == "1" then
      Menu.mostrar_status(player)
    elseif opcao == "2" then
      Menu.mostrar_inventario(player)
    elseif opcao == "3" then
      Menu.mostrar_perks(player)
    elseif opcao == "4" then
      Menu.mostrar_crafting(player)
    elseif opcao == "5" then
      explorar(player)
      if player.hp <= 0 then
        print("\nVocê desmaiou durante a aventura... Fim de jogo.")
        break
      end
    elseif opcao == "6" then
      Menu.mostrar_npcs(player)
    elseif opcao == "7" then
      print("Obrigado por jogar! Até a próxima.")
      break
    else
      print("Opção inválida, tente novamente.")
    end
  end
end

print("Pressione ENTER para começar o jogo...")
io.read()
Menu.jogo()