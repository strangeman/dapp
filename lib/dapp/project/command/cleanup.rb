module Dapp
  # Project
  class Project
    # Command
    module Command
      # Cleanup
      module Cleanup
        def cleanup
          lock("#{name}.images") do
            log_step_with_indent(name) do
              project_containers_flush
              project_dangling_images_flush
              remove_images_by_query([
                'docker images',
                %(--format '{{if ne "#{stage_cache}" .Repository }}{{.ID}}{{ end }}'),
                %(-f "label=dapp=#{stage_dapp_label}")
              ].join(' ')) # FIXME: negative filter is not currently supported by the Docker CLI
            end
          end
        end
      end
    end
  end # Project
end # Dapp
