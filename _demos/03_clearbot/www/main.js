document.addEventListener('click', (event) => {
  const target = event.target.closest('[data-snapshot-index]');
  if (!target) return;
  
  event.preventDefault();
  
  const traceInput = document.querySelector('#trace_num');
  const traceOffcanvas = document.querySelector('#trace');
  
  traceInput.value = target.dataset.snapshotIndex;
  traceInput.dispatchEvent(new Event('change'));
  
  bootstrap.Offcanvas.getOrCreateInstance(traceOffcanvas).show();
});
