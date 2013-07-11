require 'spec_helper'

steps "User manually enters work units", :type => :feature do

  let! :client do Factory(:client, :name => 'Foo, Inc.') end
  let! :project do Factory(:project, :client => client) end
  let! :user      do Factory(:user, :current_project => project) end

  before do
    @work_unit_count = WorkUnit.count
  end

  it "should login as a user" do
    visit root_path
    fill_in "Login", :with => user.login
    fill_in "Password", :with => user.password
    click_button 'Login'
    page.should have_link("Logout")
  end

  it "should have the name of the project" do
    within "h1#headline" do
      page.should have_content(project.name)
    end
  end

  it "when I fill in valid work unit information" do
    fill_in "Start time", :with => (@start_time = (Time.now - 1.hour)).to_s(:short_datetime)
    fill_in "Stop time", :with => (@stop_time = Time.now).to_s(:short_datetime)
    fill_in "Notes", :with => "An hour of work"
    # this is not a click button cause at the immediate moment poltergeist interprets
    # this button as obscured by the JS datepicker. the truly proper solution would
    # be to click somewhere else, then do a click_button once it's visible, but
    # honestly it doesn't seem worth it to spend a lot of time on this.
    find_button("Save Changes").trigger('click')
  end

  it "should have the correct values for the work unit" do

    # although the section below checks the work unit manually, this integration test
    # is important because it forces the ajax request in capybara to complete so changes
    # are written to the database

    within("#recent_work") do
      page.should have_content("1.00")
    end

    @work_unit = WorkUnit.last
    @work_unit.hours.should == 1.00
    @work_unit.notes.should == "An hour of work"
    @work_unit.start_time.to_s.should == @start_time.to_s
    @work_unit.stop_time.to_s.should == @stop_time.to_s

  end
  it "should show the work unit in recent work" do
    within "#recent_work" do
      page.should have_content("1.00")
      page.should have_css("a[href='/work_units/#{@work_unit.id}/edit']")
    end
  end


  it "should show the work unit in current project report" do
    within "#current_project" do
      page.should have_content("An hour of work")
    end
  end

end
