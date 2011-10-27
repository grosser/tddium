@mimic
Feature: spec command
  As a tddium user
  In order to run tests
  I want to start a test session

  Background:
    Given the command is "tddium spec"

  Scenario: Fail if user isn't logged in
    Given a git repo is initialized
    When I run `tddium spec`
    Then the exit status should not be 0
    And the output should contain "tddium login"
    And the output should contain "tddium heroku"

  Scenario: Don't remember test pattern or max-parallelism
    Given the destination repo exists
    And a git repo is initialized
    And the user is logged in with a configured suite
    And the user can create a session
    And the user successfully registers tests for the suite with test_pattern: "spec/foo"
    And the tests start successfully
    And the test all pass
    When I run `tddium spec --max-parallelism=1 --test-pattern=spec/foo`
    Then the exit status should be 0
    And the output should contain "Starting Session"
    And the output should contain "Test report"
    And options should not be saved

  Scenario: Ignore remembered test pattern and max-parallelism
    Given the destination repo exists
    And a git repo is initialized
    And the user is logged in with a configured suite and remembered options
    And the user can create a session
    And the user successfully registers tests for the suite with test_pattern: default
    And the tests start successfully
    And the test all pass
    When I run `tddium spec`
    Then the exit status should be 0
    And the output should contain "Test report"
    And the output should not contain "emembered"
    And options should not be saved

  @announce-cmd
  Scenario: Handle shell globbing
    Given the destination repo exists
    And a git repo is initialized
    And the user is logged in with a configured suite
    And the user can create a session
    And the user successfully registers tests for the suite
    And the tests start successfully
    And the test all pass
    And an empty file named "spec1.rb" 
    And an empty file named "spec2.rb" 
    When I run `tddium spec spec1.rb spec2.rb`
    Then the exit status should be 0
    And the output should contain "Test report"
    And the output should not contain "emembered"
    And options should not be saved


  Scenario: Output machine readable data with --machine
    Given the destination repo exists
    And a git repo is initialized
    And the user is logged in with a configured suite
    And the user can create a session
    And the user successfully registers tests for the suite
    And the tests start successfully
    And the test all pass
    When I run `tddium spec --machine`
    Then the exit status should be 0
    And the output should not contain "Ctrl-C"
    And the output should not contain "--->"
    And the output should contain:
      """
      %%%% TDDIUM CI DATA BEGIN %%%%
      --- 
      :session_id: 1
      %%%% TDDIUM CI DATA END %%%%
      """

  Scenario: Don't output messages with --machine
    Given the destination repo exists
    And a git repo is initialized
    And the user is logged in with a configured suite
    And the user can create a session
    And the user successfully registers tests for the suite
    And the tests start successfully
    And the test all pass with messages
    When I run `tddium spec --machine`
    Then the exit status should be 0
    And the output should not contain "Ctrl-C"
    And the output should not contain "--->"
    And the output should contain:
      """
      %%%% TDDIUM CI DATA BEGIN %%%%
      --- 
      :session_id: 1
      %%%% TDDIUM CI DATA END %%%%
      """

  Scenario: Output messages in normal mode
    Given the destination repo exists
    And a git repo is initialized
    And the user is logged in with a configured suite
    And the user can create a session
    And the user successfully registers tests for the suite
    And the tests start successfully
    And the test all pass with messages
    When I run `tddium spec`
    Then the exit status should be 0
    And the output should contain "Test report"
    And the output should contain "Ctrl-C"
    And the output should contain "--->"
    And the output should not contain:
      """
      %%%% TDDIUM CI DATA BEGIN %%%%
      --- 
      :session_id: 1
      %%%% TDDIUM CI DATA END %%%%
      """

