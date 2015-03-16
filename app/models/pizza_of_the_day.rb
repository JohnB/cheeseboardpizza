
require 'open-uri'

#
# NOTE: This code is very brittle and will break if the Cheese Board Collective
# changes the format of its page in even a small way.
#
# Ideally, they would add a class to each pizza description that would tell us
# what day the pizza is served (e.g. "<p class='tuesday'>Roasted potatoes..</p>")
#
class PizzaOfTheDay
  PIZZA_PAGE_URL = 'http://cheeseboardcollective.coop/pizza'
  DAY_MATCH = /\d+\/\d+/

  def cheeseboard_date(time = Time.now)
    # "Saturday 2/9", not "Saturday 02/09"
    time.strftime("%A %-m/%-d")
  end

  def pizza_page
    @pizza_page = Nokogiri::HTML(open(PIZZA_PAGE_URL))
  end

  def pizza_days
    # This scraping script is a lot simpler than I remember - only one selection via hpricot.
    # The salient piece of HTML looks like this, and we only care about the innerHtml:
    #
    #   <div class="columns">
    #	    <div class="column">
    #       <h3><strong>The Week&rsquo;s Pizza</strong></h3>
    #       <h4><label for="pizza_week_wednesday_pizza"></label></h4>		
    #       <h4>Tuesday 10/28</h4>
    #       <p>Zucchini, onion, mozzarella and other stuff..</p>
    #       <h4>Wednesday 10/29</h4>
    #       <p>Baby dino kale, baby swiss chard, and other stuff..</p>
    #       ...
    #
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
      if topping
        topping.gsub!(/ and /,' & ')
        hash[day.strftime("%m/%d")] ||= topping
      end
      hash
    end
  end

  def pizza_of_the_day( today = Time.now )
    today = today.strftime("%m/%d")
    pizza = days_with_pizza[today]
    pizza || "Bummer Dude. No pizza today."
  end

  def pizza_of_the_day_with_time(today = Time.now)
    today.strftime("%m/%d: ") + pizza_of_the_day(today)
  end

  def tweet_text(today = Time.now)
    pizza_of_the_day_with_time(today)[0..139]
  end
end
