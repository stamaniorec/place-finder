# place-finder
##### A web application which searches for places and aggregates data.

Currently, it pulls data from Google Places, Booking.com and TripAdvisor.com

Written in Ruby+Sinatra in January 2016 for the Ruby course at the Faculty of Math and Informatics, Sofia University.

##### Check it out live here: https://placefinderr.herokuapp.com/

- - -

In a nutshell, it works in the following way:

1. The main search uses the Google Places Web Service API to run a Text Search, which returns a list of results.

2. The user clicks on the appropriate result (or searches again if it's not found).

3. A Place Details search is performed using the Google Places API, and starts scraping data from Booking.com and TripAdvisor.com (if found).

4. When the page is loaded, it performs an AJAX request, performing a Place Photos request, which is visualized as a gallery for the place.

5. The user is shown a results page where most valuable information is summarized and presented to them, hopefully making their life a little easier. :)

Technically, you could search for any kind of place, as the backbone of the app is the Google Places API, but it's intended to be used mainly for hotels, and also restaurants.

### How to run:
1. Clone repo
2. Install Sinatra if you haven't already (```gem install sinatra``` should do the trick)
3. Run ```bundle --without production``` - exclude production environment to bypass having to install PostgreSQL which is only used on Heroku, while SQLite3 is used in development.
4. Run ```ruby place_finder.rb```

### How to run tests:
Run ```rspec spec/```

### How to contribute:

##### If you'd like to add a new website to scrape data from, you need to do the following:
1. Write a new class ```#{Website}Scraper``` in the ```scrapers/``` directory
2. Define ```#get_search_url(query)``` - what URL to hit to get a page with suggestions for the query
3. Define ```#navigate_from_suggestions_page_to_hotel_page(suggestions_page, query)``` - return :not_found if no result on the suggestions page matches the query, or an instance of Mechanize::Page if found
4. Define ```#build_query(google_places_data)``` - for example, on Booking.com the query is ```#{place_name} #{place_location}```, while on Tripadvisor it's simply ```place_name``` because it works better this way.
5. Define ```#build_data(hotel_page, data)``` - return the ```data``` hash with the scraped data added
6. Define ```#set_error(data)``` - modify the given ```data``` hash to have an appropriate error key and value
7. Define ```#set_success(data)``` - modify the given ```data``` hash to have an appropriate success key and value
8. Modify the ```platforms``` method in ```helpers.rb``` to include the class you wrote.
9. Modify place.erb to display the new data on the results page.
10. Enjoy!

If that's not clear enough, look in the ```scrapers/``` directory for inspiration.

You should be able to add a new website to scrape as long as it works on the principle search -> get a list of suggestions -> user clicks the correct one -> a details page is shown

One of the toughest problems in this project is determining **whether a query matches a result**.

Problem is, hotel names aren't always the same across services and websites, sometimes several hotels have identical or nearly identical names, etc. 

You can look at some 15 examples in ```/spec/base_scraper_spec.rb``` to see what I'm talking about.

If you have some brilliant algorithm in mind which can solve all cases, feel free to contribute by changing the implementation of **```BaseScraper#similar_enough?```**

And of course, the **design** and overall front-end can be improved.

You could also always add more **tests**!
