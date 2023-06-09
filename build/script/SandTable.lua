print(package.path)

package.path = "./script/?.lua;" .. package.path
--print(package.path)
require("Json")
require("Lib")
require("Config")
require("Production")
require("Admin")
require("DataSync")
require("Market")
require("HumanResources")
require("DataStorage")

local tbRuntimeData = {
    --==== 游戏整体运行信息 ====
    bPlaying = false,
    nCurYear = 0,       -- 当前年份, 取值为0时，表示游戏未开始
    nCurSeason = 0,     -- 当前季度, 取值为0~4, 0表示新年开始时且1季度开始前
    nNewProductId = 0,  -- 新建项目的id值

    --==== 玩家相关信息 ====
    nGamerCount = 0,
    tbLoginAccount = {},    -- 已登录账号列表
    tbUser = { },           -- 玩家运行时数据，数据说明见tbInitTables.tbInitUserData

    --==== 人才市场相关信息 ====
    tbManpowerInMarket = { 0, 0, 0, 0, 0 }, -- 人才市场各等级人数。元素个数需要等于tbConfig.nManpowerMaxExpLevel

    --==== npc 数据 ====
    tbNpc = { },

    --==== 产品市场相关 ====
    tbCategoryInfo = {},            --各品类运行时的信息，以品类为key，不包括中台，各value的数据项请参看tbInitTables.tbInitCategoryInfo
}

local tbFunc = {
    Action = {},
}

function Action(jsonParam)
    local tbParam = JsonDecode(jsonParam)
    local func = tbFunc.Action[tbParam.FuncName]
    local szMsg
    local bRet = false
    if func then
        szMsg, bRet, tbCustomData = func(tbParam)
        --简单处理，只要收到客户端来的指令就认为数据变更了
        DoUpdateGamerDataVersion(tbParam.Account)
    else
        szMsg = "invalid action FuncName"
    end
    local tbResult = {
        code = bRet and 0 or -1,
        msg = szMsg,
        tbRuntimeData = tbRuntimeData
    }

    if tbCustomData then
        for k, v in pairs(tbCustomData) do
            tbResult[k] = v
        end
    end

    return JsonEncode(tbResult)
end

function GetTableRuntime()
    return tbRuntimeData
end

function RecoverTableRuntime(tbData)
    tbRuntimeData = tbData
    MarketMgr:OnRecover()
end

function SandTableStart()
    Production:Reset()
    HumanResources:UpdateAllUserManpower()
    MarketMgr:DoStart()
end

--------------------接口实现---------------------------------------
-- 登录 {FuncName = "Login"}
function tbFunc.Action.Login(tbParam)
    if not table.contain_key(tbRuntimeData.tbLoginAccount, tbParam.Account) then
        if tbRuntimeData.nGamerCount >= tbConfig.nMaxGamerCount then
            print("Login : failed, too much gamers")
            return "failed, too much gamers", false
        end

        if tbRuntimeData.bPlaying and (not tbConfig.bDebug) then -- 已经开始后，非调试模式不能再进入
            return "failed, already start", false
        end

        tbRuntimeData.tbLoginAccount[tbParam.Account] = { loginTime = os.time()}
        tbRuntimeData.nGamerCount = tbRuntimeData.nGamerCount + 1
        
        if tbRuntimeData.bPlaying then
            Administration:NewUser(tbParam.Account)
        end
    end
    return "success", true
end

-- 登出 {FuncName = "Logout"}
function tbFunc.Action.Logout(tbParam)
    tbRuntimeData.tbLoginAccount[tbParam.Account] = nil
    tbRuntimeData.tbUser[tbParam.Account] = nil
    tbRuntimeData.nGamerCount = tbRuntimeData.nGamerCount - 1
    return "success", true
end

function tbFunc.Action.StepDone(tbParam)
    local tbUser = tbRuntimeData.tbUser[tbParam.Account]
    tbUser.bStepDone = true
    NextStepIfAllGamersDone(false)
    return "success", true
end

function tbFunc.Action.DoOperate(tbParam)
    return tbFunc.Action.funcDoOperate[tbParam.OperateType](tbParam)
end

function tbFunc.Action.HR(tbParam)
    local user = tbRuntimeData.tbUser[tbParam.Account]
    local func = HR[tbParam.Operate]
    if func then
        return func(tbParam, user)
    end
    return "invalid HR operate", false
end

