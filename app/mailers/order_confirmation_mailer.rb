class OrderConfirmationMailer < ApplicationMailer
    def customer_confirmation(current_user, plan_type, recipient_name, street_address_1, street_address_2, city, state, zipcode)
        @user_name = current_user.name
        @user_email = current_user.email
        @plan_type = plan_type 
        @recipient_name = recipient_name
        @street_address_1 = street_address_1
        @street_address_2 = street_address_2
        @city = city
        @state = state
        @zipcode = zipcode
        #Remove the CC afterwards.... just for testing purposes. 
        mail to: "danbrett107@gmail.com", subject: "Markitplace Subscription Confirmation"
        #flash[:warning] = "Confirmation Email has been sent"
    end

    def vendor_confirmation(customer_name, customer_email, vendor_email, plan_type, shipping_details)
        @customer_name = customer_name
        @customer_email = customer_email
        @plan_type = plan_type
        @shipping_details = shipping_details
        mail to: vendor_email, cc: "dbrett14@gmail.com", subject: "customer has placed an order on Markitplace"
    end
end
