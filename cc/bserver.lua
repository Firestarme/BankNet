--## load APIS ##--

assert(os.loadAPI('disk/banknet/SNC'),'Could not load SNC lib')
assert(os.loadAPI('disk/banknet/AMS'),'Could not load AMS lib')

--## Defining server functions and variables ##--

args = {

	cr = peripheral.find("cryptographic accelerator"),
	pr = "BankNet",
	hn = "BankServer",
	root = peripheral.call('drive_1','getMountPath'),

}

MainCond = SNC.StConduit:newConduit(args)

function receive(cond)
	
	rec = cond:receive()
  	print(rec)
	return textutils.unserialize(rec)
	
end

function operate(o)
	
	o.root = peripheral.call('drive_2','getMountPath')..'/'
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
