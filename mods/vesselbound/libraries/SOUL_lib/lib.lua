local SOUL_lib = {}

function SOUL_lib:getActionButtons(battler, btn_types)
    if battler.chara.id == "SOUL" then
        TableUtils.removeValue(btn_types, "fight")
    end
    return btn_types
end
return SOUL_lib