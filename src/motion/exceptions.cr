module Motion
  module Exceptions
    class BaseError < Exception; end

    class AlreadyConfiguredError < BaseError
      def initialize
        super(
          "Motion is already configured.\n" \
          "\n" \
          "Hint: Move all Motion config to `config/initializers/motion.cr`."
        )
      end
    end

    class ComponentError < BaseError
      getter component : Motion::Base

      def initialize(@component, message = nil)
        super(message)
      end
    end

    class ComponentRenderingError < ComponentError; end

    class MultipleRootsError < ComponentRenderingError
      def initialize(@component)
        super(
          component,
          "The template for #{component.class} can only have one root " \
          "element.\n" \
          "\n" \
          "Hint: Wrap all elements in a single element, such as `<div>` or " \
          "`<section>`."
        )
      end
    end

    class InvalidComponentStateError < ComponentError; end

    class UnrepresentableStateError < InvalidComponentStateError
      def initialize(component, cause)
        super(
          component,
          "Some state prevented `#{component.class}` from being serialized " \
          "into a string. Motion components must be serializable using " \
          "`Crystalizer::JSON.serialize`. " \
          "See the documentation for `Crystalizer::JSON.serialize` for more information.\n" \
          "https://github.com/j8r/crystalizer\n" \
          "\n" \
          "The specific error from Crystalizer::JSON.serialize` was: #{cause}\n" \
          "\n" \
          "Hint: Ensure that any exotic state variables in " \
          "`#{component.class}` are removed or replaced."
        )
      end
    end

    class MotionBaseMethodError < BaseError
      def initialize(method)
        super(
          "Motion::Base##{method} should not be invoked.\n"
        )
      end
    end

    class IncompatibleClientError < BaseError
      def initialize(server_version, client_version)
        super(
          "The client version (#{client_version}) is not the same as the server " \
          "version (#{server_version}). Please sychronize the shard & npm versions.\n" \
          )
      end
    end

    # class MotionNotMapped < ComponentError
    #   attr_reader :motion

    #   def initialize(component, motion)
    #     super(
    #       component,
    #       "No component motion handler mapped for motion `#{motion}` in " \
    #       "component `#{component.class}`.\n" \
    #       "\n" \
    #       "Hint: Consider adding `map_motion :#{motion}` to `#{component.class}`."
    #     )

    #     @motion = motion
    #   end
    # end

    # class BlockNotAllowedError < ComponentRenderingError
    #   def initialize(component)
    #     super(
    #       component,
    #       "Motion does not support rendering with a block.\n" \
    #       "\n" \
    #       "Hint: Try wrapping a plain component with a motion component."
    #     )
    #   end
    # end

    # class RenderAborted < ComponentRenderingError
    #   def initialize(component)
    #     super(component, <<~MSG)
    #       Rendering #{component.class} was aborted by a callback.
    #     MSG
    #   end
    # end

    # class SerializedComponentError < Error; end

    # class InvalidSerializedStateError < SerializedComponentError
    #   def initialize
    #     super(
    #       "The serialized state of your component is not valid.\n" \
    #       "\n" \
    #       "Hint: Ensure that you have not tampered with the contents of data " \
    #       "attributes added by Motion in the DOM or changed the value of " \
    #       "`Motion.config.secret`."
    #     )
    #   end
    # end

    # class UpgradeNotImplementedError < ComponentError
    #   attr_reader :previous_revision,
    #     :current_revision

    #   def initialize(component, previous_revision, current_revision)
    #     super(
    #       component,
    #       "Cannot upgrade `#{component.class}` from a previous revision of the " \
    #       "application (#{previous_revision}) to the current revision of the " \
    #       "application (#{current_revision})\n" \
    #       "\n" \
    #       "By default, Motion does not allow components from other revisions " \
    #       "of the application to be mounted because new code with old state " \
    #       "can lead to unpredictable and unsafe behavior.\n" \
    #       "\n" \
    #       "Hint: If you would like to allow this component to surive " \
    #       "deployments, consider providing an alternative implimentation for " \
    #       "`#{component.class}.upgrade_from`."
    #     )

    #     @previous_revision = previous_revision
    #     @current_revision = current_revision
    #   end
    # end

    # class BadSecretError < Error
    #   attr_reader :minimum_bytes

    #   def initialize(minimum_bytes)
    #     super(
    #       "The secret that you provided is not long enough. It must be at " \
    #       "least #{minimum_bytes} bytes long."
    #     )
    #   end
    # end

    # class BadRevisionError < Error
    #   def initialize
    #     super("The revision cannot contain a NULL byte.")
    #   end
    # end

    # class BadRevisionPathsError < Error
    #   def initialize
    #     super(
    #       "Revision paths must be a `Rails::Paths::Root` object or an object " \
    #       "that responds to `all_paths.flat_map(&:existent)` and returns an " \
    #       "Array of strings representing full paths."
    #     )
    #   end
    # end
  end
end
