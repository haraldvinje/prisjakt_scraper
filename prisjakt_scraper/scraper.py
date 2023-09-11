import re
from unicodedata import normalize
from typing import List, Set, Dict, Union

import time
from selenium import webdriver
from selenium.webdriver import Chrome
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.remote.webelement import WebElement
from webdriver_manager.chrome import ChromeDriverManager


from prisjakt_scraper.logger.logger import logger
from prisjakt_scraper.database.models.product import ScrapedProduct

options = webdriver.ChromeOptions()
options.headless = True
options.page_load_strategy = "none"
chrome_path = ChromeDriverManager().install()
chrome_service = Service(chrome_path)
driver = Chrome(options=options, service=chrome_service)
driver.implicitly_wait(3)


BASE_URL = "https://www.prisjakt.no"


def price_string_to_number(price_string: str) -> int:
    return int(re.sub(r"[^\d.]", "", price_string))


def clean_dictionary(dictionary: Dict) -> Dict:
    return {key: str(value) for key, value in dictionary.items()}


def get_elements(url: str, xpath: str) -> List[WebElement]:
    driver.get(url)
    time.sleep(2)
    return driver.find_elements(By.XPATH, xpath)


def find_element_by_xpath(element: WebElement, xpath_expression: str) -> WebElement:
    try:
        result = element.find_element(By.XPATH, xpath_expression)
    except Exception:
        result = None
    return result


def get_product_details(element: WebElement) -> Union[ScrapedProduct, None]:
    product_url = element.get_attribute("href")
    logger.info(f"Scraping product with url {product_url}")
    try:
        product_id = product_url.split("p=")[-1]

        product_discounted_price_element = find_element_by_xpath(
            element, './/div[starts-with(@class, "StyledPrice")]/span'
        )
        product_discounted_price = None
        if product_discounted_price_element:
            product_discounted_price = price_string_to_number(
                normalize("NFKD", product_discounted_price_element.text)
            )

        product_discount_element = find_element_by_xpath(
            element, './/div[starts-with(@class, "DiffPercentage")]'
        )
        product_discount_percentage = None
        if product_discount_element:
            product_discount_percentage = int(product_discount_element.text[1:-1])

        product_original_price = None
        if product_discounted_price and product_discount_percentage:
            product_original_price = product_discounted_price / (
                1 - (product_discount_percentage / 100)
            )

        product_name_element = find_element_by_xpath(
            element, './/span[@data-test="ProductName"]'
        )
        product_name = None
        if product_name_element:
            product_name = product_name_element.text

        return {
            "url": product_url,
            "product_id": product_id,
            "discount_percentage": product_discount_percentage,
            "name": product_name,
            "discounted_price": product_discounted_price,
            "original_price": product_original_price,
        }
    except BaseException as error:
        logger.warning(
            f"Something went wrong when getting prodcut with url {product_url}). Error: {error}",
            exc_info=True,
        )
        raise RuntimeError from error


def get_products_on_page(page_number: int):
    path = f"tema/dagens-tilbud?price-drop=10&sort=dealUpdateTime&page={page_number}"
    url = f"{BASE_URL}/{path}"
    xpath = '//a[@data-test="InternalLink" and starts-with(@href, "/product.php")][descendant::div]'

    product_elements = get_elements(url, xpath)
    products = []
    for product_element in product_elements:
        products.append(get_product_details(product_element))

    return products


def get_all_products() -> Set:
    products = []
    for page_number in range(2):
        products.extend(get_products_on_page(page_number))
    return products
