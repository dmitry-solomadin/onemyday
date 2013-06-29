class CreateStoryElementsTable < ActiveRecord::Migration
  def change
    create_table :story_elements do |t|
      t.integer :element_order
      t.references :story
      t.references :element, polymorphic: true
      t.timestamps
    end

    Story.all.each do |story|
      StoryPhoto.where(story_id: story.id).each do |story_photo|
        story_element = story.story_elements.build(element: story_photo, story: story, element_order: story_photo.photo_order)
        story_element.save!
      end
    end
  end
end
