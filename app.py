from flask import Flask, render_template, request, redirect, url_for, session, flash, send_file
import sqlite3
from pathlib import Path
from functools import wraps
from io import BytesIO
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
import os
import smtplib
from email.mime.text import MIMEText

BASE_DIR = Path(__file__).resolve().parent
DB_PATH = BASE_DIR / 'receitas.db'

app = Flask(__name__)
app.secret_key = 'troque-esta-chave-em-producao'


def get_db_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def enviar_email(assunto, mensagem, destinatario=None):
    remetente = os.getenv('EMAIL_REMETENTE')
    senha = os.getenv('EMAIL_SENHA')
    destino = destinatario or os.getenv('EMAIL_DESTINO')

    if not remetente or not senha or not destino:
        print('E-mail não enviado: variáveis EMAIL_REMETENTE, EMAIL_SENHA ou EMAIL_DESTINO não configuradas.')
        return

    msg = MIMEText(mensagem, 'plain', 'utf-8')
    msg['Subject'] = assunto
    msg['From'] = remetente
    msg['To'] = destino

    with smtplib.SMTP('smtp.gmail.com', 587) as servidor:
        servidor.starttls()
        servidor.login(remetente, senha)
        servidor.send_message(msg)

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
    filtro_tipo = request.args.get('tipo', '').strip().lower()
    filtro_status = request.args.get('status', '').strip().lower()
    data_inicio = request.args.get('data_inicio', '').strip()
    data_fim = request.args.get('data_fim', '').strip()

    query = 'SELECT * FROM receita WHERE 1=1'
    params = []

    if filtro_tipo in ('doce', 'salgada'):
        query += ' AND tipo_receita = ?'
        params.append(filtro_tipo)

    if filtro_status in ('ativa', 'inativa'):
        query += ' AND status = ?'
        params.append(filtro_status)

    if data_inicio:
        query += ' AND data_registro >= ?'
        params.append(data_inicio)

    if data_fim:
        query += ' AND data_registro <= ?'
        params.append(data_fim)

    query += ' ORDER BY id'

    conn = get_db_connection()
    receitas = conn.execute(query, params).fetchall()
    conn.close()

    return render_template(
        'receitas.html',
        receitas=receitas,
        filtro=filtro_tipo,
        filtro_status=filtro_status,
        data_inicio=data_inicio,
        data_fim=data_fim
    )

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
            request.form['status'].strip().lower(),
        )
        conn = get_db_connection()
        conn.execute(
            'INSERT INTO receita (nome, descricao, data_registro, custo, tipo_receita, status) VALUES (?, ?, ?, ?, ?, ?)',
            dados,
        )
        conn.commit()
        conn.close()
        
        enviar_email(
            'Receita cadastrada com sucesso',
            f'A receita "{dados[0]}" foi cadastrada no sistema com status "{dados[5]}".'
        )

        flash('Receita cadastrada com sucesso.', 'sucesso')
        return redirect(url_for('listar_receitas'))
    return render_template('form_receita.html', receita=None, acao='Nova Receita')

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


    if request.method == 'POST':
        dados = (
            request.form['nome'].strip(),
            request.form['descricao'].strip(),
            request.form['data_registro'].strip(),
            request.form['custo'].strip(),
            request.form['tipo_receita'].strip().lower(),
            request.form['status'].strip().lower(),
            id,
        )
        conn.execute(
            'UPDATE receita SET nome = ?, descricao = ?, data_registro = ?, custo = ?, tipo_receita = ?, status = ? WHERE id = ?',
            dados,
        )
        conn.commit()
        conn.close()
        flash('Receita atualizada com sucesso.', 'sucesso')
        return redirect(url_for('listar_receitas'))

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
            request.form['status'].strip().lower(),
            id,
        )
        conn.execute(
            'UPDATE receita SET nome = ?, descricao = ?, data_registro = ?, custo = ?, tipo_receita = ?, status = ? WHERE id = ?',
            dados,
        )
        conn.commit()
        conn.close()

        enviar_email(
            'Receita atualizada com sucesso',
            f'A receita "{dados[0]}" foi atualizada no sistema com status "{dados[5]}".'
        )

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

@app.route('/receitas/pdf')
@login_required
def exportar_pdf():
    conn = get_db_connection()
    receitas = conn.execute('SELECT * FROM receita ORDER BY id').fetchall()
    conn.close()

    buffer = BytesIO()
    pdf = canvas.Canvas(buffer, pagesize=A4)
    largura, altura = A4

    pdf.setTitle('Relatorio de Receitas')
    pdf.setFont('Helvetica-Bold', 14)
    pdf.drawString(40, altura - 40, 'Relatório de Receitas')

    y = altura - 80
    pdf.setFont('Helvetica', 10)

    for receita in receitas:
        linha = (
            f"ID: {receita['id']} | "
            f"Nome: {receita['nome']} | "
            f"Tipo: {receita['tipo_receita']} | "
            f"Status: {receita['status']}"
        )
        pdf.drawString(40, y, linha)
        y -= 18

        if y < 40:
            pdf.showPage()
            pdf.setFont('Helvetica', 10)
            y = altura - 40

    pdf.save()
    buffer.seek(0)

    return send_file(
        buffer,
        as_attachment=True,
        download_name='receitas.pdf',
        mimetype='application/pdf'
    )

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
