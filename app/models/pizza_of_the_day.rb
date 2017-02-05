
require 'open-uri'

#
# NOTE: This code is very brittle and will break if the Cheese Board Collective
# changes the format of its page (which has happend multiple times).
#
# Ideally, they would add a class to each pizza description that would tell us
# what day the pizza is served (e.g. "<p class='tuesday'>Roasted potatoes..</p>")
#
class PizzaOfTheDay
  PIZZA_PAGE_URL = 'http://cheeseboardcollective.coop/pizza'
  DAY_MATCH = /\d+\/\d+/

  def cheeseboard_dates(time = Time.now)
    # allow for days as "4" and "04"
    [time.strftime("%a %h %-d"), time.strftime("%a %h %d")]
  end

  def pizza_page
    @pizza_page ||= Nokogiri::HTML(open(PIZZA_PAGE_URL))
  end

  def pizza_days
    # The salient piece of HTML looks like this as of 12/10/2016 (but they change it sometimes):
    #
    #   <div class="pizza-list">
    #     <article>
    #       <div class="date">
    #         <p>Sat Dec 10</p>
    #       </div>
    # 			<div class="menu">
    # 				<h3>Pizza:</h3>
    #         <p>Crushed tomato, red onion, ... and oregano</p>
    # 			</div>
    # 			<hr>
    # 		</article>
    #     <article>
    #       ...
    #
    @pizza_days ||= (pizza_page/".pizza-list"/ "article")
  end

  def potential_pizza_dates
    (-6..6).collect { |delta| delta.days.from_now }
  end

  def days_and_pizzas
    days = (pizza_days / "article" / ".date").children.collect(&:text)
    pizzas = (pizza_days / ".menu" ).map {|el| el.children[3].try(:text) }

    result = {}
    days.each_with_index { |day, index| result[day] = pizzas[index] }
    result
  end

  def days_and_salads
    days = (pizza_days / "article" / ".date").children.collect(&:text)
    salads = (pizza_days / ".menu" ).map {|el| el.children[7].try(:text) }

    result = {}
    days.each_with_index { |day, index| result[day] = salads[index] }
    result
  end

  def days_with_pizza
    @days_with_pizza ||= potential_pizza_dates.inject({}) do |hash, day|
      days_to_look_for = cheeseboard_dates(day)

      topping = days_and_pizzas[days_to_look_for.first] || days_and_pizzas[days_to_look_for.last]
      if topping
        topping.gsub!(/ and /,' & ')
        topping.gsub!(/\*/,' ')   # as of 4/2015, asterisks are, apparently, not allowed!?
        topping.sub!(/^Pizza\:\s+/,'')   # after adding salads, they stuck 'Pizza: ' on the front.
        topping.squeeze!(' ')
        hash[day.strftime("%m/%d")] ||= topping
      end
      hash
    end
  end

  def pizza_of_the_day( today = Time.now )
    today = today.strftime("%m/%d")
    pizza = days_with_pizza[today]
    pizza || "Aw shucks! No pizza today."
  end

  def pizza_of_the_day_with_time(today = Time.now)
    today.strftime("%m/%d: ") + pizza_of_the_day(today)
  end

  def tweet_text(today = Time.now)
    pizza_of_the_day_with_time(today)[0..139]
  end

  def days_with_salad
    @days_with_salad ||= potential_pizza_dates.inject({}) do |hash, day|
      days_to_look_for = cheeseboard_dates(day)

      topping = days_and_pizzas[days_to_look_for.first] || days_and_pizzas[days_to_look_for.last]
      if topping
        topping.gsub!(/ and /,' & ')
        topping.gsub!(/\*/,' ')   # as of 4/2015, asterisks are, apparently, not allowed!?
        # topping.sub!(/^Pizza\:\s+/,'')   # after adding salads, they stuck 'Pizza: ' on the front.
        topping.squeeze!(' ')
        hash[day.strftime("%m/%d")] ||= topping
      end
      hash
    end
  end

  def salad_of_the_day( today = Time.now )
    today = today.strftime("%m/%d")
    salad = days_with_salad[today]
    "SALAD: " + (salad || "Not today.")
  end

  def salad_of_the_day_with_time(today = Time.now)
    today.strftime("%m/%d: ") + salad_of_the_day(today)
  end

  def salad_tweet_text(today = Time.now)
    salad_of_the_day_with_time(today)[0..139]
  end
end
