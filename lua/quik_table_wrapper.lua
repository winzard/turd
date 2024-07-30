--[[
Quik Table class QTable
-- only for Quik version 6.6+
]]
QTable ={}
QTable.__index = QTable

local table_insert=table.insert
local table_remove=table.remove

function QTable:new()
     -- Ñîçäàòü è èíèöèàëèçèðîâàòü ýêçåìïëÿð òàáëèöû QTable
	 if VERSIONLESS660118 then message("QTable: Quik Tables available ONLY in Quik 6.6+ version!",1) return nil end
	 local t_id = AllocTable()
     if t_id then
        q_table = {}
        setmetatable(q_table, QTable)
        q_table.t_id=t_id
        q_table.caption = ""
        q_table.created = false
		q_table.curr_col=0
		q_table.curr_line=0
        --òàáëèöà ñ îïèñàíèåì ïàðàìåòðîâ ñòîëáöîâ
        q_table.columns={}
		--òàáëèöà ñ äàííûìè ñòîëáöîâ
		q_table.data={}
         return q_table
     else
         return nil
     end
end
function QTable:Show()
	-- îòîáðàçèòü â òåðìèíàëå îêíî ñ ñîçäàííîé òàáëèöåé
	CreateWindow(self.t_id)
	if self.caption ~="" then
		-- çàäàòü çàãîëîâîê äëÿ îêíà
		SetWindowCaption(self.t_id, tostring(self.caption))
	end
	self.created = true
end
function QTable:IsClosed()
     --åñëè îêíî ñ òàáëèöåé çàêðûòî, âîçâðàùàåò «true»
	 return IsWindowClosed(self.t_id)
end
function QTable:delete()
     -- óäàëèòü òàáëèöó
     return DestroyTable(self.t_id)
end
function QTable:GetCaption()
	-- âîçâðàùàåò ñòðîêó, ñîäåðæàùóþ çàãîëîâîê òàáëèöû
	if not IsWindowClosed(self.t_id) then
		self.caption = GetWindowCaption(self.t_id)
	end
	return self.caption
end
function QTable:SetCaption(s)
   -- Çàäàòü çàãîëîâîê òàáëèöû (áåç ïàðàìåòðîâ âîññòàíàâëèâàåò åãî, åñëè áûë èçìåíåí èçâíå áèáëèîòåêè)
   self.caption = s or self.caption
   if IsWindowClosed(self.t_id) then return nil end
   return SetWindowCaption(self.t_id, tostring(self.caption))
end
function QTable:AddColumn(name, c_type, width, ff )
    -- Äîáàâèòü îïèñàíèå ñòîëáöà name òèïà C_type â òàáëèöó
	-- ff – ôóíêöèÿ ôîðìàòèðîâàíèÿ äàííûõ äëÿ îòîáðàæåíèÿ
	local col_desc={}
	self.curr_col=self.curr_col+1
    col_desc.c_type = c_type
	col_desc.format_function = ff
    col_desc.id = self.curr_col
	self.columns[name] = col_desc
    -- name èñïîëüçóåòñÿ â êà÷åñòâå çàãîëîâêà òàáëèöû
    return AddColumn(self.t_id, self.curr_col, name, true, c_type, width)
end
function QTable:Clear()
   -- î÷èñòèòü òàáëèöó
   self.data={}
   self.curr_line=0
   return Clear(self.t_id)
end
function QTable:SetValue(row, col_name, data, formatted)
	-- Óñòàíîâèòü çíà÷åíèå â ÿ÷åéêå
	local col_ind = self.columns[col_name].id or nil
	if col_ind == nil then
		return false
	end
	local col_type = self.columns[col_name].c_type
	if self.data[row][col_ind]==data then return true end
	self.data[row][col_ind]=data
	local col_type = self.columns[col_name].c_type
	-- åñëè äëÿ ÷èñëîâîãî ñòîëáöà äàíî ÍÅ÷èñëîâîå çíà÷åíèå, òî ïðèìåíÿåì ê íåìó tonumber
	if type(data) ~= "number" and (col_type==QTABLE_INT_TYPE or col_type==QTABLE_DOUBLE_TYPE or col_type==QTABLE_INT64_TYPE) then
		data = tonumber(data) or 0
	end
	-- åñëè äëÿ ÍÅñòðîêîâîãî çíà÷åíèÿ óæå äàí îòôîðìàòèðîâàííûé âàðèàíò, òî ñíà÷àëà èñïîëüçóåòñÿ îí
	if formatted and col_type~=QTABLE_STRING_TYPE and col_type~=QTABLE_CACHED_STRING_TYPE then
		return SetCell(self.t_id, row, col_ind, formatted, data)
	end
	-- åñëè äëÿ ñòîëáöà çàäàíà ôóíêöèÿ ôîðìàòèðîâàíèÿ, òî îíà èñïîëüçóåòñÿ
	local ff = self.columns[col_name].format_function
	if type(ff) == "function" then
		-- â êà÷åñòâå ñòðîêîâîãî ïðåäñòàâëåíèÿ èñïîëüçóåòñÿ
		-- ðåçóëüòàò âûïîëíåíèÿ ôóíêöèè ôîðìàòèðîâàíèÿ
		if col_type==QTABLE_STRING_TYPE or col_type==QTABLE_CACHED_STRING_TYPE then
			return SetCell(self.t_id, row, col_ind, ff(data))
		else
			return SetCell(self.t_id, row, col_ind, ff(data), data)
		end
	else
		if col_type==QTABLE_STRING_TYPE or col_type==QTABLE_CACHED_STRING_TYPE then
			return SetCell(self.t_id, row, col_ind, tostring(data))
		else
			return SetCell(self.t_id, row, col_ind, tostring(data), data)
		end
	end
