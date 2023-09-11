import json
import pytest
from prisjakt_scraper.database.database import SessionException
from prisjakt_scraper.scraper import (
    get_product_details,
    get_product_elements_on_page,
)
from prisjakt_scraper.database.repositories.product import store_product


@pytest.fixture
def session(mocker):
    mock_session = mocker.Mock()
    yield mock_session


@pytest.fixture
def product_dict():
    with open("tests/data/product.json", "r") as f:
        product_dict = json.load(f)
    return product_dict

def test_get_product_elements_on_page():
    product_elements = get_product_elements_on_page(1)
    assert len(product_elements) >= 6
    assert all('p=' in product_element.get_attribute('href') for product_element in product_elements)


def test_get_product_details():
    product_elements = get_product_elements_on_page(1)
    product_details = get_product_details(product_elements[0])
    assert 'url' in product_details
    assert 'product_id' in product_details

def test_store_product(session, mocker, product_dict):
    mocker.patch("prisjakt_scraper.database.database.Session", return_value=session)
    try:
        store_product(product_dict)
    except SessionException:
        pytest.fail(f"Failed to store product: {product_dict}")
