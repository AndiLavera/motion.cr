import Consumer from './Consumer';

let fallbackConsumer = null

export default function getFallbackConsumer() {
  fallbackConsumer = new Consumer(getConfig("url") || '/cable')
  // console.log(fallbackConsumer)
  // debugger
  return fallbackConsumer
}

export function getConfig(name) {
  const element = document.head.querySelector(`meta[name='action-cable-${name}']`)
  if (element) {
    return element.getAttribute("content")
  }
}
