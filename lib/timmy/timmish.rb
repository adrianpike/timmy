module Timmy
	class Timmish
	
		def initialize(server)
			@server = server
		end
	
		def b
			binding
		end

		def hosts(role = nil)
			Timmy::hosts(role)
		end
		
		def current_host; @server.host;	end
		def current_user; @server.user; end
		
	end
end