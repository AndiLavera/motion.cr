import BindingManager from './BindingManager';
import Component from './Component';

export default class AttributeTracker {
  attribute: string;

  createManager: Function;

  _managers: Map<HTMLElement, BindingManager | Component>;

  _attributeSelector: string;

  _mutationObserver: MutationObserver;

  constructor(attribute: string, createManager: Function) {
    this.attribute = attribute;
    this.createManager = createManager;

    this._managers = new Map();
    this._attributeSelector = `[${attribute}]`;

    this._mutationObserver = new MutationObserver((mutations) => {
      for (const mutation of mutations) {
        this._processMutation(mutation);
      }
    });
  }

  attachRoot(element: HTMLElement): void {
    this._forEachMatchingUnder(element, (match) => this._detect(match));

    this._mutationObserver.observe(element, {
      attributes: true,
      attributeFilter: [this.attribute],
      childList: true,
      subtree: true,
    });
  }

  shutdown(): void {
    this._mutationObserver.disconnect();

    for (const manager of this._managers.values()) {
      if (manager) {
        this._errorBoundry(() => manager.shutdown());
      }
    }

    this._managers.clear();
  }

  getManager(element: HTMLElement): HTMLElement {
    return this._managers.get(element);
  }

  _detect(element: HTMLElement): void {
    let manager = null;

    this._errorBoundry(() => {
      if (this._managers.has(element)) {
        throw new Error('Double detect in AttributeTracker');
      }

      manager = this.createManager(element);
    });

    if (manager) this._managers.set(element, manager);
  }

  _update(element: HTMLElement): void {
    const manager = this._managers.get(element);

    if (manager && manager instanceof BindingManager) {
      this._errorBoundry(() => manager.update());
    } else {
      this._remove(element);
      this._detect(element);
    }
  }

  _remove(element: HTMLElement): void {
    const manager = this._managers.get(element);

    if (manager && manager.shutdown) {
      this._errorBoundry(() => manager.shutdown());
    }

    this._managers.delete(element);
  }

  _processMutation(mutation): void {
    if (mutation.type === 'childList') {
      this._processChildListMutation(mutation);
    } else if (mutation.type === 'attributes') {
      this._processAttributesMutation(mutation);
    }
  }

  _processChildListMutation({ removedNodes, addedNodes }): void {
    this._forEachMatchingIn(removedNodes, (match) => this._remove(match));
    this._forEachMatchingIn(addedNodes, (match) => this._detect(match));
  }

  _processAttributesMutation({ target }): void {
    if (this._managers.has(target)) {
      this._processAttributeUpdateToTracked(target);
    } else {
      this._processAttributeUpdateToUntracked(target);
    }
  }

  _processAttributeUpdateToTracked(element: HTMLElement): void {
    if (element.hasAttribute(this.attribute)) {
      this._update(element);
    } else {
      this._remove(element);
    }
  }

  _processAttributeUpdateToUntracked(element: HTMLElement): void {
    if (element.hasAttribute(this.attribute)) {
      this._detect(element);
    }
  }

  _forEachMatchingIn(nodes, callback: Function): void {
    for (const node of nodes) {
      this._forEachMatchingUnder(node, callback);
    }
  }

  _forEachMatchingUnder(node, callback: Function): void {
    if (node.hasAttribute && node.hasAttribute(this.attribute)) {
      callback(node);
    }

    if (node.querySelectorAll) {
      for (const match of node.querySelectorAll(this._attributeSelector)) {
        callback(match);
      }
    }
  }

  // eslint-disable-next-line class-methods-use-this
  _errorBoundry(callback: Function): void {
    try {
      callback();
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error('[Motion] An internal error occurred:', error);
    }
  }
}
