-- For each incoming message, Iguana will call the 'main' function. 
-- Its argument is a raw string containing the unparsed message.

function main(RawMsgIn)
   
   -- Keep this channel running even in the event of error
   iguana.stopOnError(false)
   
   -- Parse incoming raw messages with the hl7.parse function.
   -- This will return the parsed message 'MsgIn' and message type 'MsgType'
   local MsgIn, MsgType  = hl7.parse{vmd='example/demo.vmd', data=RawMsgIn}
   
   -- Build the outgoing HL7 Message template
   local MsgOut = hl7.message{vmd='example/demo.vmd', name=MsgType}
   
   -- Copy all fields from MsgIn to MsgOut
   MsgOut:mapTree(MsgIn)
   
   -- Set 'MyDEMO' as sending application field
   MsgOut.MSH[3][1] = 'MyDEMO'
   
   -- Uncomment the lines below to see additional field mapping in action
   --MsgOut.MSH[12][1] = '2.7'
   --MsgOut.MSH[5][1] = MsgIn.MSH[6][1]
   -- You will see immediate feedback in the annotations on the right.
   
   -- Convert the MsgOut back to a string
   local RawMsgOut = tostring(MsgOut)
   
   -- Push the resulting string back into the queue
   queue.push{data=RawMsgOut}
end