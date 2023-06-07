module ApplicationHelper
  def page_title(page_title = '')
    base_title = 'Tournament Note'

    page_title.empty? ? base_title : "#{page_title} | #{base_title}"
  end

  def form_error_notification(object)
    if object.errors.any?
      tag.div id: "error_explanation", class: "alert alert-danger" do
        concat tag.h5 pluralize(object.errors.count, "error")
        concat tag.ul {
          object.errors.full_messages.each do |message|
            concat tag.li message
          end
        }
      end
    end
  end

end
