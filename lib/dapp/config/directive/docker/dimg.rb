module Dapp
  module Config
    module Directive
      module Docker
        # Dimg
        class Dimg < Base
          attr_reader :_volume, :_expose, :_env, :_label, :_cmd, :_onbuild, :_workdir, :_user, :_entrypoint

          def initialize
            @_volume = []
            @_expose = []
            @_env = {}
            @_label = {}
            @_cmd = []
            @_onbuild = []

            super
          end

          def volume(*args)
            @_volume.concat(args)
          end

          def expose(*args)
            @_expose.concat(args)
          end

          def env(**options)
            @_env.merge!(options)
          end

          def label(**options)
            @_label.merge!(options)
          end

          def cmd(*args)
            @_cmd.concat(args)
          end

          def onbuild(*args)
            @_onbuild.concat(args)
          end

          def workdir(val)
            @_workdir = val
          end

          def user(val)
            @_user = val
          end

          def entrypoint(*cmd_with_args)
            @_entrypoint = cmd_with_args.flatten
          end

          def _change_options
            {
              volume: _volume,
              expose: _expose,
              env: _env,
              label: _label,
              cmd: _cmd,
              onbuild: _onbuild,
              workdir: _workdir,
              user: _user,
              entrypoint: _entrypoint
            }
          end

          protected

          def clone_to_artifact
            Artifact.new.tap do |docker|
              docker.instance_variable_set('@_from', @_from)
            end
          end
        end
      end
    end
  end
end
