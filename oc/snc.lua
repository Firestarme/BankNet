local lib = {}
lib.event = require("event")

function lib.sendMsg(t,msg)
  
  if t.ra ~= nil then
  
    t.modem.sendMsg(t.ra,t.p,msg)
  
  else
  
    t.modem.broadcast(t.p,msg)
  
  end
  
end

function lib.receiveMsg(t,to)
  local ra , po
  local ti = os.clock()
  
  if t.ra ~= nil then 
  
    while ra ~= t.ra and po ~= t.po do
    
      la,ra,po,d,msg = event.pull("modem_message",t.to)

      if to ~= nil then assert(ti <= to,"Request Timed Out") end
    
    end
  
  else
    
  while po ~= t.po do
    
      la,ra,po,d,msg = event.pull("modem_message",t.to)

      if to ~= nil then assert(ti <= to,"Request Timed Out") end
    
    end
  
  end
  
end

return lib

