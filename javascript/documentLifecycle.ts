function once(target, event, callback) {
  target.addEventListener(event, function handler(event) {
    target.removeEventListener(event, handler);

    callback(event);
  });
}

export const documentLoaded = new Promise<any>((resolve) => {
  if (/^loaded|^i|^c/i.test(document.readyState)) {
    resolve();
  } else {
    once(document, 'DOMContentLoaded', resolve);
  }
});

export const beforeDocumentUnload = new Promise<any>((resolve) => {
  window.addEventListener('beforeunload', () => {
    once(window, 'beforeunload', ({ defaultPrevented }) => {
      if (!defaultPrevented) {
        resolve();
      }
    });
  }, true);
});
