require "spec_helper"

describe OrderNotifier do
  describe "recieved" do
    let(:mail) { OrderNotifier.recieved }

    it "renders the headers" do
      mail.subject.should eq("Recieved")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "shipped" do
    let(:mail) { OrderNotifier.shipped }

    it "renders the headers" do
      mail.subject.should eq("Shipped")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
