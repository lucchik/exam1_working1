source isim.do2
isim force add /exam1/rxf_l 0 -radix bin
run 32ns
run 16ns
isim force add /exam1/d 11111111 -radix bin
run 16ns
isim force add /exam1/d zzzzzzzz -radix bin
isim force add /exam1/rxf_l 1 -radix bin
run 40000000ns
