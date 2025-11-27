-- [[ SMART GHOST LOADER V7 - THE FREEZER ]] --
-- Fix lỗi: Script chạy trước khi kịp xếp đồ

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

	-- [[ CHIẾN THUẬT ĐÓNG BĂNG (QUAN TRỌNG NHẤT) ]] --
	-- Nhét ngay vào ServerStorage để Script KHÔNG ĐƯỢC CHẠY lung tung
	model.Parent = game:GetService("ServerStorage") 
	
	-- Xác định cái vỏ hộp
	local container = model
	if #model:GetChildren() == 1 and model:GetChildren()[1]:IsA("Model") then
		container = model:GetChildren()[1]
	end
	
	print("❄️ Đã đóng băng tại ServerStorage. Bắt đầu tháo dỡ...")

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
			
			-- Bật lại script (nếu nó bị tắt)
			if item:IsA("Script") or item:IsA("LocalScript") then item.Disabled = false end
		end
	end

	-- [[ BƯỚC 1: CHUYỂN MODULE & ĐỒ ĐẠC TRƯỚC ]] --
	-- Để đảm bảo khi Script chạy thì đồ đạc đã có sẵn
	local priority = {"ReplicatedStorage", "ServerStorage", "Lighting", "Workspace"}
	
	for _, name in pairs(priority) do
		local folder = container:FindFirstChild(name)
		if folder then
			local service = game:GetService(name)
			print("   📂 Chuyển: " .. name)
			MoveContents(folder, service)
			folder:Destroy()
		end
	end

	-- [[ BƯỚC 2: CHUYỂN GUI & STARTER PLAYER ]] --
	local secondary = {"StarterGui", "StarterPack", "StarterPlayer"}
	for _, name in pairs(secondary) do
		local folder = container:FindFirstChild(name)
		if folder then
			local service = game:GetService(name)
			MoveContents(folder, service)
			folder:Destroy()
		end
	end

	-- [[ BƯỚC 3: CUỐI CÙNG MỚI THẢ SCRIPT RA (GIẢI BĂNG) ]] --
	local scriptFolder = container:FindFirstChild("ServerScriptService")
	if scriptFolder then
		print("   🧠 Kích hoạt Server Scripts...")
		MoveContents(scriptFolder, game:GetService("ServerScriptService"))
		scriptFolder:Destroy()
	end
	
	-- Dọn rác còn sót lại (thường là Map nằm lẻ tẻ)
	for _, child in pairs(container:GetChildren()) do
		print("   🌍 Ném phần còn lại vào Workspace: " .. child.Name)
		child.Parent = workspace
	end
	
	-- Xóa vỏ hộp
	if container.Parent then container:Destroy() end
	if model.Parent then model:Destroy() end

	task.wait(1)
	print("🔄 Respawn người chơi...")
	for _, p in pairs(Players:GetPlayers()) do p:LoadCharacter() end
	print("✅ CÀI ĐẶT HOÀN TẤT V7 (NO ERROR)")
end

task.spawn
