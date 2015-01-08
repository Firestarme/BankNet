--## sets the default options ##--

StConduit =	{
	id = 0,
	psk = "Default",
	pr = "dftStCond",
	hn = "dftHost",
	ka = "RSA",
	ks = 526,
	ma = "RSA",
	ha = "SHA256",
	to = 50,
	suc = false,
	s = "back"
}

--## variables used ##--
-- id: target id
-- idn: recieved target id
-- psk: pre shared key (for HMAC)
-- cr: wrapped cryptographic accelerater
-- pr: protocol
-- hs: hostname
-- ka: key algorithim
-- ha: hashing algorithim
-- ma: message algorithim
-- ks: key size
-- to: timeout
-- suc: id  match sucess
-- s: side of modem

--## adds standard apis to the table ##--

	StConduit.math = math
	StConduit.pairs = pairs
	StConduit.print = print
	StConduit.setfenv = setfenv
	StConduit.textutils = textutils
	StConduit.fs = fs
	StConduit.string = string
	StConduit.rednet = rednet


--## Local functions called by the interface ##--

local function getSide()
	local s
	for k,v in pairs(peripheral.getNames()) do
		if peripheral.getType(v) == 'modem' then s = v break end
	end
	return s
end

local function loadPSK(id)
	h = fs.open("data/crypt/"..id,"r")
	str = h.readAll() 
	h.close()
	return str
end

local function deconcat(sy,str)
	a = string.match(str,"[^"..sy.."]+")
	b = string.sub(string.match(str,sy.."[^"..sy.."]+"),2)
	return a,b
end

local function generatehmac(str,psk,cr,ha)
	return cr.hash(ha,psk..cr.hash(ha,psk..str))
end

local function authhmac(hmac,str,psk,cr,ha)
	assert(hmac == generatehmac(str,psk,cr,ha),"Failed to Authenticate")
end

local function prepMsg(str,psk,cr,ha)
	return str.."$"..generatehmac(str,psk,cr,ha)
end

local function sendMsg(id,msg,pr,cr,ha)
	psk = loadPSK(id)
	rednet.send(id,prepMsg(msg,psk,cr,ha),pr)
end


local function receiveMsg(id,pr,cr,ha,to)
	local t = os.clock()
	local idn
	
	if id ~= nil then
		while idn ~= id do 
			idn,msg = rednet.receive(pr,to)
			if to ~= nil then
				if os.clock() >= t+to then error("Request Timed Out") end
			end
		end
	else
		idn,msg = rednet.receive(pr,to)
	end
	
	suc = pcall(function() psk = loadPSK(idn) end) 
	
	if suc then
		str,hmac = deconcat("$",msg)
		authhmac(hmac,str,psk,cr,ha)
	end
		return str,idn,suc
end

local function sendKey(id,pr,cr,ka,ks,cr,ha)
	pub,pri = cr.generateKeyPair(ka,ks)
	sendMsg(id,pub.encode(),pr,cr,ha)
	return pri
end

local function receiveKey(id,pr,ka,cr,ha,to)
	str,idn,suc = receiveMsg(id,pr,cr,ha,to)
	pub = cr.decodeKey(ka,str)
	return pub,idn,suc
end

local function sendMsgEnc(id,msg,pr,cr,ha,pri,ma)
	comm = pri.encrypt(ma,msg)
	sendMsg(id,comm,pr,cr,ha)
end

local function receiveMsgEnc(id,pr,cr,ha,pub,ma,to)
	comm = receiveMsg(id,pr,cr,ha,to)
	return pub.decrypt(ma,comm)
end

--## main API  ##--

function StConduit:newConduit(o,pr,hn,cr,to)
	o = o or {}
	o.pr = pr or o.pr
	o.hn = hn or o.hn
	o.cr = cr or o.cr
	o.to = to or o.to
	setmetatable(o,self)
	self.__index = self
	return o
end

function StConduit:init()
	setfenv(1,self)
	
	if s == nil then s = getSide() end
	rednet.open(s)
	
	id = rednet.lookup(pr,hn)
	pri = sendKey(id,pr..":k",cr,ka,ks,cr,ha)
	pub = receiveKey(id,pr..":k",ka,cr,ha,to)
	
end

function StConduit:serverInit()
	setfenv(1,self)

	rednet.open(s)
	
	rednet.host(pr,hn)
	
	while not suc do
		pub,id,suc = receiveKey(nil,pr..":k",ka,cr,ha)
	end
	
	pri = sendKey(id,pr..":k",cr,ka,ks,cr,ha)
	
end

function StConduit:send(msg)
	setfenv(1,self)

	sendMsgEnc(id,msg,pr,cr,ha,pri,ma)
	
end

function StConduit:receive(to)
	self.to = to or self.to
	setfenv(1,self)

	return receiveMsgEnc(id,pr,cr,ha,pub,ma,to)
end
