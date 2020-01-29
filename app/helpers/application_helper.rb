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

  def find_plan(stripe_subscription, subscription_plans)
    subscription_plans.each do |plan_type|
        if stripe_subscription.nickname.downcase == plan_type.name.downcase
            return plan_type
        end
    end
  end
  
  # def subscribed?
  #   logged_in_user? && current_user.subscribed?
  # end



    
end
