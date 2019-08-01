require 'rails_helper'

RSpec.describe "faqs/edit", type: :view do
  before(:each) do
    @faq = assign(:faq, Faq.create!(
      :body => "MyText",
      :last_modified_by => "MyString"
    ))
  end

  it "renders the edit faq form" do
    render

    assert_select "form[action=?][method=?]", faq_path(@faq), "post" do

      assert_select "textarea[name=?]", "faq[body]"

      assert_select "input[name=?]", "faq[last_modified_by]"
    end
  end
end
