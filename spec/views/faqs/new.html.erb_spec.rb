require 'rails_helper'

RSpec.describe "faqs/new", type: :view do
  before(:each) do
    assign(:faq, Faq.new(
      :body => "MyText",
      :last_modified_by => "MyString"
    ))
  end

  it "renders new faq form" do
    render

    assert_select "form[action=?][method=?]", faqs_path, "post" do

      assert_select "textarea[name=?]", "faq[body]"

      assert_select "input[name=?]", "faq[last_modified_by]"
    end
  end
end
