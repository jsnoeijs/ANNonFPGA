for i=(1:2450)
   if abs(abs_err(i)) >= 0.1
       i
       break
   end
end