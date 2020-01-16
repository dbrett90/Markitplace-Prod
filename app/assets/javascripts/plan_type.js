$(".fa-chevron-circle-down").click(function() {
    $('html,body').animate({
        scrollTop: $("#plan-offerings").offset().top},
        'slow');
});