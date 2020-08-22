import IEvent from './event_interface'

export default interface ISubscriptionPayload {
  name: string
  event: IEvent
}