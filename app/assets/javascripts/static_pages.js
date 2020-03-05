// function toggleDropdown(element) {
//     var dropdown = new Dropdown(element);
//     dropdown.toggle();
//   }
  
//   document.addEventListener('turbolinks:load', function() {
//     var dropdown_buttons = document.querySelectorAll('[data-toggle="dropdown"]');
  
//     dropdown_buttons.forEach(function(element) {
//       element.addEventListener('click', function(event) {
//         event.preventDefault();
  
//         toggleDropdown(this);
//       });
//     });
//   });

//   document.addEventListener('turbolinks:before-visit', function() {
//     var $navbar = $('.navbar-collapse');
    
//     if ( $navbar.hasClass('in') ) {
//       $navbar.collapse('hide');
//     }
//   });

$(document).on("turbolinks:load", function() {
    $('.dropdown-toggle').dropdown()
    AOS.init({
        once: true,
        duration: 1000,
        });
});

// $(function() {
//     AOS.init({
//         once: true,
//         duration: 1000,
//     });
//   });
  
  $('.nav-link').on('click', function(){
      AOS.refresh();
  });