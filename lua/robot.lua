dofile(getScriptPath() .. "\\quik_table_wrapper.lua")
JSON = (loadfile(getScriptPath() .. "\\json.lua"))() -- one-time load of the routines

function toPrice(sec_code, class_code, value)
    -- преобразования значения value к цене инструмента правильного ФОРМАТА (обрезаем лишнии знаки после разделителя)
    -- Возвращает строку
    if (sec_code == nil or value == nil) then return nil end
    local scale = getSecurityInfo(class_code or getSecurityInfo("", sec_code).class_code, sec_code).scale
    return string.format("%." .. string.format("%d", scale) .. "f", tonumber(value))
end

local function check_if_no_transaction(sec_code)
    for key, value in pairs(state) do
        if key == sec_code and value.trans_id then
            return false
        end
    end
    return true
end

function sendLimit(class, security, direction, price_raw, volume_raw, account)
    -- отправка лимитированной заявки
    -- все параметры кроме кода клиента и коментария должны быть не нил
    -- ВАЖНО! цена должна быть стрингом с количеством знаков после точки для данной бумаги
    -- если код клиента нил - подлставляем счет
    -- market_maker - признак заявки маркет-мейкера. true\false
    -- Данная функция возвращает 2 параметра
    --     1. ID присвоенный транзакции либо nil если транзакция отвергнута на уровне сервера Квик
    --     2. Ответное сообщение сервера Квик либо строку с параметрами транзакции
    if (class == nil or security == nil or direction == nil or price_raw == nil or volume_raw == nil or account == nil) then
        return nil, "QL.sendLimitSpot(): Can`t send order. Nil parameters. "
    end
    if check_if_no_transaction(security.code) then
        state[security.code].trans_id = trans_id
        local trans_id = gen_id()
        local price = to_price(price_raw, security.scale)
        local volume = math.floor(math.abs(volume_raw) + 0.5)
        local now = os.date('%d.%m.%Y %H:%M', os.time())

        local f, err = io.open(getScriptPath() .. '\\transactions.log', 'a')
        if f then
            f:write(now .. ' ' .. security.code .. ' ' .. direction .. ' ' .. tostring(price) .. ' ' .. tostring(volume) .. '\n')
            f:close()
        else
            print("error:", err)
        end

        local transaction = {
            ["TRANS_ID"] = tostring(trans_id),
            ["ACTION"] = "NEW_ORDER",
            ["CLASSCODE"] = class,
            ["SECCODE"] = security.code,
            ["OPERATION"] = direction,
            ["QUANTITY"] = tostring(math.abs(volume)),
            ["PRICE"] = tostring(price),
            ["ACCOUNT"] = tostring(account)
        }

        transaction.client_code = tostring(client_code)

        local res = sendTransaction(transaction)
        if res ~= "" then
            return nil, "Transaction:" .. res
        else
            return trans_id, "Transaction: Limit order sended sucesfully. Class=" .. class .. " Sec=" .. security.code .. " Dir=" .. direction .. " Price=" .. price .. " Vol=" .. volume .. " Acc=" .. account .. " Trans_id=" .. trans_id
        end
    else
		-- already has transaction
		local f, err = io.open(getScriptPath() .. '\\transactions.log', 'a')
        if f then
            f:write('HAS TRANSACTION '.. security.code .. ' ' .. direction .. ' ' .. tostring(price_raw) .. ' ' .. tostring(volume_raw) .. '\n')
            f:close()
        else
            print("error:", err)
        end
        return nil, nil
    end
end

local function clear_transaction_state(trans_id)
    for key, value in pairs(state) do
        if value.trans_id == trans_id then
            state[key].trans_id = nil
            break
        end
    end
end

local function init_transaction_states()
    for key, value in pairs(state) do
        if value.trans_id then
            state[key].trans_id = nil
        end
    end
end

function on_trans_reply(trans_reply)
    local s = string.format("%i: %i [%s]\n",
        trans_reply.trans_id,
        trans_reply.status,
        trans_reply.result_msg)
    local f, err = io.open(getScriptPath() .. '\\transactions.log', 'a')
    if f then
        f:write(s)
        f:close()
    else
        print("error:", err)
    end
    clear_transaction_state(trans_reply.trans_id)
