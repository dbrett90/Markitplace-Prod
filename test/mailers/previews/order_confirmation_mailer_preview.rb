class OrderConfirmationMailerPreview < ActionMailer::Preview

    # Preview this email at http://localhost:3000/rails/mailers/user_mailer/account_activation
    def test_order_confirmation
        OrderConfirmationMailer.test_order_confirmation
    end

    def recipe_instructions()
        OrderConfirmationMailer.recipe_instructions('Daniel', 'Brett', 'dbrett14@gmail.com', "https://drive.google.com/file/d/1uyrzP8oE2ZlyA43ug4JXr9R6GNNmhdHx/preview")
    end
  end