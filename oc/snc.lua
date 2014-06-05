local lib = {}

local event = require("event")
local com = require("component")

function lib.open(t)

	com.modem.open(t.po)
	
end

function lib.sendMsg(t,sub,msg)
  
  if t.ra ~= nil then
  
    t.modem.sendMsg(t.ra,t.port,sub,msg)
  
  else
  
    t.modem.broadcast(t.port,sub,msg)
  
  end
  
end

function lib.receiveMsg(t,to)
  local ra , po
  local ti = os.clock()
  
  if t.addr ~= nil then 
  
    while a ~= t.addr and po ~= t.port do
    
      ev,la,ra,po,d,sub,msg = event.pull("modem_message",to)

      if to ~= nil then assert(ti <= to,"Request Timed Out") end
    
    end
  
  else
    
 while po ~= t.port do
    
      ev,la,ra,po,d,sub,msg = event.pull("modem_message",to)

      if to ~= nil then assert(ti <= to,"Request Timed Out") end
    
    end
  
  end
  
  return ra,sub,msg
  
end

return lib

