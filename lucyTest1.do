isim force add /exam1/clk 1 -radix bin -value 0 -radix bin -time 8 ns -repeat 16 ns
isim force add /exam1/reset_h 1 -radix bin
isim force add /exam1/rxf_l 1 -radix bin
isim force add /exam1/vgaclk 1 -radix bin -value 0 -radix bin -time 20 ns -repeat 40 ns
run 168 ns
isim force add /exam1/reset_h 0 -radix bin
run 56ns
isim force add /exam1/rxf_l 0 -radix bin
run 24 ns
isim force add /exam1/d 10101010 -radix bin
run 20 ns
isim force add /exam1/rxf_l 1 -radix bin
isim force add /exam1/d 10101010 -radix bin
isim run 24 ns
isim force add /exam1/d ZZZZZZZZ -radix bin
run 56 ns
isim force add /exam1/rxf_l 0 -radix bin
run 32ns
run 16ns
isim force add /exam1/d 11110000 -radix bin
run 16ns
isim force add /exam1/d zzzzzzzz -radix bin
isim force add /exam1/rxf_l 1 -radix bin
run 40000000ns
