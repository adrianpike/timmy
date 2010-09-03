require 'rubygems'
require 'activesupport'
require 'net/ssh'
require 'net/scp'

require File.dirname(__FILE__) + '/timmy/task'
require File.dirname(__FILE__) + '/timmy/role'
require File.dirname(__FILE__) + '/timmy/server'
require File.dirname(__FILE__) + '/timmy/timmish'

module Timmy
	VERSION = '0.0.1'
	ARCHS = [ :centos, :ubuntu, :redhat, :osx, :win7 ] # Just examples for now
	
	class UnsupportedArchitecture < Exception; end
	class Panic < Exception; end
	class HostUnavailable < Exception; end
	
	mattr_accessor :roles, :servers

	def self.hosts(role = nil)
		self.servers.collect {|h,s|
			if role
				h if s.is_role?(role)
			else
				h
			end
		}
	end

	def self.role(name, &block)
		r = Role.new(name)
		r.instance_eval(&block)
		self.roles = {} unless self.roles
		self.roles[name] = r
	end
	def self.server(name, &block)
		s = Server.new(name)
		s.instance_eval(&block)
		self.servers = {} unless self.servers
		self.servers[name] = s
	end
	
	def self.dry_run!
		self.execute!(true)
	end

	# TODO: parallelize
	# It would be really neat to have a column view of all the simultaneous servers...
	def self.execute!(dry_run=false)
		self.servers.each {|n,s|
			printf "[#{n}] ----- \n"
			s.compile!
			begin
				s.exec_stack.each {|exec|
					printf exec.to_s + " : "
					$stdout.flush
					begin
						if dry_run
							printf "[DRY RUN]"
						else
							result = exec.execute(s)
							printf result.status
						end
					rescue Panic
						printf "[FAILED]"
					end
					printf "\n"
				}
			rescue HostUnavailable
				printf 'Host unavailable.' + "\n"
			end
		}
	end

	def self.run!
		printf "Hello, I'm Timmy.\n"
		unless ARGV.size>0 then
			printf "I didn't see you give me any command, so I'm going to assume you want me to compile your architecture and bring all your hosts into spec. Bail now if that's not what you want.\n"
			self.execute!
		else
			case ARGV.first
			when 'help'
				printf "RTFM.\n"
			when 'dry-run'
				self.dry_run!
			end
		end
	end	
end

at_exit {	Timmy::run! }