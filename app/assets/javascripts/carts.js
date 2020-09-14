document.addEventListener("turbolinks:load", function() {
    const publishableKey = document.querySelector("meta[name='stripe-key']").content;
    const stripe = Stripe(publishableKey);
    var checkoutButton = document.getElementById('checkout-button');
    var dataAttribute = checkoutButton.getAttribute('data-secret');
  
    checkoutButton.addEventListener('click', function() {
      stripe.redirectToCheckout({
        sessionId: dataAttribute
      }).then(function (result) {
        // If `redirectToCheckout` fails due to a browser or network
        // error, display the localized error message to your customer
        // using `result.error.message`.
        alert(result.error.message);
      });
    });
  });