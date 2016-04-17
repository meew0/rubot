# frozen_string_literal: true

module RubotHandlers::Issues
  def self.format_issue(issue)
    number = "**##{issue['number']}**"
    title = %( **#{issue['title']}** ) + issue['labels'].map { |e| "`[#{e['name']}]`"}.join(' ')
    url = "<#{issue['html_url']}>"
    [number, title, url].join("\n")
  end

  def self.handle(payload)
    case payload.action
    when 'opened'
      %(opened issue #{format_issue(payload['issue'])})
    when 'reopened'
      %(re-opened issue #{format_issue(payload['issue'])})
    when 'closed'
      %(closed issue #{format_issue(payload['issue'])})
    when 'assigned'
      %(assigned issue #{payload.tiny_issue} to **#{payload['assignee']['login']}**
<#{payload['issue']['html_url']}>)
    when 'unassigned'
      %(unassigned issue #{payload.tiny_issue} from **#{payload['assignee']['login']}**
<#{payload['issue']['html_url']}>)
    when 'labeled'
      %(added label `[#{payload['label']['name']}]` to issue #{payload.tiny_issue}
<#{payload['issue']['html_url']}>)
    when 'unlabeled'
      %(removed label `[#{payload['label']['name']}]` from issue #{payload.tiny_issue}
<#{payload['issue']['html_url']}>)
    end
  end
end