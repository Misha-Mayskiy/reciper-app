"""Add user preferences

Revision ID: 969baef44af4
Revises: 969baef44af3
Create Date: 2024-05-20 12:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '969baef44af4'
# Указываем предыдущую миграцию из твоего проекта
down_revision: Union[str, Sequence[str], None] = '969baef44af3'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Добавляем новые колонки
    op.add_column('users', sa.Column('goal', sa.String(), nullable=True))
    op.add_column('users', sa.Column('allergies', sa.String(), nullable=True))
    op.add_column('users', sa.Column(
        'preferences', sa.String(), nullable=True))


def downgrade() -> None:
    # Удаляем колонки при откате
    op.drop_column('users', 'preferences')
    op.drop_column('users', 'allergies')
    op.drop_column('users', 'goal')
