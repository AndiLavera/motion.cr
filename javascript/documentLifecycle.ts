function once(target: Document | (Window & typeof globalThis), event: string, callback: Function) {
  target.addEventListener(event, function handler(event: string) {
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
    once(window, 'beforeunload', ({ defaultPrevented }: any) => {
      if (!defaultPrevented) {
        resolve();
      }
    });
  }, true);
});
