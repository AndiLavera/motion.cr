export default function dispatchEvent(target: HTMLElement, name: string) {
  try {
    const event = new CustomEvent(name, {
      bubbles: true,
      cancelable: false,
    });

    // debugger
    target.dispatchEvent(event);
  } catch (error) {
    console.error('Error while dispatching', name, 'on', target, error);
  }
}
