// Handle tab shown events for both Bootstrap 4 and 5
$(document).ready(function() {
  // Bootstrap 5 uses 'shown.bs.tab'
  $(document).on('shown.bs.tab', function(e) {
    setTimeout(function() {
      $.fn.dataTable.tables({visible: true, api: true}).columns.adjust();
    }, 10);
  });

  // Also trigger on Shiny tab change (for navbarPage)
  $(document).on('shiny:tabactivated', function(event) {
    setTimeout(function() {
      $.fn.dataTable.tables({visible: true, api: true}).columns.adjust();
    }, 10);
  });
});

// Implement copy-to-clipboard functionality
Shiny.addCustomMessageHandler('txt', function (txt) {
    navigator.clipboard.writeText(txt);
});
