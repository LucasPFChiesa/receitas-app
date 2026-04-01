from flask import Flask, render_template, request, redirect, url_for, session, flash
import sqlite3
from pathlib import Path
from functools import wraps

BASE_DIR = Path(__file__).resolve().parent
DB_PATH = BASE_DIR / 'receitas.db'

app = Flask(__name__)
app.secret_key = 'troque-esta-chave-em-producao'


def get_db_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def login_required(view):
    @wraps(view)
    def wrapped_view(*args, **kwargs):
        if 'usuario_id' not in session:
            return redirect(url_for('login'))
        return view(*args, **kwargs)
    return wrapped_view


@app.route('/')
def index():
    if 'usuario_id' in session:
        return redirect(url_for('listar_receitas'))
    return redirect(url_for('login'))


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        login_informado = request.form['login'].strip()
        senha_informada = request.form['senha'].strip()

        conn = get_db_connection()
        usuario = conn.execute(
            'SELECT * FROM usuario WHERE login = ? AND senha = ? AND situacao = ?',
            (login_informado, senha_informada, 'ativo')
        ).fetchone()
        conn.close()

        if usuario:
            session['usuario_id'] = usuario['id']
            session['usuario_nome'] = usuario['nome']
            return redirect(url_for('listar_receitas'))

        flash('Login, senha ou situação do usuário inválidos.', 'erro')

    return render_template('login.html')


@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))


@app.route('/receitas')
@login_required
def listar_receitas():
    filtro = request.args.get('tipo', '').strip().lower()
    conn = get_db_connection()
    if filtro in ('doce', 'salgada'):
        receitas = conn.execute(
            'SELECT * FROM receita WHERE tipo_receita = ? ORDER BY id', (filtro,)
        ).fetchall()
    else:
        receitas = conn.execute('SELECT * FROM receita ORDER BY id').fetchall()
    conn.close()
    return render_template('receitas.html', receitas=receitas, filtro=filtro)


@app.route('/receitas/nova', methods=['GET', 'POST'])
@login_required
def nova_receita():
    if request.method == 'POST':
        dados = (
            request.form['nome'].strip(),
            request.form['descricao'].strip(),
            request.form['data_registro'].strip(),
            request.form['custo'].strip(),
            request.form['tipo_receita'].strip().lower(),
        )
        conn = get_db_connection()
        conn.execute(
            'INSERT INTO receita (nome, descricao, data_registro, custo, tipo_receita) VALUES (?, ?, ?, ?, ?)',
            dados,
        )
        conn.commit()
        conn.close()
        flash('Receita cadastrada com sucesso.', 'sucesso')
        return redirect(url_for('listar_receitas'))
    return render_template('form_receita.html', receita=None, acao='Nova Receita')


@app.route('/receitas/editar/<int:id>', methods=['GET', 'POST'])
@login_required
def editar_receita(id):
    conn = get_db_connection()
    receita = conn.execute('SELECT * FROM receita WHERE id = ?', (id,)).fetchone()

    if receita is None:
        conn.close()
        flash('Receita não encontrada.', 'erro')
        return redirect(url_for('listar_receitas'))

    if request.method == 'POST':
        dados = (
            request.form['nome'].strip(),
            request.form['descricao'].strip(),
            request.form['data_registro'].strip(),
            request.form['custo'].strip(),
            request.form['tipo_receita'].strip().lower(),
            id,
        )
        conn.execute(
            'UPDATE receita SET nome = ?, descricao = ?, data_registro = ?, custo = ?, tipo_receita = ? WHERE id = ?',
            dados,
        )
        conn.commit()
        conn.close()
        flash('Receita atualizada com sucesso.', 'sucesso')
        return redirect(url_for('listar_receitas'))

    conn.close()
    return render_template('form_receita.html', receita=receita, acao='Editar Receita')


@app.route('/receitas/excluir/<int:id>', methods=['POST'])
@login_required
def excluir_receita(id):
    conn = get_db_connection()
    conn.execute('DELETE FROM receita WHERE id = ?', (id,))
    conn.commit()
    conn.close()
    flash('Receita excluída com sucesso.', 'sucesso')
    return redirect(url_for('listar_receitas'))


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
