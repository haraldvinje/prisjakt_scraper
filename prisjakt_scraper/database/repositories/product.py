from typing import List

from sqlalchemy.orm import Session

from prisjakt_scraper.logger.logger import logger
from prisjakt_scraper.database.database import db_session, SessionException
from prisjakt_scraper.database.models.product import Product, ScrapedProduct


@db_session
def store_product(session: Session, product: ScrapedProduct):
    session.merge(Product(product))


@db_session
def store_products(session: Session, products: List[ScrapedProduct]):
    for product in products:
        try:
            session.merge(Product(**product))
        except SessionException as error:
            logger.warning(
                f"Exception occurred while storing ad: {product}: {error}",
                exc_info=True,
            )
            continue
