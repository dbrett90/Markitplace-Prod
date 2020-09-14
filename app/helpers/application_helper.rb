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

  def admin_user
    redirect_to(root_path) unless current_user.admin?
end

  #Implement 9+ as according to Sof
  #Modified for new users so that cart shows 0 when they first log on
  def get_cart_length
    if current_user.cart == nil
      return 0
    else
      cocktail_kits_length = current_user.cart.line_items.length
      if cocktail_kits_length == nil
        cocktail_kits_length = 0
      end
      if cocktail_kits_length > 9
        sum = "9+"
        return cocktail_kits_length
      end
      cocktail_kits_length.to_s
    end
  end  

  def get_guest_cart_length
    if guest_cart.line_items == nil
      val = 0
    else
      if guest_cart.line_items.length > 9
        val = "9+"
      else
        val = guest_cart.line_items.length
      end
    end
    val.to_s
  end
end
