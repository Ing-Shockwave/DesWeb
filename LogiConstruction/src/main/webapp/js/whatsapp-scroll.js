(function () {
    'use strict';

    // Los botones aparecen cuando faltan 220 px o menos para llegar al final.
    var END_THRESHOLD_PX = 220;
    var ticking = false;
    var resizeObserver = null;

    function initSupportButtonsVisibility() {
        var whatsappWidgets = document.querySelectorAll('.lc-whatsapp');
        var chatbotWidgets = document.querySelectorAll('.lc-chatbot');

        if (!whatsappWidgets.length && !chatbotWidgets.length) {
            return;
        }

        function updateVisibility() {
            var doc = document.documentElement;
            var body = document.body;
            var scrollTop = window.pageYOffset || doc.scrollTop || body.scrollTop || 0;
            var viewportHeight = window.innerHeight || doc.clientHeight;
            var documentHeight = Math.max(
                body.scrollHeight,
                body.offsetHeight,
                doc.clientHeight,
                doc.scrollHeight,
                doc.offsetHeight
            );

            var remainingDistance = documentHeight - (scrollTop + viewportHeight);
            var pageHasScroll = documentHeight > viewportHeight + 80;
            var shouldShow = !pageHasScroll || remainingDistance <= END_THRESHOLD_PX;

            whatsappWidgets.forEach(function (widget) {
                var link = widget.querySelector('.lc-whatsapp__button');

                widget.classList.toggle('lc-whatsapp--visible', shouldShow);
                widget.setAttribute('aria-hidden', shouldShow ? 'false' : 'true');

                if (link) {
                    link.setAttribute('tabindex', shouldShow ? '0' : '-1');
                }
            });

            chatbotWidgets.forEach(function (widget) {
                var launcher = widget.querySelector('.lc-chatbot__launcher');
                var chatbotShouldShow = shouldShow || widget.classList.contains('lc-chatbot--open');

                widget.classList.toggle('lc-chatbot--visible', shouldShow);
                widget.setAttribute('aria-hidden', chatbotShouldShow ? 'false' : 'true');

                if (launcher) {
                    launcher.setAttribute('tabindex', chatbotShouldShow ? '0' : '-1');
                }
            });

            ticking = false;
        }

        function requestUpdate() {
            if (!ticking) {
                window.requestAnimationFrame(updateVisibility);
                ticking = true;
            }
        }

        window.addEventListener('scroll', requestUpdate, { passive: true });
        window.addEventListener('resize', requestUpdate);
        window.addEventListener('load', requestUpdate);
        document.addEventListener('lc-chatbot-toggle', requestUpdate);

        // Actualiza el estado si DataTables, JSF u otro componente cambia la altura.
        if ('ResizeObserver' in window && document.body) {
            resizeObserver = new ResizeObserver(requestUpdate);
            resizeObserver.observe(document.body);
        }

        updateVisibility();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initSupportButtonsVisibility);
    } else {
        initSupportButtonsVisibility();
    }
}());
