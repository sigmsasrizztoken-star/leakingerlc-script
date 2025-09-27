-- love from saif and leaking/dawg and 2doppler me and saif has talked and here is the full code love
local function program()
    local results = {}
    local seen = {}

    local function contains(tbl, val)
        for _, v in ipairs(tbl) do
            if v == val then
                return true
            end
        end
        return false
    end

    local function cleanId(id)
        return id:gsub('^rbxassetid://', ''):gsub('^rbxasset://', '')
    end

    local function extractAssetId(texture)
        if type(texture) ~= 'string' then
            return nil
        end
        local id = texture:match('rbxassetid://(%d+)')
        if id then
            return id
        end
        return texture:match('%d+') or texture
    end

    local function formatLiveryName(objName)
        local pos = objName:match('^CustomLivery_(.+)')
        if pos then
            pos = pos:gsub('%d+$', '')
            return pos
        end
        return objName
    end

    -- get the custom name the owner of the livery made it
    local function getVehicleName(vehicle)
        local success, result = pcall(function()
            return vehicle.CustomizationOptions.Texture.Value
        end)

        if success then
            return result
        else
            return 'Unknown'
        end
    end

    local function addUnique(name, id, category)
        if id then
            id = cleanId(id)
            local key = name .. '|' .. id
            if not seen[key] then
                seen[key] = true
                table.insert(results, category .. ': ' .. name .. ' → ' .. id)
            end
        end
    end

    -- deadssrizzler
    local function processLivery(vehicle)
        -- Skip Sheriff_Supervisor vehicle
        if vehicle.Name == 'Sheriff_Supervisor' then
            return
        end

        local vehicleName = getVehicleName(vehicle)

        local getc = function()
            return vehicle.Body.COLOR:GetChildren()
        end
        local success, c = pcall(getc)
        if not success then
            return
        end

        for _, val in ipairs(c) do
            if
                (val:IsA('Texture') or val:IsA('Decal'))
                and not contains({ 'Dirt', 'Snow', 'Weld' }, val.Name)
            then
                local assetId = extractAssetId(val.Texture)
                if assetId then
                    local position = formatLiveryName(val.Name)
                    addUnique(
                        vehicleName
                            .. ' ('
                            .. vehicle.Name
                            .. ' - '
                            .. position
                            .. ')',
                        assetId,
                        'Livery'
                    )
                end
            end
        end
    end

    local function scanUniformFolder(folder)
        if not folder then
            return
        end

        local custom = folder:FindFirstChild('CustomUniform')
        if custom then
            local pants = folder:FindFirstChild('Pants')
            local shirt = folder:FindFirstChild('Shirt')

            if pants and pants:IsA('Pants') and pants.PantsTemplate then
                addUnique(
                    folder.Name .. ' (Pants)',
                    pants.PantsTemplate,
                    'Uniform'
                )
            end
            if shirt and shirt:IsA('Shirt') and shirt.ShirtTemplate then
                addUnique(
                    folder.Name .. ' (Shirt)',
                    shirt.ShirtTemplate,
                    'Uniform'
                )
            end
        end

        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA('Folder') then
                scanUniformFolder(child)
            end
        end
    end

    -- process vehicles
    local vehiclesFolder = workspace:FindFirstChild('Vehicles')
    if vehiclesFolder then
        for _, vehicle in ipairs(vehiclesFolder:GetChildren()) do
            processLivery(vehicle)
        end
    else
        warn('Vehicles folder not found in workspace.')
    end

    -- process uniforms
    local uniformsRoot = game:GetService('ReplicatedStorage')
        :FindFirstChild('ReplicatedState')
    if uniformsRoot then
        uniformsRoot = uniformsRoot:FindFirstChild('Uniforms')
        if uniformsRoot then
            scanUniformFolder(uniformsRoot)
        else
            warn(
                'Uniforms folder not found in ReplicatedStorage.ReplicatedState.'
            )
        end
    end

    -- shit nigga
    local finalString = ''

    if #results > 0 then
        finalString = table.concat(results, '\n')
    else
        finalString = 'No asset IDs found'
    end

    print('Collected Asset IDs:\n' .. finalString)

    -- Copy to clipboard
    if #results > 0 then
        pcall(function()
            setclipboard(finalString)
        end)
        print('Output copied to clipboard!')
    else
        print('No asset IDs found to copy.')
    end

    return finalString
end

local success, result = pcall(program)

if success then
    print('success (based)')
else
    print('Error: ' .. result)
end
