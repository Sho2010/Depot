class ApplicationController < ActionController::Base
  before_filter :authorize
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

    def current_cart
      Cart.find(session[:cart_id])
    rescue ActiveRecord::RecordNotFound
      cart = Cart.create
      session[:cart_id] = cart.id
      cart
    end

    def authorize
      #管理者userが一人もいないときは認証を素通りさせる
      return if User.count.zero?

      unless User.find_by_id(session[:user_id])
        redirect_to login_url, notice: "ログインしてください"
      end
    end
end
