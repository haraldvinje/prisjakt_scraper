from typing import Dict, Union, TypeAlias
from sqlalchemy import Column, Integer, String, DateTime, Float
from sqlalchemy.sql import func
from sqlalchemy.orm import declarative_base

ScrapedProduct: TypeAlias = Dict[str, Union[str, int]]

Base = declarative_base()

class Product(Base):
    __tablename__ = "product"

    product_id = Column(Integer, primary_key=True)
    fetched_timestamp = Column(DateTime(timezone=True), default=func.now())
    name = Column(String, nullable=True)
    discounted_price = Column(Float, nullable=True)
    original_price = Column(Float, nullable=True)
    discount_percentage = Column(Float, nullable=True)
    url = Column(String, nullable=True)