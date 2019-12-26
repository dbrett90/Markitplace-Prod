module ProductsHelper
    def user_add_to_library? user, product 
        user.product_subscription_library.where(user: user, product: product).any?
    end
end

