require '../lib/timmy'

Timmy.role :database do
	package 'mysql-server'
	upload 'example.conf.erb', :remote => 'example.conf', :erb => true	
end

Timmy.server 'awesome.adrianpike.com' do
	user 'apps'
	arch :centos
	role :database
end