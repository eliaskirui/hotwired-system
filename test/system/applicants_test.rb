require "application_system_test_case"

class ApplicantsTest < ApplicationSystemTestCase
  setup do
    @applicant = applicants(:one)
  end

  test "visiting the index" do
    visit applicants_url
    assert_selector "h1", text: "Applicants"
  end

  test "should create applicant" do
    visit applicants_url
    click_on "New applicant"

    fill_in "Email", with: @applicant.email
    fill_in "First name", with: @applicant.first_name
    fill_in "Job", with: @applicant.job_id
    fill_in "Last name", with: @applicant.last_name
    fill_in "Phone", with: @applicant.phone
    fill_in "Stage", with: @applicant.stage
    fill_in "Status", with: @applicant.status
    click_on "Create Applicant"

    assert_text "Applicant was successfully created"
    click_on "Back"
  end

  test "should update Applicant" do
    visit applicant_url(@applicant)
    click_on "Edit this applicant", match: :first

    fill_in "Email", with: @applicant.email
    fill_in "First name", with: @applicant.first_name
    fill_in "Job", with: @applicant.job_id
    fill_in "Last name", with: @applicant.last_name
    fill_in "Phone", with: @applicant.phone
    fill_in "Stage", with: @applicant.stage
    fill_in "Status", with: @applicant.status
    click_on "Update Applicant"

    assert_text "Applicant was successfully updated"
    click_on "Back"
  end

  test "should destroy Applicant" do
    visit applicant_url(@applicant)
    click_on "Destroy this applicant", match: :first

    assert_text "Applicant was successfully destroyed"
  end
end
