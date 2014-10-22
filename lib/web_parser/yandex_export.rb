require 'hpricot'
require 'hashie/mash'

module WebParser
  module YandexExport
    # Казань
    KAZAN_REGION_URL = 'http://export.yandex.ru/bar/reginfo.xml?region=43'

    module_function

    def day_weather
      xml = Hpricot(open(KAZAN_REGION_URL, &:read))
      weather = xml/:weather
      date_info = (weather/:date).first
      day_parts = (weather/:day_part).map do |day_part|
        {
          type_id:              day_part[:typeid],
          type_name:            day_part[:type],
          type_name:            day_part[:type],
          text:                 (day_part/:weather_type).first.try(:innerText),
          code:                 (day_part/:weather_code).first.try(:innerText),
          images: {
            image_1: {
              url: (day_part/:image).first.try(:innerText),
              size: (day_part/:image).first.try(:[], :size),
            },
            # 22x22
            image_2: {
              url: (day_part/'image-v2').first.try(:innerText),
              size: (day_part/'image-v2').first.try(:[], :size),
            },
            # 48x48
            image_3: {
              url: (day_part/'image-v3').first.try(:innerText),
              size: (day_part/'image-v3').first.try(:[], :size),
            },
          },
          image_number:         (day_part/:image_number).first.try(:innerText),
          wind_speed:           (day_part/:wind_speed).first.try(:innerText),
          wind_direction_text:  (day_part/:wind_direction).first.try(:innerText),
          wind_direction_id:    (day_part/:wind_direction).first.try(:[], :id),
          dampness:             (day_part/:dampness).first.try(:innerText),
          pressure:             (day_part/:pressure).first.try(:innerText),
          observation:          (Time.parse((day_part/:observation).first.innerText) rescue nil),
          temperature:          (day_part/:temperature).first.try(:innerText),
          temperature_from:     (day_part/:temperature_from).first.try(:innerText),
          temperature_to:       (day_part/:temperature_to).first.try(:innerText),
        }
      end

      Hashie::Mash.new(
        date: Date.parse(date_info[:date]),
        day_parts: day_parts,
        tomorrow: (((weather/:tomorrow).first/:temperature).first.innerText rescue nil)
      )
    rescue => e
      puts 'Parse error'
      puts e.message
      puts e.backtrace
      {}
    end

    # Получаем данные о трафике на дорогах
    def traffic
      xml = Hpricot(open(KAZAN_REGION_URL, &:read))
      traffic = xml/:traffic
      timestamp = (traffic/:timestamp).first.innerText.to_i
      details = {
        length: (traffic/:length).first.try(:innerText),
        level: (traffic/:level).first.try(:innerText),
        icon: (traffic/:icon).first.try(:innerText),
        time: (traffic/:time).first.try(:innerText),
        hint: (traffic/:hint).each_with_object({}) do |hint_node, result|
          result[hint_node[:lang]] = hint_node.innerText
        end,
        tend: (traffic/:tend).first.try(:innerText)
      }
      Hashie::Mash.new(
        datetime: Time.at(timestamp),
        details: details,
        url: ((traffic/:url).first.try(:innerText) rescue nil)
      )
    rescue => e
      puts 'Parse error'
      puts e.message
      puts e.backtrace
      {}
    end
  end
end
