require("Json")
require("Lib")
require("Config")

tbAdminFunc = {}
Administration = {}

function Admin(jsonParam)
    local tbParam = JsonDecode(jsonParam)
    local func = tbAdminFunc[tbParam.FuncName]
    local szMsg
    local bRet = false
    if func then
        szMsg, bRet, tbCustomData = func(tbParam)
    else
        szMsg = "invalid admin FuncName"
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
-- 登录 {FuncName = "Login"}
function tbAdminFunc.Login(tbParam)
    if tbParam.Password ~= tbConfig.szAdminPassword then
        return "failed, incorrect password", false
    end
    return "success", true
end

-- 登出 {FuncName = "Logout"}
function tbAdminFunc.Logout(tbParam)
    return "success", true
end

-- 重置 {FuncName = "DoReset"}
function tbAdminFunc.DoReset(tbParam)
    local runtime = GetTableRuntime()

    runtime.bPlaying = false
    runtime.nCurYear = 0
    runtime.nCurSeason = 0

    runtime.nGamerCount = 0
    runtime.tbLoginAccount = {}
    runtime.tbUser = {}
    runtime.tbManpowerInMarket = {0, 0, 0, 0, 0}
    runtime.tbCategoryInfo = {}
    return "success", true
end

function tbAdminFunc.SetConfig(tbParam)
    if tbParam.Key == nil or tbParam.Value == nil then
        return "failed, need Key and Value", false
    end
    if tbConfig[tbParam.Key] == nil then
        return "failed, Key:".. tbParam.Key .. "not exist", false
    end
    local old = tbConfig[tbParam.Key]
    if old ~= tbParam.Value then
        tbConfig[tbParam.Key] = tbParam.Value
        print("tbConfig." .. tbParam.Key, old, "->", tbConfig[tbParam.Key])
        tbConfig.nDataVersion = tbConfig.nDataVersion + 1
    end
    return "success", true
end

function tbAdminFunc.SetProductConfig(tbParam)
    if tbParam.Key == nil or tbParam.Value == nil or tbParam.Category == nil then
        return "failed, need Key , Value and Category", false
    end
    local info = tbConfig.tbProductCategory[tbParam.Category]
    if info == nil or info[tbParam.Key] == nil then
        return "failed, Category:" .. tbParam.Category .. " Key:".. tbParam.Key .. "not exist", false
    end
    local old = info[tbParam.Key]
    if old ~= tbParam.Value then
        info[tbParam.Key] = tbParam.Value
        print("tbConfig.tbProductCategory[" .. tbParam.Category .. "] Key:" ..tbParam.Key, old, "->", info[tbParam.Key])
        tbConfig.nDataVersion = tbConfig.nDataVersion + 1
    end
    return "success", true
end

function tbAdminFunc.DoStart(tbParam)
    local runtime = GetTableRuntime()
    if runtime.bPlaying then
        return "failed, already started", false
    end
    if runtime.nGamerCount < 1 and not tbConfig.bDebug then
        return "failed, no gamer", false
    end

    math.randomseed(os.time())
    runtime.bPlaying = true
    runtime.nCurYear = tbParam.Year or 1
    runtime.nCurSeason = 0

    for userName, tbLoginAccountInfo in pairs(runtime.tbLoginAccount) do
        Administration:NewUser(userName)
    end

    SandTableStart()

    return "success", true
end

function tbAdminFunc.RecoverData(tbParam)
    local tbData, szError = DataStorage:Load()
    if not tbData then
        return szError, false
    end

    RecoverTableRuntime(tbData)
    return "success", true
end

function Administration:NewUser(name)
    local runtime = GetTableRuntime()
    local user = Lib.copyTab(tbInitTables.tbInitUserData)
    user.szAccount = name
    user.nCash = tbConfig.nInitCash
    if runtime.nCurYear == 1 then
        user.tbHistoryYearReport[1] = user.tbYearReport
    else
        for i = runtime.nCurYear - 1, 1, -1 do
            user.tbHistoryYearReport[i] = Lib.copyTab(user.tbYearReport)
        end
        user.tbHistoryYearReport[runtime.nCurYear] = user.tbYearReport
    end
    runtime.tbUser[name] = user
end

function tbAdminFunc.NextStep(tbParam)
    local runtime = GetTableRuntime()
    if tbParam.CurSeason ~= runtime.nCurSeason or tbParam.CurYear ~= runtime.nCurYear then
        return "failed, step mismatch", false    --避免在收到请求时，服务端已经刚刚变过步骤了
    end
    NextStepIfAllGamersDone(true)
    return "success", true
end
