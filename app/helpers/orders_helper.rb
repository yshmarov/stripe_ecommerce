module OrdersHelper
  def status_badge_classes(status_in_sequence, is_current_status)
    base_classes = "inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold"

    if is_current_status
      # Determine status-specific color and ring-color classes
      status_specific_classes = case status_in_sequence
      when "submitted"
                                  "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200 ring-blue-500"
      when "processing"
                                  "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200 ring-yellow-500"
      when "delivery"
                                  "bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200 ring-purple-500"
      when "done"
                                  "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200 ring-green-500"
      else
                                  "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200 ring-gray-500"
      end

      common_active_ring_classes = "ring-2 ring-offset-1 ring-offset-white dark:ring-offset-gray-800"
      "#{base_classes} #{status_specific_classes} #{common_active_ring_classes}"
    else
      inactive_classes = "bg-gray-200 text-gray-500 dark:bg-gray-700 dark:text-gray-400"
      "#{base_classes} #{inactive_classes}"
    end
  end
end
