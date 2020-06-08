module ApplicationHelper
  def full_title(page_title = '')
    base_title = "Markitplace"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def current_user_subscribed?
    logged_in? && current_user.subscribed?
  end  

  #Check to see if the current user has been assigned admin privileges
  def admin?
    logged_in? && current_user.admin?
  end

  #Implement 9+ as according to Sof
  def get_cart_length
    one_offs = current_user.cart.one_off_products.length
    subscriptions = current_user.cart.plan_types.length
    if one_offs == nil
      one_offs = 0
    end
    if subscriptions == nil
      subscriptions = 0
    end
    sum = one_offs + subscriptions
    if sum > 9
      sum = "9+"
      return sum
    end
    sum.to_s
  end

  
  # def subscribed?
  #   logged_in_user? && current_user.subscribed?
  # end



    
end
