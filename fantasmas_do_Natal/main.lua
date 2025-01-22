-- Configurações da janela
function love.load()
    love.window.setFullscreen(true)
    larguraTela, alturaTela = love.graphics.getDimensions()

    -- Ocultar o cursor padrão do mouse
    love.mouse.setVisible(false)

    -- Carregar músicas
    musicaMenu = love.audio.newSource("assets/musica-natal.mp3", "stream")
    musicaPapaiNoel = love.audio.newSource("assets/papai-noel.mp3", "stream")

    -- Tocar música inicial
    musicaMenu:setLooping(true)
    musicaMenu:play()

    -- Carregar sprites
    sprites = {
        chao = love.graphics.newImage("assets/chao.png"),
        espada = love.graphics.newImage("assets/papai-noel1.png"),
        fantasma = love.graphics.newImage("assets/fantasma.png")
    }

    -- Configurar área da árvore central na imagem do chão
    arvore = {
        largura = 495,
        altura = 527,
        x = larguraTela / 2 - 495 / 2, -- Centraliza a árvore na tela
        y = alturaTela / 2 - 527 / 2, -- Centraliza a árvore na tela
        vida = 5
    }

    espada = {
        x = larguraTela / 2,
        y = alturaTela / 2,
        largura = sprites.espada:getWidth() * 2, -- Usando o tamanho atual da espada
        altura = sprites.espada:getHeight() * 2
    }

    fantasmas = {}
    tempoSpawn = 2
    tempoDecorrido = 0
    tempoJogo = 0 -- Tempo do jogo
    score = 0 -- Inicializar o score
    maxFantasmas = 15 -- Limite de fantasmas na tela

    jogoAtivo = true
    estadoMenu = "inicio" -- "inicio", "gameover", "vitoria"
end

-- Função para spawnar fantasmas
function spawnFantasma()
    if #fantasmas >= maxFantasmas then
        return -- Não cria novos fantasmas se o limite for atingido
    end

    local lado = love.math.random(1, 4)
    local velocidade = love.math.random(100, 250)
    local fantasma = {
        x = 0,
        y = 0,
        largura = sprites.fantasma:getWidth() * 3.5,
        altura = sprites.fantasma:getHeight() * 3.5,
        velocidade = velocidade
    }

    if lado == 1 then
        fantasma.x = love.math.random(0, larguraTela)
        fantasma.y = 0
    elseif lado == 2 then
        fantasma.x = love.math.random(0, larguraTela)
        fantasma.y = alturaTela
    elseif lado == 3 then
        fantasma.x = 0
        fantasma.y = love.math.random(0, alturaTela)
    elseif lado == 4 then
        fantasma.x = larguraTela
        fantasma.y = love.math.random(0, alturaTela)
    end

    table.insert(fantasmas, fantasma)
end

-- Atualização do jogo
function love.update(dt)
    if estadoMenu == "inicio" or estadoMenu == "gameover" or estadoMenu == "vitoria" then
        return
    end

    if not jogoAtivo then
        return
    end

    tempoJogo = tempoJogo + dt

    -- Parar música aos 56 segundos
    if tempoJogo >= 56 then
        musicaMenu:stop()
    end

    -- Reduzir tempo de spawn gradualmente
    tempoSpawn = math.max(0.5, 2 - (tempoJogo / 30))

    espada.x, espada.y = love.mouse.getPosition()

    -- Atualizar fantasmas
    for i = #fantasmas, 1, -1 do
        local fantasma = fantasmas[i]
        local dx = arvore.x + arvore.largura / 2 - fantasma.x
        local dy = arvore.y + arvore.altura / 2 - fantasma.y
        local dist = math.sqrt(dx^2 + dy^2)

        fantasma.x = fantasma.x + (dx / dist) * fantasma.velocidade * dt
        fantasma.y = fantasma.y + (dy / dist) * fantasma.velocidade * dt

        -- Verificar colisão com a árvore
        if fantasma.x < arvore.x + arvore.largura and
           fantasma.x + fantasma.largura > arvore.x and
           fantasma.y < arvore.y + arvore.altura and
           fantasma.y + fantasma.altura > arvore.y then
            arvore.vida = arvore.vida - 1
            table.remove(fantasmas, i)

            if arvore.vida <= 0 then
                estadoMenu = "gameover"
                jogoAtivo = false
            end
        end
    end

    -- Spawn de fantasmas
    tempoDecorrido = tempoDecorrido + dt
    if tempoDecorrido >= tempoSpawn then
        spawnFantasma()
        tempoDecorrido = 0
    end

    -- Condição de vitória
    if tempoJogo >= 60 then
        if arvore.vida > 0 then
            estadoMenu = "vitoria"
            musicaMenu:stop()
            musicaPapaiNoel:play()
        end
    end
end

-- Renderizar elementos na tela
function love.draw()
    if estadoMenu == "inicio" then
        love.graphics.printf("Os Fantasmas do Natal\nPressione ENTER para Jogar\nProteja a árvore de Natal até à meia-noite de Natal!", 0, alturaTela / 2 - 50, larguraTela, "center")
        return
    elseif estadoMenu == "gameover" then
        love.graphics.printf("Game Over\nScore: " .. score .. "\nPressione ENTER para Jogar Novamente", 0, alturaTela / 2 - 50, larguraTela, "center")
        return
    elseif estadoMenu == "vitoria" then
        love.graphics.printf("Parabéns! Você conseguiu!\nDaniel e Yan desejam um Feliz Natal a todos os nossos companheiros da GRAFHO!", 0, alturaTela / 2 - 50, larguraTela, "center")
        return
    end

    if not jogoAtivo then
        love.graphics.printf("PAUSE", 0, alturaTela / 2 - 50, larguraTela, "center")
    end

    -- Renderizar o chão com árvore central
    love.graphics.draw(sprites.chao, 0, 0, 0, larguraTela / sprites.chao:getWidth(), alturaTela / sprites.chao:getHeight())

    -- Renderizar barra de vida da árvore
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", arvore.x, arvore.y - 20, arvore.largura * (arvore.vida / 5), 10)
    love.graphics.setColor(1, 1, 1)

    love.graphics.draw(sprites.espada, espada.x - espada.largura / 2, espada.y - espada.altura / 2)

    for _, fantasma in ipairs(fantasmas) do
        love.graphics.draw(sprites.fantasma, fantasma.x, fantasma.y)
    end

    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("Tempo: " .. math.ceil(60 - tempoJogo), larguraTela / 2 - 50, 10)
end

function love.mousepressed(x, y, button)
    if button == 1 and jogoAtivo then
        for i = #fantasmas, 1, -1 do
            local fantasma = fantasmas[i]
            if x > fantasma.x and x < fantasma.x + fantasma.largura and y > fantasma.y and y < fantasma.y + fantasma.altura then
                table.remove(fantasmas, i)
                score = score + 10
            end
        end
    end
end

function love.keypressed(key)
    if key == "return" then
        if estadoMenu == "inicio" or estadoMenu == "gameover" or estadoMenu == "vitoria" then
            estadoMenu = "jogo"
            arvore.vida = 5
            fantasmas = {}
            tempoDecorrido = 0
            tempoJogo = 0
            jogoAtivo = true
            score = 0
            musicaMenu:play()
        end
    elseif key == "escape" then
        love.event.quit()
    elseif key == "space" then
        jogoAtivo = not jogoAtivo
    end
end
