require '../lib/timmy'

Timmy.role :database do
	upload 'example.conf.erb', :remote => '/etc/example.conf', :erb => true, :sudo => true
	package 'mysql-server'
end

Timmy.role :global do
	command "wall 'lol'"
end

Timmy.server 'awesome.adrianpike.com' do
	user 'apps'
	arch :centos
	role :database
end