module SubscriptionsHelper
    def find_plan(stripe_subscription, subscription_plans)
        subscription_plans.each do |plan_type|
            if stripe_subscription.nickname.downcase == plan_type.name.downcase
                return plan_type
            end
        end
    end
end