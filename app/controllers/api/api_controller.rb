require 'openssl'

module API
  class APIController < ActionController::Base
    Forbidden = Class.new(StandardError)
    private_constant :Forbidden
    rescue_from Forbidden, with: :forbidden

    Unauthorized = Class.new(StandardError)
    private_constant :Unauthorized
    rescue_from Unauthorized, with: :unauthorized

    protect_from_forgery with: :null_session
    before_action :ensure_authenticated
    after_action :ensure_access_checked

    attr_reader :subject

    protected

    def ensure_authenticated
      # Ensure API subject exists and is functioning
      @subject = APISubject[x509_cn: x509_cn]
      fail(Unauthorized, 'Subject invalid') unless @subject
      fail(Unauthorized, 'Subject not functional') unless @subject.functioning?
    end

    def ensure_access_checked
      return if @access_checked

      method = "#{self.class.name}##{params[:action]}"
      fail("No access control performed by #{method}")
    end

    def x509_cn
      fail(Unauthorized, 'Subject DN') if x509_dn.nil?

      x509_dn_parsed = OpenSSL::X509::Name.parse(x509_dn)
      x509_dn_hash = Hash[x509_dn_parsed.to_a
                          .map { |components| components[0..1] }]

      x509_dn_hash['CN'] || fail(Unauthorized, 'Subject CN invalid')

    rescue OpenSSL::X509::NameError
      raise(Unauthorized, 'Subject DN invalid')
    end

    def x509_dn
      x509_dn = request.headers['HTTP_X509_DN'].try(:force_encoding, 'UTF-8')
      x509_dn == '(null)' ? nil : x509_dn
    end

    def check_access!(action)
      fail(Forbidden) unless @subject.permits?(action)
      @access_checked = true
    end

    def public_action
      @access_checked = true
    end

    def unauthorized(exception)
      message = 'SSL client failure.'
      error = exception.message
      render json: { message: message, error: error }, status: :unauthorized
    end

    def forbidden(_exception)
      message = 'The request was understood but explicitly denied.'
      render json: { message: message }, status: :forbidden
    end
  end
end