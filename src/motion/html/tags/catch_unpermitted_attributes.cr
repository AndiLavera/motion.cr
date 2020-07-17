# Catch unpermitted `Avram::SaveOperation` attribute and raises a helpful error.
#
# Include this in your field components to get a nice compile-time error
# if you forgot to permit a column in your SaveOperation.
#
# This module is included in the default `Shared::Field` component in new
# Lucky apps.
module Motion::HTML::CatchUnpermittedAttribute
  # :nodoc:
  def self.new(field : Avram::Attribute, *arg, **named_args)
    Motion::HTML::InputHelpers.error_message_for_unallowed_field
  end
end
