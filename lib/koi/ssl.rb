require 'openssl'

class Koi::SSL
  
  def self.generate_debug_ctx
    ctx = OpenSSL::SSL::SSLContext.new

    ctx.min_version = OpenSSL::SSL::TLS1_2_VERSION
    ctx.max_version = OpenSSL::SSL::TLS1_3_VERSION

    ctx.key = generate_private_key
    ctx.cert = generate_and_sign_cert(ctx.key, "localhost")
    
    return ctx 
  end

  def self.generate_ctx_from_files(key_path, cert_path)
    ctx = OpenSSL::SSL::SSLContext.new
    ctx.min_version = OpenSSL::SSL::TLS1_2_VERSION
    ctx.max_version = OpenSSL::SSL::TLS1_3_VERSION

    # Load private key.
    key_data = File.read(key_path)
    private_key = OpenSSL::PKey.read(key_data, nil)

    # Load the X509 certificate
    cert_data = File.read(cert_path)
    cert = OpenSSL::X509::Certificate.new(cert_data)

    # Verify that the private key matches the certificate
    if cert.check_private_key(private_key)
      raise "Error: Private key does not match the certificate!"
    end

    ctx.key = private_key
    ctx.cert = cert
    return ctx
  end
  

  def self.generate_key_and_cert(cn)
    key = generate_private_key
    cert = generate_and_sign_cert(key, cn)

    return key, cert
  end

  def self.generate_private_key
    key = OpenSSL::PKey::RSA.new(2048)
    return key
  end

  def self.generate_and_sign_cert(key, cn)
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = 1
    cert.subject = OpenSSL::X509::Name.new([['CN', cn]])
    cert.issuer = cert.subject
    cert.public_key = key.public_key
    cert.not_before = Time.now
    cert.not_after = Time.now + (60 * 60 * 24 * 365)

    cert.sign(key, OpenSSL::Digest::SHA256.new)

    return cert
  end
end
