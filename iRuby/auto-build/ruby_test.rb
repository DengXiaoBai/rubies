#!/usr/bin/env ruby

# class Father
#   # 定义了参数就一定要传入参数
#   def f_method(message)
#     puts(message ? message : 'nothing')
#   end
#
#   def self.make(*args)
#     Father.new(*args)
#   end
#
#   def self.make_son(*args)
#     Son.new(*args)
#   end
#
#   class Son
#     def son_method
#       puts 'son_method'
#     end
#   end
# end
#
# s = Father.make_son
# puts s.class
# s.son_method
#
# f = Father.make
# puts f.class
# f.f_method 'father'
#
# z = class MyTest
#       class << self
#         self
#       end
# end
#
# puts z
#


def func(id, count)
  i = 0;
  while (i < count)
    puts "Thread#{id}  #{i} Time: #{Time.now}"
    sleep(1)
    i = i + 1
  end
end

puts "Started at #{Time.now}"
thread1 = Thread.new{func(1, 100)}
thread2 = Thread.new{func(2, 100)}
thread3 = Thread.new{func(3, 100)}
thread4 = Thread.new{func(4, 100)}

thread1.join
thread2.join
thread3.join
thread4.join
puts "Ending at #{Time.now}"