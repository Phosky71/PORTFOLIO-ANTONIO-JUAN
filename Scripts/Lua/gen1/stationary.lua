local version = memory.readword(0x14e)
local flag_addr = 0xc027
local base_address
local atkdef
local spespc

if version == 0xc1a2 or version == 0x36dc or version == 0xd5dd or version == 0x299c then
    print("RBGY JPN game detected")
    base_address = 0xcfd8
elseif version == 0xe691 or version == 0xa9d then
    print("Red/Blue USA detected")
    base_address = 0xcff1
elseif version == 0x7c04 then
    print("Yellow USA detected")
    base_address = 0xcff0
elseif version == 0xd289 or version == 0x9c5e or version == 0xdc5c or version == 0xbc2e or version == 0x4a38 or version == 0xd714 or version == 0xfc7a or version == 0xa456 then
    print("Red/Blue EUR detected")
    base_address = 0xcff6
elseif version == 0x8f4e or version == 0xfb66 or version == 0x3756 or version == 0xc1b7 then
    print("Yellow EUR detected")
    base_address = 0xcff5
else
    print(string.format("Unknown version, code: %4x", version))
    print("Script stopped")
    return
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
    joypad.set(1, {A=true})
    emu.frameadvance()

    atkdef = 0
    spespc = 0
    savestate.save(state)

    while memory.readbyte(flag_addr) ~= 0xf0 do
        joypad.set(1, {A=false})
        vba.frameadvance()
        atkdef = memory.readbyte(base_address)
        spespc = memory.readbyte(base_address + 1)
    end

    reset_count = reset_count + 1
    local atk = math.floor(atkdef / 16)
    local def = atkdef % 16
    local spe = math.floor(spespc / 16)
    local spc = spespc % 16

    if shiny(atkdef, spespc) then
        print(string.format("Reset: %d", reset_count))
        print("Shiny!!! Script stopped.")
        print(string.format("Atk: %d Def: %d Spe: %d Spc: %d", atk, def, spe, spc))
        savestate.save(state)
        break
    elseif stop_for_perfect and atk == 15 and def == 15 and spe == 15 and spc == 15 then
        print(string.format("Reset: %d", reset_count))
        print("Perfect Pokémon!!! Script stopped.")
        print(string.format("Atk: %d Def: %d Spe: %d Spc: %d", atk, def, spe, spc))
        savestate.save(state)
        break
    elseif stop_for_almost_perfect and atk == 13 and def == 13 and spe == 13 and spc == 14 then
        print(string.format("Reset: %d", reset_count))
        print("Almost perfect Pokémon!!! Script stopped.")
        print(string.format("Atk: %d Def: %d Spe: %d Spc: %d", atk, def, spe, spc))
        savestate.save(state)
        break
    elseif stop_for_custom_ivs and atk == custom_ivs.atk and def == custom_ivs.def and spe == custom_ivs.spe and spc == custom_ivs.spc then
        print(string.format("Reset: %d", reset_count))
        print("Custom IVs Pokémon!!! Script stopped.")
        print(string.format("Atk: %d Def: %d Spe: %d Spc: %d", atk, def, spe, spc))
        savestate.save(state)
        break
    else
        print(string.format("Reset: %d", reset_count))
        print(string.format("Discarded - Atk: %d Def: %d Spe: %d Spc: %d", atk, def, spe, spc))
        savestate.load(state)
    end
end