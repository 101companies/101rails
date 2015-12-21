require 'rails_helper'

describe ListUnverifiedPages do

  it 'works' do
    page = create(:unverified_page)
    page2 = create(:page)

    result = ListUnverifiedPages.run

    expect(result).to be_a_success

    pages = result.value[:pages]
    expect(pages.length).to eq(1)
    expect(pages.first).to eq(page)
  end

  it 'gives no page' do
    page = create(:page)

    result = ListUnverifiedPages.run

    expect(result).to be_a_success

    pages = result.value[:pages]
    expect(pages.length).to eq(0)
  end

end
