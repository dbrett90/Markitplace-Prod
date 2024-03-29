document.addEventListener("turbolinks:load", function() {
    const publishableKey = document.querySelector("meta[name='stripe-key']").content;
    const stripe = Stripe(publishableKey);

   
    const elements = stripe.elements({
        fonts: [{
            cssSrc: "https://rsms.me/inter/inter.css"
        }],
        locale: "auto"
    });

    const style = {
        base: {
            color: "#32325d",
            fontWeight: 500,
            fontFamily: "Inter, Open Sans, Segoe UI, sans-serif",
            fontSize: "16px",
            fontSmoothing: "antialiased",

            "::placeholder": {
                color: "#CFD7DF"
            }
        },

        invalid: {
            color: "#E25950"
        }
    };


    const card = elements.create('card', { style });
    
    window.addEventListener('turbolinks:load', function(event) {
        if (screen.width <= 667) {
          card.update({style: {base: {fontSize: '40px'}}});
        } else {
          card.update({style: {base: {fontSize: '16px'}}});
        }
      });
    
    card.mount("#card-element");

    card.addEventListener('change', ({error}) => {
        const displayError = document.getElementById('card-errors');
        if (error) {
            displayError.textContent = error.message;
        }
        else{
            displayError.textContent="";
        }
    });

    const form = document.getElementById('payment-form');
    form.addEventListener('submit', async(event) => {
        event.preventDefault();

        const{token, error } = await stripe.createToken(card);

        if (error) {
            const errorElement = document.getElementById('card-errors');
            errorElement.textContent = error.message;
        }
        else{
            stripeTokenHandler(token);
        }
        // # var test = <%= @payment_intent_id %>;
        // alert(gon.payment_intent_id);
        // alert("TEST");
        // // alert(gon.js_user_name);
        stripe.confirmCardPayment(gon.payment_intent_id, {
            payment_method: {
                card: card,
                billing_details: {
                    name: gon.js_user_name,
                },
            },
        })  
    });

   

    const stripeTokenHandler = (token) => {
        const form = document.getElementById('payment-form');
        const hiddenInput = document.createElement('input');
        hiddenInput.setAttribute('type', 'hidden');
        hiddenInput.setAttribute('name', 'stripeToken');
        hiddenInput.setAttribute('value', token.id);
        form.appendChild(hiddenInput);

        ["brand", "last4", "exp_month", "exp_year", "id"].forEach(function(field){
            addCardField(form, token, field);
        });


        form.submit();
    }

    function addCardField(form, token, field){
        let hiddenInput = document.createElement('input');
        hiddenInput.setAttribute('type', 'hidden');
        hiddenInput.setAttribute('name', "user[card_" + field + "]");
        hiddenInput.setAttribute('value', token.card[field]);
        form.appendChild(hiddenInput);
    }
});

  