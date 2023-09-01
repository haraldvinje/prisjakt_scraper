# import json
# import pytest
# from prisjakt_scraper.database.database import SessionException
# from prisjakt_scraper.scraper import (
#     get_ad_codes_from_page_number,
#     get_ad,
#     get_number_of_pages,
# )
# from prisjakt_scraper.database.repositories.product import store_product


# @pytest.fixture
# def session(mocker):
#     mock_session = mocker.Mock()
#     yield mock_session


# @pytest.fixture
# def ad_dict():
#     with open("tests/data/product.json", "r") as f:
#         ad_dict = json.load(f)
#     return ad_dict


# def test_get_number_of_pages():
#     """
#     Testing fetching of total number of .
#     """
#     number_of_pages = get_number_of_pages()
#     assert isinstance(number_of_pages, int)
#     assert number_of_pages > 2


# def test_get_ad_codes_from_page_number():
#     """
#     Testing fetching of ad codes. There should be at least 10 ad codes,
#     or else something is probably wrong.
#     """
#     codes = get_ad_codes_from_page_number(2)
#     assert len(codes) >= 10


# def test_get_ad():
#     """
#     Testing fetching of ad. There should be at least 6 fields in the resulting dictionary,
#     or else something is probably wrong.
#     """
#     ad_code = get_ad_codes_from_page_number(2).pop()
#     ad_data = get_ad(ad_code)
#     assert len(ad_data.keys()) >= 6


# def test_store_ad(session, mocker, ad_dict):
#     mocker.patch("prisjakt_scraper.database.database.Session", return_value=session)
#     """
#     Testing storing of ad.
#     """
#     try:
#         store_product(ad_dict)
#     except SessionException:
#         pytest.fail(f"Failed to store ad: {ad_dict}")
