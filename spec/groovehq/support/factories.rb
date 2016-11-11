module Factories
  def create_ticket(args = {})
    opts = {
      subject: "Hello",
      body: ENV['BODY'],
      from: ENV['ADMIN'],
      to: ENV['USER']
    }.merge(args)

    client.create_ticket(opts)
  end

  def create_ticket_with_assignee
    create_ticket( assignee: ENV['ASSIGNEE'] )
  end
end