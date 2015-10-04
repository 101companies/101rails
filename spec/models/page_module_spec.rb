require 'rails_helper'

describe PageModule do

  before(:each) do

  end

  describe 'match_page_score' do

    it 'best core' do
      page = create :page

      result = PageModule.match_page_score page, page.full_title

      expect(result).to eq(-1)
    end

    it 'regular core' do
      page = create :page

      result = PageModule.match_page_score page, page.title

      expect(result).to eq(13)
    end

    it 'worst core' do
      page = create :page

      result = PageModule.match_page_score page, 'fsdfjsdf'

      expect(result).to eq(10000)
    end

  end

  describe 'contribution_array_to_string' do

    it 'joins contribution names unless they are nil' do
      t1 = 'Title1'
      t2 = 'Title2'

      result = PageModule.contribution_array_to_string [t1, t2]

      expect(result).to include(t1)
      expect(result).to include(t2)
    end

    it 'joins contribution names unless they are nil' do
      result = PageModule.contribution_array_to_string nil

      expect(result).to eq('No information retrieved')
    end

  end


end
