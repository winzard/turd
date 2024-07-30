
POLY = {}
POLY.name = "POLY"
POLY.shares = 0
POLY.cashflow = 0

SBER ={}
SBER.name = "SBER"
SBER.shares = 0
SBER.cashflow = 0

NVTK = {}
NVTK.name = "NVTK"
NVTK.shares = 0
NVTK.cashflow = 0

MTSS ={}
MTSS.name = "MTSS"
MTSS.shares = 0
MTSS.cashflow = 0

AKRN = {}
ANRN.name = "AKRN"
AKRN.shares = 0
AKRN.cashflow = 0
DROPBOX = "C:\\Documents and Settings\\alexpan\\Мои документы\\Dropbox\\QUIK_VTB24\\"
portfolio = {AKRN, POLY, SBER, MTSS, NVTK}

income = 259000
pay = 164.361

function timestamp()
	return os.date("%d.%m.%Y %H:%M:%S")
end


function order(fdirection, fclasscode, fseccode, fprice, flots)
	local transaction={
					["CLASSCODE"]=fclasscode,
					["ACTION"]="NEW_ORDER",
					["ACCOUNT"]="L01-00000F00",
					["CLIENT_CODE"] = clientCode,
					["OPERATION"] = fdirection,
					["SECCODE"] = fseccode,
					["PRICE"] = fprice,
					["QUANTITY"] = flots

				}

    transaction.TRANS_ID = genid()
    local res = sendTransaction(trans)
	message(fdirection .. ": " .. flots .. " " .. fseccode .. " ПО ЦЕНЕ " .. fprice .. " " .. res, 1)
    appendto_file(DROPBOX .. "transaq.log", timestamp() .. " " .. fdirection .. " " .. fseccode .. " LOTS " .. flots .. "  PRICE " .. fprice)
    return res
end

function main()

end