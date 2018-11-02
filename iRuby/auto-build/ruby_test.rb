#!/usr/bin/env ruby

class Father
  # 定义了参数就一定要传入参数
  def f_method(message)
    puts(message ? message : 'nothing')
  end

  def self.make(*args)
    Father.new(*args)
  end

  def self.make_son(*args)
    Son.new(*args)
  end

  class Son
    def son_method
      puts 'son_method'
    end
  end
end

s = Father.make_son
puts s.class
s.son_method

f = Father.make
puts f.class
f.f_method 'father'

