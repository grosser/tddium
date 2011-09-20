Given /^the user is logged in$/ do
  @api_key = "abcdef"
  Antilles.install(:get, "/1/users", SAMPLE_USER_RESPONSE)
  Antilles.install(:get, "/1/accounts/usage", SAMPLE_ACCOUNT_USAGE)
  steps %Q{
    Given a file named ".tddium.mimic" with:
    """
    {"api_key":"#{@api_key}"}
    """
  }
end

Given /^the user can log in and gets API key "([^"]*)"$/ do |apikey|
  Antilles.install(:post, "/1/users/sign_in", {:status=>0, :api_key=>apikey})
end

Given /^the user cannot log in$/ do
  Antilles.install(:post, "/1/users/sign_in", {:status=>1, :explanation=>"Access Denied."}, :code=>403)
end

Then /^dotfiles should be updated$/ do
  steps %Q{
    And the file ".tddium.mimic" should contain "apikey"
    And the file ".gitignore" should contain ".tddium.mimic"
    And the file ".gitignore" should contain ".tddium-deploy-key.mimic"
  }
end