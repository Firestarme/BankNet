--## load APIS ##--

if not shell.resolve('SNC') == 'SNC' then
  shell.setPath(shell.path()..':disk/banknet')
end

os.loadAPI("SNC")
os.loadAPI("AMS")

--## Defining server functions and variables ##--

args = {

	cr = peripheral.find("cryptographic accelerator"),
	pr = "BankNet",
	hn = "BankServer"

}

MainCond = SNC.StConduit:newConduit(args)

function receive(cond)
	
	rec = cond:receive()
  	print(rec)
	return textutils.unserialize(rec)
	
end

function operate(o)
	
	acc = AMS.access:new(o)
	acc:open()
	ret = acc:operate()
	acc:close()
	
	return ret
	
end



--## Main Server Functionality ##--

while true do

	cond = MainCond:newConduit()
	cond:serverInit()
	
	while true do
		condSuc,o = pcall(receive,cond)
		
		if condSuc then
			
			err,ret = pcall(operate,o)
			
			cond:send(textutils.serialize({err = err,ret = ret}))
			
		else print(o)
	  	end
		
		if o.close then break end
		
	end
end
