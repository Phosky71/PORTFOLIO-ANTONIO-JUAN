--TODO Añadir la posibilidad de que el usuario pueda elegir el nombre del pokemon

local version = memory.readword(0x14e)
local base_address
local party_address
local atkdef
local spespc
local pokemon_names = dofile("gen1Variables/pokemon_names.lua")
local max_party_size = 6 -- Tamaño máximo del equipo en Gen I

if version == 0xc1a2 or version == 0x36dc or version == 0xd5dd or version == 0x299c then
    print("RBGY JPN game detected")
    base_address = 0xd123
elseif version == 0xe691 or version == 0xa9d then
    print("Red/Blue USA detected")
    base_address = 0xd163
elseif version == 0x7c04 then
    print("Yellow USA detected")
    base_address = 0xd162
elseif version == 0xd289 or version == 0x9c5e or version == 0xdc5c or version == 0xbc2e or version == 0x4a38 or version == 0xd714 or version == 0xfc7a or version == 0xa456 then
    print("Red/Blue EUR detected")
    base_address = 0xd168
elseif version == 0x8f4e or version == 0xfb66 or version == 0x3756 or version == 0xc1b7 then
    print("Yellow EUR detected")
    base_address = 0xd167
else
    print(string.format("Unknown version, code: %4x", version))
    print("Script stopped")
    return
end

local size = memory.readbyte(base_address) - 1
local dv_addr = (base_address + 0x23) + size * 0x2C

function get_team_size()
    local count = 0
    for i = 0, max_party_size - 1 do
        local species = memory.readbyte(base_address + 0x08 + i * 0x2C)
        if species ~= 0 then
            count = count + 1
        else
            break -- Detenerse al encontrar un slot vacío
        end
    end
    return count
end

if get_team_size() >= max_party_size then
    print("El equipo principal está lleno. Script detenido.")
    return
else
    print(string.format("Tamaño del equipo: %d", get_team_size()))
end

function shiny(atkdef, spespc)
    if spespc == 0xAA then
        if atkdef == 0x2A or atkdef == 0x3A or atkdef == 0x6A or atkdef == 0x7A or atkdef == 0xAA or atkdef == 0xBA or atkdef == 0xEA or atkdef == 0xFA then
            return true
        else
            return false
        end
    else
        return false
    end
end

local stop_for_almost_perfect = false
local stop_for_perfect = true
local stop_for_custom_ivs = false
local custom_ivs = { atk = 0, def = 0, spe = 0, spc = 0 }

state = savestate.create()
savestate.save(state)

local reset_count = 0

while true do
    emu.frameadvance()
    savestate.save(state)
    i = 0
    while i < 20 do
        joypad.set(1, { A = true })
        vba.frameadvance()
        i = i + 1
    end
    atkdef = memory.readbyte(dv_addr)
    spespc = memory.readbyte(dv_addr + 1)

    local pokemon_name = "Ivs"
    ----todo
    ----En el condicional ha de ser que sea un pokemon inicial
    --if base_address == 0xd168  then
    --    local species_index = memory.readbyte(0xD169)
    --    print(memory.readbyte(0xD169))
    --    pokemon_name = pokemon_names[species_index] or "Unknown"
    ----elseif base_address == 0xd167 then
    ----    local species_index = memory.readbyte(0xD177) ¿0xD177?¿0xD1C7?¿0xD16F?
    ----    print(memory.readbyte(0xD177))
    ----    pokemon_name = pokemon_names[species_index] or "Unknown"
    --end

    reset_count = reset_count + 1
    local atk = math.floor(atkdef / 16)
    local def = atkdef % 16
    local spe = math.floor(spespc / 16)
    local spc = spespc % 16

    print(string.format("Reset: %d", reset_count))
    print(string.format("%s: (Atk: %d Def: %d Spe: %d Spc: %d)", pokemon_name, atk, def, spe, spc))

    if shiny(atkdef, spespc) then
        print("Shiny!!! Script stopped.")
        savestate.save(state)
        break
    elseif stop_for_perfect and atk == 15 and def == 15 and spe == 15 and spc == 15 then
        print("Perfect Pokémon!!! Script stopped.")
        savestate.save(state)
        break
    elseif stop_for_almost_perfect and atk == 13 and def == 13 and spe == 13 and spc == 14 then
        print("Almost perfect Pokémon!!! Script stopped.")
        savestate.save(state)
        break
    elseif stop_for_custom_ivs and atk == custom_ivs.atk and def == custom_ivs.def and spe == custom_ivs.spe and spc == custom_ivs.spc then
        print("Custom IVs Pokémon!!! Script stopped.")
        savestate.save(state)
        break
    else
        print("discarded")
        print("")
        savestate.load(state)
    end
