class User < ApplicationRecord

  class << self
    ::Devise::Models.config(self, :email_regexp, :password_length)
  end

  devise(
    :database_authenticatable,
    :timeoutable,
    :validatable
  )

  validates(:email, format: email_regexp, uniqueness: { case_sensitive: false })
  validates(:password, length: { within: password_length })
end
