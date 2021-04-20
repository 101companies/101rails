require 'rails_helper'

describe ListUnverifiedPages do
  it 'works' do
    page = create(:unverified_page)
    create(:page)

    result = described_class.run

    expect(result).to be_a_success

    pages = result.value[:pages]
    expect(pages.length).to eq(1)
    expect(pages.first).to eq(page)
  end

  it 'gives no page' do
    create(:page)

    result = described_class.run

    expect(result).to be_a_success

    pages = result.value[:pages]
    expect(pages.length).to eq(0)
  end
end
