export default function dispatchEvent(target: HTMLElement, name: string) {
  try {
    const event = new CustomEvent(name, {
      bubbles: true,
      cancelable: false,
    });

    // debugger
    target.dispatchEvent(event);
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Error while dispatching', name, 'on', target, error);
  }
}
