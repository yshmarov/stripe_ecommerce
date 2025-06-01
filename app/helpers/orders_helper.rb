module OrdersHelper
  def status_badge_classes(is_current_status)
    if is_current_status
      "du-badge du-badge-primary"
    else
      "du-badge du-badge-neutral"
    end
  end
end
