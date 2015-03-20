
class CCallback

	attr_reader :mAttr

	def initialize(base)
		@mAttr = base
	end

	def SayHello(who, callback)
		p "Hello, " + who
		callback.call(who)
	end

	def times10(i, code)
		code.call(i)
	end

end


obj = CCallback.new(0)

func = lambda do |blck|
	return "Bye. " + blck
end

p obj.SayHello("John", func)

proc = lambda do |v|
	return v * 10
end

p obj.times10(10, proc)

