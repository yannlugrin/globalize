# Translate the distance_of_time_in_words helper
module ActionView::Helpers::DateHelper
  def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round
    case distance_in_minutes
      when 0..1
        return (distance_in_minutes==0) ? :less_than_time % [:x_minutes % [1]] : :x_minutes % [1] unless include_seconds
        case distance_in_seconds
          when 0..5   then :less_than_seconds % [5]
          when 6..10  then :less_than_seconds % [10]
          when 11..20 then :less_than_seconds % [20]
          when 21..40 then :half_a_minute.t
          when 41..59 then :less_than_time % [:x_minutes % [1] ]
          else             :x_minutes % [1]
        end
      when 2..25       then :x_minutes % [distance_in_minutes]
      when 26..34      then :half_an_hour.t
      when 35..45      then :x_minutes % [distance_in_minutes]
      when 46..1440    then :time_about % [:x_hours  % [(distance_in_minutes.to_f / 60.0).round] ]
      when 1441..9360  then :time_about % [:x_days   % [(distance_in_minutes / 1440).round] ]
      when 9361..42480 then :time_about % [:x_weeks  % [(distance_in_minutes / 10080).round] ]
      else                  :time_about % [:x_months % [(distance_in_minutes / 43200).round] ]
    end
  end
end
