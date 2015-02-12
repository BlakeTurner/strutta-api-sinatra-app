ONE_DAY = 60 * 60 * 24
SUBMISSION = {
  type: 'submission',
  title: 'Submission Round',
  start_date: Time.now.to_i,
  end_date: (Time.now + (ONE_DAY * 7)).to_i,
  rules: {
    num_entries: 2,
    interval: 'day'
  }
}
RANDOM_DRAW = {
  type: 'random_draw',
  title: 'Random Draw Round',
  start_date: (Time.now + (ONE_DAY * 7) + 1).to_i,
  end_date: (Time.now + (ONE_DAY * 8)).to_i,
  rules: {
    winners: 1,
    percentage: false
  }
}
WEBHOOK = {
  type: 'webhook',
  title: 'Webhook Round',
  start_date: (Time.now + (ONE_DAY * 8) + 1).to_i,
  end_date: (Time.now + (ONE_DAY * 9)).to_i,
  rules: {
    webhook: 'http://my.webhook.com'
  }
}
