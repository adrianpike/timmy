module Timmy
	
	class Role
		attr_accessor :name, :exec_stack
		
		def initialize(n)
			@name = n
			@exec_stack = []
		end
		
		def package(name)
			@exec_stack << Timmy::Package.new(name)
		end
		
		def command(cmd)
			@exec_stack << Timmy::Command.new(cmd)
		end

    def cap(task, *options)
      @exec_stack << Timmy::Capistrano.new(task, options)
    end

		def upload(local, *options)
			@exec_stack << Timmy::Upload.new(local, options)
		end
		
	end
	
end