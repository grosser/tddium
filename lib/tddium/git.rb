# Copyright (c) 2011, 2012, 2013 Solano Labs All Rights Reserved

module Tddium
  module Git
    class << self
      include TddiumConstant

      def git_changes?(options={})
        options[:exclude] ||= []
        options[:exclude] = [options[:exclude]] unless options[:exclude].is_a?(Array)
        cmd = "(git status --porcelain -uno || echo GIT_FAILED) < /dev/null 2>&1"
        p = IO.popen(cmd)
        changes = false
        while line = p.gets do
          if line =~ /GIT_FAILED/
            warn(Text::Warning::GIT_UNABLE_TO_DETECT)
            return false
          end
          line = line.strip
          status, name = line.split(/\s+/)
          next if options[:exclude].include?(name)
          if status !~ /^\?/ then
            changes = true
            break
          end
        end
        return changes
      end

      def git_version_ok
        version = nil
        begin
          version_string = `git --version`
          m =  version_string.match(Dependency::VERSION_REGEXP)
          version = m[0] unless m.nil?
        rescue Errno
        rescue Exception
        end
        if version.nil? || version.empty? then
          abort Text::Error::GIT_NOT_FOUND
        end
        version_parts = version.split(".")
        if version_parts[0].to_i < 1 ||
           version_parts[1].to_i < 7 then
          warn(Text::Warning::GIT_VERSION % version)
        end
      end

      def git_current_branch
        `git symbolic-ref HEAD`.gsub("\n", "").split("/")[2..-1].join("/")
      end

      def git_default_branch
        `git remote show origin | grep HEAD | awk '{ print $3}'`.gsub("\n", "")
      end

      def git_push(additional_refs=[])
        say Text::Process::GIT_PUSH
        this_branch = git_current_branch
        refs = ["#{this_branch}:#{this_branch}"]
        refs += additional_refs
        refspec = refs.map(&:shellescape).join(" ")
        cmd = "git push -f #{Config::REMOTE_NAME} #{refspec}"
        say "Running '#{cmd}'"
        system(cmd)
      end

      def git_repo?
        if File.directory?('.git') then
          return true
        end
        ignore = `git status 2>&1`
        ok = $?.success?
        return ok
      end

      def git_root
        root = `git rev-parse --show-toplevel 2>&1`
        if $?.exitstatus == 0 then
          root.chomp! if root
          return root
        end
        return Dir.pwd
      end

      def git_repo_name
        return File.basename(git_root)
      end

      def latest_commit
        `git log --pretty='%H%n%s%n%aN%n%aE%n%at%n%cN%n%cE%n%ct%n' HEAD^..HEAD`
      end

      def git_origin_url
        result = `(git config --get remote.origin.url || echo GIT_FAILED) 2>/dev/null`
        return nil if result =~ /GIT_FAILED/
        result.strip
      end

      def update_git_remote_and_push(git_repo_uri, additional_refs=[])
        unless `git remote show -n #{Config::REMOTE_NAME}` =~ /#{git_repo_uri}/
          `git remote rm #{Config::REMOTE_NAME} > /dev/null 2>&1`
          `git remote add #{Config::REMOTE_NAME} #{git_repo_uri.shellescape}`
        end
        git_push(additional_refs)
      end

      def git_current_commit
        `git rev-parse --verify HEAD`.strip
      end

      def git_number_of_commits(id_from, id_to)
        result = `git log --pretty='%H' #{id_from}..#{id_to}`
        result.split("\n").length
      end
    end
  end
end
