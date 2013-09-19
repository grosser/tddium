require 'spec_helper'
require 'tddium/cli'
require 'tddium/cli/commands/spec'

describe Tddium::TddiumCli do
  include_context "tddium_api_stubs"

  describe "#spec" do
    let(:commit_log_parser) { mock(CommitLogParser) }
    let(:suite_id) { 1 }
    let(:suite) {{ "repoman_current" => true }}
    let(:session) { { "id" => 1 } }
    let(:latest_commit) { "latest_commit" }
    let(:test_executions) { { "started" => 1, "tests" => [], "session_done" => true, "session_status" => "passed"}}

    def stub_git
      Tddium::Git.stub(:git_changes?).and_return(false)
      Tddium::Git.stub(:update_git_remote_and_push).and_return(true)
      Tddium::Git.stub(:latest_commit).and_return(latest_commit)
    end

    def stub_commit_log_parser
      commit_log_parser.stub(:commits).and_return([latest_commit])
      CommitLogParser.stub(:new).with(latest_commit).and_return(commit_log_parser)
    end

    before do
      stub_git
      stub_commit_log_parser
      tddium_api.stub(:current_suite_id).and_return(suite_id)
      tddium_api.stub(:get_suite_by_id).and_return(suite)
      tddium_api.stub(:update_suite)
      tddium_api.stub(:create_session).and_return(session)
      tddium_api.stub(:register_session)
      tddium_api.stub(:start_session).and_return(test_executions)
      tddium_api.stub(:poll_session).and_return(test_executions)
    end

    it "should create a new session" do
      tddium_api.should_receive(:create_session).with(suite_id, :commits => [latest_commit])
      subject.spec
    end
  end
end