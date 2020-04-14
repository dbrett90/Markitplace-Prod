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
        mail to: current_user.email, cc: "admin@markitplace.io", subject: "Markitplace Subscription Confirmation"
        #flash[:warning] = "Confirmation Email has been sent"
    end

    #Where are you pulling the vendor_email from?
    #Take a look at this tomorrow. Going to need to pull it from Stripe Id for connect
    def vendor_confirmation(current_user, vendor_email, plan_type, recipient_name, street_address_1, street_address_2, city, state, zipcode)
        @customer_name = current_user.name
        @customer_email = current_user.email
        @plan_type = plan_type
        @recipient_name = recipient_name
        @street_address_1 = street_address_1
        @street_address_2 = street_address_2
        @city = city
        @state = state
        @zipcode = zipcode
        mail to: vendor_email, cc: "admin@markitplace.io", subject: "Customer has bought a subscription on Markitplace"
    end
end
