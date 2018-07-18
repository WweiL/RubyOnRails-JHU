class SessionsController < ApplicationController
  skip_before_action :ensure_login, only: [:new, :create]
  def new
  end

  def create
# get the user’s username and password from the submitted form
    username = params[:user][:username]
    password = params[:user][:password]
# • ﬁnd the user based on username
    user = User.find_by(username: username)
# • authenticate the user using the supplied password
# • if authenticated
    if user && user.authenticate(password)
# • store the user.id in the session
      session[:user_id] = user.id
# • redirect the caller to the root_path of the application and supply a ﬂash.notice message announcing successful login
      redirect_to root_path, notice: "Logged in successfully"
# • if not authenticated
# • redirect the caller to the login_path and supply an ﬂash.alert message
    else
      redirect_to login_path, alert: "Invalid username/passwd"
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Logged out successfully"
  end
end
