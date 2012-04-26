# Copyright (c) 2011, 2012 Solano Labs All Rights Reserved

module Tddium
  class TddiumCli
    desc "config [SCOPE=suite]", "Display config variables for SCOPE (account, repo, suite)"
    def config(scope="suite")
      set_shell
      set_default_environment
      user_details = user_logged_in?(true, true)
      exit_failure unless git_repo? && user_details && suite_for_current_branch?

      begin
        config_details = call_api(:get, env_path(scope))
        show_config_details(scope, config_details['env'])
      rescue TddiumClient::Error::API => e
        exit_failure Text::Error::LIST_CONFIG_ERROR
      end
    end

    desc "config:add [SCOPE] [KEY] [VALUE]", "Set KEY=VALUE at SCOPE (of account, repo, suite)"
    define_method "config:add" do |scope, key, value|
      set_shell
      set_default_environment
      user_details = user_logged_in?(true, true)
      exit_failure unless git_repo? && user_details && suite_for_current_branch?

      begin
        say Text::Process::ADD_CONFIG % [key, value, scope]
        result = call_api(:post, env_path(scope), :env=>{key=>value})
        say Text::Process::ADD_CONFIG_DONE % [key, value, scope]
      rescue TddiumClient::Error::API => e
        exit_failure Text::Error::ADD_CONFIG_ERROR
      end
    end

    desc "config:remove [SCOPE] [KEY]", "Remove config variable NAME from SCOPE"
    define_method "config:remove" do |scope, key|
      set_shell
      set_default_environment
      user_details = user_logged_in?(true, true)
      exit_failure unless git_repo? && user_details && suite_for_current_branch?

      begin
        say Text::Process::REMOVE_CONFIG % [key, scope]
        result = call_api(:delete, env_path(scope, key))
        say Text::Process::REMOVE_CONFIG_DONE % [key, scope]
      rescue TddiumClient::Error::API => e
        exit_failure Text::Error::REMOVE_CONFIG_ERROR
      end
    end
  end
end  
