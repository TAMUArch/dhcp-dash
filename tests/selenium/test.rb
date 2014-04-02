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

#profile = Selenium::WebDriver::Chrome::Profile.new
#driver = Selenium::WebDriver.for :chrome, :profile => profile

#chrome = Selenium::WebDriver::Chrome.driver_path=('./chromedriver')
driver = TestDriver.new(:firefox, 'localhost:4567')

driver.load
driver.putstitle
sleep(1)
driver.click_button('home_button', :id, 'home_button')
sleep(1)
driver.click_button('networks_button', :id, 'networks_button')
sleep(1)
driver.click_button('login_button', :id, 'login_button')
driver.putstitle
sleep(1)
driver.input('username', :id, 'username', username, false)
driver.input('password', :id, 'password', password, false)
sleep(1)
driver.click_button('sign_in', :tag_name, 'button')
sleep(1)
driver.putstitle
sleep(1)
driver.click_button('home_button', :id, 'home_button')
sleep(1)
driver.click_button('networks_button', :id, 'networks_button')
sleep(1)
driver.click_button('user_dropdown', :id, 'user_dropdown')
sleep(1)
driver.click_button('add_network', :id, 'add_network')
sleep(1)
driver.click_button('cancel_button', :id, 'cancel_button')
sleep(1)
driver.click_button('user_dropdown', :id, 'user_dropdown')
sleep(1)
driver.click_button('add_network', :id, 'add_network')
sleep(1)
#should also test what happens with invalid input
driver.input('network', :id, 'network', '192.168.3.0', false)
driver.input('domain', :id, 'domain', 'test.com', false)
driver.input('netmask', :id, 'netmask', '255.255.255.0', false)
driver.input('gateway', :id, 'gateway', '192.168.0.9', false)
driver.input('nameservers', :id, 'nameservers', '192.182.33.3', false)
sleep(1)
driver.click_button('save_button', :id, 'save_button')
sleep(1)
driver.click_button('addhost_button', :id, 'addhost_button')
sleep(1)
driver.click_button('cancel_addhost', :id, 'cancel_addhost')
sleep(1)
driver.click_button('addhost_button', :id, 'addhost_button')
sleep(1)
#addhost modal input goes here
driver.click_button('save_addhost', :id, 'save_addhost')
sleep(1)
driver.click_button('edit', :id, 'edit')
sleep(1)
driver.click_button('cancel_editmodal', :id, 'cancel_editmodal')
sleep(1)
driver.click_button('edit', :id, 'edit')
sleep(1)
driver.click_button('save_editmodal', :id, 'save_editmodal')
sleep(1)
driver.click_button('delete', :id, 'delete')
sleep(1)
driver.click_button('cancel_deletemodal', :id, 'cancel_deletemodal')
sleep(1)
driver.click_button('delete', :id, 'delete')
sleep(1)
driver.click_button('delete_deletemodal', :id, 'delete_deletemodal')
sleep(1)

sleep(5)
driver.quit
