# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def flash_to_html(flash)
    flash.map {|key, val|
      "<div class=\"#{key}\">#{val}</div>"
    }.join('')
  end

  def title_header
    ret = "Errornot"
    ret += " : #{@project.name}" if @project && !@project.name.blank?
    ret += " - #{@title}" if @title
    ret
  end
end
