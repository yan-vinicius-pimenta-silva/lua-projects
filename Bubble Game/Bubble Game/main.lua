-- Endless Runner Game in Lua with LOVE2D Framework

-- Global variables
local gameState = "menu" -- Can be "menu" or "playing"
local score = 0
local bubble = {x = 50, y = 300, radius = 20, dy = 0, onGround = true, jumpCount = 0}
local obstacles = {}
local obstacleSpawnTimer = 0
local groundLevel = 500 -- Reduced platform height
local gravity = 500
local jumpStrength = -300
local speed = 200
local maxJumps = 2 -- Allow up to two jumps (double jump)

-- LOVE2D Load function
function love.load()
    love.window.setTitle("Endless Runner - Bubble Adventure")
    love.window.setMode(800, 600)
    math.randomseed(os.time())
end

-- LOVE2D Update function
function love.update(dt)
    if gameState == "playing" then
        -- Update bubble position
        bubble.dy = bubble.dy + gravity * dt
        bubble.y = bubble.y + bubble.dy * dt

        -- Ensure bubble stays on the ground
        if bubble.y > groundLevel - bubble.radius then
            bubble.y = groundLevel - bubble.radius
            bubble.dy = 0
            bubble.onGround = true
            bubble.jumpCount = 0 -- Reset jump count when on ground
        end

        -- Update score
        score = score + speed * dt

        -- Spawn obstacles
        obstacleSpawnTimer = obstacleSpawnTimer - dt
        if obstacleSpawnTimer <= 0 then
            local obstacleHeight = math.random(30, 50)
            -- Add obstacles at the bottom
            table.insert(obstacles, {x = 800, y = groundLevel - obstacleHeight, width = 20, height = obstacleHeight})
            -- Add obstacles at the top
            table.insert(obstacles, {x = 800, y = 0, width = 20, height = obstacleHeight})
            obstacleSpawnTimer = 2 -- Spawn new obstacle every 2 seconds
        end

        -- Update obstacles
        for i, obstacle in ipairs(obstacles) do
            obstacle.x = obstacle.x - speed * dt
            if obstacle.x + obstacle.width < 0 then
                table.remove(obstacles, i)
            end

            -- Check collision with bubble
            if bubble.x + bubble.radius > obstacle.x and bubble.x - bubble.radius < obstacle.x + obstacle.width and
               bubble.y + bubble.radius > obstacle.y and bubble.y - bubble.radius < obstacle.y + obstacle.height then
                gameState = "menu" -- End game
            end
        end
    end
end

-- LOVE2D Draw function
function love.draw()
    if gameState == "menu" then
        love.graphics.printf("Press Enter to Play\nPress ESC to Exit", 0, 250, 800, "center")
        love.graphics.printf("Score: " .. math.floor(score), 0, 300, 800, "center")
    elseif gameState == "playing" then
        -- Draw ground
        love.graphics.setColor(0.5, 0.8, 0.5)
        love.graphics.rectangle("fill", 0, groundLevel, 800, 100) -- Reduced ground height

        -- Draw bubble
        love.graphics.setColor(0.2, 0.6, 1)
        love.graphics.circle("fill", bubble.x, bubble.y, bubble.radius)

        -- Draw obstacles
        love.graphics.setColor(1, 0.3, 0.3)
        for _, obstacle in ipairs(obstacles) do
            love.graphics.rectangle("fill", obstacle.x, obstacle.y, obstacle.width, obstacle.height)
        end

        -- Draw score
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Score: " .. math.floor(score), 10, 10)
    end
end

-- LOVE2D Key Pressed function
function love.keypressed(key)
    if key == "return" and gameState == "menu" then
        gameState = "playing"
        score = 0
        bubble.y = 300
        bubble.dy = 0
        obstacles = {}
    elseif key == "escape" then
        if gameState == "menu" then
            love.event.quit()
        else
            gameState = "menu"
        end
    elseif key == "space" and gameState == "playing" and bubble.jumpCount < maxJumps then
        bubble.dy = jumpStrength
        bubble.jumpCount = bubble.jumpCount + 1
        bubble.onGround = false
    end
end
