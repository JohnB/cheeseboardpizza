
require 'open-uri'

#
# NOTE: This code is very brittle and will break if the Cheese Board Collective
# changes the format of its page in even a small way.
#
# Ideally, they would add a class to each pizza description that would tell us
# what day the pizza is served (e.g. "<p class='tuesday'>Roasted potatoes..</p>")
#
class PizzaOfTheDay
  DAY_MATCH = /\d+\/\d+/

  def cheeseboard_date(time = Time.now)
    # "Saturday 2/9", not "Saturday 02/09"
    time.strftime("%A %m/%d").gsub(" 0"," ").sub("/0","/")
  end

  def pizza_page
    @pizza_page ||= open('http://cheeseboardcollective.coop/pizza') { |f| Hpricot(f) }
  end

  def pizza_days
    @pizza_days ||= (pizza_page/"div.columns"/"div.column").first
  end

  def lines_that_may_have_dates_or_toppings
    @lines_that_may_have_dates_or_toppings = pizza_days.
        children.
        collect {|i| i.inner_text.gsub(/\s+/,' ').strip }.
        reject {|i| i == "" }
  end

  def potential_pizza_dates
    (-6..6).collect { |delta| delta.days.from_now }
  end

  def topping_for_a_day(day)
    day_to_look_for = cheeseboard_date(day)
    lines_that_may_have_dates_or_toppings.each_with_index do |line, idx|
      return lines_that_may_have_dates_or_toppings[idx+1] if line == day_to_look_for
    end
    nil
  end

  def days_with_pizza
    @days_with_pizza ||= potential_pizza_dates.inject({}) do |hash, day|
      topping = topping_for_a_day(day)
      hash[day.strftime("%m/%d")] ||= topping if topping
      hash
    end
  end

  #def pizzas_this_week
  #  days_with_pizza
  #end

  def pizza_of_the_day( today = Time.now )
    today = today.strftime("%m/%d")
    pizza = days_with_pizza[today]
    #month, day = today.split('/').collect { |digits| ("0"+digits)[-2..-1].to_i }
    #pizza = nil
    #["%d/%d", "%02d/%d", "%d/%02d", "%02d/%02d"].each do |format|
    #  day_to_check = format % [month,day]
    #  pizza ||= pizzas_this_week[day_to_check]
    #end
    pizza || "So sad. No Pizza Today."
  end

  def pizza_of_the_day_with_time(today = Time.now)
    today.strftime("%m/%d: ") + pizza_of_the_day(today)
  end

  def tweet_text(today = Time.now)
    pizza_of_the_day_with_time(today)[0..139]
  end
end
