-- [[ SMART GHOST LOADER V5 - THE UNPACKER ]] --
-- Fix lỗi: Script bị kẹt trong Workspace.Model

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

-- 2. HÀM CÀI ĐẶT & THÁO DỠ
local function Install()
	CleanMap()
	print("📦 Đang tải Model...")

	local success, model = pcall(function() return InsertService:LoadAsset(SecretMapID) end)
	if not success or not model then warn("❌ Lỗi tải ID!") return end

	-- Lấy cái vỏ hộp bên ngoài
	local container = model:GetChildren()[1] or model
	print("🔨 Đang tháo dỡ hộp: " .. container.Name)

	-- HÀM DI CHUYỂN THÔNG MINH
	local function MoveContents(folder, destination)
		for _, item in pairs(folder:GetChildren()) do
			-- Xử lý riêng cho GUI (Copy cho cả người đang chơi)
			if destination.Name == "StarterGui" then
				item.Parent = destination
				for _, p in pairs(Players:GetPlayers()) do
					if p:FindFirstChild("PlayerGui") then
						item:Clone().Parent = p.PlayerGui
					end
				end
			-- Xử lý riêng cho StarterPlayer
			elseif destination.Name == "StarterPlayer" then
				if item.Name == "StarterPlayerScripts" then
					for _, s in pairs(item:GetChildren()) do s.Parent = destination.StarterPlayerScripts end
				elseif item.Name == "StarterCharacterScripts" then
					for _, c in pairs(item:GetChildren()) do c.Parent = destination.StarterCharacterScripts end
				end
			else
				-- Các Service khác cứ ném thẳng vào
				item.Parent = destination
			end
			
			-- Bật script lên
			if item:IsA("Script") or item:IsA("LocalScript") then item.Disabled = false end
		end
	end

	-- [[ QUAN TRỌNG: PHÂN LOẠI ĐỒ ĐẠC ]] --
	-- Duyệt qua từng folder bên trong cái hộp Model
	for _, folder in pairs(container:GetChildren()) do
		local serviceName = folder.Name
		
		-- Kiểm tra xem tên folder có trùng với Service game không
		local isService, service = pcall(function() return game:GetService(serviceName) end)
		
		if isService and service then
			print("   📂 Chuyển nội dung vào: " .. serviceName)
			MoveContents(folder, service)
			folder:Destroy() -- Xóa cái vỏ folder đi
		else
			-- Nếu không phải Service (ví dụ Map, Part...) thì ném vào Workspace
			print("   🌍 Ném vào Workspace: " .. folderName)
			folder.Parent = workspace
			-- Nếu chính nó là Script thì bật lên
			if folder:IsA("Script") then folder.Disabled = false end
		end
	end
	
	-- Nếu cái vỏ container ban đầu là Map thì ném nó ra Workspace luôn
	if container.Parent then -- Nếu nó chưa bị xóa
		if container.Name ~= "Workspace" and container.Name ~= "Model" then 
			container.Parent = workspace 
		end
	end

	-- Respawn
	task.wait(1)
	print("🔄 Respawn người chơi...")
	for _, p in pairs(Players:GetPlayers()) do p:LoadCharacter() end
	print("✅ Cài đặt hoàn tất! Hết lỗi đường dẫn.")
end

task.spawn(Install)
