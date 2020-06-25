document.addEventListener("turbolinks:load", function() {
    const publishableKey = document.querySelector("meta[name='stripe-key']").content;
    const stripe = Stripe(publishableKey);

    //Establish the elements & Associated Styles
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
    //update size based on device
    window.addEventListener('turbolinks:load', function(event) {
        if (screen.width <= 667) {
          card.update({style: {base: {fontSize: '40px'}}});
        } else {
          card.update({style: {base: {fontSize: '16px'}}});
        }
      });
    //Need to check to see if the card exists elsewhere. Add this in at a later date.
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
    });

    //Focus on getting JS secret in. 

    // form.addEventListener('submit', function(ev) {
    //     ev.preventDefault();
    //     stripe.confirmCardPayment(clientSecret, {
    //       payment_method: {
    //         card: card,
    //         billing_details: {
    //           name: 'Jenny Rosen'
    //         }
    //       }
    //     }).then(function(result) {
    //       if (result.error) {
    //         // Show error to your customer (e.g., insufficient funds)
    //         console.log(result.error.message);
    //       } else {
    //         // The payment has been processed!
    //         if (result.paymentIntent.status === 'succeeded') {
    //           console.log("THIS HAS SUCCEEDED")
    //         }
    //       }
    //     });
    //   });

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
        //This may be something you remove
        // determineCardType(card.number)

        form.submit();
    }

    function addCardField(form, token, field){
        let hiddenInput = document.createElement('input');
        hiddenInput.setAttribute('type', 'hidden');
        hiddenInput.setAttribute('name', "user[card_" + field + "]");
        hiddenInput.setAttribute('value', token.card[field]);
        form.appendChild(hiddenInput);
    }

    // var response = fetch('/secret').then(function(response) {
    //     return response.json();
    //   }).then(function(responseJson) {
    //     var clientSecret = responseJson.client_secret;
    //     // Call stripe.confirmCardPayment() with the client secret.
    //   });

    //   form.addEventListener('submit', function(ev) {
    //     ev.preventDefault();
    //     stripe.confirmCardPayment(clientSecret, {
    //       payment_method: {
    //         card: card,
    //         billing_details: {
    //           name: 'Daniel Michael'
    //         }
    //       }
    //     }).then(function(result) {
    //       if (result.error) {
    //         // Show error to your customer (e.g., insufficient funds)
    //         console.log(result.error.message);
    //       } else {
    //         // The payment has been processed!
    //         if (result.paymentIntent.status === 'succeeded') {
    //           // Show a success message to your customer
    //           // There's a risk of the customer closing the window before callback
    //           // execution. Set up a webhook or plugin to listen for the
    //           // payment_intent.succeeded event that handles any business critical
    //           // post-payment actions.
    //         }
    //       }
    //     });
    //   });

    // Dynamically change the styles of an element

    // This may be something you remove
    // function determineCardType(card_number){
    //     let hiddenInput = document.createElement('input');
    //     hiddenInput.setAttribute('type', 'hidden');
    //     hiddenInput.setAttribute('name', "card_brand");
    //     hiddenInput.setAttribute('value', card_number.cardType);
    //     form.appendChild(hiddenInput);
    // }


})