end
function QTable:AddLine(key)
   -- äîáàâëÿåò ïóñòóþ ñòðî÷êó â ìåñòî key èëè â êîíåö òàáëèöû è âîçâðàùàåò åå íîìåð
   local line=InsertRow(self.t_id, key or -1)
   if line==-1 then return nil else self.curr_line=self.curr_line+1 table_insert(self.data,line,{}) return line end
end
function QTable:DeleteLine(key)
   -- óäàëÿåò ñòðî÷êó â ìåñòå key èëè â êîíöå òàáëèöû
   key = key or self.curr_line
   self.curr_line=self.curr_line-1
   table_remove(self.data,key)
   return DeleteRow(self.t_id,key)
end
function QTable:GetSize()
     -- âîçâðàùàåò ðàçìåð òàáëèöû, êîëè÷åñòâî ñòðîê è ñòîëáöîâ
     return GetTableSize(self.t_id)
end
function QTable:GetValue(row, name)
	 -- Ïîëó÷èòü äàííûå èç ÿ÷åéêè ïî íîìåðó ñòðîêè è èìåíè ñòîëáöà
	 local t={}
	 local col_ind = self.columns[name].id
     if col_ind == nil then
		return nil
     end
	 t = GetCell(self.t_id, row, col_ind)
     return t
end
function QTable:SetPosition(x, y, dx, dy)
	-- çàäàåò êîîðäèíàòû îêíà: x,y - êîîðäèíàòû ëåâîãî âåðõíåãî óãëà; dx,dy - øèðèíà è âûñîòà
	-- òàê æå GetPosition è SetSizeSuitable çàïîìèíàþò ïîçèöèþ îêíà è âûçîâ SetPosition áåç ïàðàìåòðîâ âåðíåò îêíî íà òî ìåñòî
	self.x, self.y, self.dx, self.dy = (x or self.x), (y or self.y), (dx or self.dx), (dy or self.dy)
	return SetWindowPos(self.t_id, self.x, self.y, self.dx, self.dy)
end
function QTable:GetPosition(size_wnd_title)
	-- âîçâðàùàåò êîîðäèíàòû îêíà (x, y, dx, dy), ãîäíûå äëÿ SetPosition: x,y - êîîðäèíàòû ëåâîãî âåðõíåãî óãëà; dx,dy - øèðèíà è âûñîòà
	if not IsWindowClosed(self.t_id) then
		local top, left, bottom, right = GetWindowRect(self.t_id)
		self.x, self.y, self.dx, self.dy = left, top-(size_wnd_title or 60), right-left, bottom-top
	end
	return self.x, self.y, self.dx, self.dy
end
function QTable:SetSizeSuitable(rows,cols,size_wnd_title,size_col_title,size_row,size_scroll)
	-- ìåíÿåò ðàçìåð îêíà òàáëèöû â ñîîòâåòñòâèè ñ ïåðåäàííûìè êîëè÷åñòâàìè ñòðîê è ñòîëáöîâ
	-- êîë-âî ñòîëáöîâ ïîêà íå èñïîëüçóåòñÿ (íå ÿñíî, ÷òî ñ íèì äåëàòü), íî åñëè îíî íå nil, òî ê øèðèíå îêíà òàáëèöû äîáàâëÿåòñÿ øèðèíà ñêðîëëáàðà
	-- áåç ïàðàìåòðà rows ìåíÿåò âåðòèêàëüíûé ðàçìåð îêíà òàáëèöû â ñîîòâåòñòâèè ñ òåêóùèì êîëè÷åñòâîì îòîáðàæàåìûõ ñòðîê
	-- äåòàëüíîå îïèñàíèå è ïðèìåð êàê ðàáîòàòü ñ ôóíêöèåé http://forum.qlua.org/topic172.html
	local top, left, bottom, right = GetWindowRect(self.t_id)
	self.x, self.y, self.dx, self.dy = left, top, right-left, bottom-top
	if cols then self.dx = self.dx + (size_scroll or 16) end
	self.dy = (size_wnd_title or 60)+(size_col_title or 42) + (rows or self.curr_line) * (size_row or 15)
	return SetWindowPos(self.t_id, self.x, self.y, self.dx, self.dy)
