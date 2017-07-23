require 'rails_helper'

describe PageModule do

  before(:each) do

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

  describe 'retrieve_namespace_and_title' do

    it 'namespace with @' do
      result = PageModule.retrieve_namespace_and_title '@project'

      expect(result).to eq({ 'namespace' => '101', 'title' => '@project' })
    end

    it 'usual namespace' do
      result = PageModule.retrieve_namespace_and_title 'Contribution:pythonSyb'

      expect(result).to eq({ 'namespace' => 'Contribution', 'title' => 'pythonSyb' })
    end

    it 'concept namespace' do
      result = PageModule.retrieve_namespace_and_title 'ProgramingLanguage'

      expect(result).to eq({ 'namespace' => 'Concept', 'title' => 'ProgramingLanguage' })
    end

  end

  describe 'default_contribution_text' do

    it 'gets the contribution text' do
      result = PageModule.default_contribution_text('pythonSyb')

      expect(result).to include('pythonSyb')
    end

  end

  describe 'escape_wiki_url' do

    it 'escapes a wiki url' do
      result = PageModule.escape_wiki_url('contribution:pythonSyb')

      expect(result).to eq('Contribution:pythonSyb')
    end

  end

  describe 'unescape_wiki_url' do

    it 'escapes a wiki url' do
      result = PageModule.unescape_wiki_url('contribution:pythonSyb')

      expect(result).to eq('Contribution:pythonSyb')
    end

  end

  describe 'create_page_by_full_title' do

    it 'creates a new page' do
      expect {
        PageModule.create_page_by_full_title 'Some title'
      }.to change{Page.count}.by(1)
    end

    it 'makes sure page has the given title' do
      result = PageModule.create_page_by_full_title 'Some title'

      expect(result.full_title).to eq('Concept:Some title')
    end

  end

  describe 'uncapitalize_first_char' do

    it 'does it' do
      result = PageModule.uncapitalize_first_char('SomeText')

      expect(result).to eq('someText')
    end

  end

end
