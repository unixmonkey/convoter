$(document).on('ready turbolinks:load', function() {
  var loggedIn = $('#sign_out').size() > 0;
  if (loggedIn) {
    App.votes = App.cable.subscriptions.create({
      channel: 'VotesChannel'
    },
    {
      connected: function() {
        console.log('connected');
      },

      disconnected: function () {
        console.log('disconnected');
      },

      received: function(data) {
        console.log('recieved data ', data);
        if (data && data.message == 'votes_updated') {
          $('#slot_'+data.slot_id).replaceWith(data.html);
        }
      }
    }
    );
  }
});

$(document).on('click', '.title-link', function() {
  $(this).closest('article').find('.synopsis').toggleClass('hide');
});
