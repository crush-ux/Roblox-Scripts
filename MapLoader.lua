-- [[ SMART GHOST LOADER V8 - THE ANESTHESIA (GÂY MÊ) ]] --
-- Fix lỗi: Tắt toàn bộ Script trước khi xếp đồ

local SecretMapID = 78113293799796 -- ID Map của bạn
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

	-- [[ BƯỚC QUAN TRỌNG NHẤT: GÂY MÊ TOÀN BỘ ]] --
	-- Tắt script ngay khi nó còn đang ở dạng dữ liệu (chưa vào game)
	for _, desc in pairs(model:GetDescendants()) do
		if desc:IsA("Script") or desc:IsA("LocalScript") then
			desc.Disabled = true -- NGỦ ĐI CON!
		end
	end
	
	-- Giờ mới được phép ném vào Workspace để tháo dỡ
	model.Parent = workspace 
	
	local container = model
	if #model:GetChildren() == 1 and model:GetChildren()[1]:IsA("Model") then
		container = model:GetChildren()[1]
	end
	
	print("💤 Script đang ngủ. Bắt đầu tháo dỡ an toàn...")

	-- HÀM DI CHUYỂN & ĐÁNH THỨC
	local function MoveContents(folder, destination)
		for _, item in pairs(folder:GetChildren()) do
			-- Di chuyển
			if destination.Name == "StarterGui" then
				item.Parent = destination
				for _, p in pairs(Players:GetPlayers()) do
					if p:FindFirstChild("PlayerGui") then
						local clone = item:Clone()
						clone.Parent = p.PlayerGui
						-- Đánh thức LocalScript trong GUI
						for _, s in pairs(clone:GetDescendants()) do
							if s:IsA("LocalScript") then s.Disabled = false end
						end
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
			
			-- [[ ĐÁNH THỨC SCRIPT ]] --
			-- Chỉ bật lại sau khi nó đã nằm yên vị ở nhà mới
			if item:IsA("Script") or item:IsA("LocalScript") then
				item.Disabled = false 
			end
			-- Nếu bên trong item con còn script nữa (ví dụ script trong tool)
			for _, sub in pairs(item:GetDescendants()) do
				if sub:IsA("Script") or sub:IsA("LocalScript") then
					sub.Disabled = false
				end
			end
		end
	end

	-- [[ THỨ TỰ DI CHUYỂN ]] --
	
	-- 1. ƯU TIÊN: Module & ServerStorage (Để Script tỉnh dậy là thấy đồ ngay)
	local priority = {"ReplicatedStorage", "ServerStorage", "Lighting"}
	for _, name in pairs(priority) do
		local folder = container:FindFirstChild(name)
		if folder then
			local service = game:GetService(name)
			print("   📂 Chuyển: " .. name)
			MoveContents(folder, service)
			folder:Destroy()
		end
	end

	-- 2. THỨ YẾU: GUI, StarterPack
	local secondary = {"StarterGui", "StarterPack", "StarterPlayer"}
	for _, name in pairs(secondary) do
		local folder = container:FindFirstChild(name)
		if folder then
			local service = game:GetService(name)
			MoveContents(folder, service)
			folder:Destroy()
		end
	end

	-- 3. CUỐI CÙNG: SERVER SCRIPT SERVICE (ĐÁNH THỨC NÃO BỘ)
	local scriptFolder = container:FindFirstChild("ServerScriptService")
	if scriptFolder then
		print("   🧠 Đánh thức Server Scripts...")
		MoveContents(scriptFolder, game:GetService("ServerScriptService"))
		scriptFolder:Destroy()
	end
	
	-- 4. MAP & CÁC THỨ CÒN LẠI
	for _, child in pairs(container:GetChildren()) do
		print("   🌍 Map vào Workspace: " .. child.Name)
		child.Parent = workspace
		-- Bật lại script trong Map (nếu có)
		for _, s in pairs(child:GetDescendants()) do
			if s:IsA("Script") then s.Disabled = false end
		end
	end
	
	-- Dọn vỏ
	if container.Parent then container:Destroy() end
	if model.Parent then model:Destroy() end

	task.wait(1)
	print("🔄 Respawn người chơi...")
	for _, p in pairs(Players:GetPlayers()) do p:LoadCharacter() end
	print("✅ CÀI ĐẶT HOÀN TẤT V8")
end

task.spawn(Install)
