module Migration
  class Page < ActiveRecord::Base
    has_and_belongs_to_many :users
    has_many :repo_links

    def full_title
      # if used default namespaces -> remove from full title
      if (self.namespace == '101') or (self.namespace == 'Concept')
        self.title
      else
        # else use normal building of full url
        self.namespace + ':' + self.title
      end
    end

  end

  class RepoLink < ActiveRecord::Base
    belongs_to :page
  end

  class User < ActiveRecord::Base

  end
end

class MigrateData < ActiveRecord::Migration[5.0]

  def down
    Sequent::Core::EventRecord.delete_all
    Sequent::Core::CommandRecord.delete_all
    Sequent::Core::StreamRecord.delete_all
  end

  def up
    Migration::Page.find_in_batches(batch_size: 100) do |batch|
      commands = batch.map do |page|
        CreatePage.new(
          full_title: page.full_title,
          content: page.raw_content,
          user_id: page.users.first&.id,
          aggregate_id: page.id
        )
      end
      Sequent.command_service.execute_commands(*commands)
    end

    Migration::RepoLink.where.not(page_id: nil).find_in_batches(batch_size: 100) do |batch|
      commands = batch.map do |repo_link|
        UpdateRepoLink.new(
          aggregate_id: repo_link.page_id,
          folder: repo_link.folder,
          user: repo_link.user,
          repo: repo_link.repo,
          page_id: repo_link.page_id
        )
      end
      Sequent.command_service.execute_commands(*commands)
    end

    Migration::User.find_in_batches(batch_size: 100) do |batch|
      commands = batch.map do |user|
        LoginUser.new(
          aggregate_id: user.id,
          email: user.email,
          name: user.name,
          github_name: user.github_name,
          github_avatar: user.github_avatar,
          github_token: user.github_token,
          github_uid: user.github_uid
        )
      end
      Sequent.command_service.execute_commands(*commands)
    end

  end
end
