from flask import Blueprint, render_template, abort
from flaskr.db import get_db
from flaskr.auth import login_required

bp = Blueprint('tables', __name__, url_prefix='/tables')

# List of all tables in the database
TABLES = ['Traders', 'Stocks', 'Portfolio', 'Transactions', 'Watchlists']

@bp.route('/')
@login_required
def index():
    """Show list of all tables"""
    db = get_db()
    table_info = []

    for table_name in TABLES:
        # Get row count for each table
        count = db.execute(f'SELECT COUNT(*) as count FROM {table_name}').fetchone()['count']
        table_info.append({
            'name': table_name,
            'count': count
        })

    return render_template('tables/index.html', tables=table_info)

@bp.route('/<table_name>')
@login_required
def view_table(table_name):
    """View data from a specific table"""
    if table_name not in TABLES:
        abort(404)

    db = get_db()
    rows = db.execute(f'SELECT * FROM {table_name}').fetchall()

    # Get column names
    if rows:
        columns = rows[0].keys()
    else:
        # If no rows, get column names from table schema
        cursor = db.execute(f'PRAGMA table_info({table_name})')
        columns = [row['name'] for row in cursor.fetchall()]

    return render_template('tables/view.html',
                          table_name=table_name,
                          columns=columns,
                          rows=rows)
