-- [[ SMART GHOST LOADER V3 - FIXED CRASH ]] --

local SecretMapID = 137867566503870 -- ID Map của bạn
local InsertService = game:GetService("InsertService")
local Players = game:GetService("Players")

-- === HÀM DỌN DẸP ===
local function CleanOldMap()
	print("🧹 Đang dọn dẹp map cũ...")

	-- 1. Dọn Workspace
	for _, item in pairs(workspace:GetChildren()) do
		if not item:IsA("Camera") and not item:IsA("Terrain") then
			if not Players:GetPlayerFromCharacter(item) then
				item:Destroy()
			end
		end
	end
	workspace.Terrain:Clear() 

	-- 2. Dọn các Service khác
	local servicesToClean = {
		game:GetService("Lighting"),
		game:GetService("ReplicatedStorage"),
		game:GetService("ServerStorage"), -- [MỚI] Thêm cái này để xóa Map cũ trong kho
		game:GetService("ServerScriptService"),
		game:GetService("StarterGui"),
		game:GetService("StarterPack"),
		game:GetService("StarterPlayer").StarterPlayerScripts,
		game:GetService("StarterPlayer").StarterCharacterScripts
	}

	for _, service in pairs(servicesToClean) do
		for _, child in pairs(service:GetChildren()) do
			if child ~= script then -- Không xóa chính bản thân loader
				pcall(function() child:Destroy() end)
			end
		end
	end
	
	-- 3. Xóa GUI người chơi
	for _, plr in pairs(Players:GetPlayers()) do
		if plr:FindFirstChild("PlayerGui") then
			plr.PlayerGui:ClearAllChildren()
		end
	end

	print("✨ Map cũ đã được xóa sạch!")
end
-- =======================================

local function InstallMap()
	
	-- BƯỚC 0: DỌN DẸP
	CleanOldMap()
	
	print("📦 Đang tải Map mới từ Cloud...")
	local success, model = pcall(function()
		return InsertService:LoadAsset(SecretMapID)
	end)

	if not success or not model then
		warn("❌ LỖI TẢI ASSET! Kiểm tra lại ID hoặc Quyền sở hữu.")
		return
	end

	local root = model:GetChildren()[1] or model

	local function MoveToService(folderName, serviceDest)
		local sourceFolder = root:FindFirstChild(folderName)
		-- Kiểm tra xem trong Model có folder đó không, và Service đích có tồn tại không
		if sourceFolder and serviceDest then
			print("➡️ Đang cài đặt: " .. folderName)
			for _, item in pairs(sourceFolder:GetChildren()) do
				-- Xử lý đặc biệt cho GUI
				if folderName == "StarterGui" then
					item.Parent = serviceDest
					for _, player in pairs(Players:GetPlayers()) do
						if player:FindFirstChild("PlayerGui") then
							item:Clone().Parent = player.PlayerGui
						end
					end
				else
					item.Parent = serviceDest
				end

				-- Kích hoạt script
				if item:IsA("Script") or item:IsA("LocalScript") then
					item.Disabled = false 
				end
			end
			sourceFolder:Destroy()
		end
	end

	-- === THỨ TỰ LOAD (QUAN TRỌNG ĐỂ KHÔNG BỊ LỖI) ===
	
	-- 1. Load Kho Chứa Đồ trước (Maps, Models, Remote...)
	-- Đây là dòng bạn bị thiếu ở script cũ:
	MoveToService("ServerStorage", game:GetService("ServerStorage")) 
	MoveToService("ReplicatedStorage", game:GetService("ReplicatedStorage"))
	MoveToService("Lighting", game:GetService("Lighting"))
	
	-- 2. Load GUI và Player Scripts
	MoveToService("StarterGui", game:GetService("StarterGui"))
	MoveToService("StarterPack", game:GetService("StarterPack"))
	MoveToService("StarterPlayerScripts", game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"))
	MoveToService("StarterCharacterScripts", game:GetService("StarterPlayer"):WaitForChild("StarterCharacterScripts"))
	
	-- 3. Load Map (Workspace)
	print("➡️ Đang cài đặt Map (Workspace)...")
	if root.Name == "Workspace" then
		for _, item in pairs(root:GetChildren()) do
			item.Parent = workspace
		end
	else
		for _, item in pairs(root:GetChildren()) do
			item.Parent = workspace
		end
	end

	-- 4. CUỐI CÙNG MỚI LOAD SERVER SCRIPT (CÁI NÃO)
	-- Để đảm bảo lúc Não chạy thì Maps trong ServerStorage đã có sẵn rồi.
	MoveToService("ServerScriptService", game:GetService("ServerScriptService"))

	-- Respawn
	print("🔄 Đang respawn người chơi...")
	for _, plr in pairs(Players:GetPlayers()) do
		plr:LoadCharacter()
	end

	print("✅ DONE! MAP MỚI ĐÃ SẴN SÀNG.")
end

task.spawn(InstallMap)
