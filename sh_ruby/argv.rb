# ARGV数组保存的是字符串
puts("第1个参数:#{ARGV[0]}")
puts("第2个参数:#{ARGV[1]}")
f = ARGV[0].to_i
s = ARGV[1].to_i
puts("total is: #{f+s} ")
