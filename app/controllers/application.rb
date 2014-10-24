#################################
# Application
#

get '/' do
  redirect '/contacts'
end

not_found do
  @text = "That page doesn't exist"
  @title = "404"
  erb :'404'
end
