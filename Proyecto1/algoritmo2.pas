repeat

if B = A then
begin
   if x = y then
      Agrego "N" a C
   else
      Agrego "B" a C
   end   
   Muevo al primero de B
   y++
   x = 0
end
else
begin
   avanzo espacio en B
   x++
end

if x > max then
begin
   agrego "x" a C
   avanzo espacio en C
   Muevo al primer B
   y++
   x = 0
end
   
until y > Max;