#!/usr/bin/env python3

from flask import Flask, g, redirect, request

from mod_hello import mod_hello
from mod_user import mod_user
from mod_posts import mod_posts
from mod_mfa import mod_mfa

import libsession

app = Flask('vulpy')
app.config['SECRET_KEY'] = 'aaaaaaa'

app.register_blueprint(mod_hello, url_prefix='/hello')
app.register_blueprint(mod_user, url_prefix='/user')
app.register_blueprint(mod_posts, url_prefix='/posts')
app.register_blueprint(mod_mfa, url_prefix='/mfa')


@app.route('/')
def do_home():
    return redirect('/posts')

@app.before_request
def before_request():
    g.session = libsession.load(request)

# SECURITY FIX #1: Disable debug mode in production
# Debug mode exposes Werkzeug debugger allowing arbitrary code execution
# SECURITY FIX #2: Use secure SSL certificate paths (not /tmp)
if __name__ == '__main__':
    import os
    debug_mode = os.environ.get('FLASK_ENV') == 'development'
    
    # Use environment variables for SSL paths instead of hardcoded /tmp
    cert_path = os.environ.get('SSL_CERT_PATH', '/etc/ssl/certs/server.crt')
    key_path = os.environ.get('SSL_KEY_PATH', '/etc/ssl/private/server.key')
    
    # Verify certificates exist before starting
    if not (os.path.exists(cert_path) and os.path.exists(key_path)):
        raise ValueError(f"SSL certificates not found at {cert_path} or {key_path}")
    
    app.run(
        debug=debug_mode,
        host='0.0.0.0',
        ssl_context=(cert_path, key_path)
    )
