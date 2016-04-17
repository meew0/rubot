# frozen_string_literal: true

module RubotHandlers::PullRequest
  def self.format_pull_request(pull_request)
    number = "**##{pull_request['number']}**"
    title = %( **#{pull_request['title']}**)
    url = "<#{pull_request['html_url']}>"
    [number, title, url].join("\n")
  end

  def self.handle(payload)
    case payload.action
    when 'opened'
      %(opened pull request #{format_pull_request(payload['pull_request'])})
    when 'reopened'
      %(re-opened pull request #{format_pull_request(payload['pull_request'])})
    when 'closed'
      %(#{payload['pull_request']['merged'] ? 'merged' : 'closed'} pull request #{format_pull_request(payload['pull_request'])})
    when 'assigned'
      %(assigned pull request #{payload.tiny_pull_request} to **#{payload['assignee']['login']}**
<#{payload['pull_request']['html_url']}>)
    when 'unassigned'
      %(unassigned pull request #{payload.tiny_pull_request} from **#{payload['assignee']['login']}**
<#{payload['pull_request']['html_url']}>)
    when 'labeled'
      %(added label `[#{payload['label']['name']}]` to pull request #{payload.tiny_pull_request}
<#{payload['pull_request']['html_url']}>)
    when 'unlabeled'
      %(removed label `[#{payload['label']['name']}]` from pull request #{payload.tiny_pull_request}
<#{payload['pull_request']['html_url']}>)
    when 'synchronize'
      %(updated pull request #{payload.tiny_pull_request} with new commits
<#{payload['pull_request']['html_url']}>)
    end
  end
end