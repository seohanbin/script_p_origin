class CreateBookshelves < ActiveRecord::Migration
  def change
    create_table :bookshelves do |t|

      t.string    :bookname
      t.string    :booksubname
      t.string    :authorname
      t.string    :publisher
      t.string    :releasedate
      t.string    :isbnnumber
      t.string    :booklink
      
      t.string    :categorize
      


      t.timestamps null: false
    end
  end
end
