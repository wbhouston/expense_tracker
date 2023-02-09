# frozen_string_literal: true
module Components
  module ButtonHelper
    def button(label, path, html_options = {})
      html_options[:class] = [
        html_options[:class],
        'bg-green-700 text-white text-sm px-2 py-1 rounded',
        'hover:bg-green-500 hover:cursor-pointer',
      ].join(' ')

      link_to(label, path, html_options)
    end
  end
end
