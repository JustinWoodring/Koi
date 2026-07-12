module Koi::Gemini::Status
  #1X
  InputExpected = 10
  InputExpectedSensitive = 11

  #2X
  Success = 20

  #3X
  TemporaryRedirection = 30
  PermanentRedirection = 31

  #4X
  RetryableGenericError = 40
  RetryableServerUnavailableError = 41
  RetryableCGIError = 42
  RetryableProxyError = 43
  RetryableSlowDownError = 44

  #5X
  PermanentGenericError = 50
  NotFound = 51
  Gone = 52
  ProxyRequestRefused = 53
  BadRequest = 59

  #60
  NeedClientCertificate = 60
  CertificateNotAuthorized = 61
  CertificateNotValid = 62
end