function tbFunc.Action.Develop(tbParam)
    local user = tbRuntimeData.tbUser[tbParam.Account]
    local func = Develop[tbParam.Operate]
    if func then
        return func(tbParam, user)
    end
    return "invalid Develop operate", false
end

function tbFunc.Action.Market(tbParam)
    local user = tbRuntimeData.tbUser[tbParam.Account]
    local func = Market[tbParam.Operate]
    if func then
        return func(tbParam, user)
    end
    return "invalid Market operate", false
end

tbFunc.Action.funcDoOperate = {}

--------------------------------------------------------------------
function NextStepIfAllGamersDone(forceAllDone)
    local bAllDone = true
    if not forceAllDone then
        for _, tbUser in pairs(tbRuntimeData.tbUser) do
            if not tbUser.bStepDone then
                bAllDone = false
                break
            end
	    end
    end
    if not bAllDone then
        return
    end
   
    -- 切换到下一步骤
    if tbRuntimeData.nCurSeason == 0 then
        tbRuntimeData.nCurSeason = 1
        DoPreSeason()
    else
        DoPostSeason()
        if tbRuntimeData.nCurSeason < 4 then
            tbRuntimeData.nCurSeason = tbRuntimeData.nCurSeason +1
            DoPreSeason()
        else
            DoPostYear()
            tbRuntimeData.nCurYear = tbRuntimeData.nCurYear + 1
            tbRuntimeData.nCurSeason = 0
            DoPreYear()
        end
    end
    -- 重置步骤完成标记
    for _, tbUser in pairs(tbRuntimeData.tbUser) do
        tbUser.bStepDone = false
	end
    DoUpdateGamerDataVersion(nil)
end

-- 每个季度开始前的自动处理
function DoPreSeason()
    print("=============== Year:".. tbRuntimeData.nCurYear .. " Season:" .. tbRuntimeData.nCurSeason .. "  ===============")
    HumanResources:AddNewManpower() -- 新人才进入人才市场
    HumanResources:SettleDepart()   -- 办理离职（交付流失员工）
    HumanResources:SettleFire()     -- 解雇人员离职
    HumanResources:SettleTrain()    -- 培训中的员工升级
    HumanResources:SettlePoach()    -- 成功挖掘的人才入职
    HumanResources:SettleHire()     -- 人才市场招聘结果
    MarketMgr:PreSeason()         -- 市场模块处理
    HumanResources:RecordProductManpower() -- 记录季度开始时的人力
end

-- 每个季度结束后的自动处理
function DoPostSeason()
    DataStorage:Save(tbRuntimeData)

    for _, tbUser in pairs(tbRuntimeData.tbUser) do
        tbUser.tbSysMsg = {}
    end
    MarketMgr:PostSeason()        -- 更新市场竞标结果 -- 获取上个季度市场收益
    Production:PostSeason()         -- 推进研发进度,更新产品品质
    HumanResources:PayOffSalary()   -- 支付薪水
    for _, info in pairs(tbRuntimeData.tbCategoryInfo) do
        info.newPublished = {}    --清空新产品列表
    end
end

-- 每年结束后的自动处理
function DoPostYear()
    for _, user in pairs(tbRuntimeData.tbUser) do
        --年尾扣税
        GameLogic:FIN_Pay(user, tbConfig.tbFinClassify.Tax, GameLogic:FIN_Tax(user.tbYearReport.nGrossProfit))
        --记录一年最后的账上结余
        user.tbYearReport.nBalance = user.nCash - user.tbYearReport.nTax
    end
end

-- 每年开始时的自动处理
function DoPreYear()
    print("=============== Year:".. tbRuntimeData.nCurYear .. "  ==============================")
    for _, tbUser in pairs(tbRuntimeData.tbUser) do
        tbUser.tbYearReport = Lib.copyTab(tbInitTables.tbInitReport)    --清空年报
        tbUser.tbHistoryYearReport[tbRuntimeData.nCurYear] = tbUser.tbYearReport
    end
end

-- 更新玩家数据版本
function DoUpdateGamerDataVersion(account)
    for key, user in pairs(tbRuntimeData.tbUser) do
        if account == nil or key == account then
            user.nDataVersion = user.nDataVersion + 1
        end
    end
end

print("╔════════════════════════════════════════════╗")
print("║    Game Company Simulator © Seasun 2003    ║")
print("╚════════════════════════════════════════════╝")
