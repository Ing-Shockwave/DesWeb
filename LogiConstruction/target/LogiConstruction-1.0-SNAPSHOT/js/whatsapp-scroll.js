(function () {
    'use strict';

    // El botón aparece cuando faltan 220 px o menos para llegar al final.
    var END_THRESHOLD_PX = 220;
    var ticking = false;
    var resizeObserver = null;

    function initWhatsAppScrollButton() {
        var widgets = document.querySelectorAll('.lc-whatsapp');

        if (!widgets.length) {
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

            widgets.forEach(function (widget) {
                var link = widget.querySelector('.lc-whatsapp__button');

                widget.classList.toggle('lc-whatsapp--visible', shouldShow);
                widget.setAttribute('aria-hidden', shouldShow ? 'false' : 'true');

                if (link) {
                    link.setAttribute('tabindex', shouldShow ? '0' : '-1');
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

        // Actualiza el estado si DataTables, JSF u otro componente cambia la altura.
        if ('ResizeObserver' in window && document.body) {
            resizeObserver = new ResizeObserver(requestUpdate);
            resizeObserver.observe(document.body);
        }

        updateVisibility();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initWhatsAppScrollButton);
    } else {
        initWhatsAppScrollButton();
    }
}());
