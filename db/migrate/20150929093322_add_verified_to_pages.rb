class AddVerifiedToPages < ActiveRecord::Migration
  def self.up
    def change
      add_column :pages, :verified, :boolean
    end
  end
  rescue	   
    # If an exception occurs, back out of this migration, but ignore any
    # exceptions generated there. Do the best you can.
    self.down rescue nil

    # Re-raise this exception for diagnostic purposes.
    raise
  end
end
