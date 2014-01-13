# Copyright (c) 2011, 2012, 2013 Solano Labs All Rights Reserved

module Tddium
  class TddiumCli < Thor
    map "show" => :describe
    desc "describe [SESSION]", "Describe the state of a session, if it
    is provided; otherwise, the latest session on current branch."
    method_option :account, :type => :string, :default => nil,
      :aliases => %w(--org --organization)
    method_option :all, :type=>:boolean, :default=>false, :desc=>"Show all results, not just failures"
    method_option :type, :type=>:string, :default=>nil, :desc=>"Restrict by result type"
    method_option :json, :type=>:boolean, :default=>false, :desc=>"Format output as JSON"
    method_option :names, :type=>:boolean, :default=>false, :desc=>"Print result names only, space-separated"
    method_option :output, :type=>:string, :lazy_default=>:unspecified, :desc=>"Include raw test output, name filtered"
    def describe(session_id=nil)
      tddium_setup({:repo => false})

      if !session_id then
        # params to get the most recent session id on current branch
        suite_params = {
          :suite_id => @tddium_api.current_suite_id,
          :active => false,
          :limit => 1
        } if suite_for_current_branch?

        sessions = suite_params ? @tddium_api.get_sessions(suite_params) : []
        if sessions.empty? then
          exit_failure Text::Status::NO_INACTIVE_SESSION
        end

        session_id = sessions[0]['id']
      end

      result = @tddium_api.query_session(session_id)

      filtered = result['session']['tests']
      if !options[:all]
        filtered = filtered.select{|x| x['status'] == 'failed'}
      end

      if options[:type]
        filtered = filtered.select{|x| x['test_type'].downcase == options[:type].downcase}
      end

      if options[:output] && !options[:json]
        exit_failure Text::Error::DESCRIBE_OUTPUT_MUST_BE_JSON
      end

      tests_with_full_output = filtered.select{ |x| options[:output] == :unspecified || x['test_name'] =~ /#{options[:output]}/ }.map{|x| x["id"]}

      if tests_with_full_output.size > Default::MAX_OUTPUT_SIZE
        exit_failure Text::Error::DESCRIBE_OUTPUT_TOO_MANY_TESTS
      end

      if options[:json]
        output_annotated = filtered.map do |x|
          if tests_with_full_output.include?(x["id"])
            x["output"] = @tddium_api.get_test_exec(session_id, x["id"])["result"]
            x
          else
            x
          end
        end
        result["session"]["tests"] = output_annotated
        puts JSON.pretty_generate(result["session"])
      elsif options[:names]
        say filtered.map{|x| x['test_name']}.join(" ")
      else
        filtered.sort!{|a,b| [a['test_type'], a['test_name']] <=> [b['test_type'], b['test_name']]}

        say Text::Process::DESCRIBE_SESSION % [session_id, result["session"]["session_status"], options[:all] ? 'all' : 'failed']

        table = 
          [["Test", "Status", "Duration", "ID"],
           ["----", "------", "--------", "-----------"]] +
          filtered.map do |x|
          [
            x['test_name'],
            x['status'],
            x['elapsed_time'] ? "#{x['elapsed_time']}s" : "-",
            x['id']
          ]
          end
        print_table table
      end
    end
  end
end
