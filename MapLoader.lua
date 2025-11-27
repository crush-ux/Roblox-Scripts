-- [[ SMART GHOST LOADER V4 - AUTO DETECT SERVICE ]] --

local SecretMapID = 138225591825247 -- ID Map của bạn
local InsertService = game:GetService("InsertService")
local Players = game:GetService("Players")

-- === 1. HÀM DỌN DẸP SẠCH SẼ ===
local function CleanMap()
	print("🧹 Đang dọn dẹp map cũ...")
	
	-- Dọn Workspace
	for _, v in pairs(workspace:GetChildren()) do
		if not v:IsA("Terrain") and not v:IsA("Camera") and not Players:GetPlayerFromCharacter(v) then
			v:Destroy()
		end
	end
	workspace.Terrain:Clear()

	-- Dọn các Service khác (Trừ Loader này ra)
	local services = {
		"ReplicatedStorage", "ServerStorage", "ServerScriptService", 
		"Lighting", "StarterGui", "StarterPack"
	}
	
	for _, name in pairs(services) do
		local svc = game:GetService(name)
		for _, child in pairs(svc:GetChildren()) do
			if child ~= script then
				pcall(function() child:Destroy() end)
			end
		end
	end
	
	-- Xóa Script trong StarterPlayer (Phức tạp hơn xíu)
	pcall(function() game:GetService("StarterPlayer").StarterPlayerScripts:ClearAllChildren() end)
	pcall(function() game:GetService("StarterPlayer").StarterCharacterScripts:ClearAllChildren() end)

	-- Xóa GUI người chơi
	for _, p in pairs(Players:GetPlayers()) do
		if p:FindFirstChild("PlayerGui") then p.PlayerGui:ClearAllChildren() end
	end
end

-- === 2. HÀM CÀI ĐẶT THÔNG MINH ===
local function Install()
	CleanMap()
	print("📦 Đang tải Map...")

	local success, model = pcall(function() return InsertService:LoadAsset(SecretMapID) end)
	if not success or not model then warn("❌ Lỗi tải ID: " .. SecretMapID) return end

	local root = model:GetChildren()[1] or model
	
	print("➡️ Bắt đầu phân loại tài nguyên...")

	-- DUYỆT QUA TẤT CẢ CÁC FOLDER TRONG MODEL
	for _, folder in pairs(root:GetChildren()) do
		local folderName = folder.Name
		
		-- Kiểm tra xem tên folder có trùng với Service nào trong game không?
		-- Ví dụ: Folder tên "ServerScriptService" -> Tìm thấy Service -> OK
		local success, service = pcall(function() return game:GetService(folderName) end)

		if success and service then
			-- A. NẾU LÀ SERVICE (Lighting, ServerStorage, v.v...)
			print("   📂 Phát hiện Service: " .. folderName)
			
			for _, item in pairs(folder:GetChildren()) do
				-- Xử lý đặc biệt cho StarterGui (Copy cho cả người chơi)
				if folderName == "StarterGui" then
					item.Parent = service
					for _, plr in pairs(Players:GetPlayers()) do
						if plr:FindFirstChild("PlayerGui") then
							item:Clone().Parent = plr.PlayerGui
						end
					end
				-- Xử lý đặc biệt cho StarterPlayer (Vì nó có folder con)
				elseif folderName == "StarterPlayer" then
					-- Tìm 2 folder con bên trong nó
					local scripts = item:FindFirstChild("StarterPlayerScripts") or folder:FindFirstChild("StarterPlayerScripts")
					local chars = item:FindFirstChild("StarterCharacterScripts") or folder:FindFirstChild("StarterCharacterScripts")
					
					if item.Name == "StarterPlayerScripts" then
						item.Parent = game:GetService("StarterPlayer").StarterPlayerScripts
					elseif item.Name == "StarterCharacterScripts" then
						item.Parent = game:GetService("StarterPlayer").StarterCharacterScripts
					else
						-- Nếu là folder StarterPlayer to đùng
						for _, sub in pairs(item:GetChildren()) do
							if sub.Name == "StarterPlayerScripts" then
								for _, s in pairs(sub:GetChildren()) do s.Parent = game:GetService("StarterPlayer").StarterPlayerScripts end
							elseif sub.Name == "StarterCharacterScripts" then
								for _, c in pairs(sub:GetChildren()) do c.Parent = game:GetService("StarterPlayer").StarterCharacterScripts end
							end
						end
					end
				else
					-- Các Service bình thường khác (ServerStorage, ReplicatedStorage...)
					item.Parent = service
				end
				
				-- Bật script lên nếu bị tắt
				if item:IsA("Script") or item:IsA("LocalScript") then item.Disabled = false end
			end
			folder:Destroy() -- Xóa vỏ sau khi lấy ruột
			
		else
			-- B. NẾU KHÔNG PHẢI SERVICE -> NÓ LÀ MAP (WORKSPACE)
			print("   🌍 Phát hiện Map/Object: " .. folderName)
			folder.Parent = workspace
			if folder:IsA("Script") then folder.Disabled = false end
		end
	end
	
	-- Respawn lại cho chắc
	task.wait(1)
	for _, p in pairs(Players:GetPlayers()) do p:LoadCharacter() end
	print("✅ Cài đặt hoàn tất!")
end

task.spawn(Install)
