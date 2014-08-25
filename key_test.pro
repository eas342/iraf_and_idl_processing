pro key_test
repeat begin
   a = get_kbrd(1,/key_name)
   print,a
endrep until a EQ 'q'
end

