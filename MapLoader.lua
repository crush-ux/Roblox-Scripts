-- [[ SMART GHOST LOADER V6 - FINAL FIX ]] --

local SecretMapID = 138225591825247 -- ID Map của bạn
local InsertService = game:GetService("InsertService")
local Players = game:GetService("Players")

-- 1. HÀM DỌN DẸP
local function CleanMap()
	print("🧹 Đang dọn dẹp rác cũ...")
	for _, v in pairs(workspace:GetChildren()) do
		if not v:IsA("Terrain") and not v:IsA("Camera") and not Players:GetPlayerFromCharacter(v) then
			pcall(function() v:Destroy() end)
		end
	end
	workspace.Terrain:Clear()

	local services = {"ReplicatedStorage", "ServerStorage", "ServerScriptService", "Lighting", "StarterGui", "StarterPack"}
	for _, name in pairs(services) do
		for _, child in pairs(game:GetService(name):GetChildren()) do
			if child ~= script then pcall(function() child:Destroy() end) end
		end
	end
	
	-- Xóa GUI cũ
	for _, p in pairs(Players:GetPlayers()) do
		if p:FindFirstChild("PlayerGui") then p.PlayerGui:ClearAllChildren() end
	end
end

-- 2. HÀM CÀI ĐẶT
local function Install()
	CleanMap()
	print("📦 Đang tải Model...")

	local success, model = pcall(function() return InsertService:LoadAsset(SecretMapID) end)
	if not success or not model then warn("❌ Lỗi tải ID!") return end

	-- [[ FIX QUAN TRỌNG V6: XÁC ĐỊNH ĐÚNG CONTAINER ]] --
	-- Logic: Nếu Model tải về chỉ chứa đúng 1 Model con bên trong, thì lấy cái con đó.
	-- Còn nếu nó chứa nhiều folder (Lighting, ServerStorage...) thì lấy chính nó.
	local container = model
	if #model:GetChildren() == 1 and model:GetChildren()[1]:IsA("Model") then
		container = model:GetChildren()[1]
	end
	
	print("🔨 Đang tháo dỡ hộp: " .. container.Name .. " (Chứa " .. #container:GetChildren() .. " mục)")

	-- HÀM DI CHUYỂN
	local function MoveContents(folder, destination)
		for _, item in pairs(folder:GetChildren()) do
			if destination.Name == "StarterGui" then
				item.Parent = destination
				for _, p in pairs(Players:GetPlayers()) do
					if p:FindFirstChild("PlayerGui") then
						item:Clone().Parent = p.PlayerGui
					end
				end
			elseif destination.Name == "StarterPlayer" then
				if item.Name == "StarterPlayerScripts" then
					for _, s in pairs(item:GetChildren()) do s.Parent = destination.StarterPlayerScripts end
				elseif item.Name == "StarterCharacterScripts" then
					for _, c in pairs(item:GetChildren()) do c.Parent = destination.StarterCharacterScripts end
				end
			else
				item.Parent = destination
			end
			
			if item:IsA("Script") or item:IsA("LocalScript") then item.Disabled = false end
		end
	end

	-- [[ PHÂN LOẠI TOÀN BỘ ]] --
	-- Duyệt qua TẤT CẢ các folder (Lighting, ServerStorage, v.v...)
	for _, folder in pairs(container:GetChildren()) do
		local folderName = folder.Name
		local isService, service = pcall(function() return game:GetService(folderName) end)
		
		if isService and service then
			print("   📂 Chuyển nội dung vào: " .. folderName)
			MoveContents(folder, service)
			folder:Destroy() 
		else
			print("   🌍 Ném vào Workspace: " .. folderName) 
			folder.Parent = workspace
			if folder:IsA("Script") then folder.Disabled = false end
		end
	end
	
	-- Dọn dẹp cái vỏ hộp cuối cùng
	if container.Parent then 
		if container.Name ~= "Workspace" and container.Name ~= "Model" then 
			container.Parent = workspace 
		end
	end

	task.wait(1)
	print("🔄 Respawn người chơi...")
	for _, p in pairs(Players:GetPlayers()) do p:LoadCharacter() end
	print("✅ Cài đặt hoàn tất! (V6)")
end

task.spawn(Install)
