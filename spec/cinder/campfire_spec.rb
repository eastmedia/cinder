require File.dirname(__FILE__) + "/../spec_helper"

module Cinder
  describe Campfire do

    before(:each) do
      @campfire = Campfire.new 'domain', :ssl => false
      @page = mock("Page")
      @page.stub!(:uri).and_return(@campfire.uri)
      @page.stub!(:links).and_return([])
      @mechanize = mock("Mechanize agent", :post => true)
      @mechanize.stub!(:page).and_return @page
      @campfire.stub!(:agent).and_return @mechanize
    end

    it "should login with email address and password" do
      @campfire.stub!(:login_with_email_and_password).and_return @page
      @campfire.login("email", "password")
      @campfire.should be_logged_in
    end

    it "should not login with invalid email address" do
      login_page = mock("Login page")
      login_page.stub!(:uri).and_return(URI.parse("#{@campfire.uri}/login"))
      @campfire.stub!(:login_with_email_and_password).and_return login_page
      lambda {
        @campfire.login("wrong_email", "password")
      }.should raise_error(Cinder::Error, "Campfire login failed")
    end

    it "should create a post request on login" do
      @mechanize.should_receive(:post).with("http://domain.campfirenow.com/login", "email_address" => "email_address", "password" => "password").and_return(@mechanize)
      @campfire.login_with_email_and_password("email_address", "password")
    end

    it "should have protocol https if created with ssl turned on" do
      @campfire = Campfire.new 'domain', :ssl => true
      @campfire.uri.to_s.should == "https://domain.campfirenow.com"
    end

  end
end
