function toggleDropdown(element) {
    var dropdown = new Dropdown(element);
    dropdown.toggle();
  }
  
  document.addEventListener('turbolinks:load', function() {
    var dropdown_buttons = document.querySelectorAll('[data-toggle="dropdown"]');
  
    dropdown_buttons.forEach(function(element) {
      element.addEventListener('click', function(event) {
        event.preventDefault();
  
        toggleDropdown(this);
      });
    });
  });
