"""create product table

Revision ID: 49f7dbe4a73e
Revises: 
Create Date: 2023-08-18 14:52:00.753609

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '49f7dbe4a73e'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        'product',
        sa.Column('product_id', sa.Integer, primary_key=True),
        sa.Column('name', sa.String(100), nullable=False),
        sa.Column('original_price', sa.Float, nullable=True),
        sa.Column('discounted_price', sa.Float, nullable=True),
        sa.Column('discount_percentage', sa.Float, nullable=True),
        sa.Column('url', sa.String(100), nullable=True),
        sa.Column('fetched_timestamp', sa.DateTime, nullable=True)
    )

def downgrade():
    op.drop_table('product')