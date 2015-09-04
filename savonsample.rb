require 'savon'

# create a client for the service
p client = Savon.client(wsdl: 'http://www.webservicex.net/uszip.asmx?WSDL')

puts("--")

p client.operations
# => [:find_user, :list_users]

puts("--")

# call the 'findUser' operation
p response = client.call(:find_user, message: { id: 42 })

p response.body
# => { find_user_response: { id: 42, name: 'Hoff' } }