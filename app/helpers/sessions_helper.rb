module SessionsHelper

    def log_in(user)
        session[:user_id] = user.id
    end

    def current_user
        if (user_id = session[:user_id])
            @current_user ||= User.find_by(id: user_id)
        elsif (user_id = cookies.signed[:user_id])
            user = User.find_by(id: user_id)
            if user && user.authenticated?(:remember, cookies[:remember_token])
              log_in user
              @current_user = user
            end
        end
    end

    #Tweak this function to catch if a user is subscribed... currently not working
    def user_subscribed?
      logged_in? && current_user.subscribed == true
    end

    #Method returns true if given user is the current one. 
    def current_user?(user)
        user == current_user
    end

    def logged_in?
        !current_user.nil?
    end

    def log_out
        forget(current_user)
        session.delete(:user_id)
        @current_user = nil
    end

    #Specifically for guest checkout
    def get_guest_cart
      if session[:cart]
        @cart = Cart.find(session[:cart])
      else
        #Create a new guest cart
        @cart = Cart.new()
        session[:cart] = @cart.id
        return @cart
      end
    end

    def remember(user)
        user.remember
        cookies.permanent.signed[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end

    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    # Redirects to stored location (or to the default).
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
