(function () {
    'use strict';

    function initChatbot() {
        var root = document.querySelector('.lc-chatbot');
        if (!root || root.dataset.initialized === 'true') {
            return;
        }
        root.dataset.initialized = 'true';

        var contextPath = root.getAttribute('data-context-path') || '';
        var panel = root.querySelector('.lc-chatbot__panel');
        var launcher = root.querySelector('.lc-chatbot__launcher');
        var closeButton = root.querySelector('.lc-chatbot__close');
        var form = root.querySelector('.lc-chatbot__form');
        var input = root.querySelector('.lc-chatbot__form input[name="mensaje"]');
        var messages = root.querySelector('.lc-chatbot__messages');
        var quickActions = root.querySelector('.lc-chatbot__quick-actions');
        var sending = false;

        function setOpen(open) {
            panel.hidden = !open;
            root.classList.toggle('lc-chatbot--open', open);
            launcher.setAttribute('aria-expanded', open ? 'true' : 'false');
            launcher.setAttribute('aria-label', open ? 'Cerrar LogiBot' : 'Abrir LogiBot');
            document.dispatchEvent(new CustomEvent('lc-chatbot-toggle'));

            if (open) {
                window.setTimeout(function () {
                    input.focus();
                    scrollToBottom();
                }, 60);
            }
        }

        function scrollToBottom() {
            messages.scrollTop = messages.scrollHeight;
        }

        function appendMessage(text, sender, options) {
            var row = document.createElement('div');
            row.className = 'lc-chatbot__message lc-chatbot__message--' + sender;

            if (sender === 'bot') {
                var avatar = document.createElement('span');
                avatar.className = 'lc-chatbot__mini-avatar';
                avatar.setAttribute('aria-hidden', 'true');
                avatar.innerHTML = '<i class="fa-solid fa-robot"></i>';
                row.appendChild(avatar);
            }

            var content = document.createElement('div');
            content.className = 'lc-chatbot__message-content';

            var bubble = document.createElement('div');
            bubble.className = 'lc-chatbot__bubble';
            bubble.textContent = text;
            content.appendChild(bubble);

            if (options && options.actionUrl && options.actionText) {
                var action = document.createElement('a');
                action.className = 'lc-chatbot__action-link';
                action.textContent = options.actionText;
                action.href = buildActionUrl(options.actionUrl);

                if (/^https?:\/\//i.test(options.actionUrl)) {
                    action.target = '_blank';
                    action.rel = 'noopener noreferrer';
                }
                content.appendChild(action);
            }

            row.appendChild(content);
            messages.appendChild(row);
            scrollToBottom();
        }

        function buildActionUrl(url) {
            if (!url) {
                return '#';
            }
            if (/^(https?:\/\/|mailto:|tel:)/i.test(url)) {
                return url;
            }
            return contextPath + '/' + url.replace(/^\//, '');
        }

        function addTypingIndicator() {
            var row = document.createElement('div');
            row.className = 'lc-chatbot__message lc-chatbot__message--bot lc-chatbot__typing-row';
            row.innerHTML = '<span class="lc-chatbot__mini-avatar" aria-hidden="true">'
                    + '<i class="fa-solid fa-robot"></i></span>'
                    + '<div class="lc-chatbot__bubble lc-chatbot__typing" aria-label="LogiBot está escribiendo">'
                    + '<span></span><span></span><span></span></div>';
            messages.appendChild(row);
            scrollToBottom();
            return row;
        }

        function renderSuggestions(suggestions) {
            if (!Array.isArray(suggestions) || !suggestions.length) {
                return;
            }

            quickActions.innerHTML = '';
            suggestions.slice(0, 4).forEach(function (suggestion) {
                var button = document.createElement('button');
                button.type = 'button';
                button.textContent = suggestion;
                button.setAttribute('data-chat-message', suggestion);
                quickActions.appendChild(button);
            });
        }

        function sendMessage(message) {
            var cleanMessage = (message || '').trim();
            if (!cleanMessage || sending) {
                return;
            }

            sending = true;
            appendMessage(cleanMessage, 'user');
            input.value = '';
            input.disabled = true;
            var typing = addTypingIndicator();

            var body = new URLSearchParams();
            body.set('mensaje', cleanMessage);

            fetch(contextPath + '/ChatbotServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                    'Accept': 'application/json'
                },
                body: body.toString(),
                credentials: 'same-origin'
            })
                .then(function (response) {
                    return response.json().then(function (data) {
                        return { ok: response.ok, status: response.status, data: data };
                    });
                })
                .then(function (result) {
                    typing.remove();
                    appendMessage(
                        result.data.respuesta || 'No se recibió una respuesta válida.',
                        'bot',
                        {
                            actionUrl: result.data.accionUrl,
                            actionText: result.data.accionTexto
                        }
                    );
                    renderSuggestions(result.data.sugerencias);

                    if (result.status === 401 && result.data.accionUrl) {
                        input.disabled = true;
                    }
                })
                .catch(function () {
                    typing.remove();
                    appendMessage(
                        'No pude comunicarme con el servidor. Verifica que Tomcat y la aplicación estén activos.',
                        'bot'
                    );
                })
                .finally(function () {
                    sending = false;
                    if (!input.disabled || input.disabled && document.body.contains(input)) {
                        input.disabled = false;
                        input.focus();
                    }
                });
        }

        launcher.addEventListener('click', function () {
            setOpen(panel.hidden);
        });

        closeButton.addEventListener('click', function () {
            setOpen(false);
            launcher.focus();
        });

        form.addEventListener('submit', function (event) {
            event.preventDefault();
            sendMessage(input.value);
        });

        quickActions.addEventListener('click', function (event) {
            var button = event.target.closest('[data-chat-message]');
            if (!button) {
                return;
            }
            sendMessage(button.getAttribute('data-chat-message'));
        });

        document.addEventListener('keydown', function (event) {
            if (event.key === 'Escape' && !panel.hidden) {
                setOpen(false);
                launcher.focus();
            }
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initChatbot);
    } else {
        initChatbot();
    }
}());
