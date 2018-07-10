function read_query(packet)                         
   if string.byte(packet) == proxy.COM_QUERY then   
      --log(string.sub(packet, 2))                  
      proxy.queries:append(1, packet, {resultset_is_needed = true})                                      
      return proxy.PROXY_SEND_QUERY                 
   end                                              
end                                                 

function log(query)                                 
   output = "[" .. os.date("%Y-%m-%d %X") .. "] " .. query                                               
   local file = io.open("/log/query.log", "a")          
   file:write(output .. "\n" .. "\n")               
   file:flush()                                     
end                                                 

transaction_counter = 0                             

function read_query_result (inj)                    
  local res = assert(inj.resultset)                 
  local error_status = ""                           
  local color = ""                                  
  if res.flags.no_good_index_used then              
    error_status = error_status .. "No good index used!"                                                 
    color = "\27[33m"                               
  end                                               
  if res.flags.no_index_used then                   
    error_status = error_status .. "No index used!" 
    color = "\27[1;33m"                             
  end                                               
  local row_count = 0                               
  if res.affected_rows then                         
    row_count = res.affected_rows                   
  else                                              
    local num_cols = string.byte(res.raw, 1)        
    if num_cols > 0 and num_cols < 255 then         
      for row in inj.resultset.rows do              
        row_count = row_count + 1                   
      end                                           
    end                                             
  end                                               
  if res.query_status == proxy.MYSQLD_PACKET_ERR then                                                    
    error_status = string.format("%q", res.raw:sub(10))                                                  
    color = "\27[1;31m"                             
  end                                               
  local query = string.gsub(string.sub(inj.query, 2), "%s+", " ")                                        
  local word = string.upper(string.sub(query,1,6))  
  if word == "UPDATE" or word == "DELETE" or word == "INSERT" then                                       
    color = "\27[35m"                               
  elseif word == "COMMIT" then                      
    transaction_counter = transaction_counter - 1   
  end                                               

  local i = 0                                       
  while i < transaction_counter do                  
    i = i +1                                        
  end                                               

  if string.upper(string.sub(query,1,5)) == "BEGIN" then                                                 
    transaction_counter = transaction_counter + 1   
  end                                               
                                                    
  log(                                              
    string.format(                                  
      "%s%s; \27[0m%s\27[0m%s %fms\27[0m \27[7;31m%s\27[0m",                                             
      color,                                        
      query,                                        
      row_count == 0 and "\27[7;31m<NONE>" or "(" .. row_count .. ")",                                   
      inj.response_time > 1e5 and "\27[1;31m" or "\27[32m",                                              
      inj.response_time / 1e3,                      
      error_status                                  
    )                                               
  )                                                 
end 

