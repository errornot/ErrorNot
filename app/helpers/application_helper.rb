# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def flash_to_html(flash)
    flash.map {|key, val| 
      "<div class=\"#{key}\">#{val}</div>"
    }.join('')
  end
end
