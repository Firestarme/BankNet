local lib = {}

local event = require("event")
local com = require("component")
local ser = require("serialization")

function lib.getPri(t)

  return com.modem,com.immibis_peripherals_crypto
  
end

local function deconcat(sy,str)

  a = string.match(str,"[^"..sy.."]+")
  b = string.sub(string.match(str,sy.."[^"..sy.."]+"),2)
  return a,b
  
end

local function split(s,l)

  a = s:sub(0,l)
  b = s:sub(l+1)
  return a,b
  
end

function lib.sendMsg(port,addr,sub,msg)
  
  if addr ~= nil then
  
    t.modem.sendMsg(addr,port,sub,msg)
  
  else
  
    t.modem.broadcast(port,sub,msg)
  
  end
  
end

function lib.receiveMsg(port,addr,to)
  local ra , po
  local ti = os.clock()
  
  if addr ~= nil then 
  
    while ra ~= addr and po ~= port do
    
      ev,la,ra,po,d,sub,msg = event.pull("modem_message",to)

      if to ~= nil then assert(ti <= to,"Request Timed Out") end
    
    end
  
  else
    
 while po ~= port do
    
      ev,la,ra,po,d,sub,msg = event.pull("modem_message",to)

      if to ~= nil then assert(ti <= to,"Request Timed Out") end
    
    end
  
  end
  
  return ra,sub,msg
  
end

function lib.sendKey(port,addr,algo,crypto,ksize)

  local pub,pri = crypto.generateKeyPair(algo,ksize)
  sendMsg(t,"key",pub)
  return pri
  
end

function lib.receiveKey(port,addr,algo,crypto,to)

  local str,idn = receiveMsg(port,addr,to)
  pub = crypto.decodeKey(algo,str)
  return pub,idn
  
end

function lib.sendMsgEnc(port,addr,msg,pri,algo)
  local b,commt = msg,{}
  for i = 1,math.ceil(msg:len()/55) do
    a,b = split(b,55)
    commt[i] = pri.encrypt(algo,a)
  end
  comm = ser.serialize(commt)
  sendMsg(port,addr,sub,comm)
end

function lib.receiveMsgEnc(port,addr,pub,algo,to)
  comm = receiveMsg(port,addr,to)
  local str = ""
  for k,v in pairs(ser.unserialize(comm)) do
    str = str..pub.decrypt(algo,v)
  end
  return str
end

return lib