end

local function get_turd(sec_code, price)
    local tag = sec_code .. '_TD'
    local n = getNumCandles(tag)
    local movement = '-'
    local old_turtle = tonumber(state[sec_code].turtle)
    local turtle_time = tonumber(state[sec_code].turtle_time) or os.time { year = 2020, month = 6, day = 23, hour = 18 }
    local date = os.date('%Y%m%d', turtle_time)
    local time = os.date('%H%M%S', turtle_time)
    local R, G, B = 127, 0, 0
    if old_turtle < 0 then
        R = 0
        G = 127
    end
    local label = AddLabel(tag, { TEXT = tostring(math.abs(old_turtle)), YVALUE = math.abs(old_turtle), DATE = date, TIME = time, R = R, G = G, B = B, TRANSPARENT_BACKGROUND = 0, TRANSPARENCY = 50, HINT = 'Метка' })
    local turtle = 0
    local dolphin = 0
    local goesUp = false
    local trend = '----'
    local revert = false
    local last_price = tonumber(price)
    if n then
        local fast, num, legend = getCandlesByIndex(tag, 0, n - 1, 1)
        local slow, num, legend = getCandlesByIndex(tag, 1, n - 1, 1)
        if fast and slow and num > 0 then
            dolphin = tonumber(fast[0].open)
            turtle = tonumber(slow[0].open)
        end
        if old_turtle < 0 and math.abs(old_turtle) > turtle then
            trend = 'вниз'
        end
        if old_turtle > 0 and math.abs(old_turtle) < turtle then
            trend = 'вверх'
        end
        if dolphin > turtle then -- дельфин выше черепахи, восходящий тренд
            goesUp = true
            if old_turtle < 0 and last_price > dolphin then -- в прошлый раз продавали, теперь можно купить
                revert = true
            end
        elseif turtle > dolphin then -- дельфин ниже черепахи, плывем вниз
            goesUp = false
            if old_turtle > 0 and last_price < dolphin then -- в прошлый раз покупали, теперь продаем
                revert = true
            end
        end
    end
    return trend, goesUp, revert, turtle, dolphin
end

-- Convert a lua table into a lua syntactically correct string
function table_to_string(tbl)
    if tbl then
        local result = "{"
        for k, v in pairs(tbl) do
            -- Check the key type (ignore any numerical keys - assume its an array)
            if type(k) == "string" then
                result = result .. "[\"" .. k .. "\"]" .. "="
            end

            -- Check the value type
            if type(v) == "table" then
                result = result .. table_to_string(v)
            elseif type(v) == "boolean" then
                result = result .. tostring(v)
            else
                result = result .. "\"" .. v .. "\""
            end
            result = result .. ","
        end
        -- Remove leading commas from the result
        if result ~= "" then
            result = result:sub(1, result:len() - 1)
        end
        return result .. "}"
    end
end


function get_currency_limit(currency, limit_kind)
    local n = getNumberOf("money_limits")
    for i = 0, n - 1 do
        local money = getItem("money_limits", i)
        if money then
            --message('money firmid '.. i .. ' ' .. money.limit_kind)

            if money.limit_kind == limit_kind and money.currcode == currency and money.firmid == firmid and money.client_code == client_code then
                return money.currentbal
            end
        end
    end
end

function gen_id()
    trans_id = trans_id + 1
    return trans_id
end

local function is_trading_session(class_code, sec_code)

    local status = getParamEx(class_code, sec_code, "status") --

    if status.param_type == "4" and status.param_value == "1.000000" then
        return true
    end

    if status.param_type == "2" and status.param_value == "0.000000" then
        if ParamRequest(class_code, sec_code, "status") == true then
            status = getParamEx(class_code, sec_code, "status")
        end
        if status.param_type == "4" and status.param_value == "1.000000" then
            return true
        end
        return false
    end
end

function readAll(file)
    local f, err = io.open(file, "rb")
    if err then
        local f, err = io.open(file, 'w')
        f:write()
        f:close()
    else
        local content = f:read("*all")
        f:close()
        return content
    end
end

function save_state()
    local loaded_json = JSON:encode(state)
    local f, err = io.open(getScriptPath() .. '\\portfolio.json', 'w')
    if f then
        f:write(tostring(loaded_json))
        f:close()
    else
        print("error:", err)
    end
