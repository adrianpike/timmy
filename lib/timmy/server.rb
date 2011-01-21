module Timmy

	class Server
		attr_accessor :exec_stack, :host, :user, :raw_output
		def initialize(n)
			@host = n
			@exec_stack = []
			@roles = []
			@silent = false
			@arch = :centos
			@raw_output = false
		end
		
		def architecture; @arch; end
		
		def arch(a); @arch = a; end
		def roles(r); @roles += r; end
		def role(r); @roles << r; end
		def user(u); @user = u; end
		def silent(s); @silent = s; end
		def raw(s); @raw_output = s; end
		
		def is_role?(role); @roles.include?(role);	end
	
		def compile!
			unless @silent
				# build the execution stack based upon our roles and the kind of server we are
				# this is mostly vestigal
				if Timmy::roles[:global] then
					@exec_stack += Timmy::roles[:global].exec_stack
				end
			
				@roles.each {|r|
					Timmy::roles[r].exec_stack.each {|p|
						@exec_stack << p
					}
				}
			end
		end
	
		def connection
			begin
				@connection ||= Net::SSH.start(@host, @user)
			rescue SocketError
				raise HostUnavailable, @host
			rescue Net::SSH::AuthenticationFailed
				raise AuthFailed, @host
			end
		end

		# MEGA REFACTOR THIS, SINCE IT'S JUST YANKED FROM NET::SSH
		def execute(command, responder = nil)
			lock ||= Proc.new do |ch, type, data|
			  ch[:result] ||= ""
			  ch[:result] << data
			end
		
			channel = async_execute(command, responder)
			channel.wait
		end
	
		def async_execute(command, responder)
			connection.open_channel do |channel|
				channel.request_pty do |ch, success|
			    unless success
				  	raise Timmy::Panic, "Couldn't obtain PTY on #{@host}!"
			    end
			  end
			  channel.exec(command) do |ch, success|
			    channel.on_data do |ch2, data|
			       responder.send(:data, data)
			    end
		
			    channel.on_extended_data do |ch2, type, data|
			      responder.send(:data, data)
			    end
			
					success
			  end
			end
		end
	
	end
	
end