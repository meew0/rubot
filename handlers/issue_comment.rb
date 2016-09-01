module RubotHandlers::IssueComment
  def self.handle(payload)
    case payload.action
	when "created"
      %(commented on issue #{payload.tiny_issue}
      <#{payload['comment']['html_url']}>)
	when "edited"
	  %(edited comment on issue #{payload.tiny_issue}
	  <#{payload['comment']['html_url']}>)
	when "deleted"
	  %(deleted comment on issue #{payload.tiny_issue}
	  <#{payload['comment']['html_url']}>)
	end
  end
end