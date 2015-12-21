require 'rails_helper'

describe VerifyPage do

  it 'verifies a page' do
    page = create(:unverified_page)
    user = create(:user)

    result = VerifyPage.run(full_title: page.full_title, user_id: user.id)
    page.reload

    expect(page.verified).to be_truthy
    expect(result).to be_a_success
  end

  it 'doesnt verify a verified page' do
    page = create(:page)
    user = create(:user)

    result = VerifyPage.run(full_title: page.full_title, user_id: user.id)
    page.reload

    expect(result).to fail_with(:page_already_verified)
  end

  it 'logs a change event' do
    page = create(:unverified_page)
    user = create(:user)

    expect {
      VerifyPage.run(full_title: page.full_title, user_id: user.id)
    }.to change{PageVerification.count}.by(1)
  end

end
