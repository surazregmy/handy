from selenium import webdriver
from selenium.webdriver import DesiredCapabilities
from selenium.webdriver.chrome.options import Options


chrome_options = Options()
chrome_options.add_argument("--headless")
chrome_options.add_argument('--ignore-certificate-errors')
chrome_options.add_argument("--window-size=1920x1080")

capabilities = DesiredCapabilities.CHROME.copy()
capabilities['acceptSslCerts'] = True               #some sites have ssl certification issue and this would solve them
capabilities['acceptInsecureCerts'] = True


driver = webdriver.Chrome(chrome_options = chrome_options,executable_path='/home/suregmi/chromedriver',desired_capabilities=capabilities)
driver.get("")


driver.get_screenshot_as_file("capture.png")

username = driver.find_element_by_id('username')
password = driver.find_element_by_id('password')

username.send_keys('*****')
password.send_keys('****')

driver.find_element_by_id('button').click()

#punchin | punchout both has same id

punchin = driver.find_element_by_id('pIn').click()

