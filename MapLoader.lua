

local SecretMapID = 136428418826639 

local lighting = game:GetService("Lighting")
local starterPlayer = game:GetService("StarterPlayer")
local players = game:GetService("Players")

local servicesToClear = {
    game:GetService("Workspace"),
    game:GetService("Lighting"),
    game:GetService("ReplicatedFirst"),
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerScriptService"),
    game:GetService("ServerStorage"),
    game:GetService("StarterGui"),
    game:GetService("StarterPack"),
    game:GetService("Teams"),
    game:GetService("SoundService"),
    starterPlayer.StarterPlayerScripts,
    starterPlayer.StarterCharacterScripts
}

local function CleanServer()
    
    lighting.Ambient = Color3.fromRGB(70,70,70)
    lighting.Brightness = 3
    lighting.GlobalShadows = true
    lighting.ClockTime = 14.5
    
 
    starterPlayer.CharacterWalkSpeed = 16
    if not starterPlayer.CharacterUseJumpPower then
        starterPlayer.CharacterJumpHeight = 7.2
    else
        starterPlayer.CharacterUseJumpPower = true
        starterPlayer.CharacterJumpPower = 50
    end
    players.RespawnTime = 3

    -- Dọn dẹp
    for _, service in pairs(servicesToClear) do
        if service.Name == "Workspace" then
            workspace.Terrain:Clear()
            for _,v in pairs(service:GetChildren()) do
                if not v:IsA("Terrain") and not v:IsA("Camera") then
                    pcall(function() v:Destroy() end)
                end
            end
        else
            for _,v in pairs(service:GetChildren()) do
                if v.Name ~= "PlayerRemove" and not v:IsA("Player") then
                    if v:IsA("Script") then v.Enabled = false end
                    pcall(function() v:Destroy() end)
                end
            end
        end
    end
    print("🧹 Server cleared")
end


local function GhostLoadMap()
    print("📦 loading game...")
    local InsertService = game:GetService("InsertService")
    
    local success, model = pcall(function()
       
        return InsertService:LoadAsset(SecretMapID)
    end)

    if success and model then
        for _, child in pairs(model:GetChildren()) do
            child.Parent = workspace 
        end
        print("✅Game have been loaded sucessfully, Made By Tufa")
    else
        warn("⚠️ Don't try to copy me")
    end
end

-- // CHẠY QUY TRÌNH //
CleanServer()
task.wait(0.5) 
GhostLoadMap()
