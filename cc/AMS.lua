-- ## Access Structure ##--
-- *defined by recieved table

--* n : account number to be accessed
--* f : same as n for transactions (account the money is transferred from)
--* t : same as n for transactions (account the money is transferred to)
-- na : the account info (loaded by the api)
--		-name : the name of the account holder
--		-amount : the current balance
--		-ohpin : the original hashed pin 
--		-ohtcode : the original transac code (pin alternative for transactions)
--		-frozen : whether the account has been frozen
-- fa : same as na for transactions (account the money is transferred from)
-- ta :	same as na for transactions (account the money is transferred to)
-- *q : quantity operated on by request
-- *hpin : the hashed pin supplied by the request
-- *htcode: the hashed tcode supplied by the request
-- *op : the operation that is requested (cash,transac,bal,nPin,nTcode,freeze)
-- *name : the name supplied by the request (used for creating an account)
-- *nhpin : new hashed pin (used for changing your pin)
-- *nhtcode : new hashed tcode (used for changing your tcode)

--## local utility functions ##--

local opt = {cash,transac,bal,nPin,nTcode,freeze}
local ops = 'Operation Sucessful'
	
local function readFile(path)

		h = fs.open(path,"r")
		str = h.readAll()
		h.close()
		return str

end

local function saveFile(str,path)

	h = fs.open(path,"w")
	h.write(str)
	h.close()

end	

local function log(lpath,l)

	if fs.exists(lpath) then
	
		h = fs.open(lpath,"a")
		h.writeLine(l)
		h.close()
		
	else
	
		h = fs.open(lpath,"w")
		h.writeLine(l)
		h.close()
		
	end
	
end

local function genOut(num)
	
	if num > 0 then 
	
		a = "+" 
		
	else 
	
		a = "-" 
		
	end
	
	return a..tostring(math.abs(num))

end

local function vPin(ohpin,hpin)

	assert(ohpin == hpin,"Pin Incorrect")

end

local function vTcode(ohpin,hpin,ohtcode,htcode)

	assert(ohpin == hpin or ohtcode == htcode,"Pin or transac code Incorrect")

end

local function vfrozen(frozen)

	assert(not frozen,"Your account has been frozen")

end

local function nameCheck(name,n,path)

	if fs.exists(path) then
		
		nList = textutils.unserialize(readFile(path))
		
		for k,v in pairs(nList) do 
			
			assert(name ~= v,"You already have an account")
			
		end
		
	else
			
			nList = {}
			
	end
	
	nList[n] = name
	
	saveFile(textutils.serialize(nList))

end

local function getNextNumber(path)
	
	local n
	
	if fs.exists(path) then
	
		n = tonumber(readFile(root..nxNumPath))
	
	else
	
		n = 100
	
	end
	
	saveFile(n+1,root..nxNumPath)
	
	return n
	
end

local function nilCheck(var,varname)

	assert(var ~= nil,"no "..varname.." specified")

end

local function getOpt()

	return opt

end
	
--## Account Operation Sub-API ##--

function opt.cash()
	setfenv(1,opt.access)

	vPin(na.ohpin,hpin)
	vfrozen(na.frozen)
	
	nilCheck(q,"Quantity")
	
	local b = na.amount + q
	assert(b >= 0,"Funds are unavailable")
	na.amount = b
		
	log(lRoot..n,genOut(q).." :Cash")
	
	return ops

end


function opt.transac()
	setfenv(1,opt.access)

	vTcode(fa.ohpin,hpin,fa.ohtcode,htcode)
	vFrozen(fa.frozen)
	
	nilCheck(q,"Quantity")
	
	q = math.abs(q)
	
	local b = fa.amount - q
	assert(b >= 0,"Funds are unavailable")
	fa.amount = b
		
	log(lRoot..f,genOut(-q).." :Transfered To "..t.." ("..ta.name..")")
	
	ta.amount = ta.amount + q

	log(lRoot..t,genOut(q).." :Transfered From "..f.." ("..fa.name..")")
	
	return ops
	
end

function opt.bal()
	setfenv(1,opt.access)

	return na.amount
	
end

function opt.nPin()

	vPin(na.ohpin,hpin)
	
	nilCheck(nhpin,"new pin")
	
	na.ohpin = nhpin
	
	return ops

end

function opt.nTcode()

	vPin(na.ohpin,hpin)
	
	nilCheck(nhtcode,"new transac code")
	
	na.ohtcode = nhtcode
	
	return ops

end

function opt.freeze()

	vPin(na.ohpin,hpin)
	
	na.frozen = true
	
	return ops

end
	
--## Account Access API ##--
		
access = {
	
	root = "disk/",
	aRoot = "data/accounts/",
	lRoot = "data/logs/",
	nxNumPath = "data/nxNum",
	nListPath = "data/accounts/nList",
	tonumber = tonumber,
	assert = assert,
 	print = print,
	setfenv = setfenv,
	math = math,
	textutils = textutils,
	fs = fs
	
}	

function access:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function access:open()
	setfenv(1,self)
	
	if op == "transac" then
		
		nilCheck(f,"account number (from)")
		nilCheck(t,"account number (to)")
		
		fpath = root..aRoot..f
		tpath = root..aRoot..t
		
		assert(fs.exists(fpath),"account "..f.."Does not exist")
		assert(fs.exists(tpath),"account "..t.."Does not exist")
		
		fa = textutils.unserialize(readFile(aRoot..f))
		ta = textutils.unserialize(readFile(aRoot..t))
	else
		
		nilCheck(n,"account number")
		
		path = root..aRoot..n
		
		assert(fs.exists(path),"account "..n.."Does not exist")

		na = textutils.unserialize(readFile(aRoot..n))
	end
end

function access:close()
	setfenv(1,self)
	
	if op == "transac" then
		
		saveFile(textutils.serialize(fa),fpath)
		saveFile(textutils.serialize(ta),tpath)
	
	else
	
		saveFile(textutils.serialize(na),path)
	
	end	
end

function access:operate()
	setfenv(1,self)
	
  	local opt = getOpt()
  
	opt.access = self
  	res = opt[op]()
	return res	
	
end

function access:create()
	setfenv(1,self)
	
	nilCheck(name,"name")
	nilCheck(hpin,"pin")
	nilCheck(htcode,"transac code")
	
	na = {
		
		amount = 150,	
		name = name,
		ohpin = hpin,
		ohtcode = htcode,
		frozen = false
		
	}
	
	
	n = getNextNumber()
	nameCheck(name,n,root..nListPath)
	
	path = root..aRoot..n
end

