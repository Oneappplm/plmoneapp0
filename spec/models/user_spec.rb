require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'email validation' do
    it 'is invalid without a dot in the email' do
      user = User.new(email: 'test@domain') # no dot
      expect(user).to be_invalid
      expect(user.errors[:email]).to include("must contain a dot ('.')")
    end

    it 'is valid with a dot in the email' do
      user = User.new(email: 'test@domain.com') # has dot
      user.validate
      expect(user.errors[:email]).to be_empty
    end

    it 'is valid with a dot but without common TLD like .com' do
      user = User.new(email: 'test@domain.local') # has dot but custom TLD
      user.validate
      expect(user.errors[:email]).to be_empty
    end
  end
end
