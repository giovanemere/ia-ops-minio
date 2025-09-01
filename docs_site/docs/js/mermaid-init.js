window.addEventListener('load', function() {
    if (typeof mermaid !== 'undefined') {
        mermaid.initialize({
            startOnLoad: true,
            theme: 'default',
            securityLevel: 'loose',
            flowchart: {
                useMaxWidth: true,
                htmlLabels: true
            }
        });
        
        // Re-render any mermaid diagrams
        const mermaidElements = document.querySelectorAll('.mermaid');
        mermaidElements.forEach((element, index) => {
            const id = 'mermaid-' + index;
            element.id = id;
            mermaid.render(id + '-svg', element.textContent, (svgCode) => {
                element.innerHTML = svgCode;
            });
        });
    }
});
