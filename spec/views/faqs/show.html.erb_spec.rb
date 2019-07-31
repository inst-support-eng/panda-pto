require 'rails_helper'

RSpec.describe "faqs/show", type: :view do
  before(:each) do
    @faq = assign(:faq, Faq.create!(
      :body => "MyText",
      :last_modified_by => "Last Modified By"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Last Modified By/)
  end
end
