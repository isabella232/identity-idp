require 'rspec'
require 'rails_helper'

describe 'Recovery Code Generation' do

  it 'should generate recovery codes ans be able to verify them' do
    user = create(:user)
    rcg = RecoveryCodeGenerator.new(user)
    codes = rcg.generate

    codes.each do |code|
      success = rcg.verify code
      expect(success).to eq(true)
    end
  end

  it 'should reject invalid codes' do
    user = create(:user)
    rcg = RecoveryCodeGenerator.new(user)
    rcg.generate

    success = rcg.verify "This is a string which will never result from code generation"
    expect(success).to eq(false)
  end
end