require 'spec_helper'

describe ApplicationHelper do

  describe :project_options do

    let! :unarchived_parent_1 do
      FactoryGirl.create(:project, archived: false)
    end

    let! :unarchived_parent_2 do
      FactoryGirl.create(:project, archived: false)
    end

    let! :archived_parent do
      FactoryGirl.create(:project, archived: true)
    end

    let! :unarchived_child_1 do
      FactoryGirl.create(:project, archived: false, parent_id: unarchived_parent_1.id)
    end

    let! :unarchived_child_2 do
      FactoryGirl.create(:project, archived: false, parent_id: unarchived_parent_2.id)
    end

    let! :archived_child_1 do
      FactoryGirl.create(:project, archived: true, parent_id: unarchived_parent_1.id)
    end

    let! :archived_child_2 do
      FactoryGirl.create(:project, archived: true, parent_id: archived_parent.id)
    end

    let :project_options_ids do
      returned_project_options.map{ |row| row[1] }
    end

    context "displaying only unarchived projects (default)" do
      let :returned_project_options do
        helper.project_options
      end

      it "should return only unarchived projects with their children in the proper order" do
        expect(project_options_ids).to eq([Project.root.id, unarchived_parent_1.id, unarchived_child_1.id, unarchived_parent_2.id, unarchived_child_2.id])
      end
    end

    context "displaying all projects" do
      let :returned_project_options do
        project_options(true)
      end

      it "should return all projects with their children in the proper order" do
        expect(project_options_ids).to eq([Project.root.id, unarchived_parent_1.id, unarchived_child_1.id, archived_child_1.id, unarchived_parent_2.id, unarchived_child_2.id, archived_parent.id, archived_child_2.id])
      end
    end
  end

end