end














--local version = memory.readword(0x14e)
--local base_address
--local party_address
--local atkdef
--local spespc
--local pokemon_names = dofile("gen1Variables/pokemon_names.lua")
--local max_party_size = 6 -- Tamaño máximo del equipo en Gen I
--
--if version == 0xc1a2 or version == 0x36dc or version == 0xd5dd or version == 0x299c then
--    print("RBGY JPN game detected")
--    base_address = 0xd123
--elseif version == 0xe691 or version == 0xa9d then
--    print("Red/Blue USA detected")
--    base_address = 0xd163
--elseif version == 0x7c04 then
--    print("Yellow USA detected")
--    base_address = 0xd162
--elseif version == 0xd289 or version == 0x9c5e or version == 0xdc5c or version == 0xbc2e or version == 0x4a38 or version == 0xd714 or version == 0xfc7a or version == 0xa456 then
--    print("Red/Blue EUR detected")
--    base_address = 0xd168
--elseif version == 0x8f4e or version == 0xfb66 or version == 0x3756 or version == 0xc1b7 then
--    print("Yellow EUR detected")
--    base_address = 0xd167
--else
--    print(string.format("Unknown version, code: %4x", version))
--    print("Script stopped")
--    return
--end
--
--local size = memory.readbyte(base_address) - 1
--local dv_addr = (base_address + 0x23) + size * 0x2C
--print(size)
--
--
--function shiny(atkdef, spespc)
--    if spespc == 0xAA then
--        if atkdef == 0x2A or atkdef == 0x3A or atkdef == 0x6A or atkdef == 0x7A or atkdef == 0xAA or atkdef == 0xBA or atkdef == 0xEA or atkdef == 0xFA then
--            return true
--        else
--            return false
--        end
--    else
--        return false
--    end
--end
--
--local stop_for_almost_perfect = true
--local stop_for_perfect = true
--local stop_for_custom_ivs = false
--local custom_ivs = { atk = 0, def = 0, spe = 0, spc = 0 }
--
--state = savestate.create()
--savestate.save(state)
--
--local reset_count = 0
--
--while true do
--    emu.frameadvance()
--    savestate.save(state)
--    i = 0
--    while i < 20 do
--        joypad.set(1, { A = true })
--        vba.frameadvance()
--        i = i + 1
--    end
--    atkdef = memory.readbyte(dv_addr)
--    spespc = memory.readbyte(dv_addr + 1)
--
--
--    local pokemon_name = "Ivs"
--    ----todo
--    ----En el condicional ha de ser que sea un pokemon inicial
--    --if base_address == 0xd168  then
--    --    local species_index = memory.readbyte(0xD169)
--    --    print(memory.readbyte(0xD169))
--    --    pokemon_name = pokemon_names[species_index] or "Unknown"
--    ----elseif base_address == 0xd167 then
--    ----    local species_index = memory.readbyte(0xD177) ¿0xD177?¿0xD1C7?¿0xD16F?
--    ----    print(memory.readbyte(0xD177))
--    ----    pokemon_name = pokemon_names[species_index] or "Unknown"
--    --end
--
--    reset_count = reset_count + 1
--    local atk = math.floor(atkdef / 16)
--    local def = atkdef % 16
--    local spe = math.floor(spespc / 16)
--    local spc = spespc % 16
--
--    print(string.format("Reset: %d", reset_count))
--    print(string.format("%s: (Atk: %d Def: %d Spe: %d Spc: %d)", pokemon_name, atk, def, spe, spc))
--
--    if shiny(atkdef, spespc) then
--        print("Shiny!!! Script stopped.")
--        savestate.save(state)
--        break
--    elseif stop_for_perfect and atk == 15 and def == 15 and spe == 15 and spc == 15 then
--        print("Perfect Pokémon!!! Script stopped.")
--        savestate.save(state)
--        break
--    elseif stop_for_almost_perfect and atk == 13 and def == 13 and spe == 13 and spc == 14 then
--        print("Almost perfect Pokémon!!! Script stopped.")
--        savestate.save(state)
--        break
--    elseif stop_for_custom_ivs and atk == custom_ivs.atk and def == custom_ivs.def and spe == custom_ivs.spe and spc == custom_ivs.spc then
--        print("Custom IVs Pokémon!!! Script stopped.")
--        savestate.save(state)
--        break
--    else
--        print("discarded")
--        print("")
--        savestate.load(state)
--    end
--end
