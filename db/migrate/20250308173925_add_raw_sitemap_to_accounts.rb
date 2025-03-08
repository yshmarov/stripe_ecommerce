class AddRawSitemapToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :raw_sitemap, :text
  end
end
