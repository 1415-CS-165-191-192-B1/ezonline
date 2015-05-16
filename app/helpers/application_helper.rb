# Helper module for the application EzOnline
module ApplicationHelper

  # Sets the site's name
  #
  # @return [void]
  def site_name
    "EZ Online"
  end

  # Sets the site's url
  #
  # @return [void]
  def site_url
    if Rails.env.production?
      # Place your production URL in the quotes below
      "http://www.ezonline.com/"
    else
      # Our dev & test URL
      "http://ezonline-dev.com:3000"
    end
  end

  # Sets the author of the site
  #
  # @return [void]
  def meta_author
    # Change the value below between the quotes.
    "Team Tation"
  end

  # Sets the descriotion of the site
  #
  # @return [void]
  def meta_description
    # Change the value below between the quotes.
    "File Repository for EZ Troubleshooter"
  end

  # Sets the key words for the site
  #
  # @return [void]
  def meta_keywords
    # Change the value below between the quotes.
    "ezonline, ez troubleshooter, repository"
  end

  # Returns the full title on a per-page basis.
  #	No need to change any of this we set page_title and site_name elsewhere.
  def full_title(page_title)
    if page_title.empty?
      site_name
    else
      "#{page_title} | #{site_name}"
    end
  end

  # Choose action depeding on level
  #
  # @param level [String] alert level
  # @return [void]
  def flash_class(level)
    case level
        when 'notice' then "alert alert-info"
        when 'success' then "alert alert-success"
        when 'error' then "alert alert-danger"
        when 'alert' then "alert alert-error"
    end
  end

  # For Bootstrap
  #
  # @param flash_type
  # @return [void]
  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info" }[flash_type] || flash_type.to_s
  end
 
  # Handles flash messages
  #
  # @param opts
  # @return [void]
  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} fade in") do 
              concat content_tag(:button, 'x', class: "close", data: { dismiss: 'alert' })
              concat message 
            end)
    end
    nil
  end

end
