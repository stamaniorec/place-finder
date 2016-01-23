get '/sign_up' do
  erb :sign_up
end

post '/sign_up' do
  user = create_user(params)

  if user.save
    flash[:success] = 'Successfully signed up!'
    login(user)
    redirect to('/')
  else
    flash[:errors] = user.errors.full_messages
    redirect back
  end
end

get '/login' do
  erb :login
end

post '/login' do
  user = User.find_by_email(params[:email])

  if authenticate(user, params[:password])
    login(user)
    flash[:success] = "Successfully logged in as #{user.email}"
    redirect to('/')
  else
    flash[:errors] = ['Invalid email or password!']
    redirect back
  end
end

get '/logout' do
  session[:user_id] = nil
  flash[:success] = 'Successfully logged out!'
  redirect to('/')
end