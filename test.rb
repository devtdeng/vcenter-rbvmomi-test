require 'rubygems'
require 'rbvmomi'

def network_identifiers
	datacenter.network.map do |network|
		network.pretty_path.sub(/^#{datacenter.pretty_path}\/network\//, '')
	end
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
