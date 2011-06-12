jQuery(function() {
  $("a").live("click", function(e) {
    jQuery.get(this.href, function(data) {
      $("body").append(data);
    });

    e.preventDefault();
  });
});