end

function int_format(data)
    return string.format("%.0f", data)
end

function price_format(data)
    if data then
        return string.format("%.2f", data)
    end
end

local function index(tab, val)
    for i, value in ipairs(tab) do
        if value == val then
            return i
        end
    end

    return false
end

function init_state()
    trans_id = os.time()
    local loaded_json = readAll(getScriptPath() .. '\\portfolio.json')
    state = JSON:decode(loaded_json) or {}
end

function to_price(value, scale)
    -- преобразования значения value к цене инструмента правильного ФОРМАТА (обрезаем лишнии знаки после разделителя)
    -- Возвращает строку
    if (scale == nil or value == nil) then return nil end
    return string.format("%." .. string.format("%d", scale) .. "f", tonumber(value))
end

function job(depo, t, security, class_code, assets, sum, cycle_ep, cycle_assets, account, row, stage, turtle)
    local last_price = 0
    local sec_code = security.code
    local is_trading = is_trading_session(class_code, sec_code)
    if depo.firmid == firmid and depo.client_code == client_code and depo.limit_kind == 365 then
        local last_price_ex = getParamEx(class_code, sec_code, "LAST")
        local position = depo.currentbal
        local lot_size = security.lot_size
        local roce = portfolio[sec_code].roce
        local debet = portfolio[sec_code].debet
        local virtual = position + debet
        if last_price_ex then
            last_price = last_price_ex.param_value
        end
		sum = sum + roce
        local target = roce / cycle_ep
        local value = virtual * last_price
        assets = assets + value
        local target_value = cycle_assets * target * 0.7
        local disbalance = (target_value / last_price - virtual) / lot_size
        local min_disbalance = 0.01
        local trend, goesUp, rev, now_turtle, now_dolphin = get_turd(sec_code, last_price)
        local order_amount = math.abs(disbalance)
        local over = value / target_value - 1
        --                        if order_amount > max_order_amount then -- ограничиваем размер заказа
        --                            order_amount = max_order_amount
        --                        end
        if is_trading then
            if rev then -- переворот

                if trend == 'вверх' then
                    -- проверяем условия для продажи
                    --if (stage == 'B' or over > min_disbalance) and disbalance <= -1 then -- недавно купили или недавно продали, но выросло на 1%
                    if disbalance <= -1 then 
                        local tran_id, mess = sendLimit(class_code, security, 'S', last_price, order_amount, account)
                        if mess then message(mess) end
                        state[sec_code].stage = 'S'
                        state[sec_code].turtle = -1 * last_price
                        state[sec_code].turtle_time = os.time()
                        save_state()
                    end
                elseif trend == 'вниз' then
                    -- проверяем условия для покупки
                    --if (stage == 'S' or over < -min_disbalance) and disbalance >= 1 then -- недавно продали или недавно купили, но упало на 1%
                    if disbalance >= 1 then -- недавно продали или недавно купили, но упало на 1%
                        local tran_id, mess = sendLimit(class_code, security, 'B', last_price, order_amount, account)
                        if mess then message(mess) end
                        state[sec_code].stage = 'B'
                        state[sec_code].turtle = last_price
                        state[sec_code].turtle_time = os.time()
                        save_state()
                    end
                end
                -- обновляем состояние, перевернулись же
                if goesUp == false then
                    state[sec_code].turtle = -1 * last_price
                    state[sec_code].turtle_time = os.time()
                    save_state()
                elseif goesUp == true then
                    state[sec_code].turtle = last_price
                    state[sec_code].turtle_time = os.time()
                    save_state()
                end
            end
        end
        --                        if trend == 'вверх' then
        --                            t:SetColor(row, nil, {152, 251, 152})
        --                        elseif trean == 'вниз' then
        --                            t:SetColor(row, nil, {251, 152, 152})
        --                        end
        if is_trading then
            t:SetValue(row, "Актив", security.short_name)
        else
            t:SetValue(row, "Актив", '*' .. security.short_name)
        end
        t:SetValue(row, "Позиция", position)
        t:SetValue(row, "Купить-Продать", disbalance)
        t:SetValue(row, "Стоимость", value)
        t:SetValue(row, "ROCE", roce)
        t:SetValue(row, "Последняя цена", last_price)
        t:SetValue(row, "Средняя цена", depo.wa_position_price)
        t:SetValue(row, "Цель", target_value)
        t:SetValue(row, "Тренд", trend)
        t:SetValue(row, "Операция", stage)
        t:SetValue(row, "НКД", turtle)
        t:SetValue(row, "Черепаха", to_price(now_turtle - math.abs(turtle), security.scale))
        t:SetValue(row, "Дельфин", to_price(now_dolphin - now_turtle, security.scale))
        t:SetValue(row, "Переворот", tostring(rev))
    end
    return assets, sum
