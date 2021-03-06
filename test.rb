# 1. replace with actual value in iaas_configuration
# 2. gem install rbvmomi
# 3. ruby test.rb > outputfile
# 4. upload outputfile

require 'rubygems'
require 'rbvmomi'

def network_identifiers
	identifiers = datacenter.network.map do |net|
		results = [net.name, net.pretty_path]
		if net.is_a?(RbVmomi::VIM::DistributedVirtualPortgroup)
			if net.config.distributedVirtualSwitch.nil?
				puts net.config.inspect
			else
				results << net.config.distributedVirtualSwitch.pretty_path + '/' + net.name
			end
		end
		results.map { |path| path.sub(/^#{datacenter.pretty_path}\/network\//, '') }
	end
	identifiers.flatten.uniq
end

def datacenter
	iaas_configuration = {
		:host=> '',
		:user => '',
		:password => '',
		:ssl => true,
		:insecure => true,
		:datacenter => ''}

	connection = RbVmomi::VIM.connect(
		host: iaas_configuration[:host],
	  user: iaas_configuration[:user],
	  password: iaas_configuration[:password],
	  ssl: iaas_configuration[:ssl],
	  insecure: iaas_configuration[:insecure],
	  )

	result = connection.searchIndex.FindByInventoryPath(inventoryPath: iaas_configuration[:datacenter])

	if result.nil?
	  fail(AuthenticationError, "Unknown datacenter #{iaas_configuration[:datacenter].inspect}.")
	elsif result.is_a? RbVmomi::VIM::Datacenter
	  result
	else
	  fail(AuthenticationError, "Found #{iaas_configuration[:datacenter].inspect} but it is not a datacenter.")
	end
end

puts network_identifiers.to_s
