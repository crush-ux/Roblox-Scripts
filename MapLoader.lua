-- [[ SMART GHOST LOADER ]] --

local SecretMapID = 111367249182397 

local InsertService = game:GetService("InsertService")

local function InstallMap()
    print("📦 loading")

    -- 1. Tải Model về (Dùng LoadAsset xịn hơn GetObjects)
    local success, model = pcall(function()
        return InsertService:LoadAsset(SecretMapID)
    end)

    if not success or not model then
        warn("❌ error, please check id.")
        return
    end

    -- 2. Bắt đầu phân loại và lắp ráp
    local root = model:GetChildren()[1] -- Lấy cái Model chính
    if not root then 
        -- Trường hợp Model bị rỗng hoặc cấu trúc lạ
        root = model 
    end

    -- Hàm di chuyển đồ đạc
    local function MoveToService(folderName, serviceName)
        local sourceFolder = root:FindFirstChild(folderName) -- Tìm folder tên đó
        local targetService = game:GetService(serviceName)   -- Tìm service đích

        if sourceFolder and targetService then
            print("➡️ installingt: " .. folderName)
            for _, item in pairs(sourceFolder:GetChildren()) do
                item.Parent = targetService -- Di chuyển từng món sang
                
                -- Kích hoạt Script nếu có (Quan trọng!)
                if item:IsA("Script") or item:IsA("LocalScript") then
                    item.Disabled = false 
                end
            end
            sourceFolder:Destroy() -- Xóa cái vỏ folder đi cho gọn
        end
    end

    -- 3. Gọi hàm di chuyển cho từng nơi
    -- Cấu trúc: MoveToService("Tên Folder Trong Model", "Tên Service Trong Game")
    
    MoveToService("Lighting", "Lighting")
    MoveToService("ReplicatedStorage", "ReplicatedStorage")
    MoveToService("ServerScriptService", "ServerScriptService")
    MoveToService("StarterGui", "StarterGui")
    MoveToService("StarterPack", "StarterPack")
    MoveToService("StarterPlayerScripts", "StarterPlayer") -- Lưu ý: Cái này phải xử lý khéo
    
    -- 4. Những gì còn sót lại (Thường là Map/Part) thì vứt vào Workspace
    print("➡️ loading workspace")
    
    -- Nếu root là Model thì ném cả Model vào Workspace
    -- Nếu root là Folder Workspace thì ném ruột nó ra
    if root.Name == "Workspace" then
        for _, item in pairs(root:GetChildren()) do
            item.Parent = workspace
        end
    else
        root.Parent = workspace
    end

    -- 5. Kích hoạt lại toàn bộ Script (Fix lỗi script không chạy)
    for _, desc in pairs(workspace:GetDescendants()) do
        if desc:IsA("Script") and desc.Disabled == true then
            desc.Disabled = false
        end
    end

    print("✅ LOADED, MADE BY TUFA")
end

task.spawn(InstallMap)
