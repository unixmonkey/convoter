
$(document).on('click', 'a[data-toggle=tab]', function() {
  var day_index = $(this).attr('href').replace('#day_', ''); // "0" and up
  $.get(document.location.href + '/set_day/' + day_index);
})
