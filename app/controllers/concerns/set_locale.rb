module SetLocale
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  private

  def set_locale
    I18n.locale = extract_locale || cookies[:locale] || Setting.default_language || I18n.default_locale
  end

  def extract_locale
    return nil if params[:locale].blank?

    locale = params[:locale]
    cookies[:locale] = locale if I18n.available_locales.include?(locale.to_sym)
  end
end
