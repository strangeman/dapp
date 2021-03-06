module Dapp
  module Build
    module Stage
      module SetupGroup
        # GAPostSetupPatch
        class GAPostSetupPatch < GABase
          include Mod::Group

          def initialize(dimg, next_stage)
            @prev_stage = GAPostSetupPatchDependencies.new(dimg, self)
            super
          end

          def prev_g_a_stage
            super.prev_stage # GAPreSetupPatch
          end

          def next_g_a_stage
            next_stage.next_stage
          end
        end # GAPostSetupPatch
      end
    end # Stage
  end # Build
end # Dapp
