#frozen_string_literal: true

module Components
  module ButtonMenuHelper
    def render_button_menu(links:)
      render('components/button_menu', links: links)
    end

    def render_button_menu_link(link)
      url = link.delete(:url)
      label = link.delete(:label)

      link_to(
        label,
        url,
        **link,
      )
    end
  end
end