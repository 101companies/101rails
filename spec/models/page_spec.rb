require 'rails_helper'

describe Page do
  describe 'preparing_the_page' do
    it 'parses the page' do
      page = create :page

      expect(page.used_links).to include('Abstraction',
                                         'MemberOf::Vocabulary:Programming',
                                         'RelatesTo::Result',
                                         'IsA::Concept')
    end
  end

  describe 'describe render page' do
    it 'renders the page' do
      page = create :page

      expect(page.render).to include('abstraction')
    end
  end

  describe 'get_metadata_section' do
    it 'gives the section if metadata exists' do
      page = create :page

      expect(page.get_metadata_section).not_to be_nil
    end

    it 'gives nil if metadata does not exists' do
      page = create :page_without_metadata

      expect(page.get_metadata_section).to be_nil
    end
  end

  describe 'inject_triple' do
    it 'inserts a triple into a page with metadata' do
      page = create :page

      page.inject_triple 'instanceOf::something'
      page.parse
      expect(page.get_metadata_section['content']).to include('[[instanceOf::something]]')
    end

    it 'inserts a triple into a page without metadata' do
      page = create :page_without_metadata

      page.inject_triple 'instanceOf::something'
      page.parse
      expect(page.get_metadata_section['content']).to include('[[instanceOf::something]]')
    end
  end

  describe 'decorate_headline' do
    it 'cuts too long headline' do
      page = create :page_with_long_headline

      result = page.decorate_headline page.title

      expect(result).to include('...')
      expect(result.length).to eq(254)
    end

    it 'does nothing for short headlines' do
      page = create :page

      result = page.decorate_headline page.title

      expect(result).to eq(page.title)
    end
  end

  describe 'get_headline' do
    it 'gets headline' do
      page = create :page

      result = page.get_headline

      expect(result).to eq('The argument of an Abstraction')
    end

    it 'gets no headline' do
      page = create :page_with_no_headline

      result = page.get_headline

      expect(result).to include('No headline found')
    end
  end

  describe 'full_title' do
    it 'gets full title for normal page' do
      page = create :page

      result = page.full_title

      expect(result).to include(page.title, page.namespace)
    end
  end

  describe 'update_or_rename' do
    it 'renames page and links to it' do
      page = create :page
      abstraction_page = create :abstraction_page
      user = create :user

      abstraction_page.update_or_rename 'Other abstraction', abstraction_page.raw_content, abstraction_page.sections, user

      expect(page.reload.raw_content).to include('Other abstraction')
    end
  end

  describe 'page url' do
    it 'gives url' do
      page = create :page

      url = page.url

      expect(url).not_to include(' ')
    end
  end

  describe 'semantic links' do
    it 'lists semantic links' do
      page = create :page

      links = page.semantic_links

      expect(links).to include('MemberOf::Vocabulary:Programming')
      expect(links).to include('RelatesTo::Result')
      expect(links).to include('IsA::Concept')
    end

    it 'doesnt crash for no metadata section' do
      page = create :page_without_metadata

      links = page.semantic_links

      expect(links).to eq([])
    end
  end

  describe 'backlinks' do
    it 'gives backlinks' do
      page = create :page
      abstraction_page = create :abstraction_page

      links = abstraction_page.backlinks
      expect(links).to include(page.full_title)
    end
  end

  describe 'last_change' do
    it 'gives last change' do
      page = create(:page_with_changes)
      change = page.page_changes[1]

      result = page.get_last_change

      expect(result).to include(user_name: change.user.name)
      expect(result).to include(user_pic: change.user.github_avatar)
      expect(result).to include(user_email: change.user.email)
    end

    it 'has no last change' do
      page = create :page

      result = page.get_last_change

      expect(result).to eq({})
    end
  end
end
