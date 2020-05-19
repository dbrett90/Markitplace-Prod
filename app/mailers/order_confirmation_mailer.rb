class OrderConfirmationMailer < ApplicationMailer

    #In the interim added the admin email as bcc so we can actually track which orders are coming in and view them from there.  
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
        mail to: current_user.email, bcc: "admin@markitplace.io", subject: "Markitplace Subscription Confirmation"
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
        mail to: vendor_email, bcc: "admin@markitplace.io", subject: "Customer has bought a subscription on Markitplace"
    end

    def one_off_customer_confirmation(current_user, one_off_product, recipient_name, street_address_1, street_address_2, city, state, zipcode)
        @user_name = current_user.name
        @user_email = current_user.email
        @one_off_product = one_off_product
        @recipient_name = recipient_name
        @street_address_1 = street_address_1
        @street_address_2 = street_address_2
        @city = city
        @state = state
        @zipcode = zipcode
        #Make sure we're CCed on the initial emails in the beginning
        mail to: current_user.email, bcc: "admin@markitplace.io", subject: "Markitplace Order Confirmation"
    end

    def one_off_vendor_confirmation(current_user, vendor_email, one_off_product, recipient_name, street_address_1, street_address_2, city, state, zipcode)
        @customer_name = current_user.name
        @customer_email = current_user.email
        @one_off_product = one_off_product
        @recipient_name = recipient_name
        @street_address_1 = street_address_1
        @street_address_2 = street_address_2
        @city = city
        @state = state
        @zipcode = zipcode
        mail to: vendor_email, bcc: "admin@markitplace.io", subject: "Customer has bought a product on Markitplace"
    end
end
