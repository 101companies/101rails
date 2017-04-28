require 'rails_helper'

describe PageModule do

  before(:each) do

  end

  describe 'rights' do

    it 'makes sure admins can access everyting' do
      user = create(:user)
      ability = Ability.new(user)

      access_pages = ability.can?(:show, Page.new)
      edit_pages = ability.can?(:edit, Page.new)
      destroy_pages = ability.can?(:destroy, Page.new)

      rails_admin = ability.can?(:access, :rails_admin)

      expect(access_pages).to be true
      expect(edit_pages).to be true
      expect(destroy_pages).to be true
      expect(rails_admin).to be true
    end

    it 'makes sure editors can access pages but not admin' do
      user = create(:editor_user)
      ability = Ability.new(user)

      access_pages = ability.can?(:show, Page.new)
      edit_pages = ability.can?(:edit, Page.new)
      destroy_pages = ability.can?(:destroy, Page.new)

      rails_admin = ability.can?(:access, :rails_admin)

      expect(access_pages).to be true
      expect(edit_pages).to be true
      expect(destroy_pages).to be true
      expect(rails_admin).to be false
    end

    it 'makes sure contributors can update only own pages' do
      user = create(:contributor_user)
      ability = Ability.new(user)

      access_pages = ability.can?(:show, Page.new)
      edit_pages = ability.can?(:edit, Page.new)
      destroy_pages = ability.can?(:destroy, Page.new)

      rails_admin = ability.can?(:access, :rails_admin)

      expect(access_pages).to be true
      expect(edit_pages).to be false
      expect(destroy_pages).to be false
      expect(rails_admin).to be false

    end

  end

end
