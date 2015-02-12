$(document).ready(function() {
  // Initialize stop count
  var step = 1;

  // Intelligible flow data
  var flowData = function() {
    var roundData = JSON.parse(localStorage.rounds);
    return {
      submission_id: roundData.submission.id,
      random_draw_id: roundData.random_draw.id,
      webhook_id : roundData.webhook.id
    };
  };

  // Create Game, add Rounds, build Flow
  $('.step:not(.step-processed)').each(function() {
    // Closure vars for this element
    var $container = $(this).addClass('step-processed');
    var key = $container.attr('data-key');

    // Advance global steps, store locally
    step++;
    var nextStep = step;

    // Action buttons
    $('.action', $container).click(function() {
      var $button = $(this);

      // Get Sinatra to create the game
      if ($container.attr('data-url')) {

        // Only Flow requires dynamic data
        var postData = localStorage.hasOwnProperty('rounds') && key == 'flow' ? flowData() : {};

        // Post to url defined in data-url attribute
        $.post($container.attr('data-url'), JSON.stringify(postData), function(data) {
          // Store results locally
          localStorage[key] = data;

          // Modify UI and reveal next step
          $button.hide();
          $('.result', $container).append(prettyPrint(JSON.parse(data)));
          $('.step-' + nextStep).fadeIn();
        });
      } else {
        // Modify UI and reveal next step
        $button.hide();
        $('.step-' + nextStep).fadeIn()
      }

      // Cancel click event
      return false;
    });
  });
});
