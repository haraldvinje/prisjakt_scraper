from prisjakt_scraper.scraper import get_all_products
from prisjakt_scraper.database.database import check_database_connection
from prisjakt_scraper.database.repositories.product import store_products


def main():
    check_database_connection()
    products = get_all_products()
    store_products(products)


if __name__ == "__main__":
    main()
