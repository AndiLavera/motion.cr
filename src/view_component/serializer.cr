# require "digest"
# require "active_support/message_encryptor"

# require "motion"
require "crystalizer/json"
require "base64"

module ViewComponent::Motion
  class Serializer
    private HASH_PEPPER = "Motion"

    NULL_BYTE = "\0"

    getter secret
    getter revision

    def self.minimum_secret_byte_length
      # ActiveSupport::MessageEncryptor.key_len
      12
    end

    def initialize(
      secret : String = "secretsecret", # = Motion.config.secret,
      revision : String = "revision"    # = Motion.config.revision
    )
      unless secret.size >= self.class.minimum_secret_byte_length
        raise "BadSecretError" # TODO: BadSecretError.new(self.class.minimum_secret_byte_length)
      end

      raise "BadRevisionError" if revision.includes?(NULL_BYTE)
      # raise BadRevisionError if revision.include?(NULL_BYTE)

      @secret = secret
      @revision = revision
    end

    def weak_digest(component)
      dump(component).hash
    end

    def serialize(component)
      state = dump(component)
      state_with_revision = "#{revision}#{NULL_BYTE}#{state}"

      [
        salted_digest(state_with_revision),
        encrypt_and_sign(state_with_revision),
      ]
    end

    def deserialize(serialized_component)
      state_with_revision = decrypt_and_verify(serialized_component)
      serialized_revision, state = state_with_revision.split(NULL_BYTE, 2)
      component = load(state)

      if revision == serialized_revision
        component
      else
        component.class.upgrade_from(serialized_revision, component)
      end
    end

    private def dump(component)
      serialized_comp = Crystalizer::JSON.serialize(component)
      enc = Base64.encode(serialized_comp)

      Marshal.dump(component)
    rescue e : TypeError
      raise "UnrepresentableStateError" # TODO: .new(component, e.message)
    end

    private def load(state)
      # TODO:
      # component = Crystalizer::JSON.deserialize(Base64.decode_string(enc), to: component.class)
      Marshal.load(state)
    end

    private def encrypt_and_sign(cleartext)
      encryptor.encrypt_and_sign(cleartext)
    end

    # private def decrypt_and_verify(cypertext)
    #   encryptor.decrypt_and_verify(cypertext)
    # rescue ActiveSupport::MessageEncryptor::InvalidMessage,
    #   ActiveSupport::MessageVerifier::InvalidSignature
    #   raise InvalidSerializedStateError
    # end

    # private def salted_digest(input)
    #   Digest::SHA256.base64digest(hash_salt + input)
    # end

    # private def encryptor
    #   @encryptor ||= ActiveSupport::MessageEncryptor.new(derive_encryptor_key)
    # end

    private def hash_salt
      @hash_salt ||= derive_hash_salt
    end

    private def derive_encryptor_key
      secret.byteslice(0, self.class.minimum_secret_byte_length)
    end

    private def derive_hash_salt
      Digest::SHA256.digest(HASH_PEPPER + secret)
    end
  end
end
