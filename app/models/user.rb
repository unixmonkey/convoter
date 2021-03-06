class User < ApplicationRecord
  has_many :votes

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end

  def voted_for?(talk)
    !has_not_voted_for?(talk)
  end

  def has_not_voted_for?(talk)
    talk.votes.pluck(:user_id).exclude?(id)
  end
end
