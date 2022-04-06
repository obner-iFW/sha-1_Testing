-- This script sets Iguana up as a web service for patient name requests.
-- For each incoming request, Iguana will call the 'main' function. 

require 'node'  -- Add the shared module 'node' to this script

function main(Data)
   
   -- Parse each incoming request with net.http.parseRequest
   local Request = net.http.parseRequest{data=Data}

   -- Get 'LastName' parameter from request
   if Request.params.LastName then
      -- Send LastName to PatientSearch function to check database
      local Result, MimeType = PatientSearch(Request.params.LastName, Request.params.Format)
      net.http.respond{body=Result, entity_type=MimeType}      
      return
   end
   
   -- Return the results with net.http.respond
   net.http.respond{body=Usage}
  
end

-- Connect to database
DB = db.connect{api=db.SQLITE, name='Demo/PatientData.sqlite'}

function PatientSearch(Name, Format)
   local Result = {}
   -- Search database for Patient with requested LastName
   -- NOTE: DB:quote handles quotes in SQL statement for you
   local R = DB:query('SELECT * FROM Patient WHERE LastName = '..DB:quote(Name))
   -- Loops through results(R) from the database query
   for i = 1, #R do 
      local Patient 
      if Format == 'xml' then 
         -- Create an blank XML template
         Patient = xml.parse{data="<Patient Id='' FirstName='' LastName='' Gender=''/>"}.Patient
      else
         -- Create a blank JSON table
         Patient = {}
      end
      -- Loops each result to get each field and insert result into 'Patient' table
      Patient.Id        = R[i].Id:nodeValue()
      Patient.FirstName = R[i].FirstName:nodeValue()
      Patient.LastName  = R[i].LastName:nodeValue()
      Patient.Gender    = R[i].Gender:nodeValue()
      
      if Format == 'xml' then Result[i] = Patient:S() else Result[i] = Patient end
   end
   
   -- If XML, then runs concatenate results with table.concat
   if Format == 'xml' then
      local Output = "<AllPatients>"..table.concat(Result).."</AllPatients>"
      return Output, 'text/xml'
   else
      -- if NOT XML then Serialize 'Result' with json.serialize
      return json.serialize{data=Result}, 'text/plain'
   end
end

-- This section builds the original hyperlink to test the call to the web server
Usage=[[
<h1>USING IGUANA AS A WEB SERVICE</h1>
<p>To use this web service, please supply the following parameters:</p>
<ul>
   <li><b>LastName:</b> Please provide the last name of the patient you would like to find.</li>
   <li><b>Format:</b> Please specify if you would like your results in XML or JSON format</li>
</ul>
<p>
The following are pre-formatted requests that you can use to search for a patient with the last name "Smith".
</p>
<p>
Return the results as XML: <a href='?LastName=Smith&Format=xml'>http://localhost:6544/lookup?LastName=Smith&Format=xml</a><br>
Return the results as JSON: <a href='?LastName=Smith&Format=json'>http://localhost:6544/lookup?LastName=Smith&Format=json</a>
</p>
]]
