isim force add /exam1/clk 1 -radix bin -value 0 -radix bin -time 8 ns -repeat 16 ns
isim force add /exam1/vgaclk 1 -radix bin -value 0 -radix bin -time 20 ns -repeat 40 ns
isim force add /exam1/reset_h 1 -radix bin
run 40ns
isim force add /exam1/reset_h 0 -radix bin
isim force add /exam1/rxf_l 0 -radix bin
run 16ns
isim force add /exam1/d 10101010 -radix bin
run 16ns
isim force add /exam1/d 10101010 -radix bin
isim force add /exam1/rxf_l 1 -radix bin
run 8 ns
run 8ns
isim force add /exam1/d zzzzzzzz -radix bin
isim force add /exam1/rxf_l 0 -radix bin
run 32ns
isim force add /exam1/d 11111111 -radix bin
run 16ns
isim force add /exam1/rxf_l 1 -radix bin
run 16ns
run 16ns
run 16ns
