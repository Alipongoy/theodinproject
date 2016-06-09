require 'net/http'

url = URI('https://reddit.com')
p unknown = Net::HTTP.get(url)
