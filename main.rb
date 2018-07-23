require 'sinatra'
# require 'sinatra/reloader'
require 'pg'
require 'pry'
require_relative "db_config"
require_relative "models/dish"
require_relative "models/comment"
require_relative "models/user"
require_relative "models/like"

enable :sessions

# sinatra methods that can be used within views
helpers do

  def current_user
    User.find_by(id: session[:user_id])
  end

  def logged_in?
    # using double-negation
    !!current_user # returns truthy if not nil

    # if current_user # returns user object or nil
    #   true
    # else
    #   false
    # end
  end

end

def run_sql(sql)
  conn = conn = PG.connect(dbname: 'goodfoodhunting')
  result = conn.exec(sql)
  conn.close
  return result
end

get '/' do

  if !logged_in?
    redirect '/login'
  end

  @dishes = Dish.all
  erb :index
end

get '/about' do
  return 'me me me'
end

# getting the form
get '/dishes/new' do
  erb :new
end

# create a dish
post '/dishes' do
  # how?
  # inputs from the form
  # sql - inserts
  # sql = "INSERT INTO dishes (name, image_url) VALUES ('#{ params[:name] }', '#{ params[:image_url] }');"
  # run_sql(sql)

  dish = Dish.new
  dish.name = params[:name]
  dish.image_url = params[:image_url]
  dish.user_id = current_user.id
  dish.save

  # get post redirect
  redirect '/'
end

# delete a dish
delete '/dishes/:id' do
  # sql = "DELETE FROM dishes WHERE id = #{ params[:id] }"
  # run_sql(sql)

  dish = Dish.find( params[:id] )
  dish.destroy

  redirect '/'
end

# showing single dish details by id
get '/dishes/:id' do
  # sql = "SELECT * FROM dishes WHERE id = '#{ params[:id] }';"
  # result = run_sql(sql) # always returns a fancy array
  # @dish = result.first
  # @comments = run_sql("SELECT * FROM comments WHERE dish_id = '#{ params[:id] }';")

  @dish = Dish.find( params[:id] ) # find is always by id, find-by you choose
  @comments = @dish.comments

  erb :dish_details
end

get '/dishes/:id/edit' do
  result = run_sql("SELECT * FROM dishes WHERE id = #{ params[:id] }")
  @dish = result.first

  erb :edit
end

put '/dishes/:id' do
  # # craft correct sql
  # sql = "UPDATE dishes SET name = '#{ params[:name] }', image_url = '#{ params[:image_url] }' WHERE id = '#{ params[:id] }';"
  # # run the sql
  # run_sql(sql)

  dish = Dish.find(params[:id])
  dish.name = params[:name]
  dish.image_url = params[:image_url]
  dish.save

  # redirect
  redirect "/dishes/#{ params[:id] }"
end

post '/comments' do
  # sql = "INSERT INTO comments (content, dish_id) VALUES ('#{ params[:content] }', #{ params[:dish_id] });"
  # run_sql(sql)

  # redirect to login if not logged in
  redirect '/login' unless logged_in?

  comment = Comment.new
  comment.content = params[:content]
  comment.dish_id = params[:dish_id]
  comment.save

  redirect "/dishes/#{ params[:dish_id] }"
end

get '/login' do

erb :login
end

post '/session' do
  # grab email and password (params)
  # find the user by email
  user = User.find_by(email: params[:email])
  # authenticate user with password
  if user && user.authenticate(params[:password])
    # create new session
    session[:user_id] = user.id
    # redirect to secret page
    redirect '/'
  else
    erb :login
  end

end

delete '/session' do
  # delete the session
  session[:user_id] = nil

  redirect '/login'
end

post '/likes' do
  like = Like.new
  like.dish_id = params[:dish_id]
  like.user_id = current_user.id
  like.save

  redirect "/dishes/#{ params[:dish_id] }"
end
