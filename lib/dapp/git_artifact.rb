module Dapp
  # Artifact from Git repo
  class GitArtifact
    attr_reader :repo
    attr_reader :name

    # rubocop:disable Metrics/ParameterLists
    def initialize(repo, to:, name: nil, branch: nil, commit: nil,
                   cwd: nil, include_paths: nil, exclude_paths: nil, owner: nil, group: nil)
      @repo = repo
      @name = name

      @branch = branch || repo.dimg.project.cli_options[:git_artifact_branch] || repo.branch
      @commit = commit

      @to = to
      cwd = File.expand_path(File.join('/', cwd))[1..-1] unless cwd.nil? || cwd.empty? # must be relative!!!
      @cwd = cwd
      @include_paths = include_paths
      @exclude_paths = exclude_paths
      @owner = owner
      @group = group
    end
    # rubocop:enable Metrics/ParameterLists

    def apply_archive_command(stage)
      credentials = [:owner, :group].map { |attr| "--#{attr}=#{send(attr)}" unless send(attr).nil? }.compact

      ["#{repo.dimg.project.install_path} #{credentials.join(' ')} -d #{to}",
       ["#{repo.dimg.project.git_path} --git-dir=#{repo.container_path} archive #{stage.layer_commit(self)}:#{cwd} #{include_paths.join(' ')}",
        "#{sudo}#{repo.dimg.project.tar_path} -x -C #{to} #{archive_command_excludes.join(' ')}"].join(' | ')]
    end

    def apply_patch_command(stage)
      current_commit = stage.layer_commit(self)
      prev_commit = stage.prev_g_a_stage.layer_commit(self)

      if prev_commit != current_commit || any_changes?(prev_commit, current_commit)
        [["#{repo.dimg.project.git_path} --git-dir=#{repo.container_path} #{diff_command(prev_commit, current_commit)}",
          "#{sudo}#{repo.dimg.project.git_path} apply --whitespace=nowarn --directory=#{to} #{patch_command_excludes.join(' ')} --unsafe-paths"].join(' | ')]
      else
        []
      end
    end

    def archive_command_excludes
      exclude_paths.map { |path| %(--exclude=#{path}) }
    end

    def patch_command_excludes
      exclude_paths.map do |path|
        base = File.join(to, path)
        path =~ /[\*\?\[\]\{\}]/ ? %(--exclude=#{base} ) : %(--exclude=#{base} --exclude=#{File.join(base, '*')})
      end
    end

    def any_changes?(from, to = latest_commit)
      !repo.git_bare(diff_command(from, to, quiet: true), returns: [0, 1]).status.success?
    end

    def patch_size(from, to)
      repo.git_bare("#{diff_command(from, to)} | wc -c").stdout.strip.to_i
    end

    def latest_commit
      @latest_commit ||= commit || repo.latest_commit(branch)
    end

    def paramshash
      Digest::SHA256.hexdigest [to, cwd, *include_paths, *exclude_paths, owner, group].map(&:to_s).join(':::')
    end

    def exclude_paths(with_cwd = false)
      base_paths(@exclude_paths, with_cwd)
    end

    def include_paths(with_cwd = false)
      base_paths(@include_paths, with_cwd)
    end

    def base_paths(paths, with_cwd = false)
      [paths].flatten.compact.map { |path| (with_cwd && cwd ? File.join(cwd, path) : path).gsub(%r{^\/*|\/*$}, '') }
    end

    def full_name
      "#{repo.name}#{name ? "_#{name}" : nil}"
    end

    protected

    attr_reader :to
    attr_reader :commit
    attr_reader :branch
    attr_reader :cwd
    attr_reader :owner
    attr_reader :group

    def sudo
      repo.dimg.project.sudo_command(owner: owner, group: group)
    end

    def diff_command(from, to, quiet: false)
      "diff --binary #{'--quiet' if quiet} #{from}..#{to} #{"--relative=#{cwd}" if cwd} -- #{include_paths(true).join(' ')}"
    end
  end
end
