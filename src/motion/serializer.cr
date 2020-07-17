require "json"
require "base64"
require "crypto/bcrypt"

module Motion
  class Serializer
    private HASH_PEPPER = "Motion"
    private NULL_BYTE   = "\0"
    private property hash_salt : String?
    getter secret = "Motion"

    def serialize(component : Motion::Base)
      state = dump(component)

      # [
      #   salted_digest(state_with_revision),
      #   encrypt_and_sign(state_with_revision),
      # ]

      state_with_class = "#{state}#{NULL_BYTE}#{component.class}"
      [
        salted_digest(state_with_class),
        encode(state_with_class),
      ]
    end

    def weak_digest(component : Motion::Base) : String
      hash(dump(component)).to_s
    end

    # TODO:
    # Possibly accept `digest` & ensure the digests match
    def deserialize(encoded_component : String)
      state_with_class = decode(encoded_component)
      # raise "BadDigestError" unless salted_digest(state_with_class) == digest

      state, component_class = state_with_class.split(NULL_BYTE)
      puts state

      component = load(state, component_class)

      # if revision == serialized_revision
      #   component
      # else
      #   component.class.upgrade_from(serialized_revision, component)
      # end

    end

    private def dump(component : Motion::Base)
      serialized_comp = component.to_json
    rescue e : Exception
      raise Exceptions::UnrepresentableStateError.new(component, e.message)
    end

    private def load(state : String, klass : String) : Motion::Base
      Motion::Base.subclasses[klass].from_json(state)
    end

    private def hash(state)
      Crypto::Bcrypt.hash_secret(state)
    end

    private def encode(state)
      Base64.strict_encode(state)
    end

    private def decode(state : String)
      Base64.decode_string(state)
    end

    def salted_digest(input)
      Base64.strict_encode(hash_salt + input)
    end

    def hash_salt
      @hash_salt ||= derive_hash_salt
    end

    def derive_hash_salt
      # TODO: Change to OpenSSL::Digest.digest
      OpenSSL::Digest.new("SHA256").update(HASH_PEPPER + secret).final.to_s
    end
  end
end
