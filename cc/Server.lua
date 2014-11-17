local server
local IDs = {923,924,925}
local numID = 4
local event
local id
local data
local mode
local continue == false


function recieve()
local data
local id
continue = false
while continue == false do
event,id,data = os.pullEvent("rednet")
for 1,numID do 
if id == IDs[i] then
continue == true
break
end
end
return data
return id
end
end

function recieveCons(local id)
local data
local id
continue = false
while continue == false do
event,id,data = os.pullEvent("rednet")
for 1,numID do 
if id == IDs[i] then
continue == true
break
end
end
return data
return id
end
end

function newUser()
local accountNo
local user
local file
local pin
local cardCode
if fs.exists(tostring (accountNo)) == false then
fs.copy("Default",tostring (accountNo))
file = fs.open(tostring (accountNo),"a")
file.write("user = "..string.format("%q",user))
file.write("pin = "..tostring (pin))
file.write("amount = 0")
file.write("cardCode = "..tostring cardCode)
file.close()
end
end

function withdraw()
local accountNo
local account = tostring (accountNo)
local content
local pin
local amount
local status
local length
local balence
local cardCode

status,content,length = Read(accountNo)
if status == true then
os.loadAPI(account)
balence = account.amount
if cardCode == account.cardCode then
if pin == account.pin then
if balence - amount < 0 then
balence = balence - amount
content[3] = "amount = "..balence
status = Write(accountNo,content,length)
else
return "ERROR: Not enough money"
end
else
return "ERROR: Incorrect Pin"
end
return "ERROR: Incorrect Card"
end
end
end

function deposit()
local accountNo
local account = tostring (accountNo)
local content
local pin
local amount
local status
local length
local balence
local cardCode

status,content,length = Read(accountNo)
if status == true then
os.loadAPI(account)
balence = account.amount
if cardCode == account.cardCode then
if pin == account.pin then
balence = balence + amount
content[3] = "amount = "..balence
status = Write(accountNo,content,length)
else
return "ERROR: Incorrect Pin"
end
return "ERROR: Incorrect Card"
end
end
end

function Read(local accountNo)
local file
local content = {}
local s
local w
local length = 0

if fs.exists(tostring (accountNo)) then
file = fs.open(tostring (accountNo),"r")
s = file.readAll()
file.close()
for w in string.gmatch(s,"%C+") do
content[i] = w
length = length + 1
end
return true 
return content
return length
else
return false
return "ERROR: File does not exist"
return 0
end
end

function Write(local accountNo,local content,local length)
local s
local file

if fs.exists(tostring accountNo) then
for i = 1,length do
s = s..content[i]..\n
end
file = fs.open(tostring (accountNo),"w")
file.write(s)
file.close()
return true
else 
return false
end
end

recieve()
recieveCons()
rednet.send(id,"ping")
rednet.broadcast("busy")
mode = recieve()



