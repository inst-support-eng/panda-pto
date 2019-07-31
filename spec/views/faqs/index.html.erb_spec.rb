require 'rails_helper'

RSpec.describe "faqs/index", type: :view do
  before(:each) do
    assign(:faqs, [
      Faq.create!(
        :body => "MyText",
        :last_modified_by => "Last Modified By"
      ),
      Faq.create!(
        :body => "MyText",
        :last_modified_by => "Last Modified By"
      )
    ])
  end

  it "renders a list of faqs" do
    render
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Last Modified By".to_s, :count => 2
  end
end