end

function main_cycle()
    local t = QTable.new()
    -- добавить два столбца с функциями форматирования
    -- в первом столбце – hex-значения, во втором – целые числа


    t:AddColumn("Актив", QTABLE_STRING_TYPE, 25)
    t:AddColumn("Позиция", QTABLE_STRING_TYPE, 20, int_format)
    t:AddColumn("Купить-Продать", QTABLE_STRING_TYPE, 10, int_format)
    t:AddColumn("Стоимость", QTABLE_STRING_TYPE, 20, price_format)
    t:AddColumn("ROCE", QTABLE_STRING_TYPE, 10, price_format)
    t:AddColumn("Последняя цена", QTABLE_STRING_TYPE, 15, price_format)
    t:AddColumn("Средняя цена", QTABLE_STRING_TYPE, 15, price_format)
    t:AddColumn("Цель", QTABLE_STRING_TYPE, 20, price_format)
    t:AddColumn("НКД", QTABLE_STRING_TYPE, 15, price_format)
    t:AddColumn("Тренд", QTABLE_STRING_TYPE, 10)
    t:AddColumn("Операция", QTABLE_STRING_TYPE, 10)
    t:AddColumn("Черепаха", QTABLE_STRING_TYPE, 15)
    t:AddColumn("Дельфин", QTABLE_STRING_TYPE, 15)
    t:AddColumn("Переворот", QTABLE_STRING_TYPE, 15)

    t:SetCaption("Портфель активов " .. client_code)
    t:Show()
    local total_assets_row = t:AddLine()
    local rub_assets_row = t:AddLine()
    local usd_assets_row = t:AddLine()
    local eur_assets_row = t:AddLine()
    t:AddLine() -- пустая строка
    local rub_row = t:AddLine()
    local usd_row = t:AddLine()
    local eur_row = t:AddLine()
    local assets_starts_here = t:AddLine() -- пустая строка


    local tables = { RUB_SHARES = {}, USD_SHARES = {}, EUR_SHARES = {}, BONDS = {} }



    local cycle_rub_ep = 1
    local cycle_usd_ep = 1
    local cycle_eur_ep = 1
    local cycle_usd_assets = 0
    local cycle_eur_assets = 0
    local cycle_rub_assets = 0
    for key, value in pairs(portfolio) do
        DelAllLabels(key .. '_TD')
    end
    if not state then
        state = {}
    end
    init_transaction_states()
    while is_run do
        if t:IsClosed() then
            t:Show()
            --is_run = false
        end


        -- проходим по списку бумаг
        local info = getPortfolioInfo(firmid, client_code)
        local depo_length = getNumberOf("depo_limits")
        local sum_rub_ep = 0 -- + 1 / pe_fxmm
        local sum_usd_ep = 0
        local sum_eur_ep = 0
        local usd_assets = 0
        local eur_assets = 0
        local rub_assets = 0

        for i = 1, depo_length - 1 do
            local depo = getItem("depo_limits", i)
            local sec_code = depo.sec_code
            local stage = ''
            local turtle = depo.wa_position_price
            if state[sec_code] then
                stage = state[sec_code].stage
                turtle = tonumber(state[sec_code].turtle)
                if turtle == 0 then
                    turtle = depo.wa_position_price
                    state[sec_code].turtle = depo.wa_position_price
                end
            else
                state[sec_code] = {}
                state[sec_code].stage = 'S'
                state[sec_code].turtle = depo.wa_position_price
                state[sec_code].trans_id = nil
            end

            if portfolio[sec_code] then
                local class_code = "TQBR" -- TQTF
                local security = getSecurityInfo(class_code, sec_code) -- акции
                if not security then
                    class_code = "TQTF"
                    security = getSecurityInfo(class_code, sec_code) -- акции ETF
                end
                if security then
                    local row = 0
                    local pos = index(tables.RUB_SHARES, sec_code)
                    if pos then
                        row = pos + 9
                    else
                        row = t:AddLine()
                        tables.RUB_SHARES[#tables.RUB_SHARES + 1] = sec_code
                    end
                    rub_assets, sum_rub_ep = job(depo, t, security, class_code, rub_assets, sum_rub_ep, cycle_rub_ep, cycle_rub_assets, account_rub, row, stage, turtle)
                else


                    local class_code = "SPBXM"
                    local security = getSecurityInfo(class_code, sec_code) -- акции SPB
                    if security then

                        local row = 0
                        local pos = index(tables.USD_SHARES, sec_code)
                        if pos then
                            row = 9 + #tables.RUB_SHARES + pos
                        else
                            row = t:AddLine()
                            tables.USD_SHARES[#tables.USD_SHARES + 1] = sec_code
                        end
                        usd_assets, sum_usd_ep = job(depo, t, security, class_code, usd_assets, sum_usd_ep, cycle_usd_ep, cycle_usd_assets, account_usd, row, stage, turtle)
                    else
						local class_code = "SPBDE"
						local security = getSecurityInfo(class_code, sec_code) -- акции SPB DE
						if security then

							local row = 0
							local pos = index(tables.EUR_SHARES, sec_code)
							if pos then
								row = 9 + #tables.RUB_SHARES + #tables.USD_SHARES + pos
							else
								row = t:AddLine()
								tables.EUR_SHARES[#tables.EUR_SHARES + 1] = sec_code
							end
							eur_assets, sum_eur_ep = job(depo, t, security, class_code, eur_assets, sum_eur_ep, cycle_eur_ep, cycle_eur_assets, account_usd, row, stage, turtle)
						end
                    
                    end
                end
            else
                local class_code = "TQOB" --TQCB
                local security = getSecurityInfo(class_code, sec_code) -- облигации
                if not security then
                    class_code = "TQCB"
                    security = getSecurityInfo(class_code, sec_code) -- облигации
                end	
                if not security then
					if sec_code == 'VTBY' then
					class_code = "TQTE" -- 
                    security = getSecurityInfo(class_code, sec_code) -- etf eur
                    else
					   class_code = "TQTD" -- 
                       security = getSecurityInfo(class_code, sec_code) -- etf usd
                       if not security then
                          class_code = "TQTF"
                          security = getSecurityInfo(class_code, sec_code) -- etf rub
                       end   
                    end
                end	
                if security then

                    -- облигации мы используем ТОЛЬКО как инструменты денежного рынка. Они не входят в долю балансируемых
                    -- общая доля денег и эквивалентов должна быть 20%. Должна быть часть в деньгах - для ребалансировки
                    -- остальное можно пихать в краткосрочные облигации (НЕ FXMM!!)
                    if depo.firmid == firmid and depo.client_code == client_code and depo.limit_kind == 365 then
                        local lot_size = security.lot_size
                        local last_price = nil
                        local face_value = security.face_value
                        local nkd_ex = getParamEx(class_code, sec_code, "accruedint")
                        local nkd = 0

                        if nkd_ex then
                            nkd = nkd_ex.param_value
                        end

                        local last_price_ex = getParamEx(class_code, sec_code, "LAST")
                        local param = {}
                        if last_price_ex and last_price_ex.param_value then
                            last_price = last_price_ex.param_value
                        end
                        if not last_price or last_price == 0 then
                            param = getParamEx(class_code, sec_code, "MARKETPRICE")
                            if param then
                                last_price = param.param_value
                            end
                        end
                        if not last_price or last_price == 0 then
                            param = getParamEx(class_code, sec_code, "PREVPRICE")
                            if param then
                                last_price = param.param_value
                            end
                        end
                        if not last_price or last_price == 0 then
                            param = getParamEx(class_code, sec_code, "WAPRICE")
                            if param then
                                last_price = param.param_value
                            end
                        end
                        if not last_price or last_price == 0 then
                            param = getParamEx(class_code, sec_code, "LCURRENTPRICE")
                            if param then
                                last_price = param.param_value
                            end
                        end
                        if not last_price or last_price == 0 then
                            param = getParamEx(class_code, sec_code, "LCLOSEPRICE")
                            if param then
                                last_price = param.param_value
                            end
                        end
                        if not last_price or last_price == 0 then
                            last_price = depo.wa_position_price
                        end
                        if not last_price then
                            last_price = 0
                        end
                        
                        -- печать данных
                        local row = 0
                        local pos = index(tables.BONDS, sec_code)
                        if pos then
                            row = 9 + #tables.RUB_SHARES + #tables.USD_SHARES + #tables.EUR_SHARES + pos
                        else
                            row = t:AddLine()
                            tables.BONDS[#tables.BONDS + 1] = sec_code
                        end
                        local position = depo.currentbal
                        local virtual = position

                        local dirt_price = last_price
                        if class_code == 'TQTF' then
                        	dirt_price = last_price
                        	rub_assets = rub_assets + position * dirt_price
                        else
							if class_code == 'TQTD' then	
								dirt_price = last_price
								usd_assets = usd_assets + position * dirt_price
							else if class_code == 'TQTE' then
								dirt_price = last_price
								eur_assets = eur_assets + position * dirt_price
								else
								dirt_price = nkd + last_price * face_value * lot_size / 100
								rub_assets = rub_assets + position * dirt_price
								end
							end	
                        end
                        
                        t:SetValue(row, "Купить-Продать", 0)
                        t:SetValue(row, "Актив", security.short_name)
                        t:SetValue(row, "Позиция", position)
                        t:SetValue(row, "Стоимость", position * dirt_price)
                        t:SetValue(row, "ROCE", 0)
                        t:SetValue(row, "Последняя цена", last_price)
                        t:SetValue(row, "Средняя цена", depo.wa_position_price)
                        t:SetValue(row, "Цель", 0)
                        t:SetValue(row, "НКД", nkd)
                        t:SetValue(row, "Тренд", class_code)
                        t:SetValue(row, "Операция", "")
                        t:SetValue(row, "Черепаха", last_price_ex.param_value)
                        t:SetValue(row, "Дельфин", "")
                        t:SetValue(row, "Переворот", "")
                    end
                end
            end
        end


        --local money = getMoney(firm_code, client_code, "EQTV", "SUR")
        local rub = get_currency_limit('SUR', 365) or 0
        t:SetValue(rub_row, "Актив", "Рубли")
        t:SetValue(rub_row, "Стоимость", rub)
        rub_assets = rub_assets + rub + RUB_DEBET
        t:SetValue(rub_row, "Цель", 0)

        local usd = get_currency_limit('USD', 365) or 0
        usd_assets = usd_assets + usd + USD_DEBET
        t:SetValue(usd_row, "Актив", "Доллары США")
        t:SetValue(usd_row, "Стоимость", usd)
        t:SetValue(usd_row, "Цель", 0)
		
		local eur = get_currency_limit('EUR', 365) or 0
        eur_assets = eur_assets + eur + EUR_DEBET
        t:SetValue(eur_row, "Актив", "Евро")
        t:SetValue(eur_row, "Стоимость", eur)
        t:SetValue(eur_row, "Цель", 0)

        t:SetValue(rub_assets_row, "Актив", "Рублевые активы")
        t:SetValue(rub_assets_row, "Стоимость", rub_assets)
        t:SetValue(usd_assets_row, "Актив", "Долларовые активы")
        t:SetValue(usd_assets_row, "Стоимость", usd_assets)
        t:SetValue(eur_assets_row, "Актив", "Евровые активы")
        t:SetValue(eur_assets_row, "Стоимость", eur_assets)

        t:SetValue(total_assets_row, "Актив", "Итого")
        t:SetValue(total_assets_row, "Стоимость", info.all_assets)


        cycle_rub_ep = sum_rub_ep
        cycle_usd_ep = sum_usd_ep
        cycle_eur_ep = sum_eur_ep
        cycle_usd_assets = usd_assets
        cycle_eur_assets = eur_assets
        cycle_rub_assets = rub_assets
        sleep(2000)
    end
end
