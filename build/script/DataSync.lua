require("Json")
require("Lib")
require("Config")

local tbFunc = {}

function Query(jsonParam)
    local tbParam = JsonDecode(jsonParam)
    local func = tbFunc[tbParam.FuncName]
    local szMsg
    local bRet = false
    if func then
        szMsg, bRet, tbCustomData = func(tbParam)
    else
        szMsg = "invalid FuncName"
    end
    local tbResult = {
        code = bRet and 0 or -1,
        msg = szMsg,
    }
    if tbCustomData then
        for k, v in pairs(tbCustomData) do
            tbResult[k] = v 
        end
    end
    return JsonEncode(tbResult)
end

--------------------接口实现---------------------------------------
function tbFunc.GetLuaFile(tbParam)
    return "success", true,  { tbConfig = tbConfig }
end
