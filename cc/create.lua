--# Load APIs #--

os.loadAPI('disk/banknet/AMS')

--# Defining worker functions & Loading peripherals #--

local cr = peripheral.find('cryptographic accelerator')

function input(prom,covr)
	
	print(prom..' :')
	return read(covr)

end

--# Obtain Account Info #--

local name = input('Please Ener Your Name')
local hpin = cr.hash('SHA-512',input('Please Enter Your PIN','*'))
local htcode = cr.hash('SHA-512',input('Please Ener Your Transaction Code','*'))

--# Define Access Arguments #--

arg = {
  name = name,
  hpin = hpin,
  htcode = htcode,
  root = peripheral.call('drive_2','getMountPath')..'/'
}

--# Create Account #--

local acc = AMS.access:new(arg)
sta,err = pcall(acc:create)
if sta then
  print(acc.name..', your new account number is: '..acc.n)
else
  print(err)
end