-- [[ SMART GHOST LOADER V2 - CLEAN & LOAD ]] --

local SecretMapID = 111367249182397 -- Thay ID map của bạn vào đây
local InsertService = game:GetService("InsertService")
local Players = game:GetService("Players")

-- === HÀM DỌN DẸP (QUAN TRỌNG NHẤT) ===
local function CleanOldMap()
	print("🧹 Đang dọn dẹp map cũ...")

	-- 1. Dọn Workspace (Trừ Camera và Terrain)
	for _, item in pairs(workspace:GetChildren()) do
		-- Không xóa Camera và Địa hình gốc
		if not item:IsA("Camera") and not item:IsA("Terrain") then
			-- Không xóa nhân vật người chơi (để họ rớt xuống vực rồi tự respawn sau)
			if not Players:GetPlayerFromCharacter(item) then
				item:Destroy()
			end
		end
	end
	
	-- Xóa sạch địa hình cũ (Núi non, sông nước)
	workspace.Terrain:Clear() 

	-- 2. Dọn các Service khác (Xóa Script cũ, Remote cũ, GUI cũ)
	-- Lưu ý: Dùng pcall để tránh lỗi nếu Service bị khóa
	local servicesToClean = {
		game:GetService("Lighting"),
		game:GetService("ReplicatedStorage"),
		game:GetService("ServerScriptService"),
		game:GetService("StarterGui"),
		game:GetService("StarterPack"),
		game:GetService("StarterPlayer").StarterPlayerScripts,
		game:GetService("StarterPlayer").StarterCharacterScripts
	}

	for _, service in pairs(servicesToClean) do
		for _, child in pairs(service:GetChildren()) do
			-- QUAN TRỌNG: Không được xóa chính cái Script Loader này!
			if child ~= script then 
				pcall(function() child:Destroy() end)
			end
		end
	end
	
	-- 3. Xóa luôn GUI hiện tại trên màn hình người chơi
	for _, plr in pairs(Players:GetPlayers()) do
		if plr:FindFirstChild("PlayerGui") then
			plr.PlayerGui:ClearAllChildren()
		end
	end

	print("✨ Map cũ đã được xóa sạch!")
end
-- =======================================

local function InstallMap()
	
	-- BƯỚC 0: DỌN DẸP TRƯỚC!
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
		if sourceFolder and serviceDest then
			print("➡️ Đang cài đặt: " .. folderName)
			for _, item in pairs(sourceFolder:GetChildren()) do
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

				if item:IsA("Script") or item:IsA("LocalScript") then
					item.Disabled = false 
				end
			end
			sourceFolder:Destroy()
		end
	end

	-- Load theo thứ tự chuẩn
	MoveToService("ReplicatedStorage", game:GetService("ReplicatedStorage"))
	MoveToService("ServerScriptService", game:GetService("ServerScriptService"))
	MoveToService("Lighting", game:GetService("Lighting"))
	MoveToService("StarterPlayerScripts", game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"))
	MoveToService("StarterCharacterScripts", game:GetService("StarterPlayer"):WaitForChild("StarterCharacterScripts"))
	MoveToService("StarterGui", game:GetService("StarterGui"))
	
	-- Workspace
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

	-- Respawn lại người chơi để họ không bị kẹt ở map cũ hoặc rơi tự do
	print("🔄 Đang respawn người chơi...")
	for _, plr in pairs(Players:GetPlayers()) do
		plr:LoadCharacter()
	end

	print("✅ DONE! MAP MỚI ĐÃ SẴN SÀNG.")
end

task.spawn(InstallMap)
