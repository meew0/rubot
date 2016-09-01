module RubotHandlers::IssueComment
  def self.handle(payload)
    return if payload.action == "edited" or payload.action == "deleted" 
    %(commented on issue #{payload.tiny_issue}
<#{payload['comment']['html_url']}>)
  end
end