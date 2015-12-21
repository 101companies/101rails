require 'rails_helper'

describe RepoLink do

  before(:each) do

  end

  describe 'namespace' do

    it 'gets the namespace' do
      link = create :repo_link

      result = link.namespace

      expect(result).to eq('contributions')
    end

    it 'gets the namespace with no page' do
      link = create :repo_link_without_page

      result = link.namespace

      expect(result).to eq('contributions_from_repo')
    end

  end

  describe 'gets user repo' do

    it 'gives correct user repo' do
      link = create(:repo_link)

      result = link.user_repo

      expect(result).to eq('pythonSyb')
    end

  end

  describe 'gets page title' do

    it 'gives page title when there is a page' do
      link = create(:repo_link)

      result = link.page_title

      expect(result).to eq(link.page.title)
    end

    it 'gives empty string when there is no page' do
      link = create(:repo_link_without_page)

      result = link.page_title

      expect(result).to eq('')
    end

  end

  describe 'outname' do

    it 'gives outname when there is a page' do
      link = create(:repo_link)

      result = link.out_name

      expect(result).to eq(link.page.title)
    end

    it 'gives outname when there is no page' do
      link = create(:repo_link_without_page)

      result = link.out_name

      expect(result).to eq('pythonSyb')
    end

  end

  describe 'full_url' do

    it 'gives full url' do
      link = create(:repo_link)

      result = link.full_url

      expect(result).to eq('https://github.com/kevin-klein/pythonSyb/tree/master/contributions/pythonSyb')
    end

    it 'gives full url' do
      link = create(:repo_link_to_root_folder)

      result = link.full_url

      expect(result).to eq('https://github.com/kevin-klein/pythonSyb')
    end

  end


end
