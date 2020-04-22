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

    const stripeTokenHandler = (token) => {
        const form = document.getElementById('payment-form');
        const hiddenInput = document.createElement('input');
        hiddenInput.setAttribute('type', 'hidden');
        hiddenInput.setAttribute('name', 'stripeToken');
        hiddenInput.setAttribute('value', token.id);
        form.appendChild(hiddenInput);

        ["type", "last4", "exp_month", "exp_year"].forEach(function(field){
            addCardField(form, token, field);
        });
        //This may be something you remove
        determineCardType(card.number)

        form.submit();
    }

    function addCardField(form, token, field){
        let hiddenInput = document.createElement('input');
        hiddenInput.setAttribute('type', 'hidden');
        hiddenInput.setAttribute('name', "user[card_" + field + "]");
        hiddenInput.setAttribute('value', token.card[field]);
        form.appendChild(hiddenInput);
    }

    // This may be something you remove
    function determineCardType(card_number){
        let hiddenInput = document.createElement('input');
        hiddenInput.setAttribute('type', 'hidden');
        hiddenInput.setAttribute('name', "card_brand");
        hiddenInput.setAttribute('value', card_number.cardType);
        form.appendChild(hiddenInput);
    }


})
