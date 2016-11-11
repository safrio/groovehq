require 'spec_helper'

describe GrooveHQ::Client::Tickets, integration: true do

  let(:client) { GrooveHQ::Client.new }

  describe "#tickets_count" do

    it "successfully gets tickets count" do
      response = client.tickets_count
      expect(response).to be_instance_of GrooveHQ::Resource
    end

  end

  describe "#create_ticket" do
    let(:ticket) { create_ticket }

    it "successfully creates ticket" do
      expect(ticket.summary).to eq ENV['BODY']
    end

    let(:customer_hash) do
      {
        email: "customer@example.com",
        about: "Your internal reference",
        company_name: "SomeCompany Pty Ltd"
      }
    end

    let(:ticket) { create_ticket(to: customer_hash) }

    it "successfully can include customer details in ticket" do
      customer = ticket.rels['customer'].get
      expect(customer.company_name).to eq customer_hash[:company_name]
      expect(customer.email).to eq customer_hash[:email]
      expect(customer.about).to eq customer_hash[:about]
    end

  end

  describe "#ticket" do
    let(:ticket) { create_ticket }

    it "successfully gets ticket" do
      expect(ticket.data).to have_attributes(created_at: String, number: Fixnum)
    end

    it "gets the right ticket info" do
      expect(ticket.title).to eq "Hello"
    end
  end

  describe "#tickets" do
    it "successfully gets tickets" do
      response = client.tickets
      expect(response).to be_instance_of GrooveHQ::ResourceCollection
    end
  end

  context "ticket state" do
    let(:ticket) { create_ticket }

    describe "#ticket_state" do
      it "successfully gets ticket state" do
        response = client.ticket_state(ticket.number)
        expect(response).to be_instance_of String
      end
    end

    describe "#update_ticket_state" do
      it "successfully updates ticket state" do
        client.update_ticket_state(ticket.number, 'pending')
        client.update_ticket_state(ticket.number, 'opened')
        current_state = client.ticket_state(ticket.number)
        expect(current_state).to eq 'opened'
      end
    end
  end

  describe "#ticket_assignee" do
    context "when ticket has an assignee" do
      let(:ticket) { create_ticket(assignee: ENV['ASSIGNEE']) }

      it "successfully gets ticket assignee" do
        response = client.ticket_assignee(ticket.number)
        expect(response.email).to eq ENV['ASSIGNEE']
      end
    end

    context "when ticket has no assignee" do
      let(:ticket) { create_ticket }

      it "returns nil" do
        response = client.ticket_assignee(ticket.number)
        expect(response).to be_nil
      end
    end
  end

  # We cannot update ticket assignee, because we cannot create new user through API
  describe "#update_ticket_assignee" do
    let(:ticket) { create_ticket }

    it "successfully updates ticket assignee" do
      client.update_ticket_assignee(ticket.number, ENV['ADMIN'])
      current_assignee = client.ticket_assignee(ticket.number)
      expect(current_assignee.email).to eq ENV['ADMIN']
    end
  end

  describe "#update_ticket_priority" do
    let(:ticket) { create_ticket }

    it "successfully updates ticket priority" do
      client.update_ticket_priority(ticket.number, 'high')
      current_priority = client.ticket(ticket.number).priority
      expect(current_priority).to eq "high"
    end
  end

  # We cannot create assigned_group through API yet, so this test won't work
  describe "#update_ticket_assigned_group" do
    let(:ticket) { create_ticket(assignee: ENV['ASSIGNEE']) }

    it "successfully updates ticket assigned group" do
      client.update_ticket_assigned_group(ticket.number, ENV['ANOTHER_GROUP'])
      current_assigned_group = client.ticket(ticket.number).assigned_group
      expect(current_assigned_group).to eq ENV['ANOTHER_GROUP']
    end
  end
end
