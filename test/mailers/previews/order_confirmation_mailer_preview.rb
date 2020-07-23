class OrderConfirmationMailerPreview < ActionMailer::Preview

    # Preview this email at http://localhost:3000/rails/mailers/user_mailer/account_activation
    def test_order_confirmation
        OrderConfirmationMailer.test_order_confirmation
    end
  
  end