require 'rubygems'
require 'selenium-webdriver'

class TestDriver
  attr_accessor :driver, :page
  def initialize(driver, page)
    @driver = Selenium::WebDriver.for driver
    @page = page
  end
  def load
    @driver.get @page
  end
  def putstitle
    puts "Page title is #{@driver.title}"
  end
  def click_button(button_name, search_type, search_name)
    button_name = @driver.find_element(search_type, search_name)
    button_name.click
  end
  def input(field_name, search_type, search_name, input, submit)
    if submit
      field_name = @driver.find_element(search_type, search_name)
      field_name.send_keys input
      field_name.submit
    else
      field_name = @driver.find_element(search_type, search_name)
      field_name.send_keys input
    end
  end
  def quit
    @driver.quit
  end
end

username = ENV['USERNAME']
password = ENV['PASSWORD']
driver = TestDriver.new(:firefox, "localhost:4567")

driver.load
driver.putstitle
sleep(1)
driver.click_button("home_button", :id, "home_button")
sleep(1)
driver.click_button("networks_button", :id, "networks_button")
sleep(1)
driver.click_button("login_button", :id, "login_button")
driver.putstitle
sleep(1)
driver.input("username", :id, "username", username, false)
driver.input("password", :id, "password", password, false)
sleep(1)
driver.click_button("sign_in", :tag_name, "button")
#need to set submit flag on driver.input ^^^ to false
#and add check "sigin in" button on ldap authentication page
#driver.click_button("xxx", :id, "xxx")
#can't do this currently --- can't locate file which contains ldap authentication code
#probably just being stupid
sleep(1)
driver.putstitle
sleep(1)
driver.click_button("home_button", :id, "home_button")
sleep(1)
driver.click_button("networks_button", :id, "networks_button")
sleep(1)
driver.click_button("user_dropdown", :id, "user_dropdown")
sleep(1)
driver.click_button("add_network", :id, "add_network")

#driver.click_button("logout", :id, "logout")

#driver.click_button("user_dropdown", :id, "user_dropdown")
#sleep(5)
#need to find this file, and give this button a callable id



driver.quit

