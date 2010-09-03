module Timmy
	
	class Result
		attr_accessor :status, :raw_output
		
		def initialize
			@raw_output = ''
		end
		
		def ok!
			self.status = '[SUCCESS]'
			self
		end
		
		def failure!
			self.status = '[FAILURE]'
			self
		end
		
		def noop!
			self.status = '[NOOP]'
			self
		end
	end
	
	class Task
		def initialize
			@result = Result.new
		end
		def execute(server); @result.noop!; end
		def to_s; 'Anonymous Task'; end
		def data(d)
			@result.raw_output += d # TODO: thread-safe
		end
	end
	
	class Upload < Task
		def initialize(local, options)
			@local = local
			@options = options.extract_options!
			@remote = @options[:remote] || local.dup
			super()
		end
		def to_s
			"Uploading #{@local} to #{@remote}"
		end
		def execute(server)
			if @options[:erb] then
				temp_location = '/tmp/' + Time.current.to_i.to_s
				output = File.new(temp_location, 'w')
				t = ERB.new(File.new(@local).read, nil, '%') 
				output.puts(t.result(Timmish.new(server).b))
				output.close
				@local = temp_location
			end
			if @options[:sudo] then
				# HACK ;_;
				server.connection.scp.upload!(@local,temp_location)
				server.execute("sudo mv #{temp_location} #{@remote}")
			else
				server.connection.scp.upload!(@local,@remote)
			end
			@result.ok!
		end
	end
	
	class Command < Task
		def initialize(cmd); 
			@cmd = cmd
			super()
		end
		def to_s
			"Executing `#{@cmd}`"
		end
		def execute(server)
			server.execute(@cmd, self)
			@result.ok!
		end
	end
	
	class Package < Task
		def initialize(package)
			@package = package
			super()
		end
		
		def to_s
			"Installing package #{@package}"
		end
		
		def execute(server)
			case server.architecture
				when :centos
					server.execute('sudo yum -y install ' + @package, self)
					@result.ok!
				when :ubuntu
					server.execute('sudo apt-get -y install' + @package, self)
					@result.ok!
				else
					raise UnsupportedArchitecture
			end
		end
	end
	
end