end
-- only for Quik version 6.7+
function QTable:SetColor(row,col_name,b_color,f_color,sel_b_color,sel_f_color)
	-- set color for cell, row or column
	if VERSIONLESS6713 then return false end
	local col_ind,row_ind=nil,nil
	--toLog(log,'setcol params='..tostring(row)..tostring(col_name)..tostring(b_color))
	if row==nil then row_ind=QTABLE_NO_INDEX else row_ind=row end
	if col_name==nil then col_ind=QTABLE_NO_INDEX
	else
		col_ind = self.columns[col_name].id
		if col_ind == nil then
			message('QTable.SetColor(): No such column name - '..col_name)
			return false
		end
	end
	--toLog(log,'SetColors row:col='..tostring(row_ind)..':'..tostring(col_ind)..' - '..tostring(b_color)..tostring(f_color)..tostring(sel_b_color)..tostring(sel_f_color))
	local bcnum,fcnum,selbcnum,selfcnum=0,0,0,0
	if b_color==nil or b_color=='DEFAULT_COLOR' then bcnum=16777215 else bcnum=RGB2number(b_color) end
	if f_color==nil or f_color=='DEFAULT_COLOR' then fcnum=0 else fcnum=RGB2number(f_color) end
	if sel_b_color==nil or sel_b_color=='DEFAULT_COLOR' then selbcnum=16777215 else selbcnum=RGB2number(sel_b_color) end
	if sel_f_color==nil or sel_f_color=='DEFAULT_COLOR' then selfcnum=0 else selfcnum=RGB2number(sel_f_color) end
	return SetColor(self.t_id,row_ind,col_ind,bcnum,fcnum,selbcnum,selfcnum)
end
function QTable:Highlight(row,col_name,b_color,f_color,timeout)
	-- ïîäñâåòêà ÿ÷åéêè, ñòðî÷êè, ñòîëáóà - â çàâèñèìîñòè îò ïàðàìåòðîâ row,col_nameþ. Öâåò ôîíà - b_color, öâåò òåêñòà - f_color, çàòóõàíèå - timeout ìñ
	if VERSIONLESS6713 then return false end
	local col_ind,row_ind=nil,nil
	if row==nil then row_ind=QTABLE_NO_INDEX else row_ind=row end
	if col_name==nil then col_ind=QTABLE_NO_INDEX
	else
		col_ind = self.columns[col_name].id
		if col_ind == nil then
			message('QTable.Highlight(): No such column name - '..col_name)
			return false
		end
	end
	local bcnum,fcnum=0,0
	if b_color==nil or b_color=='DEFAULT_COLOR' then bcnum=16777215 else bcnum=RGB2number(b_color) end
	if f_color==nil or f_color=='DEFAULT_COLOR' then fcnum=0 else fcnum=RGB2number(f_color) end
	--toLog(log,'High par='..tostring(row)..tostring(col_name)..tostring(b_color)..tostring(f_color)..tostring(timeout))
	--toLog(log,'HP2 ='..row_ind..col_ind..' b='..bcnum..' f='..fcnum..' t='..timeout)
	return Highlight(self.t_id,row_ind,col_ind,bcnum,fcnum,timeout)
end
function QTable:StopHighlight(row,col_name)
	-- îòìåíà ïîäñâåòêè
	if VERSIONLESS6713 then return false end
	local col_ind,row_ind=nil,nil
	if row==nil then row_ind=QTABLE_NO_INDEX else row_ind=row end
	if col_name==nil then col_ind=QTABLE_NO_INDEX
	else
		col_ind = self.columns[col_name].id
		if col_ind == nil then
			message('QTable.StopHighlight(): No such column name - '..col_name)
			return false
		end
	end
	return Highlight(self.t_id,row_ind,col_ind,nil,nil,0)
end
function QTable:SetTableNotificationCallback(func)
	-- Çàäàíèå ôóíêöèè îáðàòíîãî âûçîâà äëÿ îáðàáîòêè ñîáûòèé â òàáëèöå
	if VERSIONLESS6713 then return false end
	if func~=nil and type(func)=='function' then
		return SetTableNotificationCallback(self.t_id,func)
	end
	return false
end