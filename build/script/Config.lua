tbConfig = {
    --[[未实际启用，暂时注释掉
    nLuaVersion = 1,
    --]]

    --==== 游戏整体性设置与控制 ====
    nMaxGamerCount = 9,     --最多允许容纳的玩家的数目，因为界面没有做灵活适配，所以限制数目上限
    bDebug = true,          --调试模式，允许玩家客户端发出一些管理请求
    szAdminPassword = "",   --管理者登录密码

    --==== ====
    nSalary = 1, -- 薪水
    fSalaryRatioPerLevel = 0.2,  -- 每薪水等级薪水涨幅
    fHireWeightRatioPerLevel = 0.5,  -- 每薪水等级增加招聘权重系数
    fTrainMaxRatioPerLevel = 0.2,  -- 每级可培训人数比例
    fTrainMaxRatioTotal = 0.1,   -- 总可培训人数比例
    tbPoachExpenseRatio = { 2, 4, 8, 12, 16},  -- 挖掘人才可选薪水倍数
    fPoachSalaryLevelRatio = 1.2, -- 挖掘时薪水等级系数
    nPoachSalaryWeight = 1, -- 挖掘时薪水等级部分的权重， 此参数越高，挖掘费用效果越不明显
    fPoachFailedReturnExpenseRatio = 0.8, -- 挖掘人才失败时候返还费用比例
    fTaxRate = 0.1,
    tbEnableMarketPerYear = { {}, {2}, {3}},
    ---tbBeginStepPerYear = {
    --    { desc = "调整薪资", nStepUniqueId = 1},
        --{ desc = "支付税款", mustDone = true, nStepUniqueId = 1},
        --{ desc = "追加额外市场，支付本地化费用", nStepUniqueId = 108},
       -- { desc = "市场竞标，抢用户", mustDone = true, syncNextStep = true, finalAction = "SettleOrder", nStepUniqueId = 2},
       -- { desc = "招聘并支付费用", nStepUniqueId = 3},
    --},
--    tbStepPerSeason = {
        --[[进入季度初自动流程]]
--        { desc = "获取上个季度市场收益", nStepUniqueId = 14},
--        { desc = "市场份额刷新", nStepUniqueId = 17},
--        { desc = "更新产品品质", nStepUniqueId = 3},
        --[[自由操作阶段]]
--        { desc = "推盘阶段：产品上线、市场竞标、人才市场竞标、解雇/挖人/培训、研发分配人力", nStepUniqueId = 2},
        --[[进入季度末自动流程]]
--        { desc = "推进研发进度", nStepUniqueId = 13},
        -- { desc = "产品上线，把加倍进度的员工放到待岗区", nStepUniqueId = 101},
        -- { desc = "季度竞标市场用户", syncNextStep = true, finalAction = "SettleOrder", nStepUniqueId = 111},
        -- { desc = "临时招聘，支付临时招聘费用", nStepUniqueId = 102},
        -- { desc = "解聘，支付解聘费用", nStepUniqueId = 112},
        -- { desc = "选择初始市场，并立项", nStepUniqueId = 103},
        -- { desc = "现有人力资源调整（产品线调整人力、预研人力投入）", nStepUniqueId = 104},
        -- { desc = "更新应收款", nStepUniqueId = 105},
        -- { desc = "本季收入结算—现结款收入、放置延期收款", nStepUniqueId = 106},
        -- { desc = "研发推进", nStepUniqueId = 107},
        -- { desc = "roll点扣除剩余点数，查看预研结果", nStepUniqueId = 109},
--    },
    --tbEndStepPerYear = {
        -- { desc = "准备进入年底", syncNextStep = true, finalAction = "EnableNextMarket", nStepUniqueId = 201},  -- 下个步骤，开放海外市场应该是大家一起开的。所以这里加一步，等大家一起NextStep
        -- { desc = "海外市场自动开放", enterAction = "EnableMarketTip", nStepUniqueId = 202},
        -- { desc = "结清账务（填损益表、负债表）", syncNextStep = true, enterAction = "FinancialReport", nStepUniqueId = 204},
        -- { desc = "排名总结", syncNextStep = true, finalAction = "NewYear", enterAction = "Year1FixManpower", nStepUniqueId = 205},
    --},
    tbProduct = {
        a1 = { minManpower = 20, maxManpower = 60, maxProgress = 3, addMarketCost = 3, },
        a2 = { minManpower = 40, maxManpower = 120, maxProgress = 4, addMarketCost = 8,},
        b1 = { minManpower = 20, maxManpower = 60, maxProgress = 3, addMarketCost = 3,},
        b2 = { minManpower = 40, maxManpower = 120, maxProgress = 6, addMarketCost = 12,},
        d1 = { minManpower = 40, maxManpower = 120, maxProgress = 4, addMarketCost = 8,},
        d2 = { minManpower = 80, maxManpower = 240, maxProgress = 6, addMarketCost = 24,},
        e1 = { minManpower = 60, maxManpower = 180, maxProgress = 4, addMarketCost = 12,},
        e2 = { minManpower = 120, maxManpower = 360, maxProgress = 8, addMarketCost = 48,},
    },
    tbProductSort = {"a1", "a2", "b1", "b2", "d1", "d2", "e1", "e2"},

    --tbYearStep = {},

    tbResearchSort = {"d", "e"},
    tbInitUserData = {
        -- 当前季度
        nCurSeason = 0,
        -- 当前季度步骤
        nCurSeasonStep = 1,
        -- 当前步骤已经操作完，防止重复操作
        bStepDone = false,
        -- 提示
        szTitle = "",
        -- 薪水等级
        nSalaryLevel = 1,
         -- 市场营销投入
        tbMarketingExpense = {},
        -- 产品
        tbProduct = {
            a1 = { manpower = 20, tbManpower = { 10, 5, 4, 1, 0 }, progress = 3, published = true, done = false, nQuality = 1 },
        },
         -- 订单
        tbOrder = {
            --a1 = {{ cfg = { n = 2, arpu = 2}, done = false}}
        },
        -- 待岗
        tbIdleManpower = { 10, 5, 4, 1, 0 },
        -- 解雇员工
        tbFireManpower = { 0, 0, 0, 0, 0},
        -- 培训员工
        tbTrainManpower = { 0, 0, 0, 0, 0},
        -- 即将离职员工
        tbDepartManpower = {0, 0, 0, 0, 0},
        -- 待收款
        tbReceivables = {0, 0, 0, 0},
        -- 现金
        nCash = 1000,
        -- 追加市场费
        nAppendMarketCost = 0,
        -- 税收
        nTax = 0,
        -- 市场营销费
        nMarketingExpense = 0,
        -- 总人力
        nTotalManpower = 20,
        -- 招聘、解雇费用
        nSeverancePackage = 0,
        -- 薪水
        tbLaborCost = {0, 0, 0, 0},
        -- 权益占比
        fEquityRatio = 1.0,
        -- 上一年财报
        tbLastYearReport = {
            -- 收入
            nTurnover = 40,
            -- 人力费用
            nLaborCosts = 0,
            -- 销售费用
            nMarketingExpense = 0,
            -- 行政+本地化费用
            nSGA = 0,
            -- 营业利润
            nGrossProfit = 0,
            -- 财务费用
            nFinancialExpenses = 0,
            -- 利润
            nProfitBeforeTax = 0,
            -- 需要缴纳税款
            nTax = 0,
            -- 净利润
            nNetProfit = 0,
            -- 权益
            nEquity = 60,
            -- 现金
            nCash = 60,
            -- 融资
            nFinance = 0,
            --创始人权益
            nFounderEquity = 60,
        },
        tbYearReport = {
        },

        bMarketingDone = false,

        -- 市场份额
        tbMarket = {
            a1 = 0,
            a2 = 0,
            b1 = 0,
            b2 = 0,
            d1 = 0,
            d2 = 0,
            e1 = 0,
            e2 = 0,
        },

        -- 市场投标计划
        tbMarketingExpense = {
        },
    },
    tbInitUserDataYearPath = {
        [1] = {  -- 第一年开始的初始数据补丁
        },
        [2] = {},
    },
    tbInitReport = {
        -- 收入
        nTurnover = 0,
        -- 人力费用
        nLaborCosts = 0,
        -- 销售费用
        nMarketingExpense = 0,
        -- 行政+本地化费用
        nSGA = 0,
        -- 营业利润
        nGrossProfit = 0,
        -- 财务费用
        nFinancialExpenses = 0,
        -- 利润
        nProfitBeforeTax = 0,
        -- 需要缴纳税款
        nTax = 0,
        -- 净利润
        nNetProfit = 0,
        -- 权益
        nEquity = 0,
        -- 现金
        nCash = 0,
    },
    tbOrder = { -- 订单
    },
    tbNewManpowerPerYear = {  -- 每年人才市场各等级新进人数
        {61, 26, 12, 1, 0},
        {66, 39, 21, 4, 0},
        {77, 54, 38, 11, 0},
        {76, 65, 50, 19, 0},
        {53, 54, 41, 19, 3},
        {43, 43, 45, 21, 8},
        {32, 36, 38, 24, 10},
        {25, 29, 30, 24, 12},
        {20, 23, 29, 26, 12},
        {21, 20, 30, 31, 18},
    },
    fSeason1NewManpowerRatio = 0.3,  -- 一季度新进人数占全年人数比例， 剩下的三季度新进

    -- 产品状态
    tbProductState = {
        nBuilding = 1,       -- 研发中
        nEnabled = 2,        -- 可上线
        nPublished = 3,      -- 发布
        nRenovating = 4,     -- 翻新
        nClosed = 5,         -- 关闭
    },

    --- 市场初始总份额
    tbMarket = {
        a1 = 250,
        a2 = 250,
        b1 = 150,
        b2 = 150,
        d1 = 350,
        d2 = 350,
        e1 = 450,
        e2 = 450,
    },

    --- 产品基础留存率
    tbProductRetentionRate = {
        a1 = 0.5,
        a2 = 0.5,
        b1 = 0.5,
        b2 = 0.5,
        d1 = 0.5,
        d2 = 0.5,
        e1 = 0.5,
        e2 = 0.5,
    },
}

--[[for i = 1, 4 do
    for j, v in ipairs(tbConfig.tbStepPerSeason) do
        local tbSeasonCfg = Lib.copyTab(v)
        tbSeasonCfg.nCurSeason = i
        tbSeasonCfg.nCurSeasonStep = j
        table.insert(tbConfig.tbYearStep, tbSeasonCfg)
    end
end--]]

tbConfig.tbInitUserData.tbLastYearReport = Lib.copyTab(tbConfig.tbInitReport)
tbConfig.tbInitUserData.tbYearReport = Lib.copyTab(tbConfig.tbInitReport)

