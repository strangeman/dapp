module Dapp
  class CLI
    class Stages
      # stages cleanup repo subcommand
      class CleanupRepo < CleanupLocal
        banner <<BANNER.freeze
Version: #{Dapp::VERSION}

Usage:
  dapp stages cleanup repo [options] [DIMGS PATTERN ...] REPO

    DIMGS PATTERN               Dapp images to process [default: *].

Options:
BANNER
        def run(argv = ARGV)
          self.class.parse_options(self, argv)
          repo = self.class.required_argument(self)
          Project.new(cli_options: config, dimgs_patterns: cli_arguments).stages_cleanup_repo(repo)
        end
      end
    end
  end
end
