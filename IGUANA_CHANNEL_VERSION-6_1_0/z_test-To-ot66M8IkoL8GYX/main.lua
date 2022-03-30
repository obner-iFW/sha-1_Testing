
function wait(time)
   --error("bang")
   util.sleep(10000)
end


local function ProtectedMain(Data)
   iguana.setTimeout(1)
   
   if pcall(wait,nil) ==false then
      return nil, "Script took too long"
   end
   
   return "good"
   
end
 
function main(Data)   
   local Success, Err = pcall(ProtectedMain, "DataIn")
   if not Success then
      iguana.logError("Skipping error: "..Err)
   end
end