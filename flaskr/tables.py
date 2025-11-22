from flask import Blueprint, render_template, abort, request, redirect, url_for, flash
from werkzeug.security import generate_password_hash
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

    # Get primary key for edit/delete links
    pk_column = get_primary_key(table_name)

    return render_template('tables/view.html',
                          table_name=table_name,
                          columns=columns,
                          rows=rows,
                          pk_column=pk_column)

def get_table_schema(table_name):
    """Get column information for a table"""
    db = get_db()
    cursor = db.execute(f'PRAGMA table_info({table_name})')
    schema = []
    for row in cursor.fetchall():
        schema.append({
            'name': row['name'],
            'type': row['type'],
            'notnull': row['notnull'],
            'pk': row['pk']
        })
    return schema

def get_primary_key(table_name):
    """Get the primary key column name for a table"""
    schema = get_table_schema(table_name)
    for field in schema:
        if field['pk'] == 1:
            return field['name']
    return None

@bp.route('/<table_name>/create', methods=('GET', 'POST'))
@login_required
def create(table_name):
    """Create a new record in the table"""
    if table_name not in TABLES:
        abort(404)

    schema = get_table_schema(table_name)

    if request.method == 'POST':
        db = get_db()
        error = None

        # Build the INSERT query dynamically
        columns = []
        values = []
        placeholders = []

        for field in schema:
            # Skip auto-increment primary keys
            if field['pk'] == 1:
                continue

            field_name = field['name']
            field_value = request.form.get(field_name, '').strip()

            # Check required fields
            if field['notnull'] and not field_value:
                error = f"{field_name} is required."
                break

            # Hash password field for Traders table
            if table_name == 'Traders' and field_name == 'Password' and field_value:
                field_value = generate_password_hash(field_value)

            # Add to query if value provided or field is required
            if field_value or field['notnull']:
                columns.append(field_name)
                values.append(field_value if field_value else None)
                placeholders.append('?')

        if error is None:
            try:
                query = f"INSERT INTO {table_name} ({', '.join(columns)}) VALUES ({', '.join(placeholders)})"
                db.execute(query, values)
                db.commit()
                flash(f'Successfully added new record to {table_name}!', 'success')
                return redirect(url_for('tables.view_table', table_name=table_name))
            except db.IntegrityError as e:
                error = f"Database error: {str(e)}"

        flash(error, 'danger')

    return render_template('tables/create.html',
                          table_name=table_name,
                          schema=schema)

@bp.route('/<table_name>/edit/<int:record_id>', methods=('GET', 'POST'))
@login_required
def edit(table_name, record_id):
    """Edit an existing record in the table"""
    if table_name not in TABLES:
        abort(404)

    schema = get_table_schema(table_name)
    pk_column = get_primary_key(table_name)

    if not pk_column:
        flash('Cannot edit: No primary key found for this table.', 'danger')
        return redirect(url_for('tables.view_table', table_name=table_name))

    db = get_db()

    # Get the existing record
    record = db.execute(f'SELECT * FROM {table_name} WHERE {pk_column} = ?', (record_id,)).fetchone()

    if record is None:
        flash('Record not found.', 'danger')
        return redirect(url_for('tables.view_table', table_name=table_name))

    if request.method == 'POST':
        error = None

        # Build the UPDATE query dynamically
        updates = []
        values = []

        for field in schema:
            # Skip primary key
            if field['pk'] == 1:
                continue

            field_name = field['name']
            field_value = request.form.get(field_name, '').strip()

            # Check required fields
            if field['notnull'] and not field_value:
                error = f"{field_name} is required."
                break

            # Hash password field for Traders table (only if new password provided)
            if table_name == 'Traders' and field_name == 'Password':
                if field_value:
                    field_value = generate_password_hash(field_value)
                else:
                    # Keep existing password if not changed
                    continue

            # Add to update query
            if field_value or field['notnull']:
                updates.append(f"{field_name} = ?")
                values.append(field_value if field_value else None)

        if error is None:
            try:
                # Add the record_id for the WHERE clause
                values.append(record_id)
                query = f"UPDATE {table_name} SET {', '.join(updates)} WHERE {pk_column} = ?"
                db.execute(query, values)
                db.commit()
                flash(f'Successfully updated record in {table_name}!', 'success')
                return redirect(url_for('tables.view_table', table_name=table_name))
            except db.IntegrityError as e:
                error = f"Database error: {str(e)}"

        flash(error, 'danger')

    return render_template('tables/edit.html',
                          table_name=table_name,
                          schema=schema,
                          record=record,
                          pk_column=pk_column)

@bp.route('/<table_name>/delete/<int:record_id>', methods=('POST',))
@login_required
def delete(table_name, record_id):
    """Delete a record from the table"""
    if table_name not in TABLES:
        abort(404)

    pk_column = get_primary_key(table_name)

    if not pk_column:
        flash('Cannot delete: No primary key found for this table.', 'danger')
        return redirect(url_for('tables.view_table', table_name=table_name))

    db = get_db()

    try:
        db.execute(f'DELETE FROM {table_name} WHERE {pk_column} = ?', (record_id,))
        db.commit()
        flash(f'Successfully deleted record from {table_name}!', 'success')
    except db.IntegrityError as e:
        flash(f'Cannot delete: {str(e)}', 'danger')

    return redirect(url_for('tables.view_table', table_name=table_name))
