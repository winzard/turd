client_code = "243423"
firmid = "MC0003300000"
account_rub = "L01-00000F00"
account_usd = "VTBRM_CL"

RUB_DEBET = 66000
USD_DEBET = 0
EUR_DEBET = 0

-- ROCE = Operating Income/ (Assets - Current Liabilities) from Google Spreadsheet
    POLY = {} -- 2q2021
    POLY.income = 1127 -- AVG
    POLY.assets = 4440
    POLY.liabilities = 632
    POLY.debet = 0
    POLY.roce = 0.2848030502 -- 0.2841098737

    NLMK = {} -- 2q2021
    NLMK.income = 2071 -- AVG
    NLMK.assets = 9862
    NLMK.liabilities = 2282
    NLMK.debet = 0
    NLMK.roce = 0.34 --4114000/(9862000-2282000)

    PLZL = {} -- 2q2021
    PLZL.income = 2071 -- AVG
    PLZL.assets = 9862
    PLZL.liabilities = 2282
    PLZL.debet = 0
    PLZL.roce = 0.5 --4114000/(9862000-2282000)

    GLTR = {} -- 3Q2020
    GLTR.income = 24247066000
    GLTR.assets = 75458309000
    GLTR.liabilities = 483376930
    GLTR.debet = 0
    GLTR.roce = 0.2616417816

    MTSS = {} -- FY2020
    MTSS.income = 114235 -- AVG
    MTSS.assets = 919203
    MTSS.liabilities = 328614
    MTSS.debet = 0
    MTSS.roce = 0.33 --0.2091893527 --122959000/(919203000-328614000)

    FIVE = {} -- FY2020
    FIVE.income = 105717
    FIVE.assets = 1173229
    FIVE.liabilities = 408684
    FIVE.debet = 0
    FIVE.roce = 0.1231870999 -- FIVE.income / (FIVE.assets - FIVE.liabilities)

    MOEX = {} -- FY2020
    MOEX.income = 45910.25 -- AVG
    MOEX.assets = 4932596
    MOEX.liabilities = 4793306
    MOEX.debet = 0
    MOEX.roce = 0.1753537059 -- 0.3358206689

    ALRS = {} -- 2Q2020
    ALRS.income = 50127000000
    ALRS.assets = 100606000000
    ALRS.liabilities = 7208905830
    ALRS.debet = 0
    ALRS.roce = 0.3203088136 --ALRS.income / (ALRS.assets - ALRS.liabilities)

    DSKY = {} -- FY2020
    DSKY.income = 13729 -- AVG
    DSKY.assets = 96994
    DSKY.liabilities = 58715
    DSKY.debet = 0
    DSKY.roce = 0.434700024 -- 0.3542213767

    CHMF = {} -- 2q2021
    CHMF.income = 145367.5 -- AVG 187153 - 56021 + 140167 + 150568
    CHMF.assets = 546369 -- 632718
    CHMF.liabilities = 130780 -- 152682
    CHMF.debet = 0
    CHMF.roce = 0.5423731447 -- 0.3766036705

    SBER = {} -- FY2020
    SBER.income = 19684.5 -- AVG
    SBER.assets = 282405
    SBER.liabilities = 91339
    SBER.debet = 0
    SBER.roce = 0.1286774681

    UPRO = {} -- FY2020
    UPRO.income = 19666439.5 -- AVG
    UPRO.assets = 135270962
    UPRO.liabilities = 8601745
    UPRO.debet = 0
    UPRO.roce = UPRO.income / (UPRO.assets - UPRO.liabilities)

    LKOH = {} -- FY2020
    LKOH.income = 424876 -- AVG
    LKOH.assets = 5991579
    LKOH.liabilities = 885659
    LKOH.debet = 0
    LKOH.roce = LKOH.income / (LKOH.assets - LKOH.liabilities)

    NVTK = {} -- 2q2020
    NVTK.income = 491300.5 -- AVG
    NVTK.assets = 2059178
    NVTK.liabilities = 159996
    NVTK.debet = 0
    NVTK.roce = 0.33

    OZON = {} -- 2q2020
    OZON.income = 491300.5 -- AVG
    OZON.assets = 2059178
    OZON.liabilities = 159996
    OZON.debet = 0
    OZON.roce = 0.32


    T_SPB = {} -- 2q2021
    T_SPB.income = 26405000000 -- this is not real OP, fix for assets impairment
    T_SPB.assets = 147505000000
    T_SPB.liabilities = 7183000000
    T_SPB.debet = 0
    T_SPB.roce = 0.059 -- 27310000/(525761000-63438000) = 0.059

    MMM_SPB = {} -- 2q2021
    MMM_SPB.income = 26405000000 -- this is not real OP, fix for assets impairment
    MMM_SPB.assets = 147505000000
    MMM_SPB.liabilities = 7183000000
    MMM_SPB.debet = 0
    MMM_SPB.roce = 0.2024663832

    NEM_SPB = {} -- Y2020
    NEM_SPB.income = 26405000000 -- this is not real OP, fix for assets impairment
    NEM_SPB.assets = 147505000000
    NEM_SPB.liabilities = 7183000000
    NEM_SPB.debet = 9
    NEM_SPB.roce = 0.20 -- T_SPB.income / (T_SPB.assets - T_SPB.liabilities)

    GOLD_SPB = {} -- 2q2021
    GOLD_SPB.income = 4989000
    GOLD_SPB.assets = 46528000
    GOLD_SPB.liabilities = 1798000
    GOLD_SPB.debet = 0
    GOLD_SPB.roce = 0.109822909


    PFE_SPB = {} -- 2q2021
    PFE_SPB.income = 13560000
    PFE_SPB.assets = 169920000
    PFE_SPB.liabilities = 35664000
    PFE_SPB.debet = 0
    PFE_SPB.roce = 0.1082127501

    XOM_SPB = {} -- Y2019
    XOM_SPB.income = 13766000000
    XOM_SPB.assets = 43831000000
    XOM_SPB.liabilities = 4270000000
    XOM_SPB.debet = 0
    XOM_SPB.roce = 0.12 -- XOM_SPB.income / (XOM_SPB.assets - XOM_SPB.liabilities)

    ABBV_SPB = {} -- 2q2021
    ABBV_SPB.income = 16064000
    ABBV_SPB.assets = 147972000
    ABBV_SPB.liabilities = 28684000
    ABBV_SPB.debet = 0
    ABBV_SPB.roce = 0.15778564

    O_SPB = {} -- 2q2021 fake
    O_SPB.income = 1300
    O_SPB.assets = 0
    O_SPB.liabilities = 200
    O_SPB.debet = 0
    O_SPB.roce = 0.07091074031

    BMY_SPB = {} -- 2q2021 fake
    BMY_SPB.income = 1300
    BMY_SPB.assets = 0
    BMY_SPB.liabilities = 200
    BMY_SPB.debet = 0
    BMY_SPB.roce = 0.08020446291

    VALE_SPB = {} -- 2q2021
    VALE_SPB.income = 31774000
    VALE_SPB.assets = 96716000
    VALE_SPB.liabilities = 14335000
    VALE_SPB.debet = 0
    VALE_SPB.roce = 0.156556192

    MOS_SPB = {} -- 2q2021
    MOS_SPB.income = 1348600
    MOS_SPB.assets = 21473500
    MOS_SPB.liabilities = 4137900
    MOS_SPB.debet = 0
    MOS_SPB.roce = 0.07106783542

    PRU_SPB = {} -- 2q2021
    PRU_SPB.income = 1300
    PRU_SPB.assets = 0
    PRU_SPB.liabilities = 200
    PRU_SPB.debet = 0
    PRU_SPB.roce = 0.09158119026

    BAYN_DE_SPB = {} -- fake
    BAYN_DE_SPB.income = 2500
    BAYN_DE_SPB.assets = 0
    BAYN_DE_SPB.liabilities = 200
    BAYN_DE_SPB.debet = 0
    BAYN_DE_SPB.roce = 0.1280049638

    IFX_DE_SPB = {} -- fake
    IFX_DE_SPB.income = (581+1161)/2
    IFX_DE_SPB.assets = (21999+13581)/2
    IFX_DE_SPB.liabilities = (3450+2213)/2
    IFX_DE_SPB.debet = 0
    IFX_DE_SPB.roce = 0.08043245384

    BMW_DE_SPB = {} -- fake
    BMW_DE_SPB.income = (581+1161)/2
    BMW_DE_SPB.assets = (21999+13581)/2
    BMW_DE_SPB.liabilities = (3450+2213)/2
    BMW_DE_SPB.debet = 0
    BMW_DE_SPB.roce = 0.07431984722

    HEN3_DE_SPB = {} -- fake
    HEN3_DE_SPB.income = (581+1161)/2
    HEN3_DE_SPB.assets = (21999+13581)/2
    HEN3_DE_SPB.liabilities = (3450+2213)/2
    HEN3_DE_SPB.debet = 0
    HEN3_DE_SPB.roce = 0.1203897748

    DTE_DE_SPB = {} -- fake
    DTE_DE_SPB.income = 570
    DTE_DE_SPB.assets = 0
    DTE_DE_SPB.liabilities = 200
    DTE_DE_SPB.debet = 0
    DTE_DE_SPB.roce = 0.06384358217

    VNA_DE_SPB = {} -- fake
    VNA_DE_SPB.income = 3500
    VNA_DE_SPB.assets = 0
    VNA_DE_SPB.liabilities = 200
    VNA_DE_SPB.debet = 0
    VNA_DE_SPB.roce = 0.04333739336

    ALV_DE_SPB = {} -- fake
    ALV_DE_SPB.income = 3500
    ALV_DE_SPB.assets = 0
    ALV_DE_SPB.liabilities = 200
    ALV_DE_SPB.debet = 0
    ALV_DE_SPB.roce = 0.09313409942

    SAP_DE_SPB = {}
    SAP_DE_SPB.income = 3500
    SAP_DE_SPB.assets = 0
    SAP_DE_SPB.liabilities = 200
    SAP_DE_SPB.debet = 0
    SAP_DE_SPB.roce = 0.1094266189 --0.125548331

    SIE_DE_SPB = {}
    SIE_DE_SPB.income = 3500
    SIE_DE_SPB.assets = 0
    SIE_DE_SPB.liabilities = 200
    SIE_DE_SPB.debet = 0
    SIE_DE_SPB.roce = 0.06178801024

    SU26212RMFS9 = {}
    SU26212RMFS9.coupon = 35.15*2

    SU52002RMFS1={}
    SU52002RMFS1.coupon=28*2

    SU26215RMFS2= {}
    SU26215RMFS2.coupon=34.90*2
    SU26207RMFS9 = {}
    SU26207RMFS9.coupon=40.64*2
    RU000A100WA8 = {}
    RU000A100WA8.coupon=21.19*4
    RU000A1008J4 = {}
    RU000A1008J4.coupon=49.36*2
    SU25083RMFS5 = {}
    SU25083RMFS5.coupon=34.90*2
    SU26221RMFS0 = {}
    SU26221RMFS0.coupon=38.39*2

    portfolio = {
        NLMK = NLMK,
        MTSS = MTSS,
		NVTK = NVTK
    }




dofile(getScriptPath() .. "\\robot.lua")

function OnInit(script)
    is_run = true
    init_state()
    -- определим тут все бумаги и коэффициенты
end

function OnStop()
    save_state()
    is_run = false
end

function OnTransReply(trans_reply)
    --информирует о каждом получении результата обработки транзакций
    on_trans_reply(trans_reply)

end

function main()
    main_cycle()
end
