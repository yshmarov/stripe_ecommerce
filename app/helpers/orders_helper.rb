module OrdersHelper
  def status_badge_classes(status_in_sequence, is_current_status)
    base_classes = "inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold"

    if is_current_status
      # Determine status-specific color and ring-color classes
      status_specific_classes = case status_in_sequence
      when "submitted"
                                  "du-badge du-badge-primary"
      when "processing"
                                  "du-badge du-badge-warning"
      when "delivery"
                                  "du-badge du-badge-secondary"
      when "done"
                                  "du-badge du-badge-success"
      else
                                  "du-badge du-badge-neutral"
      end

      "#{base_classes} #{status_specific_classes}"
    else
      "du-badge du-badge-neutral"
    end
  end
end
