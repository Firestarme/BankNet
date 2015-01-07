--# Access Structure #--

-- n : account number to be accessed
-- f : same as n for transactions (account the money is transferred from)
-- t : same as n for transactions (account the money is transferred to)
-- hpin : the hashed pin supplied by the request
-- htcode: the hashed tcode supplied by the request
-- op : the operation that is requested (cash,transac,bal,nPin,nTcode,freeze)
-- name : the name supplied by the request (used for creating an account)
-- nhpin : new hashed pin (used for changing your pin)
-- nhtcode : new hashed tcode (used for changing your tcode)

--# Load APIs #--

os.loadAPI('disk/banknet/SNC')
os.loadAPI('disk/banknet/AMS')

--# Define Conduit Arguments #--

args = {

	cr = peripheral.find("cryptographic accelerator"),
	pr = "BankNet",
	hn = "BankServer"

}

--# Main Body #--

MainCond = SNC.stConduit:newConduit(args)

function input(prom,covr)
	
	print(prom..' :')
	return read(covr)

end

function sendTbl(tbl)

	cond = MainCond:newConduit()
	cond:init()
	cond:send(tbl)
	
	return cond

end

opt = {}

function opt.cash(tbl)
	
	tbl.n = input('Enter Your Account Number')
	tbl.q = input('Enter The Quantity Needed')
	tbl.hpin = args.cr.hash('SHA256',input('Enter Your Pin'))
	
	return tbl

end

function opt.transac(tbl)
	
	tbl.fn = input('Enter The Source Account Number')
	tbl.tn = input('Enter The Destination Account Number')
	tbl.q = input('Enter The Quantity To Be Transferred')
	tbl.hpin = args.cr.hash('SHA256',input('Enter Your Pin'))
	tbl.htcode = args.cr.hash('SHA256',input('Enter Your TCode'))
	
	return tbl

end

function opt.bal(tbl)

	tbl.n = input('Enter Your Account Number')
	
	return tbl
	
end

function opt.nPin(tbl)

	tbl.n = input('Enter Your Account Number')
	tbl.hpin = args.cr.hash('SHA256',input('Enter Your Pin'))
	tbl.nhpin = args.cr.hash('SHA256',input('Enter Your New Pin'))
	
	return tbl

end

function opt.nTcode(tbl)
	
	tbl.n = input('Enter Your Account Number')
	tbl.hpin = args.cr.hash('SHA256',input('Enter Your Pin'))
	tbl.nhtcode = args.cr.hash('SHA256',input('Enter Your New TCode'))
	
	return tbl

end

function opt.freeze(tbl)

	tbl.n = input('Enter Your Account Number')
	tbl.hpin = args.cr.hash('SHA256',input('Enter Your Pin'))
	
	return tbl

end

while true do

	tbl = {}

	print[[Possible Operations:
	> cash ... add or remove cash from your account.
	> transac ... transaction between two accounts.
	> bal ... check your balance.
	> nPin ... change your pin.
	> nTcode ... change your transac code.
	> freeze ... freeze your account.
	]]
	tbl.op = input('Input the operation you want to complete')
	tbl = opt[tbl.op](tbl)
	
	bool,r1 = pcall(sendTbl(tbl))
	
	if bool then 
	
		bool2,rec = pcall(textutils.unserialize(r1:receive()))
		
		if bool2 then
		
				if rec.err then
				
					print(rec.ret)
				
				else
				
					print('Server Side Error : '..rec.ret)
				
				end
		
		else
		
			print('Client Side Error : '..rec)
		
		end
	
	else
	
		print('Client Side Error : '..r1)
		
	end
	
end
